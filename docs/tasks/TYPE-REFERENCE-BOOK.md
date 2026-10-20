# TYPE-REFERENCE-BOOK: Complete navigable per-type language reference

## Metadata

- Tree ID: `TYPE-REFERENCE-BOOK`
- Status: `active` / numeric .1.2.5 follows completed scoped-callable repair; before enumeration
- Roadmap lane: `.spec language documentation / complete type and method reference`
- Created: `2026-10-10`
- Last updated: `2026-10-20`
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
  Children: `TYPE-REFERENCE-BOOK.1.2.0`, `TYPE-REFERENCE-BOOK.1.2.3`, `TYPE-REFERENCE-BOOK.1.2.4`, `TYPE-REFERENCE-BOOK.1.2.5`, `TYPE-REFERENCE-BOOK.1.2.6`, `TYPE-REFERENCE-BOOK.1.2.7`, `TYPE-REFERENCE-BOOK.1.2.1`, `TYPE-REFERENCE-BOOK.1.2.2`.
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
  Reproduce: Retained distinguish cases bare-scalar-across-call, array-helper-across-call and codeblock-arguments. A callback changing marker from before to inside also changes the earlier bare marker argument; scalar-rvalue, saved-binding and registered named-function controls retain before. Both Get and fresh generated source agree.
  Impact: Sibling evaluation changes already encountered scalar values, making constructor and callable behavior depend on Perl lvalue stack aliasing.
  Root cause: Actual emitted source places $marker directly around invoke in a Perl list. MethodLowering array_literal and lower_ast_codeblock_variable_call_node join lowered expressions without sequential value temporaries; named-function arguments already use temporaries. Full source/channels precede conclusions in the inventory capsules.
  Schedule: Immediately after .1.2.0 commits, before complete operation enumeration. This intake creates ownership, not a dirty runtime pivot.
  Owned paths: perl/LinkedSpec/ActionIR/MethodLowering.pm, the already canonically selected t/callable_codeblock_literal_contract.t, t/actionir_ast_parser.t and t/trace_actionir_method_lowering.t and required t/phase0_regression.t direct-consumer assertions plus tests/evaluated-values/cases.json, public probes/readers under docs/checkpoints/type-evaluated-values/ and docs/checkpoints/TYPE-REFERENCE-BOOK.1.2.3-*, relevant book/Knowledge clarification, whole prior publication preservation and normal continuity. Split before unrelated runtime families.
  Verification tier: `canonical`
  Focused checks: Native-first Get/descriptor/fresh generated-source impact matrix; once/order/kind/caller/alias and name-collision controls; actual unchanged baseline RED and candidate GREEN/source inverses; direct AST/lowering/generated/uniform/callable/variadic consumers; current complete Knowledge/book, histories, memory and all doctrines.
  Canonical trigger: Observable evaluated-value/runtime correction; exact staged candidate must pass approved-host tools/run_ci_local.sh and normal receipt-bound hooks.
  Claim verification: `docs/claims/TYPE-REFERENCE-BOOK.1.2.3.json`
  Acceptance: Distinguish scalar evaluation from intentional container aliases and dynamic caller mutations; repair every demonstrated route with precise once/order tests, independent fresh emitted proof and direct consumers. Split new failure families before writes, update book/facts and run canonical candidate proof.

  Activation: Clean c053c9dcf24a78cc8b551187f47cdb7aefb03eb3 after all10 normal hooks, final readonly388/full68814, explicit post-pointer/post-memory, brief0 and clean Git. Preserve the whole current inventory record, every input/mode, full nested1300-source and1487-graph context and actual readonly baseline before any bound write. Extend public impact probes to adjacent construction/argument forms before choosing the smallest complete repair. Existing caller-local shadowing is separately owned by SESSION-STARTUP-READING.32; do not copy its known shadowing pattern or silently close that owner.
  Ancillary continuity defect owned here: ROADMAP_V2 still labels .1.1/.1.2 activation as current after completed .1.2.0; update its two current paragraphs during this activation, preserving dated chronology.

  Impact extension before runtime writes: Native23 plus independent host controls retain unchanged1303 inputs. Hash values, hash constructors, dynamic hash keys and array/harray/callable rebinding show the same Perl list-slot late read. Eager blocks/assignment values reproduce it without a deferred call; an interpreted nested codeblock-body array already preserves the early scalar. Host isolated scalar temporaries preserve early values, same-name caller initialization and reference identity. The initial plan provisionally calls one array mutation question a shared-reference control; its later rejected-oracle epoch below corrects that classification; this is not a deep-copy/alias parity claim. Initial boolean-body case intersects known SESSION-STARTUP-READING.35 literal-kind drift; use an explicit boolean parameter in the final value-order regression. The initial repeated-counter case instead raises unknown_helper:num_add with a retained diagnostic prelude; .1.2.5 owns that separate helper gap and a cat-based ordered-state control avoids relying on it here. Both initial observations remain immutable.

  Rejected first candidate/oracle epoch: Original23-case plan has18 timing REDs and5 nominal controls. Candidate fixes18 but the array-mutation question then disagrees with its original expected first value. Independent saved-binding Get/generated controls yield saved old/current updated, and the existing perl-uniform-binding-runtime card plus unchanged push_value producer establish copy-on-write. The original plan wrongly classified late scalar-slot observation as reference mutation. Preserve every original case/producer/result; a separate one-row correction requires a fresh accepted-runtime baseline. Host reference-identity controls remain valid and separate. First direct consumers pass generated-source/uniform/variadic behavior but old AST/trace exact-source assertions fail; replace those representation checks with executed-value observations while preserving poisoned-source and trace checks. No production change is justified by rewriting an expected value alone.

  Input-closure repair before admission: The first corrected supplied baseline retains syntax2/TAP2 because t/callable_codeblock_literal_contract.t was not materialized; its public baseline still executes. The original conservative1300/1303 selection omitted .t, and root tests/ JSON data also falls outside that selection. Source proposals already retain the changed callable test; unchanged originals remain recoverable from real c053 Git, but missing first per-test manifest/mode assertions are not invented. Preserve all old actors/capsules/channels; a distinct fresh supplement retains actual277 owned t/tests/bin inputs and all seven selected suites before a separate final baseline/candidate epoch. This repairs proof custody without altering the runtime candidate or admitting the incomplete TAP result.

  Phase0 consumer follow-up owned here: Required broader Phase0 reveals old exact-source assertions for array/hash and nested pipeline constructors. Preserve the whole draft publication and all bound inputs before test/reviewer/publisher edits; replace only obsolete layout assertions with executed-value observations. The first bare prove invocation also failed the same-volume fixture check because it bypassed the documented project-data wrapper; its actual cleanup assertion passes. Retain the full failed run and use the wrapper for the complete corrected rerun. No production defect or behavioral RED is inferred from representation/environment failures.

  Publication refinement: The initial uncommitted568-input/full91709-byte draft, full receipt, manifest and original producer/README bytes are retained in docs/checkpoints/TYPE-REFERENCE-BOOK.1.2.3-publication-guard.json.gz. Every original binding hash/mode is verified before guarded writes; all other inputs remain at their exact tracked paths. The separate final manifest is a direct claim binding. No fabricated historical revision or measurement refresh.

  Completion: Evaluated-list operands retain earlier values across later effects and preserve explicit splices. Accepted19 RED/four controls becomes23 native/fresh-generated GREEN; seven suites use277 declared test/data/bin inputs. Six emitter faults reject19/14/2/1/1/1 and restore. Focused52 preserves982 skips in1651 supplied files; ordinary all1035 passes separately. Observer129 RED/one null, missing-selector RED and restoration remain effective. Twelve recurring suites retain4998 assertions plus3 value/ABI goldens:5001 quiet PASS; mapper bypass fails198 and restores. Three exact owner/prior/current scanner admissions retain original registrations;28 denials and actual check-removal faults9/6/3 pass. Two oversized streams become31 bounded chunks with exact bytes/modes and retained-review use in explicit original scanner context;500733803 duplicate bytes are removed with residue0. Historical metadata has4 denials/actual guard RED1; current reads stay unchanged. Whole837/full130737 and actual readonly0 survive; one physical input becomes an index, preserving all original logical inputs. Fresh845/full130759 binds the complete4178-input closure including4163 scanner candidates, with no oversized files. Graph1487/1349/10462 preserves897 entries/248 fields at8388584 Knowledge bytes; book89/heading denial and whole388/full68814/2706 replay pass. Rejected/preparation epochs retain their original limits and bytes. Scoped-with4, numeric5 and generated-drop6 remain owned; no exhaustive type, cross-backend or private/parent admission. Exact staged canonical receipt and normal hooks govern landing; derive actual admission identity from Git.


  Admission supplement: docs/checkpoints/type-values-admission/ retains the whole636-input draft identity, every binding hash/mode, changed-before bytes, actual readonly0, exact first staged binary patch at the real activation base, and first canonical CI1. Its report passes eight doctrines and rejects only missing acceptance evidence plus one absolute derived display path. The independent wrapped ordinary entrypoint reaches1035/1035 with exit0, no stderr, no exclusions and an empty new-failure set. The derived display becomes repository-relative through separate portable actors/proposals; original raw observations and every former actor remain recoverable. No runtime, warning policy or expected value changes during admission repair.

  Historical-auditor prerequisite owned here: The second canonical candidate passes all10 doctrines, then the isolated objective-evidence audit rejects the reviewed Phase0 representation changes at verify_signature_regression_evolution. Its exact staged candidate and full failure remain retained. Before bound writes preserve the whole649-input draft and actual default readonly baseline. Extend the historical auditor only with an exact, owner-bound inverse of the reviewed Phase0 delta; recover the original complete historical bytes and unchanged hash. Own tests/language-readiness/verify_objectives.py, its neutral inverse fixture, the maintained isolated recovery instrument if needed to retain that new input, docs/checkpoints/type-values-signature/ and the corresponding fact/book explanation. Preserve all existing denial controls, add distinguishing missing/duplicate/altered/foreign source denials and rerun the actual isolated historical proof before canonical retry. No historical milestone, capture hash, log or runtime behavior is refreshed.

  Historical admission verification: The complete isolated proof now passes with184 declared producer inputs, the original134 archived inputs/84,613,241 bytes,22 recovery controls and zero original-log reads/tracked writes. All368 original auditor denials remain effective;70 reviewed fragments add210 source denials for578 total. A whitespace-only, semantically identical JSON table mutation rejects by exact input identity and the reader restores. The first new-control loop shadowed its outer governance row and raised KeyError historical; original source/inputs/channels remain in the signature checkpoint, and a separate two-reference correction is verified. This instrument error is not behavioral RED. Existing source snapshots retain their original auditor; its independently proved current evolution is explicitly separate. Historical hashes, logs and runtime observations stay unchanged.

  Original-control baseline closure repair: capture_corrected.py supplies c053 Phase0 bytes but its baseline_reader otherwise delegates to original repository paths, including historical logs. The candidate isolated proof has the measured zero-read/write boundary; that boundary is not inferred for the outer baseline. Preserve the first baseline/report and add a distinct baseline through the validated134-input archive under calibrated original-log/tracked-write denial. Retain initial input modes/identities and prove the same original control population before using that baseline as complete current claim evidence. This bounded custody repair is owned here; no historical log, hash or source is refreshed.

  Private recurring-consumer prerequisite owned here: Canonical3 passes the new historical audit and the runtime contract families, then the complete private suite exposes202 stale assertions in12 files. Eleven consumers include198 frozen MethodLowering diagnostic-coordinate comparisons after the nine-line helper insertion; four source representations cover general-return, array/hash public expressions and the inner/scalar invocation. Preserve whole823/current readonly before bound edits. Own the affected general-return, array/scalar/hash receiver-required, array-end-required, hash-index-required, dropped-trim, small-kind, method-kind, source-assignment-kind, AST-optional and formal-trim .t consumers; add shared test-only source-coordinate support and docs/checkpoints/type-values-required/. Derive coordinate correspondence from unchanged statements in the same named routine against real c053 source, preserving callback/file/line distinctions and all frozen native rows. Execute the general-return source to observe its nested value. Keep plans/effect/alias/authority checks and add distinguishing wrong-callback/file/line and mapper controls; no production change or historical observation refresh is authorized by these stale tests.

  Recurring-consumer verification: Complete12 suites retain4998 original assertions and add3 independent value/ABI goldens, all5001 GREEN. Exact same-routine source correspondence preserves callback/file/line distinctions and frozen native records. Actual mapper bypass causes198 failures; restoration passes5001, and14 native/value controls pass. Full supplied context retains15 literal native JSON inputs. The first control omitted captures and an earlier callback; the separate census guard guessed14 instead of observed15. All rejected sources/channels remain preparation failures, not behavioral RED. Two duplicate input capsules recover their exact original gzip bytes/modes/hashes through verified references. Whole823 draft/default0 remains; all823 prior direct claim bindings stay, while a closed hash manifest gates every new supporting source/artifact and native input under the unchanged cap. Canonical retry and normal hooks remain the admission boundary.

  Observer-advisory follow-up: A test-only invocation replacement introduced two redefinition advisories. Clear its localized glob before installing the stub; warning settings remain enabled. Current5001 and the independent observer probe have empty stderr through approved host execution. Keep the first837-input manifest/stopped143 attempt, failed preparation guard and restricted-wrapper process-group diagnostic separate from behavioral RED. The current complete support manifest is closure-final.json; the earlier manifest remains immutable.

  Selector admission prerequisite owned here: Canonical4 passes all10 doctrines and the reached runtime contracts, then aggregate-selector admission rejects three edited diagnostic fixtures whose original byte registrations are unchanged. Own tools/check_executable_aggregate_selector_sources.py and docs/checkpoints/type-values-selector/. Preserve whole837/full130737, every input/mode, actual default readonly baseline and the exact failed candidate before bound writes. Keep original historical path/hash registrations; add only exact owner-bound reviewed fixture admissions after proving the selector occurrence populations and existing negative diagnostics unchanged. Edited/copied/appended-positive/wrong-owner/prior/current hash and missing-registration controls must reject and restore. No public selector syntax or classifier pattern may be broadened; current source/claim/book and canonical retry remain required.

  Oversized checkpoint repair owned here: A staged-file census finds docs/checkpoints/type-values-admission/canonical1-candidate.patch.gz at131321076 bytes, exceeding GitHub's100MiB normal-Git file limit (https://docs.github.com/en/repositories/working-with-files/managing-large-files/about-large-files-on-github). The new complete failed-candidate capsule is also oversized. Before landing, partition both exact byte streams into bounded repository-local chunks with per-part and whole-stream hashes/modes, prove copy/reconstruct/use and distinguishing corruption/truncation/order failures, then remove only the duplicate originals and census resulting staged blobs. Preserve all original logical inputs and whole837/default0; explicitly disclose the physical input migration rather than promising unchanged direct paths or inventing a historical revision. Own the narrow checkpoint reader/publisher integration and storage explanation here; no LFS, external storage, original observation change or verification weakening.

  Complete selector input closure: The first finite fixture/producer-fault capsule binds the old837 closure and actual three-fixture context; its supplemental global command outputs do not invent a full initial repository candidate manifest. After all new source and storage artifacts are fixed, capture every actual scanner candidate input/hash/mode before the fresh composed scan and publication re-derivation. Keep this final closure distinct from the earlier finite control epoch and gate all retained producers/artifacts.

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
  Status: `pending` / P2 generated single-key drop diagnostic
  Goal: Emit warning-free Perl for scalar-key drop while preserving hash-copy and multi-key semantics.
  Dependencies: `TYPE-REFERENCE-BOOK.1.2.5`
  Reproduce: Current public Top/x probe initializes meta={kind:node,debug:1} and returns drop_keys(meta,"debug"). Descriptor and Get succeed without warnings; fresh generated loading emits one scalar hash-slice advisory and still returns {kind:node}. The separate generated caller using warnings FATAL=>'syntax' fails to load with that exact advisory. Full inputs, route channels and source precede classification in phase0-warning-routes artifacts under the .1.2.3 checkpoint prefix.
  Mechanism: Actual generated line49 contains delete @__ls_drop{"debug"}; MethodLowering.pm's drop_keys emission at the current line6625 always joins keys into a hash slice. The compiler explicitly requests scalar deletion for a known single key. Resolve actual accepted-input baseline and literal/computed/flat key cardinality before choosing a fix; do not infer a public pre-change observation merely from source similarity.
  Impact: Exported Perl cannot load under a caller fatal syntax-warning profile for this otherwise valid operation.
  Schedule: After scoped-with .1.2.4 and deferred numeric helpers .1.2.5, before complete operation enumeration .1.2.1.
  Owned paths: Bounded drop_keys MethodLowering producer, existing selected receiver/hash/native/generated tests, public advisory/FATAL reproducer, two new Phase0 compatibility warning goldens, book/fact clarification and whole prior-publication preservation.
  Planned tier: `canonical`; observable generated-source/compiler diagnostic correction.
  Claim verification: none: Current diagnostic intake is retained by .1.2.3. Declare the complete source-bound accepted baseline, warning/FATAL RED, candidate and source controls at activation.
  Acceptance: Verify ordinary/fresh generated values and zero unexpected warnings under ordinary and fatal caller profiles for one/multiple/computed keys, missing/empty keys and relevant aliases/receiver forms. Preserve independent copied results, explicit splices and actual invalid-kind/key diagnostics. Update the two explicitly retained compiler-advisory goldens only with the actual fix. No blanket hash-helper admission.

- ID: `TYPE-REFERENCE-BOOK.1.2.7`
  Status: `pending` / deferred aggregate availability
  Goal: Repair deferred aggregate numeric helpers/overloads and receivers.
  Dependencies: `TYPE-REFERENCE-BOOK.1.2.6`
  Reproduce/impact: Numeric5 red-run retains unknown_helper for num_sum([1,2]), num_min([2,1]) and [2,1].min(); public reducers unavailable in callbacks.
  Planned tier: `focused`; existing contracts.
  Claim verification: none: Intake retained by5; bind complete family/RED before repair.
  Acceptance: Reconcile reducer contract/spellings, overloads, kinds/empty/errors/effects and native/generated controls; preserve scalar5, update book/facts and direct consumers.

- ID: `TYPE-REFERENCE-BOOK.1.2.1`
  Status: `pending`
  Goal: Enumerate every supported operation and spelling from the retained authority population, grouped by actual type and syntax role.
  Dependencies: `TYPE-REFERENCE-BOOK.1.2.7`
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
| 4 | `TYPE-REFERENCE-BOOK.1.2.6` | `pending` | P2 generated scalar-drop advisory/FATAL load failure before enumeration. |
| 5 | `TYPE-REFERENCE-BOOK.1.2.7` | `pending` | Deferred aggregates before enumeration. |
| 6 | `TYPE-REFERENCE-BOOK.1.2.1` | `pending` | Enumerate complete supported operations/spellings after the owned P1 repairs. |
| 7 | `TYPE-REFERENCE-BOOK.1.2.2` | `pending` | Map every reconciled item to actual book coverage. |
| 8 | `TYPE-REFERENCE-BOOK.1.3` | `pending` | Independently review the complete inventory and bounded layout plan. |
| 9 | `TYPE-REFERENCE-BOOK.8` | `pending` | Reconcile owned legacy metadata contradictions from exact history. |
| 10 | `PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.13` | `pending` | Deferred unconfirmed literal-rendering question after Type .1/.8. |
| 11 | `TYPE-REFERENCE-BOOK.2` | `pending` | Inventory-backed type-family references and independent .7 closeout follow. |

## Decisions

- `2026-10-10`: DBIQNP authorizes discussion without pivot. Record and schedule the confirmed qualitative gap;
  do not claim unsupported missing-method counts or start reference restructuring during the current AST work.
- `2026-10-10`: Inventory actual language contracts before choosing the final type taxonomy or section layout.
  Historical book closeouts remain dated evidence; this tree owns the newly stated per-type completeness criterion.

## Open Questions

The inventory determines exact operation population, canonical section layout and any backend distinctions.
These are evidence questions owned by `.1`, not blockers requiring a director decision now.

## Blockers

None requiring director input. P1 evaluated-value .1.2.3 is complete; scoped-with .1.2.4 is next from clean Git, then deferred numeric helpers .1.2.5 and generated-drop compiler diagnostic .1.2.6 before enumeration.

## Verification Log

- `2026-10-20` — `.1.2.5`: See the complete numeric checkpoint above.

- `2026-10-20` — `.1.2.3`: Evaluated-list operands retain earlier values across later effects and preserve explicit splices. Accepted19 RED/four controls becomes23 native/fresh-generated GREEN; seven suites use277 declared test/data/bin inputs. Six emitter faults reject19/14/2/1/1/1 and restore. Focused52 preserves982 skips in1651 supplied files; ordinary all1035 passes separately. Observer129 RED/one null, missing-selector RED and restoration remain effective. Twelve recurring suites retain4998 assertions plus3 value/ABI goldens:5001 quiet PASS; mapper bypass fails198 and restores. Three exact owner/prior/current scanner admissions retain original registrations;28 denials and actual check-removal faults9/6/3 pass. Two oversized streams become31 bounded chunks with exact bytes/modes and retained-review use in explicit original scanner context;500733803 duplicate bytes are removed with residue0. Historical metadata has4 denials/actual guard RED1; current reads stay unchanged. Whole837/full130737 and actual readonly0 survive; one physical input becomes an index, preserving all original logical inputs. Fresh845/full130759 binds the complete4178-input closure including4163 scanner candidates, with no oversized files. Graph1487/1349/10462 preserves897 entries/248 fields at8388584 Knowledge bytes; book89/heading denial and whole388/full68814/2706 replay pass. Rejected/preparation epochs retain their original limits and bytes. Scoped-with4, numeric5 and generated-drop6 remain owned; no exhaustive type, cross-backend or private/parent admission. Exact staged canonical receipt and normal hooks govern landing; derive actual admission identity from Git.

- `2026-10-19` — `.1.2.0`: Authority/model .1.2.0 retains1300 owned inputs;14 descriptor/Get/generated cases include70 neutral scalar fields, and11 distinguishing cases isolate two owned P1 Perl defects. Actual private promotion has report0/strict RED/exact restoration. Current Knowledge1487/1349/10455, all897 list items/248 fields and8387566 bytes fit unchanged limits; complete89-input book and changed-heading control pass. Whole original396/full68960 replays with exact channels and bytes/modes unchanged. Only that accepted claim is frozen at real cf4dceccd; first no-write frontmatter writer failure and separate correction remain retained. No runtime, contract, gate, budget, complete operation inventory, cross-backend or private/parent admission. P1 scalar-evaluation .1.2.3 then scoped-with .1.2.4 precede complete enumeration .1.2.1.

- `2026-10-19` — `.1.1`: TYPE-REFERENCE-BOOK.1.1 corrects the retired tagged-return recipes: exact historical m/ma callbacks splice groups, while current copy recipes have explicit snapshot/identity limits. Seventeen fixed parser/generated payloads, five alternate native-shape REDs and four module-identity REDs pass. Two Toolbox return examples and the complete89-input book/affected-page links pass; the actual worked source matches native execution. Whole prior208/full39111 and first uncommitted355/full60395 records, actual baselines and all inputs remain recoverable. Exact isolated original reader fails its absolute INC predicate; the distinct corrected predicate/full supplied context restores the whole original claim with identical channels. Redundant public42/40 references and executable negative capture sources are resolved without changing gates: exact original producers remain archived data with guarded stubs. Current Knowledge1487/1349/10455, all897 entries/248 fields, 8386601 bytes and map21249 fit unchanged controls. Current readonly publication binds396 inputs/full68960. No runtime, contract, budget, full alias/deep-copy, exhaustive type inventory or private/parent admission changes. Clean activation of .1.2 inventory follows; .8 legacy status repair and deferred metadata QA .13 remain owned.

- `2026-10-10`: Intake reads current SUMMARY, value/container helper reference, Values/codeblock prose, fluent and
  declaration chapters, helper catalog and existing book task records. Structure and sampled entries establish a
  qualitative gap only. Exact legacy status contradictions are recorded above; no runtime or full coverage proof.

## Commit Log

Intake landed under `PERL-PRIVATE-FACTORY-CAPTURE.3.1.3.2`. TYPE-REFERENCE-BOOK.1.1 is the first completed child; derive its accepted commit by subject from Git. Authority/model .1.2.0 is complete; derive its accepted commit by subject. P1 .1.2.3 completes the evaluated-value repair; derive its accepted commit by subject. Scoped-with .1.2.4 completes its finite repair; derive its accepted commit by subject. Numeric .1.2.5 completes scalar calls/snapshots; derive its commit by subject.

## Changelog

- `2026-10-10`: Queue inventory, five type-family reference slices, independent coverage closeout and the exact
  encountered legacy metadata repair without changing the active private callback frontier.

- `2026-10-19`: Clean accepted metadata handoff activates .1.1; split stale guidance, full inventory and independent layout review into separately committed leaves. Queue the unconfirmed scalar-format question without redirecting reference work.

- `2026-10-19`: Complete .1.1 with corrected historical flat groups, bounded snapshot guidance, preserved claims/producers, current rendered book and focused proof; hand off cleanly to .1.2.

- `2026-10-19`: Activate .1.2 from clean cf4dceccd; split authority/type model, complete operation/spelling enumeration and book mapping into independently committed children. Current .1.2.0 owns the pre-measurement source population and preservation.

- `2026-10-19`: Complete authority/model prerequisite; schedule both source-isolated P1 repairs before exhaustive operation enumeration.

- `2026-10-20`: Complete scoped callable .1.2.4 with typed errors, frame restoration and authored spans; numeric .1.2.5 is next.
