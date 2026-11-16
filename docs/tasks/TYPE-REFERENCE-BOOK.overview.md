# TYPE-REFERENCE-BOOK: Complete navigable per-type language reference

## Metadata

- Tree ID: `TYPE-REFERENCE-BOOK`
- Status: `active` / remaining fluent-family and inter-type feature selection; full reference/admission open
- Roadmap lane: `.spec language documentation / complete type and method reference`
- Created: `2026-10-10`
- Last updated: `2026-11-13`
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

- ID: `TYPE-REFERENCE-BOOK.1.2.23.4.33`
  Status: `completed`
  Goal: Complete the due November16 retention-only artifact review before canonical publication preparation.
  Dependencies: Clean b3ab04a22019bd8e95fcba47d278b95bb401d709; last cleanup November12; published named-scope scanner and independent metadata review.
  Acceptance: Reuse retained scanner contracts, compare every dated path/suffix/byte row in the eight existing scopes with independent scandir/lstat, retain all artifacts/caches/proof, preserve actual source/commands/channels and effective corruption controls, overwrite the latest-only cleanup record and commit. No liveness, disposal or physical-reclamation claim.
  Verification tier: `focused`
  Focused checks: One bounded metadata capture and separate readonly recovery with corruption controls; claim/source identity, task/index, memory, history pressure, book and normal doctrine hooks.
  Canonical trigger: Current discovery4.1 and final clean publication30.2; this checkpoint-only maintenance changes no shared runner, policy, storage default or runtime.
  Claim verification: `docs/claims/TYPE-REFERENCE-BOOK.1.2.23.4.33.json`
  Landing correction: Initial CHANGES heading lacked the required ISO date; scripts/check_document_history.pl387-390 reports the exact defect. Preserve the partial failed normal log and before/after source in landing-repair/. Remaining first hooks and the redundant standalone claim check were canceled; no all-doctrine credit. Only the heading changes; normal retry must complete every required hook.
  Outcome: 1316 dated metadata rows agree in eight named scopes; five altered-evidence controls and separate readonly recovery pass. All artifacts, caches and proof remain retained; nothing removed. Actual observation/source images/modes/index/commands/channels: docs/checkpoints/artifact-review-2026-11-16/. Reverify: bash tools/run_python_project_data.sh docs/checkpoints/artifact-review-2026-11-16/review.py. Normal hooks govern landing. Native/physical custody remains4.2/SESSION5.
  Next: Current canonical discovery4.1, then early publication30.2 after all prerequisites.

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
  Verification tier: `focused`
  Focused checks: Preserve all intersecting live claims and actual readonly baselines before bound writes; native-first Toolbox lowering/descriptor/execution observations for every current replacement and distinguishing retired/removed-selector controls; independent value/shape/aliasing review, retained original historical facts, effective semantic denials/restorations, current Knowledge, affected complete book and history/memory/task gates.
  Canonical trigger: none for documentation correction to already-admitted syntax; reclassify before changing runtime behavior, a public contract, or mechanical owners. No push before the PNT boundary.
  Claim verification: `docs/claims/TYPE-REFERENCE-BOOK.1.1.json`
  Acceptance: Preserve the June retirement observations as dated history. Establish actual current constructors/bare bindings/copy and group behavior through public tools; do not imply an unverified aliasing equivalence or full type inventory. Keep current examples and reverify routes valid. Commit this bounded repair before inventory .1.2.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree TYPE-REFERENCE-BOOK --id TYPE-REFERENCE-BOOK.1.1`.

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
  Verification tier: `focused`
  Focused checks: Exact owned Git source/contract/book population and recoverable bytes/modes before producers; existing language-coverage and neutral type/callable/numeric authorities; public-tool probes where current acceptance is uncertain; independent completeness/category and distinguishing omission/private-promotion controls; changed Knowledge/book, histories, explicit memory and normal doctrines/hooks.
  Canonical trigger: none for inventory/clarification of existing admitted behavior; split/reclassify before any runtime, public contract, generated format or mechanical owner change.
  Claim verification: `docs/claims/TYPE-REFERENCE-BOOK.1.2.0.json`
  Acceptance: Produce a source-bound authority ledger and current type taxonomy with explicit admitted/private/retired and historical boundaries. Reconcile scalar/string/numeric integer-real and boolean/null distinctions, array/harray/codeblock bindings and yielded receiver dispatch without inventing separate method tables. Do not call the shared helper-name inventory a complete operation/spelling inventory. Commit this bounded prerequisite before .1.2.1.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree TYPE-REFERENCE-BOOK --id TYPE-REFERENCE-BOOK.1.2.0`.

- ID: `TYPE-REFERENCE-BOOK.1.2.3`
  Status: `done` / bounded evaluated-value and admission repair
  Goal: Preserve evaluated values across later side effects in array/harray literals and constructors and callable argument lists.
  Dependencies: `TYPE-REFERENCE-BOOK.1.2.0`
  Verification tier: `canonical`
  Focused checks: Native-first Get/descriptor/fresh generated-source impact matrix; once/order/kind/caller/alias and name-collision controls; actual unchanged baseline RED and candidate GREEN/source inverses; direct AST/lowering/generated/uniform/callable/variadic consumers; current complete Knowledge/book, histories, memory and all doctrines.
  Canonical trigger: Observable evaluated-value/runtime correction; exact staged candidate must pass approved-host tools/run_ci_local.sh and normal receipt-bound hooks.
  Claim verification: `docs/claims/TYPE-REFERENCE-BOOK.1.2.3.json`
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree TYPE-REFERENCE-BOOK --id TYPE-REFERENCE-BOOK.1.2.3`.

- ID: `TYPE-REFERENCE-BOOK.1.2.4`
  Status: `done` / scoped callable repair; clean activation 2fca7d848
  Goal: Make the scoped with value callable inside its attached codeblock without silent null lowering.
  Dependencies: `TYPE-REFERENCE-BOOK.1.2.3`
  Verification tier: `canonical`
  Focused checks: Scoped descriptor/Get/fresh-source values and diagnostics, actual source faults, callable/with/direct consumers, Knowledge and rendered book.
  Canonical trigger: Scoped callable lowering and runtime-frame movement; exact staged candidate.
  Claim verification: `docs/claims/TYPE-REFERENCE-BOOK.1.2.4.json`
  Acceptance: Repair scoped dependency projection with nested scope/restoration, static helper/function precedence, false/null/noncallable and explicit-parameter controls; check actual unsupported-call diagnostics separately. Preserve existing call/with contracts, verify fresh emitted routes and direct consumers, document the fix and run canonical candidate proof.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree TYPE-REFERENCE-BOOK --id TYPE-REFERENCE-BOOK.1.2.4`.

- ID: `TYPE-REFERENCE-BOOK.1.2.5`
  Status: `done`
  Goal: Repair scalar numeric calls and snapshots.
  Dependencies: `TYPE-REFERENCE-BOOK.1.2.4`
  Verification tier: `canonical`
  Focused checks: Native/fresh values/kinds/errors/effects, neutral contracts, direct consumers, source faults, book/Knowledge.
  Canonical trigger: Interpreter/generated behavior; exact staged receipt.
  Claim verification: `docs/claims/TYPE-REFERENCE-BOOK.1.2.5.json`
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree TYPE-REFERENCE-BOOK --id TYPE-REFERENCE-BOOK.1.2.5`.

- ID: `TYPE-REFERENCE-BOOK.1.2.6`
  Status: `done` / bounded Perl drop producer repair
  Goal: Quiet scalar-key generated loading with copied harrays and evaluated key lists.
  Dependencies: `TYPE-REFERENCE-BOOK.1.2.5`
  Verification tier: `canonical`
  Focused checks: Fixed48 descriptor/Get/lowering/fresh normal/FATAL routes;34 values/14 diagnostic controls;4 emitter faults;9 suites/1322 TAP; five real Phase0 roots with18 permanent assertions; book89/3/heading RED; exact historical644+6/134/22 and2 auditor faults/table denial; Knowledge.
  Canonical trigger: Observable generated compiler diagnostic; exact staged-candidate receipt required before normal landing.
  Claim verification: `docs/claims/TYPE-REFERENCE-BOOK.1.2.6.json`
  Commit subject: `TYPE-REFERENCE-BOOK.1.2.6 - materialize generated drop keys`.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree TYPE-REFERENCE-BOOK --id TYPE-REFERENCE-BOOK.1.2.6`.

- ID: `TYPE-REFERENCE-BOOK.1.2.7`
  Status: `done` / bounded Perl availability and portable evidence admission
  Goal: Execute deferred aggregate numeric calls/overloads and terminal receivers.
  Dependencies: `TYPE-REFERENCE-BOOK.1.2.6`
  Verification tier: `canonical`
  Focused checks: Public descriptor/Get/dump/fresh routes; six families/names/receivers, arity/kind/empty/effects; scalar5/drop6/direct tests; book/Knowledge/doctrines.
  Canonical trigger: Public callback availability and emitted invalid-shape diagnostics; exact staged receipt.
  Claim verification: `docs/claims/TYPE-REFERENCE-BOOK.1.2.7.json`
  Commit subject: `TYPE-REFERENCE-BOOK.1.2.7 - execute deferred array reducers`.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree TYPE-REFERENCE-BOOK --id TYPE-REFERENCE-BOOK.1.2.7`.

- ID: `TYPE-REFERENCE-BOOK.1.2.9`
  Status: `done` / activation49ce3fb
  Goal: Execute deferred sorted/take aggregate pipelines.
  Dependencies: `TYPE-REFERENCE-BOOK.1.2.7`
  Verification tier: `canonical`
  Focused checks: Public descriptor/Get/dump/fresh routes; lexical sorting, take default/count/arity/kind/effects/copy/chain boundaries; aggregate/scalar/callable direct consumers; book/Knowledge/doctrines.
  Canonical trigger: Public deferred helper availability and terminal composition admission; exact staged canonical receipt required.
  Claim verification: `docs/claims/TYPE-REFERENCE-BOOK.1.2.9.json`
  Commit subject: `TYPE-REFERENCE-BOOK.1.2.9 - execute deferred sorted take pipelines`.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree TYPE-REFERENCE-BOOK --id TYPE-REFERENCE-BOOK.1.2.9`.

- ID: `TYPE-REFERENCE-BOOK.1.2.13`
  Status: `done` / selected proof; exact canonical admission required
  Goal: Preserve numeric kinds through lexical sorting and container copies.
  Dependencies: `TYPE-REFERENCE-BOOK.1.2.9`
  Verification tier: `canonical`
  Focused checks: Fixed native/Get-dump/descriptor/fresh values and typed-index errors; independent B flags, JSON and clone kinds; numeric-looking strings, null/boolean and lexical order; source/result independence, ordinary/deferred and implicit-accumulator paths; direct consumers, book/Knowledge/history/doctrines.
  Canonical trigger: Observable Perl scalar-kind and pure-sort correction; exact staged canonical receipt required before normal landing.
  Claim verification: `docs/claims/TYPE-REFERENCE-BOOK.1.2.13.json`
  Commit subject: `TYPE-REFERENCE-BOOK.1.2.13 - preserve sorted scalar kinds`.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree TYPE-REFERENCE-BOOK --id TYPE-REFERENCE-BOOK.1.2.13`.

- ID: `TYPE-REFERENCE-BOOK.1.2.10`
  Status: `done` / selected proof; exact canonical admission required
  Goal: Execute deferred count/first and align their free harray kind guards.
  Dependencies: `TYPE-REFERENCE-BOOK.1.2.13`
  Verification tier: `canonical`
  Focused checks: Public descriptor/Get-dump/native/fresh values and typed errors; free/receiver shape, empty/kind/continuation/effects, copy/index/source controls; direct consumers, book/Knowledge/history/doctrines.
  Canonical trigger: Observable Perl callable helper availability; exact staged canonical receipt before normal landing.
  Claim verification: `docs/claims/TYPE-REFERENCE-BOOK.1.2.10.json`
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree TYPE-REFERENCE-BOOK --id TYPE-REFERENCE-BOOK.1.2.10`.

- ID: `TYPE-REFERENCE-BOOK.1.2.11`
  Status: `completed` / bounded behavior and conservative input closure verified
  Goal: Repair registered sorted receiver pipelines and ordinary length continuation.
  Dependencies: `TYPE-REFERENCE-BOOK.1.2.10`
  Verification tier: `canonical`
  Focused checks: Fixed public descriptor/Get/dump/native/fresh grid; registered parameter/local/rest/nested and free controls; lexical kind/copy/empty/nonarray/effects; permanent scalar consumer and direct dependents; actual source faults/restoration, full supplied book and artifact controls, Knowledge/history/doctrines.
  Canonical trigger: Public Perl pipeline availability and terminal/invalid-shape contract; exact staged canonical receipt required before normal landing.
  Claim verification: `docs/claims/TYPE-REFERENCE-BOOK.1.2.11.json`
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree TYPE-REFERENCE-BOOK --id TYPE-REFERENCE-BOOK.1.2.11`.

- ID: `TYPE-REFERENCE-BOOK.1.2.12`
  Status: `completed` / bounded deferred-write foundation; exact canonical receipt governs landing
  Goal: Execute typed indexed writes inside deferred codeblocks.
  Dependencies: `TYPE-REFERENCE-BOOK.1.2.11`
  Verification tier: `canonical`
  Focused checks: Public LinkedSpec::Get/return_descriptor/dump_parser_source/native/fresh indexed-write cases; frozen write fixtures; copied parameters/alias/null/effect/guard/malformed controls; permanent callable/multiline and direct dependents; complete mdBook; source faults and input/scope denials.
  Canonical trigger: Public deferred typed-write availability; exact staged canonical CI and normal hooks required.
  Claim verification: `docs/claims/TYPE-REFERENCE-BOOK.1.2.12.json`
  Commit: `TYPE-REFERENCE-BOOK.1.2.12 - execute deferred indexed writes atomically`
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree TYPE-REFERENCE-BOOK --id TYPE-REFERENCE-BOOK.1.2.12`.

- ID: `TYPE-REFERENCE-BOOK.1.2.14`
  Status: `completed`
  Goal: Execute deferred last array selectors.
  Dependencies: `TYPE-REFERENCE-BOOK.1.2.17.6`
  Verification tier: `focused`
  Focused checks: perl module syntax and one small public LinkedSpec::Get/native/emitted last regression, covering value/empty/kind, free/receiver shape, terminal effects and copied nested results. Build changed book and run fast continuity checks. No full Phase0/package/corpus/proof matrix or global registry scan.
  Canonical trigger: None for this implementation leaf under director's explicit feature-completion policy; exhaustive verification is deferred.
  Claim verification: none: Deterministic helper implementation/docs and a quick regression only; no quantified corpus, benchmark or exhaustive admission measurement is published.
  Acceptance: Match existing ordinary free/receiver arity, array/nonarray/empty results, stored-value kinds and terminal/effect/copy behavior. Quick syntax/native/emitted checks pass; comprehensive verification stays deferred.
  Commit: `TYPE-REFERENCE-BOOK.1.2.14 - execute last inside deferred Perl codeblocks`.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree TYPE-REFERENCE-BOOK --id TYPE-REFERENCE-BOOK.1.2.14`.

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
  Verification tier: `focused`
  Focused checks: Actual clean prior publication and complete checked-live claim census; source-bound owned contracts/public producers before native/fresh probes; ordinary/deferred literal/dynamic negative/empty/range/read-purity/effect controls on six runtime routes through published interfaces; independent oracle/reader denials; Knowledge/book/history/memory/whitespace and normal doctrines.
  Canonical trigger: none — diagnostic baseline and internal transition design only. Contract/checker, runtime, generated carrier and admission changes belong to canonical children.
  Claim verification: `docs/claims/TYPE-REFERENCE-BOOK.1.2.17.0.json`
  Acceptance: Retain exact current behavior without inferring support from a host language. Reconcile v1 creation/diagnostic/evaluation/read-purity constraints with the director's existing-array tail-relative rule. Enumerate affected public guards/direct consumers and choose a safe backend transition. No runtime or portable admission.
  Commit: `TYPE-REFERENCE-BOOK.1.2.17.0 - record signed-index baseline and CLI repair priority`
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree TYPE-REFERENCE-BOOK --id TYPE-REFERENCE-BOOK.1.2.17.0`.

- ID: `TYPE-REFERENCE-BOOK.1.2.17.1`
  Status: `completed` / neutral target, source custody and bounded storage enrollment
  Goal: Freeze the signed neutral contract/checker and historical-v1 transition.
  Dependencies: `TYPE-REFERENCE-BOOK.1.2.17.0`, `TYPE-REFERENCE-BOOK.1.2.17.8`
  Verification tier: `canonical`
  Focused checks: Actual storage census/direct FAIL-PASS and signed-checker hostile-root wrapper execution; Source-bound neutral arithmetic/read/write/diagnostic/effect/identity/copy cases; full historical-v1 compatibility; actual finite oracle/source controls and input/scope denials; complete affected book render; memory/history/Knowledge/whitespace and all normal doctrines.
  Canonical trigger: Separate cross-backend target contract/checker; exact staged canonical receipt before landing.
  Claim verification: `docs/claims/TYPE-REFERENCE-BOOK.1.2.17.1.json`
  Acceptance: Preserve positive/quoted-key, copy, atomicity, effect, diagnostic and guard contracts. Negative selectors require an existing in-range array position and never create gaps. No full portable admission before child7.
  Commit: `TYPE-REFERENCE-BOOK.1.2.17.1 - freeze signed array selector target contract`
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree TYPE-REFERENCE-BOOK --id TYPE-REFERENCE-BOOK.1.2.17.1`.

- ID: `TYPE-REFERENCE-BOOK.1.2.17.2`
  Status: `completed`
  Goal: Implement signed ordinary/deferred reads/writes on Perl.
  Dependencies: `TYPE-REFERENCE-BOOK.1.2.17.1`
  Verification tier: `canonical`
  Focused checks: Public LinkedSpec::Get/return_descriptor/dump_parser_source/native and independently emitted execution before/after; frozen signed and historical-v1 fixtures; integer/string/coercion/read-purity, bounds, effects/order, identity, detachment, copied parameters and exact diagnostic spans; actual SUT inverse/source controls; direct Perl consumers, complete book, Knowledge/history/storage/whitespace and normal doctrines.
  Canonical trigger: Public Perl ordinary/deferred signed-selector semantics; exact staged canonical receipt and normal hooks before landing.
  Claim verification: `docs/claims/TYPE-REFERENCE-BOOK.1.2.17.2.json`
  Acceptance: Preserve positive/quoted-key, copy, atomicity, effect, diagnostic and guard contracts. Negative selectors require an existing in-range array position and never create gaps. No full portable admission before child7.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree TYPE-REFERENCE-BOOK --id TYPE-REFERENCE-BOOK.1.2.17.2`.

- ID: `TYPE-REFERENCE-BOOK.1.2.22`
  Status: `done` / verified finite Perl repair
  Goal: Preserve deferred primitive kinds, numeric payloads and copied scalar validity before continuing signed backend work.
  Dependencies: `TYPE-REFERENCE-BOOK.1.2.17.2`
  Verification tier: `canonical`
  Focused checks: Source-bound public descriptor/native/independently emitted literal and compiled-argument controls; pre-serialization scalar flags and JSON boolean identity; fixed/rest/contextual/copy/helper/selector effects; actual faulty/restored producer variants; callable, signed selector, numeric, logical, binding, generated and variadic direct consumers; rendered book, Knowledge/history/pressure and all doctrines.
  Canonical trigger: Public deferred primitive-value kind repair and exact staged canonical receipt before normal commit hooks.
  Claim verification: `docs/claims/TYPE-REFERENCE-BOOK.1.2.22.json`
  Acceptance: Preserve supported integer/float/boolean source kind through deferred literal values, assignments, copied parameters/containers and helper operands; independently test negative selectors, scalar flags, direct literal and compiled-argument controls. Keep general numeric values/ranges, string/boolean/null, effects/copy/guard and frozen old/signed contracts intact. Add distinguishing actual producer inverse/restoration, current book teaching and exact canonical proof.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree TYPE-REFERENCE-BOOK --id TYPE-REFERENCE-BOOK.1.2.22`.

- ID: `TYPE-REFERENCE-BOOK.1.2.17.3`
  Status: `done` / selected and admission proof; exact canonical receipt governs landing
  Goal: Implement the same policy through Rust native/generated interfaces.
  Dependencies: `TYPE-REFERENCE-BOOK.1.2.17.2`, `TYPE-REFERENCE-BOOK.1.2.22`
  Verification tier: `canonical`
  Focused checks: Source-bound Rust public CLI/trace and typed native/generated consumers against the frozen signed target; changed behavior RED/GREEN, actual runtime fault/restoration, direct write/receiver/copy/numeric compatibility, independent emitted compilation, retained producer/input controls, executable book examples/render and normal history/memory/Knowledge/doctrine checks. Resolve exact affected suites from the current interfaces before runtime edits.
  Canonical trigger: Rust runtime/generated behavior and the new typed underflow diagnostic; run exact staged-candidate canonical CI before the normal commit workflow. Portable admission stays with17.7.
  Claim verification: `docs/claims/TYPE-REFERENCE-BOOK.1.2.17.3.json`
  Acceptance: Preserve positive/quoted-key, copy, atomicity, effect, diagnostic and guard contracts. Negative selectors require an existing in-range array position and never create gaps. No full portable admission before child7.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree TYPE-REFERENCE-BOOK --id TYPE-REFERENCE-BOOK.1.2.17.3`.

- ID: `TYPE-REFERENCE-BOOK.1.2.17.4`
  Status: `done` / exact canonical receipt and normal hooks govern landing
  Goal: Implement the same policy through Dart native/generated interfaces.
  Dependencies: `TYPE-REFERENCE-BOOK.1.2.17.3`, `SESSION-STARTUP-READING.55.1`
  Verification tier: `canonical`
  Focused checks: Retain complete first-party producer/fixture inputs and actual public RED/GREEN channels; independent signed arithmetic/value/diagnostic targets; ordinary/callable, native/SpecFile/compiled/generated-plan/fresh emitted/CLI carriers; exact guards/effects/copies/Unicode spans and source inverses/restoration; unchanged write/map/binding/callable/direct dependents, complete Dart package tests and non-writing format/strict-analysis observations; current book/executed examples, Knowledge/history/memory/doctrine checks.
  Canonical trigger: Planned backend signed-selector implementation boundary; exact staged approved-host canonical CI and normal hooks before landing. Keep the canonical process sandbox intact; no push during PNT.
  Claim verification: `docs/claims/TYPE-REFERENCE-BOOK.1.2.17.4.json`
  Acceptance: Preserve positive/quoted-key, copy, atomicity, effect, diagnostic and guard contracts. Negative selectors require an existing in-range array position and never create gaps. No full portable admission before child7.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree TYPE-REFERENCE-BOOK --id TYPE-REFERENCE-BOOK.1.2.17.4`.

- ID: `TYPE-REFERENCE-BOOK.1.2.17.5`
  Status: `completed`
  Goal: Implement the same signed-array policy through Julia native/generated interfaces.
  Dependencies: `TYPE-REFERENCE-BOOK.1.2.17.4`
  Verification tier: `focused`
  Focused checks: Load/compile LinkedSpecJulia through tools/run_julia_project_data.sh and run one small signed-selector regression covering native/generated reads/writes, underflow/missing target and positive/quoted-key controls. Build the changed book; fast manual memory/task/diff checks before commit. No full suite, corpus, exhaustive fault matrix or global registry scan for this feature.
  Canonical trigger: None for this implementation leaf under the director's explicit feature-completion policy. Broad validation belongs to the deferred validation phase; no portable admission is claimed here.
  Claim verification: none: Deterministic implementation/docs and a small regression check; no quantified corpus, benchmark, exhaustive or portable-admission measurement is published. Later comprehensive verification stays owned by17.7.
  Acceptance: Existing-array negative selectors resolve against each encountered array's length. Preserve positive/quoted-key, kind/copy, atomicity/effect, diagnostic and guard contracts; negative selectors never create gaps or missing arrays. Compile and focused regression pass before committing; full portable admission stays open.
  Commit: `TYPE-REFERENCE-BOOK.1.2.17.5 - support signed Julia array selectors`.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree TYPE-REFERENCE-BOOK --id TYPE-REFERENCE-BOOK.1.2.17.5`.

- ID: `TYPE-REFERENCE-BOOK.1.2.17.6`
  Status: `completed`
  Goal: Implement the signed-array policy in shared Lua for PUC Lua and LuaJIT.
  Dependencies: `TYPE-REFERENCE-BOOK.1.2.17.5`
  Verification tier: `focused`
  Focused checks: Compile/load the shared module and run the small signed-selector regression through tools/run_lua_project_data.sh on puc and luajit. Cover native/generated/emitted values and immediate missing/underflow/coercion controls; build changed book and run fast manual continuity checks. No full gate/corpus/exhaustive matrices/global registry scan.
  Canonical trigger: None for this implementation leaf under the director's explicit feature-completion policy. Broad validation belongs to deferred17.7 after feature coverage.
  Claim verification: none: Deterministic implementation/docs and a quick regression only; no quantified corpus/benchmark, exhaustive or portable-admission measurement is published.
  Acceptance: Existing-array negative selectors use L+index without creating missing arrays or gaps. Preserve positive/key, copy, atomicity/effect, diagnostic and guard behavior. Compile/targeted checks pass on both Lua ABIs; portable admission remains open.
  Commit: `TYPE-REFERENCE-BOOK.1.2.17.6 - support signed selectors on Lua and LuaJIT`.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree TYPE-REFERENCE-BOOK --id TYPE-REFERENCE-BOOK.1.2.17.6`.

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
  Verification tier: `canonical`
  Focused checks: Public Get/descriptor/dump/native/fresh and exact CLI before/after/source-inverse channels; valid null/false/no-match controls; permanent trace/CLI consumers and shared manifest default/POSIX; current Knowledge/complete rendered book; artifact/scope falsifiers, memory/history/whitespace and normal doctrines.
  Canonical trigger: Public primary-command runtime-error reporting repair; exact staged canonical CI and normal hooks before admission.
  Claim verification: `docs/claims/TYPE-REFERENCE-BOOK.1.2.17.8.json`
  Acceptance: Observe thrown and context-reported failures, preserve legitimate null/false/no-match results, emit the existing invocation-failure heading/exit and error trace, add distinguishing permanent CLI proof, retain actual before/after/source-inverse channels and all fixture inputs, update current book/Knowledge, and run exact canonical admission. Other repositories remain read-only.
  Commit: `TYPE-REFERENCE-BOOK.1.2.17.8 - report context-only Perl CLI runtime failures`
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree TYPE-REFERENCE-BOOK --id TYPE-REFERENCE-BOOK.1.2.17.8`.

- ID: `TYPE-REFERENCE-BOOK.1.2.16`
  Status: `completed`
  Goal: Execute scoped with inside deferred callable bodies.
  Dependencies: `TYPE-REFERENCE-BOOK.1.2.14`
  Verification tier: `focused`
  Focused checks: Module syntax and one small public ordinary/deferred/native/emitted with regression, plus scoped binding/presence restoration on a typed error. Cover metadata-approved helper/receiver/contextual/explicit forms, nesting, caller context and shape/effect guards. Build book and run fast manual continuity checks; no full suite/corpus/exhaustive proof/global registry scan.
  Canonical trigger: None for this implementation leaf under director feature-completion policy; broad validation is deferred.
  Claim verification: none: Deterministic implementation/docs and a quick regression; no quantified corpus, benchmark, exhaustive or portable-admission measurement is published.
  Acceptance: Metadata-approved helper/receiver forms execute in caller context with temporary present value binding, correct block-local return and restoration on success/error. Reject unsupported shapes before effects; retain explicit callback invocation rules and unrelated caller effects. Quick syntax/native/emitted checks pass.
  Commit: `TYPE-REFERENCE-BOOK.1.2.16 - execute scoped with inside deferred codeblocks`.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree TYPE-REFERENCE-BOOK --id TYPE-REFERENCE-BOOK.1.2.16`.

- ID: `TYPE-REFERENCE-BOOK.1.2.19`
  Status: `done` / ordinary grouped assignment values
  Goal: Resolve grouped indexed-assignment values against the supported mutation-expression contract.
  Dependencies: `TYPE-REFERENCE-BOOK.1.2.16`
  Verification tier: `focused`
  Focused checks: Module/test syntax and one small grouped-value native/fresh regression; book render and fast continuity checks. Exhaustive suites/global scans stay deferred under director instruction.
  Canonical trigger: None for this bounded implementation phase; broad validation follows feature coverage.
  Claim verification: none: Deterministic lowering repair and a small regression; no quantified corpus, exhaustive or portable-admission measurement.
  Commit: `TYPE-REFERENCE-BOOK.1.2.19 - lower ordinary grouped assignment values`.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree TYPE-REFERENCE-BOOK --id TYPE-REFERENCE-BOOK.1.2.19`.

- ID: `TYPE-REFERENCE-BOOK.1.2.21`
  Status: `done` / raw multiline regex source-fidelity repair
  Goal: Preserve complete assigned raw-regex payloads across statement splitting and native/fresh Perl execution.
  Dependencies: `TYPE-REFERENCE-BOOK.1.2.19`
  Acceptance: Toolbox statement-boundary/source/pattern/value evidence identifies the exact producer. Preserve authored LF/CRLF, escapes, classes, delimiters and source spans; retain numeric slash calls and helper regex boundaries. Add independent match/mismatch and mutation controls, native/fresh recurrence and accurate legacy scope. No new portable raw-host capability is implied.
  Verification tier: `focused`
  Focused checks: Compile the changed module and run a small source/match regression; fast continuity checks and book render. Broad verification stays deferred under director instruction.
  Canonical trigger: None for bounded source-fidelity implementation; stop/re-scope before a new slash-precedence or runtime-type contract.
  Claim verification: none: Bounded deterministic repair/diagnosis; no quantified corpus or portable raw-host capability admission.
  Commit: `TYPE-REFERENCE-BOOK.1.2.21 - preserve assigned raw multiline regex payloads`.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree TYPE-REFERENCE-BOOK --id TYPE-REFERENCE-BOOK.1.2.21`.

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
  Status: `completed` / accepted only through normal hooks and exact staged canonical receipt for20.1.10
  Goal: Repair resulting-tree pressure/freshness failures and restore normal hooks before further runtime features.
  Children: Existing atomic map20.1.1 and claim-throughput20.1.2; reviewable retention-contract design20.1.3; bounded migrations and canonical closure split after the design decision.
  Discovered by: Focused optional document-pressure gate during valid reduction implementation21.4; runtime43 strict checks/book render pass independently. This intake does not activate a containment migration while the current feature tree is dirty.
  Reproduction: bash tools/project_data_run.sh bash scripts/check_readme_stability.sh with the preserved staged-index epoch at base0b9046522682d308b26d7935e09b0a279a7ab291. docs/checkpoints/type-operation-inventory/document-pressure-intake.md, metadata, exact staged binary patch and raw stdout retain the failed command/source context.
  Impact / ownership: Full admission/push is blocked by change_history/engineering_notes archive file/member controls, engineering aggregate controls, knowledge card count/bytes and task collection bytes. Document-history freshness additionally rejects non-dated current CHANGES headings, propagating to live status; task collection overflow propagates to task-index freshness. Ordinary focused runtime feature proof is not a full-doctrine receipt.
  Root cause: Completed chronology/immutable archives and cards have outgrown fixed resulting-tree controls, while the ignored feature doc writer formats CHANGES headings without an ISO date. Controlled HEAD/index deltas show the baseline already violates these controls: this Julia slice adds no archive/card files and its bounded existing-card/task edits cannot account for the excess. No deletion of immutable history or baseline/budget refresh is authorized by this intake.
  Schedule: Director explicitly prioritized proper repair now during the73.1 approval continuation. After committing the bounded E2BIG23.4.5 implementation, activate this owner immediately and restore normal hooks before Rust73.2 or other runtime feature work. Canonical owner LIVE-DOCUMENT-PRESSURE-CONTAINMENT is currently done through16; reactivate/split the required containment work only at a clean boundary, keeping this intake responsible until transferred to explicit repair leaves. No policy migration pivot inside the dirty Julia feature.
  Planned repair lanes: (1) Fix/clarify dated CHANGES production and normalize bounded current headings from retained history while preserving exact prior bytes; current Julia heading and ongoing local writer are corrected now to stop new recurrence. (2) Choose a governed bounded archive/index retention representation from canonical containment policy with exact ordered retrieval and immutable old evidence, addressing file/member/aggregate pressure. (3) Consolidate current Knowledge homes/lookup questions within unchanged controls, retaining provenance/current links. (4) Contain completed task chronology while retaining every stable ID/status/acceptance route and partition snapshots. (5) Run exact resulting-tree/freshness and designated canonical admission proof after all repairs, then close this owner.
  Acceptance: Reconcile adopted containment guide and registry/canonical memory/history rules before changes; preserve all unique facts, history, claims/producer inputs and current user reference. Use bounded separate commits, no arbitrary cap increases or hidden loss. Existing feature cadence remains focused; do not present current ordinary feature commits as a clean canonical doctrine receipt. Track each failure until fixed and verified.
  Planned verification tier: canonical at migration/admission activation; split ordinary bounded corrections when the existing policy permits.
  Claim verification: none: first-time deterministic gate-failure intake and source/index provenance, not an accepted population/capacity measurement. Actual repair must declare any measured admission claim and retain its producer/inputs/observed RED-GREEN.
  Integrated acceptance: Implementation and distinct component preservation/negative controls are retained under `docs/checkpoints/document-pressure-restoration/`; normal hooks require canonical receipt for the exact candidate before this checkpoint can land. No hook bypass or portable performance/completeness inference.

- ID: `TYPE-REFERENCE-BOOK.1.2.20.1.1`
  Status: `completed` / accepted only through normal hooks and exact staged canonical receipt for20.1.10
  Goal: Publish generated Knowledge Map content atomically so readers and interruption cannot observe or retain a truncated live map.
  Discovered by: Dart56.3.0 documentation finalization. Generator session58884 was still running when an independently launched git diff read KNOWLEDGE_MAP.md and reported nearly the entire file deleted. After actual generator exit0, the same diff contains only intended reverify/status edits and the complete map is intact. No final-map loss occurred.
  Root cause: knowledge-map/scripts/gen_knowledge_map.sh redirects its rendering block directly to KM_OUTPUT (currently line189). Redirection truncates the public file before rendering completes; final validate_output runs afterward. Current concurrent-read observation is transient, not accepted deletion or a runtime feature regression.
  Reproduce: Use an isolated repository-local output with existing KM_OUTPUT override; run generator while a bounded reader observes that path. Preserve the old full output, expose a controlled render interruption and distinguish current truncation from proposed atomic publication. Never interrupt writing to the maintained live map for this proof.
  Impact: Concurrent readers can observe partial data; interruption can leave the derived lookup truncated until regeneration. Agent mitigation now: await actual terminal generator success before reading/staging/building dependent content. The map remains derivable from committed cards.
  Schedule: With20.1 maintenance after ordinary feature coverage, before23.4/admission/push; do not pivot dirty feature work or change infra under a focused feature receipt.
  Acceptance: Use validated same-directory repository-local staging and atomic replacement with cleanup on failure; preserve output-path/symlink/locality/portable-shell contracts and exact deterministic map bytes. Add focused interruption/reader/invalid-output controls and run designated infrastructure/canonical proof. Keep all other repositories read-only.
  Verification tier: `canonical`
  Focused checks: Existing map regeneration/validator controls plus isolated output interruption and full-reader old-or-new invariants.
  Canonical trigger: Generator infrastructure publication changes, before admission/push.
  Claim verification: none: This node records a finite observed race and direct source mechanism, no population or capacity measurement; repair declares its actual proof.

  Activation: clean318da8b8a3298bd59c4d72c937d9187907178c39; proposal3 committed/post-hook0/brief0. Independent of pending archive/reference choice. Preserve exact renderer bytes in this slice; compact projection is separately owned20.1.9. Controlled isolated public generator probes must show reader/failure/TERM/validator behavior before production; never interrupt the maintained map.

  - [x] **REPRODUCE / ISSUE**: Unchanged public-generator control on retained original source fails replacement/first-publication readers, render failure, TERM and completed-output rejection; existing symlink rejection stays healthy. Only isolated repository-local destinations are interrupted.
  - [x] **ROOT CAUSE (WHY + WHERE)**: The source renderer block redirects directly to KM_OUTPUT before its final awk runs; a deterministic renderer barrier observes incomplete live bytes. Post-render validation happens after corruption. Retained original renderer/source and actual output phases establish this mechanism.
  - [x] **FIX**: Render to a unique validated sibling, preserve existing file permissions, validate completed staged output/destination, then atomically rename. EXIT and handled-signal cleanup remove only the owned temporary path. No renderer or metadata extraction change.
  - [x] **ADDRESSED (verified)**: Same six cases become6PASS from baseline5RED1PASS. Existing output survives failed rendering, TERM and rejected completed output; successful replacement/first publication exposes complete output and leaves no staging residue.
  - [x] **NO REGRESSION**: Existing header/list176 passes. Full current projection is byte-identical to318da8b8a with unchanged source cards. Bash syntax and source controls pass; canonical CI includes the new test. No complete canonical receipt is claimed while independent pressure fails.
  - [x] **LOCKSTEP**: Bundle README/book/fact/derived map/task/history/live/resume and actual producer/input/output capture agree. Original/repaired control inputs retain dynamic fixture/shim/validator bytes. Compact20.1.9 and independent claim-throughput20.1.2 retain their next-action ownership; the policy choice and canonical closure retain their separate owners.
  Result: Knowledge generation now publishes atomically through a validated unique sibling and rename, preserving prior complete output on renderer failure, handled termination and completed-output rejection. Replacement and first-publication readers observe only complete versions; symlink rejection remains intact. The unchanged six-case public-generator control is baseline5RED1PASS and repaired6PASS; the existing header/list regression176 passes. With unchanged canonical inputs, the entire current projection is byte-identical to committed318da8b8a. Renderer/extraction semantics and current caps are unchanged; compact projection is separate20.1.9. Canonical CI registers the new control. This establishes focused implementation, with canonical closure still pending pressure20.1.8. Archive/reference policy choice remains pending; normal-hook restoration and runtime features/push remain separate.
  Verification: bash tools/run_python_project_data.sh tools/test_knowledge_map_atomic_output.py --generator .linkedspec-data/knowledge-atomic/original/gen_knowledge_map.sh --evidence .linkedspec-data/knowledge-atomic/before.json (expected RED); same current generator after.json GREEN; bash tools/project_data_run.sh env PERL5LIB= prove t/knowledge_map_header_lists.t (176); full projection exact-byte comparison before adding the new fact; Bash syntax/book/map/history/memory/diagnosis/changed claim-input/diff. Actual evidence: docs/checkpoints/document-pressure-restoration/knowledge-map-atomic-intake.json.gz. Canonical closeout remains20.1.8; this node is not closed.
  Commit: `TYPE-REFERENCE-BOOK.1.2.20.1.1 - publish Knowledge Map output atomically`.
  Integrated acceptance: Implementation and distinct component preservation/negative controls are retained under `docs/checkpoints/document-pressure-restoration/`; normal hooks require canonical receipt for the exact candidate before this checkpoint can land. No hook bypass or portable performance/completeness inference.

- ID: `TYPE-REFERENCE-BOOK.1.2.20.1.2`
  Status: `completed` / accepted only through normal hooks and exact staged canonical receipt for20.1.10
  Goal: Reduce avoidable repeated historical/index reads in claim verification without weakening record validation, identity checks or stable-candidate ownership.
  Discovered by: Definedness calibration28.0. Broad normal and memoized collection attempts remained active after focused behavior proof and were deliberately stopped with actual exit143, without collection acceptance credit. The new claim subsequently passed the unchanged strict validator/self-tests/input hashes/owner declaration and pre-existing live-input intersection check on a stable candidate. No successful full-collection runtime or performance population is claimed.
  Mechanism to investigate: tools/check_claim_verification.py::check_owner repeatedly walks task index/Markdown blobs for disclosed gaps, while read_input issues Git reads for those blobs. Code establishes the repeated-read path, not a complete bottleneck profile; the ad hoc immutable-read memoization attempt did not establish a completed optimized collection proof.
  Reproduction/impact: At a clean maintenance boundary run the existing checker on an exact staged candidate with retained command/exits/read instrumentation; compare repeated immutable blob/owner lookups against distinguishable cached/snapshot controls. Preserve the known claim-verification-index-snapshot contract; never stage while a check is running. Redundant collection work delays ordinary feature delivery and the required admission gate.
  Schedule: After ordinary feature coverage, with20.1 containment maintenance, before full23.4/admission/final push. Existing director-authorized manual focused feature checks continue; no dirty-feature infrastructure pivot.
  Acceptance: Establish the actual cost mechanism and implement the smallest correct repair, such as immutable-read/current-owner snapshot reuse if supported by proof. Preserve strict schemas, historical/live input hashing, all gap-owner status/uniqueness checks, staged selected-owner disclosure, all-record canonical behavior and failure diagnostics. Keep meaningful negative controls and retain actual producers/inputs/results. Do not infer equivalent all-record results from the prior canceled attempts.
  Planned verification tier: canonical.
  Planned focused checks: Existing claim validator/staged-candidate tests plus distinguishing repeated-read/snapshot/owner-drift controls; unchanged semantic results for all registered records at the designated boundary.
  Planned canonical trigger: Claim-verifier infrastructure change, before admission/push.
  Planned claim verification: none: This node owns observed workflow delay and a source-confirmed repeated-read path; no measured speedup or complete bottleneck census. Repair declares its actual proof.
  Integrated acceptance: Implementation and distinct component preservation/negative controls are retained under `docs/checkpoints/document-pressure-restoration/`; normal hooks require canonical receipt for the exact candidate before this checkpoint can land. No hook bypass or portable performance/completeness inference.

- ID: `TYPE-REFERENCE-BOOK.1.2.20.1.3`
  Status: `completed` / director explicitly adopted proposed archive/reference contracts
  Goal: Freeze the exact current constraints, lossless repair design and browse/retention decision before changing governing lifecycles.
  Dependencies: clean E2BIG implementation7ec45b810;20.1 owns pressure; canonical closure23.4.5 remains pending.
  Acceptance: Reconcile local README routing contracts and the supplied containment guide; retain actual pressure diagnostics, name concrete changed paths/verifiers/migration order, distinguish existing bounds from proposed policy replacements, and request direction where lifecycle changes affect direct browsing. No limit/registry/retention/content migration occurs in this design slice. Independent atomic-map and verifier-throughput repairs may proceed while the decision is pending.
  Verification tier: `focused`
  Focused checks: Targeted current routing pressure and schema/contract/source review, proposal consistency, both history checks, memory/map/book/diff.
  Canonical trigger: Every later infrastructure/migration and final normal-hook restoration needs canonical proof after prerequisites; proposal does not authorize policy by itself.
  Claim verification: none: First-time diagnostic and design classification of finite existing failures; no accepted migration/capacity, repair census or performance measurement.
  Commit: `TYPE-REFERENCE-BOOK.1.2.20.1.3 - freeze lossless normal-hook restoration proposal`.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree TYPE-REFERENCE-BOOK --id TYPE-REFERENCE-BOOK.1.2.20.1.3`.

- ID: `TYPE-REFERENCE-BOOK.1.2.20.1.4`
  Status: `completed` / accepted only through normal hooks and exact staged canonical receipt for20.1.10
  Goal: Lossless ledger catalog and archive containment.
  Dependencies: retention/lifecycle decision20.1.3 and the preceding applicable repair lanes; split bounded atomic children before implementation.
  Acceptance: Preserve exact original segments/IDs and ordered retrieval; implement the selected archive contract under separately committed chronology-family children, with strict corruption and reconstruction controls.
  Planned verification tier: canonical
  Planned focused checks: Changed-surface preservation, query/index/source identity and distinguishing corruption controls; memory/map/history/book/diff as relevant.
  Planned canonical trigger: Infrastructure/migration acceptance and final normal-hook restoration; no portable/full-gate credit from focused controls alone.
  Planned claim verification: none: Unactivated repair lane; actual migration declares its source-bound preservation/measurement evidence before publishing claims.
  Integrated acceptance: Implementation and distinct component preservation/negative controls are retained under `docs/checkpoints/document-pressure-restoration/`; normal hooks require canonical receipt for the exact candidate before this checkpoint can land. No hook bypass or portable performance/completeness inference.

- ID: `TYPE-REFERENCE-BOOK.1.2.20.1.5`
  Status: `completed` / accepted only through normal hooks and exact staged canonical receipt for20.1.10
  Goal: Completed task narrative containment.
  Dependencies: retention/lifecycle decision20.1.3 and the preceding applicable repair lanes; split bounded atomic children before implementation.
  Acceptance: Preserve every current node ID/status/goal/acceptance/frontier and full historical details; extract only classified closed narrative with predecessor/range identity and exact query proof, one task owner per atomic child.
  Planned verification tier: canonical
  Planned focused checks: Changed-surface preservation, query/index/source identity and distinguishing corruption controls; memory/map/history/book/diff as relevant.
  Planned canonical trigger: Infrastructure/migration acceptance and final normal-hook restoration; no portable/full-gate credit from focused controls alone.
  Planned claim verification: none: Unactivated repair lane; actual migration declares its source-bound preservation/measurement evidence before publishing claims.
  Integrated acceptance: Implementation and distinct component preservation/negative controls are retained under `docs/checkpoints/document-pressure-restoration/`; normal hooks require canonical receipt for the exact candidate before this checkpoint can land. No hook bypass or portable performance/completeness inference.

- ID: `TYPE-REFERENCE-BOOK.1.2.20.1.6`
  Status: `completed` / accepted only through normal hooks and exact staged canonical receipt for20.1.10
  Goal: Knowledge and ADR scope containment.
  Dependencies: retention/lifecycle decision20.1.3 and the preceding applicable repair lanes; split bounded atomic children before implementation.
  Acceptance: Apply the explicitly selected maintained-reference or consolidation policy; preserve every question, canonical fact and indexed decision, retaining per-file limits, complete source ownership and fail-closed admission.
  Planned verification tier: canonical
  Planned focused checks: Changed-surface preservation, query/index/source identity and distinguishing corruption controls; memory/map/history/book/diff as relevant.
  Planned canonical trigger: Infrastructure/migration acceptance and final normal-hook restoration; no portable/full-gate credit from focused controls alone.
  Planned claim verification: none: Unactivated repair lane; actual migration declares its source-bound preservation/measurement evidence before publishing claims.
  Integrated acceptance: Implementation and distinct component preservation/negative controls are retained under `docs/checkpoints/document-pressure-restoration/`; normal hooks require canonical receipt for the exact candidate before this checkpoint can land. No hook bypass or portable performance/completeness inference.

- ID: `TYPE-REFERENCE-BOOK.1.2.20.1.7`
  Status: `completed` / accepted only through normal hooks and exact staged canonical receipt for20.1.10
  Goal: Maintained manual pressure repair.
  Dependencies: retention/lifecycle decision20.1.3 and the preceding applicable repair lanes; split bounded atomic children before implementation.
  Acceptance: Preserve product semantics/examples/anchors and direct mdBook browsing; reflow or remove only proved duplicates, render and verify the actual changed pages.
  Planned verification tier: canonical
  Planned focused checks: Changed-surface preservation, query/index/source identity and distinguishing corruption controls; memory/map/history/book/diff as relevant.
  Planned canonical trigger: Infrastructure/migration acceptance and final normal-hook restoration; no portable/full-gate credit from focused controls alone.
  Planned claim verification: none: Unactivated repair lane; actual migration declares its source-bound preservation/measurement evidence before publishing claims.
  Integrated acceptance: Implementation and distinct component preservation/negative controls are retained under `docs/checkpoints/document-pressure-restoration/`; normal hooks require canonical receipt for the exact candidate before this checkpoint can land. No hook bypass or portable performance/completeness inference.

- ID: `TYPE-REFERENCE-BOOK.1.2.20.1.8`
  Status: `completed` / accepted only through normal hooks and exact staged canonical receipt for20.1.10
  Goal: Normal-hook and canonical restoration closeout.
  Dependencies: retention/lifecycle decision20.1.3 and the preceding applicable repair lanes; split bounded atomic children before implementation.
  Acceptance: All mandatory doctrines pass on the actual candidate, then exact staged canonical CI passes. Close20.1 and23.4.5 only with retained acceptance evidence; restore normal commits before runtime features/push.
  Planned verification tier: canonical
  Planned focused checks: Changed-surface preservation, query/index/source identity and distinguishing corruption controls; memory/map/history/book/diff as relevant.
  Planned canonical trigger: Infrastructure/migration acceptance and final normal-hook restoration; no portable/full-gate credit from focused controls alone.
  Planned claim verification: none: Unactivated repair lane; actual migration declares its source-bound preservation/measurement evidence before publishing claims.
  Integrated acceptance: Implementation and distinct component preservation/negative controls are retained under `docs/checkpoints/document-pressure-restoration/`; normal hooks require canonical receipt for the exact candidate before this checkpoint can land. No hook bypass or portable performance/completeness inference.

- ID: `TYPE-REFERENCE-BOOK.1.2.20.1.9`
  Status: `completed` / accepted only through normal hooks and exact staged canonical receipt for20.1.10
  Goal: Remove duplicated projection metadata without removing any question route or unique fact metadata.
  Dependencies: atomic publication20.1.1; independent of pending archive/reference lifecycle choice.
  Acceptance: Keep current generated-map line/byte caps. Prove every question/home, fact ID/title/date/status/evidence/reverify/source value and anchor survives the compact rendering; parser and canonical card files remain unchanged. Retain exact original/repaired projection inputs and distinguishing lost-field/question controls. No direct canonical-home or browsing lifecycle migration.
  Planned verification tier: canonical
  Planned focused checks: Public generator/header-list regression, complete projection semantic equivalence and field/question loss negatives, actual line/byte pressure proof, map/book/history/memory/diff.
  Planned canonical trigger: Generator infrastructure and final normal-hook restoration; complete acceptance remains20.1.8.
  Planned claim verification: none: Unactivated deterministic projection repair; actual preservation/pressure proof declared before publishing measurements.
  Integrated acceptance: Implementation and distinct component preservation/negative controls are retained under `docs/checkpoints/document-pressure-restoration/`; normal hooks require canonical receipt for the exact candidate before this checkpoint can land. No hook bypass or portable performance/completeness inference.

- ID: `TYPE-REFERENCE-BOOK.1.2.20.1.10`
  Status: `completed` / accepted only through normal hooks and exact staged canonical receipt for this leaf
  Goal: Implement the explicitly approved archive/reference contracts and restore normal commit gates without any hook bypass.
  Authority: Director explicitly chose “Adopt the proposed archive/reference contracts (recommended)” after PLAN.md318da8b8a. This authorizes its exact-history archives, retained current task graph/per-file bounds, maintained-reference scope admission and bounded projection repairs. It does not authorize data loss, arbitrary cap increases or infrastructure no-verify commits.
  Transaction boundary: Existing independent failures prevent intermediate normal infrastructure commits. Prepare the interdependent policy/readers/checkers/data migrations as one atomic restoration candidate, keeping each component separately evidenced under20.1.2/.4/.5/.6/.7/.8/.9. No bypass or temporary pressure waiver; commit only when normal hooks and exact staged canonical proof pass. This is the necessary bootstrap integration boundary, not unrelated feature batching.
  Acceptance: Preserve exact promised history, every current task ID/status/goal/acceptance, all fact questions/canonical homes and direct public mdBook browsing. Install accepted indexed old/new lifecycle contracts, bounded archive catalogs, strict maintained-reference scope admission, bounded current task narrative and compact generated projection. Repair claim verifier reuse without weakening snapshots/validation. Require meaningful loss/corruption/unowned-growth negatives, all normal doctrines and canonical CI; close the component owners only after verified acceptance.
  Verification tier: `canonical`
  Focused checks: Component-specific preservation/retrieval/semantic/launch/snapshot controls and direct dependents; source-bound RED/GREEN evidence; render/map/history/memory/diagnosis/diff checks. No unrelated runtime feature work.
  Canonical trigger: Exact staged restoration candidate and normal hook-enabled commit; no infrastructure bypass, no push until this boundary passes.
  Claim verification: `docs/claims/TYPE-REFERENCE-BOOK.1.2.20.1.10.json`
  Activation: clean0db5e9e87b7c1cfaf09936b9629974787038f5e3; prior atomic implementation committed, brief0/tree clean. User approval resolves the pending lifecycle choice. Earlier feature-only no-verify permission was applied too broadly to infrastructure; that extension is withdrawn and is not used for this checkpoint.
  Ancillary cleanup ownership: The daily record passed24h during this long restoration. This leaf owns a bounded parent/Rust artifact review and exact cleanup of duplicate scratch logs only after their full bytes are retained and verified; dependency stores, unrelated caches, dependency repositories and proof inputs remain protected; a separately identified disposable Python bytecode cache is owned by this leaf.
  Cleanup claim correction: The record's later bytecode addition incorrectly extended full-byte-retention wording beyond the three actual retained scratch-log payloads. Reproduce by comparing ARTIFACT_CLEANUP.md, cleanup-intake.json.gz and the original bytecode identity record. This leaf corrects the statement, tracks the original identity/actual producer fragment and explicitly discloses that full bytecode bytes were not retained; source bytes are separately bound at correction time. The obsolete canonical run was stopped at exit143 before acceptance, then the exact corrected candidate is reverified. No unrelated deletion or retention credit is inferred.
  Artifact owner correction: The punctuation capture limits mistakenly routed broad fixture-input custody to23.4.3, which owns backend gate-path coverage. Current source/fact now route it to the actual existing23.4.2 owner. custody-owner-correction.json retains the initial metadata/producer and corrected source; the original capsule stays byte-identical. No input-closure promotion follows.
  Integrated acceptance: Implementation and distinct component preservation/negative controls are retained under `docs/checkpoints/document-pressure-restoration/`; normal hooks require canonical receipt for the exact candidate before this checkpoint can land. No hook bypass or portable performance/completeness inference.

  Acceptance Checklist:
  - [x] **REPRODUCE / ISSUE**: Original document-pressure diagnostics and complete unchanged-index claim checks are retained; `scripts/check_readme_stability.sh` exposes exact contract/admission requirements.
  - [x] **ROOT CAUSE (WHY + WHERE)**: `tools/read_document_history.pl` and `scripts/check_readme_routing_pressure.pl` distinguish lifetime archive/reference totals from bounded current data; claim validation repeated immutable reads and generated metadata duplicated display rows.
  - [x] **FIX**: Accepted ADR0139, source-bound archives, bounded catalogs/current partitions/scope admission, complete compact projection and snapshot-bounded claim reuse restore the intended contracts.
  - [x] **ADDRESSED (verified)**: `tools/test_task_narrative.py`, `t/document_history_catalog.t`, `tools/test_reference_scope.py` and `tools/test_knowledge_map_projection.py` reject the documented losses/corruption; retained replay checks actual full inputs.
  - [x] **NO REGRESSION**: `tools/test_claim_verification_cache.py`, existing header/list and atomic generator controls, actual history reconstruction/rollover, mdBook render and exact staged `tools/run_ci_local.sh` govern acceptance.
  - [x] **LOCKSTEP**: Book, accepted policy/ADR, Knowledge fact/map, current task contracts/indexes, history/live resume and `git diff --check` are synchronized; normal hook-enabled commit requires the exact receipt.
  Session boundary: Earlier stop-after-commit steering is superseded by the latest continuation steering below. After the verified normal-hook boundary, activate the explicit before-any-push prerequisite23.4.3; publish only after its closure. Rust Count73.2 follows that prerequisite; session health may require an explicit /exit request at a clean boundary.
  Commit: `TYPE-REFERENCE-BOOK.1.2.20.1.10 - restore normal hooks with approved archive contracts`.
  Candidate integration repairs: The first staged doctrine run reproduced three local integration failures: new TYPE index absent from the explicit tracked-index registry; completed checklist missing required bold labels/header; change-history entry missing its date prefix. This leaf owns and fixes all three, retaining the failed log locally. Current-ID registry adds TYPE without broadening immutable-history exclusions; the other fixes restore existing document contracts. Re-run the focused metadata/checklist/history checks before canonical restart.

  Owned book correction: Public history `--segment` requires four digits; the draft example `segment-0001` rejects. Use the actual retained ID `4932` from the catalog, retain actual RED/GREEN plus exact segment bytes, and check the other new retrieval examples through their public CLIs. No reader/API change.

  Owned canonical-doc drift repair: Earlier book/fact sections still described both author histories as bounded collections, omitted TYPE partitioning, and reconstructed history by indexing a physical flat manifest. Reconcile the current explanations, label original facts historical, retain exact before/after prose and observed old-example RED/new public-catalog GREEN, and gate the published commands. Refresh current view metadata dates without changing immutable source capsules.
  Owned catalog publication defect: The exported writer validated metadata only after replacing the live root. Extra/type-invalid metadata could reject after damaging that root; unsupported input versions could be silently coerced. Reproduce in the managed catalog fixture, require actual RED, preflight metadata and validate the complete virtual candidate before rename, then require rejection with the prior root byte-identical. This is contained within the new catalog producer and owned here.
  Canonical blocker resolved by component11: All10 doctrines/component checks pass, then the actual canonical recovery consumer rejects `current executable evidence drift: perl/LinkedSpec/Compiler.pm`. A targeted milestone/source comparison observes22 raw executable hash differences; this is not22 proven failures because existing exact evolutions admit some of them. Keep old checkpoints/logs/hashes and old falsifiers intact. Under11, classify existing routes and add only exact owner-bound current-image transitions with stage-qualified predecessor proof and effective mutation denials. No fresh historical runtime execution or broader23.4 feature admission follows.
  Latest continuation steering (November2): The director revokes the automatic pause at the next clean pushed checkpoint. Complete this exact canonical/normal-hook boundary and push, then continue PNT unless session health requires an explicit /exit request. Earlier component/capsule push-then-pause statements remain dated capture history, superseded here and in MEMORY.md; continuation-steering.json records the change.

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
  Goal: Index non-call value syntax, binding/path operators and callable forms against canonical authorities, without confusing syntax roles with methods or promoting raw host forms.
  Dependencies: `TYPE-REFERENCE-BOOK.1.2.21`
  Verification tier: `focused`
  Focused checks: One small public AST syntax probe for representative role boundaries; existing contracts/grammar and current signed/group/raw limits. Book render and fast continuity/history/diff checks only.
  Canonical trigger: None; existing syntax index, no runtime/public contract change or exhaustive admission.
  Claim verification: none: Qualitative source-linked syntax catalog, not a measured method count, coverage claim or backend execution census.
  Acceptance: Each syntax family records authored shape, role, result/mutation/callback/alias boundaries and canonical source; helpers, receiver methods, compatibility and private syntax remain separate. Leave helper/method enumeration to the next children and own encountered ambiguities instead of guessing support.
  Commit: `TYPE-REFERENCE-BOOK.1.2.1.1 - index value syntax and operation roles`.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree TYPE-REFERENCE-BOOK --id TYPE-REFERENCE-BOOK.1.2.1.1`.

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
  Goal: Index current helper spellings by source resolver family, canonical/compatibility alias mapping and dedicated/private syntax roles. Establish a usable source spine before per-helper signature/effect mapping.
  Verification tier: `focused`
  Focused checks: Source-linked spelling/alias consistency check against the actual Dart registry and checker classifications; book build and fast continuity/history checks. No runtime census.
  Canonical trigger: None; qualitative source index only, no new language/runtime/helper admission or complete semantic coverage claim.
  Claim verification: none: Qualitative name/role index of explicit current source registries, not measured execution parity, API completeness, per-type coverage or corpus census.
  Acceptance: Preserve overloaded roles and source-family limits; canonicalize aliases without promoting source-only compatibility or private/dedicated forms. Keep signatures/results/effects with next1.2.1.2.2, receiver transitions with1.2.1.3/.23. Correct the encountered stale array fact's Dart/Julia pending wording against already committed5.3.2/.3; no replay of old producers.
  Commit: `TYPE-REFERENCE-BOOK.1.2.1.2.1 - index helper spellings and syntax roles`.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree TYPE-REFERENCE-BOOK --id TYPE-REFERENCE-BOOK.1.2.1.2.1`.

- ID: `TYPE-REFERENCE-BOOK.1.2.1.2.2`
  Status: `pending`
  Goal: Map each indexed free helper to its actual signature/arity, input/result kinds, mutation/copy/callback boundaries and backend limits; select missing implementations as bounded feature leaves. Do not equate resolver families with input types or mark a method complete from a name.
  Dependencies: `TYPE-REFERENCE-BOOK.1.2.1.2.1`
  Planned tier: `focused`; source/contract mapping and tiny public probes for uncertainty only. Broad semantic census follows feature coverage.
  Claim verification: none: No complete method coverage measurement.

- ID: `TYPE-REFERENCE-BOOK.1.2.1.3`
  Status: `pending`
  Children: `TYPE-REFERENCE-BOOK.1.2.1.3.1`.
  Owned reconciliation: Current Helper Catalog still says booleans/flow results are terminal, while the authority/model ledger records generic false.with()/cat observations. Confirm current behavior with a tiny public probe and repair the per-method wording here; do not promote a stale blanket statement or historical observation to a complete method table.
  Goal: Index actual receiver methods by input and returned type, chain/terminal behavior, argument and callback shapes, mutation/copy rules and backend limits; route actual missing methods/transitions to23.
  Dependencies: `TYPE-REFERENCE-BOOK.1.2.1.2`
  Planned tier: `focused`; use tiny public probes only where current contracts are uncertain.
  Claim verification: none: Not yet activated; no complete fluent API claim.

- ID: `TYPE-REFERENCE-BOOK.1.2.1.4`
  Status: `pending`
  Children: `.1.2.1.4.1`, `.1.2.1.4.2`, `.1.2.1.4.3`.
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
  Status: `completed` / approved bounded rollout; full source/context/portable admission23.4 separate
  Goal: Resolve accepted scalar/null copy domains and repair the resulting portable copy/method gaps.
  Acceptance: Establish admitted function/receiver copy domains from current canonical contracts/book/Perl reference and retained compatibility records; choose a coherent target with explicit authority for any domain movement. Cover scalar Bool/Number/String/null and existing Array/Hash copies without losing source snapshots/kinds, arity-before-effects, mutability/detachment bounds or callable origin. Fix every accepted-domain mismatch (or consistently implement the explicitly reviewed unsupported-input boundary); documentation alone does not close this owner. Preserve dated prior compatibility evidence; no blind oracle refresh or unrelated depth-policy expansion.
  Planned verification tier: Select at activation for actual public contract/domain movement under the director's feature-first cadence; complete canonical admission remains23.4.
  Planned claim verification: none: deterministic authored compatibility/domain intake; no population/completeness measurement.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree TYPE-REFERENCE-BOOK --id TYPE-REFERENCE-BOOK.1.2.1.4.2`.

- ID: `TYPE-REFERENCE-BOOK.1.2.1.4.2.1`
  Status: `completed`
  Goal: Reconcile scalar/null copy authority and current reference behavior before bounded parity repairs.
  Parent: TYPE-REFERENCE-BOOK.1.2.1.4.2; authority ADR0006/0007, current book, canonical copy facts and public Perl reference.
  Verification tier: `focused`
  Focused checks: Public Get/substitution/fresh emitted execution of scalar/null/free/receiver/prefix/selected copy and container controls; inspect explicit contract authorities before selecting repair children. Compile authored probe, render changed book, bounded history and staged continuity checks. No broad matrix/full CI.
  Canonical trigger: Actual public domain/contract movement requires explicit authority and designated admission; complete portable copy/method admission remains23.4 after feature coverage.
  Claim verification: none: Deterministic authored contract/reproduction intake, no completeness/population measurement.
  Acceptance: Distinguish supported container inputs from scalar/null fallbacks, avoid deriving target from backend majority, preserve existing nested/detachment/arity/callable boundaries, retain exact prior evidence, own bounded fixes rather than documentation-only closure. Any genuinely conflicting policy or required language-evolution decision is surfaced with concrete alternatives.
  Commit: `TYPE-REFERENCE-BOOK.1.2.1.4.2.1 - reconcile copy-domain authority and reference`.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree TYPE-REFERENCE-BOOK --id TYPE-REFERENCE-BOOK.1.2.1.4.2.1`.

- ID: `TYPE-REFERENCE-BOOK.1.2.1.4.2.2`
  Status: `completed` / all bounded backend children targeted-checked; complete admission23.4 separate
  Goal: Adopt the director's scalar/null copy choice, then own bounded reference/backend repairs to completion.
  Dependencies:4.2.1 copy-domains.md and the October27 director approval of the value-preserving extension.
  Acceptance: Adopt the approved value-preserving Bool/Number/String/null extension; advance Perl first then Rust and independently check Dart/Julia/safe Lua. The container-only alternative was not selected. Preserve container depth/detachment/arity/snapshots/callable origin; own exact bounded children before production changes and retain prior observations. Documentation alone does not close parent4.2; broad admission23.4 remains later.
  Planned verification tier: Select for adopted contract movement under current director cadence; canonical admission before push remains mandatory.
  Planned claim verification: none: Deterministic contract decision and bounded feature repairs, not a completeness measurement.
  Children:4.2.2.0 implementation-target adoption;4.2.2.1 Perl (producer1.1, receiver1.2, existing interpreted-copy context1.3 if admitted);4.2.2.2 Rust;4.2.2.3 Dart;4.2.2.4 Julia;4.2.2.5 safe Lua. Full canonical admission remains23.4.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree TYPE-REFERENCE-BOOK --id TYPE-REFERENCE-BOOK.1.2.1.4.2.2`.

- ID: `TYPE-REFERENCE-BOOK.1.2.1.4.2.2.0`
  Status: `completed`
  Goal: Record the director-approved scalar/null value-copy implementation target and own bounded rollout before code.
  Dependencies:4.2.1 retained authority/reference observations; October27 explicit director choice.
  Verification tier: `focused`
  Focused checks: Exact director decision/ADR0006/0007 and retained copy-domain facts, existing signatures/guards/depths; clear target/current implementation distinction, small document/history/map/book/continuity checks only. No invented runtime PASS or broad gate.
  Canonical trigger: Full public/portable/context/canonical admission23.4 after reference/backend implementation; this leaf records the approved future implementation target and does not admit an existing backend capability.
  Claim verification: none: Normative director-approved target and bounded implementation ownership, no new runtime/population/completeness measurement.
  Acceptance: copy(expr) and expr.copy() preserve accepted Bool/Number/String/null values/kinds, evaluate the source once, and continue by actual returned kind. Retain current container depths, no implicit numeric/Boolean/text conversion, callable-origin rights, binding/noncreation, source errors, existing free malformed signatures and receiver arity-before-effects. Scope existing interpreted copy contexts independently; do not add new deferred vocabulary. Perl first; keep past observations and superseded scalar fallback evidence historical and own old expectation changes under explicit approval.
  Commit: `TYPE-REFERENCE-BOOK.1.2.1.4.2.2.0 - adopt scalar and null value-copy target`.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree TYPE-REFERENCE-BOOK --id TYPE-REFERENCE-BOOK.1.2.1.4.2.2.0`.

- ID: `TYPE-REFERENCE-BOOK.1.2.1.4.2.2.1`
  Status: `completed` / bounded producer, receiver and existing-context children
  Goal: Implement the approved primitive value-copy target on Perl without changing container/context/provenance bounds.
  Dependencies:4.2.2.0 ADR0138/frozen target.
  Children:4.2.2.1.1 ordinary producer/results;4.2.2.1.2 ordinary receiver/results;4.2.2.1.3 already-supported interpreted copy preservation/repair.
  Acceptance: All three bounded children verify and commit before Rust rollout. Preserve historical observations and update only scalar/null expectations explicitly superseded by the director's decision. Full source/context/portable/canonical admission remains23.4.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree TYPE-REFERENCE-BOOK --id TYPE-REFERENCE-BOOK.1.2.1.4.2.2.1`.

- ID: `TYPE-REFERENCE-BOOK.1.2.1.4.2.2.1.1`
  Status: `completed`
  Goal: Make ordinary Perl function copy preserve primitive values and actual-kind result continuations.
  Dependencies:4.2.2.0.
  Acceptance: Typed one-argument producer preserves Bool/Number/String/null, source-once/order/snapshots and errors; Number0 versus String0 remains independently distinguishable before serialization. Existing Array/Hash ordinary depth, rule accumulator/legacy storage, valid expression materialization and retired-source boundaries remain. A copied scalar result cannot acquire Array semantics or run incompatible consumer operands. Preserve malformed free signature policy; generic receiver rollout is next1.2. Own any necessary actual-result classifier changes in this producer slice, splitting before edits if too large.
  Planned verification tier: focused
  Planned focused checks: Independent producer-first scalar/null/control RED/GREEN on native/fresh, actual-kind/source/error/container controls and direct copy/result tests, source syntax/book/history/continuity only.
  Planned canonical trigger: Complete source/context/portable/contract admission23.4 after all feature children and final clean push.
  Planned claim verification: none: Deterministic authored feature/preservation controls, no population/completeness measurement.
  Verification tier: `focused`
  Focused checks: Public producer-first scalar/null/typed source/shape/error/container distinction, strict native/fresh primitive identity/kinds/source snapshots and actual-result guards plus direct copy/container/result compatibility and syntax; book/history/staged continuity. No full suite/matrix.
  Canonical trigger: Complete copy/source/context/portable/admission23.4 and final clean push after feature coverage. Generic receiver1.2 and existing interpreted context1.3 remain separate.
  Claim verification: none: Deterministic authored feature/regression/preservation controls, no population/completeness measurement.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree TYPE-REFERENCE-BOOK --id TYPE-REFERENCE-BOOK.1.2.1.4.2.2.1.1`.

- ID: `TYPE-REFERENCE-BOOK.1.2.1.4.2.2.1.2`
  Status: `completed`
  Goal: Complete ordinary Perl value.copy() primitive/result-flow counterparts after the typed producer.
  Dependencies:4.2.2.1.1.
  Acceptance: Named/literal/selected/block/function/prior scalar-result and scoped flows preserve copied primitive kind/value; repeated copy and compatible scalar/default/container-recovery continuations work by actual kind. Wrong container consumers skip their operands after valid source/prefix effects. Zero authored operands and pre-effect malformed shapes remain; preserve container depths and legacy callable/scoped provenance. Update old fallback/rejection expectations only with ADR0138 authority.
  Planned verification tier: focused
  Planned focused checks: Strict native/fresh finite copy-result/method/scope/shape/error/source-kind controls and direct existing copy/scalar-result regressions, syntax/book/history/continuity.
  Planned canonical trigger: Full context/source/portable/canonical admission23.4 after feature coverage.
  Planned claim verification: none: Deterministic finite feature/regression controls, no population/completeness measurement.
  Verification tier: `focused`
  Focused checks: Producer-first receiver RED/GREEN; strict native/fresh primitive kinds, prior-result/repeated/default/scoped/source snapshots/errors/shape and container controls; direct copy/logical result checks, syntax/book/history/continuity. No full suite/matrix.
  Canonical trigger: Complete source/context/portable/admission23.4 and final clean push after feature coverage; independent interpreted context1.3 and backend children follow.
  Claim verification: none: Deterministic authored finite feature/regression controls, no completeness measurement.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree TYPE-REFERENCE-BOOK --id TYPE-REFERENCE-BOOK.1.2.1.4.2.2.1.2`.

- ID: `TYPE-REFERENCE-BOOK.1.2.1.4.2.2.1.3`
  Status: `completed` / existing supported path preserved
  Goal: Independently assess already-supported Perl interpreted copy paths against the approved scalar target.
  Dependencies:4.2.2.1.2.
  Acceptance: Public producer-first literal/callable invocation controls establish existing free/receiver copy vocabulary before changes. CodeblockRuntime already routes free copy through _copy_value; do not infer a defect or ordinary shallow-depth promise from that source pointer. Preserve current invocation/origin/context/depth behavior and malformed signatures. Fix only actual scalar/result drift; add no new deferred vocabulary. Close as preserved if existing supported paths are healthy; full contexts remain23.4.
  Planned verification tier: focused
  Planned focused checks: Named safe native/fresh copy/input/result/source/malformed/origin controls and relevant component checks only; no full callable/write matrix.
  Planned canonical trigger: Complete copy/context/portable admission23.4 after feature coverage.
  Planned claim verification: none: Deterministic finite preservation/repair controls, no completeness measurement.
  Verification tier: `focused`
  Focused checks: Finite public native/fresh interpreted free-copy primitive kinds, source snapshots/errors, scalar-result guards, method-vocabulary and callable-origin controls; changed/new source syntax and direct deferred-boundary test, book/history/continuity.
  Canonical trigger: Full source/context/portable/admission23.4 and final clean push after feature coverage; independent backends follow Perl.
  Claim verification: none: Deterministic finite preservation/repair controls, no completeness measurement.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree TYPE-REFERENCE-BOOK --id TYPE-REFERENCE-BOOK.1.2.1.4.2.2.1.3`.

- ID: `TYPE-REFERENCE-BOOK.1.2.1.4.2.2.2`
  Status: `completed`
  Goal: Independently assess and complete Rust scalar/null value-copy function and receiver behavior.
  Dependencies:4.2.2.1; ADR0138/copy-value-preservation.md.
  Acceptance: Preserve Bool/Number/String/null kinds, named/literal/selected/block/function/prior-result/scoped flows, source-once/snapshots and compatible continuations. Reject incompatible container consumers before operands after valid prefix effects. Keep receiver shapes, free malformed-signature behavior, current container depth/detachment and callable-origin/context/serialization bounds. Observe own producer/method behavior before changes; update old scalar expectations only under explicit approved target. Safe Lua uses only named PUC5.5.1/LuaJIT fixtures/loadfile, no unsafe patterns/full runner/declared5.4 claim.
  Planned verification tier: focused
  Planned focused checks: Strict finite native/generated kind/value/order/shape/result RED/GREEN where needed and direct copy/scalar-result compatibility plus changed compile/format checks; book/history/continuity only.
  Planned canonical trigger: Complete source/context/portable/copy admission23.4 and final clean push after feature coverage.
  Planned claim verification: none: Deterministic authored feature/preservation controls, no population/completeness measurement.
  Verification tier: `focused`
  Focused checks: Independent Rust producer/method/actual-kind native/restored/plan RED/GREEN, source/shape/snapshot/typed selector/container/legacy controls, direct copy/logical-result checks and changed Rust format/compile; book/history/continuity. No full suite/matrix.
  Canonical trigger: Full source/context/portable/admission23.4 and final clean push after feature coverage; Dart3 follows.
  Claim verification: none: Deterministic finite authored feature/preservation controls, no completeness measurement.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree TYPE-REFERENCE-BOOK --id TYPE-REFERENCE-BOOK.1.2.1.4.2.2.2`.

- ID: `TYPE-REFERENCE-BOOK.1.2.1.4.2.2.3`
  Status: `completed`
  Goal: Independently assess and complete Dart scalar/null value-copy function and receiver behavior.
  Dependencies:4.2.2.2; ADR0138/copy-value-preservation.md.
  Acceptance: Preserve Bool/Number/String/null kinds, named/literal/selected/block/function/prior-result/scoped flows, source-once/snapshots and compatible continuations. Reject incompatible container consumers before operands after valid prefix effects. Keep receiver shapes, free malformed-signature behavior, current container depth/detachment and callable-origin/context/serialization bounds. Observe own producer/method behavior before changes; update old scalar expectations only under explicit approved target. Safe Lua uses only named PUC5.5.1/LuaJIT fixtures/loadfile, no unsafe patterns/full runner/declared5.4 claim.
  Planned verification tier: focused
  Planned focused checks: Strict finite native/generated kind/value/order/shape/result RED/GREEN where needed and direct copy/scalar-result compatibility plus changed compile/format checks; book/history/continuity only.
  Planned canonical trigger: Complete source/context/portable/copy admission23.4 and final clean push after feature coverage.
  Planned claim verification: none: Deterministic authored feature/preservation controls, no population/completeness measurement.
  Verification tier: `focused`
  Focused checks: Shared strict value-copy source plus finite actual-kind/source/shape/typed selector/legacy controls native/restored/plan before edits, direct copy/logical/selected tests and changed format/analyze; book/history/continuity. No full suite/matrix.
  Canonical trigger: Full source/context/portable/admission23.4 and final clean push after feature coverage; Julia4 follows.
  Claim verification: none: Deterministic finite authored feature/preservation controls, no population/completeness measurement.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree TYPE-REFERENCE-BOOK --id TYPE-REFERENCE-BOOK.1.2.1.4.2.2.3`.

- ID: `TYPE-REFERENCE-BOOK.1.2.1.4.2.2.4`
  Status: `completed`
  Goal: Independently assess and complete Julia scalar/null value-copy function and receiver behavior.
  Dependencies:4.2.2.3; ADR0138/copy-value-preservation.md.
  Acceptance: Preserve Bool/Number/String/null kinds, named/literal/selected/block/function/prior-result/scoped flows, source-once/snapshots and compatible continuations. Reject incompatible container consumers before operands after valid prefix effects. Keep receiver shapes, free malformed-signature behavior, current container depth/detachment and callable-origin/context/serialization bounds. Observe own producer/method behavior before changes; update old scalar expectations only under explicit approved target. Safe Lua uses only named PUC5.5.1/LuaJIT fixtures/loadfile, no unsafe patterns/full runner/declared5.4 claim.
  Planned verification tier: focused
  Planned focused checks: Strict finite native/generated kind/value/order/shape/result RED/GREEN where needed and direct copy/scalar-result compatibility plus changed compile/format checks; book/history/continuity only.
  Planned canonical trigger: Complete source/context/portable/copy admission23.4 and final clean push after feature coverage.
  Planned claim verification: none: Deterministic authored feature/preservation controls, no population/completeness measurement.
  Verification tier: `focused`
  Focused checks: Independent shared/finite Julia value-copy sources native/plan/fresh before edits, recursive strict Bool-versus-Number oracle, source/shape/snapshot/typed selector/container/legacy controls and direct copy/logical/selected component checks, compile/book/history/continuity. No full suite/matrix.
  Canonical trigger: Full source/context/portable/admission23.4 and final clean push after feature coverage; safe Lua5 follows.
  Claim verification: none: Deterministic finite authored feature/preservation controls, no population/completeness measurement.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree TYPE-REFERENCE-BOOK --id TYPE-REFERENCE-BOOK.1.2.1.4.2.2.4`.

- ID: `TYPE-REFERENCE-BOOK.1.2.1.4.2.2.5`
  Status: `completed`
  Goal: Independently assess and complete safe Lua scalar/null value-copy function and receiver behavior.
  Dependencies:4.2.2.4; ADR0138/copy-value-preservation.md.
  Acceptance: Preserve Bool/Number/String/null kinds, named/literal/selected/block/function/prior-result/scoped flows, source-once/snapshots and compatible continuations. Reject incompatible container consumers before operands after valid prefix effects. Keep receiver shapes, free malformed-signature behavior, current container depth/detachment and callable-origin/context/serialization bounds. Observe own producer/method behavior before changes; update old scalar expectations only under explicit approved target. Safe Lua uses only named PUC5.5.1/LuaJIT fixtures/loadfile, no unsafe patterns/full runner/declared5.4 claim.
  Planned verification tier: focused
  Planned focused checks: Strict finite native/generated kind/value/order/shape/result RED/GREEN where needed and direct copy/scalar-result compatibility plus changed compile/format checks; book/history/continuity only.
  Planned canonical trigger: Complete source/context/portable/copy admission23.4 and final clean push after feature coverage.
  Planned claim verification: none: Deterministic authored feature/preservation controls, no population/completeness measurement.
  Verification tier: `focused`
  Focused checks: Independent safe-host strict JSON shared/finite copy controls native/plan/fresh before edits; source/shape/snapshot/typed selector/container/legacy and direct copy/logical/selected checks, module/runner loadfile syntax/book/history/continuity. No full suite/matrix.
  Canonical trigger: Complete source/context/portable/admission23.4 and final clean push after feature coverage; declared5.4 remains separate. Finish copy rollout before returning to queued direct computed selection.
  Claim verification: none: Deterministic finite authored feature/preservation controls, no population/completeness measurement.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree TYPE-REFERENCE-BOOK --id TYPE-REFERENCE-BOOK.1.2.1.4.2.2.5`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.1.4`
  Status: `completed`
  Goal: Select the next independent ordinary fluent feature while copy-domain4.2.2 awaits the director.
  Dependencies: Logical family23 all five bounded children targeted-checked; copy authority intake4.2.1 complete.
  Acceptance: Use current helper/signature/receiver inventory and canonical facts; assess public reference before inferring a missing feature or backend defect. Own a bounded family/producer repair and frozen target before changes. Do not change scalar-copy domains without the requested decision. Preserve feature-first focused checks/docs/commit cadence; full admission/context/matrices remain separate.
  Planned verification tier: focused
  Planned focused checks: Exact public producer/receiver probes and changed documentation/continuity only; no full CI or registry audit.
  Planned canonical trigger: Actual contract movement/full family admission and final clean push after ordinary feature coverage.
  Planned claim verification: none: Deterministic feature selection, no population/completeness measurement.
  Verification tier: `focused`
  Focused checks: Canonical typed read/signed-selector and existing value_access contracts, public Perl Get/substitution/native/fresh comparisons against equivalent intermediate-binding controls; source syntax/book/history/staged continuity. No broad matrix or full CI.
  Canonical trigger: Full input/context/portable and new surface admission remain23.4 after feature coverage; any actual generated-format movement must be owned explicitly before code.
  Claim verification: none: Bounded normative feature selection and deterministic authored public controls, no population/completeness measurement.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.1.4 - define computed-value bracket selection`.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree TYPE-REFERENCE-BOOK --id TYPE-REFERENCE-BOOK.1.2.23.1.4`.

- ID: `TYPE-REFERENCE-BOOK.1.2.2`
  Status: `pending`
  Goal: Map the complete reconciled operation/spelling population to actual book coverage and proposed canonical per-type homes.
  Dependencies: `TYPE-REFERENCE-BOOK.1.2.1`, `TYPE-REFERENCE-BOOK.1.2.23`
  Planned tier: `focused`; reclassify before public/mechanical movement.
  Claim verification: none: Unactivated coverage mapping; declare complete source/book evidence before measurement.
  Acceptance: Retain exact current entries/anchors/includes/examples/backend qualifications for every inventory item, mark precise depth/navigation gaps, preserve old anchors and schedule bounded family work. Close .1.2 only after all inventory children agree; independent layout review .1.3 follows. No exhaustive public-reference coverage claim from an inventory closeout.

- ID: `TYPE-REFERENCE-BOOK.1.2.23`
  Status: `active` / ordinary fluent/result implementation follows Current Frontier; earlier bounded backend outcomes retain their recorded qualifications; complete inventory/context/matrix/admission remain open
  Goal: Establish comprehensive fluent method families for every supported type and complete inter-type chaining.
  Dependencies: `TYPE-REFERENCE-BOOK.1.2.1`
  Children: `TYPE-REFERENCE-BOOK.1.2.23.1`, `TYPE-REFERENCE-BOOK.1.2.23.2`, `TYPE-REFERENCE-BOOK.1.2.23.3`, `TYPE-REFERENCE-BOOK.1.2.23.4`.
  Schedule: Director's comprehensive-method requirement plus current feature-first steering selects the concrete first/last result transition before exhaustive inventory/matrix completion. Freeze that bounded contract, then implement native children; full inventory, transition matrix and final admission remain parent closeout dependencies. Do not resume superseded Rust17.3 work.
  Acceptance: Assess useful semantic operation families as well as implemented names. Own and resolve missing fluent operations/transitions before declaring a type complete. Dispatch each chain continuation by its returned value's actual type; preserve container element types, mutation/detachment, callback/error/empty behavior and backend limits. Do not invent a new type or meaningless method merely for symmetry.
  Planned tier: Select per child; new public methods/contracts and final admission require canonical proof.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.1.5`
  Status: `completed`
  Goal: Select the next useful ordinary fluent method family or inter-type transition after all bounded computed-selection implementations.
  Dependencies: Completed bounded23.3.24 children and approved copy4.2.2; helpers.md/current contracts/book and prior inventory records.
  Acceptance: Reconcile retained semantic helper roles and implemented result/method families with actual per-type use cases; do not equate helper names or resolver categories with method admission. Identify a bounded missing ordinary family/transition, resolve only necessary public producer distinctions, freeze its target and own implementation children before production. Preserve deferred/context/control/list-splice/mutation/copy rights and prior defect owners. Do not claim exhaustive coverage or pivot to admission/maintenance while feature gaps remain.
  Planned verification tier: focused
  Planned focused checks: Targeted canonical inventory/contracts/book and only small public distinguishing probes if needed; normal docs/continuity. No exhaustive matrix/full suite.
  Planned canonical trigger: Full feature/source/domain/context/portable admission23.4 and final clean push after feature coverage.
  Planned claim verification: none: Prospective bounded feature selection; declare any actual measurement at activation.
  Verification tier: `focused`
  Focused checks: Canonical helper roles/current entry-local capture contracts, small Get/runtime context/native/fresh/substitution distinction, producer/named/fluent/copy/compatibility controls and probe syntax; scoped book/history/fast continuity/diff. No complete matrix/history/full gate.
  Canonical trigger: Full source/domain/context/portable/generated admission23.4 and final clean push after feature coverage; any actual metadata/format movement must be owned explicitly before implementation.
  Claim verification: none: Bounded normative feature selection and deterministic authored distinctions; no population/completeness measurement.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.1.5 - select capture collection result composition`.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree TYPE-REFERENCE-BOOK --id TYPE-REFERENCE-BOOK.1.2.23.1.5`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.1.6`
  Status: `completed`
  Goal: Select the next useful ordinary method family or inter-type transition after bounded capture collection composition.
  Dependencies: Completed bounded25 children and preservation25.0; retained spelling/role/source inventory, actual per-type contracts and current book.
  Acceptance: Reconcile semantic helper roles, callable signatures and implemented method/result families with project use cases; select and freeze any remaining required feature with implementation owners before production. Use only small public distinctions for unresolved facts. Preserve deferred/context/control/list-splice/mutation/copy rights and existing defect owners. Do not equate registered names or bounded test success with exhaustive method completeness; do not start admission/maintenance while feature gaps remain.
  Planned verification tier: focused
  Planned focused checks: Targeted canonical inventory/contracts/book and small distinguishing public probes only when needed; normal docs/continuity. No whole suite/exhaustive matrix.
  Planned canonical trigger: Full feature/source/domain/context/portable admission23.4 and final clean push after feature coverage.
  Planned claim verification: none: Prospective bounded feature selection; declare any actual measurement at activation.
  Verification tier: `focused`
  Focused checks: Canonical helper roles/current inline-control and typed-read contracts/book; six public native/fresh/descriptor/substitution cases, four condition controls and four AST distinctions; producer syntax/JSON, book/history/fast staged continuity/diff. No production/full matrix/CI.
  Canonical trigger: Full source/domain/context/portable/generated admission23.4 and final clean push after feature coverage; actual schema/format movement requires separate ownership.
  Claim verification: none: Normative bounded feature selection and deterministic finite authored distinctions; no population/completeness measurement.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.1.6 - select inline conditional result selection`.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree TYPE-REFERENCE-BOOK --id TYPE-REFERENCE-BOOK.1.2.23.1.6`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.1.7`
  Status: `completed`
  Goal: Select the next useful ordinary fluent method family or inter-type transition after conditional result composition26.
  Dependencies: Completed bounded26 children and prerequisite26.0; canonical helper roles/signatures, per-type contracts, current book and preservation owners.
  Acceptance: Reconcile remaining semantic operations and result transitions against implemented families and practical use cases. Freeze the next justified bounded feature and independent implementation owners before production; use small public distinctions only for unresolved facts. Preserve callback/control/marker/list-splice/mutation/copy/error boundaries and existing defect owners. Do not infer exhaustive completeness from name inventories or passing finite checks, and do not pivot to admission/maintenance while feature gaps remain.
  Planned verification tier: focused
  Planned focused checks: Relevant canonical inventory/contracts/book; small public source/producer/result distinctions as needed; docs/history/continuity. No full suite/exhaustive matrix.
  Planned canonical trigger: Full source/domain/context/portable/generated admission23.4 and final clean push after feature coverage.
  Planned claim verification: none: Prospective bounded feature selection; declare any actual measurement at activation.
  Verification tier: `focused`
  Focused checks: Canonical semantic spelling/role inventory, typed source-location reader contracts, current reader/default/value book; nine corrected authored distinctions plus three input/cursor controls, original instrument/channels retained; producer syntax, packet/fixture JSON, book/history/fast staged continuity/diff. No full suite/matrix.
  Canonical trigger: Full source/domain/context/portable/generated admission23.4 and final clean push after feature coverage; actual format/contract/infrastructure changes require separate ownership.
  Claim verification: none: Normative bounded feature selection and deterministic finite authored controls; no population/completeness measurement.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.1.7 - select input and cursor value composition`.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree TYPE-REFERENCE-BOOK --id TYPE-REFERENCE-BOOK.1.2.23.1.7`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.1.8`
  Status: `completed`
  Goal: Select the next useful ordinary fluent family or inter-type transition after bounded function-state prerequisite repairs29.2.
  Dependencies: Completed bounded result families1-27, scalar-root28.1/static-name29.1 and catalogued/noncatalogued function repairs29.2; canonical operation/source/signature inventory and current book. Stale neutral example29.2.6.6 and full admission stay independently scheduled.
  Acceptance: Reconcile remaining meaningful operations/result transitions against frozen targets and current per-type requirements. Start with readonly entry/match scalar reader flow and other remaining source/data transforms where useful, without assuming a gap or that every parser helper needs a method. Consult Knowledge Map/canonical owner before re-deriving; use a few public producer/result distinctions only for unresolved facts. Freeze the next bounded feature and independent implementation owners before production. Preserve parser/callback/deferred/control/marker/list-splice/mutation/copy/error boundaries and legacy special-source policies. No exhaustive matrix/completeness claim or maintenance pivot while features remain.
  Planned verification tier: focused
  Planned focused checks: Relevant current canonical inventory/contracts/book, small distinguishing public observations if needed, producer syntax/fixture JSON/book/history/continuity. No full suite/matrix.
  Planned canonical trigger: Full source/domain/context/portable/generated23.4 and final clean push after feature coverage; actual public contract/schema/infrastructure movement separately owned.
  Planned claim verification: none: Prospective deterministic finite feature selection; declare any actual measurement at activation.
  Verification tier: `focused`
  Focused checks: Current helper spelling/role and source-location/Number/default/with/root contracts; six original plus five distinguishing public native/fresh/Value-descriptor/substitution cases. Producer syntax and prospective fixture JSON, book/history/fast continuity/diff. No full suite/matrix or prospective target execution admission.
  Canonical trigger: Full source/domain/context/portable/generated23.4 and final clean push after feature coverage; actual public contract/schema/infrastructure movement independently owned.
  Claim verification: none: Normative bounded target selection and deterministic finite authored diagnostics, not a population/completeness measurement.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.1.8 - select entry and match Number result composition`.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree TYPE-REFERENCE-BOOK --id TYPE-REFERENCE-BOOK.1.2.23.1.8`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.1.9`
  Status: `completed`
  Goal: Select the next useful bounded fluent family/inter-type transition after Number30, with-result31 and their immediate callback prerequisites.
  Dependencies: Current canonical operation/source/signature inventory, completed bounded feature children and relevant book; broad context/portable admission, document pressure and excluded deferred readiness31.6.4.4 stay separately scheduled.
  Acceptance: Reconcile implemented coverage with remaining meaningful methods/result transitions, consult Knowledge Map/canonical owners before deriving facts, and use only small public distinctions for uncertain facts. Freeze the next bounded target and independent implementation/prerequisite owners before production; do not assume a gap or infer completeness. Preserve existing deferred/callback/control/parser/unknown-source/first-consumer/root/mutation/copy boundaries. No maintenance/full-matrix pivot while useful features remain.
  Planned verification tier: focused
  Planned focused checks: Relevant inventory/contracts/book, a few finite source/actual-result distinctions if needed, producer syntax/fixture JSON/book/history/continuity; no full suite/matrix.
  Planned canonical trigger: Full source/domain/context/portable/generated23.4/final clean push after feature coverage; actual public contract/schema movement separately owned.
  Planned claim verification: none: Prospective finite authored feature selection; no population measurement.
  Verification tier: `focused`
  Focused checks: Current helpers/syntax/computed24/conditional26/with31/callable contract and current book; eight public native/fresh/Top metadata/AST/substitution distinctions with independent prospective oracle RED4 helper gaps/4 healthy controls. Producer syntax and normative fixture JSON14 strict coordinates; book/history/fast continuity. No fixture execution/full suite/matrix claim.
  Canonical trigger: Independent bounded32.1-.5 implementations next; full source/domain/context/portable/generated23.4/final clean push after feature coverage. Excluded deferred readiness31.6.4.4 stays owned.
  Claim verification: none: Normative finite authored target and deterministic diagnostic distinctions; no population/completeness measurement.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.1.9 - select immediate with-result bracket composition`.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree TYPE-REFERENCE-BOOK --id TYPE-REFERENCE-BOOK.1.2.23.1.9`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.1.10`
  Status: `completed`
  Goal: Select the next useful bounded fluent method/result transition after immediate with-selection32.
  Dependencies: Current canonical helper/source/signature inventory, bounded implemented families and relevant book. Full context/portable23.4, pressure20.1, excluded deferred readiness31.6.4.4 and declared-host admission remain separately scheduled.
  Acceptance: Reconcile meaningful remaining per-type methods and inter-type transitions with implemented coverage; use Knowledge Map/canonical authorities first, then a few public source/actual-result distinctions for uncertainty. Freeze the next safe additive target and independent implementation/prerequisite leaves before production. Preserve current deferred/callback/control/parser/unknown/source/first-consumer/root/mutation/copy boundaries. No completeness claim or maintenance/full-matrix pivot while useful features remain.
  Planned verification tier: focused
  Planned focused checks: Relevant inventory/contracts/book and small public distinctions where needed, producer syntax/JSON/book/history/manual continuity; no full suite/matrix.
  Planned canonical trigger: Full source/domain/context/portable/generated23.4/final clean push after feature coverage; actual public contract/schema movement separately owned.
  Planned claim verification: none: Prospective finite authored feature selection, no population measurement.
  Verification tier: `focused`
  Focused checks: Canonical helpers/source/getter contracts/book and public Get/native/fresh/descriptor/substitution/dump controls. Exact final-row JSON consumer guards separate NONE diagnostic prefix. Producer syntax and prospective fixture JSON, readonly/alias/bound snapshot calibration native/fresh, book/map/history/manual continuity. No production change/full suite/matrix.
  Canonical trigger: Independent bounded33 children, P1 block35 then named34; full23.4/new Perl registration23.4.1/document pressure20.1/final clean push after feature coverage remain separate.
  Claim verification: none: Finite authored feature selection/calibration and defect ownership, no population or completeness measurement.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.1.10 - select readonly capture Number composition and own adjacent source defects`.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree TYPE-REFERENCE-BOOK --id TYPE-REFERENCE-BOOK.1.2.23.1.10`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.1.11`
  Status: `completed`
  Goal: Select and freeze the next useful ordinary fluent result transition after the retained Perl regression subset is GREEN. Start with readonly capture String producers and related result-kind guards; distinguish already-supported behavior from an actual gap before choosing implementation.
  Dependencies: Canonical helper/source/signature inventory, source-boundary contract, existing33/34/35/42/47/49 targets, current book and Knowledge Map. Full23.4/pressure20.1/Perl registration/declared Lua host and broader deferred-context owners stay separate.
  Acceptance: Read relevant accepted roles/result/value/error/absence/alias authority; use a few public native/fresh producer/bound/direct controls with a proven action carrier and actual action-bearing metadata/source. Preserve coordinates/zero/empty/missing/snapshots/operand order, first-consumer and context/function/callback/mutation/copy boundaries. Freeze one safe additive target and independent bounded backend/prerequisite leaves before any production edit. No blanket helper allowlist, count-based completeness or broad matrix.
  Verification tier: `focused`
  Focused checks: Relevant inventory/contracts/book, finite public distinguishing producer/direct/bound cases and actual source/readiness, prospective fixture syntax/JSON plus book/map/history/manual continuity. No full suite/matrix.
  Canonical trigger: Full source/domain/context/portable23.4/final clean push after feature coverage and owned prerequisites; actual public contract/generated-format movement separately owned.
  Claim verification: none: Finite authored feature selection/diagnostic controls, no population or comprehensive-method measurement.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.1.11 - select readonly capture String result composition`.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree TYPE-REFERENCE-BOOK --id TYPE-REFERENCE-BOOK.1.2.23.1.11`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.1.12`
  Status: `completed`
  Goal: Select the next useful ordinary fluent/result transition after all bounded readonly capture String50 children have focused outcomes. Assess existing advancing capture String/Number result sources and related remaining helper roles first, without assuming a gap or imposing new mutation semantics.
  Dependencies: Current canonical helper/source/signature inventory, typed source-location contract, bounded33/34/35/40/42/47/49/50 targets, book and Knowledge Map. Full23.4/pressure20.1/Perl registration/declared5.4 and existing deferred-context/authority owners remain separate.
  Acceptance: Establish actual existing signatures/result kinds/endpoints/advance/null/alias/shape/function/callback authority before production. Use finite public source/bound/direct controls and distinguishing once-only source/effect/empty/missing/consumer observations with a proven action carrier. Freeze one safe additive target and independent implementation/prerequisite owners. Preserve first-consumer/copy/error-phase/serialization bounds; no blanket helper allowlist or completeness claim.
  Verification tier: `focused`
  Focused checks: Relevant inventory/contracts/book and a few actual public producer/direct/bound/effect distinctions, prospective fixture syntax/JSON, book/map/history/manual continuity. No full suite/matrix.
  Canonical trigger: Full source/domain/context/portable23.4/final clean push after features/owned prerequisites; actual public contract/generated-format movement separately owned.
  Claim verification: none: Finite authored feature selection/diagnostic controls, no population or comprehensive-method measurement.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.1.12 - select advancing capture String result composition`.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree TYPE-REFERENCE-BOOK --id TYPE-REFERENCE-BOOK.1.2.23.1.12`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.1.13`
  Status: `completed`
  Goal: Select the next useful ordinary fluent/result family after bounded advancing String51; first assess existing anonymous advancing Number counterparts without assuming a gap or changing mutation semantics.
  Dependencies: Current helper/source/signature inventory, typed source-location contract, bounded30/35/40/47/49/50/51 targets, book and Knowledge Map. Full23.4/pressure20.1/registration/declared5.4 and existing deferred/context/authority owners remain separate.
  Acceptance: Establish actual signatures/result kinds/endpoints/advance/null/zero/shape/function/callback authority before production. Use finite public primitive/bound/direct/effect controls and a proven action carrier; freeze one safe target and independent implementation/prerequisite owners. Preserve named overload/first-consumer/copy/error-phase/serialization boundaries; no blanket helper allowlist or completeness claim.
  Verification tier: `focused`
  Focused checks: Relevant inventory/contracts/book and finite public source/bound/direct/effect distinctions, prospective fixture syntax/JSON, book/map/history/manual continuity. No full suite/matrix.
  Canonical trigger: Full source/domain/context/portable23.4/final clean push after features and owned prerequisites; contract/generated-format movement separately owned.
  Claim verification: none: Finite authored feature selection/diagnostic controls, no population/comprehensive-method measurement.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.1.13 - select advancing capture Number result composition`.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree TYPE-REFERENCE-BOOK --id TYPE-REFERENCE-BOOK.1.2.23.1.13`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.1.14`
  Status: `completed`
  Goal: Select the next useful ordinary fluent/result family after bounded advancing Number52, beginning remaining named capture String/advancing-result and computed/effect-returning source transitions without assuming a gap.
  Dependencies: Current helper/source/signature/result-role inventory, typed source-location contract, bounded25/30/33/34/35/40/42/47/49/50/51/52 targets, book and Knowledge Map. Full23.4/pressure20.1/registration/declared5.4/deferred/context/authority owners remain separate.
  Acceptance: Establish existing signatures/result kinds/endpoints/effects/null/zero/shape/function/callback authority before production. Use finite public primitive/bound/direct/effect controls with a proven carrier; freeze one safe additive target and independent implementation/prerequisite owners. Preserve named/first-consumer/copy/error-phase/serialization bounds; no blanket helper allowlist or completeness claim.
  Verification tier: `focused`
  Focused checks: Relevant inventory/contracts/book and finite public source/bound/direct/effect distinctions, prospective fixture syntax/JSON, book/map/history/manual continuity. No full suite/matrix.
  Canonical trigger: Full source/domain/context/portable23.4/final clean push after features and owned prerequisites; actual contract/generated-format movement separately owned.
  Claim verification: none: Finite authored feature selection/diagnostic controls, no population/comprehensive-method measurement.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.1.14 - select structural boundary capture result composition`.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree TYPE-REFERENCE-BOOK --id TYPE-REFERENCE-BOOK.1.2.23.1.14`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.1.15`
  Status: `completed`
  Goal: Select the next useful ordinary fluent/result family after bounded structural-boundary53, beginning remaining rule-call result and other helper/effect-returning source continuations without assuming a gap.
  Dependencies: Current helper/source/signature/result-role inventory, typed source-location contract, existing25/30/33/34/35/40/42/47/49/50/51/52/53 targets, rule-call invocation/child-frame/cursor/error/context authorities and Knowledge Map/book. Full23.4/pressure20.1/registration/declared5.4/deferred/context/authority owners remain separate.
  Acceptance: Establish existing signatures/result kinds/effects/null/empty/shape/function/callback and invocation scope authority before production. Finite public primitive/bound/direct/effect controls on proven carriers distinguish gaps from healthy forms; freeze one safe additive target and independent backend/prerequisite owners. Preserve named/first-consumer/copy/error-phase/serialization contracts; no blanket allowlist or completeness claim.
  Verification tier: `focused`
  Focused checks: Relevant inventory/contracts/book and finite public source/bound/direct/effect distinctions, prospective fixture syntax/JSON, book/map/history/manual continuity. No full suite/matrix.
  Canonical trigger: Full source/domain/context/portable23.4/final clean push after features and owned prerequisites; actual contract/generated-format movement separately owned.
  Claim verification: none: Finite authored feature selection/diagnostic controls, no population/comprehensive-method measurement.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.1.15 - select rule call result reads and own closed selector prerequisite`.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree TYPE-REFERENCE-BOOK --id TYPE-REFERENCE-BOOK.1.2.23.1.15`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.1.16`
  Status: `completed`
  Goal: Select the next useful ordinary fluent/result family after bounded static rule-call54, beginning remaining inter-match gap/slot boxed-record reads and cursor effect-returning Number sources without assuming a gap.
  Dependencies: Current helper/signature/source/result-role inventory, gap/slot capture and typed source-location/cursor contracts, existing25/27/29/33/34/35/40/42/47/49/50/51/52/53/54 targets, Knowledge Map/book. Full23.4/pressure20.1/registration/declared5.4/context/error-authority owners stay separate.
  Acceptance: Establish existing signatures/actual kinds/effects/offset/span/null/empty/shape/function/callback authority first. Finite public primitive/bound/direct/effect controls on a documented carrier distinguish actual gaps from healthy forms; freeze one safe additive target and independent backend/prerequisite owners before production. Preserve metadata/policies/named/first-consumer/copy/error-phase/serialization boundaries, no blanket helper allowlist or completeness claim.
  Verification tier: `focused`
  Focused checks: Relevant inventory/contracts/book and finite public source/bound/direct/effect distinctions, prospective fixture syntax/JSON, book/map/history/manual continuity. No full suite/matrix.
  Canonical trigger: Full source/domain/context/portable23.4/final clean push after features and owned prerequisites; actual contract/format movement separately owned.
  Claim verification: none: Finite authored feature selection/diagnostic controls, no population/comprehensive-method measurement.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.1.16 - select gap and slot record computed reads`.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree TYPE-REFERENCE-BOOK --id TYPE-REFERENCE-BOOK.1.2.23.1.16`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.1.17`
  Status: `completed`
  Goal: Select the next useful ordinary fluent/result family after bounded gap-slot record55, beginning remaining cursor effect-returning Number sources without assuming a gap.
  Dependencies: Current helper/signature/source/result-role inventory, input/cursor and typed source-location contracts, existing25/27/29/33/34/35/40/42/47/49/50/51/52/53/54/55 targets, Knowledge Map/book.
  Acceptance: Reconcile remaining source/result/method families with actual completed bounded work. Establish existing signatures/kinds/effects/offset/shape/context authority first. Finite public primitive/bound/direct/effect controls distinguish actual gaps from healthy forms; freeze one safe additive target and backend/prerequisite owners before production. Preserve capture/state/metadata/lifecycle/function/callback/deferred/copy/error/schema policies. Full23.4, pressure20.1/registration/declared5.4/exhaustive verification stay separate.
  Verification tier: `focused`
  Focused checks: Relevant canonical inventory/contracts/book and finite public source/bound/direct/effect distinctions, prospective fixture syntax/JSON, book/map/history/manual continuity. No full suite/matrix.
  Canonical trigger: Full source/domain/context/portable23.4/final clean push after features and owned prerequisites; contract movement separately owned.
  Claim verification: none: Finite authored feature selection, no population/comprehensive-method measurement.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.1.17 - select cursor rewind Number result composition`.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree TYPE-REFERENCE-BOOK --id TYPE-REFERENCE-BOOK.1.2.23.1.17`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.1.18`
  Status: `completed`
  Goal: Select the next useful bounded fluent method/result-type feature after recorded rewind56 implementations and arity repairs, using current inventory and actual use cases rather than assuming helper coverage is complete.
  Dependencies: Current helpers/signatures/source/result-role inventory and per-type gap records, completed bounded result targets through56, canonical contracts/Knowledge Map/book and current feature-first cadence.
  Acceptance: Reconcile ordinary returned-type transitions and each supported type's method families with current implementations and open owners. Establish existing signatures/kinds/effects/mutation/aliasing/context/shape/error authority. Use finite public primitive/bound/direct controls for unknown distinctions, distinguish missing useful features from healthy or intentionally excluded surfaces, and freeze one safe additive target with prerequisite/backend owners before production. Preserve deferred/callback/function/state/copy/error/schema authority. Full23.4, document pressure20.1/atomic publication20.1.1/registration/progress authority/declared5.4/exhaustive17.7 remain separately owned; no cleanup or broad-verification pivot.
  Verification tier: `focused`
  Focused checks: Relevant canonical inventory/contracts/book plus finite distinguishing public observations and prospective fixture/source/JSON checks; book/map/history/manual continuity. No full suite/matrix or population measurement.
  Canonical trigger: Full domain/context/portable admission/final clean push after features and owned prerequisites; actual new public authority separately owned.
  Claim verification: none: Finite authored feature selection, no complete method/coverage/population measurement.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.1.18 - select guarded gap String result composition`.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree TYPE-REFERENCE-BOOK --id TYPE-REFERENCE-BOOK.1.2.23.1.18`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.1.19`
  Status: `completed`
  Goal: Select the next useful bounded fluent method/result-type feature after recorded gap String57 implementations, from canonical inventory and actual use cases.
  Dependencies: Current helpers/signatures/source/result-role inventory and per-type gap records, bounded targets through57, current contracts/Knowledge Map/book and feature-first cadence.
  Acceptance: Reconcile remaining useful per-type/inter-type method families with current authority and implementations. Establish signatures/kinds/effects/mutation/aliasing/context/shape/errors before selecting an additive target. Use finite public primitive/bound/direct controls only for unknown distinctions; preserve deferred/function/callback/state/copy/error/schema authority. Freeze target and prerequisite/backend owners before production. No broad verification, cleanup or infrastructure pivot; full23.4/pressure20.1/atomic-map20.1.1/registration/progress/declared-host/exhaustive owners remain separate.
  Verification tier: `focused`
  Focused checks: Relevant canonical inventory/contracts/book, finite distinguishing public controls and fixture/source/JSON checks as needed; book/map/history/manual continuity.
  Canonical trigger: Full domain/context/portable admission and final clean push after features and owned prerequisites; actual new public authority separately owned.
  Claim verification: none: Finite authored feature selection, no complete method/domain/context/population measurement.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.1.19 - select explicit push snapshot composition`.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree TYPE-REFERENCE-BOOK --id TYPE-REFERENCE-BOOK.1.2.23.1.19`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.1.20`
  Status: `completed`
  Goal: Select the next useful bounded per-type/inter-type fluent or result-source feature after recorded58 outcomes.
  Dependencies: Current canonical helper/signature/source/result-role inventory, bounded targets through58, contracts/Knowledge Map/book and feature-first cadence.
  Acceptance: Reconcile useful remaining method/result/source families with existing authority. Establish signatures/kinds/effects/mutation/aliasing/context/shape/error boundaries before selecting a target. Use finite public primitive/bound/direct controls only for unknown distinctions; preserve callback/deferred/function/state/copy/error/schema authority. Freeze target and prerequisite/backend owners before production. No broad verification/cleanup/infrastructure pivot; full23.4/pressure20.1/atomic-map20.1.1/registration/progress/declared-host/exhaustive owners stay separate.
  Verification tier: `focused`
  Focused checks: Relevant canonical inventory/contracts/book and finite distinguishing public controls/fixture/source/JSON checks; book/map/history/manual continuity.
  Canonical trigger: Full domain/context/portable admission and final clean push after features and owned prerequisites; new public authority separately owned.
  Claim verification: none: Finite authored feature selection, no complete method/domain/context/population measurement.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.1.20 - select canonical set result composition`.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree TYPE-REFERENCE-BOOK --id TYPE-REFERENCE-BOOK.1.2.23.1.20`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.1.21`
  Status: `completed`
  Goal: Resolve the independently observed Rust free-default result-source guard gap after bounded59 peer rollout.
  Dependencies: Bounded59.5; current helper/source/result inventory, existing default6/18 authority and scalar operand-domain contracts.
  Acceptance: Establish published scalar counterparts and current free helper signature/source-shape/domain/context authority before implementation. Existing6 excludes free coalesce and18 does not grant universal aggregate domains. Use finite public primitive/bound/direct and scalar/container distinctions; preserve helper producer/arity/laziness/copy/alias/parser/schema and unknown unbridged bound-call policy. Freeze bounded target/prerequisite/backend owners, then implement every confirmed defect. No portable aggregate-domain promotion by this record, broad verification/cleanup pivot or inferred peer defect.
  Verification tier: `focused`
  Focused checks: Canonical inventory/contracts/book plus finite distinguishing public controls/fixture checks and manual book/map/history continuity.
  Canonical trigger: Full domain/context/portable admission/final clean push after owned prerequisites; new public authority separately owned.
  Claim verification: none: Finite authored source/defect controls, no complete method/domain/context/population measurement.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.1.21 - select guarded free-default result composition`.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree TYPE-REFERENCE-BOOK --id TYPE-REFERENCE-BOOK.1.2.23.1.21`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.1.22`
  Status: `completed`
  Goal: Select the next useful bounded per-type/inter-type fluent or result-source feature after recorded60 outcomes.
  Dependencies: Bounded60.5; current canonical helper/signature/source/result-role inventory, existing targets through60, contracts/Knowledge Map/book and feature-first cadence.
  Acceptance: Reconcile useful remaining method/result/source families with existing authority, including documented Array/Hash constructor result composition if still unassessed. Establish signatures/kinds/effects/mutation/aliasing/context/shape/error boundaries before selecting a target. Use finite public primitive/bound/direct controls only for unknown distinctions, no assumed missing behavior. Preserve callback/deferred/function/state/copy/error/schema and legacy source-kind authority. Freeze target/prerequisite/backend owners before production. Full23.4/pressure20.1/atomic map20.1.1/registration/progress/declared-host/exhaustive owners remain separate; no broad verification/cleanup pivot.
  Verification tier: `focused`
  Focused checks: Relevant inventory/contracts/book and finite distinguishing public controls/fixture/source/JSON checks; book/map/history/manual continuity.
  Canonical trigger: Full domain/context/portable admission/final clean push after owned prerequisites; new public authority separately owned.
  Claim verification: none: Finite authored feature selection, no complete method/domain/context/population measurement.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.1.22 - select constructor results and isolate Perl sort scope prerequisite`.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree TYPE-REFERENCE-BOOK --id TYPE-REFERENCE-BOOK.1.2.23.1.22`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.1.23`
  Status: `completed` / frozen free String62/P1 Perl isolation first
  Goal: Select the next useful bounded per-type/inter-type fluent or result-source feature after recorded61 outcomes.
  Dependencies: Bounded61.5; current canonical helper/signature/source/result-role inventory, existing targets through61, contracts/Knowledge Map/book and feature-first cadence.
  Acceptance: Reconcile remaining useful operation families with existing authority and completed bounded work; do not infer a missing feature from spelling counts. Establish signatures/kinds/effects/mutation/aliasing/context/shape/error boundaries before selecting a target. Use finite public primitive/bound/direct controls only for unresolved distinctions. Preserve callback/deferred/function/state/copy/error/schema and legacy source-kind policy. Freeze target/prerequisite/backend owners before production. Full23.4/pressure20.1/atomic map20.1.1/registration/progress/declared-host/exhaustive owners remain separate; no broad verification/cleanup pivot.
  Verification tier: `focused`
  Focused checks: Relevant inventory/contracts/book and finite distinguishing public controls/fixture/source/JSON checks; book/map/history/manual continuity.
  Canonical trigger: Full domain/context/portable admission/final clean push after owned prerequisites; new authority separately owned.
  Claim verification: none: Finite authored feature selection, no complete method/domain/context/population measurement.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.1.23 - select free String result guards and own Perl host Hash isolation`.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree TYPE-REFERENCE-BOOK --id TYPE-REFERENCE-BOOK.1.2.23.1.23`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.1`
  Status: `active` / bounded remaining-feature selection child; full matrix open
  Children: `.23.1.1`, `.23.1.2`, `.23.1.3`, `.23.1.4`, `.23.1.5`, `.23.1.6`, `.23.1.7`, `.23.1.8`, `.23.1.9`, `.23.1.10`, `.23.1.11`, `.23.1.12`, `.23.1.13`, `.23.1.14`, `.23.1.15`, `.23.1.16`, `.23.1.17`, `.23.1.18`, `.23.1.19`, `.23.1.20`, `.23.1.21`, `.23.1.22`, `.23.1.23`, `.23.1.24`, `.23.1.25`, `.23.1.26`, `.23.1.27`, `.23.1.28`, `.23.1.29`, `.23.1.30`, `.23.1.31`, `.23.1.32`, `.23.1.33`, `.23.1.34`, `.23.1.35`, `.23.1.36`, `.23.1.37`, `.23.1.38`, `.23.1.39`, `.23.1.40`, `.23.1.41`, `.23.1.42`.
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
  Verification tier: `focused`
  Focused checks: Canonical role/traversal records/book, public producer-first native/fresh small distinguishing controls and syntax, book/history/staged continuity guards; no full runtime matrix.
  Canonical trigger: None for bounded feature selection under director feature-first cadence; full signature/context/portable admission/final clean push separate.
  Claim verification: none: normative feature selection and deterministic authored distinctions; no aggregate coverage/population measurement.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.1.1 - select reduction result continuations`.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree TYPE-REFERENCE-BOOK --id TYPE-REFERENCE-BOOK.1.2.23.1.1`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.1.2`
  Status: `completed`
  Goal: Select the next ordinary fluent feature after bounded data-result and reduction families through21.
  Dependencies: .23.3.21.5.
  Acceptance: Reconcile remaining String/Array/Hash-producing helper and wrapper roles from retained helpers.md, canonical contracts/book and current fact cards against implemented useful methods. Resolver categories are not input types or method admission. Select a small meaningful missing family/transition from the actual contracts, use public producer/result distinctions only if needed, and own/freeze its implementation before production. Do not promote constructor/list-splice, control, parser-state, callback/deferred or mutation-only roles by spelling alone. No exhaustive coverage claim or full matrix; keep error-signature/pressure/admission owners explicit and feature-first focused cadence.
  Planned verification tier: focused
  Planned focused checks: Targeted canonical role/domain/method records and small public distinctions needed for next selection, current book/normal continuity.
  Planned canonical trigger: Full signature/context/portable/doctrine admission and final clean push remain separate.
  Planned claim verification: none: bounded normative feature selection and authored distinctions, no aggregate completeness/population measurement.
  Verification tier: `focused`
  Focused checks: Canonical spelling/role/producer domains/book and small public native/fresh distinguishing controls, source syntax/book/history/staged memory/cadence/diagnosis only; no broad matrix/global registry replay.
  Canonical trigger: None for ordinary bounded feature selection under director feature-first cadence; full domain/context/portable/admission pressure and final push remain separate.
  Claim verification: none: normative selection and authored distinctions, no aggregate completeness/population measurement.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.1.2 - freeze tagged-record String bridge repairs`.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree TYPE-REFERENCE-BOOK --id TYPE-REFERENCE-BOOK.1.2.23.1.2`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.1.3`
  Status: `completed`
  Goal: Select the next meaningful ordinary fluent family/transition after bounded data-result, reduction and tagged-record families1-22.
  Dependencies: .23.3.22.5.
  Acceptance: Reconcile retained helper/wrapper/receiver roles, current canonical facts/contracts/book and ordinary exclusions against implemented bounded families. Choose a useful missing operation/transition without treating resolver output category as input type, reviving compatibility spellings or inventing meaningless symmetry. Small independent public producer-first distinction as needed; freeze one safe target and schedule backend leaves before production. Full type/context/domain matrix/admission, error parity and pressure maintenance stay separately owned.
  Planned verification tier: focused
  Planned focused checks: Targeted canonical inventory/contracts/book and small distinguishing public observation, syntax/book/history/staged continuity. No full suite/population census or historical replay campaign.
  Planned canonical trigger: Full domain/context/portable admission and final clean push remain separate under director feature-first cadence.
  Planned claim verification: none: normative bounded feature selection and authored examples; no population/completeness measurement.
  Verification tier: `focused`
  Focused checks: ADR0043 and neutral logical-helper policy/helper cases, canonical role inventory/current book, small public Get/runtime_ctx_ref/substitution/native/fresh distinction and syntax/book/history/staged continuity. No broad matrix/history campaign.
  Canonical trigger: New method/domain/context/portable admission and final canonical push remain23.4 after feature coverage, including signature parity/canonical registration/pressure repair. Director small-check implementation cadence governs ordinary leaves.
  Claim verification: none: normative bounded feature selection and deterministic authored controls; no population/completeness measurement.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.1.3 - freeze eager logical receiver counterparts`.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree TYPE-REFERENCE-BOOK --id TYPE-REFERENCE-BOOK.1.2.23.1.3`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.2`
  Status: `active` / bounded selection contract; full matrix remains open
  Children: `TYPE-REFERENCE-BOOK.1.2.23.2.1`, `TYPE-REFERENCE-BOOK.1.2.23.2.2`, `TYPE-REFERENCE-BOOK.1.2.23.2.3`, `TYPE-REFERENCE-BOOK.1.2.23.2.4`, `TYPE-REFERENCE-BOOK.1.2.23.2.5`, `TYPE-REFERENCE-BOOK.1.2.23.2.6`, `TYPE-REFERENCE-BOOK.1.2.23.2.7`, `TYPE-REFERENCE-BOOK.1.2.23.2.8`, `TYPE-REFERENCE-BOOK.1.2.23.2.9`, `TYPE-REFERENCE-BOOK.1.2.23.2.10`, `TYPE-REFERENCE-BOOK.1.2.23.2.11`, `TYPE-REFERENCE-BOOK.1.2.23.2.12`, `TYPE-REFERENCE-BOOK.1.2.23.2.13`, `TYPE-REFERENCE-BOOK.1.2.23.2.14`, `TYPE-REFERENCE-BOOK.1.2.23.2.15`, `TYPE-REFERENCE-BOOK.1.2.23.2.16`, `TYPE-REFERENCE-BOOK.1.2.23.2.17`, `TYPE-REFERENCE-BOOK.1.2.23.2.18`, `TYPE-REFERENCE-BOOK.1.2.23.2.19`, `TYPE-REFERENCE-BOOK.1.2.23.2.20`
  Goal: Define and verify the result-type transition matrix and cross-type fluent contracts.
  Dependencies: `TYPE-REFERENCE-BOOK.1.2.23.1`
  Acceptance: Include the director's string -> regex split -> array<string> -> array methods -> selected string -> string methods journey, plus supported conversion/collection/callback results that return another family. Specify regex/Unicode/empty/no-match behavior, indexing or extraction, dynamic returned types, side effects and wrong-type rejection. A continuation must use the current returned value; do not retain the chain's original receiver family or silently stringify it.
  Planned tier: Select from actual contract scope; freeze new public authority before code.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.2.1`
  Status: `done`
  Goal: Freeze the bounded ordinary first/last selected-value continuation contract before code, using existing helper semantics and the director's exact inter-type journey.
  Dependencies: `TYPE-REFERENCE-BOOK.1.2.1.2.1`
  Verification tier: `focused`
  Focused checks: Canonical existing first/last/string/numeric/container signatures and public Get/substitution distinction; book build and fast continuity/history checks only. No runtime census.
  Canonical trigger: None for planning/freeze of this bounded feature under director feature-first phase; portable/public implementation admission remains with23.4 after feature coverage.
  Claim verification: none: Normative selected-value contract and qualitative observed Perl gap, no implementation/parity/completeness measurement.
  Acceptance: Specify selection result kinds, source/argument evaluation, inherited wrong-kind/null/empty/copy behavior and pure continuation limits. Schedule bounded per-backend implementation children. Preserve full matrix/admission as open, with no new type or unsupported mutation/callback promise.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.2.1 - define selected-value receiver continuations`.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree TYPE-REFERENCE-BOOK --id TYPE-REFERENCE-BOOK.1.2.23.2.1`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.2.2`
  Status: `done`
  Goal: Probe and freeze bounded count/count_keys/length numeric-result receiver continuations before implementation.
  Verification tier: `focused`
  Focused checks: Public Perl Get/substitution distinctions for array/string/hash counts, existing helper and selected-value authorities, book build and fast continuity/history/diff guards. No runtime census.
  Canonical trigger: None for freezing this bounded feature under director feature-first direction, following23.2.1; implementation/portable admission stays with23.3.3/23.4 after feature coverage.
  Claim verification: none: Normative count/length contract and qualitative observed Perl gap, no implementation/parity/completeness measurement.
  Acceptance: Define count/count_keys/length results feeding existing compatible pure scalar/number methods, actual value identity, once-only source/argument evaluation and inherited null/domain/error rules. Explicitly reconcile the earlier count-terminal control as prior bounded policy. Add implementation children only after the contract/probe, commit per backend and retain comprehensive signatures/matrix, numeric reducer/boolean/control/mutation/callback scope separately.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.2.2 - define count and length result continuations`.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree TYPE-REFERENCE-BOOK --id TYPE-REFERENCE-BOOK.1.2.23.2.2`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.2.3`
  Status: `done`
  Goal: Publicly assess and freeze bounded ordinary aggregate numeric reducer result continuations.
  Dependencies: .23.3.3.5.
  Verification tier: `focused`
  Focused checks: Existing six reducer/public helper contracts, public Perl Get/substitution distinguishing fluent/nested results, book build and fast continuity/history/diff guards; no runtime census or full replay.
  Canonical trigger: None for bounded normative freeze under director feature-first phase; implementation per backend and complete portable/public admission remain separate.
  Claim verification: none: Normative bounded result contract and qualitative public observations; no quantified corpus, completeness or portable admission measurement.
  Acceptance: Read existing six aggregate helper domains and callable boundaries, compare reducer-result fluent arithmetic/string methods with nested public Perl controls, and isolate any actual gap before choosing code. Preserve min/max array/scalar overloads, null/error/source rules, argument order, copy and deferred boundaries. Freeze only meaningful existing pure consumer transitions, supersede old terminal policy explicitly, then schedule per-backend implementation children. Keep broad signatures/matrices/admission separate.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.2.3 - define aggregate numeric result continuations`.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree TYPE-REFERENCE-BOOK --id TYPE-REFERENCE-BOOK.1.2.23.2.3`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.2.4`
  Status: `done`
  Goal: Publicly assess and freeze ordinary Array join_values result continuations into existing compatible String methods.
  Dependencies: .23.3.4.5.
  Verification tier: `focused`
  Focused checks: Existing join helper signatures/domains, public Perl Get/substitution fluent/nested and receiver snapshot/effect controls, book and fast continuity/history/diff guards; no runtime census or broad replay.
  Canonical trigger: None for bounded normative freeze under director feature-first phase; implementation per backend and complete public/portable admission remain separate.
  Claim verification: none: Normative bounded result contract and qualitative public observations; no quantified corpus, completeness or portable admission measurement.
  Acceptance: Read existing join_values delimiter-first free/receiver signatures, source/argument/effect/null/empty and domain rules. Compare ordinary joined-result chains with nested public Perl controls, including selected/pipeline/hash-view sources, before classifying a gap. Freeze only compatible existing pure result continuations and explicitly supersede old join-terminal policy; retain invalid-shape, copy/deferred and complete admission boundaries. Schedule per-backend implementation after concrete findings; no broad matrix/replay.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.2.4 - define joined String result continuations`.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree TYPE-REFERENCE-BOOK --id TYPE-REFERENCE-BOOK.1.2.23.2.4`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.2.5`
  Status: `completed`
  Goal: Assess container-valued default selections continuing through the actual returned kind.
  Dependencies: .23.3.5.5.
  Verification tier: `focused`
  Focused checks: Small public Get/substitution/native/fresh assessment of documented nonempty defaults and selected Array/Hash compatibility; preserve scalar/empty/null/lazy/effect controls, syntax, book and fast continuity/history/diff checks. No full suites or cross-backend campaign.
  Canonical trigger: None for bounded diagnostic/frozen transition under director feature-first cadence; complete public/domain/portable admission remains23.4 and final clean push.
  Claim verification: none: deterministic authored diagnostic value/order examples; no quantified corpus, support/completeness or portable measurement.
  Acceptance: Establish public actual behavior and domains before classification, retain laziness/once-only effects/copy/kinds, freeze a bounded transition if needed and schedule backend repairs. Preserve current joined-result scope and complete admission as separate.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.2.5 - freeze selected default result flow`.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree TYPE-REFERENCE-BOOK --id TYPE-REFERENCE-BOOK.1.2.23.2.5`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.2.6`
  Status: `completed`
  Goal: Assess ordinary index_of integer/null results continuing through compatible scalar/numeric methods.
  Dependencies: .23.3.6.5.
  Verification tier: `focused`
  Focused checks: Small public Perl Get/substitution/native/fresh index-result and nested controls; producer snapshot/order, zero/no-match/null, scalar boundaries and malformed shapes. Probe syntax, book and fast continuity/history/diff guards; no full suite/cross-backend campaign.
  Canonical trigger: None for bounded diagnostic/frozen transition under director feature-first cadence; full public/domain/portable admission23.4 and final clean push remain separate.
  Claim verification: none: deterministic authored diagnostic values/order; no quantified corpus, support/completeness or portable measurement.
  Acceptance: Freeze a bounded actual-result transition if needed, preserve existing helper/needle/source/snapshot/once-only/arity/null policies, schedule backend repairs and commit. Full domain/portable admission remains23.4.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.2.6 - freeze index result continuations`.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree TYPE-REFERENCE-BOOK --id TYPE-REFERENCE-BOOK.1.2.23.2.6`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.2.7`
  Status: `completed`
  Goal: Assess ordinary has_key truth-value results continuing through existing compatible scalar/text methods.
  Dependencies: .23.3.7.5.
  Verification tier: `focused`
  Focused checks: Canonical hash/scalar-text/arity rules, small public Get/substitution/native/fresh has_key and nested/presence/snapshot/effect/shape controls; probe syntax, book and fast continuity/history/diff guards. No full suite or cross-backend campaign.
  Canonical trigger: None for bounded diagnostic/frozen transition under director feature-first cadence; full domain/portable admission23.4 and final clean push remain separate.
  Claim verification: none: deterministic authored diagnostic values/order; no quantified corpus, support/completeness or portable measurement.
  Acceptance: Establish public behavior/domains before classification, freeze bounded compatible result flow if needed and schedule repairs. Existing contains missing-needle calibration/helper normalization remains FUTURE-PARITY-BACKLOG.5; do not silently change it here. Full domain/portable admission remains23.4.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.2.7 - freeze has_key result continuations`.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree TYPE-REFERENCE-BOOK --id TYPE-REFERENCE-BOOK.1.2.23.2.7`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.2.8`
  Status: `completed`
  Goal: Assess ordinary is_empty/is_nonempty predicate results continuing through existing compatible scalar/text methods.
  Dependencies: .23.3.8.5.
  Acceptance: Establish public results before classification; freeze bounded compatible handoff/shape targets and schedule independent backend children if needed. Existing contains missing-needle calibration remains FUTURE-PARITY-BACKLOG.5. Full domains/comprehensive/portable admission remains23.4.
  Verification tier: `focused`
  Focused checks: Canonical emptiness/scalar-text/arity rules and existing producer defect owners16.1/.16.2; small public Get/substitution/native/fresh fluent/nested, domain/presence/effect/shape controls; syntax/book/fast continuity/history/diff guards.
  Canonical trigger: None for bounded diagnostic/freeze under director feature-first cadence; full domain/portable admission23.4 and final clean push separate.
  Claim verification: none: deterministic authored diagnostic values/order, no quantified population or portable measurement.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.2.8 - freeze emptiness result continuations`.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree TYPE-REFERENCE-BOOK --id TYPE-REFERENCE-BOOK.1.2.23.2.8`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.2.9`
  Status: `completed`
  Goal: Assess ordinary String predicate results continuing through existing compatible scalar/text methods.
  Dependencies: .23.3.9.5.
  Acceptance: Establish actual availability/value/kind/shape behavior before classification; freeze bounded compatible handoff/backend children if needed. Exact String comparison receiver additions require separate inventory/contract work; contains missing-needle calibration remains FUTURE-PARITY-BACKLOG.5. Full domain/fluent/portable admission stays23.4.
  Verification tier: `focused`
  Focused checks: Canonical String/regex/scalar-text/arity rules and existing Rust61.2 boundary record; small public Get/substitution/native/fresh fluent/nested, false/null/empty, source/order/snapshot and shape probes; syntax/book/fast continuity/history/diff guards.
  Canonical trigger: None for bounded diagnostic/freeze under director feature-first cadence; complete regex/domain/portable admission23.4 and final clean push separate.
  Claim verification: none: deterministic authored diagnostic values/order, no quantified population or portable measurement.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.2.9 - freeze String predicate result handoff`.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree TYPE-REFERENCE-BOOK --id TYPE-REFERENCE-BOOK.1.2.23.2.9`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.2.10`
  Status: `completed`
  Goal: Assess/freeze ordinary is_defined/is_undefined results and compatible continuations across actual supported value kinds.
  Dependencies: .23.3.10.6 committed cleanly.
  Acceptance: Public Perl native/fresh producers and fluent/nested distinctions with exact source/effect mechanism before classifying gaps; freeze bounded contract/fixture and schedule independent backend implementation/confirmation children. Small checks/docs/commit, no broad matrix.
  Verification tier: `focused`
  Focused checks: Read generic inventory/catalog and canonical returned-definedness observation; public Get/substitution plus independent fresh emitted producer/fluent/nested/source/effect controls, probe syntax/book/history/diff and final staged memory/cadence/diagnosis.
  Canonical trigger: None for bounded normative/result assessment under director feature-first cadence; independent backend implementation and complete public/domain/portable admission23.4/final push separate.
  Claim verification: none: deterministic authored diagnostic values/order and bounded normative transition, no quantified population or portable completeness measurement.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.2.10 - freeze generic definedness receiver results`.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree TYPE-REFERENCE-BOOK --id TYPE-REFERENCE-BOOK.1.2.23.2.10`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.2.11`
  Status: `completed`
  Goal: Assess/freeze receiver/result counterparts for existing str_eq/str_ne/str_gt/str_ge/str_lt/str_le helpers.
  Dependencies: .23.3.11.5 committed cleanly.
  Acceptance: Retained public Get/substitution/native/fresh distinctions and exact mechanism before classification; freeze bounded contract and ordinary one-operand/no-effect malformed policy; schedule independent backend implementation/confirmation children. Small focused checks/docs/commit, no broad suite/full admission.
  Verification tier: `focused`
  Focused checks: Canonical bridge/catalog and public Perl Get/substitution plus independent fresh producer/fluent/nested/null/empty/order controls, probe syntax/book/history/diff and final staged continuity guards. No broad suite.
  Canonical trigger: None for bounded normative assessment under director feature-first cadence; independent backend implementation/full domain/portable admission23.4 and final push separate.
  Claim verification: none: deterministic authored diagnostic values/order and bounded normative transition, no quantified population or portable completeness measurement.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.2.11 - freeze explicit String comparison receivers`.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree TYPE-REFERENCE-BOOK --id TYPE-REFERENCE-BOOK.1.2.23.2.11`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.2.12`
  Status: `completed`
  Goal: Assess remaining Dart action literal x/go/unknown suffix and invalid-pattern behavior against the documented matches/regex contracts.
  Dependencies: .23.3.12.5 committed cleanly.
  Acceptance: Reconcile every stated exclusion with a bounded observed result/owner and implement missing documented features or correct unsupported-domain claims before admission. No public regex type, submodule internals, full suite or unmeasured failure classification.
  Planned verification tier: focused; declare exact proof/no-measurement rationale at activation.
  Verification tier: `focused`
  Focused checks: Public authored distinguishing literal x/go/unknown/invalid and split/filter/effect controls native/restored/plan, existing String predicate fixture, selected-file fatal analysis/formatting, book/history/diff/final staged continuity guards.
  Canonical trigger: None for bounded existing documented ordinary feature repair under director feature-first cadence; full regex/context/portable admission and final clean push separate.
  Claim verification: none: deterministic authored regression decisions, no dialect population/completeness measurement.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.2.12 - preserve Dart extended regex modes and helper failures`.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree TYPE-REFERENCE-BOOK --id TYPE-REFERENCE-BOOK.1.2.23.2.12`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.2.13`
  Status: `completed`
  Goal: Assess ordinary Array contains result handoff and compatible scalar/generic/explicit-container consumers.
  Dependencies: .23.2.12 and immediate grouped-invalid operand repair23.3.10.7 committed cleanly.
  Acceptance: Retained public native/generated producer/fluent/nested/source/effect distinctions; freeze only observed-authorized ordinary result/shape transition and schedule independent backend children. Small compile/direct checks/docs/commit, full domain/portable admission separate. No current consumer failure or uniform terminal behavior claimed before assessment.
  Planned verification tier: focused; declare proof/no-measurement rationale at activation.
  Verification tier: `focused`
  Focused checks: Retained public LinkedSpec::Get/substitution/dump_parser_source/native/fresh controls and canonical membership/signature/arity owners, small syntax/doc/book/history/final staged continuity checks.
  Canonical trigger: None for bounded assessment/freeze under director feature-first phase; complete domains/context/portable admission23.4 separate.
  Claim verification: none: normative bounded contract and authored public distinction, no quantified population/completeness measurement.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.2.13 - freeze Array contains result transitions`.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree TYPE-REFERENCE-BOOK --id TYPE-REFERENCE-BOOK.1.2.23.2.13`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.2.14`
  Status: `completed`
  Goal: Reconcile membership null/empty equality and aggregate-consuming source snapshots with the Perl reference and typed value contracts.
  Dependencies: Bounded contains rollout23.3.13.1-.5 committed; coordinate FUTURE-PARITY-BACKLOG.5 caveat authority.
  Acceptance: Resolve accepted scalar/null/equality authority before normalization; independently compare actual membership/index selection and remaining array/hash consumer source/operand effects. Fix confirmed bounded first-party defects with small producer/direct checks and explicit original-owner coordination, preserve unrelated source kinds/equality/copy/arity and published caveats. No broad census or portable admission from samples.
  Planned verification tier: focused; declare exact metadata at activation.
  Verification tier: `focused`
  Focused checks: Retained public Perl Get/native/fresh and Rust Engine producer probes, canonical typed values/membership/selection/source snapshot contracts, source syntax/book/history/diff/final staged continuity guards. No corpus/full verification.
  Canonical trigger: None for bounded assessment under director feature-first cadence; complete portable/context/domain admission23.4 separate.
  Claim verification: none: deterministic authored distinctions and bounded contract reconciliation, no population/completeness measurement.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.2.14 - freeze aggregate operand and null-key repairs`.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree TYPE-REFERENCE-BOOK --id TYPE-REFERENCE-BOOK.1.2.23.2.14`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.2.15`
  Status: `completed`
  Goal: Assess ordinary numeric comparison receiver results and compatible inter-type continuations.
  Dependencies: Six bounded aggregate/null repairs23.3.14.1-.6 committed.
  Acceptance: Publicly compare raw/free/nested/current fluent producers, Number/Bool/null kinds, true/false/default/numeric/String/Array bridges, literal/named/selected/pipeline/function/default sources, source/operand/consumer order and malformed receiver shapes. Preserve current numeric domains and free signatures; do not conflate numeric and lexical comparisons or invent strict Bool equality. Freeze only observed-authorized ordinary result transition and schedule independent backend implementation children before code. Small syntax/direct checks/docs/commit; full domain/context/portable admission separate.
  Planned verification tier: focused
  Planned focused checks: Retained public Get/substitution/dump/native/fresh and canonical numeric owners, bounded direct current consumers; no exhaustive matrix/full suite.
  Planned canonical trigger: Full admission/final clean push separate under director feature-first cadence.
  Planned claim verification: none: bounded normative contract and deterministic authored distinctions; no population/completeness measurement.
  Verification tier: `focused`
  Focused checks: Public Perl Get/substitution/dump/native/fresh probe and canonical numeric contract/receiver owners; syntax/direct current comparison checks, book/history/staged continuity guards.
  Canonical trigger: None for bounded contract selection under director feature-first cadence; complete domain/context/portable admission and clean push separate.
  Claim verification: none: normative bounded transition and deterministic authored distinctions, no population/completeness measurement.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.2.15 - freeze numeric comparison result continuations`.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree TYPE-REFERENCE-BOOK --id TYPE-REFERENCE-BOOK.1.2.23.2.15`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.2.16`
  Status: `completed`
  Goal: Assess compatible scalar/text/generic/inter-type continuations of ordinary scalar numeric arithmetic results.
  Dependencies: Numeric comparison result implementations23.3.15.1-.5 committed.
  Acceptance: Independently compare raw/free/nested/current fluent results and actual Number/null kinds, zero/negative/decimal/invalid inputs, source families and source/operand/consumer effects. Assess numeric->text->split Array->selected String, explicit defaults/generic/scalar boundaries and shape controls; preserve numeric domain/free signatures and existing scalar/Array min/max overload selection. No general strict equality, Array reducer repair or unsupported canonical method-name expansion. Freeze only observed-authorized result transitions and schedule bounded backend children before production; small syntax/direct checks/docs/commit, full admission separate.
  Planned verification tier: focused
  Planned focused checks: Retained public Get/substitution/dump/native/fresh distinctions and existing arithmetic/overload owners; no exhaustive matrix or full suite.
  Planned canonical trigger: Complete admission/final clean push separate under director feature-first cadence.
  Planned claim verification: none: bounded normative transition and deterministic authored distinctions, no population/completeness measurement.
  Verification tier: `focused`
  Focused checks: Public Get/substitution/dump/native/fresh arithmetic/overload distinctions, canonical numeric contracts, small syntax/direct checks and book/history/staged continuity guards.
  Canonical trigger: None for bounded contract selection under director feature-first cadence; complete domain/context/portable admission and clean push separate.
  Claim verification: none: bounded normative transition and deterministic authored distinctions, no population/completeness measurement.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.2.16 - freeze scalar arithmetic result continuations`.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree TYPE-REFERENCE-BOOK --id TYPE-REFERENCE-BOOK.1.2.23.2.16`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.2.17`
  Status: `completed`
  Goal: Assess ordinary logical-helper Boolean result continuations from the helper spelling/role spine and existing logical-helper-v1 authority.
  Dependencies: Bounded scalar arithmetic23.3.16.1-.5 committed.
  Acceptance: Use small public producer/nested/fluent native/fresh distinctions for all three logical helper results, valid eager effects/snapshots, false/default/generic/numeric/text/explicit-container boundaries and selected Boolean sources. Preserve existing errors, free signatures, lazy-control contrast, callbacks and admitted behavior. Freeze only needed compatible actual-value transitions and schedule bounded backend children after concrete observations; no full matrix/replay or new truthiness policy.
  Planned verification tier: focused
  Planned focused checks: Existing canonical fact/neutral contract and public producer/nested/result distinctions, small syntax/direct logical checks, current book/task/live continuity.
  Planned canonical trigger: Full admission/final clean push separate under director feature-first cadence.
  Planned claim verification: none: normative bounded feature selection and deterministic authored distinctions, no population/completeness measurement.
  Verification tier: `focused`
  Focused checks: Public Get/substitution/dump/native/fresh authored distinctions and direct logical contract checks, syntax/book/history/staged continuity guards.
  Canonical trigger: None for bounded feature assessment; full domain/context/portable admission/final clean push separate.
  Claim verification: none: normative bounded selection and deterministic authored distinctions, no population/completeness measurement.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.2.17 - freeze logical Boolean result continuations`.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree TYPE-REFERENCE-BOOK --id TYPE-REFERENCE-BOOK.1.2.23.2.17`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.2.18`
  Status: `completed`
  Goal: Assess useful ordinary defined-only coalesce receiver surface and actual selected-result continuations from the helper spelling/role spine.
  Dependencies: Bounded logical result23.3.17.1-.5 and Perl rejection-effect follow-up committed.
  Acceptance: Public producer/nested/current receiver/source/arity/kind/effect distinctions before production. Preserve defined empty String/zero/false selections, null exhaustion, left-to-right lazy fallback selection, actual values/copies and skipped later errors. Establish existing scalar/Array/Hash domains, source-before-fallback/consumer snapshots and method arities without normalizing free helpers or broadening portable domains. Freeze only a bounded useful counterpart/result rule if warranted, then own backend children; small syntax/direct checks/docs/commit, no full matrix/replay.
  Planned verification tier: focused
  Planned focused checks: Canonical default facts/contracts and public Get/substitution/dump/native/fresh distinctions, small direct defaults/strict kinds and book/continuity checks.
  Planned canonical trigger: Full admission/final clean push separate under director feature-first cadence.
  Planned claim verification: none: normative bounded feature selection and deterministic authored distinctions, no population/completeness measurement.
  Verification tier: `focused`
  Focused checks: Public Get/substitution/dump/native/fresh distinctions and direct default contracts, syntax/book/history/staged continuity guards.
  Canonical trigger: None for bounded feature assessment under director feature-first cadence; full domain/context/portable admission separate.
  Claim verification: none: normative bounded feature selection and deterministic authored distinctions, no population/completeness measurement.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.2.18 - freeze defined-only default receivers`.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree TYPE-REFERENCE-BOOK --id TYPE-REFERENCE-BOOK.1.2.23.2.18`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.2.19`
  Status: `completed`
  Goal: Assess ordinary scalar String-helper result continuations and scalar boundaries from the helper spelling/role spine.
  Dependencies: Bounded defined-only default23.3.18.1-.5 committed.
  Acceptance: Read canonical String helper signatures/semantics and relevant current book before public producer/nested/fluent/source/arity/effect native/fresh distinctions. Preserve actual scalar/null results, including original Number/Boolean kinds on identity replacement/removal, empty/Unicode/conversion/domain/arity policies, source-first once-only operands/snapshots and compatible scalar/generic/explicit Array bridges. Assess incompatible container consumers and malformed shapes without changing free helpers, known source-context differences or callbacks. Freeze only concrete bounded gaps/needed flow and schedule independent backend children after observations; small checks/docs/commit, no full matrix/replay.
  Planned verification tier: focused
  Planned focused checks: Canonical String facts/contracts and small public producer/nested/receiver distinctions with direct String checks/syntax/book/continuity.
  Planned canonical trigger: Full admission/final clean push separate under director feature-first cadence.
  Planned claim verification: none: normative bounded feature selection and deterministic authored distinctions, no population/completeness measurement.
  Verification tier: `focused`
  Focused checks: Canonical String facts/contracts and public Get/substitution/dump/native/fresh distinctions, small direct String checks/syntax/book/history/staged continuity guards.
  Canonical trigger: None for bounded feature assessment under director feature-first cadence; full domain/context/portable admission separate.
  Claim verification: none: normative bounded feature selection and deterministic authored distinctions, no population/completeness measurement.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.2.19 - freeze scalar String-helper result flow`.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree TYPE-REFERENCE-BOOK --id TYPE-REFERENCE-BOOK.1.2.23.2.19`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.2.20`
  Status: `completed` / frozen existing-reference repair target
  Goal: Reconcile explicitly supplied null optional substring width and Boolean offset policies across supported backends without inferring domains from return-value samples.
  Dependencies: Scalar String implementation19.1-.5; signature/domain owners1.2.1.4 and SESSION-STARTUP-READING61.3 remain authoritative.
  Acceptance: Independently distinguish omitted width, explicit null width, null source/start, Boolean/integer/fractional offsets and existing scalar text carriers on native/generated routes. Reconcile primary records/contracts/book with explicit per-backend domain rows, then freeze needed changes and own implementation children. No full matrix or unsupported universal domain claim from a few examples; broad61.3 remains open until its own admission.
  Planned verification tier: focused
  Planned focused checks: Canonical domain records and small retained public argument distinctions, book/continuity.
  Planned canonical trigger: Any actual public input-domain contract movement requires its designated implementation/admission tier; final clean push remains separate.
  Planned claim verification: none: normative bounded policy assessment and deterministic authored distinctions, no population/completeness measurement.
  Verification tier: `focused`
  Focused checks: Canonical signature/domain/decision records and retained current native/generated distinguishing inputs, small new public checks only if a fact is missing, book/history/staged continuity guards.
  Canonical trigger: None for bounded assessment/qualification under director feature-first cadence; any actual public input-domain movement gets its own designated owner/tier, full admission/final push separate.
  Claim verification: none: normative bounded policy assessment and deterministic authored distinctions, no population/completeness measurement.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.2.20 - reconcile ordinary substring argument parity`.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree TYPE-REFERENCE-BOOK --id TYPE-REFERENCE-BOOK.1.2.23.2.20`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3`
  Status: `active` / bounded selected-value rollout; full gap matrix remains open
  Children: `TYPE-REFERENCE-BOOK.1.2.23.3.1`, `.23.3.2`, `.23.3.3`, `.23.3.4`, `.23.3.5`, `.23.3.6`, `.23.3.7`, `.23.3.8`, `.23.3.9`, `.23.3.10`, `.23.3.11`, `.23.3.12`, `.23.3.13`, `.23.3.14`, `.23.3.15`, `.23.3.16`, `.23.3.17`, `.23.3.18`, `.23.3.19`, `.23.3.20`, `.23.3.21`, `.23.3.22`, `.23.3.23`, `.23.3.24`, `.23.3.25`, `.23.3.26`, `.23.3.27`, `.23.3.28.1`, `.23.3.29.1`, `.23.3.29.2`, `.23.3.30`, `.23.3.31`, `.23.3.32`, `.23.3.33`, `.23.3.34`, `.23.3.35`, `.23.3.36`, `.23.3.37`, `.23.3.38`, `.23.3.39`, `.23.3.44`, `.23.3.45`, `.23.3.46`, `.23.3.47`, `.23.3.49`, `.23.3.48`, `.23.3.40`, `.23.3.41`, `.23.3.42`, `.23.3.43`, `.23.3.50`, `.23.3.51`, `.23.3.52`, `.23.3.53`, `.23.3.54`, `.23.3.55`, `.23.3.56`, `.23.3.57`, `.23.3.58`, `.23.3.59`, `.23.3.60`, `.23.3.61`, `.23.3.62`, `.23.3.63`, `.23.3.64`, `.23.3.65`, `.23.3.66`, `.23.3.67`, `.23.3.68`, `.23.3.69`, `.23.3.70`, `.23.3.71`, `.23.3.72`, `.23.3.73`, `.23.3.74`, `.23.3.75`, `.23.3.76`, `.23.3.77`, `.23.3.78`, `.23.3.79`, `.23.3.80`
  Goal: Resolve every verified method-family and type-transition gap through bounded implementation leaves.
  Dependencies: `TYPE-REFERENCE-BOOK.1.2.23.2`
  Acceptance: Before activation create per-operation/family and backend children from the gap matrix. Each owns its contract, native/generated implementation, independent RED/GREEN and source inverses, compatibility, current book examples and separate commit. Existing defect owners remain authoritative. Generic, boolean/null and codeblock operations must follow their real semantics, including dispatch on a callable's yielded value rather than a fabricated codeblock method table.
  Planned tier: Select for each bounded child; public contract/admission changes require canonical proof.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.4`
  Status: `pending`
  Children: `TYPE-REFERENCE-BOOK.1.2.23.4.1`, `TYPE-REFERENCE-BOOK.1.2.23.4.2`, `TYPE-REFERENCE-BOOK.1.2.23.4.3`, `TYPE-REFERENCE-BOOK.1.2.23.4.4`, `TYPE-REFERENCE-BOOK.1.2.23.4.5`, `TYPE-REFERENCE-BOOK.1.2.23.4.6`, `TYPE-REFERENCE-BOOK.1.2.23.4.7`, `TYPE-REFERENCE-BOOK.1.2.23.4.8`, `TYPE-REFERENCE-BOOK.1.2.23.4.9`, `TYPE-REFERENCE-BOOK.1.2.23.4.10`, `TYPE-REFERENCE-BOOK.1.2.23.4.11`, `TYPE-REFERENCE-BOOK.1.2.23.4.12`, `TYPE-REFERENCE-BOOK.1.2.23.4.13`, `TYPE-REFERENCE-BOOK.1.2.23.4.14`, `TYPE-REFERENCE-BOOK.1.2.23.4.15`, `TYPE-REFERENCE-BOOK.1.2.23.4.16`, `TYPE-REFERENCE-BOOK.1.2.23.4.17`, `TYPE-REFERENCE-BOOK.1.2.23.4.18`, `TYPE-REFERENCE-BOOK.1.2.23.4.19`, `TYPE-REFERENCE-BOOK.1.2.23.4.20`, `TYPE-REFERENCE-BOOK.1.2.23.4.21`, `TYPE-REFERENCE-BOOK.1.2.23.4.22`, `TYPE-REFERENCE-BOOK.1.2.23.4.23`, `TYPE-REFERENCE-BOOK.1.2.23.4.24`, `TYPE-REFERENCE-BOOK.1.2.23.4.25`, `TYPE-REFERENCE-BOOK.1.2.23.4.26`, `TYPE-REFERENCE-BOOK.1.2.23.4.27`, `TYPE-REFERENCE-BOOK.1.2.23.4.28`, `TYPE-REFERENCE-BOOK.1.2.23.4.29`, `TYPE-REFERENCE-BOOK.1.2.23.4.30`, `TYPE-REFERENCE-BOOK.1.2.23.4.31`, `TYPE-REFERENCE-BOOK.1.2.23.4.32`, `TYPE-REFERENCE-BOOK.1.2.23.4.33`; remaining admission leaves split at activation.
  Count/length prerequisite: Bounded result rollout23.3.3 must land before complete fluent admission; the frozen contract is23.2.2 and bounded implementations23.3.3.1-.5 are targeted-checked; complete context/portable admission remains here.
  Known admission prerequisite: Rust scalar/default and bounded copy-arity implementations are targeted-checked; broad61.3/62.3/.62.4/copy23.3.2.5 remain open. Selected/count result implementations do not establish complete scalar families. Lua declared5.4 runtime/header proof remains LUA-STARTUP-READING.2.2.
  Goal: Independently admit complete fluent families and inter-type chains for the selected scope.
  Dependencies: `TYPE-REFERENCE-BOOK.1.2.23.3`
  Acceptance: Reconcile expected families and every transition in both directions against actual native/generated consumers and individual mdBook examples. Reject deliberate missing-method, wrong-return-type and continuation-dispatch faults; include empty/missing/error and backend controls. No family's final reference leaf .2-.6 or aggregate .7 closes over an unresolved assigned fluent gap. Keep scope exclusions explicit; publish no completeness claim from samples alone.
  Planned tier: Canonical admission; declare exact source-bound claim records before execution.

  Required gate prerequisite: TYPE-REFERENCE-BOOK.1.2.23.4.1 registers retained new Perl feature fixtures before this admission and any final push. Focused direct checks do not imply canonical selection.
  Artifact admission note: Rust23.3.10.2 restores action regex suffix modes in new compiled patterns. Rebuild current production derived artifacts from tracked source before promotion; previously stored nodes cannot infer discarded suffix information. Preserve immutable historical proof artifacts and their original results under their existing owners.

  Mandatory admission prerequisites: Resolve document-pressure/freshness intake1.2.20.1 and invalid-callback phase/diagnostic parity1.2.1.4.1, alongside explicit Perl registration23.4.1 and all existing backend/context prerequisites. Ordinary feature checks and known baseline gate failures do not constitute canonical admission.

  Admission prerequisite2026-10-27: TYPE-REFERENCE-BOOK.1.2.23.3.31.6.4.4 must reconcile deferred-helper readiness (coalesce recognized statically but unknown in the current CodeblockRuntime vocabulary) without inheriting eager receiver18's excluded Codeblock/deferred domain. Immediate identity/snapshot .4.1-.3 remain ahead of unrelated feature selection.

  Direct-fixture custody prerequisite:23.4.2 audits earlier capture consumers and repairs every demonstrated direct-input omission before admission; bounded67.6 closes only its specified named edges.

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

- ID: `TYPE-REFERENCE-BOOK.1.2.23.4.5`
  Status: `completed` / accepted only through normal hooks and exact staged canonical receipt for20.1.10
  Goal: Remove the all-tracked-path argv limit from the path-portability and storage-locality doctrine checks.
  Reproduction: Normal pre-commit during73.1 reports scripts/check_repo_root_path_portability.sh:14 and scripts/check_project_data_storage_locality.sh:13 /usr/bin/perl: Argument list too long. Both consume git ls-files -z into a Bash array and pass all filenames to one Perl launch. A minimal Perl command using the retained actual vector fails OSError errno7 (E2BIG); a single-path launch succeeds. This proves the process-launch defect without rerunning policy scans or changing their rules.
  Evidence: docs/checkpoints/type-operation-inventory/gate-argv-limit-intake.json.gz retains the actual NUL filename vector, checker/input bytes, diagnostic, RED/GREEN commands/results and environment qualification. No portable exact threshold or complete environment/census claim.
  Impact: Two mandatory integrity gates fail before their Perl checks execute, independently of the existing document-pressure failures. Feature behavior is unaffected by this diagnosis.
  Priority/schedule: P1 after ordinary feature coverage in the existing infrastructure window after pressure20.1, before full23.4 and any push. LinkedSpec owns repair through verified closure; no dirty-feature pivot or cap increase.
  Acceptance: Stream NUL-delimited tracked paths through stdin or a repository-local manifest while preserving exact pathname handling, tracked parent-repository scope and both existing policy scans. Add distinguishing small/large-list launch controls, inspect direct consumers, and complete canonical infrastructure proof before closing. Do not mistake a process launch failure for a policy scan result.
  Verification tier: `canonical`
  Focused checks: Existing path/storage self-controls plus retained large filename-vector launch RED/GREEN, safe input-path cases and directly affected doctrine checks.
  Canonical trigger: Infrastructure/checker changes require canonical proof after pressure prerequisites and before admission/push.
  Claim verification: none: Finite input-bound process-launch diagnosis and planned repair; no repaired gate, portable threshold or population-completeness claim.

  Activation: clean79301cb16 after committed Perl73.1/post-hook0/brief0. Director explicitly prioritized addressing both gate failures now. Preserve scan semantics, exact pathname transport, failure propagation and five primary anchors. Repair two process launches first; pressure20.1 remains a named normal-hook/canonical blocker until repaired. No dependency implementation access or cap increase.

  - [x] **REPRODUCE / ISSUE**: Original actual normal-hook launches fail E2BIG, retained in gate-argv-limit-intake.json.gz. Independent oversized Perl argv reproduces errno7 while the same one-file launch succeeds.
  - [x] **ROOT CAUSE (WHY + WHERE)**: Both shell checkers collect every git ls-files filename into an argv array. Process launch fails before policy code runs; two exact launch locations and original bytes retained. No policy-scan finding is inferred from launch failure.
  - [x] **FIX**: Git's exact NUL path stream now goes to Perl stdin; the unchanged Perl source uses descriptor3. pipefail preserves Git failures, incomplete NUL records reject, and no argv grows with checkout size. Classification, binary/symlink skips and primary anchors stay.
  - [x] **ADDRESSED (verified)**: Both actual current tracked-tree scans return0. Actual checker controls pass small/oversized paths, spaces/newline filename, binary and symbolic files, policy rejection, truncated NUL and Git exit23 propagation. The independent oversized argv control still fails E2BIG, distinguishing the repaired transport.
  - [x] **NO REGRESSION**: Existing14 portability/28 storage classifier controls and five primary anchors pass within the real scans. Script syntax passes. Canonical CI registers the new actual-checker control; complete canonical proof remains blocked by independent pressure20.1, not claimed.
  - [x] **LOCKSTEP**: Book/Toolbox/fact/map/task/live/roadmap/history/resume reflect process repair and the explicit remaining pressure/canonical boundary. The original diagnosis remains immutable; new producer/inputs/raw outputs are retained in gate-path-streaming-intake.json.gz. Parent remains implemented until canonical verification closes it.
  Result: The E2BIG mechanism is repaired and both actual policy checks execute successfully. This is not normal-hook restoration: pressure20.1 and full canonical proof still remain. Director now prioritizes pressure20.1 immediately after committing this bounded process repair, before Rust73.2. Do not resume runtime feature work until normal hooks are restored. No broad claim-registry result or canonical receipt is claimed from focused checks.
  Verification: bash scripts/check_repo_root_path_portability.sh; bash scripts/check_project_data_storage_locality.sh; bash tools/run_python_project_data.sh tools/test_doctrine_path_streaming.py --evidence .linkedspec-data/gate-path-streaming/controls.json; Bash syntax/book/map/history/memory/diagnosis/diff. Canonical verification explicitly pending pressure20.1; node not closed.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.4.5 - stream tracked paths into doctrine checkers`.
  Integrated acceptance: Implementation and distinct component preservation/negative controls are retained under `docs/checkpoints/document-pressure-restoration/`; normal hooks require canonical receipt for the exact candidate before this checkpoint can land. No hook bypass or portable performance/completeness inference.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.4.4`
  Status: `pending` / P2 owned backend-guide drift repair before admission
  Goal: Reconcile stale Lua guide continuation descriptions with current canonical method contracts.
  Reproduction: `rg -n -F -e 'matches is terminal' -e 'terminal in a' -e 'Downstream array receiver methods' lua/README.md` exposes legacy terminal-matches and pending split-to-Array wording. Current bounded String-predicate70/Array-family outcomes and the helper-contract catalog already describe compatible continuations. A targeted read during71.6.5 established these two documentary contradictions; no exhaustive guide-drift census is claimed.
  Impact: Backend guide readers can mistake implemented ordinary continuations for unsupported work. Canonical book remains the current authority; no new runtime defect is inferred.
  Priority/schedule: P2 after ordinary feature coverage, before full23.4 admission/final push. LinkedSpec owns correction through verified closure; preserve declared-host/context qualifications and immutable historical evidence.
  Acceptance: Read current guide passages and relevant canonical70/split/Array facts, correct the two named descriptions and any directly dependent examples, and check for contradictory wording on those same surfaces. Use existing focused proof or a minimal distinguishing public example if facts have changed. Keep the book and backend guide aligned without inferring complete family/context admission from these controls.
  Planned verification tier: focused
  Planned focused checks: Targeted guide/catalog/fact reconciliation, minimum public example only if required, documentation/continuity checks.
  Planned canonical trigger: Complete guide/context/portable admission remains23.4 and final clean push.
  Planned claim verification: none: Two observed documentary contradictions, no exhaustive population measurement.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.4.3`
  Status: `done` / backend/shared-fixture gate extension; exact canonical receipt required for landing
  Goal: Extend the documented TASK-ACCEPTANCE path scope to owned Dart/Julia/Lua code/tests and shared fixtures before admission/push.
  Trigger: Dart70.3 stages interpreter/test changes but scripts/check_diagnosis_evidence.sh exits0 with the no-governed-changes message. Its explicit case list and canonical task-acceptance-evidence-gate-boundary card cover Perl/Rust but omit Dart/Julia/Lua/tests. This is an existing documented enforcement limitation; the current Dart feature checklist is manually reviewed, not mechanically enforced by that no-op.
  Evidence: docs/checkpoints/type-operation-inventory/task-acceptance-backend-scope-intake.json.gz retains the actual unchanged staged Dart candidate, gate source/instrument/dependencies and fresh stdout/stderr/exit0. No exhaustive omitted-path census or runtime feature failure is claimed.
  Priority/schedule: P1 after ordinary feature coverage, in the existing infrastructure/admission-prerequisite window after document-pressure20.1, before full23.4 and any push. Own through verified closure; do not pivot dirty feature work into a doctrine rewrite. Director repeatedly requests the earliest safe push; therefore this existing before-any-push prerequisite is the next clean activation immediately after integrated restoration20.1.10, ahead of Rust Count73.2. Latest push authorization does not waive this explicit repository requirement.
  Acceptance: Inventory the actual owned backend/shared-fixture paths and policy/registry consumers, preserving read-only dependency boundaries. Update the gate and canonical scope documentation together. Exercise real gate calls with isolated project-local alternate indexes: missing task evidence must reject each newly governed backend code/test/shared-fixture path, complete evidence must pass, existing Perl/Rust behavior and documentation-only no-op controls must remain. Retain distinguishing pre-repair negatives and repaired positives, actual producer/input identities and exact staged canonical proof; do not infer broader evidence truth or historical completeness from this shape gate.
  Verification tier: `canonical`
  Focused checks: Shell syntax; actual legacy/new-contract RED/repaired70 gate controls; bounded historical/live-count/prerequisite replay; four current storage population controls; complete restoration reader; synthetic temporary-publication protocol controls; mandatory doctrine/history/memory/map and mdBook checks.
  Canonical trigger: Doctrine gate/CI infrastructure; exact staged tools/run_ci_local.sh receipt and normal hooks required before commit or push.
  Claim verification: `docs/claims/TYPE-REFERENCE-BOOK.1.2.23.4.3.json`
  Evidence/result: docs/checkpoints/task-acceptance-backend-scope/before.json and after.json retain actual producer/helper/gate bodies, tracked path populations and every stdout/stderr/exit. Eight new code/test/native/shared prefixes and nine prior directory prefixes each exercise missing/complete/incomplete/deletion evidence; root/docs prose controls stay no-ops. The new contract first fails on unchanged Dart missing-evidence exit0; repaired70 calls pass. Real index bytes are unchanged. Exact canonical success is represented by the receipt required at landing, not inferred from focused controls.
  Scope/consumers: scripts/check_diagnosis_evidence.sh remains an evidence-shape check, not a Markdown command executor. tools/run_ci_local.sh now requires/runs the same actual-index producer. Registry identity stays TASK-ACCEPTANCE; TOOLBOX, doctrine, canonical fact and book explain full directory scope, including backend guides/manifests. Root/docs-only prose and black-box dependencies retain their boundaries. Feature admission/fixture custody/canonical feature registration remain separately owned.
  Commit: TYPE-REFERENCE-BOOK.1.2.23.4.3 — enforce task evidence across owned backend paths

  Acceptance Checklist
  - [x] **REPRODUCE / ISSUE** — bash scripts/check_diagnosis_evidence.sh returns exit0/no governed changes for a real alternate-index Dart source delta with no task; retained new-contract RED rejects that behavior.
  - [x] **ROOT CAUSE (WHY + WHERE)** — scripts/check_diagnosis_evidence.sh is_governed_path explicitly omitted dart/julia/lua/tests; retained source and actual staged set show the mechanism.
  - [x] **FIX** — Add exactly those four directory prefixes and register the actual-index producer in canonical CI; evidence signatures and checklist semantics remain.
  - [x] **ADDRESSED (verified)** — 70 repaired actual gate calls pass with per-call exits/channels, including newly enforced missing/incomplete/deletion rejects and complete evidence passes.
  - [x] **NO REGRESSION** — Existing Perl/Rust/spec/test/tool/bin/hook/workflow and root/docs controls pass; bash syntax and git diff --check pass. Full canonical proof is the required exact receipt at landing.
  - [x] **LOCKSTEP** — Canonical scope card/map, TOOLBOX, doctrine, mdBook, task/roadmap, history/live/resume and source-bound claim agree; original baseline/manual-review history is retained.
  Predecessor evidence preservation: Two live restoration claims intersect TOOLBOX/runner edits. preserve_claim.py verifies all248 original input identities against committed cd3b6adc and every original claim field before changing only durability mode/revision to historical. claim-preservation.txt retains actual PASS. Both interrupted preparation attempts supply no canonical receipt; the complete corrected candidate is required.
  Canonical preparation: The newly added book subsection exceeds the unchanged chapter line cap. Reflow only its prose with exact token equality; retain original source/full failure log in book-cap-preparation.json.gz. No cap, content, runtime or historical observation changes. Complete corrected canonical CI remains required.
  Reached canonical blocker and repair: The accepted owner22 book-count reader still freezes the mutable book/reader bytes after its capture. Retain complete failed canonical output and actual indexed sources in restoration-boundary-before.json.gz. book_count.capture_read now validates the explicitly historical restoration record and reads its exact cd3b6adc source image; original five corruption controls remain. validate_live_count independently derives the maintained summary from the current manifest. Authored prose and a synthetic next-count pair pass; six live-count/revision denials reject. The current storage reader preserves its captured populations while replaying actual current census controls. Add tools/test_diagnosis_evidence.py to both exact Python inventories; all four storage populations/controls pass. Historical artifacts/results/hashes remain unchanged. Focused sources and actual current/historical bytes are retained in boundary-after.json.gz; no new CLI case is admitted.
  Publication steering: The director requests the earliest safe push. The conservative initial outgoing non-thin estimate is over the GitHub per-push limit; tracked push-plan.json and publish.py prepare smaller fast-forward ranges without rewriting history. Publish immediately after this exact canonical/normal-hook commit, before maintenance or another feature. The original inline-planning and full object-input disclosure gaps remain explicitly owned by23.4.7; no oversized server rejection is claimed.
  Additional fixed-snapshot dependencies: Direct execution proof reproduces TOOLBOX source drift, and changing that reader reproduces its Phase0 exact-reader freeze. Those historical reads now use the same accepted Git boundary; current early-execution block/order remains separately checked. The retained bounded replay binds136 historical images and observed current inputs, retains every original mutation control and rejects ten current count/revision/prerequisite variants. Complete restoration review returns PASS; source/failure/result logs remain immutable.
  Compressed transfer check: Raw objects total19032710823 bytes (about17.7 GiB); a thin pack against all advertised remote refs measures9304184386 bytes. The tracked publisher now uploads only to its own temporary branch in freshly bounded ranges, advances main once at the verified runtime HEAD and deletes its temporary ref with an expected-tip lease. Five synthetic protocol controls pass; no real publication or server rejection is claimed yet.
  Exact CI registration repair: The next actual canonical run reaches the historical recovery auditor and rejects the newly interposed runner block. ci-registration-before.json.gz retains the whole failure and indexed inputs. Reverse only this exact owner-bound three-script block before all older inverses; every original runner byte/hash remains required. Existing corruption controls remain and eleven new effective missing/duplicate/presence/disabled/substituted-command denials reject. Complete isolated recovery passes714 governance denials with200 actual input byte images and no original-log read/tracked-write escapes; capture_registration.py independently rechecks eleven new faults. ci-registration-after.json.gz retains the actual report, producers and all declared/observed artifact inputs. This is historical evidence integrity, not fresh runtime admission. Whole staged canonical proof is still mandatory at landing.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.4.2`
  Status: `pending` / P2 mandatory direct-fixture capture-closure audit before admission/push
  Goal: Audit and repair declared direct fixture-input closure in earlier feature intake captures using their actual retained selected consumers and producers.
  Addition74.6: The first Length/Count before/after archives omit new untracked tests/fixtures/length_count_source_ownership_cases.json. Actual replay KeyError, original producer/reviewer/manifest/raw phases remain in length-count-owner-perl-2026-11-06; qualified original/final runs explicitly include it before proof and preserve outcomes. Keep first-run scope qualified, never claim recovered original fixture custody; coordinate broader native/transitive first-run closure under the existing schedule.
  Trigger: Custody67.6 confirms an inherited fixture-glob/changed-nearest-selector mismatch in five named67 packets. Its bounded companion closes only the thirteen specified edges. Reused earlier templates require an explicit review; no additional omission population or runtime regression is inferred without tools.
  Count73.2 intake: Its focused host harness retains direct source/fixture inputs and actual native/fresh results but does not separately retain the standalone generated Cargo manifest/lock/module bodies from the first runs. Preserve that original scope qualification. Coordinate a complete new generation-input capture and broader dependency/toolchain closure with SESSION-STARTUP-READING.5 before full admission; do not present a later replay as recovered original inputs. Runtime guard implementation remains focused-checked; no global audit pivot during feature coverage.
  Priority/schedule: After ordinary feature coverage, with admission prerequisites and in coordination with SESSION-STARTUP-READING.5 claim/producer audit, before23.4 admission/final push. This owner remains accountable until any explicit transfer; no dirty-feature global audit pivot.
  Acceptance: Inventory actual selected direct consumers and literal/constructed fixture loaders for the earlier captures, beginning source-role families63–66 and expanding through their real dependencies. Compare against retained byte identities, not filename lists or summary receipts alone. Own and repair each demonstrated omission with immutable companions/historical recovery and explicit original-observation limits; re-run focused behavior only where missing freshness or changed evidence requires it. Use distinguishing missing-input/provenance controls, retain actual producers/all direct artifact inputs and verify retrieval. Preserve original captures/results/history, black-box dependency boundaries and existing backend policies. Coordinate broader transitive/toolchain/producer census with its canonical owner; do not claim it from a direct-input inventory. Close only after verified repair and designated canonical proof.
  Planned verification tier: canonical.
  Planned focused checks: Retained-consumer/direct-input audit, historical-source recovery, distinguishing byte/provenance negatives and affected focused suites with exact input identities; original packet/history preservation and claim/book/continuity checks.
  Planned canonical trigger: Admission prerequisite/declared capture-closure closeout before push; infrastructure changes split into explicit canonical leaves if needed.
  Planned claim verification: none: This node schedules review of a demonstrated template-reuse risk; no additional missing-input census, measured repair or current runtime failure is claimed.
  Addition78.6.1.0/P1 native timing claims: The retained Perl observer persists emit_generated_source before fresh eval, but persists parser_source_ref after Get returns; SpecEntry has already eval-compiled internal native handlers. The inherited handler_input/handler.pl artifact is a standalone dump, not that internal eval input. Current intake and selection-card overstatements are qualified before landing; source-bound native-dump-timing review0/three controls and original narratives are retained. Audit earlier reused Perl observers/prose after feature coverage and before admission/push with SESSION5; qualify every demonstrated overstatement, preserve original receipts, and establish prospective actual native-input custody where supported. No retroactive precompile receipt, exhaustive historical census or changed runtime verdict is inferred. This owner remains responsible through verified closeout.

  Addition75.6.3.1/P1 named source assets before admission: Dart's public default function loader reads specs/user_function_definition.spec. Initial callable3 intake/normal/direct snapshots omitted that direct input; immutable qualified companions now capture and explicitly supply it before SDK use, preserving all16 observations/module/parsed bodies and qualified normal16/direct29. Original partial epochs are not retroactively closed. The same check confirms Rust spec_parser.rs19-20 embeds that file with include_str!, while saved Rust75.6.2 declarations cover rust/ and fixtures but omit the compile-time grammar asset. Rust observations and saved declared-source identities remain actual; original embedded asset/warm native-producer provenance is not proved. This owner must inventory these named asset edges, retain a prospective grammar-before-build/producer-bound companion and coordinate actual native/cache provenance with SESSION-STARTUP-READING.5 before23.4/push. No whole-history omission census or runtime defect is inferred. Current Dart3.1 closes its prospective direct asset edge; broader historical/default and Rust embedded-build legs remain open.

  Added ownership30.1: The outgoing-pack operational claim has checked re-derivation/falsification but explicitly lacks full native/physical Git/cache/compressor/toolchain/OS and ignored raw-pack/index artifact custody. Own this named gap with SESSION-STARTUP-READING.5 under the existing P2 after-feature/admission/final-publication schedule. Start from the actual retained producer/config/ref/logical-object/native index/verify packets in docs/checkpoints/publication-size-monitor-2026-11-12/; retain the failed first validator and scoped limits. Do not infer complete native closure from stream/stat/hash or logical Git addresses, and do not replay old captures or inspect dependency implementations.

  Added ownership28: The selected Lua field proof retains its SDK/normal/oracle direct inputs, actual channels and opaque native bodies before the new loads. Its source-only initial case-preparation outer channels were not archived, and query-preparation-before-use.tar.gz is actually a late preparer source image. CUSTODY.md in docs/checkpoints/lua-raw-error-observation-2026-11-13/ owns those exact original-origin limits without retroactive first-use credit. Preserve the originals and include these named edges in this existing P2/SESSION5 origin audit before its admission/final-publication closeout; no broader native/source-resolution closure is inferred from the field observations.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.4.1`
  Status: `pending` / P1 canonical admission prerequisite
  Goal: Register new bounded feature regressions in canonical CI before full admission/final push.
  Addition80.1: Check exact canonical discovery for t/array_concat_open_arity_result_guard_composition.t and tests/fixtures/array_concat_open_arity_result_guard_perl_cases.json before23.4/push. The new504/direct1028 focused groups do not establish canonical selection. Preserve original-v1/qualified-v2 expectations,26 supported/four separate compatibility/474 preserved scope and native-dump timing qualification.
  Addition78.6.5: Check exact canonical discovery for lua/test/array_transform_callable_result_guard_composition_test.lua, callable_array_transform_observation.lua and array_transform_callable_result_guard_lua_cases.json/profiles.json on each installed ABI and separately declared5.4 before admission/push. One run.lua group and focused1872/direct3939 per host do not establish canonical selection. Preserve published-error/selected-outer scope and raw-field4.28 qualification.
  Addition78.6.4: Check actual canonical discovery for julia/test/array_transform_callable_result_guard_composition_test.jl, its callable_array_transform_observation.jl include and array_transform_callable_result_guard_julia_cases.json/profiles.json fixtures before23.4/push. One local runner include and focused1248/direct2927 do not establish canonical selection. Preserve independent full error/producer fences and new first-use inputs; older direct transient strings gain no custody credit.
  Addition78.6.3: Check actual canonical discovery for dart/test/array_transform_callable_result_guard_composition_test.dart, tests/fixtures/array_transform_callable_result_guard_dart_profiles.json, its docs/checkpoints/array-transform-callable-dart-2026-11-12/cases.json input and probe/observation/trace tools before23.4/push. Focused312/private/direct647 are separate from canonical discovery; preserve full error wires/own policies and new parsed-before-compile custody, without upgrading historical4.24.
  Addition78.6.2: Check actual canonical discovery for rust/linkedspec-runtime/tests/array_transform_callable_result_guard_composition.rs and its array_transform_callable_rust_cases.json/array_transform_callable_result_guard_rust_profiles.json fixtures before23.4/push. Own focused312/private/direct701 are separate from canonical discovery; preserve independent Rust policies and source-before-use evidence.
  Addition78.6.1.2: Register t/array_transform_callable_result_guard_composition.t and tests/fixtures/array_transform_callable_result_guard_perl_cases.json through exact canonical selection before23.4/push. Focused312 and direct212/188 prove the selected behavior, not canonical discovery; preserve the first/qualified data and three separately disclosed readiness movements.
  Addition74.3: Inventory Dart length_result_guard_composition_test/shared24 and length_result_guard_dart_domain.json against actual runner/canonical discovery; focused45 does not establish selection. Avoid duplicate entries where discovery already exists.
  Addition74.4: Inventory Julia length_result_guard_composition_test/shared24 and independent domain/error profiles against runner/canonical discovery; focused220 assertions and one runtests include do not establish canonical selection. Avoid duplicate entries.
  Addition74.5: Inventory Lua length_result_guard_composition_test/shared24 and independently frozen installed-host domain/error profiles against runner/canonical discovery; targeted122 per host and three runner lines do not establish canonical selection. Avoid duplicate entries.
  Addition75.0: Inventory frozen key_count_result_guard_cases shared22 and upcoming typed/domain/backend normals/profiles against actual canonical discovery after implementation; current assessment does not establish selection. Avoid duplicate entries.
  Addition75.0.1: Inventory t/key_count_block_source_composition.t and key_count_block_source_cases9 against canonical discovery; focused28 does not establish selection. Avoid duplicate entries.
  Addition74.2: Inventory Rust length_result_guard_composition/shared24 and length_result_guard_rust_domain.json against actual package/canonical discovery. Focused44 does not establish canonical coverage; classify existing automatic selection before adding any duplicate entry.
  Addition74.6: t/length_count_source_ownership.t/shared8 fixture require exact canonical presence/syntax/execution registration; focused8PASS/existing19PASS do not establish discovery.
  Addition74.1: t/length_result_guard_composition.t (shared16 plus three host-seed groups) and tests/fixtures/length_result_guard_cases.json require exact canonical presence/syntax/execution registration before admission/push. Current focused19PASS does not establish inclusion.
  Existing authority: docs/knowledge/perl-receiver-copy-canonical-selection.md states the runner uses exact explicit suites; future files require registration, with historical inverse/custody constraints.
  Reproduction: rg -n -F -e 't/string_predicate_result_receiver_contract.t' -e 't/emptiness_result_receiver_contract.t' -e 't/has_key_result_receiver_contract.t' tools/run_ci_local.sh returns no matches/exit1 after these fixtures are introduced. This confirms omission of these named direct selections; no complete omission population has been measured.
  Impact / ownership: Direct focused runs protect current feature commits, but merely retaining new t files does not add their execution to the final canonical receipt. This includes t/defined_default_receiver_contract.t, t/scalar_string_result_receiver_contract.t, t/reduction_result_receiver_contract.t, t/tagged_record_producer_contract.t, t/tagged_record_receiver_contract.t, t/logical_receiver_method_contract.t, t/computed_selection_noncall_contract.t, t/computed_selection_callable_compat.t and t/computed_selection_deferred_boundary.t; the approved primitive-copy producer/receiver add t/value_copy_function.t, t/value_copy_receiver.t and t/value_copy_interpreted.t; computed helper sources add t/computed_selection_helper_calls.t. Registered sources add t/computed_selection_functions.t; contextual grammar preservation adds t/computed_selection_contextual_boundary.t. Readonly capture composition adds t/capture_collection_selection.t. Inline condition producer repair adds t/inline_condition_value_blocks.t. Conditional bracket selection adds t/conditional_selection.t. Input/cursor reader composition adds t/input_cursor_result_continuations.t. Eager key/order repair adds t/set_key_block_operands.t. Static capture-name/function-fence repair adds t/named_capture_literal_names.t. Catalogued function-state fence adds t/user_function_parser_state_boundary.t. Noncatalogued parser-context fence adds t/user_function_parser_context_boundary.t. Number reader composition adds t/entry_match_number_result_continuations.t. Ordinary eager with Hash composition adds t/with_hash_result_continuations.t. Callback origin-label repair adds t/callback_identity.t. Callback snapshot repair adds t/with_callback_snapshot.t. Immediate with-result bracket composition adds t/with_result_selection.t. Anonymous capture Number composition adds t/capture_boundary_number_results.t; ordinary value-block reset adds t/capture_reset_value_block.t; readonly named-mark Number composition adds t/named_mark_number_results.t. Input-boundary mark value-block statements add t/input_mark_value_block_statements.t. Governed Number-reader name arguments add t/mark_name_number_arguments.t. Governed named writer statements add t/mark_name_write_arguments.t. Readonly named text/predicate names and unused calls add t/mark_name_text_arguments.t. Named advancing/bridge names add t/mark_name_advance_arguments.t. Reversed local-start named take guards add t/named_take_reversed_span.t. Sparse single-action AND classification adds t/sparse_and_single_action.t. Shared ordinary progress guard adds t/shared_rule_progress_guard.t. Standalone wiring adds t/emitted_rule_progress_guard.t. Repeated AND falsey group acceptance adds t/repeated_and_falsey_group.t and t/repeated_and_falsey_recognition.t. This owner must inventory all newly added feature fixtures/helpers, classify actual selection and repair every omission before admission/push; do not infer completeness from the three named controls.
  Schedule: Mandatory after feature coverage, before23.4 admission and before final clean push; no full-CI/policy detour during ordinary implementation.
  Acceptance: Inventory current feature fixtures and all producer/artifact inputs; add exact tracked-presence/syntax/execution selection through the published canonical runner/historical-inverse contract. Distinguish direct/indirect coverage; retain targeted selector RED/GREEN and actual full canonical receipt for exact staged candidate. Update runner docs/fact/card/current task records and commit as an infrastructure leaf before push.
  Planned verification tier: canonical; declare claim/inputs and focused selection at activation.

  Added ownership: t/computed_selection_helper_calls.t and t/computed_selection_functions.t require explicit canonical registration after the bounded computed-source rollout and before admission/push.

  Canonical fixture addition from33.1: Register t/capture_boundary_number_results.t alongside the other bounded Perl feature fixtures before full23.4/admission/push.

  Canonical fixture addition from45.3: Register t/pick_keys_operand_isolation.t and its retained fixture alongside direct capture/default consumers; current ordinary focused success does not establish canonical inclusion.

  Latest-child blind binding39.2.5.1 adds t/blind_child_retv.t; explicit canonical syntax/execution registration is required before admission/push, alongside all existing named bounded fixtures.

  Falsey blind iteration39.9.1 adds t/repeated_blind_falsey_group.t; explicit canonical syntax/execution registration is required before admission/push.

  Repeated blind parent publication39.9.2 adds t/repeated_blind_parent_acceptance.t; explicit canonical syntax/execution registration is required before admission/push.

  Lua intake39.4.0: tools/run_lua_local.sh also selects explicit files rather than automatically discovering new consumers. Register lua/test/sparse_and_structural_sequence_test.lua and subsequent bounded Lua feature consumers exactly once per installed ABI/declared host in ordinary and canonical owners before23.4 admission/push. Current direct focused102 assertions per host does not imply runner admission. No infrastructure change in the focused intake.

  Lua live progress39.4.6 adds lua/test/recognition_repetition_progress_test.lua to the required exact ordinary/canonical registration inventory; direct focused234 assertions per installed host does not imply discovery.

  Lua repeated-group39.4.2 adds lua/test/repeated_and_group_results_test.lua to the exact ordinary/canonical registration inventory before admission; direct390 assertions per installed host is not automatic discovery.

  Lua ordinary-minimum39.4.3 adds lua/test/minimum_miss_routes_test.lua to required explicit ordinary/canonical registration; direct289 assertions per installed host is not discovery/admission.

  Lua implicit-blind39.4.4 adds lua/test/blind_repetition_collection_test.lua to exact ordinary/canonical registration inventory. Current13active2owned dormant (Default .9/post-call .5) is direct focused proof only; remove satisfied dormancy before full admission.

  Lua Default-family39.4.9 adds lua/test/default_blind_generated_family_test.lua to required explicit ordinary/canonical registration. Current blind14active1post-call dormant/structural31fully active; direct304/230/205/234/222 assertions per installed host is not full admission.

  Lua post-call39.4.5.1 adds lua/test/blind_postcall_results_test.lua to required exact ordinary/canonical registration. All15 collection/all31 structural rows are active, no residual dormancy; direct274/240/289/390/234/205 per host is focused proof, not full admission.

  Lua nullable39.4.7.1 requires exact ordinary/canonical registration of lua/test/null_return_and_observation_test.lua. Its32qualified sources/52inputs pass506 per host; blind_LE one source/two inputs is explicitly excluded pending .5.2 and must be qualified/covered before full admission. Direct focused execution is not runner registration or canonical admission.

  Lua diagnostic39.4.8 requires exact ordinary/canonical registration of lua/test/runtime_unknown_helper_diagnostic_test.lua. Direct105 plus minimum289/callable449 per host is focused proof, not runner registration or full admission.

  Selected cursor38 adds dart/test/fixtures/gap_ls_broad_carrier.json as the original wildcard-carrier acceptance supplement. SDK/restored/plan current Dart/Julia proof is explicit; require actual separate-process Dart/Julia emitted replay of this supplemental1/1 before full admission/push. Existing core8-module fresh proof does not include it. Lua38.3 intake will include core plus broad from its RED epoch; exact new Lua normal registration remains required.

  Lua cursor38.3 requires exact ordinary/canonical registration of lua/test/gap_ls_selected_cursor_test.lua. It reads core+broad fixtures and passes118 assertions per installed host; direct nullable506/recognition246/gap controls6 are focused proof, not runner registration/full admission. Nine baseline modules per host include broad from RED and fresh; supplemental Dart/Julia broad emitted replay remains independently required.

  Perl boundary37 requires exact ordinary/canonical registration of t/emitted_boundary_catalog.t and its tests/fixtures/emitted_boundary_catalog.json input. Direct13-group native/arbitrary-package eval and separately retained13-source18-input fresh emitted proof do not imply canonical selection. Existing current nested boundary consumer remains; archival case/claim inputs are unchanged.

  Perl endpoint40.1 requires exact ordinary/canonical registration of t/capture_endpoint_absence.t and tests/fixtures/capture_endpoint_absence.json. Native/arbitrary-package eval16 groups and retained separate-process clean+seeded proof are focused coverage, not canonical selection. Existing typed-source4/Number7 controls stay selected; no blanket broader SESSION17 closure.

  Rust endpoint40.2 adds rust/linkedspec-runtime/tests/capture_endpoint_absence.rs over the frozen16-source fixture. Actual ordinary Cargo target discovery and three-route execution are verified; exact canonical presence/selection remains in this owner audit before admission/push. Temporary capture_endpoint_intake_probe.rs was snapshotted/removed and is not a normal consumer.

  Dart endpoint40.3 adds dart/test/capture_endpoint_absence_test.dart using the frozen16-source fixture. Ordinary target discovery/three SDK routes and retained separate-VM modules are verified; exact canonical presence/selection remains in this audit before admission/push. Adjacent named47 discovery has SDK-only proof and no normal/fresh completion credit.

  Julia endpoint40.4 adds julia/test/capture_endpoint_absence_test.jl and ordinary runtests registration using the frozen16-source fixture;112 normal assertions/three SDK routes and retained separate-process modules independently pass. Exact canonical selection remains required before admission/push, no peer/named completion inferred.

  Lua endpoint40.5 adds lua/test/capture_endpoint_absence_test.lua and ordinary run.lua registration.112 normal/three SDK routes plus retained separate-process modules pass independently on safe installed PUC5.5/LuaJIT; no declared5.4/unsafe formatter/full phase credit. Exact canonical selection remains required before admission/push.

  Native nested error41.1 adds t/nested_handler_error.t using frozen9-source/22-call fixture; ordinary discovery and selected30 groups/75 canonical nested assertions verified. Exact canonical selection remains required before admission/push, no full Phase0 or peer completion credit.

  Perl named endpoint47.1 adds t/named_capture_endpoint_absence.t using frozen15-source fixture; ordinary native/fresh target15 plus range11/Number3 groups verified, exact canonical presence/selection remains required before admission/push. Old emitted modules remain v2 accepted with original defects and require regeneration; no stale-artifact repair credit.

  Rust named endpoint47.2 adds rust/linkedspec-runtime/tests/named_capture_endpoint_absence.rs; ordinary Cargo discovery/three SDK routes and retained separately compiled emitted sources pass, exact canonical selection remains required before admission/push. Runtime relink consumes unchanged source, temporary probe removed; no writer49/peer/full admission credit.

  Dart47.3 adds dart/test/named_capture_endpoint_absence_test.dart using frozen15 target; ordinary discovery/current three SDK routes verified and separate VM reuses original15 emitted modules. Exact canonical presence/selection remains required before admission/push.

  Julia47.4 adds julia/test/named_capture_endpoint_absence_test.jl and explicit runtests include. Ordinary105 assertions and separate emitted current15 verified; exact canonical presence/selection remains before admission/push.

  Safe Lua47.5 adds lua/test/named_capture_endpoint_absence_test.lua and explicit run.lua registration; current15/four routes plus436 focused checks per installed host verified. Exact canonical presence/selection remains before admission/push; declared5.4 and unsafe formatter not covered.

  Perl49.1 adds t/named_writer_endpoint_absence.t using frozen15 target. Ordinary discovery/native+emitted15 groups and separate clean/seeded15-source proof verified; exact canonical presence/selection remains required before admission/push.

  Rust49.2 adds rust/linkedspec-runtime/tests/named_writer_endpoint_absence.rs with frozen15 current target. Ordinary Cargo discovery/three SDK routes and separate compiled original15 source proof verified; exact canonical presence/selection remains before admission/push. Temporary probe archived/removed.

  Dart49.3 adds dart/test/named_writer_endpoint_absence_test.dart with frozen15 writer target. Ordinary discovery/three SDK routes and original15 separate-VM modules verified; exact canonical presence/selection remains before admission/push.

  Julia49.4 adds julia/test/named_writer_endpoint_absence_test.jl with explicit runtests include. Ordinary105 assertions/current three SDK routes and separate emitted15-source proof verified; exact canonical presence/selection remains before admission/push.

  Safe Lua49.5 adds lua/test/named_writer_endpoint_absence_test.lua and explicit run.lua registration. Current15/four routes plus429 selected checks per installed host verified; exact canonical presence/selection remains before admission/push, no declared5.4/full suite credit.

  Perl48.1 adds t/referenced_blind_intermediate.t: focused12 groups cover8valid4reject and7native/fresh runtime controls. Exact canonical presence/selection remains required before admission/push.

  Rust48.2 adds referenced_blind_intermediate.rs compile-only regression; runtime closure48.2.3 remains open. Exact canonical selection must include final complete consumer before admission.

  Rust48.2.1 adds blind_fluent_return_values.rs consuming17 reference-qualified cases, with focused native/reconstructed/plan/fresh proof. Exact canonical presence/selection remains required before admission.

  Rust48.2.2 adds rule_invocation_accumulators.rs with3 qualified source fixtures, focused four-route proof and13 selected tests. Exact canonical selection required before admission; original parent-LX exclusions remain48.2.2.1.

  Rust48.2.3 adds referenced_blind_intermediate_qualified.rs and separate qualified12 target, four-route7-runtime proof and4 selected normals. Original compile consumer remains. Exact canonical selection must preserve original parent-LX authority exclusions.

  Rust48.2.4 adds blind_parent_push.rs with8 single-pass witnesses, four-route RED/GREEN and8 selected tests. Exact canonical selection must preserve repeated/Unicode/phase exclusions until their owners close.

  Rust48.2.5 adds blind_postcall_results.rs and5-source repeated composition in blind_parent_push.rs; main18/27 four-route proof/15 selected tests. Exact canonical selection must include both and preserve stated diagnostic/phase/cursor projection limits before admission.

  Perl48.2.6 adds t/unicode_rule_recognition_runtime.t (20 groups); exact canonical discovery must select it before admission. Static operand scanner48.2.6.1 remains separately owned immediately next.

  Perl48.2.6.1 adds t/unicode_recognition_operands.t (22 groups), with scanner/lowering/runtime closure and exact negative diagnostics; canonical discovery must include it before admission.

  Dart48.3 adds referenced_blind_intermediate_test.dart (16 checks); exact canonical selection must include it after48.3.1 removes the3 explicitly owned runtime exclusions.12 original compile sources, qualified runtime and4 strict negatives remain separate authority.

  Dart48.3.1 adds blind_parent_push_test.dart (13 shared PIPE/repeated controls); exact canonical selection must include it and referenced_blind_intermediate_test.dart after48.3.2 removes the3 remaining accumulator exclusions.

  Dart48.3.2 adds rule_invocation_accumulators_test.dart (3 Scope controls, implicit backend-qualified),92 selected checks.39.8.1, not completed Scope repair, owns3 referenced runtime exclusions. Candidate progress normal remains outside discovery; pure-code48.3.3 next. Canonical selection must preserve these qualifications.

  Dart48.3.3 adds pure_blind_targets_test.dart (15 cases incl3 bypass) and pure_blind_targets.json8. Exact canonical selection must include these and retain6 negative/immutable map/call-ref/entry-slot absence properties. Ordinary policy/source fixture candidates remain separately owned39.8.1.

  Julia48.4 adds referenced_blind_targets_test.jl with one runtests include,36 compiler roles plus strict bypass/real-empty and10 runtime controls (180 assertions). Qualified push3 excluded under48.4.1 with compile coverage; original parent-LX runtime unqualified48.2.2.1. Exact canonical selection must include this normal and completed runtime repair before admission.

  Julia48.4.1 adds blind_parent_push_test.jl with one runtests include,13 exact source controls104 assertions. Qualified coordinator3 runtime qualification moves to actual invocation-array owner48.4.2; original parent-LX remains unqualified. Exact canonical selection must include repaired normals before admission/push.

  Julia48.4.2 adds rule_invocation_accumulators_test.jl with one runtests include,3 original plus4 binding-scope controls56 assertions. Preserve explicit implicit-tail39.8.1 and undeclared-write48.4.2.1 qualifications; no portable credit until canonical authority/repair.

  Safe Lua48.5 adds referenced_blind_targets_test.lua with one run.lua registration,189 checks including36 source compiler roles/strict bypass/real empty/10 runtime controls. Both safe hosts809 selected assertions;3 coordinator runtime exclusions remain39.8.1 and original parent-LX unqualified48.2.2.1. Exact canonical selection before admission/push.

  Perl40.1.1 adds t/perl_match_local_declarations.t9 groups plus finite fixture. Exact canonical selection must include it and retain explicit OR warning40.1.1.1 ownership until repaired, with unsupported callback typed failure unchanged.

  Perl40.1.1.1 adds t/perl_or_match_local_declarations.t10 groups, closes prior AND normal OR warning allowance, and requires both normals in exact canonical selection. All new OR/AND generated loading checks now require0 warnings.

  Perl40.1.2 adds t/perl_blind_scalar_declarations.t24 source groups+1 context guard; exact canonical selection must cover nested scalar ownership/nonmutating diagnostic JSON and keep existing AND/OR declaration normals strict.

  New focused normal awaiting explicit canonical selection: `t/sorted_values_scalar_isolation.t` / `tests/fixtures/sorted_values_scalar_isolation.json`, producer repair45.11.1; native/fresh seeded scalar/Hash controls. Required before full23.4/push, alongside prior pick_keys normal.

  New focused normal from50.1: Register t/capture_boundary_text_results.t and shared fixture before full23.4/push; direct focused execution does not establish canonical inclusion.

  New focused normal from51.1: Register t/capture_advance_text_results.t/shared fixture before full23.4/push; focused execution alone is not canonical inclusion.

  New focused normal from52.1: Register t/capture_advance_number_results.t/shared fixture before full23.4/push; focused execution alone is not canonical inclusion.

  New focused normal from53.1: Register t/boundary_capture_fluent_results.t/shared fixture before full23.4/push; focused execution alone is not canonical inclusion.

  Queued normals from54: Explicitly register t/closed_named_selector_assignments.t, t/rule_call_result_selection.t and shared rule_call_selection_values fixture before full23.4/push; focused execution alone is not canonical inclusion.

  Queued normal from55: Explicitly register t/gap_slot_record_selection.t/shared fixture before full23.4/push; focused execution alone is not canonical inclusion.

  Queued normal56.0: Explicitly register t/cursor_statement_scope.t10 before full23.4/push; direct focused execution is not canonical inclusion.

  Queued normal56.1: Explicitly register t/cursor_rewind_result.t9/shared fixture before full23.4/push; focused execution alone is not canonical inclusion.

  Queued normal57.1: Explicitly register `t/gap_string_result.t` (15 groups) and its shared fixture before full23.4/push; focused execution is not canonical inclusion.

  Canonical fixture addition from58.0: Explicitly register t/push_payload_values.t (8 groups) for syntax/execution before23.4 admission/final push; direct focused execution is not canonical selection.

  Canonical fixture addition from58.1.1: Explicitly register t/push_result_selection.t (6 groups), push_result_selection_read_values.spec/.json and push_result_excluded_source_ast.json before23.4 admission/final push; full12 target remains separate.

  Canonical fixture addition from58.1.2: Explicitly register t/push_result_fluent.t (10 groups) and full push_result_selection_values.spec/.json before23.4 admission/final push; direct focused proof is not canonical selection.

  Canonical fixture addition from59.1: Explicitly register t/set_result_composition.t (11 groups), set_result_selection_values.spec/.json and set_result_excluded_source_ast.json before23.4 admission/final push; direct focused execution is not canonical registration.

  Added60.1 ownership: t/free_default_result_composition.t18/shared tests/fixtures/free_default_result_cases.json12/eight free_default_excluded_source_ast.json controls require explicit canonical registration before admission/push. Focused direct execution is not registration.

  Added61.0 ownership: t/perl_sort_scope.t11/shared tests/fixtures/perl_sort_scope_cases.json7 require explicit canonical selection before admission/push. Direct focused execution is not registration.

  Added61.1 ownership: t/constructor_result_composition.t25/shared constructor_result_cases.json15/eight public excluded AST-lowering controls retained in constructor-perl-intake.json.gz require explicit canonical registration before admission/push. Focused direct execution is not registration.

  Added62.1 ownership: t/free_string_result_composition.t18/t/free_string_source_fences.t9/shared free_string_result_cases.json16/free_string_excluded_source_ast.json9 require explicit canonical registration before admission/push. Direct focused execution is not registration.

  Added62.6.1 ownership: t/receiver_string_bridge_guards.t13/t/receiver_string_bridge_source_fences.t9/shared receiver_string_bridge_cases.json12/receiver_string_bridge_excluded_ast.json9 require explicit canonical registration before admission/push. Updated free String18 must assert admitted receiver readiness; historical unready qualifier retired with proof.

  Added63.1 ownership: t/free_numeric_result_composition.t17/t/free_numeric_source_fences.t14/shared free_numeric_result_cases.json17/free_numeric_excluded_source_ast.json14 require explicit canonical registration before admission/push. Focused execution is not canonical registration.

  Added64.1 ownership: t/free_numeric_comparison_result_composition.t19/t/free_numeric_comparison_source_fences.t14/shared free_numeric_comparison_result_cases.json19/free_numeric_comparison_excluded_source_ast.json14 require explicit canonical registration before admission/push. Focused execution is not canonical registration.

  Added65.1 ownership: t/logical_result_guard_composition.t22/t/logical_result_guard_source_fences.t16/shared logical_result_guard_cases.json22/logical_result_guard_excluded_ast.json16 require explicit canonical registration before admission/push; focused execution is not registration.

  Added66.1 ownership: t/lexical_result_guard_composition.t20/t/lexical_result_guard_source_fences.t18/shared lexical_result_guard_cases.json20/lexical_result_guard_excluded_ast.json18 require explicit canonical registration before admission/push; focused execution is not registration.

  Calibration28.0 adds t/definedness_native_numeric_contract.t (two native/fresh/readiness groups). Register exact syntax/execution before admission/push; current focused execution does not establish canonical selection.

  Added67.1 ownership: t/definedness_result_guard_composition.t21/t/definedness_result_guard_source_fences.t18/shared definedness_result_guard_cases.json21/definedness_result_guard_excluded_ast.json18 require explicit canonical registration before admission/push; focused execution is not registration.

  Added68.1 ownership: t/emptiness_result_guard_composition.t22/t/emptiness_result_guard_source_fences.t18/shared emptiness_result_guard_cases.json22/emptiness_result_guard_excluded_ast.json18 require explicit canonical registration before admission/push; focused execution is not registration.

  Added69.1 ownership: t/has_key_result_guard_composition.t22/t/has_key_result_guard_source_fences.t18/shared has_key_result_guard_cases.json22/has_key_result_guard_excluded_ast.json18 require explicit canonical registration before admission/push; focused execution is not registration. Existing null-source regression remains covered by its unchanged6-assertion contract.

  Added69.6.1 ownership: t/copied_null_presence_composition.t11 and tests/fixtures/copied_null_presence_cases.json10 require explicit canonical registration before admission/push; focused execution is not registration. Existing presence18 source fences remain unchanged.

  Added70.1 ownership: t/string_predicate_result_guard_composition.t22/t/string_predicate_result_guard_source_fences.t18/shared string_predicate_result_guard_cases.json22/string_predicate_result_guard_excluded_ast.json18 require explicit canonical registration before admission/push; focused execution is not registration.

  Added71.0 ownership: t/contains_block_operand_composition.t13/t/contains_result_guard_source_fences.t18/tests/fixtures/contains_block_operand_cases.json13 require explicit canonical registration before admission/push; focused execution is not registration.

  Added71.1 ownership: t/contains_result_guard_composition.t26/shared contains_result_guard_cases.json23/contains_null_prefix_guard_cases.json3 require explicit canonical registration before admission/push; fences18 already71.0-owned. Focused execution is not registration.

  Added71.6.1 ownership: t/copied_null_contains_composition.t11 and tests/fixtures/copied_null_contains_cases.json11 require explicit canonical registration before admission/push. Focused direct execution is not registration; existing contains18 fences remain unchanged.

  Added72.0 ownership: t/index_block_operand_composition.t15/t/index_result_guard_source_fences.t18/tests/fixtures/index_block_operand_cases.json15 require explicit canonical registration before admission/push; focused execution is not registration.

  Added72.1 ownership: t/index_result_guard_composition.t19/tests/fixtures/index_null_prefix_guard_cases.json3 require explicit canonical registration before admission/push alongside frozen shared16 and source18; focused execution is not registration.

  Added72.6.1 ownership: t/copied_null_index_composition.t14 (shared12 plus two inline source-exact diagnostics) and tests/fixtures/copied_null_index_cases.json12 require explicit canonical registration before admission/push. Focused execution is not registration; original index18 fences remain unchanged.

  Added73.0 ownership: t/count_block_source_composition.t14, t/count_result_guard_source_fences.t18 and tests/fixtures/count_block_source_cases.json14 require explicit canonical registration before admission/push. Original count excluded18 is consumed by the new fence; focused execution is not registration.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.4.28`
  Status: `completed` / focused selected-field proof; full discovery/admission separate
  Goal: Inventory the distinction between full published Lua error JSON, selected outer fields and all raw native error-table fields; qualify any broader historical preservation claim and add the missing targeted field coverage where required.
  Reproduction: interpreter.to_json(RuntimeInterpreterException) publishes message/diagnostic, while fail/with_runtime_diagnostic preserve outer binding identifier/expected_kind/actual_kind and function-call metadata. The callable observer retains published JSON plus selected code/helper/arity flags, so it is not an injective view of every raw field. Current78.6.5 owns a narrow public two-case/per-host probe and explicit scope disclosure; this owner covers the broader historical contract/consumer review and repair.
  Impact: Equal published JSON alone cannot establish preservation of every raw outer native field. Existing complete-native/diagnostic admission remains open; no runtime serializer or public-format defect is asserted merely from this documented projection.
  Schedule: After agreed feature coverage, before full23.4/diagnostic/native admission and final push; coordinate with4.2/SESSION5. Current bounded guard repair preserves the published projection and named outer flags without claiming all raw-field closure.
  Acceptance: Inventory actual public contracts/consumers and complete raw field populations for the selected errors; retain source-bound old/current probes, distinguishing field mutations and producer/input custody. Repair missing observation/regression coverage or narrow overstated claims, preserving originals and native serializer formats unless separately authorized.
  Verification tier: `focused`
  Focused checks: Source-bound contract/consumer inventory, selected binding-kind and registered-function-arity native error tables on installed PUC/LuaJIT and native/restored/plan/fresh-emitted routes; old/current producer observations, complete observed key/value and absence checks, distinguishing field mutations, historical recovery/corruptions, immutable originals, book/Knowledge/memory/history/task/scope and normal hooks. No unsafe full Lua runner or malformed native patterns.
  Canonical trigger: Final current discovery4.1 and clean publication30.2; split actual public/diagnostic/native admission or infrastructure movement before implementation.
  Claim verification: `docs/claims/TYPE-REFERENCE-BOOK.1.2.23.4.28.json`
  Activation: Clean e0a1bb47571b75b800546c3d4522e0d2ca5f778c after resource14 canonical0, exact promoted receipt, all10 normal hooks, post-pointer, brief0 and clean Git. The fresh committed-range producer0/cached origin4683555e reports1,415,327,104 bytes/108 ahead/47,344 objects, leaving84,672,896 bytes to the director1.5GB trigger; preparation is due. Raw diagnostic pack stays ignored at .linkedspec-data/push-monitor/20261113T004910.681476Z; no remote freshness/wire/future promise. Read the canonical Lua diagnostics/callable pipeline/transform cards, current serializer/wrapper/failure owners, existing two-case probe, selected observers and public book error sections. The serializer projects message/diagnostic; wrapper copying preserves additional native fields. This leaf adds bounded observation coverage and qualifies historical claims, without changing public serializer formats or existing frozen proof. Complete raw-field closure is limited to the selected observed errors, not all runtime errors. Preserve actual producer, direct artifact inputs and native bodies before use; reuse successful opaque native outputs, with wider physical/native closure explicit. After this focused commit, remeasure and complete current discovery4.1 before publication; no new feature lane intervenes.

  Ancillary stale-index defect (own/fix in this handoff): docs/TASK_TREE.md's TYPE-REFERENCE-BOOK table still says independent Dart78.6.3 is next, while committed family80/resource14 and this raw28 pointer are later. Reproduce with the exact TYPE row and current tree frontier at e0; impact is conflicting startup guidance. A separate213-record/nine-historical/zero-live binding query plus injected-live RED protects that row before its one-cell update. Preserve all other rows, record the paused raw28 handoff and discovery4.1/publication next, then verify the public table/root/pointer agree.


  Outcome: Lua selected raw-error coverage is focused-checked: eight source questions/two installed hosts/four routes/old-current128 records;2896 field controls with384 named native misses in the older projection. Each new standalone normal128PASS, specific legacyRED1/rawGREEN0 and first historical recovery0/ten controls pass. Complete source census204 identifies eight function-grammar guard normals: three full public-JSON helpers and five older partial named-field observers. Native/restored and generated envelopes keep distinct contracts. No SDK/serializer or old observation/hash changes; native/source/preparation-origin4.2/SESSION5 and declared5.4/full admission remain separate. Evidence: docs/checkpoints/lua-raw-error-observation-2026-11-13/REVIEW.md. All original used sources/sealed core/failed legacy controls remain unchanged; ten historical corruptions reject. Actual source-bound normal/oracle inputs and modes precede use. The new normal awaits4.1 explicit registration. Director stop is the clean next boundary; no new feature or discovery activation follows this commit.

  Acceptance Checklist
  - [x] **REPRODUCE / ISSUE** — Native raw changes can leave JSON/named flags equal; each host legacy oracle1 specifically misses expected_kind.
  - [x] **ROOT CAUSE (WHY + WHERE)** — to_json is a projection; generated_source_execution_failed creates a separate envelope. Eight source-derived consumers split three published/five partial observers.
  - [x] **FIX** — Add test-only full selected-field observation, per-host old-baseline fixtures and standalone normal; qualify historical scope without SDK/serializer changes.
  - [x] **ADDRESSED (verified)** —128 old/current route records/2896 controls/384 named misses; each new normal128PASS/raw oracle0; independent eight/four controls and first historical0/ten controls.
  - [x] **NO REGRESSION** — Old/current observations and each host recurring old baseline exact; old captures/hash/modes retained. Physical/native and preparation-origin gaps remain4.2/SESSION5; no unsafe full runner/declared5.4/all-error admission.
  - [x] **LOCKSTEP** — Book/Knowledge/roadmaps/live/global task index/resume align; current discovery4.1 and before-push work remain separately owned.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.4.28 - cover selected Lua native error fields`.

  Publication qualification: Original publisher1 expected one reference phrase, but exact source has two, in pipeline and concat sections. It failed before shared writes. Separate qualified execution changes only that guard to two and its output directory; all intended edits then complete0. Original publication-reader1 incorrectly decodes retained binary attachments as UTF-8 before interpretation. Separate qualified reader decodes only known text suffixes, preserves all membership/hash/mode checks, and passes0/six reason-sensitive corruptions. Original sources/failures/images remain unchanged, with no SDK or successful producer replay. Default publication recovery is review_publication_qualified.py; core review.py remains the original first-green historical reader. Final metadata/book/memory/normal-hook checks still govern landing.

  Landing preparation: Current229-input identity/no SDK-or-old-claim diff/rendered-book/stopped-pointer guard0; first historical0/ten controls and qualified publication0/six controls. Knowledge1756/12506 keys and reference scope1958/17 pages synchronize. mdBook0/runtime chapter879 lines; known15304114-byte search index remains18.2. Explicit memory/handoff0/MEMORY15 lines3185 bytes; histories0 at315/48729 and216/38780. Metadata0/4178 unique IDs/12553463 collection bytes before this short note, with README20 surfaces/62 routes/40 classes0 and whitespace0. Normal all10/post-pointer/brief0/clean governs landing; no full CI. Then fresh outgoing-size check and director-requested stop, without activating4.1.

  Staging qualification: Cached whitespace check2 exposes one trailing blank in the new book-section.md template; no commit starts. Preserve exact used bytes/full mode in the existing before-use archives and a verified gzip, then retire only that plain duplicate after exact original-archive comparison. Historical publication readers consume the frozen template image, so original inputs remain recoverable without changing used bytes or replaying SDK/publishers. template-retirement/result.json records exact identity and residue; no SDK or public-book change follows.

  Normal-attempt qualification: The diagnosis-evidence gate rejects the literal word pending in any checked-label line. One new checked line used that word solely for separately owned discovery/publication work. Exact staged-source grep identifies that single cause; stop the first commit attempt after its known rejection (actual session1, HEAD still e0, brief432). Preserve its exact staged task body, gate, raw metadata and combined log in normal-attempt-one/. Rephrase that line to separately owned, retaining the same scope and every proof; run the unchanged production gate and then a fresh complete normal commit. No test/SDK/checker change or completed all10 result is claimed for the stopped attempt.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.4.29`
  Status: `completed` / bounded existing data epoch with focused proof
  Goal: Renew task-evidence headroom from closed hygiene narratives without changing contracts or limits.
  Dependencies: Clean Perl80.1 after its own new-commentary routing repair; no dirty pivot.
  Scope: Existing unpartitioned REPO-HYGIENE epoch only. Preserve all ordered IDs/CORE fields, complete open/unselected bodies, metadata and full Current Frontier/trailing bytes. Retain exact before/after/Git origin, actual producers/inputs/channels/public queries and independent corruptions. No SDK/pin/tool/schema/cap change, runtime/parity promotion or disk-reclamation claim.
  Trigger: First80.1 normal hook rejects task_evidence12590016/12582912; own10915-byte commentary route permits its clean landing, but further backend records need bounded headroom. Execute before Rust80.2, then resume it immediately.
  Planned verification tier: focused; exact selected-source preservation/retrieval and changed-surface pressure gates, no runtime replay.
  Planned canonical trigger: Full23.4/final clean push; actual policy/tool changes require a separate canonical owner.
  Planned claim verification: Finite authored source/byte-preservation controls; declare exact producer and retained inputs at activation.

  Verification tier: `focused`
  Focused checks: Existing epoch writer/public whole-source and every-ID query, exact source/CORE/open-body/full-tail recovery and corruptions/current identity; task metadata/pressure, book/history/scope/normal hooks. No SDK replay.
  Canonical trigger: Full23.4/final clean push; data-only migration changes no infrastructure.
  Claim verification: none: Finite authored task/byte preservation controls, no new runtime/performance/population/completeness measurement.
  Activation: Cleanbf01d855bf913a5a839670669d9ad91e9c6314df/all10/post-pointer/brief0/clean. Original unactivated four-helper-node plan is incompatible with the published epoch API's explicit unpartitioned-tree requirement (tools/migrate_task_narrative.py, docs/TASK_TREE_README.md). Select eligible unpartitioned REPO-HYGIENE instead; source has exact uppercase frontier, no Scope/prior-epoch fields and no duplicate CORE labels. Existing framework/source contracts and relevant book reviewed; preserve dated cleanup claims without re-admission. Prepare before one-shot use; source equals activation Git.

  Acceptance Checklist
  - [x] **REPRODUCE / ISSUE** — Prior80.1 task-evidence cap failure and own-commentary route leave little feature-record headroom; exact bf01 REPO-HYGIENE source is independently retained.
  - [x] **ROOT CAUSE (WHY + WHERE)** — Current collection reaches its fixed aggregate; existing unpartitioned data epochs retain closed commentary in Git while keeping current CORE/open obligations. Partitioned helper source is rejected by that interface, so the unactivated source proposal is corrected.
  - [x] **FIX** — Existing epoch29 creates22 closed pointers, preserving25 ordered IDs/all CORE fields/three complete unselected bodies/prefix/full22339-byte tail;110217 becomes61280 bytes, renewing48937 under unchanged limits.
  - [x] **ADDRESSED (verified)** — One-shot migration0 and all26 public whole-source/every-ID queries0/empty stderr match originals; first independent review0/ten effective corruptions/current target-manifest identity0.
  - [x] **NO REGRESSION** — Every unselected byte/full tail and all statuses/contracts stay exact; source/tool/Git/full-mode/physical command channels recover. No SDK/cleanup execution, cache/source deletion, pin/schema/tool change or modern parity claim.
  - [x] **LOCKSTEP** — Book/Knowledge/live/roadmap/resume/task/index/scope/history align; normal clean commit before independent Rust80.2. Full23.4 remains separate.
  Outcome: docs/checkpoints/task-headroom-hygiene-2026-11-12/REVIEW.md. Actual original templates/input snapshots precede use and output snapshots precede queries. Seal precedes first historical review; later launcher/results/publication query/prose are outside it. Current identity is pre-staging only. Publication-input query0 enumerates206 exact accepted claim records/236 historical intersections/zero live bindings; original claims/hashes/revisions remain unchanged.
  Remaining: All source/context/portable/full23.4/native4.2/SESSION5/discovery4.1/historical4.24/raw-error4.28/boundary4.17/routing18.2/launcher/declared5.4/formatter owners remain. Historical cleanup dates/totals/frontier words stay dated; current PNT is MEMORY.md. No disk-reclamation/upload-size/whole-repo-reading inference. Rust80.2 resumes after clean landing.
  Landing checks: Task metadata0, memory architecture0, Knowledge1747 facts/12452 question keys, reference scope1949 members/17 pages, mdBook0 (existing15192999-byte search-index warning remains18.2-owned), bounded histories0 (231/38437 change shard;261/53969 engineering shard, existing warning below rollover) and whitespace0. Independent publication-input recovery0 rejects three injected live bindings; original claim rows stay exact. Mandatory normal pressure/doctrine hooks follow; no full CI or runtime replay.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.1.24`
  Status: `completed` / frozen arithmetic63
  Goal: Select the next missing ordinary fluent/source feature from canonical helper/role inventory after bounded free String62 and receiver-prefix62.6 repairs.
  Dependencies: .23.3.62.6.5; current canonical inventory/contracts/book, retained bounded feature outcomes and open defect owners.
  Acceptance: Reconcile remaining per-type/free-helper/receiver source roles with current roadmap/code/book and existing return-kind/arity/mutation/empty/error/context authority. Choose one safe bounded feature and create detailed implementation owners before production. Use public tooling only for missing distinctions; preserve legacy/deferred/context/alias/domain/copy/parser/schema boundaries and prior defect ownership. Feature-first focused checks/docs/commit; no whole-repository/history/full-matrix audit or registered-name coverage inference.
  Verification tier: `focused`
  Focused checks: Targeted canonical inventory/contract/book reads and minimal distinguishing public observations needed for selection; normal continuity.
  Canonical trigger: Full source/domain/context/portable admission and final clean push remain separate after scheduled prerequisites.
  Claim verification: none: Finite authored feature-selection controls, no complete coverage/population measurement; declare any new measured claims at activation.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.1.24 - select arithmetic source and Number-prefix result guards`.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree TYPE-REFERENCE-BOOK --id TYPE-REFERENCE-BOOK.1.2.23.1.24`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.1.25`
  Status: `completed` / frozen numeric comparison64
  Goal: Select the next missing ordinary fluent/source feature from canonical helper/role inventory after bounded arithmetic63.
  Dependencies: .23.3.63.5; current canonical inventory/contracts/book, retained bounded feature outcomes and open defect owners.
  Acceptance: Reconcile remaining per-type/free-helper/receiver source roles with current roadmap/code/book and existing return-kind/arity/mutation/empty/error/context authority. Choose one safe bounded feature and create detailed implementation owners before production. Use public tooling only for missing distinctions; preserve legacy/deferred/context/alias/domain/copy/parser/schema boundaries and prior defect ownership. Feature-first focused checks/docs/commit; no whole-repository/history/full-matrix audit or registered-name coverage inference.
  Verification tier: `focused`
  Focused checks: Targeted canonical inventory/contract/book reads and minimal distinguishing public observations needed for selection; normal continuity.
  Canonical trigger: Full source/domain/context/portable admission and final clean push remain separate after scheduled prerequisites.
  Claim verification: none: Finite authored feature-selection controls, no complete coverage/population measurement; declare any new measured claims at activation.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.1.25 - select numeric comparison source guards and document six-helper reference`.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree TYPE-REFERENCE-BOOK --id TYPE-REFERENCE-BOOK.1.2.23.1.25`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.1.26`
  Status: `completed` / frozen logical65
  Goal: Select the next missing ordinary fluent/source feature from canonical helper/role inventory after bounded numeric comparison64.
  Dependencies: .23.3.64.5; current canonical inventory/contracts/book, retained bounded feature outcomes and open defect owners.
  Acceptance: Reconcile remaining per-type/free-helper/receiver source roles with current roadmap/code/book and existing return-kind/arity/mutation/empty/error/context authority. Choose one safe bounded feature and create detailed implementation owners before production. Use public tooling only for missing distinctions; preserve legacy/deferred/context/alias/domain/copy/parser/schema boundaries and prior defect ownership. Feature-first focused checks/docs/commit; no whole-repository/history/full-matrix audit or registered-name coverage inference.
  Verification tier: `focused`
  Focused checks: Targeted canonical inventory/contract/book reads and minimal distinguishing public observations needed for selection; normal continuity.
  Canonical trigger: Full source/domain/context/portable admission and final clean push remain separate after scheduled prerequisites.
  Claim verification: none: Finite authored feature-selection controls, no complete coverage/population measurement; declare any new measured claims at activation.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.1.26 - select logical Boolean source guard composition`.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree TYPE-REFERENCE-BOOK --id TYPE-REFERENCE-BOOK.1.2.23.1.26`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.1.27`
  Status: `completed` / frozen lexical66
  Goal: Select the next missing ordinary fluent/source feature from canonical helper/role inventory after bounded logical guard65.
  Dependencies: .23.3.65.5; current canonical inventory/contracts/book, retained bounded feature outcomes and open defect owners.
  Acceptance: Reconcile remaining per-type/free-helper/receiver source roles with roadmap/code/book and existing return-kind/arity/mutation/empty/error/context authority. Choose one safe bounded feature and create detailed implementation owners before production. Use public tooling only for missing distinctions; preserve unknown/deferred/context/alias/domain/copy/parser/schema boundaries and prior defect ownership. Feature-first focused checks/docs/commit; no whole-repository/history/full-matrix audit or registered-name coverage inference.
  Verification tier: `focused`
  Focused checks: Targeted canonical inventory/contract/book reads and minimal distinguishing public observations needed for selection; normal continuity.
  Canonical trigger: Full source/domain/context/portable admission and final clean push remain separate after scheduled prerequisites.
  Claim verification: none: Finite authored feature-selection controls, no complete coverage/population measurement; declare any new measured claims at activation.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.1.27 - select lexical comparison source guard composition`.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree TYPE-REFERENCE-BOOK --id TYPE-REFERENCE-BOOK.1.2.23.1.27`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.1.28`
  Status: `completed` / frozen definedness67 after compatibility calibration28.0
  Goal: Select the next missing ordinary fluent/source feature from canonical helper/role inventory after bounded lexical guard66.
  Dependencies: .23.3.66.5; current canonical inventory/contracts/book, retained bounded feature outcomes and open defect owners.
  Acceptance: Reconcile remaining per-type/free-helper/receiver source roles with roadmap/code/book and existing return-kind/arity/mutation/empty/error/context authority. Choose one safe bounded feature and create detailed implementation owners before production. Use public tooling only for missing distinctions; preserve unknown/deferred/context/alias/domain/copy/parser/schema boundaries and prior defect ownership. Feature-first focused checks/docs/commit; no whole-repository/history/full-matrix audit or registered-name coverage inference.
  Verification tier: `focused`
  Focused checks: Targeted canonical inventory/contract/book reads and minimal distinguishing public observations needed for selection; normal continuity.
  Canonical trigger: Full source/domain/context/portable admission and final clean push remain separate after scheduled prerequisites.
  Claim verification: none: Finite authored feature-selection controls, no complete coverage/population measurement; declare any new measured claims at activation.
  Children: `.23.1.28.0` immediate producer/numeric-flag calibration prerequisite before feature freeze.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.1.28 - select definedness result source guard composition`.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree TYPE-REFERENCE-BOOK --id TYPE-REFERENCE-BOOK.1.2.23.1.28`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.1.28.0`
  Status: `completed` / existing-compatibility oracle calibration
  Goal: Resolve unexpected Perl definedness-false numeric continuation before defining result-guard expectations.
  Dependencies: parent28 public21/native-fresh/descriptor/substitution/emission; current definedness11/numeric/scalar-copy authority; Knowledge Map before code.
  Acceptance: Establish whether native empty-text false carries numeric flags and whether nested/free/copy/fluent numeric routes preserve an existing compatibility or expose a defect. Inspect public values before serialization/coercion and retain actual producer/instrument/constants/inputs/results. Use distinguishing literal empty String/DSL Bool/Number0 controls and current numeric contract, trace code only after public mechanism. If defective, own a bounded repair; otherwise correct only the provisional authored expectation and document qualified compatibility without new portable authority. Keep original observations/expectation epoch, no false runtime RED credit. Parent feature freeze/production waits for resolution.
  Verification tier: `focused`
  Focused checks: Finite public native/fresh scalar-flag and numeric controls, relevant direct numeric/definedness check only if needed; book/card/map/history/manual continuity.
  Canonical trigger: New cross-backend authority would need separate adoption; ordinary existing-compatibility calibration remains focused; full23.4/push separate.
  Claim verification: `docs/claims/TYPE-REFERENCE-BOOK.1.2.23.1.28.0.json`
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.1.28.0 - preserve Perl definedness native numeric compatibility`.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree TYPE-REFERENCE-BOOK --id TYPE-REFERENCE-BOOK.1.2.23.1.28.0`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.1.29`
  Status: `completed` / frozen emptiness68
  Goal: Select the next missing ordinary fluent/source feature from canonical helper/role inventory after bounded definedness guard67.
  Dependencies: .23.3.67.5; current canonical inventory/contracts/book, retained bounded feature outcomes, compatibility calibration28.0 and open defect owners.
  Acceptance: Reconcile remaining per-type/free-helper/receiver source roles with roadmap/code/book and existing return-kind/arity/mutation/empty/error/context authority. Choose one safe bounded feature and create detailed implementation owners before production. Use public tooling only for missing distinctions; preserve unknown/deferred/context/alias/domain/copy/parser/schema boundaries and prior defect ownership. Feature-first focused checks/docs/commit; no whole-repository/history/full-matrix audit or registered-name coverage inference.
  Verification tier: `focused`
  Focused checks: Targeted canonical inventory/contract/book reads and minimal distinguishing public observations needed for selection; normal continuity.
  Canonical trigger: Full source/domain/context/portable admission and final clean push remain separate after scheduled prerequisites.
  Claim verification: `docs/claims/TYPE-REFERENCE-BOOK.1.2.23.1.29.json`
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.1.29 - select emptiness guards and own fixture-input custody gap`.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree TYPE-REFERENCE-BOOK --id TYPE-REFERENCE-BOOK.1.2.23.1.29`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.1.30`
  Status: `completed` / frozen has_key69
  Goal: Select the next missing ordinary fluent/source feature from canonical helper/role inventory after bounded emptiness guard68.
  Dependencies: .23.3.68.5; current canonical inventory/contracts/book, retained bounded feature outcomes and open defect owners.
  Acceptance: Reconcile remaining per-type/free-helper/receiver source roles with roadmap/code/book and existing return-kind/arity/mutation/empty/error/context authority. Choose one safe bounded feature and create detailed owners before production. Use public tooling for missing distinctions; preserve unknown/deferred/context/alias/domain/copy/parser/schema boundaries and prior defect ownership. Feature-first focused checks/docs/commit; no whole-repository/history/full-matrix audit or registered-name coverage inference.
  Verification tier: `focused`
  Focused checks: Targeted canonical inventory/contract/book reads and minimal distinguishing public observations needed for selection; normal continuity.
  Canonical trigger: Full source/domain/context/portable admission and final clean push remain separate after scheduled prerequisites.
  Claim verification: none: Finite authored feature-selection controls, no complete coverage/population measurement; declare any new measured claims at activation.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.1.30 - select has_key result source guard composition`.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree TYPE-REFERENCE-BOOK --id TYPE-REFERENCE-BOOK.1.2.23.1.30`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.1.31`
  Status: `completed` / frozen String-predicate guard70; production unchanged
  Goal: Select the next missing ordinary fluent/source feature from canonical type/role inventory after bounded presence69 and copied-null69.6.
  Dependencies:69.6.5 committed; current canonical inventory/contracts/book, recorded bounded outcomes and open defect owners.
  Acceptance: Reconcile remaining per-type/free-helper/receiver source roles with roadmap/code/book and existing return-kind/arity/mutation/empty/error/context authority. Choose one safe bounded feature and create detailed owners before production. Use public tools for missing distinctions; preserve unknown/deferred/context/alias/domain/copy/parser/schema boundaries and existing defect ownership. Feature-first focused checks/docs/commit; no whole-repository/history/full-matrix audit or registered-name coverage inference.
  Verification tier: `focused`
  Focused checks: Targeted canonical inventory/contract/book reads and minimal distinguishing public observations needed for selection; ordinary continuity.
  Canonical trigger: Full source/domain/context/portable admission and final clean push after scheduled prerequisites.
  Claim verification: none: Finite authored feature-selection controls, no complete coverage/population measurement; declare any new measured claims at activation.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.1.31 - select String predicate source guard composition`.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree TYPE-REFERENCE-BOOK --id TYPE-REFERENCE-BOOK.1.2.23.1.31`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.1.32`
  Status: `completed` / frozen contains71; production unchanged
  Goal: Select the next missing ordinary fluent/source feature from canonical type/role inventory after bounded String-predicate guards70.
  Dependencies:70.5 committed; current canonical inventory/contracts/book, recorded bounded outcomes and open defect owners.
  Acceptance: Reconcile remaining per-type/free-helper/receiver source roles and inter-type continuations against roadmap/code/book and existing return-kind/arity/mutation/empty/error/context authority. Choose one safe bounded feature and create detailed owners before production. Use public tools for missing distinctions; retain unknown/deferred/context/alias/domain/copy/parser/schema boundaries and existing defect ownership. Feature-first focused checks/docs/commit; no whole-repository/history/full-matrix audit or registered-name completeness inference. Infrastructure/admission prerequisites remain scheduled, including task-evidence backend-path extension23.4.3.
  Verification tier: `focused`
  Focused checks: Targeted canonical inventory/contract/book reads and minimum distinguishing public observations needed for selection; ordinary continuity.
  Canonical trigger: Full source/domain/context/portable admission and final clean push after scheduled prerequisites.
  Claim verification: none: Finite authored feature-selection controls, no complete coverage/population measurement; declare any new measured claims at activation.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.1.32 - select contains source guards and own operand-copy repairs`.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree TYPE-REFERENCE-BOOK --id TYPE-REFERENCE-BOOK.1.2.23.1.32`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.1.33`
  Status: `completed` / frozen index72; production unchanged
  Goal: Select the next ordinary fluent/source feature after bounded membership71 and copied-null71.6.
  Dependencies:71.6.5 committed; canonical helper/type/receiver inventory/contracts/book/current outcomes/open defect owners.
  Acceptance: Reconcile remaining per-type/free-helper/receiver roles and returned-type transitions against existing kind/arity/mutation/copy/empty/error/context authority. Use the smallest distinguishing public observations needed to choose one safe bounded feature; create detailed owners before production. Preserve unknown/deferred/traversal/function/parser/schema/host boundaries and recorded qualifications. Feature-first focused docs/commit, no whole-repository/history/full-matrix audit or registered-name completeness inference.
  Verification tier: `focused`
  Focused checks: Targeted canonical inventory/contract/book reads and minimal distinguishing public observations for selection; ordinary continuity.
  Canonical trigger: Full source/domain/context/portable admission and final clean push after scheduled prerequisites.
  Claim verification: none: Finite authored selection controls, no complete population/coverage measurement; declare any measurement at activation.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.1.33 - freeze index source guards and typed-operand repair campaign`.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree TYPE-REFERENCE-BOOK --id TYPE-REFERENCE-BOOK.1.2.23.1.33`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.1.34`
  Status: `completed` / frozen count73; production unchanged
  Goal: Select the next ordinary fluent/source feature after bounded index72 and copied-null72.6.
  Dependencies:72.6.5 committed; canonical helper/type/receiver inventory/contracts/book/current outcomes/open defect owners.
  Acceptance: Reconcile remaining per-type/free-helper/receiver roles and returned-type transitions against existing kind/arity/mutation/copy/empty/error/context authority. Use the smallest distinguishing public observations to choose one safe bounded feature and create detailed owners before production. Preserve unknown/deferred/traversal/function/parser/schema/host boundaries and dated qualifications. Feature-first focused selection/docs/commit, no whole-repository/history/full-matrix audit or registered-name completeness inference.
  Verification tier: `focused`
  Focused checks: Targeted canonical inventory/contract/book reads and minimum distinguishing public observations for selection; ordinary continuity.
  Canonical trigger: Full source/domain/context/portable admission and final clean push after scheduled prerequisites.
  Claim verification: none: Finite authored selection controls, no population/coverage measurement; declare any measurement at activation.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.1.34 - freeze count source guards and typed-source repairs`.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree TYPE-REFERENCE-BOOK --id TYPE-REFERENCE-BOOK.1.2.23.1.34`.

- ID: `TYPE-REFERENCE-BOOK.1.2.20.2`
  Status: `completed` / source-bound epoch capacity renewed
  Priority: P1; next after23.4.7 clean landing, before further feature growth.
  Goal: Renew current task collection headroom through another source-bound closed-narrative extraction while retaining every current obligation and all existing ceilings.
  Dependencies: Accepted20.1.10; preserve the selected Count73 feature sequence unless the actual gate would reject further task growth.
  Reproduction/impact: The restored current collection passes its existing aggregate byte cap with less than one percent headroom. Additional evidence can consume this margin, so normal-hook restoration is not a lifetime task-growth allowance. Publication-custody7 now records actual normal-hook rejection at12584656/12582912 bytes; activate this owner before further growth. No numerical ceiling increase is authorized.
  Schedule: Actual rejection activates this owner immediately after23.4.7, before Rust Count73.2. Use the current capacity checker, classify closed narrative in the next suitable owner, retain exact predecessor/retrieval and independent obligation/open-body proof; do not remove current nodes or edit immutable partitions.
  Acceptance: Meaningful renewed headroom within the original aggregate/file/per-part limits, exact source reconstruction, complete current contracts, negative loss/corruption controls, book/continuity updates and normal canonical acceptance for infrastructure.
  Verification tier: `canonical`
  Focused checks: Selected owner/source census, exact narrative/current-contract preservation and direct reader/index controls; no unrelated historical audit.
  Canonical trigger: Infrastructure acceptance and exact clean push boundary.
  Claim verification: `docs/claims/TYPE-REFERENCE-BOOK.1.2.20.2.json`

  Activation: Clean659f19d748dd after custody7 normal-hook landing; brief0 and tree clean. Preserve all current IDs/contracts/open bodies and immutable sources. Scope closed narrative renewal only; no ceiling increase or dependency implementation access.

  Selected source: Clean659f19d7 PERL-PRIVATE-FACTORY-CAPTURE.md has72 eligible closed nodes with388827 legacy-render structural bytes available. New epochs retain the full committed source through Git content identity and guarded ancestry, preserving every CORE field and open body; no duplicate payload archive or old-source pointer is invented. Current3-tree retrieval stays unchanged. Population setup assumed multiline headers for five legacy inline-root files; rejected source/log are retained, those files explicitly unclassified and untouched. No selected source/tool has a live claim intersection.

  Result: New unpartitioned source epochs preserve the complete accepted Git body by ancestor commit/path/blob/SHA256 and keep old three-archive queries unchanged. PERL private task source retains83 IDs/all CORE fields/11 open or unselected bodies;72 closed narratives renew380979 bytes. The current maintenance date is refreshed. Dated final focused capture12204983/12582912 leaves377929 bytes before later continuity edits; final gates enforce current pressure. Immutable partitions, existing source archives and all numerical ceilings stay unchanged.
  Verification: Independent line-state contract projection, actual public node/full/legacy CLI routes, old archive controls and22 exact source/selection/contract/pointer/manifest denials pass. The committed-manifest case explicitly models the prior boundary. Original reader RED and initial/corrected/final producer epochs survive; complete final direct artifact inputs are retained or Git-retrievable. Canonical receipt and normal hooks govern infrastructure landing; no complete runtime/portable admission follows. Existing Python entrypoint/temporary-owner membership covers the changed test file; no inventory allowance changes.
  Documentation: Book/setup guide/Knowledge/current task and roadmap/live/resume pointers align; no live claim intersects changed source/tools/book/card paths. Publish the next exact verified clean HEAD under normal hooks, then resume Rust Count73.2/peers, P1 copy73.6 and advisory growth8.
  Commit: TYPE-REFERENCE-BOOK.1.2.20.2 — retain later task narratives through immutable source epochs

  Acceptance Checklist
  - [x] **REPRODUCE / ISSUE** — source-bound custody7 cap rejection and actual new-epoch CLI exit2 retained; `rg -n`/task capacity records identify the owning surface.
  - [x] **ROOT CAUSE (WHY + WHERE)** — tool-backed original reader restricts three one-time snapshots; tools/task_narrative.py and tools/read_task_narrative.py need explicit later source identity, not a new numerical ceiling.
  - [x] **FIX** — bounded immutable epoch manifest, ancestor/Git body hashes, exact current contracts/open bodies and stable-ID query; preserve original archive contracts.
  - [x] **ADDRESSED (verified)** — actual reader REJECT->PASS; independent83-ID/core/11-body proof and22 specific denials PASS with exact retained source/input epochs.
  - [x] **NO REGRESSION** — original archive preservation/corruptions and actual legacy CLI PASS; `git diff --check`; exact `bash tools/run_ci_local.sh` and normal hooks govern this canonical landing.
  - [x] **LOCKSTEP** — mdBook/setup/Knowledge/map/history/roadmap/task/live/MEMORY synchronized; source snapshots remain historical and complete feature admission separate.

  Owned writer boundary defect: Path.read_bytes/write_bytes can follow a symlink or a nested Git boundary before post-write verification. Add explicit repository-volume/regular-file/symlink/nested-repository checks before any new-epoch source read or destination creation. Preserve the prior16-denial source/input capsule unchanged; add actual public-writer refusal controls with no outside write.

  Boundary resolution: All writer modes validate local regular-file/symlink/repository/volume boundaries before writes; new epochs require retained ancestry before mutation. Physical symlink and explicitly modeled repository/device/ancestor controls refuse with no destination creation. Repeated original migration refuses before candidate creation. Final22-denial producer/input capture and replay PASS; prior16/21 phases stay exact. No outside write or other repository creation occurred.

- ID: `TYPE-REFERENCE-BOOK.1.2.20.1.11`
  Status: `completed` / component accepted only through integrated20.1.10 normal hooks and exact canonical receipt
  Goal: Restore canonical historical-objective integrity with exact source-evolution admissions for already committed runtime images and the restoration CI registrations.
  Reproduction: `bash tools/run_python_project_data.sh docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.4.2.1-proof.py` rejects the current Compiler.pm image after original milestone/log reconstruction. The actual canonical log and targeted source population are retained before repair.
  Acceptance: Preserve all original captures/hashes/results and every existing evolution falsifier at its exact admitted source stage. Bind each necessary current image to the immutable0db5e9e87 source and owning current repair, with no wildcard or refreshed old hash; keep current-stage and predecessor-stage reporting explicit. Add missing/corrupt/image/revision/source membership controls and retain actual producers/all inputs. Admit the restoration's exact CI insertions through the existing anchored inverse. Full feature/runtime compatibility remains separately scheduled23.4; this is historical evidence integrity only.
  Planned verification tier: canonical
  Planned focused checks: Actual recovery/audit, prior-stage and current-stage mutation denials, exact Git source identities and provenance, documentation/claim/map/scope/index checks.
  Planned canonical trigger: Blocking prerequisite of integrated20.1.10 and final clean push; no hook bypass or skipped consumer.
  Planned claim verification: none: Component proof is declared by integrated10.
  Focused implementation: Intake classifies22 raw differences as18 required image admissions/three already admitted/one exact CI inverse. The actual isolated recovery passes with all134 original inputs, all prior falsifiers retained at their admitted stages,18 new current-image denials and zero healthy original-log/tracked-write attempts. Current-image helper schema/revision/path/mode/membership/cache controls pass. Final canonical acceptance remains required for landing. The final traced recovery retains185 observed artifact inputs within196 declared inputs; omission controls reject both missing declarations and hidden observations.
  Known wrapper recurrence: The managed retain_objective_epoch.py call emits `child setpgid (83175 to 83175): Operation not permitted`, then exits0 after verifying every declared artifact input. The warned child's actual PGID was not captured. This is already owned by SESSION-STARTUP-READING.7 per project-data-liveness-permission-denial; no establishment guarantee or new cause is inferred, and no recover/purge operation runs.

- ID: `TYPE-REFERENCE-BOOK.1.2.20.1.12`
  Status: `completed` / component accepted only through integrated20.1.10 normal hooks and exact canonical receipt
  Goal: Resolve the reproduced punctuation-light required-argument method fixture failure through current public lowering and the canonical helper contract.
  Reproduction/impact: Exact staged canonical CI passes restoration and historical recovery, then t/punctuation_light_zero_arg_contract.t subtest5 expects an unsupported-helper marker for values.contains while the actual public lowerer emits return undef for both spellings. The normal restoration commit remains blocked.
  Acceptance: Retain actual RED, use LinkedSpec::call_spec_handler_subst and descriptors/execution to distinguish obsolete marker coupling from a runtime/arity regression, preserve bare/parenthesized equivalence and missing-argument rejection, repair the correct owner with a distinguishing negative, synchronize canonical book/fact/proof and rerun exact staged canonical CI plus normal hooks. Do not re-bless without a dumped current outcome and source location.
  Planned verification tier: canonical
  Planned focused checks: Exact punctuation fixture, public lowering/metadata/runtime probes and directly affected contains contract controls.
  Planned canonical trigger: Required integrated restoration acceptance; no bypass.
  Planned claim verification: none: Component actual proof will be bound by integrated10 before landing.

  Root cause and focused proof: Public substitution gives return undef for both missing aliases. Existing typed MethodLowering.pm shape preflight and TYPE13.1 required-needle authority already specify null before effects; only the old punctuation test required the obsolete unsupported-helper marker. Native/fresh authored probes return [null,null,empty-text,1], raw/fallback/unresolved0; adding the rejected needle and removing the valid one distinguish the oracle. Corrected punctuation8 plus direct contains6 pass together; no runtime source changes. Formal grammar/facts/map reconcile the current contract and historical Lua emitter statement. Actual before/after source, failed canonical log, RED/GREEN channels, probe producers/source epoch and rendered paragraph are retained in punctuation-intake.json.gz; initial standalone reviewer import-path failure is retained and repaired. Four complete projection epochs and all retained-evidence controls pass. Exact staged canonical CI and normal hooks still govern landing.

- ID: `TYPE-REFERENCE-BOOK.1.2.20.1.13`
  Status: `completed` / component accepted only through integrated20.1.10 normal hooks and exact canonical receipt
  Goal: Resolve the canonical uniform-binding mutation-result public-surface failure without weakening current mutation or historical supersession contracts.
  Reproduction/impact: Exact staged CI passes punctuation12, then tools/check_uniform_binding_mutation_result_surface.py rejects docs/knowledge/dart-runtime-array-helpers.md for missing explicit uniform-binding supersession. The normal restoration commit remains blocked.
  Acceptance: Read canonical mutation-result authority and affected public surfaces; reproduce the actual checker, retain original inputs/output, reconcile all directly affected required annotations with current results and dated history, preserve negative stale-claim checks, update book/facts/map/scope and run focused surface checks before exact canonical acceptance. No marker-only re-blessing or new runtime behavior.
  Planned verification tier: canonical
  Planned focused checks: Actual named mutation-result and directly dependent public aggregate-selector surfaces plus their mutation controls and rendered documentation as affected.
  Planned canonical trigger: Integrated restoration acceptance and normal hooks; no bypass.
  Planned claim verification: none: Component proof belongs to integrated10.

- ID: `TYPE-REFERENCE-BOOK.1.2.20.1.14`
  Status: `completed` / component accepted only through integrated20.1.10 normal hooks and exact canonical receipt
  Goal: Resolve independently emitted signed-array result-path load failures reached by exact canonical CI.
  Reproduction/impact: The complete staged gate passes all10 doctrines, restoration controls, prior reached backend/MCP/semantic contracts and repaired punctuation/uniform/selector checks, then t/signed_array_selector_perl_contract.t fails independent source loading for control/result_path_positive, negative, float and string. Native invocation completes. This blocks the normal restoration commit.
  Acceptance: Retain actual failed gate and exact fixture/source/error bytes; use LinkedSpec::emit_generated_source, runtime context and source introspection to identify why these four sources fail loading. Compare canonical path/return authority and distinguishing controls before classifying a fixture or production defect. Repair the actual cause with focused native/fresh and loss/negative proof, synchronize affected book/facts/claim/index, then require exact staged canonical CI and normal hooks. No unsupported re-blessing, skipped consumer or bypass.
  Planned verification tier: canonical
  Planned focused checks: The four exact emitted-source failures, public source-emission/loading and signed-array direct dependents selected from the measured cause.
  Planned canonical trigger: Integrated20.1.10 acceptance and normal hooks.
  Planned claim verification: none: Component proof belongs to integrated10.
  Root cause: Count73.1's emitted-result bridge re-reads a raw_perl compatibility receiver after its callable/read_path expression was already prepared, emitting invalid pick()[index]. Native compilation is skipped too; the old fixture's early return after emitted load failure hides native value assertions. Preserve the prepared expression only for this raw Count role; keep ordinary Count policy and compatibility readiness boundaries.
  Integrity preflight correction: An attempted historical current-image inverse failed its added mutation oracle because MethodLowering.pm is outside that audit's historical source population. The rejected producer/error are retained; no such inverse or enlarged historical admission lands. The original auditor is restored byte-identically. This repair instead binds its own actual MethodLowering/test/probe inputs and observations under14; broader fixture/generation closure remains23.4.2. A redundant build argument also rejected before mdBook rendering; corrected invocation uses the published wrapper without a build subcommand.
  Focused closure: Actual four before emitted syntax errors and skipped native handlers become native/fresh1,2,0,0 with the exact prepared-receiver fix. Signed/Count guard/source-fence42 and the strengthened final signed7 pass. Retained emitted sources independently replay four RED/four GREEN; source/value/native/loss mutations reject. Original auditor bytes and its18-image historical admissions remain unchanged. A first standalone reviewer import failed; original producer/error are retained, its explicit tools import is corrected, and final review passes. Canonical CI and normal hooks remain required.
  Final integration discipline: An aggregate review overlapped the deliberate unstage for scope refresh; its index-stability assertion correctly rejected that run. Keep the failed local log, then rerun the same review with the index stable before staging. No failed run receives acceptance credit.

- ID: `TYPE-REFERENCE-BOOK.1.2.20.1.15`
  Status: `completed` / component accepted only through integrated20.1.10 normal hooks and exact canonical receipt
  Goal: Resolve deferred-push recursion diagnostic cycle-label disagreement reached after signed-array admission passes.
  Reproduction/impact: Exact staged canonical42244 passes all earlier restoration/backend/semantic/punctuation/binding/selector checks and repaired signed-array7, then t/codeblock_push_composition_perl.t fails8/605 assertions. Four authored native and emitted cycle errors report cb in cycle position1 where the fixture expects callback or fresh. Typed rejection itself occurs. The normal restoration commit is blocked.
  Acceptance: Retain actual failure and exact inputs; use public native/emitted execution and diagnostic introspection to identify invocation identity versus spelling behavior. Read canonical recursion/codeblock/copy contracts and relevant existing repairs before classifying stale expectations or runtime regression. Repair only the demonstrated cause with distinguishing cycle/alias/independent-value controls; preserve full error shape, ownership and state restoration, synchronize documentation/facts/claim/index, then require exact canonical CI and normal hooks. No blanket diagnostic re-blessing or bypass.
  Planned verification tier: canonical
  Planned focused checks: Four exact native/fresh cycle cases and directly affected codeblock/copy/recursion diagnostic consumers selected after causal evidence.
  Planned canonical trigger: Integrated20.1.10 acceptance and normal hooks.
  Planned claim verification: none: Component evidence belongs to integrated10.
  Focused closure: Canonical TYPE31.6.4.2 and the actual invoke guard close the matched active origin, not the incoming alias spelling. Four authored public native/emitted complete errors report cb-to-cb with exact generated carriers. Only four fixture expected cycles change; push605/identity8 pass. The latter distinguishes copied origins from equal independent records and preserves direct/mutual order. Retained emitted sources independently reproduce all four typed diagnostics; alias/loss/carrier/kind denials reject. Runtime and identity fixture bytes remain unchanged. Original mixed stdout and a probe-local input-scope compile error are retained and corrected without product RED credit; book render and standalone evidence review pass. Exact canonical CI/normal hooks remain mandatory.

- ID: `TYPE-REFERENCE-BOOK.1.2.20.1.16`
  Status: `completed` / component accepted only through integrated20.1.10 normal hooks and exact canonical receipt
  Goal: Resolve scalar numeric composition expectation disagreements reached after all prior restoration blockers pass.
  Reproduction/impact: Exact staged canonical2552 passes signed7, corrected push605, call normalization, variadic functions, generated-source and scalar-text checks, then t/scalar_numeric_contract.t fails20/1008 cases in its final composed subtest on native/emitted values. Actual values/effects differ from expected null/empty results. Normal restoration cannot commit.
  Acceptance: Retain actual failure and fixture/producer/source inputs; identify every failing case and canonical current source/result/receiver/guard authority using public execution/lowering/metadata probes. Classify outdated tests versus production defects only from that evidence and distinguishing controls. Repair the actual owner, retain exclusions and required effect/rejection semantics, update affected book/facts/claim/index and require exact canonical CI plus normal hooks. No blanket expected-value refresh or bypass.
  Planned verification tier: canonical
  Planned focused checks: Exact failed scalar numeric cases and directly affected producer/result/guard consumers selected after causal evidence.
  Known wrapper recurrence: The managed ninth-projection packet retention emits child setpgid73285 EPERM and exits0 after writing the artifact. Actual child PGID is unavailable; no group/cause/lifecycle conclusion follows. Existing SESSION-STARTUP-READING.7 and its required-reading prerequisites own establishment/denied-liveness repair; no recovery/purge runs. Exact observed excerpt/limits are in wrapper-notice-numeric-projection.json.
  Focused closure: All20 are old terminal expectations for current ordinary comparison15/arithmetic16/reducer4/Count-Length3/first-value1 contracts. Twenty independently authored nested-helper twins agree with actual native/emitted fluent values and effects; explicit mathematical/lexicographic derivation preserves sorted[2,10,1]=[1,10,2], take2/sum11. Only20 expected fields in five JSON files change. All1008 IDs/sources/other fields and988 unselected expectations remain exact; complete verbose scalar10/1008 passes without runtime/numeric-v1/deferred-method changes. Actual old log, nine inputs, authorities, initial/final producer epochs,40 public observations, generated sources and complete TAP are retained. Loss/effect/order/value/Boolean-kind denials reject; book renders. These files are outside historical objective source/artifact populations, so no audit inverse or admission expansion is added. Exact canonical CI/normal hooks remains required.
  Planned canonical trigger: Integrated20.1.10 acceptance and normal hooks.
  Planned claim verification: none: Component evidence belongs to integrated10.

- ID: `TYPE-REFERENCE-BOOK.1.2.20.1.17`
  Status: `completed` / component accepted only through integrated20.1.10 normal hooks and exact canonical receipt
  Goal: Resolve three AST source-assertion mismatches reached after scalar numeric calibration passes.
  Reproduction/impact: Exact staged canonical85771 passes every earlier repair, scalar numeric10/1008, named/file resolution and current language coverage, then t/actionir_ast_parser.t fails3/24 groups: Count of an append result gains current actual-kind wrappers; set_key materializes its key operand; compatibility capture_slice gains bounds guards. Normal restoration remains blocked.
  Acceptance: Retain actual failed gate and exact test/runtime inputs. Use public substitution/emitted-source execution, canonical Count/key-evaluation/span contracts and distinguishing effect/bounds controls to establish each mechanism before changing assertions or production. Preserve the AST-first/no broad raw-fallback purpose and reject semantic regressions; update book/facts/claims/index and require exact canonical CI plus normal hooks. No blind expected-string refresh or bypass.
  Planned verification tier: canonical
  Planned focused checks: Three exact lowering cases, distinguishing once-only/key-list/capture-bound controls, complete AST parser fixture and directly affected consumers selected from the measured cause.
  Planned canonical trigger: Integrated20.1.10 acceptance and normal hooks.
  Planned claim verification: none: Component evidence belongs to integrated10.

  Focused closure: Actual native/fresh Count/key programs and exact lowered fragments confirm current contracts. Replace the three layout assertions with append Count once/COW, key snapshot and six defined/empty/missing/reversed capture observations; retain poisoned-source, parser-entry and unknown-helper sentinel fences. AST24/capture-endpoint16 pass. Retained sources replay; isolated lost materializer selects the wrong key and unguarded spans invoke the API on missing/reversed bounds. Five loss/effect/snapshot/bounds/empty corruption controls reject. Original failed gate, exact inputs/producer epochs and rendered book are retained; no production or historical-audit-population edit. Exact canonical CI and normal hooks remain required. Director now authorizes push after clean acceptance, then session-health stop.

- ID: `TYPE-REFERENCE-BOOK.1.2.20.1.18`
  Status: `completed` / accepted only through integrated20.1.10 normal hooks and exact canonical receipt
  Goal: Resolve the complete reached private-factory regression failures without discarding historical source/alias/identity proof.
  Reproduction/impact: Exact staged canonical23277 passes all10 doctrines, E2BIG/atomic/catalog/scope controls, every earlier restoration consumer, scalar numeric and repaired AST/copy/source-bound suites, then complete private-factory population91/32248 fails136 assertions in nine fixtures: trace method lowering, inline capture, AST call/cold capture, method value capture, scalar receiver capture, method-kind capture, AST optional capture and named dispatch capture. Observed differences include generated-layout expectations, callback scalar/array aliases, user-function metadata FETCH traces and literal source-line diagnostics. No cause classification or runtime readiness follows from these symptoms alone; normal commit/push is blocked.
  Acceptance: Freeze the failed gate and exact fixture/probe/baseline/runtime/authority inputs before repair. Use LinkedSpec facade/Trace and the existing actual native capture probes to locate each difference. Reconcile current accepted evaluated-operand, binding/kind/context and callback-selection/alias/error authority with the dated preservation scope. Fix production where its contract is violated; otherwise add exact source-bound current calibration with independent distinguishing controls, preserving original archived observations and all unrelated guards. No blanket trace/line filtering, refreshed historical baseline, skipped consumer or bypass. Keep book/facts/live claims/index and final push/pause steering synchronized, then require exact staged whole canonical CI and normal hooks.
  Planned verification tier: canonical
  Planned focused checks: The nine reached fixtures and their actual probe populations, grouped only by demonstrated causal mechanism; directly affected public semantic controls. Complete private-factory population is deferred to required canonical integration after focused repair.
  Planned canonical trigger: Integrated20.1.10 normal-hook acceptance and director-authorized push; latest parent steering governs continuation.
  Planned claim verification: none: New component evidence belongs to integrated10 before landing.
  Focused closure: Nine current suites2850 pass with all archived native records and production Perl unchanged. Preserve full callback/public-map/fatal/context/alias/publication checks while targeting active splitter/extractor/regex/fallback sites; explicitly test the former inline flow field is unused. Current scalar adapters decline dynamic intermediates, while four original public controls execute their independent values. Nine additional native/fresh programs and retained source replay cover compatible scalars, eager numeric invalid values, incompatible container skip, typed condition order/lazy branches and key snapshots. Scope-guard bypass and legacy key-order controls distinguish regressions. Exact failed input253 and final populations, all source/producers/channels and rejected preparations are retained. No intermediate source-epoch closure or broad private/portable admission is claimed; custody23.4.2 remains owned. Eleven projection/four recovery epochs remain separate. Final exact canonical and normal hooks are required before authorized push/pause.

- ID: `TYPE-REFERENCE-BOOK.1.2.20.1.18.1`
  Status: `completed` / model and instrument errors resolved; integrated acceptance pending
  Goal: Resolve two new public probe prediction disagreements and a separate tied-map instrument error without refreshing predictions from observations alone.
  Reproduction/impact: factory_probe.pl expects score="bad";score.abs().add(effect) to skip effect, but both native/fresh yield null with effectV. It expects raw=7;raw.trim().cat(effect) rejection, but both routes yield7! with effectV. The function-scope probe also lacks FIRSTKEY/NEXTKEY during a real map clone. Exact producer/runtime/channel is frozen in factory-probe-preparation.json.gz before repair. These are unclassified preparation observations, not established runtime defects.
  Acceptance: Read the current scalar/coercion and Number continuation authority, use public substitution/descriptors and source-bound effect/rejection controls to establish the exact contract and mechanism. Repair a real runtime defect if present; otherwise correct only the demonstrated model/instrument error and retain this rejected epoch without product RED credit. Add distinguishing actual-invalid-prefix/healthy controls within documented domains. Require final public/native/fresh and retained-source replay before18 closure.
  Planned verification tier: canonical
  Planned focused checks: Exact two public sources, canonical signature/value/operand-order records, actual lowered source and finite distinguishing controls; tied-map protocol repair.
  Planned canonical trigger: Integrated20.1.10 normal-hook commit and authorized push; latest parent steering governs continuation.
  Planned claim verification: none: Component evidence belongs to integrated10.
  Resolution: The authored predictions confused scalar/Number coercion and numeric domain validation with incompatible-container rejection. Canonical trim signature is scalar; Numeric evaluates already-evaluated arguments then rejects invalid values. Actual substitution retains eager add operands, yielding null/V; trim7/cat yields7!/V. New Number/String take controls prove real container incompatibility skipsV. Nine public native/fresh programs agree with independently stated values/effects. Tied-map iteration is supplied; a bounded secondary component is held constant for guard/fault comparison, exposing active function entry_text rejection before fallback. Initial two exact producer/output preparations remain rejected setup, without product RED credit. No production defect remains from these observations.

- ID: `TYPE-REFERENCE-BOOK.1.2.20.1.18.2`
  Status: `completed` / exact reviewed evolution; integrated acceptance pending
  Goal: Admit the owned method-value diagnostic fixture revision without broadening selector permissions or changing original registrations.
  Reproduction/impact: The actual executable scan rejects the two unchanged intentional diagnostic lines in revised t/actionir_method_value_capture.t because its complete file no longer matches the original historical registration. Actual failed scan, complete current scanner/auditor and fixture bytes are frozen in factory-selector-intake.json.gz before changes.
  Acceptance: Add an exact owned evolution from the retained original file identity to the reviewed final fixture identity, preserving original registrations and every actual positive/copy/edit/foreign-owner/missing-source denial. Retain new source epoch and actual RED/GREEN. If this changes historical-governance input bytes, admit only the exact source-bound inverse with distinct corruption controls; preserve all previous recovery epochs and original falsifiers. No blanket path exclusion, refreshed original hash, classifier-policy change or skipped consumer.
  Planned verification tier: canonical
  Planned focused checks: Actual executable/composed-public scanners, exact evolution ownership/hash controls and required source-bound historical recovery only.
  Planned canonical trigger: Integrated20.1.10 normal hooks and authorized push; latest parent steering governs continuation.
  Planned claim verification: none: Component evidence belongs to integrated10.

  Resolution: Retain original9e9e1d9a file registration and every older evolution. Add only exact18.2-owned method-value evolution to b968a347 with a path-specific owner check; original two diagnostic lines are unchanged. Actual executable and composed-public scans pass. Foreign owner/prior hash/current hash/lost entry/copied path/edited bytes/new positive controls reject. Both changed paths are absent from the historical196 declared/185 observed inputs; no speculative inverse or recovery-population expansion is added. Original source epochs and falsifiers remain exact. Source-reviewer correction: The actual scanner also rejects one controlled invalid selector literally embedded in the new factory reviewer. Its immutable first reader remains in factory-evidence.json.gz. The live reader consumes a retained diagnostic line for the same whole-file corruption denial. factory-reviewer-source-calibration.json.gz retains the exact one-statement correction and actual scanner RED/GREEN on both full reader sources; no exemption or syntax-policy change.
- ID: `TYPE-REFERENCE-BOOK.1.2.20.1.19`
  Status: `completed` / accepted only through integrated20.1.10 normal hooks and exact canonical receipt
  Goal: Repair the reached project-storage inventory assertions against exact reviewed owner populations while retaining actual locality probes and unexpected-owner denials.
  Reproduction/impact: Exact staged canonical18666 passes all10 doctrines, historical recovery, runtime contracts, repaired AST/private-factory91/32260 and CLI/trace12, then tools/test_perl_project_data_storage.sh passes allocation/trace/managed-workspace probes but rejects tracked Perl temporary-owner census29 versus30. The remainder of storage/IO/relocation/phase0 is unreached. No storage leak is established by the census mismatch.
  Acceptance: Freeze the full failed gate, storage checkers and actual original/current inventories before edits. Identify and review every new owner, its allocation semantics, wrapper and same-volume root. Replace changing cardinality assumptions with exact reviewed population comparisons or equivalent hash-bound input authority, preserving all representative filesystem, trace, residue and CLI proofs. Add actual missing/unexpected/replacement-owner controls, review directly dependent Python/tool inventories exposed by the same restoration and fix only demonstrated drift. No blind count increase, permissive discovery baseline, bypass or skipped consumer. Update book/facts/claims/current index, retain producers/all inputs and require whole exact canonical CI plus normal hooks before push.
  Planned verification tier: canonical
  Planned focused checks: Actual Perl storage checker and directly dependent tool-storage census/checker, with exact inventory and mutation controls; other full CI remains the required final boundary.
  Planned canonical trigger: Integrated20.1.10 normal hooks and authorized push; then PNT unless session health requires /exit.
  Planned claim verification: none: Component evidence belongs to integrated10 before landing.

  Resolution: Frozen storage-intake.json.gz retains the full failed18666 log, directly reproduced tool census failure and every matching/nonmatching current/HEAD source candidate before edits. The added Perl history-catalog test uses explicit managed TMPDIR. Three added Python import owners select managed run scratch, the repository restoration directory or validated scope-output parents. Four added Python entrypoints allocate no additional undeclared temporary root. The old tool regex also omitted an existing mkdtemp user; prior Python/shell census drift is retained, not misattributed to new runtime leakage. Four exact reviewed manifests bind30 Perl files,10 Python import owners,47 Python entrypoints and16 shell allocator files. The new Perl validator consumes NUL records, rejects Git errors, missing/unexpected/same-count replacements, duplicates, truncation and empty records. All seven prior Perl memberships remain in its exact authority. Actual old count-plus-seven predicate accepts a same-count substitution on its frozen29-owner population; the same new validator with that frozen population rejects it. Actual Perl and full tool storage checks PASS, preserving filesystem, trace, CLI cleanup, bytecode/map/book/TAP/oracle and hostile-destination probes. Source/data inverse restores the exact29-owner script before all nine original Perl falsifiers; all700 prior governance denials remain, plus seven new source/table/support denials. Fifth isolated recovery epoch closes188 observed/199 declared inputs with all134 originals and18 current-image denials preserved. storage-evidence-accepted.json.gz and perl-storage-inventory-evolution.json.gz retain actual producers/inputs/channels; two prior storage capsules and the actual rejected reader remain immutable. The first documentation reader wrongly required PASS from mdBook output; its actual HTML-success marker is now checked, without product RED credit. broader runtime/feature and transitive allocator completeness are not admitted. Whole exact canonical CI and enabled hooks remain required before landing/push.


- ID: `TYPE-REFERENCE-BOOK.1.2.20.1.20`
  Status: `completed` / accepted only through integrated20.1.10 normal hooks and exact canonical receipt
  Goal: Enforce the already documented macOS sandbox initialization prerequisite before expensive canonical checks and finish normal-hook admission in approved host execution.
  Reproduction/impact: Canonical86500 passes all10 doctrines, recovery, runtime/admission contracts, factory91/32260, CLI12 and repaired Perl/tool storage populations30/10/47/16. The next process-locality oracle exits71 with sandbox_apply Operation not permitted. The current Knowledge card already records the exact September6/7 restricted-harness failure and requires approved host execution from the start. This recurrence is an execution mistake, not evidence of forbidden backend I/O; no receipt, relocation or Phase0 success follows.
  Acceptance: Freeze failed86500 and pre-edit runner/oracle/known guidance/auditor bytes. Reproduce the documented no-op initialization control inside and outside the harness, preserve containment profiles/denials, run the unchanged process oracle with approved host execution, and add a minimal early canonical initialization preflight so denied launches fail before doctrines. Retain actual failure-order controls, exact CI insertion inverse and all prior reason-sensitive falsifiers. Synchronize existing fact/book/tool guidance and complete producer/input closure, stage the complete candidate, then rerun WHOLE canonical CI with approved host execution from the start. Require enabled normal hooks, brief0, clean tree, exact promoted receipt and authorized push. No suffix receipt, hook bypass, profile weakening, dependency/internal repair or new runtime admission.
  Planned verification tier: canonical
  Planned focused checks: Read-only real sandbox initialization controls; actual early failure before doctrines; unchanged six-family process-locality oracle in approved host execution; exact CI evolution and recovery controls; affected book render.
  Planned canonical trigger: Integrated20.1.10 normal hooks and authorized push; latest parent continuation steering applies.
  Planned claim verification: none: Component evidence belongs to integrated10.

  Resolution: execution-intake.json.gz retains failed86500 and every pre-edit execution authority, including the existing September6/7 guidance. Actual no-op exits71 restricted/0 host; the unchanged six-family process oracle passes with its original profile and all denials. The runner now checks exactly that initialization before doctrines, with no bypass flag. Actual stable-index restricted launch stops there with a named host-execution instruction. A first trial begun before staging finished is retained as a rejected setup error, without guard/product RED credit; dependent actions now wait for staging completion. execution-evidence.json.gz retains actual host subprocess outcomes, complete channels, exact single-insertion source evolution, four source/five outcome corruption denials and rendered additive guidance. The oracle source is byte-identical to intake. Existing Knowledge/Toolbox/startup/book routes now expose the requirement before another long run. Historical inverse strips the exact new CI block, retains all prior700 governance controls and adds three (703 total); storage7 and other populations are unchanged. Sixth recovery epoch closes188 observed/199 declared inputs; aggregate comparison requires every earlier per-source/control population preserved. Whole final candidate CI MUST launch with require_escalated host execution from the start; no restricted retry, suffix receipt, profile weakening or normal-hook bypass.


- ID: `TYPE-REFERENCE-BOOK.1.2.20.1.21`
  Status: `completed` / component accepted only through integrated20.1.10 normal hooks and exact canonical receipt
  Goal: Resolve the six actual Phase0 failures against current observable semantics and lowering contracts, preserving original captures, all existing behavior/readiness tests and historical evidence stages.
  Reproduction/impact: Full host canonical69786 passes all doctrines, restoration/recovery, runtime/admission contracts, factory91/32260, CLI12, both storage oracles, unchanged six-family process containment, five relocation anchors, and Perl primary66 default/66 POSIX. Complete Phase0 reaches1035 top-level tests in1418s and fails234/836/1012/1014/1015/1022: named-mark capture_from rewrite, capture_slice_len source, decimal and block numeric chains, numeric aliases and append-result Count source. No whole CI receipt, normal commit or push follows. Initial diagnostics show generated-source expectation mismatches; classify each only after Toolbox/native/fresh observations and exact contract review.
  Acceptance: Freeze failed69786 complete log and pre-edit Phase0/producer/runtime/support/authority inputs. Use LinkedSpec public probes first; distinguish wrong behavior from incidental layout and preserve independent value, effect, alias, guard, source/readiness and kind denials. Fix real runtime defects if established; never weaken a test to hide them. Retain1035 existing top-level IDs and all unaffected assertions. Any Phase0 fixture evolution must have an exact owner-bound byte inverse to its committed0db image before older historical checks, with actual current fixture provenance separate from18 preserved committed image admissions; preserve every earlier703 governance, storage7 and image18 falsifier at its proper stage. Retain all producers/inputs/channels and rejected instrument attempts honestly; update affected book/facts/claims/index. Focused checks first, then whole exact staged canonical HOST run from the start, enabled normal hooks, brief0, clean receipt-bound authorized push. No stale-hash refresh, fake Git revision, suffix proof, test/profile skip or hook bypass.
  Planned verification tier: canonical
  Planned focused checks: Exact six reached Phase0 consumers and independently authored native/fresh public programs plus source/effect/kind corruption controls; current/historical source-stage recovery and book render.
  Planned canonical trigger: Integrated20.1.10 normal hooks and authorized push; current parent continuation steering applies.
  Planned claim verification: none: Component evidence belongs to integrated10.

  Resolution: Full failed69786 and112 pre-edit inputs are retained. Public lowering and independently authored native/fresh programs confirm guarded named/anonymous captures, valid empty/zero, floor-before-add3.75, block effects once and appendCount3 with updated[1,2,3]/earlier[1,2] snapshots. Exactly six assertion spans change; every other assertion and1035 top-level identities remain, including all readiness and whole native-value tests. Actual six-group baseline fails6 and final six-group run passes70 assertions; six deliberately wrong emitted bodies fail the same new assertions. Early focused harness attempts lacked initialization supplied by earlier Phase0 tests and are retained as setup errors without product RED credit. Current producer/native/fresh/source/input/outcome/rendered-page evidence and loss controls are retained in phase0-evidence-final.json.gz; no production source changes belong to21.
  Rejected capture custody: The first seventh recovery epoch recorded the old book hash before an overlapping operator book edit and declared the new one at completion. The existing aggregate epoch verifier rejects that exact mismatch. Original rejected epoch/initial evidence reader remain byte-identical; a stable-input rerun passes189/200 and is the accepted seventh epoch. No new production defect or accepted proof is inferred from the rejected setup.
  Composed reader correction: The execution capsule also binds its own reader. Aggregate review rejects that self-input drift after adding the exact auditor delegation. Final reader uses an exact single-replacement predecessor/current check for itself too; phase0-evidence-final retains both previous provisional capsules/readers and actual composed rejection. No unrelated input identity is skipped.
  Source-stage custody: Unchanged18-image guard actually rejects the new fixture before admission. Pinned owner21 six-hunk table validates the actual full current hash and restores exact committed0db bytes ahead of unchanged image/predecessor checks. The current fixture and preserved activation image have separate reported provenance, without a fake revision or old hash update. Seven exact auditor edits and the execution-evidence reader's single owned source-evolution delegation are retained against their predecessors. All703 governance, storage7, image18, runtime9 and support5 controls retain their original stages;11 new fixture source/table/owner/path/revision/hash/hunk denials pass. Seventh recovery closes189 observed/200 declared inputs and zero healthy original-log/tracked-write attempts. Book/fact and aggregate review explain the distinction. Exact final whole host canonical, normal enabled hooks, cleared brief, clean promoted receipt and authorized push remain mandatory.


- ID: `TYPE-REFERENCE-BOOK.1.2.20.1.13.1`
  Status: `completed` / component accepted only through integrated20.1.10 normal hooks and exact canonical receipt
  Goal: Repair exact executable-source selector classification for current constructor and intentional negative fixtures while retaining positive selector denials and concurrency guarantees.
  Reproduction/impact: tools/check_public_aggregate_selector_surface.py invokes the executable scanner concurrency check, which rejects current array(false) constructors and named retired-selector negative cases in computed-selection, constructor, copy and set-key fixtures. Public mutation teaching itself passes. This is separate from deferred task-acceptance backend path scope23.4.3.
  Acceptance: Use the actual scanner's existing classification/public contract, inventory every reported occurrence at its authored test role, preserve all genuine positive selector denials and exact negative provenance, add distinguishing positive/negative/reserved-literal and concurrent controls, retain source/input/RED/GREEN evidence and synchronize current scanner knowledge/book contracts. No blanket file exclusion or runtime grammar change. Exact canonical CI plus normal hooks is required through integrated10.
  Planned verification tier: canonical
  Planned focused checks: Actual scanner reported population and mutation/concurrency controls, then the directly composed public aggregate-selector checker.
  Planned canonical trigger: Blocking infrastructure prerequisite of integrated restoration.
  Planned claim verification: none: Component proof is declared by integrated10.

- ID: `TYPE-REFERENCE-BOOK.1.2.20.1.13.2`
  Status: `completed` / component accepted only through integrated20.1.10 normal hooks and exact canonical receipt
  Goal: Keep public selector reference classification consistent with actual literal AST tokens when documenting the executable scanner repair.
  Reproduction/impact: The public checker uses the same textual identifier approximation; verify its treatment of literal constructor arguments against public parsing/execution before publishing the new scanner explanation. Binding tokens and case variants must remain rejected.
  Acceptance: Retain actual public-checker RED and permitted constructor observations, make only exact keyword-discrimination changes, preserve current70/40 public inventory and every migration/positive denial, admit any changed historical-governance source through exact anchored inverses with old and new falsifiers, then run focused composed checks and recovery before canonical acceptance. No runtime or signature change.
  Planned verification tier: canonical
  Planned focused checks: Public inline/fenced literal/binding controls, existing migration mutations, composed selector and isolated historical recovery producer.
  Planned canonical trigger: Integrated restoration and normal hooks.
  Planned claim verification: none: Component proof is declared by integrated10.

  Focused component13 closure: Dart already described updated snapshots; explicit supersession provenance was missing. Frozen reader inputs reproduce RED and after-note GREEN; lost annotation, stale public claim and missing current anchor all reject. Mutation teaching and direct uniform-binding13 pass. Component13.1 classifies20 reported sites as8 real literal constructors plus12 negative/AST diagnostics in8 exact files. Whole-file/path/line identities,84 denials, ordinary/mixed positives and staggered concurrency pass without fixture/runtime edits. Component13.2 fixes the same literal approximation in public references with18 inline/fenced controls and unchanged70/40 inventory. The historical audit retains its original controls and adds6 exact regex-edit denials (700 governance controls);134 restored inputs,18 current-image denials and185 observed/196 declared artifact inputs remain intact. Source populations replay original RED20/repaired GREEN0; dropped/stale source controls reject. Verified primary references reconstruct the original compressed population byte-for-byte, avoiding duplicate binary payloads. All actual producers, inputs, channels and rendered addendum are retained; six full projection epochs and four recovery epochs pass. Exact staged canonical CI and normal hooks still govern landing.

- ID: `TYPE-REFERENCE-BOOK.1.2.20.1.22`
  Status: `completed` / component accepted only through integrated10 exact canonical and normal hooks
  Goal: Correct the current local-gate book summary from61 to66 primary CLI cases without rewriting historical61-case observations or weakening retained source identities.
  Reproduction/impact: local-ci-and-regression.md What the local gate checks explicitly says currently/all61 primary CLI cases, while current conformance has66 and whole host38905 passes the default66 leg. Later66-case historical records do not qualify that current61 statement. The director reviews the book, so the current summary is misleading. Whole38905 was stopped through its documented managed-wrapper signal forwarding at exit143 before source edits; no complete receipt or passing whole-run claim follows.
  Acceptance: Retain pre-edit book/readers/current producer/case data and complete interrupted run. Change only the current summary count, preserve every historical count and other book word, admit exact owned current-book evolution separately from unchanged historical source capsules, retain actual distinguishing stale-count/loss/current-source controls, render and review, refresh current task/index/claims/scope and rerun whole exact host canonical before normal hooks. Existing23.4.3 explicitly remains mandatory before any push; next clean activation must repair it before publication, with Rust Count73.2 following. No suffix proof, stale-hash refresh or hook bypass.
  Planned verification tier: canonical
  Planned focused checks: Actual primary case inventory against exact book sentence; exact single-replacement current-book inverse and historical capsule preservation; rendered corrected summary and source/loss mutations.
  Planned canonical trigger: Integrated restoration normal commit; existing23.4.3 separately precedes authorized push.
  Planned claim verification: none: Component proof belongs to integrated10.

  Component22 result: Current summary changes exactly one61->66 token; all other bytes and historical61-case observations remain. Actual manifest/default-leg66 inventory, five stale/wrong/lost/source corruptions and rendered summary pass. Prior storage reader/book bytes are retained and independently normalized only after exact current transitions validate; actual storage population/control results are unchanged and pass. Interrupted38905 exits143 without a receipt. Explicit23.4.3 before-any-push prerequisite is next after clean restoration landing, ahead of Rust Count73.2.


- ID: `TYPE-REFERENCE-BOOK.1.2.23.4.6`
  Status: `done` / bounded retention-only daily artifact review
  Goal: Review safe disposable artifacts after the November1 cleanup boundary and refresh the bounded cleanup record.
  Acceptance: Inspect only LinkedSpec-owned paths using the canonical cleanup tools; preserve dependency stores, active jobs and every proof input. Remove only exact proven disposable artifacts after preserving required evidence, or record that no deletion is safe. Commit the latest timestamp/summary and retained review evidence before continuing PNT.
  Priority/schedule: Next clean activation after23.4.3; daily cleanup is over24h old. No cross-repository writes or dependency implementation reads.
  Verification tier: `focused`
  Focused checks: Existing non-following scanner on named root/Rust/log scopes; independent per-file metadata and retained snapshot corruption controls; book render, memory/history/task integrity and mandatory doctrines.
  Canonical trigger: Final clean push; no storage, hook, CI or production implementation changes in this leaf.
  Claim verification: `docs/claims/TYPE-REFERENCE-BOOK.1.2.23.4.6.json`

  Activation: d3a26a94f5c2efba736806ac13911155e3739995 is committed, canonical-verified and published. All23 bounded uploads, main fast-forward and leased temporary-branch removal completed; independent fresh refs match local/origin main and the tree/brief are clean. Publication custody remains7. Read canonical cleanup boundary, closed-hardlink rule and book maintenance section; metadata alone does not authorize disposal. No deletion is selected. Preserve all current build/package stores and proof data.
  Small pointer clarification: The preceding leaf generated boundary-after.json and retained it byte-for-byte as boundary-after.json.gz; update its maintained narrative to name the actual compressed artifact. No evidence byte changes.
  Finding ownership: New8 owns the actual GitHub large-file warning and repository-growth guidance, after already selected Rust Count73.2 and P1 copy73.6 before unrelated selection. Preserve historical evidence; no history rewrite or off-volume migration is authorized by the warning.

  Result: The retained926 per-file path/suffix/byte rows match independent scandir/lstat observations across eight named scopes. Actual missing-row, wrong-size, duplicate-row, outside-path and producer-byte controls reject; default readonly replay passes. No file was removed and no reclamation/liveness/disposability claim follows. Dart/Julia convention directories and Lua wrapper remain retained. Snapshot/source/index/message bytes survive in docs/checkpoints/artifact-review-2026-11-04/observation.json.gz; result.json records the actual readonly replay.
  Documentation: Latest-only cleanup record, book maintenance explanation, published-backlog fact, live/resume/roadmap and new growth owner8 agree. Shared live-claim intersection check finds none for the edited cleanup/book/card/continuity paths. The compressed preceding pointer is clarified without altering any artifact.
  Focused verification outcome: Readonly metadata review and five corruption controls PASS; mdBook HTML build PASS with its large search-index warning retained in the build log. Mandatory memory/history/map/task/doctrine checks and normal hooks govern this focused landing; no new canonical run or broader feature admission is inferred.
  Commit: TYPE-REFERENCE-BOOK.1.2.23.4.6 — retain artifacts after bounded daily review

- ID: `TYPE-REFERENCE-BOOK.1.2.23.4.7`
  Status: `completed` / bounded publication custody reviewed
  Goal: Retain the actual size-safe publication outcomes and close disclosed initial planning/evidence gaps after the authorized immediate push.
  Acceptance: Preserve actual publisher source, exact initial/final plans, per-batch commands/exits/log bytes, final local/remote identity and canonical receipt. Recover the initial inline measurement instrument or explicitly retain its historical limitation; add non-mutating wrong-budget/chain controls and a reproducible Git-object input identity/retrieval representation before claiming complete measured pack custody. Preserve all published Git IDs. No oversized upload or history rewrite is required.
  Priority/schedule: After the immediate normal-hook publication and due cleanup23.4.6, before unrelated runtime selection. Own until verified closure; the director-authorized early safe push is not blocked on converting the initial diagnostic into a broader measurement claim.
  Verification tier: `focused`
  Focused checks: Actual retained publication records and final identities; immutable Git-object identity/retrieval proof; non-mutating wrong-budget/chain controls and scoped claim validation. No full CI or new push for this evidence-only leaf.
  Canonical trigger: Any mechanical hook/storage change needs a separate canonical leaf; final clean publication follows the current receipt policy.
  Claim verification: `docs/claims/TYPE-REFERENCE-BOOK.1.2.23.4.7.json`

  Activation: Clean1888c1bbfce2; published boundary d3a26a94f5c2. Full rejected-candidate narrative/source survives in narrative-before.json.gz; detailed original-source acquisition, findings, contracts and results are canonical in docs/checkpoints/publication-custody-2026-11-04/README.md and its source-bound capsules.
  Result: Original24 records/five primary calls, all23 uploads/normal hooks/receipt/main/leased cleanup, raw streams and109230 opaque-body address/SHA256 checks retained. Readonly replay/16 denials and predecessor preservation pass; only two disclosed claim legs change. Initial equality accepts while current strict guard rejects; raw original group33 differs from actual final34/runtime834; one historical blob repeats across ranges, whose unique required-object coverage passes. No physical pack/transitive toolchain closure, exact wire/server disk/concurrent-state or full feature admission claim.
  Landing blocker/ownership: Actual normal-hook task collection12584656 exceeds unchanged12582912 cap. Attempt stopped143 after recorded rejection; remaining checks get no passing credit. Preserve all rejected input bytes, shorten only this new narrative with acceptance fields intact, and verify the unchanged cap. Earlier diagnostic setup used an unlisted readonly helper operation; rejected source retained and direct Git fixes setup. Existing20.2 explicitly activates before further growth on this trigger; it now precedes Rust73.2, peers/copy73.6 and growth8. No cap increase, dropped obligation or immutable edit.
  Verification: Corrected custody/source review, original-claim preservation, scoped claims, task contracts/history/map/memory/book and complete normal hooks govern landing. narrative_boundary.py retains rejected/current collections and rejects missing-input/lost-acceptance controls. Detailed first failed object reviewer and actual overlap diagnosis remain retained. No new push/full CI for this evidence-only leaf; later maintenance stays local until a future canonical push.
  Commit: TYPE-REFERENCE-BOOK.1.2.23.4.7 — preserve publication source and logical object custody

- ID: `TYPE-REFERENCE-BOOK.1.2.23.4.8`
  Status: `completed` / bounded assessment and outgoing-scope correction; normal hooks govern landing
  Goal: Assess future retained-artifact growth against GitHub guidance without losing evidence or rewriting accepted history.
  Trigger/evidence: Actual accepted batch10 warns that docs/checkpoints/signed-array-contract-admission/import-epoch-before.json.gz is50.86MB, above GitHub's50MB recommendation. The initial outgoing thin-pack diagnostic is about9.3GB; that is not the server repository on-disk size. GitHub repository-limits guidance recommends10GB on disk and separately labels per-push/object enforcement. Retain the actual warning and primary-source pointers in the6 checkpoint;7 owns transport input custody.
  Priority/schedule: P1 after already selected Rust Count73.2, peers and copy73.6, before unrelated selection. This advisory review does not retroactively invalidate the accepted publication.
  Acceptance: Use committed Git/public host contracts to separate future artifact growth, original pack estimates, actual object sizes and unknown server storage. Prepare bounded lossless prevention options and their producer/reader/claim implications, with a concrete recommendation. Preserve exact historical blobs/IDs, package stores and proof; no blanket cleanup, force push, history rewrite, other-repository write or off-volume migration. Obtain a director decision only for a concrete change that needs authority outside the existing contract. Own any demonstrated defect through verified repair.
  Verification tier: `focused`
  Focused checks: Named committed blob/header/body size comparison, retained accepted-warning extraction, local count-objects snapshot, scope/threshold distinguishing controls, retained public host contracts and bounded prevention-options review; book/Knowledge/history/memory/normal hooks. No full object census or repack. Actual validator check_selected_claims.py passes the three affected records; preserve_claim.py/preserve_publication_claim.py and the bounded current restoration/publication readers pass.
  Canonical trigger: Separate infrastructure/publication repair or final clean push; this assessment changes no mechanical contract.
  Claim verification: `docs/claims/TYPE-REFERENCE-BOOK.1.2.23.4.8.json`
  Activation: Cleaneda3c81fe6ca9264f0ba96f3f90525d96d79626c after formatting73.8 passes all10 doctrines/post-pointer; brief0 and clean Git. Existing publication-custody4.7 and retained chunked-archive profile, ADR0139 and book maintenance section recovered before deriving new facts. Review preserves all historical objects, package stores, proof and external/submodule boundaries.
  Result: Named historical blob metadata agrees with its complete streamed body count and recomputed Git address/SHA256 at53325495 bytes; retained accepted batch10 warning stays exact. Local size-pack10630033KiB is a dated local field, not total Git-directory/server/wire storage; physical layout can change. Five effective object/warning/unit/scope/history-bound controls reject; capture and separate readonly replay pass. Current primary Git/GitHub contracts and concrete producer/reader/claim implications are retained in docs/checkpoints/artifact-growth-2026-11-05/PLAN.md with the actual observation and producer. Recommend prospective exact Git-input reuse plus the already admitted bounded payload/archive profile; historical objects/claims/caches stay. LFS/releases/external payload authority remains unselected and would need explicit new authority. No new storage contract, measured savings, remote-size/supportability, full custody/admission or publication claim. Adoption12 is scheduled after current feature coverage and before the next new large-payload publication; remaining-feature selection23.1.35 is next.
  Landing correction: The first normal hook rejects diagnostics chapter2064/2048 lines. Route its new explanation to the complete canonical PLAN and keep only a concise book pointer under the unchanged limit. The rejected invocation is stopped; its interrupted remaining checks receive no credit. Future adoption uses sibling4.12 so completed assessment4.8 remains a leaf; the discarded uncommitted child draft was never a published ID. Rerun all normal hooks after correction.
  Director correction: The prior chat finding emphasized whole-store10.14GiB without the current outgoing context. Fixed local4683555e..eda3c81 is15 commits; director reports about11.5MB outgoing. Public Git shows the historical warned blob already at both tips with the same identity. Retain the original observation, add outgoing-scope.json/review_outgoing.py and three effective count/blob/scope corruptions; clarify the PLAN/facts/claim and withdraw any implication of a current oversized push. No new pack generation or independent11.5MB measurement is claimed. This correction does not authorize restarting the RAM-blocked hook.
  RAM blocker: A transient host VM observation crossed the director86% threshold. Stop only the own remaining commit/check tree; no interrupted claim-check credit. The later pre-stop snapshot in docs/checkpoints/artifact-growth-2026-11-05/ram-stop.json is lower, and post-stop usage remains above the80% restart target. Quiet-window confirmation requested for20 minutes, starting after confirmation, host<=80% and other large jobs held. All code/docs/claim inputs and focused checks are ready; rerun the complete normal hooks only after confirmed readiness. This blocks landing4.8 and activation35; no other repository process was stopped.
  RAM resume: Director says try now. Fresh host query confirms24GiB total and about54% estimated use; recheck before starting and monitor during the one normal hook run. The earlier interruption and its actual lower pre-stop capture remain retained. No passing credit is inherited from interrupted runs; this complete corrected candidate must pass every normal hook. Release the requested quiet window when this commit verification finishes.
  Claim-input repair: The complete retry passes9 doctrines then rejects the changed diagnostics chapter bound by4.3 historical-restoration-and-live-count-boundaries. Enumerate every live changed-path intersection: only that claim and its dependent4.7 dated-publication-and-logical-object-custody need preservation. Existing fixed-Git procedure verifies all40/20 original input rows and full original record equality; only selected durability mode/revision change to clean eda3c81. Five effective field/hash/revision/population/unselected-claim corruptions per record reject. Current restoration reader retains original5 plus10 denials; default publication reader retains16 controls and does not rerun full bodies. New readers/results/claim preserve actual stale-book and changed-predecessor hash REDs. The dependent helper first has a malformed generated task namespace; failed source/setup note survive, no target was changed and no product RED credit follows. Corrected capture/replay pass. Historical close_claim remains tied to accepted input state.
  Director RAM update: Stable high-80s use is allowed; observe the trend rather than stopping at86/88. Reduce or stop only own jobs if usage keeps rising toward90%;90 remains the ceiling. This supersedes the earlier operational stop threshold for ongoing PNT and is retained in the handoff.
  Commit: TYPE-REFERENCE-BOOK.1.2.23.4.8 — assess retained artifact growth and preserve evidence

- ID: `TYPE-REFERENCE-BOOK.1.2.23.4.12`
  Status: `pending` / prospective proof-input reuse; scheduled after feature coverage, before next new large-payload publication
  Goal: Admit a first bounded proof-input producer/reader that reuses exact retained Git inputs and existing content-addressed payload/chunk semantics.
  Dependencies: Completed growth assessment4.8/PLAN.md, existing REPO-HYGIENE.23 archive profile, public Git APIs and current claim/input custody authority.
  Acceptance: Select one actual producer and retain the inputs it consumes before first execution. Reference an ancestor object only after comparing actual consumed bytes; preserve genuinely new dirty/generated/untracked payloads. Consumer must recover every declared byte, mode and required identity on this volume from retained full history/payloads. Reject wrong revision/body, missing payload and changed byte; prove actual first consumer uses recovered inputs. Preserve old physical bindings/claims/objects and all locality/black-box boundaries. Establish measured savings independently before publishing any; complete native/transitive custody4.2 remains separate. Split a new mechanical contract before implementation and use its canonical boundary; do not introduce external storage or history rewriting.
  Planned verification: Focused selected producer/consumer proof, corruptions and current claim compatibility; canonical if a storage/infrastructure contract changes and at final publication.
  Planned claim verification: none: Unactivated producer admission; declare actual recovery/savings scope and retained inputs on activation.


- ID: `TYPE-REFERENCE-BOOK.1.2.23.4.13`
  Status: `completed` / bounded retention-only daily artifact review
  Goal: Review the named LinkedSpec artifact scopes and refresh the latest-only cleanup record after the November5 boundary.
  Acceptance: Reuse the canonical non-following scanner and independent scandir/lstat for root-level strays, six named Rust release/incremental/deps locations and retained logs; verify the configured Cargo target is covered. Retain Dart/Julia caches and Lua managed-run conventions, active output/proof and all other repositories. Delete only exact provably disposable artifacts, otherwise record retention without liveness/disposability/reclamation inference. Keep previous observations/claims immutable, retain actual direct producers/Git-index input and effective corruption controls, then commit before domain75.0.2.
  Priority/schedule: Next clean boundary after typed-source75.0.1; November5T04:49:48Z is now over24h old. Return immediately to P1 domain75.0.2 afterward; no dirty pivot or dependency implementation access.
  Verification tier: `focused`
  Focused checks: Bounded existing scanner/independent per-file metadata and retained-snapshot corruption controls; separate readonly replay, selected claim/source identities, book render, memory/history/task/Knowledge integrity and normal hooks. No broad runtime suite.
  Canonical trigger: Final clean push; no production/storage-default/hook/CI contract changes in this dated maintenance leaf.
  Claim verification: `docs/claims/TYPE-REFERENCE-BOOK.1.2.23.4.13.json`
  Activation: Clean856a9c2d4df577f5b2980434434f43148e1e22bb, typed-source75.0.1 all ten doctrines/post-pointer/brief0/clean Git. Read last cleanup November5 04:49, canonical cleanup boundary, previous review/claim/scanner and book maintenance record. New namespace4.13 is unused. Metadata alone gives no deletion authority; retain protected caches/proof and preserve source/domain repair priority.
  Result: New dated observation2026-11-06T05:15:49.166118+00:00 retains1043 primary per-file path/suffix/byte rows, all matching independent scandir/lstat in eight named scopes. Configured Cargo target rust/target is covered. Five actual missing-row/wrong-size/duplicate-row/outside-path/producer-byte controls reject; separate readonly replay passes with empty stderr. No files removed and no ownership/liveness/disposability/reclamation inference. Direct producer bodies and Git-index input survive in docs/checkpoints/artifact-review-2026-11-06/observation.json.gz; previous observations/claims untouched.
  Documentation/verification: Latest-only cleanup date, book maintenance example and existing cleanup fact agree. Source/book/card/cleanup record have no live-claim input intersections; selected three-leg claim binds actual direct producers/retained inputs. Readonly source/claim identities, book render, history/memory/task/map and normal mandatory doctrines govern focused landing. No runtime/storage-default/hook/CI change, broad suite or push; immediately resume P1 domain75.0.2.
  Commit: TYPE-REFERENCE-BOOK.1.2.23.4.13 — retain artifacts after bounded daily review.


- ID: `TYPE-REFERENCE-BOOK.1.2.23.1.35`
  Status: `completed` / finite Length74 frozen; key-count75 P1 owned
  Goal: Select and freeze one next roadmap-required fluent source/consumer family from the current inventory and remaining gap matrix.
  Dependencies: Completed Count73/P1 source-copy repairs/P2 compiler/P3 formatting and advisory4.8; existing23.1 inventory, source roles and current contracts.
  Acceptance: Recover the next actually open capability before defining a finite target; distinguish existing supported behavior from new authority, signatures, kinds, effects, errors, copy/alias and excluded contexts. Independently assess each backend through public diagnostics before attributing a defect; preserve existing ready/raw/domain controls and actual first-execution inputs. Create bounded backend children before implementation. No broad suite/admission, invented population count, unsupported context promotion, dependency internals or change of language authority.
  Verification tier: `focused`
  Focused checks: Minimum authored public Get/descriptor/substitution/emission/native-fresh controls for ordinary Length/key-count sources, existing contract and preservation distinctions; freeze only an observed next gap. No broad suite/matrix. Book/Knowledge/history/memory/diff and normal hooks govern landing.
  Canonical trigger: Full source/domain/context/portable admission23.4 and final clean push after scheduled prerequisites; no new public authority in this selection.
  Claim verification: none: Finite authored selection and preservation controls; no method/backend/population, performance or full-custody measurement.
  Activation: Cleanf6295bc8fc76e7c6049f28397049f527fe8133d7 after4.8 all10 doctrines/post-pointer, brief0 and clean Git. Existing count/length3, scalar String19/free62 exclusions, helper inventory/catalog and terse-array fact recover current compatible Number/null flow before probes. Candidate Length and key-count source guards must be independently observed, not inferred from Count73. Director allows stable high-80s host RAM; watch trend and intervene toward90% ceiling, only own jobs. First acquisition retains declared own-source inputs; native/transitive custody4.2 remains separate.


  Result: Public Length native/fresh diagnostics freeze shared16: nine healthy preservation programs/seven target gaps, all ready/raw0/fallback0/unresolved0/warning-free. Wrong consumers and later with/copy/logical effects expose missing source-role guards, not numeric producer failure. Exact Count/compatible-prefix contrasts localize MethodLowering source admission. Corrected main::4 seed exposes actual emitted host contamination; original outer seed was ineffective and its cause is verified through retained public substitution/actual module. Key-count has two independent Perl gaps and healthy compatible control, owned P1 family75 after74.5 before unrelated selection. No peer failure inferred.
  Evidence/limits: docs/checkpoints/length-selection-2026-11-05/REVIEW.md and readonly review.py retain original raw channels, source snapshots and actual supplemental modules before fresh load. Expected-error Trace stdout defeated outer JSON-only summary after capture; recovery and three corruptions pass without rerunning behavior. Physical historical argv/headers remain opaque compressed provenance; reader maps logical relative paths. No native/transitive closure, independent isolation, population or full admission claim. Frozen target: length-result-guard-composition.md; tests/fixtures/length_result_guard_cases.json. No production change.
  Verification: Readonly exact19-row recovery, three effective corruptions, public substitution/full-module empty/outer/main seed distinctions, observer syntax and book render; Knowledge/history/memory/diff and normal hooks govern landing. Next Perl74.1 before peers/key-count75.0.
  Commit: TYPE-REFERENCE-BOOK.1.2.23.1.35 — freeze Length source guards and own key-count gaps.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.1.36`
  Status: `completed`
  Goal: Select and freeze the next actually open roadmap-required fluent source/consumer family after bounded Length74/CountKeys75 coverage.
  Dependencies: Focused ordinary75.1-.5/peer75.7 and callable75.6 backend outcomes; current23.1 inventory/gap matrix/contracts/Knowledge. Full23.4 remains separate.
  Acceptance: Recover actual remaining feature requirements and canonical source roles before probing. Select at most one finite existing-contract gap using minimum full-source public Get/descriptor/substitution/emitted native-fresh controls. Preserve source domains, signatures, actual kinds, ordered effects/errors, copy/alias and named excluded contexts. Retain actual first inputs/producer/modules/full channels; distinguish healthy behavior from a demonstrated defect, assess peers independently and create bounded backend leaves before production edits. No broad census/suite/admission, unsupported context promotion, invented population claim or dependency-internal inspection.
  Planned verification: Small public selection and direct-preservation controls, syntax/book/Knowledge/history/memory/diff and normal hooks; full verification after feature coverage.
  Planned claim verification: none: Finite authored selection controls; separate any actual population or performance measurement.

  Activation: Clean659a1ecccdc0467951f529a8fa9add5e9f05e510 after installed Lua75.6.5 all10 doctrines/post-pointer/brief0/clean Git. Canonical helper spelling spine, constructor61 typed result guards, Hash-view and sorted-values scalar-host facts recovered. First bounded candidate is ordinary sorted_keys/sorted_values Array result composition; use existing compatible/constructor-copy oracles and preserve producer/source/arity policies. No implementation verdict before actual full-source public observations.
  Verification tier: `focused`
  Focused checks: Finite authored public Get/descriptor/substitution/full emitted native-fresh selection and preservation controls; instrument syntax, book/Knowledge/history/memory and normal doctrines. No broad suite or implementation in this selection.
  Canonical trigger: Full23.4/final clean push after coverage; new public authority or mechanical changes require a separate owner before implementation.
  Claim verification: none: Finite authored selection/preservation controls, no complete method/backend/context/population or performance measurement.
  Continuity repair: Add36 to its parent's Children list and refresh helpers.md's stale75.0 frontier before acquisition. Source-role selection may retain healthy candidates; no defect or next family is inferred from a name list.
  Actual first intake: Hash-view16 retained at docs/checkpoints/hash-view-selection-2026-11-06/intake. Compatible values/bridges/nested kinds/source snapshot/empty-with stay healthy; free wrong-Hash consumers runtime-fail, literal-receiver counterparts retain raw DSL and compile-fail despite ready/raw0 descriptors. Separate constructor/copy oracle is [null,"ran","X"]: constructor rejection is retained, but direct free-copy rejection is reduced to ordinary null before with. Do not normalize this control or infer a peer defect. Own P1 copy prerequisite76.0 before Hash-view repair; preserve actual original16 and qualify a separate minimal copy/null discriminator before freeze.
  Qualified outcome: Original16 source controls retain seven view failures, seven healthy programs (including needed error), one independently discovered copy-oracle failure and one nonadmitted arity profile. Separate copy6 at identical declared runtime inputs qualifies three healthy/three failing native-fresh programs; no peer verdict. Shared views15 is original14 plus a qualified constructor control, not one original15 execution. View family76 and Perl copy P176.0 are scheduled before unrelated selection/admission; no production edit in selection.
  Instrument qualification: Original readonly review.py reaches its first corrupted-error-object control then raises unhandled TypeError; full original source and actual failed channels remain immutable. Separate review_qualified.py adds one typed-object assertion and binds its actual producer/input bytes. Qualified recovery/eight effective corruptions PASS with empty own stderr. Surrounding qualifier-wrapper setpgid EPERM is tool-observed, not separately raw-acquired; SESSION7 retains that lifecycle boundary. No product RED credit or native rerun for reviewer correction.
  Verification: Actual public Get/descriptor/substitution/full modules/handlers/native-fresh, exact activation source/input byte identities, original16/copy6/source-preserving fixture projection, eight corruptions and observer syntax; book/map/history/memory/diff and mandatory normal hooks govern landing. Actual evidence/limits: docs/checkpoints/hash-view-selection-2026-11-06/REVIEW.md. Original runtime errors/ready0 arity profile remain intact; no complete source/context/host isolation or native/transitive closure.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.1.36 - freeze Hash-view guards and own copy rejection prerequisite`.
  Next: Commit selection36, then P1 Perl76.0 before view76.1 and independent peers; full verification after feature coverage.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.1.37`
  Status: `completed` / finite original selection frozen; bounded77 outcomes focused-checked, full23.4 separate
  Goal: Select and freeze the next actually open roadmap-required fluent source/consumer family after bounded Hash-view76 coverage.
  Dependencies: Focused76.0-.6/backend and initial-source outcomes; current23.1 inventory/gap matrix/contracts/Knowledge. Full23.4 remains separate.
  Acceptance: Recover actual remaining requirements and canonical source roles before probing. Select at most one finite existing-contract gap with minimal full-source public Get/descriptor/substitution/emitted native-fresh controls. Preserve source domains/signatures/actual kinds/ordered effects/errors/copy/alias and excluded contexts. Retain actual first inputs/producers/modules/full channels, distinguish healthy preservation from demonstrated defects, independently assess peers and create bounded backend leaves before production. No broad census/suite/admission, unsupported-context promotion, invented population claim or dependency-internal inspection.
  Planned verification: Small public selection/direct-preservation controls, syntax/book/Knowledge/history/memory/diff and normal hooks; full verification after feature coverage.
  Planned claim verification: none: Finite authored selection controls; separately own any population/performance measurement.
  Frontier: Activate only from clean Git after installed Lua76.5 normal-hook landing/brief0. No next family or defect is inferred merely from method names; use current requirements and canonical contracts.

  Activation: Clean795e8c1ade747d12a1c1e304ddf144a9372eea2e after installed Lua76.5 all10/post-pointer/brief0/clean Git. Read current helper spelling/role spine, roadmap comprehensive fluent requirement, helper catalog Hash-valued signatures and preserved key/collision/source-copy facts. Candidate assessment is ordinary documented Hash-valued pure helper results (merge_hash/set_key/rename_key/drop_keys/pick_keys); flat_hash is a list-splice role and remains excluded. This is a hypothesis/remaining coverage boundary, not a defect verdict. Preserve set_key statement/operator mutation, key-list/splice/collision/source-domain/arity policies; acquire actual public full-source controls before deciding any scope or implementation.
  Verification tier: `focused`
  Focused checks: One finite authored public Get/descriptor/substitution/native-fresh selection with actual inputs/modules/full channels and source/shape/error preservation controls; source/instrument syntax, readonly recovery/distinguishing corruptions, book/Knowledge/history/memory/diff and mandatory hooks. No broad census/suite.
  Canonical trigger: Full23.4/final clean push after feature coverage; new public authority or infrastructure requires a separately owned canonical leaf.
  Claim verification: none: Finite authored candidate/preservation controls, no complete method/domain/context/backend or performance measurement.

  Actual first intake: docs/checkpoints/hash-value-result-selection-2026-11-07/intake retains32 unchanged public Perl programs/modules/handlers. Twenty-eight are ready/raw0/fallback0/unresolved0; fifteen fail the candidate contract and thirteen preserve healthy values/required producer errors. Five free wrong-Array consumers return[] instead of null; five literal receivers retain raw DSL and native/fresh compile-fail; three later with/copy/logical programs run W/D; two composed needed-error programs compile-fail instead of reaching the terminal producer's binding error. Constructor Hash-to-Array oracle returnsnull/skips A/W. Four zero-key drop/pick forms are unready with unresolved helper1 and remain nonadmitted profiles. All original raw epochs stay unchanged; no peer verdict or production edit.
  Tool mechanism: Actual substitution for free pick_keys includes take's legacy nonarray[] fallback; its receiver counterpart contains literal DSL, as do composed needed-source/value forms. Same constructor consumer uses the existing retained-result rejection marker and returnsundef before later with. MethodLowering.pm's ordinary free/prefix/result-chain classifications and retained/copy/with paths include constructors/views but omit these Hash-valued pure helpers. Freeze only this existing-contract family after readonly recovery; new backend children must preserve each own initial-source/arity/error/producer policies before edits.

  Outcome: Exact eligible28 unchanged-source fixture freezes original15 failures/13 healthy controls; four unready zero-key forms retain full independent Perl profiles. First readonly recovery0/empty stderr and eight effective corruption controls PASS;32 actual module/handler pairs and original input modes/hashes/channels retained. No SDK production edit or peer verdict. docs/checkpoints/hash-value-result-selection-2026-11-07/REVIEW.md owns scope and the frozen first contract's backlog-name erratum; actual collision owner is FUTURE-PARITY-BACKLOG.5.
  Next ownership: Family77 and pending Perl77.1/Rust77.2/Dart77.3/Julia77.4/installed Lua77.5 are defined before production. Each first captures its own initial Number/null/Array/arity/key-list/needed-error policies and actual unchanged28 baseline; only demonstrated composition gaps may change. Full23.4 remains separate.
  Scope continuity: Pre-stage scope refresh rejected a successor active_work_unit. Apply existing docs/knowledge/reference-scope-selected-owner.md: completed37 stays active through landing, next_action alone names77.1. No scope/gate implementation change.
  Hook format repair: First normal attempt rejects TASK-ACCEPTANCE because two new checked evidence lines use the forbidden word for future work. Existing task-acceptance-evidence-gate-boundary card explains the whole-file predicate. Keep open runtime statuses in their nodes and move that wording off checked lines; checker unchanged. Stop only the verified already-failed own commit process chain (tool exit143, HEAD unchanged), then rerun normal hooks. Retained event note distinguishes tool-result transcription from a full raw hook log.
  Continuity correction: Parent23.3 Children omitted already defined74/75/76; add them and new77 in the current owning planning slice. Existing child statuses/verification authority stay exact; no implementation or gate change.
  Commit: TYPE-REFERENCE-BOOK.1.2.23.1.37 — freeze Hash-valued helper result guard targets.

  Acceptance Checklist
  - [x] **REPRODUCE / ISSUE** — original32 public native/fresh intake distinguishes15 eligible defects,13 healthy controls and4 unready profiles.
  - [x] **ROOT CAUSE (WHY + WHERE)** — public substitution/actual artifacts show legacy take fallback/raw DSL; own result/source/prefix classifications omit these pure Hash roles.
  - [x] **FIX** — freeze unchanged28 and source-policy prerequisite; schedule independent bounded77 children before production. Runtime repairs remain separately owned; no runtime completion is claimed here.
  - [x] **ADDRESSED (verified)** — first readonly recovery/all eight corruptions and smallest instrument/task/book/Knowledge/history/memory checks pass.
  - [x] **NO REGRESSION** — no SDK/grammar/dependency edit, signature/source/collision/mutation authority or peer verdict.
  - [x] **LOCKSTEP** — tasks/index, helper spine, public catalog/handoff, Knowledge and continuity agree on independent77.1 next.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.4.9`
  Status: `completed` / director-requested clean pause
  Goal: Finish the current verified unit and save a committed, idle handoff at the director's next-checkpoint pause request.
  Acceptance: Preserve completed canonical/normal-hook outcomes and the actual publication rejection; record exact local and remote boundaries, a scheduled recovery owner and an explicit-resume requirement. Update task/roadmap/live/MEMORY and the book handoff explanation. Commit through normal focused hooks, clear the brief, confirm clean Git and no required job, then stop before Rust Count73.2.
  Verification tier: `focused`
  Focused checks: Exact Git/receipt and retained operational log pointers; task/index, memory/handoff, history pressure, reference scope, mdBook rendering, diff and all mandatory doctrines.
  Canonical trigger: No new infrastructure or runtime change; any later push requires canonical proof for its exact HEAD.
  Claim verification: none: Director steering and operational event bookkeeping only; no new population, performance or feature-correctness measurement.
  Activation: Clean5801970b4d311e97b5764d16a2573a4094144e49 after canonical PASS and all normal hooks; brief empty. The normal push reused its exact receipt but GitHub rejected main with fatal error in commit_refs. Independent API read-back remains at d3a26a94f5c2efba736806ac13911155e3739995. GitHub reports an active Git Operations incident; this is consistent with the rejection, not a demonstrated exact server root cause. A subsequent SSH read also returned publickey denial while authenticated API reads succeeded. Preserve both observations without inferring a size rejection or changing authentication/configuration.
  Recovery: New23.4.10 owns publication recovery on explicit resume, before Rust73.2. Do not wait indefinitely on the host incident or start another feature during this pause handoff.
  Evidence: docs/checkpoints/pause-handoff-2026-11-04/ retains actual successful commit log, exact5801970b canonical receipt, rejected push log, acquisition source and raw host/ref/workflow responses. The manual workflow is registered active but remains push-disabled/job-guarded under ADR0004; no automatic hosted proof is inferred.
  Handoff: MEMORY is idle and explicitly paused;4.10 is first only on explicit resume. The later focused pause commit has no inherited exact-HEAD canonical receipt. Normal hooks/brief clearing/clean Git finish this unit; no background verification or automatic retry remains required for this pause.
  Commit: TYPE-REFERENCE-BOOK.1.2.23.4.9 — record director pause and publication recovery

  Acceptance Checklist
  - [x] **REPRODUCE / ISSUE** — retain actual normal push rejection and independent unchanged API main ref; director requests a clean pause.
  - [x] **ROOT CAUSE (WHY + WHERE)** — GitHub reports a contemporaneous Git Operations incident; exact server cause and separate SSH denial remain explicitly unconfirmed and4.10-owned.
  - [x] **FIX** — commit idle pause steering and operational custody, schedule recovery before feature selection; no speculative code/authentication repair.
  - [x] **ADDRESSED (verified)** — focused pointer/task/index/history/scope checks and mdBook rendering validate the handoff; normal hooks govern landing.
  - [x] **NO REGRESSION** — runtime, infrastructure, historical evidence and dependency boundaries are unchanged; publication still requires exact current canonical proof.
  - [x] **LOCKSTEP** — task/root/index, roadmap, live/MEMORY, change/engineering notes and book agree on explicit-resume-only steering.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.4.10`
  Status: `completed` / committed checkpoint published through4683555e; later outcome record uses its next normal publication boundary
  Priority/schedule: P1 first on explicit director resume, before Rust Count73.2, peers/P1 copy73.6 and growth8.
  Goal: Publish the committed post-backlog work after the GitHub rejection without rewriting history or bypassing verification.
  Reproduction/impact: At the November4 failure, normal exact-receipt main push from5801970b4 returned remote fatal error in commit_refs and the API still named d3a26a94f5c2. A later SSH read returned publickey denial. The contemporaneous host incident smtdswd1h2w4 affected Git Operations; the repository-specific cause remains unconfirmed. Maintenance/infrastructure work then remained safely committed locally. The completed recovery outcome is recorded below.
  Acceptance: Read retained23.4.9 operational records and fresh host/ref state. Resolve SSH access if it remains unavailable; use only authorized published authentication paths. Run canonical CI for the exact final clean HEAD, push with normal hooks and no force/submodule recursion, confirm fresh local/origin/API identities and hosted status. Retain any repeated error and investigate its actual cause; do not assume a pack-size problem or change repository policy from the generic error. Stop for specific missing authority/access only when necessary.
  Children: `TYPE-REFERENCE-BOOK.1.2.23.4.10.1`, `TYPE-REFERENCE-BOOK.1.2.23.4.10.2`.
  Planned tier: Ordinary operational records use focused proof; exact clean publication requires canonical CI and normal pre-push hooks. Runtime feature work follows successful recovery.
  Claim verification: none: Parent operational tracking; child records preserve dated external events without a population or runtime-admission claim.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.4.10.1`
  Status: `completed` / recovered access checkpoint; publication follows
  Goal: Record the explicit PNT resume and fresh host/SSH/API access before exact clean publication.
  Acceptance: Preserve fresh acquisition commands and dated responses; compare independent SSH/API main identities, retain previous failures, update the paused pointers and commit this bounded checkpoint. Do not change authentication/configuration or infer the earlier server root cause from recovery.
  Verification tier: `focused`
  Focused checks: Read retained pause events, fresh official host/SSH/API responses, policy hash comparisons, task/index and memory/handoff checks, history pressure, reference scope, mdBook build and normal doctrines/hooks.
  Canonical trigger: This documentation-only checkpoint makes no infrastructure or runtime change; the following clean publication operation requires exact committed HEAD canonical proof.
  Claim verification: none: Director steering and dated external operational events only; no measured population, performance or feature-correctness claim.
  Activation: Clean4df2a8cfe468c46fe269e957193765a53603a16f; director explicitly resumes full PNT. Last cleanup remains within24h. All three supplied policy hashes match recorded startup/ADR0126 review.
  Result: Fresh official Git Operations status is operational; approved-host SSH/API main both name d3a26a94f5c2. Restricted reads failed DNS/network access, not a demonstrated authentication regression. No key/remote/config change. Source and responses: docs/checkpoints/publication-recovery-2026-11-05/. Earlier rejection remains retained and unattributed. Focused task/index, memory, history, book/reference scope and normal doctrines govern landing; exact clean publication10.2 remains required.
  Commit: TYPE-REFERENCE-BOOK.1.2.23.4.10.1 — resume and checkpoint recovered publication access

- ID: `TYPE-REFERENCE-BOOK.1.2.23.4.10.2`
  Status: `completed` / exact canonical checkpoint published and independently read back
  Goal: Publish the recovered clean checkpoint with exact canonical proof, normal hooks and independent remote read-back; retain the actual outcome before Rust Count73.2.
  Acceptance: Run canonical CI in approved host execution for the exact clean committed HEAD; push fast-forward main without force, tags or submodule recursion. Confirm local/origin/API main identities and hosted workflow status. Commit the operational outcome with focused integrity checks; that later record has no inherited exact-HEAD receipt and is published at the next normal canonical boundary. Repeated errors require retained diagnosis and explicit unblock ownership before feature work.
  Verification tier: `focused`
  Focused checks: Actual canonical completion/receipt and normal push log, independent SSH/API/local-origin refs and hosted workflow response; task/index, memory/handoff, histories, Knowledge/reference scope, book rendering, diff and all mandatory hooks.
  Canonical trigger: Exact clean4683555ec51f04b8977812ce4e984c5cc6e6f42c passed default canonical CI before actual publication. This later operational record changes no infrastructure or runtime; its own later publication needs fresh exact-HEAD proof.
  Claim verification: none: Dated publication/verification event bookkeeping only; no feature admission, performance or population measurement.
  Activation: Clean4683555ec51f04b8977812ce4e984c5cc6e6f42c after10.1 normal hooks and brief0. Approved-host default canonical CI exits0 and writes a committed exact-HEAD receipt. Normal push reuses it, exits0 and advances main fromd3a26a94 to4683555e. Prior host rejection/publickey causes remain unconfirmed; no authentication or history rewrite.
  Result: Local/origin/SSH/API main agree on4683555e; hosted runs are empty under ADR0004 and fresh Git Operations status is operational. Actual acquisition source, dated responses, byte-exact compressed gate/push logs and exact receipt are retained in docs/checkpoints/publication-recovery-2026-11-05/. An early check before receipt finalization rejected; the completed gate and fresh check subsequently pass before the push. This later operational record is local until its own normal canonical publication boundary. Full23.4 and independent prerequisites remain open; Rust73.2 is next.
  Verification: Fresh identity comparisons and retained-log byte equality, receipt check, task/index, memory, histories, Knowledge/reference scope, book rendering and normal mandatory hooks govern this focused record. No second full gate for this ordinary outcome record.
  Commit: TYPE-REFERENCE-BOOK.1.2.23.4.10.2 — record verified publication recovery

- ID: `TYPE-REFERENCE-BOOK.1.2.23.4.11`
  Status: `completed` / bounded retention-only daily artifact review
  Goal: Review named LinkedSpec artifact scopes after the November4 boundary and refresh the latest-only cleanup record.
  Acceptance: Use the canonical non-following scanner and independent per-file metadata on root-level strays, six named Rust locations and retained logs. Preserve caches, active output, proof and every other repository. Delete only exact artifacts proven disposable, or record retention when metadata grants no disposal authority. Retain direct producers/inputs, effective corruption controls and dated observation; commit before Julia73.4.
  Priority/schedule: Next clean activation after Dart73.3; November4T04:26:54Z is over24h old. No dirty pivot or dependency implementation access.
  Verification tier: `focused`
  Focused checks: Bounded existing scanner/independent metadata and retained snapshot controls; readonly replay, source/claim identities, book render, memory/history/task/Knowledge integrity and normal hooks. No broad runtime suite.
  Canonical trigger: Final clean push; no production/storage/hook/CI contract changes in this dated maintenance leaf.
  Claim verification: `docs/claims/TYPE-REFERENCE-BOOK.1.2.23.4.11.json`
  Activation: Clean553f9d1889f29eeae9f068359b6cba6848f8f7c5, Dart73.3 all ten doctrines/post-pointer pass and brief0. Canonical cleanup boundary, previous review producer/claim, book maintenance policy and retained-cache conventions reviewed. Metadata does not establish ownership/disposability/liveness; no removal is selected.
  Result: All977 retained per-file path/suffix/byte rows match independent metadata in eight named scopes. Five actual missing-row/wrong-size/duplicate-row/outside-path/producer-byte controls reject; separate readonly replay passes. Nothing was removed; no disposability/liveness/reclamation inference follows. Direct producer bodies and Git-index input survive in docs/checkpoints/artifact-review-2026-11-05/observation.json.gz; actual acquisition/replay results and three-leg claim are retained. Earlier review/publication evidence stays immutable.
  Documentation/verification: Latest-only cleanup date, book maintenance example, existing cleanup fact and live/resume pointers agree. Edited maintenance/book/card surfaces have no current live-claim input intersection. Readonly source/claim identities, book render, history/memory/task/map and normal mandatory doctrines govern this focused landing; Julia73.4 resumes next. No runtime or infrastructure change, broad suite or push.
  Commit: TYPE-REFERENCE-BOOK.1.2.23.4.11 — retain artifacts after bounded daily review

- ID: `TYPE-REFERENCE-BOOK.1.2.23.4.14`
  Status: `completed` / RAM/source-stage prerequisites focused-verified; exact canonical receipt governs landing
  Goal: Make RAM host-size acquisition correct under restricted macOS access, reconcile current trend policy, and close bounded historical-source prerequisites exposed by its mandatory canonical gate.
  Priority/schedule: Own now from Rust75.6.2 preflight; repair after agreed callable feature coverage and before using ram_guard for full verification/push. Current product work uses separately verified host size, conservative workers and live observation; no actual pressure blocker.
  Reproduction/root cause: Default managed-shell sysctl -n hw.memsize returns Operation not permitted. memory_pressure -Q independently identifies the24GiB host, matching the director. tools/ram_guard.sh _used_pct falls back to17179869184 bytes (16GiB) on the denied query, underestimating the used percentage for this host. Its three vm_stat calls also are separate snapshots; assess the producer without normalizing this diagnostic into policy. shared-host-ram-budget still describes the older86/90 hard-threshold directive, while the director now permits stable high80s and asks intervention when above90 and still increasing. MEMORY already records the latest instruction.
  Impact: A restricted-shell preflight can report an inaccurate host-wide percentage and admit a job on that mistaken basis. Current Rust preflight derives actual total from memory_pressure and uses one vm_stat snapshot, with enough available memory; the Cargo wrapper does not invoke ram_guard. No other project's jobs may be stopped.
  Acceptance: Retain actual first producer/input/OS observations and distinguishing denial/success controls; derive actual host size or fail clearly rather than invent a fallback total; test the restricted-query case and accurate memory arithmetic; reconcile the latest director policy in the canonical card/docs without overwriting prior evidence; retain/update restricted-macos-ram-host-size-fallback, the discovery card added by Rust75.6.2, and reconcile the canonical RAM card. Keep same-volume logs and explicitly distinguish snapshot admission from live trend monitoring. Do not create an unsolicited quiet-window pause when headroom is adequate.
  Planned verification: Focused fake/actual denied-query and arithmetic controls, locality/syntax and canonical infrastructure admission when activated; live trend observation for own intensive jobs.
  Planned claim verification: none: Structural source-policy defect and exact named host capacity; retain a separate claim record if publishing new measurements.
  Verification tier: `canonical`
  Focused checks: Retained original-wrapper denial RED; deterministic capacity/query/snapshot/arithmetic and admission controls; real restricted-shell query and repaired preflight; shell syntax, locality, book, memory, history and normal hooks.
  Canonical trigger: This leaf changes shared RAM/preflight and canonical CI infrastructure; exact staged-candidate canonical receipt is required before commit. Feature admission/current discovery4.1 and raw-error4.28 remain separate before-push owners.
  Claim verification: `docs/claims/TYPE-REFERENCE-BOOK.1.2.23.4.14.json`
  Activation: Clean b370de8d31e3f38da6abf8ed4702a523aa3d6d97 after headroom32, all10/post-pointer/brief0/clean verified. Fresh committed monitor0 against cached origin4683555e is retained for publication preparation; no remote freshness or upload-size guarantee. Both affected producers and canonical RAM cards have been read. Preserve dated defect evidence and derive each Darwin availability result from one vm_stat snapshot. Default job admission is separate from director host-wide trend monitoring; no other project's jobs may be stopped.
  Binding prerequisite: Exact212-record query correctly exits1 for the live backend-task-evidence-path-scope claim4.3 bound to tools/run_ci_local.sh. Retain the original refusal and accepted records. Preserve only that claim durability mode/revision at activation b370, verifying every original input and unchanged other fields/claims before runner edits; no original hash or observation is refreshed.
  Focused qualification: Original native sysctl1/Operation not permitted and independent capacity query0 are retained before repair. Actual old-wrapper control1 observes25-percent/admitted child/three VM snapshots instead of the independently specified50-percent/refusal/single snapshot. First repaired controls0 are retained separately; their launcher did not freeze all changed tools before use, so do not credit original first-use custody. Capture their unchanged source images afterward, then use a new complete source-bound proof epoch. Also replace the initial harness's fixed repository scratch with validated managed LINKEDSPEC_RUN_DIR and register its exact entrypoint/temporary-owner population; existing212 accepted binding query plus the mode-only qualification finds no remaining live storage-registry binding before those edits.
  Acceptance Checklist
  - [x] **REPRODUCE / ISSUE** — Retained actual native sysctl1 and old-wrapper deterministic RED1: wrong25-percent/admitted child/three VM snapshots.
  - [x] **ROOT CAUSE (WHY + WHERE)** — Original tools/ram_guard.sh39 and tools/run_ci_local.sh1325 used17179869184 fallback and separate VM queries; exact original sources remain in before/.
  - [x] **FIX** — Shared tools/host_ram_usage.sh validates real capacity and one snapshot, refuses unavailable data and preserves admitted child exit/77 skip behavior; canonical CI uses the same producer.
  - [x] **ADDRESSED (verified)** — Source-bound finite controls0, actual native recorder0/independent arithmetic, historical review0/eight corruptions; full staged canonical receipt is mandatory before normal commit can land.
  - [x] **NO REGRESSION** — Success/fallback/invalid snapshot/rounding/Linux-simulated/child-exit controls pass; exact storage inventories and bash syntax/locality are selected, git diff --check and normal doctrines govern landing.
  - [x] **LOCKSTEP** — Current RAM cards/book, task/index, roadmaps/live/pointer and bounded histories carry the same qualified behavior; canonical and feature-admission boundaries stay distinct.
  Outcome: docs/checkpoints/ram-host-size-preflight-2026-11-12/REVIEW.md. Default review.py is historical. preserve_ci_claim.py default reviews original mode/revision-only preservation; current tool/candidate identities are separate point-in-time checks. Never replay one-shot capture/publish/seal producers.
  Verification boundary: Focused implementation proof is complete. This infrastructure commit requires the exact staged canonical receipt; the actual receipt/log, not this intended handoff text, establishes that gate. Current discovery4.1/raw-error4.28/declared5.4/formatter/full23.4 admission remain independent before-push owners. Fresh size then current discovery; the1.5GB trigger overrides cadence.
  Publication qualification: Original review_publication.py1 is retained: its short literal not-continuous phrase does not occur in the correctly negative full policy sentence. The qualified default gates the full sentence, preserves original source/failure/images, changes only that literal in an execution copy and adds three policy controls beside the four original publication controls. No producer, document or claim observation is rewritten.
  Owned P1 first canonical prerequisite (before image/audit changes): Approved-host canonical6889 exits1 after all10 doctrines and functional source/Knowledge/history controls pass. The isolated objective recovery refuses unreviewed current source image dart/lib/src/runtime/interpreter.dart at historical_objective_images.py84; no canonical receipt or full-pass credit. The existing three-objective-language-readiness contract requires reviewed exact later images and preserved predecessor oracles, not a wildcard/hash refresh. Retain the whole failed log and exact staged267-file candidate; inventory all effective image paths and the complete historical source population before selecting repairs. Own only demonstrated accepted-commit successor identities and exact inverses for this RAM CI/storage integration, preserving original tables, protected Phase0 calibration, old runtime results and every prior denial. Focused isolated recovery and distinguishing lineage/source/inverse controls must pass before a complete restaged canonical restart. No runtime implementation change is authorized by this prerequisite.
  Image inventory/root cause: Retained intake inventories all149 historical source paths and19 effective images; exactly four committed runtime images differ (Dart/Julia/Lua/Rust), all at acceptedb370 and following the existing7289836f successor layer. Every other current executable difference is covered by its prior inverse except this uncommitted RAM CI block. The additional prospective binding query finds no live helper/auditor/table/card intersection after the completed4.3 qualification. New actual nested-successor unit1 shows verification reaches the latest image but report() still names the intermediate image by reading raw successor rows/data. Fix that bounded report defect to use effective successor reports while retaining nested lineage; existing original three control groups remain unchanged and passed before this RED.

  Historical prerequisite outcome: Complete actual intake149/19 isolates four acceptedb370 runtime images and the RAM CI change; all other executable paths retain their registered inverses. No live prospective helper/auditor/table/card bindings. Nested-report original RED1/final unit0; new reports retain effective b370 and intermediate728 lineage. Original three image tables and protected Phase0 bytes remain exact. Current and prior19 source denials both pass. Two exact RAM CI hunks restore committedb370; old pure governance predicate is byte-exact apart from its name, and all714 original controls run at that precursor. New RAM CI nine controls remain separate. Actual isolated consumer0/empty stderr has210 declared/199 observed bodies inside213 before-use sources; every old recovery/control field matches. Independent historical review0/six corruptions and exact-population review0/three controls pass. Existing Phase0-value12 predicate is unchanged; no runtime SDK body, old observation/hash or broad feature admission changes. First full canonical1 has no receipt credit; complete new staged canonical is still required.
  Handoff order: After clean commit and fresh size, do focused raw-error4.28 before final current discovery4.1 so its added consumers can share the final canonical publication boundary. Both remain required before push; no owner is waived. Image-prerequisite/review.py and review_population.py are historical defaults; all old capture/publish/seal writers remain one-shot. Prior check_candidate.py is the first-attempt point-in-time check, not the new candidate check.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.4.15`
  Status: `completed` / bounded retention-only daily artifact review
  Goal: Complete the due November7 bounded daily artifact review and refresh the latest-only cleanup record before Dart77.3.
  Acceptance: Reuse the existing non-following scanner and separate scandir/lstat for root-level strays, six named root/crate Rust release/incremental/deps locations and retained logs; verify the configured Cargo target is covered. Preserve all other repositories/submodules, Dart/Julia caches, Lua managed-run conventions, active output and unresolved proof. Remove only exact provably disposable artifacts; otherwise retain them without ownership/liveness/disposability/reclamation claims. Retain actual direct producers/index input and five distinguishing corruptions, separate readonly replay and three-leg scoped claim; update book/Knowledge/live/task pointer and commit before returning to Dart.
  Priority/schedule: Immediate clean boundary after Rust77.2; November6T05:15:49Z record is more than24h old at November7 05:35UTC. No dirty pivot or dependency implementation access; no broad runtime suite.
  Verification tier: `focused`
  Focused checks: Existing bounded primary/independent metadata capture and five altered-evidence controls, separate readonly replay, three composition-template controls and selected source/claim identities; book render, history/memory/task/Knowledge/diff and normal mandatory hooks. No runtime/storage-default/hook/CI changes.
  Canonical trigger: Final clean push; dated maintenance does not change infrastructure or product behavior.
  Claim verification: `docs/claims/TYPE-REFERENCE-BOOK.1.2.23.4.15.json`
  Activation: Clean12cfcaa7ae01af8451fda2d9533ac612a08d7317 after Rust77.2 all10/post-pointer/brief0/clean Git. Read latest cleanup, existing cleanup Knowledge/card boundary, November6 actual reader/claim and maintenance book paragraph. New4.15 namespace is unused. Existing named-scope reader is reused without changing traversal policy; metadata alone gives no disposal authority. Check changed documentation surfaces against current live claim inputs before edits. Return directly to independent Dart77.3 after clean landing.

  Result: New dated observation2026-11-07T05:37:20.574917+00:00 retains1157 primary path/suffix/byte rows, all matching separate scandir/lstat in eight named scopes. Configured Cargo target rust/target is covered. Five actual missing-row/wrong-size/duplicate-row/outside-path/producer-byte controls reject; separate readonly replay returns0 with empty stderr. No removals or ownership/liveness/disposability/reclamation inference. Source/index packets and actual argv/cwd/exit/full compressed stdout/stderr survive in the new dated directory; previous observations/claims untouched.
  Documentation/verification: Latest-only cleanup record, current maintenance example and existing cleanup card agree. The changed documentation surfaces have no current live claim-input intersections. The scoped three-leg claim binds actual direct producers, outer channel instrument, record-composition producer and retained inputs. Book/history/memory/task/Knowledge/diff and normal hooks govern focused landing; no runtime/storage-default/hook/CI change, broad suite or push. Return immediately to independent Dart77.3.
  Commit: TYPE-REFERENCE-BOOK.1.2.23.4.15 — retain artifacts after bounded daily review.

  Preparation correction / P1 owned and repaired: Original publish.py consumes the prior4.13 claim as a template but omits it from the draft input declarations. Before HEAD changes, verify and TERM only own commit PID1708/hook descendants; actual tool143 and unchanged HEAD/staged digest are retained with the compressed process snapshot. This deliberately stopped preparation is neither hook failure nor all10 PASS. Preserve original publisher/draft and all actual metadata/source/raw channels unchanged.
  Qualified binding outcome: New qualify_claim.py declares the actual prior template, checks activation-Git bytes, and binds saved draft plus qualification instrument/result/outer wrapper. Original missing declaration, removed binding and altered SHA all reject; qualified write/readonly return0/empty stderr. Metadata remains1157 rows/five controls/zero removals with unchanged observation/replay. The corrected candidate requires a fresh complete normal-hook execution. Knowledge card artifact-claim-composition-inputs records this durable producer-input boundary.

  Acceptance Checklist
  - [x] **REPRODUCE / ISSUE** — latest-only record is over24h old; existing non-following census.py and separate scandir/lstat acquire the named current scopes.
  - [x] **ROOT CAUSE (WHY + WHERE)** — dated metadata identifies1157 path/suffix/byte rows and covered rust/target; age/name/size establishes no disposal authority.
  - [x] **FIX** — retain every selected artifact/cache/proof and refresh the latest-only record from the actual dated observation; source/index and command channels persist.
  - [x] **ADDRESSED (verified)** — all1157 primary rows match independent metadata; five altered-evidence controls reject; separate readonly replay0/empty stderr and actual source/claim identities agree.
  - [x] **NO REGRESSION** — earlier observations/claims, active outputs, protected caches, submodules and other repositories remain untouched; no runtime or storage policy changes.
  - [x] **LOCKSTEP** — book maintenance example, Knowledge, tasks/index and change/engineering/live/MEMORY route the clean handoff to independent Dart77.3.


- ID: `TYPE-REFERENCE-BOOK.1.2.23.1.38`
  Status: `completed` / finite original Array-transform selection frozen; family78 owned
  Goal: Select the next roadmap-aligned finite feature or establish the existing implemented-feature boundary after bounded Hash-valued77 outcomes.
  Containment repair: First commit attempt rejected task_evidence at12586477/12582912 bytes. Stop only its still-running claim verifier after the known pressure failure; that interrupted check is not passing. Preserve complete candidate task bytes beside compact_pending_tasks.py, move five identical pending proof contracts/verification plans to parent78, retain each named route and all acceptance requirements. Shorten only this selection's duplicate narrative; current contracts, frozen artifacts and prior evidence stay intact. Rerun routing pressure and all ordinary hooks.
  Continuity repairs verified: Rewrite the stale helper-spine current finite frontier from committed77 outcomes and correct its Julia-to-Lua next sentence. The callable audit card now states all four steps complete at the accepted August1 boundary, agreeing with its admission update and actual FUTURE-PARITY-BACKLOG.11.8.4 done node. Literal-path searches of tracked claim records found no references to either edited document; ordinary commit identity gates remain authoritative. Preserve historical plan/evidence and all frozen contracts/fixtures/seals; no new runtime/current-host admission claim or broad audit.
  Dependencies: Clean installed Lua77.5 landing; current23.1 requirements/canonical role inventory/book/Knowledge and recorded77 source/custody qualifications.
  Acceptance: Recover the next eligible requirement from current canonical inventory and parent frontier without treating method names as defect evidence. Select at most one finite existing-contract gap with minimal distinguishing public observations where needed, own any implementation/prerequisite before changes, and preserve all source/arity/context/collision/mutation boundaries. If ordinary feature coverage is exhausted, identify the already owned prerequisite/deferred verification task now eligible; do not invent a gap or make an aggregate completeness claim. Retain actual first producers/inputs/artifacts/channels for any acquisition and distinguish healthy behavior from measured defects. No broad suite/matrix between feature slices, no dependency-internal inspection or unsupported authority.
  Verification tier: `focused`
  Focused checks: Targeted canonical requirements/role/Knowledge/book retrieval and only distinguishing public controls needed for selection; readonly evidence recovery if new observations, book/history/memory/task/Knowledge/diff and normal hooks.
  Canonical trigger: Full23.4/final clean push after feature coverage; new public authority/infrastructure separately owned.
  Claim verification: none: Finite authored feature selection and preservation distinctions; separately declare any population/performance measurement.
  Frontier: Activate only from clean Git after77.5 normal hooks/post-pointer/brief0. Keep family77 historical contracts/fixtures/seals unchanged and carry actual per-backend qualifications forward.
  Outcome: All37 original programs are eligible ready1/raw0/fallback0/unresolved0; unchanged37 source/target fixture and first scoped contract frozen. Nineteen actual failures contrast18 healthy controls, including all four required source/count errors already propagating. All37 actual module/handler pairs and actual first own Perl/three grammar/instrument inputs/full gzip-first channels retained. Family78 plus five independent backend leaves now own source/optional/excluded-arity/error acquisition and bounded result repair before any production edit.
  Recovery qualification: Original review.py exits1 on fresh_error absent for unloaded modules. Separate review_unloaded.py recovers positive evidence then halts at its first corrupted None error record without a shape assertion. Both failures/full channels/readers/seals unchanged. Separate review_typed_errors.py adds explicit error-record shape checks; first strict recovery0/empty stderr/nine effective corruption controls PASS. No original producer/SDK/target/observation/contract/fixture rewrite. Emitted modules precede fresh loading; native handlers precede native execution after Get builds them. Complete native/cache/transitive/toolchain custody4.2/SESSION5, general isolation/context/portable/registration/full23.4 remain separate.
  Evidence: docs/checkpoints/array-transform-result-selection-2026-11-07/REVIEW.md and readonly review_typed_errors.py; frozen docs/checkpoints/type-operation-inventory/array-transform-result-guard-composition.md and tests/fixtures/array_transform_result_guard_cases.json. Other transforms/list splices/aliases/mutation/callback contexts remain excluded; preserve existing coercion/sort/depth/backend differences.
  Next: After clean landing activate capacity4.16 before independent Perl78.1 source/arity/error acquisition. Cleanup record November7 05:37UTC remains current.
  Commit: TYPE-REFERENCE-BOOK.1.2.23.1.38 — select Array transform result guards.

  Acceptance Checklist
  - [x] **REPRODUCE / ISSUE** — original37 public Get/return_descriptor/call_spec_handler_subst/emit_generated_source/native-fresh retains19 failures/18 healthy and ready1/raw0/fallback0/unresolved0 metadata before any production edit.
  - [x] **ROOT CAUSE (WHY + WHERE)** — actual substitution/handler shows computed Array entering unguarded Hash copy and literal receiver DSL; constructor oracle has HASH test/rejection flag; MethodLowering.pm retained/free/prefix/copy/logical/with roles omit selected transforms.
  - [x] **FIX** — freeze exact unchanged37 and scoped existing-contract78, create independent backend owners before implementation; correct two owned continuity paragraphs against committed outcomes/actual done admission node.
  - [x] **ADDRESSED (verified)** — separate strict readonly0/empty stderr/nine effective corruptions, actual37 module/handler pairs/input identities; both earlier reader failures retained; no production/peer fix claimed.
  - [x] **NO REGRESSION** — eighteen healthy controls/needed errors/source order/snapshots/Bools/null/empty/bridges/constructor oracle preserved in original evidence; no SDK/emitter/grammar/dependency change or broad suite.
  - [x] **LOCKSTEP** — book/helper spine/Knowledge, task/future78/index/frontier, change/engineering/live/MEMORY distinguish observed defects/reader qualifications.
  Open scope: pending independent implementation and full admission remain separately owned.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.4.16`
  Status: `completed` / qualified exact-tail preservation; generic repair4.17 open
  Goal: Renew task-evidence headroom before Array78 using the existing exact-Git closed-narrative epoch workflow.
  Reproduction/impact: Selection38 first commit exceeds12582912-byte control; duplicate-plan consolidation fits but leaves inadequate implementation headroom.
  Acceptance: Select one eligible unpartitioned tree; preserve all CORE fields, open bodies, source bytes and reader recovery under ADR0139. Check claim bindings, use existing migrate_task_narrative.py, retain focused source/current/inverse evidence; no limit/tool/policy change. Then Perl78.1.
  Verification tier: `focused`
  Focused checks: Actual public before/node/full queries, narrative/Unicode/capability/language-closure consumers on first/qualified inputs; independent157-ID/CORE/eight-body/exact-tail recovery with seven reason-sensitive denials; book/Knowledge/history/memory/diff and mandatory hooks.
  Canonical trigger: Existing data-only epoch, no tool/limit/policy change. Infrastructure repair4.17, full23.4 and final clean push retain their own canonical boundaries.
  Claim verification: `docs/claims/TYPE-REFERENCE-BOOK.1.2.23.4.16.json`
  Initial semantic failure: Existing writer/queries and three named metadata checks exit0, but independent legacy-section inspection finds Current frontier/trailing sections absent from current Lua; first node query includes233688 bytes of chronology. Exact uppercase separator in both node parser and migration is the mechanism. Preserve first instrument/results; separately qualify by restoring the entire original lowercase frontier tail, not by changing the frozen producer. Generic repair4.17 owned before qualification.
  Activation: Clean2286c6606a9fb86290801e1c8a0053e59d342a1f; all10/post-pointer/brief0. Existing population report nominates unpartitioned LUA-BACKEND-PARITY; current source eligibility and historical-only claim reference checked. Named Unicode/capability/language-closure consumers read current IDs/statuses. Preserve dated Lua acceptance; no new runtime/5.4/admission credit.

  Final staged claim proof: bash tools/run_python_project_data.sh docs/checkpoints/task-headroom-lua-2026-11-07/check_final_claims.py passes actual staged4.8/4.16 validation (two records), with no recorded-command execution; focused cadence/canonical-path0 and diff checks pass.
  Claim qualification verified: Bound actual validator rejects the stale book then passes after selected4.8 mode/revision-only preservation. All64 original rows verify at2286; every measured field/hash and both unselected claims unchanged. Writer/default replay0/empty stderr/six effective type/field/hash/revision/population denials PASS. Initial wrong-diagnostic recorder/source/inner rejection retained; qualified bound epochs have complete producer/material/wrapper capture. Historical old recipes explicitly require accepted Git inputs; new replay does not read future live book text. No schema/infrastructure change or new pack/publication measurement.
  Claim intersection repair: Exact live-binding search finds only4.8/intersecting-claim-mode-only-preservation among111 literal chapter bindings (110 historical). Actual selected validator rejects the stale chapter. Initial recorder wrongly expects the word mismatch and fails after retaining that real rejection; preserve it unchanged. New bound recorder follows actual stale-input diagnostic and retains validator/checker sources before use. Qualify only selected4.8 durability.mode/revision at clean2286 after verifying all64 original inputs; preserve every measured value/hash and other claims. Prior-record search finds no literal dependent of4.8; the new4.16 qualification explicitly binds its preserved record. Focused actual validator and strict field controls govern repair.
  Book budget repair: First4.16 commit rejects diagnostics2063/2048; its remaining claim verifier is interrupted, not passed. Retain the full draft; contain_book_budget.py keeps all pre-existing fenced examples exact, uses an inline command for only the new note and removes two outside-example redundant blank lines. Result2047/2048; no limit change. Original data proof unchanged; rerender/ledger and normal hooks govern corrected candidate.
  Outcome: Qualified all157 current IDs/complete multiline CORE fields,149 selected closed contracts/eight complete short bodies, original477660-byte source and exact232154-byte current/trailing tail survive. Current362317 bytes renew115343, not first unsafe347497. First readonly0/empty stderr/seven reason-sensitive denials PASS; actual first tail loss is retained semantic RED even though metadata passed. Final narrative and all three direct metadata consumers pass on qualified images; no original producer/epoch/result rewrite.
  Source boundary: Existing task_narrative nodes()/migrate_epoch() exact uppercase Current Frontier misses Lua lowercase Current frontier. Separate qualify_legacy_tail.py restores only the exact original tail. Generic last-node query remains233688-byte chronology-bearing chunk; explicit repair4.17 scheduled after feature coverage, earlier if capacity blocks continuation. No generic boundary, runtime, Lua5.4, full input-custody/isolation/admission credit.
  Evidence: docs/checkpoints/task-headroom-lua-2026-11-07/README.md; immutable epoch and first/qualified capsules, readonly review.py, claim and Knowledge card. Remaining unchanged tracked metadata-consumer inputs at activation Git/before patch; full transitive OS/toolchain custody4.2/SESSION5 remains separate.
  Next: Normal hooks/post-pointer/brief0/clean Git, then independent Perl78.1 own unchanged37/source/optional/excluded-arity/error/prior-owner preflight before production.
  Commit: TYPE-REFERENCE-BOOK.1.2.23.4.16 — preserve Lua task tail while renewing headroom.

  Acceptance Checklist
  - [x] **REPRODUCE / ISSUE** — selection38 pressure rejection; actual first migration removes lowercase current tail despite passing metadata; full public query/source images retained.
  - [x] **ROOT CAUSE (WHY + WHERE)** — exact uppercase separator in nodes()/migrate_epoch() misses legacy lowercase heading; actual last-node query includes chronology.
  - [x] **FIX** — separate captured qualification restores the entire original tail byte-for-byte; generic precise-boundary repair4.17 remains explicitly owned.
  - [x] **ADDRESSED (verified)** — independent all157 CORE/149 contracts/eight short bodies/exact source/tail proof, actual RED/qualified GREEN and seven effective denials pass; first readonly0/empty stderr.
  - [x] **NO REGRESSION** — qualified public node/full/narrative and Unicode/capability/language-closure metadata checks pass; tools/limits/runtime and historical acceptance unchanged.
  - [x] **LOCKSTEP** — book/Knowledge/claim/tasks/live/MEMORY retain first failure, qualified result and4.17 limit; independent Perl78.1 remains next.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.4.17`
  Status: `pending`
  Priority: P2 after agreed feature coverage; earlier if task capacity blocks continuation.
  Goal: Repair task-narrative handling of legacy lowercase frontier boundaries.
  Reproduction/impact:4.16 first retained Lua migration exits0/all metadata checks pass but tools/task_narrative.py nodes and migrate_task_narrative.py split only exact Current Frontier. Lua Current frontier and trailing sections are swallowed into final8.4 node/removed from the live view. Public node query returns233688 bytes including chronology.4.16 separately restores the exact tail; generic precise-boundary defect remains owned here.
  Acceptance: Recognize or safely refuse supported legacy boundaries before mutation; preserve all current sections/CORE/open bodies and original archives. Add distinguishing boundary/corruption controls, qualify affected frozen historical consumers without rewriting evidence, and prove actual node/full-source queries.
  Planned verification: Focused boundary/reader/migration and direct metadata consumers; infrastructure canonical receipt required at activation.
  Planned claim verification: none: Declare exact repair proof or scoped no-measurement rationale at activation.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.4.18`
  Status: `active` / bounded planning then canonical implementation
  Priority: P1 first on PNT resumption, before independent Dart78.3 or further fact growth.
  Goal: Recover bounded Knowledge Map growth capacity while preserving published facts and lookup keys.
  Reproduction/impact: Rust78.2 normal hooks expose knowledge_map22501 lines against max22500 in doctrine/readme_stability/routes.jsonl. Current Rust closure consolidates only overlapping unpublished lookup aliases within its own additions; factual bodies and activation-owned questions remain. Qualified containment reaches22499/22500 with generator/control unchanged and prior question text/fact bodies preserved. It leaves one line before the hard bound for the next backend fact, so capacity recovery is a prerequisite rather than an unowned warning.
  Dependencies: Clean stopped Rust78.2 checkpoint; director instruction to resume. Generic task-boundary4.17 remains a separate owner.
  Acceptance: Recover README_POLICY/ADR0063 and current containment authority, inspect the generator and every affected reader/gate, and inventory exact current lines/bytes/facts/questions. Preserve all activation-owned facts and lookup identities. Prepare a bounded compaction/partition or explicitly authorized capacity proposal with exact affected surfaces, preservation oracle and implementation leaves before mutation. A cap increase requires accepted authority under README_POLICY; Rust78.2 raises no cap and changes no generator. Do not silently remove published questions or duplicate the full index into another unbounded landing page.
  Planned verification: Focused planning and preservation/reader-contract proof; source-bound canonical receipt if implementation changes generator/registry/infrastructure.
  Planned canonical trigger: Actual infrastructure/control movement, milestone and final clean push; declare at activation.
  Planned claim verification: none: Planning only; declare exact scoped proof or no-measurement explanation at activation.
  Activation: Director resumes full PNT on November10 at clean6cd8e78437df8693c31a9af64c2e242977c84786. Supplied policy hashes still match the canonical startup provenance. No cap increase is proposed.
  Children: `TYPE-REFERENCE-BOOK.1.2.23.4.18.0`, `TYPE-REFERENCE-BOOK.1.2.23.4.18.1`, `TYPE-REFERENCE-BOOK.1.2.23.4.18.2`, `TYPE-REFERENCE-BOOK.1.2.23.4.18.3`.
  Next: After bounded18.1 canonical landing, daily artifact review4.19 and lookup publication18.3 precede Dart78.3;18.2 retains the complete routing sweep and warning-pressure reassessment after feature coverage.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.4.18.0`
  Status: `completed` / focused planning proof
  Goal: Freeze current Knowledge projection and select bounded duplicate-display compaction before infrastructure changes.
  Verification tier: `focused`
  Focused checks: Readonly exact baseline census, prospective projection preservation and distinguishing corruption controls; source/reader inventory; unchanged generator/checker, task metadata, memory, histories and normal doctrines/hooks.
  Canonical trigger: none: Planning and retained evidence only; generator/control implementation is18.1.
  Claim verification: `docs/claims/TYPE-REFERENCE-BOOK.1.2.23.4.18.0.json`
  Acceptance: Preserve complete question index and all fact/source/metadata bytes, identify every production reader and directly affected test, freeze actual instrument/input identities, and own implementation before changing the generator. No recovered production capacity claim at this planning boundary.
  Verification: Actual capture and separate readonly review.py agree:1710 facts/12237 keys/22499 lines/7872229 bytes; prospective20789 lines/7125905 bytes, seven actual corruptions rejected. PLAN.md inventories production readers/direct tests and requires canonical18.1; original map/generator/control/reader bytes retained. All existing card keys and map bytes unchanged. Normal doctrines/hooks govern landing.
  Commit subject: `TYPE-REFERENCE-BOOK.1.2.23.4.18.0 - plan lossless Knowledge Map compaction`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.4.18.1`
  Status: `completed` / focused prerequisites verified; exact canonical receipt and normal hooks govern landing
  Goal: Omit the redundant per-fact answers display, preserve lookup identity, and repair bounded fixture, recurring-review, source-image, callable receiver/source-snapshot and proof-command prerequisites exposed during mandatory verification.
  Dependencies: `TYPE-REFERENCE-BOOK.1.2.23.4.18.0`
  Planned verification: Canonical infrastructure leaf; actual old/new generator output, exact question routing and all retained metadata/anchors, original card bytes, meaningful omission/metadata controls, direct header/list/atomic/storage consumers, normal doctrines, rendered book and exact staged canonical receipt.
  Planned claim verification: Declare exact scoped compaction/preservation proof at activation.
  Activation: Clean7289836f28e4873463ad1c50d354d8e66c77af8d;18.0 normal all10 doctrines/post-pointer pass, brief0 and clean Git. PLAN.md and frozen actual source/reader/map bytes own the chosen removal. No limit increase.
  Verification tier: `canonical`
  Focused checks: Actual unchanged/candidate public generator output; frozen-map exact records/question prefix and corruption controls; current/legacy/header/atomic/storage/routing/capability consumers; catalogue epoch, recurring factory, closed current-image controls and exact isolated historical recovery; book render, selected staged claims, scope ledger, memory/history/doctrines and exact canonical receipt.
  Canonical trigger: Knowledge generator and recurring verification infrastructure change.
  Claim verification: `docs/claims/TYPE-REFERENCE-BOOK.1.2.23.4.18.1.json`
  Verification selection qualification: tools/test_tool_project_data_storage.sh passes. The combined direct invocation then starts tools/test_project_data_workflow_routing.sh, whose full multi-workflow sweep recursively runs all doctrines. Stop that unprepared broad run and its own descendants143; it receives no PASS credit. Replace it here with the exact generator-only outside-cwd routing.py, plus the already selected hostile/symlink storage checks.18.2 retains the broader sweep after feature coverage; canonical receipt is still mandatory for18.1.
  Acceptance: Keep current line/byte ceilings and freshness/locality/atomic publication unchanged. Update the whole-projection oracle to compare both formats without overlooking legacy answers corruption; preserve original instrument for historical users. Add a durable retrieval pointer by updating the existing canonical routing-pressure card without removing its keys. Admit changed maintained references with the scope ledger. Close only after exact staged canonical proof and normal hooks.
  Verification: Actual unchanged/current generator output and independent original-line walk establish22499->20789 lines/7872229->7125905 bytes:1710 lines/746324 bytes removed, complete12237-key Questions prefix and all retained1710-fact records byte-exact. Current full source population is unchanged across separate qualified acquisition. Four actual implementation controls/seven retained planning controls reject; current and legacy projection fixtures preserve authored order/repeats with effective denials. Header/list176, atomic publication, hostile/symlink storage, capability, exact synchronization and generator-only outside-cwd routing pass; book renders and its changed HTML guidance is inspected under unchanged2048-line bound. Initial broad routing run deliberately143, no PASS;18.2 owns deferred sweep and remaining line-warning pressure. See VALIDATION.md/current-generation.json and readonly implementation.py/acquire.py in docs/checkpoints/knowledge-map-capacity-2026-11-10/. Exact staged canonical receipt and normal hooks govern landing; no whole23.4/native custody credit.
  Commit subject: `TYPE-REFERENCE-BOOK.1.2.23.4.18.1 - compact map and repair recurring proof`.
  Canonical restart: First approved-host canonical attempt exposes the known whole-file checklist-format constraint at selection38's older completed LOCKSTEP line. task-acceptance-evidence-gate-boundary already documents this; no new gate defect or policy change is inferred. Stop only the failed own CI tree143, preserving canonical-first.log.gz without receipt credit. Actual staged task_format.py captures reject1/accept0 with exact gate/status/other-task-byte preservation when the older future-work qualification moves to its following line. Both epoch source/channel packets and unchanged original map claim are retained; supplementary scoped claim records this correction. Restart the complete exact staged candidate after restaging.
  Bounded-record repair: The second full attempt exits1: nine doctrines pass, CLAIM-VERIFICATION rejects the422243-byte inline record against the unchanged128KiB contract. Original complete record and actual CI log remain gzip-retained. freeze_inputs.py retains every acquired source body against its prior SHA/member rows; bundle_review.py replays the exact archived renderer/source epoch and rejects missing-input/altered-producer controls. bound_record.py replaces only inline source rows with the complete hash-bound bundle and its instruments; map statement/results and the separate format claim stay exact. record_review.py uses the actual strict reader/validator on the selected staged record before another full run. No cap/gate increase or later live-card freshness credit.
  Selected bounded-record result: Actual record_review.py returns0/PASS: strict schema and every declared staged identity pass, and the original overbound declaration rejects. Raw stdout is retained in record-review-result.json. Current REVIEW.md directs readers to frozen bundle replay; initial acquire.py defaults require its source epoch, not later live card bodies. That correction yields14942 bytes under unchanged128KiB before the later fixture supplement. Complete source bodies, the rejected record and actual failed logs are retained; restart full exact CI after final staging.
  Owned P1 canonical prerequisite (before fixture code changes): Third canonical run passes all10 doctrines/header176/atomic/projection/cache/reference controls, then tools/test_task_narrative.py:184 fails with FileNotFoundError for its fixture's docs/tasks/LUA-BACKEND-PARITY.md. The fixture copies every retained epoch manifest but seeds only row[source_path] for the selected older Perl epoch; task_narrative.verify_epochs correctly checks every retained epoch, including Lua4.16. This is setup/catalogue drift, not the separately owned lowercase frontier4.17 production issue. This leaf owns the bounded blocking setup repair: seed every validated manifest's current source, retain actual unchanged/candidate observations, preserve the older20.2 live source claim at its actual accepted Git input boundary, and rerun the complete canonical candidate. No production reader, manifest, history, retention or runtime semantics change is authorized by this prerequisite.
  Fixture outcome: The test now seeds current sources through every retained manifest's validated epoch_source before mutation controls. Qualified private exact-old source reproduces missing Lua; qualified repaired full consumer exits0/empty stderr. Frozen helper replay copies the complete declared source/body map exactly and rejects missing/altered-source controls. Initial direct observers hit the stale TYPE index after this intake edit and assert before persisting; retain their original instrument without original-channel/normal credit. Refresh the index, then use separate qualified packets. preserve_epoch_claim.py independently verifies every original20.2 input at accepted5801970b4d311e97b5764d16a2573a4094144e49 and changes only selected mode/revision plus explicit capture scope. Original source/claim/statements/results/hashes stay retained; default old review requires that Git boundary. Lookup publication18.3 follows daily4.19 before Dart78.3; complete workflow routing18.2 remains after feature coverage. Full canonical restart required.
  Owned P1 fourth canonical prerequisite (before reviewer changes): Fourth canonical exits1 after all10 doctrines, metadata/projection/atomic/reference and repaired22 epoch denials pass. The recurring document-pressure factory reviewer rejects current perl/LinkedSpec/ActionIR/MethodLowering.pm byte drift from its November4 capture before executing its nine public compatibility probes. Its companion source-calibration reviewer also requires today's reader bytes to equal the old single-correction image. This leaf owns the bounded replay-boundary repair: retain original capture/reviewer/result bytes and the actual failure; independently run the unchanged nine semantic targets on current source before deciding the correction; keep historical unchanged-production/source-calibration assertions tied to their frozen epochs, while current recurring execution must satisfy the original semantic oracle. Preserve all intersecting older claim inputs at their actual accepted Git boundary, add distinguishing refusals, and restart full canonical CI. No new runtime policy, fixture re-blessing, old observation refresh or native/transitive-custody claim is authorized.
  Recurring-review outcome: Independent unchanged native/fresh targets pass before repair, while the original recurring reviewer exits1 only on captured-runtime drift. Current semantic compatibility retains the original oracle; unchanged-production/source-calibration claims use their exact frozen epochs. Both corrected reviewers return0/empty stderr. Actual current native-kind/fresh-effect child-result faults and an unrelated historical reader edit reject. Original captures and both intersecting20.1.10 claims already bind accepted cd3b6adc3e58fb64283ae4ae4a5a37823eabd891 and stay exact. Before/after source-only packets, actual channels, reader controls and failed fourth log survive under the existing proof owner; no full native/transitive custody or canonical PASS is inferred.
  Direct-dependent result: The exact formerly failing document-pressure-restoration/review.py completes0 with empty stderr. Full channels are packaged after exit with relative command metadata in factory-dependent-result.json; no first-use input capture credit. The updated book renders, memory/history checks pass, and complete canonical CI still must restart on the fully staged candidate.
  Bound-document correction: Selected staged claim validation rejects the additional recurring-review sentence in the already bound local-CI chapter. Restore that chapter's exact proven bytes; publish replay semantics in the unbound documentation-workflow chapter after checking all live chapter intersections. No earlier claim hash changes. Re-render both chapters and revalidate selected records before canonical restart.
  Owned P1 fifth canonical prerequisite (before source-image changes): Fifth canonical passes all10 doctrines, repaired recurring reviews, history45 and structural language controls, then isolated historical recovery rejects unreviewed current source image dart/lib/src/runtime/interpreter.dart. The canonical three-objective-language-readiness card explicitly requires a reviewed evolution owner when later accepted source changes exceed the frozen18-image table. This leaf owns a bounded exact successor-image layer for only demonstrated changed parent-repository paths at clean7289836f, preserving the original table, original historical and admitted predecessor stages, Phase0 calibration and every existing denial. First inventory all18 effective current paths through the published image/fixture adapters, retain actual table/producer/source/hash/mode/history inputs and the fifth failure, then gate committed successor identities without changing runtime code or rewriting old observations. Direct isolated recovery must pass with distinguishing source/revision/membership corruptions before another canonical restart. No fresh objective/runtime/whole-feature admission, wildcard drift allowance, submodule inspection or prior-result promotion is authorized.
  Expanded-source qualification (before extending admission): The original18-entry inspection finds four changed committed runtime images and fourteen preserved effective images; its focused lineage/Phase0/all18-denial replay passes. The actual isolated consumer then rejects dart/test/source_emitter_test.dart outside that original table. Preserve the initial four-path proof, source snapshots and failed direct channels as a bounded intermediate, without complete recovery credit. Inspect the complete historical source population through the existing milestone records and exact evolution functions before further changes. Own exact first-image admissions only for demonstrated changed executable paths not already admitted by existing inverses, with their historical Git predecessor, source hashes/modes/accepted owners and new current-image denials. Keep documentation evolution separate; no arbitrary path or generic drift exemption. Final qualified proof replaces no earlier observation.
  Qualified image outcome: Complete149-source intake and the separate actual audit report agree. Existing inverses cover the other executable changes; only four committed runtime successors plus accepted Count73.3/553f9d18's emitter test need image admission. Closed tables preserve the original eighteen-entry table, every admitted/historical predecessor and protected Phase0 calibration. Initial merged-row ordering assertion is fixed by sorting. Qualified legacy/successor/first-image controls, all19 real current-byte denials and wrong lineage/member/revision/table controls pass; source loss/altered historical hash reject. Actual isolated producer returns0/empty stderr, preserves134 recovered inputs/22 controls/714 governance denials and all other accepted backend-registration controls, and closes191 observed artifacts within202 declared bodies. The first comparison used the older703 baseline and fails; its source/empty stdout remain, with no product RED. Corrected comparison uses accepted backend-registration4.3. Original4.3 inputs are verified/preserved at actual f6295bc8fc76e7c6049f28397049f527fe8133d7, with only selected mode/revision/scope qualification. The bounded fifth claim binds every actual declared input plus the new instruments; no runtime/objective/native/full-feature promotion. Source-only intermediate snapshots stay distinct and require their own supplied input epoch. Full exact canonical restart remains required.
  Owned P1 sixth canonical defect (before runtime changes): Sixth canonical passes all10 doctrines, repaired historical recovery and registered native admission/contract consumers through uniform binding. The unchanged callable-codeblock literal consumer then fails its neutral dynamic-caller fixture: native result is undef and independently emitted Perl fails to load near ")[" at generated line122. Runtime sources still equal the accepted7289836f activation. This leaf owns diagnosis through public Get/dump_parser_source/return_descriptor/emit_generated_source and the smallest demonstrated source repair, preserving ADR0031/0032 fixture values, dynamic caller/parameter/rest/source-once behavior and all existing fluent guards. Retain actual failed canonical channels, SDK/grammar/producer input identities and native/emitted failure before mutation; locate the generated expression and production lowering source before deciding the fix. An invalid emitted program is not a fixture re-blessing opportunity. Focused original fixture, distinguishing minimal counterexample/oracle and directly affected lowering controls precede another complete exact canonical restart. No new callable/context authority or broad feature admission is authorized.
  Codeblock diagnosis before production: Public AST reports an intentional raw_perl receiver for collector(...)["items"]. Get/dump and standalone emission show invalid raw DSL in the Length initializer at generated122. MethodLowering's existing5800 compatibility path already builds CodeblockRuntime::read_path, but the6412 guarded source bridge preserves that prepared raw receiver only for ordinary Count. Length re-lowers the raw node, falls back, and the7423 legacy expression embeds the authored call/index verbatim. Preserve Count's existing path; track only successfully prepared complete callable-index paths and reuse that expression in the guarded bridge. All other raw/arity/domain dispatch stays. The canonical Count fact already records the earlier same-mechanism Count repair. All live claim intersections for MethodLowering/current callable test are empty. Six authored SDK cases extend the existing selected consumer without changing old expectations: healthy Array Count plus Array/empty/String/null Length and String uppercase with one caller-side effect.
  Probe qualification: Original outer collector assumes pure JSON and fails on expected-error Trace stdout, while actual child exit0/full channels and pre-use source identities survive in codeblock-before.json.gz. Keep that instrument/result boundary without outer PASS. The separate qualified collector preserves every prefix byte and validates the producer's complete final JSON frame; unchanged fixture still yields native undef/emitted load0 with the original syntax error. Parent-owned source/grammar bytes reuse the complete checked factory-after bundle; no original canonical first-use or full native/cache/transitive custody credit.
  Codeblock implementation outcome: Track only a complete successfully lowered callable-index path and reuse that prepared read_path in the guarded source bridge; the existing Count disjunct remains. Qualified original neutral native/emitted fixture now passes with metadata/source/expected unchanged; four source/value/effect/artifact controls reject. The extended original callable consumer passes all six new cases. Direct Count composition, Length composition and Length/Count ownership pass; Count excluded-source snapshot has one failing lowered-string field for malformed count().take(1).with. Its new Array-result/with scaffold differs from the earlier snapshot; AST/errors/warnings and other rows still match. Before any snapshot change, this leaf owns a bounded private exact-old/current MethodLowering comparison and public descriptor/native/fresh check of that excluded source. Preserve original fixture and failed direct channels. Correct only a demonstrated pre-existing source-layout expectation, retaining arity/unsupported ownership and every other field; no new Count authority or runtime result re-blessing.
  Source-fence outcome: Initial private overlay loads current MethodLowering because facade initialization prepends its SDK root; the recorded module SHA fails its identity check and earns no activation credit. Keep original collector/intake and empty outer result. Qualified explicit preloading records the exact activation7289836f module and repaired module before their uses. Both produce identical18 rows and identical excluded native/fresh/generated/metadata results. Only row0 lowered differs from the original fixture. Retain original Git-exact fixture and calibrate just that source cell; all other bytes and unresolved count/non-ready ownership stay. Readonly source/diagnostic replay and old-snapshot/extra-cell/unsupported-owner controls pass. The exact repaired18-row consumer returns0. Shared native/cache/transitive custody remains4.2/SESSION5; no malformed Count admission. Book, canonical fact body and live docs are synchronized before complete exact CI restart.
  Publication qualification: The bounded seven-claim supplement preserves all original five objects. Source/diagnostic custody is checked at its stated granularity; finite native behavior discloses the incomplete runtime/cache/OS/transitive durability leg to open4.2. The first supplement writer mistakenly enumerates its own shell-redirected empty output among unused checkpoint paths. Preserve that original declaration and exact empty byte stream; remove only the unused output row through a retained qualifier, without refreshing any source/producer/result identity. No first-publication completeness credit. Source bodies, fixture originals, failed collectors and actual channels stay retained.
  Owned proof-command defect before correction: Seventh canonical passes all10 doctrines, repaired fixture/factory/historical recovery and initial native contracts. Review catches that claim7's declared replay command invokes the original-fixture and source-fence artifact readers but does not inspect the separately saved six-case/direct-dependent test channels included in its granularity. The actual channels and producer sources are retained; this is a declaration/reader coverage gap, not a new runtime failure. Stop only this verified own CI tree before a receipt, retain its actual interrupted log/process identity, and add a bounded readonly channel reviewer with missing-pass/wrong-target/altered-exit denials. Preserve the original declaration and every older binding; qualify the replay command and explicitly retain the new reader/results. Existing native durability gap4.2 stays open. Then restage and rerun the complete canonical candidate; no seventh-attempt receipt or full pass credit.
  Proof-command outcome: Verified own runner77165 and five-process tree are stopped143; actual stop record reports no live residue. Full seventh log remains uncredited. Readonly callable_channels_review.py checks exact argv/cwd/exits, complete original14 failure titles, four direct passing files, one lowered-only failure, final18-row PASS and six authored cases against both frozen consumer images. Missing-pass/wrong-target/wrong-exit/missing-original-failure/missing-authored-case controls reject. The initial reader's physical-gzip assumption rejects the old before metadata, whose original hashes name decoded channels; retain that instrument and empty outer output. Explicit fixed domains preserve every hash and corrected replay passes. Qualification preserves the entire prior declaration, all original five claims, both supplementary statements, every source/producer/result binding and the native durability gap4.2. It adds only command/result/scope coverage and new reader/artifacts, staying under128KiB. Runtime/test/fixture sources are unchanged by this proof repair. Exact full canonical and normal hooks still govern landing.
  Owned P1 eighth canonical prerequisite before source/test changes: Eighth attempt passes all10 doctrines, retained recovery, native/contract consumers including the repaired callable40 and signed selectors, generated source/scalar numeric/ActionIR parser. Scalar-copy suite then has486 passing assertions and one source-string failure at49: legacy_source is a guarded copy of [@Top], while its old expected literal is return [@Top]. Live/standalone14 values, all outer/nested identity facts, typed poisoning, arity and legacy callback controls pass. Preserve actual failed log and original test/probe/SDK images. This leaf owns exact activation/current public substitution comparison and an independent executable rule-array snapshot oracle before choosing calibration versus runtime repair. Preserve source-once/shallow outer-distinct/nested-shared semantics and all original controls; do not re-bless a runtime failure. If both modules already agree and the old source literal is merely layout, replace only that literal-source assertion with value/identity/effect checks. No other source/test change or broad copy/native admission is authorized by this prerequisite. Full exact canonical restart remains mandatory.
  Copy-source oracle outcome: Public AST is variable Top plus zero-operand copy. The current guarded ordinary-copy bridge keeps the original [@Top] source snapshot. Qualified exact activation/current modules emit identical source; both match executable original return-snapshot values, outer/nested identity, mutation isolation and one size/six element reads. Empty/alias/lost-nesting/repeated-read programs differ. Replace only the literal-source assertion with this executable comparison and add its observational helper; all other original assertion source/probe bytes remain. The actual normal helper, extracted from the consumer before use, independently matches the oracle and rejects the same four executed controls. Initial preservation review catches placement of the new import before an original blank line; retain that first test body/empty output and restore the original prefix before capture. First full487 pass precedes this blank-only correction; its raw channels were not retained before log reuse and earn no original-channel credit. Final consumer487 passes separately with full channels retained. No MethodLowering or other production source changes. Source/diagnostic proof and focused native outcome keep the existing4.2/SESSION5 custody boundary. Book/current copy card are synchronized; exact complete CI must restart.
  Final copy declaration: Nine-claim record is within128KiB and preserves every prior seven claim object. New source/diagnostic binding retains all SDK members, exact original/candidate test/probe/producer bodies, executed independent and actual-helper controls and final full channels. The reader checks all14 native/generated values/identity facts and rejects four actual channel faults. Separate focused native487 result discloses the incomplete native durability leg to4.2. Selected strict staged validation, full exact canonical and normal hooks govern landing; no original first-use or whole-feature promotion.
  Owned P1 ninth canonical prerequisite before Phase0/reader changes: Full exact ninth attempt passes all preceding sections, including scalar-copy487, complete supplied private population, managed/relocated storage, five-runtime named execution and both CLI66 environments. Full Phase0 then exits7/1035 groups at476/720/756/759/762/799/1022. Exact names: emit_context_lowers_method_contracts_for_capture_and_structured_return_values; emit_context_lowers_aggregate_expression_emptiness_flow_helpers; emit_context_lowers_rename_key_value_helpers; emit_context_lowers_drop_keys_value_helpers; emit_context_lowers_pick_keys_value_helpers; emit_context_lowers_fluent_if_else_and_branch_statements; spec_format_terse_3_3_3_mutation_assignment_expression_values. Visible failures compare old source guards/temporary nesting; no blanket stale-or-runtime classification is authorized. Retain full log, original protected test and current source/claim inputs before mutation. Use current-only selected replay, independent public source/value/effect oracles and distinguishing REDs for each exact failed assertion; keep all healthy assertions and production unchanged unless a demonstrated runtime defect requires repair. Phase0 is protected by exact historical calibration: preserve its old source stages and all denials through a bounded exact inverse, never a successor/wildcard exemption. New18.1 claim5 has uncommitted producer inputs, so retain its complete accepted-by-this-capture logical input epoch and original declaration before changing any bound path; do not invent a Git revision or refresh hashes. Full canonical remains mandatory after focused repair/recovery and strict staged proof.
  Acceptance Checklist:
  - [x] **REPRODUCE / ISSUE** — actual before generation retains22499 lines/redundant displays; mandatory canonical separately exposes incomplete epoch setup, historical/current factory-byte conflict and unadmitted committed source images.
  - [x] **ROOT CAUSE (WHY + WHERE)** — public generator194 repeats the complete Questions index; epoch test seeds one source for a whole catalogue; factory reviewer pins current runtime to a frozen capture; historical audit tables omit later accepted four-runtime/one-test images.
  Qualified Phase0 outcome: Current-only seven-name replay reproduces20 source-layout assertion failures/140 assertions and seven failed groups. Pre-authored finite values/effects agree for every exact activation/current emitted source, including aggregate preservation, diagnostic sink output and nested-write snapshots;40 executed wrong-value/warning controls distinguish failures. Replace only those20 assertions; every other source byte/helper/plan is recovered by the exact inverse. Final seven-name replay exits0,140 passing/complete8-result TAP/empty stderr. The new closed20-hunk table restores actual committed7289836f bytes before the unchanged older six-hunk/image stages; all11 prior fixture and19 current-image denials remain exact, plus12 new source/table/owner/path/revision/hash/hunk denials. Before protected-reader/test edits, freeze claim5's complete original nine-claim declaration/all231 inline source bodies/roles/modes; the already-nested unit producer supplies232 logical sources. Both unchanged reviewers execute from that same-volume artifact epoch using real read-only Git objects; no fictitious Git capture or old hash refresh. First replay's missing nested unit and initial replacement title-placement mistake remain explicit bounded setup failures, corrected before test edits. Eleven bounded claims preserve all prior nine objects; three native custody gaps remain4.2/SESSION5. Ninth full canonical failure remains nonpassing; complete exact restart and normal hooks govern landing. Readonly objective_frozen_epoch_review.py and phase0_review.py route all qualified evidence.
  - [x] **FIX** — omit only duplicated display, preserve strict legacy comparison, seed every validated epoch source, keep recurring semantic and frozen calibration checks distinct, and admit exact committed source images while preserving every original predecessor and Phase0 boundary; replace20 stale source envelopes with independent finite value/effect checks and a closed exact inverse.
  - [x] **ADDRESSED (verified)** — map1710 lines/746324 bytes renewed with exact lookup/record preservation and effective controls; qualified fixture/factory/source-image/recovery proofs pass, including source loss, semantic, historical-edit and all19 current-image denials.
  - [x] **NO REGRESSION** — header176/current-legacy/atomic/storage/capability/sync/outside-cwd/task controls pass; actual isolated recovery preserves original134 inputs/22 controls/714 governance and every other prior denial. Runtime policies/limits stay; selected staged records and exact canonical receipt govern landing.
  - [x] **LOCKSTEP** — canonical fact bodies, portable architecture/README, rendered mdBook, scope ledger, tasks/index and bounded change/engineering/live/MEMORY route to daily4.19/lookup18.3 then Dart78.3; broader routing18.2/full23.4 remain explicit.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.4.19`
  Status: `completed` / focused metadata/source/channel proof; native custody remains separate
  Goal: Refresh the latest-only daily artifact review after the November7 record exceeds24h.
  Dependencies: `TYPE-REFERENCE-BOOK.1.2.23.4.18.1`
  Activation: Clean41ba410bbb03fe8e7e4dc1412331d069e258d70b after all1035 Phase0 groups, exact canonical receipt, normal all10 hooks/post-pointer, brief0 and clean parent/submodule state. Preserve all eight checked18.1 claim bindings at that actual accepted Git capture before the shared book edit; native gaps remain4.2. Capture only eight named root/Rust/log metadata scopes, retaining caches/proof and other repositories. No deletion is authorized by metadata alone.
  Verification tier: `focused`
  Focused checks: Pre-use project producer bodies; named-scope scanner and independent scandir/lstat agreement, five altered-evidence controls, separate readonly replay/full command channels; actual accepted-claim preservation, selected staged claims, rendered book, scope/memory/history/doctrines and normal hooks.
  Canonical trigger: none: Dated metadata maintenance and explicit historical capture preservation; no storage defaults, runtime, CI/hook or doctrine implementation changes.
  Claim verification: `docs/claims/TYPE-REFERENCE-BOOK.1.2.23.4.19.json`
  Planned verification: Focused named-scope metadata census/independent walk, protected-cache classification, readonly replay and mandatory integrity checks. No broad audit or unsafe deletion.
  Planned claim verification: Declare the dated bounded review at activation.
  Acceptance: Reuse canonical artifact conventions without traversing black-box repositories; remove only data with complete disposal authority, otherwise retain it. Overwrite docs/ARTIFACT_CLEANUP.md and commit before Dart78.3.
  Outcome: Dated2026-11-10T15:19:32.257058+00:00 primary/independent walk agree on1181 path/suffix/byte rows in eight named root/Rust/log scopes, with configured rust/target covered. All candidates remain retained; no content/liveness/disposal inference or other-repository traversal. Project observation producers precede census-helper import and remain stable afterward. Five metadata/four exact command-channel controls and separate readonly replay pass. Both complete command channels, source bodies and explicit script templates survive; the declaration is authored directly without borrowing a prior-claim template. Native/OS first-use closure is explicitly separate under4.2. Before shared book edits, all eight checked18.1 claims preserve214 original regular Git input rows at actual accepted41ba410b; only mode/revision/capture scope change, original logical epochs/statements/results/hashes and three native gaps remain. Original/qualified records and readonly preservation replay are retained. The updated book renders and actual HTML is inspected; initial incorrect wrapper arguments reject2 before rendering, with no product RED/GREEN credit, then correct no-argument invocation returns0. Required CHANGES rollover archives only accepted41ba410b lines201–333 as exact segment4929; pressure/source-byte checks pass. Evidence: docs/checkpoints/artifact-review-2026-11-10/; readonly channel_review.py composes all bounded proof. Normal focused integrity checks/hooks govern landing, without a new full CI run.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.4.18.2`
  Status: `pending`
  Goal: Run the deferred complete outside-cwd workflow-routing sweep after agreed feature coverage on a prepared exact candidate.
  Dependencies: `TYPE-REFERENCE-BOOK.1.2.23.4.18.1`; selected feature coverage before23.4 admission.
  Planned verification: Full tools/test_project_data_workflow_routing.sh with complete mandatory doctrines and runtime preflight controls; do not infer it passed from generator-only routing or canonical CI, which does not invoke this whole producer.
  Planned claim verification: Declare the complete sweep evidence at activation.
  Acceptance: Obtain a complete successful result; retain the initial deliberate143 as nonpassing. Continue to own generated-map warning/rollover pressure:18.1 renews finite capacity, not a healthy-size or lifetime-growth claim. Reassess before further hard-limit pressure; no threshold increase is authorized.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.4.18.3`
  Status: `completed` / authored scoped navigation; focused checks pass
  Goal: Publish precise lookup aliases for the newly recorded bounded-claim, complete epoch-fixture, historical/current recurring-review and exact source-image facts after the original-population compaction lands.
  Dependencies: `TYPE-REFERENCE-BOOK.1.2.23.4.18.1`, `TYPE-REFERENCE-BOOK.1.2.23.4.19`
  Planned verification: Focused original-question preservation and new alias-to-card routing, current regeneration, scope/history/memory and normal hooks.4.19 already preserves all eight checked18.1 claims at actual accepted41ba410b; verify that capture rather than rebinding old observations to a later Git revision.
  Planned claim verification: none: Authored lookup routing for facts already recorded; separately declare any new population measurement.
  Activation: Cleanbcd02e8516a650aa24928f3351b088c63db66509 after focused4.19/all10 hooks/post-pointer/brief0. Six canonical cards already contain the bounded facts; append precise question aliases only, retain their original authored answer order/repeats and every other header/body byte. Existing eighteen-one source claims are already historical at actual41ba410b, with preserved214 input rows; no rebind or new measurement. Verify every old question route and the complete Facts projection against this clean activation; the intended difference is only the authored new routes. Book adds navigation examples under existing boundaries.
  Verification tier: `focused`
  Focused checks: Exact old answer prefix/source preservation, public regeneration and synchronization, original question-route multiplicity and unchanged Facts projection, new alias-to-card resolution, direct header-list fixture, accepted prior-claim replay, rendered book, scope/history/memory/doctrines and normal hooks.
  Canonical trigger: none: Authored metadata/navigation only; no generator, reader, runtime, CI/hook or doctrine implementation change.
  Claim verification: none: Adds authored question aliases for already recorded bounded evidence; routing/preservation checks publish no new runtime or population measurement.
  Routing-check qualification: Initial strict whole-map restoration fails only because the public generator updates its derived question-total header after alias insertion. Actual remaining diff contains precisely that total; original routes/multiplicity and Facts bytes already pass. Retain initial checker/empty result/authored mapping and exact header diff, then derive the expected total from actual question rows while preserving every other projection byte. Record this existing deterministic header rule in the canonical archive/reference fact with one append-only explanation and alias; preserve every original fact byte outside those explicit authored additions. This is checker setup calibration, not a product RED or new population measurement.
  Commit-preparation correction: Raw unified-diff context spaces cause the staged whitespace check to reject. The agent launches a commit before inspecting that exit2, then stops only its own complete commit tree143 before landing; actual HEAD staysbcd02e851 and no live descendants remain. Retain stopped process/log evidence; copy/verify the exact diagnostic to gzip, then delete only the raw duplicate. Restage and require clean whitespace plus normal hooks; no bypass or stopped-attempt verification credit.
  Acceptance: Keep all original keys/identities; add direct queries for the128KiB record bound/frozen body bundle, missing-Lua epoch-fixture cause, callable indexed-result lowering, executable rule-copy snapshot oracle, logical artifact epochs without fictitious Git capture, and the exact twenty-assertion Phase0 inverse. Current fact bodies already live in their canonical cards. Retain original compaction observations as dated evidence; no whole-feature or deferred18.2 admission. Complete after daily4.19 and before Dart78.3.
  Outcome: Authored aliases route exactly to six existing canonical cards. Every old answer/order/repeat, status/date/evidence/reverify and original body byte remains; one explicit append-only note explains the derived question-total rule. Public regeneration/synchronization and direct header176 pass. Readonly routing review preserves all old question rows/multiplicity, the complete Facts projection and every other map byte after calculating the header total from question rows; lost original route, wrong target, stale total and changed Facts controls reject. Initial checker/empty result/authored mapping/exact remaining header diff stay retained as setup calibration, not product RED. Prior accepted214-input/eight-claim preservation replay passes unchanged. Final book render and actual HTML navigation example are inspected. Evidence: docs/checkpoints/lookup-aliases-2026-11-10/. No new measured claim, runtime/source policy, wider admission or deferred18.2 completion; independent Dart78.3 is the next activation after normal focused commit/brief0/clean handoff.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.4.20`
  Status: `completed` / qualified new finite direct run; original omission disclosed
  Goal: Close explicit artifact-input bindings for Dart78.3's additional selected direct tests without rewriting its accepted original proof.
  Discovery owner: Julia78.4 prospective input-closure review at clean0c4738c4 activation; no Dart runtime defect or failed behavior inferred.
  Reproduction: Inspect dart/test/with_hash_results_test.dart fixture reads plus hash_value_result_guard_composition_test.dart and hash_view_result_guard_composition_test.dart. Compare their external spec/json, older checkpoint cases and profile paths with docs/checkpoints/array-transform-result-guard-dart-2026-11-10/direct/custody.json root files: explicit bindings are absent. capture.py declares tracked dart sources and the new family's cases/profiles/grammar, but not these older selected normals' external fixture closure.
  Impact: Actual direct292 TAP remains a dated passing observation; the new readonly recovery does not explicitly bind every external input of those additional tests. All own141 sources/profiles/grammar, four-route artifacts and same-path old/current inverse remain bound. Older fixtures already exist in Git, but do not retroactively assume their actual first-use identity from a later hash refresh.
  Dependencies: Finish active Julia78.4 and its clean normal handoff before activating this leaf; keep Julia prospective fixture closure complete before first SDK use.
  Acceptance: Trace the finite selected test input closure through current source and actual retained epochs. If historical evidence establishes complete original bindings, qualify precisely; otherwise acquire the unchanged direct292 once with actual complete producer/fixture/grammar inputs before use, retain full channels/readonly recovery/effective corruption controls, and distinguish original missing explicit binding from qualified new proof. Never rewrite the accepted original capsule/streams or grant retrospective first-use credit. Update Dart proof explanation/canonical facts/book and all live/task/history records. No production policy change or broad suite. Then return directly to independent Lua78.5.
  Planned verification: Exact finite direct292/input closure, source/fixture identity and corruption/recovery controls, book/history/memory/Knowledge/diff and normal hooks.
  Planned canonical trigger: none: Bounded existing focused-proof input qualification; full23.4/final clean push remain separate.
  Planned claim verification: none: Finite semantic/integrity controls and explicit custody qualification, no population or performance measurement.
  Activation: Cleandaa081db0de3ce0d761f1ee389f7d9a4500bbccb after Julia78.4 all10/post-pointer/brief0/clean Git. Read this stable leaf, canonical Dart qualification/Julia fixture-closure cards, original direct command/custody/streams, five test sources' actual file reads and current book limits. Exact additional closure is six older with/Hash fixture files; own cases/profiles and grammar already bind. Original source/archives are retained, but omitted first-use identities are not established by later hashes or older Git existence. Acquire the unchanged five-file/concurrency1 direct292 once with the complete declared fixture/grammar/own source/instrument inputs before SDK use, preserving original byte identities and separating the qualified new epoch from original custody. Retain actual full channels, exact semantic-stream agreement, old actual missing-binding RED/new complete-binding PASS and effective corruption controls/read-only recovery. Check host headroom before the single own Dart job; full native/cache/transitive custody4.2 remains separate. Then clean normal handoff directly to Lua78.5.
  Verification tier: `focused`
  Focused checks: Exact unchanged direct292, explicit fixture/grammar/source input closure and original preservation, actual old missing-binding RED/qualified PASS, semantic-stream comparison, negative binding/channel controls and readonly recovery, book/Knowledge/history/memory/diff and normal hooks.
  Canonical trigger: none: Bounded existing proof input qualification; no runtime, CI/hook, storage-default or doctrine implementation change. Full23.4/final clean push remain separate.
  Claim verification: none: Finite authored semantic/integrity controls and disclosed historical custody qualification, no population or performance measurement.
  Outcome: The actual accepted0c4738c4 packet and every originally captured owned Dart source byte/mode are preserved; only append-only old REVIEW explanation is permitted. Actual original input gate is RED on exactly six omitted older with/Hash fixtures. A separate new source/fixture/grammar/instrument snapshot precedes first SDK invocation, and actual resolved routing is captured before the exact original five-file/concurrency1 command:292PASS/empty stderr. All11 printed result/grammar stream families agree exactly, including Bool/Number kinds, values/effects/full errors and grammar bytes. Default parser grammar/nearer-candidate absence and package routing are explicit. First readonly0/empty stderr/eight effective corruptions and every acquired current source/resolved input identity pass. Evidence: docs/checkpoints/dart-direct-input-qualification-2026-11-10/REVIEW.md. No runtime/test source change, old hash refresh, fabricated Git capture or retrospective original first-use identity. Book/old append-only explanation/canonical facts/tasks/live/history/MEMORY distinguish the qualified epoch and route to Lua78.5 after normal clean landing. Full native/cache/transitive/toolchain/OS custody4.2/SESSION5 and full23.4 remain separate.
  Final focused integrity: Book build0 and rendered direct-input qualification/reference inspected. Final every-current-input check passes and proves old packet changes are solely an append to REVIEW.md, preserving even the accepted Julia explanation prefix; published metadata references are repository-relative. No runtime/test/toolchain source changes. Both bounded chronology checks, task index, Knowledge regeneration/sync, selected scope, memory/handoff and whitespace accompany normal hooks; all10/post-pointer remain mandatory. No broad suite or push.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.1.39`
  Status: `completed` / original pure-pipeline selection frozen; family79 owned
  Goal: Select the next roadmap-aligned finite feature or establish the implemented-feature boundary after bounded Array-transform78 outcomes.
  Dependencies: Clean installed Lua78.5 normal landing; current23.1 requirements, canonical role inventory/Knowledge/book and all retained backend/source/custody qualifications.
  Acceptance: Recover the next eligible requirement from canonical inventory and parent frontier without treating method names as defect evidence. Select at most one finite existing-contract gap using minimal distinguishing public observations when needed; own implementation/prerequisites before edits. Preserve source/arity/context/collision/mutation and peer independence. If ordinary coverage is exhausted, identify the already owned prerequisite/deferred verification now eligible; do not invent a gap or claim aggregate completeness. Retain actual first inputs/artifacts/full channels for acquisitions. No broad suite/matrix or dependency internals.
  Planned verification tier: focused
  Planned focused checks: Targeted canonical requirements/roles/Knowledge/book and only distinguishing public controls needed for selection; readonly recovery if new observations, book/history/memory/task/Knowledge/diff and normal hooks.
  Planned canonical trigger: Full23.4/final clean push after feature coverage; new public authority/infrastructure separately owned.
  Planned claim verification: none: Finite authored selection/preservation distinctions; declare any population/performance measurement separately.
  Schedule: First after clean Lua78.5 landing/brief0/post-pointer; routing18.2, registration4.1, generic boundary4.17, native custody4.2/SESSION5, RAM4.14 and declared5.4 retain their separate owners.
  Activation: Clean2a0a4b4ad7a51f2aa7e7a8e511020a5a6768902c after Lua78.5 all10/post-pointer/brief0/clean Git. Canonical syntax/helper/authority ledger/pipeline book and value/standalone contract read; own source/grammar/instruments precede SDK use. No production edit or peer policy inheritance.
  Verification tier: `focused`
  Focused checks: Minimal public existing-contract selection controls native/fresh/descriptor/substitution, actual input/artifact recovery and distinguishing evidence controls if observations are acquired; book/history/task/Knowledge/memory/diff and normal hooks.
  Canonical trigger: Full23.4/final clean push after feature coverage; new public authority/infrastructure separately owned.
  Claim verification: none: Finite authored existing-contract selection and preservation controls; no operation-population/completeness/performance measurement.
  Outcome: Original36 public Get/descriptor/substitution/dump_parser_source/native/full emitted-fresh retains17 defects (ten free/later Hash-copy runtime errors/seven literal receiver handler-module compile failures) and19 healthy controls, including four needed errors. Actual metadata29 ready/seven ready0-unresolved1 is preserved. All36 module-handler pairs/first inputs/full channels survive. Constructor HASH-kind rejection distinguishes missing pipeline result roles in MethodLowering.pm retained/copy/logical/with paths. First readonly0/empty stderr/eleven controls passes; qualified current-input producer/command/channels/exit proves unchanged Perl/grammar/instruments. Preliminary inline check has no standalone producer-bound credit. Full detail: docs/checkpoints/array-pipeline-result-selection-2026-11-10/REVIEW.md. Frozen36/contract/five independent family79 owners precede production.
  Continuity: Fix helpers.md's two stale current frontier sentences and obsolete catalog blanket direct-return warning; healthy pure values/source preservation and standalone writeback remain, compact I.return split caveat separate. Book/Knowledge/roadmap/live/history/MEMORY agree. Full source/context/native-cache-transitive custody4.2/SESSION5/registration/declared5.4/full23.4 remain separate.
  Containment: First normal attempt rejects task_evidence12586933/12582912 (4021 over). Preserve exact staged task bodies/full failed log in containment/, then TERM only own remaining commit/hooks; commit143 and unfinished claim check are not PASS, HEAD unchanged. This producer deduplicates only new39/79 prose via unchanged canonical contract/REVIEW; accepted task bodies/statuses/requirements and limits stay unchanged. Capacity4.21 follows clean selection before Perl79.1; final book/Knowledge/index/reference scope/history/memory/diff and all normal hooks still required.

  Acceptance Checklist
  - [x] **REPRODUCE / ISSUE** — LinkedSpec::Get/return_descriptor/call_spec_handler_subst/dump_parser_source/native/fresh36 retains17 failures/19 healthy.
  - [x] **ROOT CAUSE (WHY + WHERE)** — actual substitutions retain receiver DSL/free Hash copy; MethodLowering ordinary result roles omit pipelines; constructor rejects.
  - [x] **FIX** — unchanged36/contract/family79 owners frozen; current guidance corrected, no production edit.
  - [x] **ADDRESSED (verified)** — first readonly0/eleven denials; source/Git/modes/metadata/values/errors/warnings/absent fields/36 artifact pairs exact.
  - [x] **NO REGRESSION** — nineteen healthy/four needed errors; production/grammar/78 targets/formats unchanged.
  - [x] **LOCKSTEP** — book/helper spine/Knowledge/task/frontier/live/history/MEMORY aligned; normal hooks govern landing.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.4.21`
  Status: `completed` / closed Dart narrative preservation focused-checked
  Goal: Renew task-documentation headroom before family79 implementation.
  Dependencies: Clean selection23.1.39 after its4021-byte pressure failure/new-prose compaction.
  Acceptance: Apply existing ADR0139 narrative containment to closed records with exact source/Git/byte/mode preservation, complete stable-ID/frontier/requirement retention and independently recoverable archives. Fix only encountered migration defects under explicit ownership. Keep limits/infrastructure/SDKs unchanged; retain failed/pre-edit inputs and distinguishing controls. Restore sufficient headroom for79 before Perl intake.
  Planned verification: Focused migration/preservation/readonly controls, task metadata/routing pressure/index/Knowledge/book/history/memory/diff and normal hooks.
  Planned canonical trigger: Final push; new infrastructure separately owned/canonical if required.
  Planned claim verification: none: Finite exact documentation transformation; declare any new population measurement separately.
  Activation: Clean3906078befb43dcc2c2536c516a81d46de37f8c5 after selection39 all10/post-pointer/brief0/clean Git. Read ADR0139/normal archive and legacy-frontier cards, public migrator/reader/data contracts and book workflow. Select the closed DART-BACKEND-PARITY milestone, whose exact Current Frontier boundary is present and no existing epoch/Scope-reading fields were found. Preserve current metadata/prefix/full tail and all stable IDs/statuses/CORE fields; move only eligible closed commentary with exact old/current/public-reader comparisons. Target/source claim references stay historical; no current Dart runtime/toolchain/parity admission. Existing tools/registries/limits remain unchanged. Complete actual input capture before migration/reader use and reject altered source/fields/IDs/tail/artifacts. Then smallest task metadata/routing checks, book/Knowledge/live/history/MEMORY and normal commit before Perl79.1.
  Verification tier: `focused`
  Focused checks: Existing migration/public-reader full-source and per-node recovery, independent prefix/tail/ID/status/field/selected-unselected preservation/corruptions, task metadata/routing pressure, book/Knowledge/index/scope/history/memory/diff and normal hooks.
  Canonical trigger: Final push; any required infrastructure change receives separate ownership/canonical proof. This leaf applies an existing data contract only.
  Claim verification: none: Finite exact documentation transformation and preservation controls; no current runtime, operation-population or performance measurement.
  Outcome: Existing unchanged migrator produces explicit epoch4.21 for DART-BACKEND-PARITY from accepted3906078be. Preserve68 IDs/all CORE fields/statuses, ten unselected short bodies, exact metadata/prefix and entire54718-byte current/trailing section;58 eligible closed narratives gain pointers. Exact171451 source becomes106515 current bytes, renewing64936 under unchanged limits. Actual first instrument/tool/wrapper/task/epoch/Git-source inputs precede migration; actual output bytes/modes precede reader use. Target/three direct tools match activation Git; wider task superset honestly includes this leaf's uncommitted activation/index state. Public --all and all68 node queries match exact original bytes/exit0/empty stderr. First independent readonly0/empty stderr/ten effective corruptions checks complete source/fields/IDs/statuses/prefix/tail/selected-unselected/pointers/modes/channels without importing migrator/parser. Historical source/claims stay unchanged; no current SDK/runtime/parity/reading/native-custody/disk-reclamation admission. Evidence: docs/checkpoints/task-headroom-dart-2026-11-10/REVIEW.md.
  Lockstep: Book workflow documents explicit Dart recovery and distinguishes existing focused data use from canonical infrastructure changes; Knowledge card/live/history/roadmap/MEMORY route to independent Perl79.1 after normal landing. Reconcile the admission parent's current split-child list with already owned19/20/21; no contract/status changes elsewhere. Metadata/routing/Knowledge/index/scope/history/memory/diff, rendered book and all normal hooks govern acceptance. Generic lowercase4.17, native/cache/transitive/toolchain custody4.2/SESSION5/registration/declared5.4/full23.4 remain separate; tools/registries/limits/SDK code unchanged.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.1.40`
  Status: `completed` / qualified callable successor frozen
  Goal: Select the next existing-contract feature or establish the bounded implemented-feature boundary after79, starting with registered-function pipeline receiver composition.
  Dependencies: Clean installed Lua79.5/all10/post-pointer/brief0; parent23.1 requirements and canonical function MVP/value-helper contracts.
  Acceptance: Use only minimal distinguishing public controls for one candidate, own actual defects/prerequisites before production, preserve peer independence and source/arity/context/collision/mutation/list-splice boundaries. Healthy probes are not gap evidence; identify an existing deferred owner if no eligible feature remains. Retain all actual first-use inputs/products/physical channels; no broad suite or implementation edit in selection.
  Verification tier: `focused`
  Focused checks: Canonical helper/syntax/authority ledger/function MVP/book; finite public Get/descriptor/substitution/dump_parser_source/native/full emitted-fresh when needed; readonly recovery/corruptions/current input identity; book/Knowledge/task/history/memory/diff and normal hooks.
  Canonical trigger: Full23.4/final clean push after coverage; new authority/infrastructure separately owned.
  Claim verification: none: Finite authored existing-contract selection and preservation distinctions; no operation-population/completeness/performance measurement.
  Activation: Clean7955c16ca0a98c373dd437284d578e80432b1321 after Lua79.5 normal landing. Relevant canonical role/syntax/helper ledger, function MVP/CountKeys callable card, pipeline reference and prior public observer/input helpers read. A pure registered call is an existing ordinary value/compatible receiver source; canonical79 explicitly excludes unassessed registered-function receivers. Acquire original terminal/free/receiver/effects/errors before inferring any defect, without inspecting a speculative implementation root. Use newline-anchored declarations and distinct caller/parameter names to avoid known SESSION32 shadowing, which remains separately owned. No peer verdict or new function format; no RGX/PGEN internals or other-repository writes.
  Owned P1 documentation defect (fix first): helpers.md still labels Rust79.2 as the next backend and Perl79.1 as next after selection39 despite all bounded79 outcomes. Reproduce: read its Current finite frontier sentence and final paragraph. Impact: stale canonical inventory guidance can repeat completed work. Preserve pre-edit bytes/Git, update only those current pointers, keep old factual outcomes/table/requirements exact, then acquire the candidate. No user decision required.

  Original acquisition40: Full-source39 and all39 module/handler pairs/complete fields/channels retained, actual observer0. Context-free substitution lacks the source function registry and is diagnostic only; Get/descriptor/native/full emission are source-authoritative. Assessment identifies both execution and readiness differences, including correct values with unresolved with metadata; no value-only PASS classification. Actual handlers retain supply(...).trim_each().set_key DSL or an unsupported with sentinel. MethodLowering.pm's ordinary pipeline-chain classifier explicitly excludes registered-function receivers before shared result/copy/logical/with guards; terminal/free counterparts distinguish this from a function-registration failure. Own this under the forthcoming frozen callable subfamily, with peer acquisition independent.
  Original pattern-control qualification (before acceptance): Two authored computed-pattern controls incorrectly require eager DSL binding errors. The published filter_match signature requires a regex operand; actual terminal handler matches escaped block source as literal text and returns[], without executing that block. This is not a newly blessed source-isolation policy or product-RED credit. Preserve every original39 input/observation/assessment unchanged. Under this same selection owner, acquire a separate41 epoch consisting of the unchanged37 supported questions plus four balanced invalid-range literal free/receiver terminal/composed controls. Require actual literal error provenance, qualified readiness and exact original37 preservation before freezing implementation. No production edit, no original setup failure relabeled PASS.
  Finding owned/scheduled: Correct returned values can conceal unready descriptors for callable pipelines (trim_later_with and initial-kind compositions in original39). Schedule readiness repair together with the same prefix classifier under callable79.6; full-source readiness and execution are separate acceptance legs. This is not accepted existing producer behavior.

  Qualified outcome: Separate41 = unchanged supported37 plus four balanced invalid-range literal controls. All37 original supported full records are exact except physical artifact paths; their actual module/handler bytes stay equal. Qualified16 targets/25 healthy: eleven execution/error failures plus five readiness-only failures (trim_later_with, initial Number/null/Hash compositions and invalid-range receiver composition). First independent readonly0/empty stderr/thirteen controls and actual source/grammar/instrument identity PASS; original39/wrong pattern assumptions remain unchanged and receive no product-RED credit. All39/41 actual source pairs/full observed error fields/physical channels/actual exits survive. Six metadata projection fields, same-process fresh modules and context-free substitution's missing registry are explicit limits.
  Ownership/next: Safe shared37 and Perl-specific41 are separate; malformed Perl literals must never run in Lua. Frozen callable contract and five independent79.6 backend lanes precede production. Perl79.6.1 is next after normal commit/post-pointer/brief0/clean Git, with original producer/first-with/arity/error/earlier-owner policies acquired before edits. Existing shadowing32, native formatter/declared5.4/custody4.2/SESSION5/source/context/isolation/registration/full23.4 stay owned. Evidence: docs/checkpoints/array-pipeline-callable-selection-2026-11-11/REVIEW.md. Also repair parent79's stale next-Lua frontier while freezing its successor; original79 contracts/outcomes remain unchanged.

  Acceptance Checklist
  - [x] **REPRODUCE / ISSUE** — Full-source LinkedSpec::Get/return_descriptor/dump_parser_source/native/emit_generated_source/fresh original39 and separate qualified41 retain16 supported targets; value-only checks miss five unready cases.
  - [x] **ROOT CAUSE (WHY + WHERE)** — Actual handlers retain callable receiver DSL/unsupported with; MethodLowering.pm ordinary_array_pipeline_result_chain excludes registered-function receivers before result/copy/logical/with guards. Free/terminal counterparts are healthy.
  - [x] **FIX** — Frozen safe37/Perl41/contract and five independent79.6 owners, current pointer corrections and public workaround; no production edit. Preserve original unsupported-pattern expectations and separately qualified controls.
  - [x] **ADDRESSED (verified)** — First readonly0/thirteen denials and current input identity PASS; original37 observed records/pairs exact, all39/41 actual source artifacts/complete observed fields and channels retained.
  - [x] **NO REGRESSION** — Own Perl/grammar bytes remain activation-exact; shared questions/initial policies/source snapshots/needed terminal errors retained. Broad feature/source/context/full admission stays separate.
  - [x] **LOCKSTEP** — Book/current workaround, Knowledge, helper/root/task/index/frontier, roadmap and change/engineering/live/MEMORY align; rendering/continuity/normal hooks required before landing.

  Landing checks: Book render0/actual HTML contains the callable-limit/workaround paragraph; memory/handoff, both bounded histories and whitespace pass. Knowledge1723/12337 keys and reference scope1925 members/17 pages are synchronized. Normal hooks/post-pointer/brief0/clean Git still govern landing; no broad suite or push.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.4.22`
  Status: `pending` / P1 import-isolation infrastructure follow-up after feature coverage
  Goal: Make live/new Python recovery launchers immune to checkpoint standard-library name shadowing while preserving required sibling imports and historical source identities.
  Dependencies: Perl intake79.6.1.0's retained unsafe/safe import and traceback controls; agreed feature coverage before broad infrastructure admission. Current reader already uses -P/cleared PYTHONPATH safely.
  Acceptance: Reproduce traceback/_colorize/dataclasses/local inspect side effects through published launch paths; preserve all historic producers/inputs rather than renaming sealed files in place. Qualify a project-local safe launcher or equivalent that supports required explicit sibling modules and physical stdlib origin aliases, retains project cache locality and does not preload arbitrary side-effecting stdlib modules. Add meaningful RED/positive controls and doctrine/launcher integration only under canonical tier; no silent command or custody promotion for old records.
  Planned verification: Canonical infrastructure boundary after focused launcher/import/locality/compatibility controls; complete required canonical gate before landing/push.
  Planned claim verification: Declare finite setup/launcher evidence and every missing native/toolchain leg at activation.
  Schedule: After feature coverage and before full23.4 evidence/admission; do not block the now isolated current reader or pivot away from active feature repairs.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.4.23`
  Status: `completed`
  Goal: Renew task headroom before Perl callable arity repair using existing narrative epochs.
  Dependencies: Clean d34acedac2583bd7ef7ab805880710cd806afbdd intake; task collection has361 bytes free. ADR0139 and4.21 establish the unchanged data workflow.
  Acceptance: Extract only eligible closed JULIA-BACKEND-PARITY commentary; retain exact Git/source/modes, every ID/status/CORE field, complete open/unselected bodies, metadata and whole Current Frontier tail. Retain actual before-use inputs/output/reader channels and independent recovery/corruptions. Tools/limits/SDKs unchanged; normal clean commit precedes arity79.6.1.1.
  Verification tier: `focused`
  Focused checks: Exact migration/public source and node queries, independent preservation/corruptions, task metadata/routing/index/Knowledge/book/scope/history/memory/diff and normal hooks.
  Canonical trigger: Final clean push; any new infrastructure change requires separate canonical ownership.
  Claim verification: none: Finite exact documentation transformation, no runtime/population/performance/disk-reclamation measurement.
  Activation: Clean d34acedac258 after all10/post-pointer/brief0/clean Git. Read ADR0139, archive/legacy-frontier/Dart cards, existing migrator/reader/CORE contract and book workflow. Julia source has exact uppercase frontier, no prior narrative extraction and unchanged source at this activation. Broader4.17/18.2 remains separate.
  Outcome: Existing migrator retains75 IDs/all CORE fields/statuses,14 complete unselected bodies, metadata and full232573-byte tail;61 closed narratives gain epoch pointers.298069 source becomes282692 current bytes (15377 renewed). Actual migration/all76 public queries0/empty stderr match exact originals; first independent readonly0/ten controls and current before-reader identities pass. No source/tool/limit/runtime changes. Evidence: docs/checkpoints/task-headroom-julia-2026-11-11/REVIEW.md.
  Acceptance Checklist
  - [x] **REPRODUCE / ISSUE** — Clean intake leaves361 task bytes; frozen exact source establishes bounded renewal.
  - [x] **ROOT CAUSE (WHY + WHERE)** — Current collection includes closed commentary; existing ADR0139 epoch preserves contracts and full source.
  - [x] **FIX** — Existing unchanged migration extracts only61 eligible closed narratives; no cap/infrastructure change.
  - [x] **ADDRESSED (verified)** — All76 actual public queries exact; independent reader0/ten distinguishing corruptions/current output identities pass.
  - [x] **NO REGRESSION** —75 ordered IDs/fields/statuses,14 unselected bodies/prefix/full frontier tail exact; SDKs unchanged.
  - [x] **LOCKSTEP** — Book/Knowledge/root/roadmap/live/MEMORY align; focused metadata/routing/index/scope/history/memory/diff/normal hooks before arity79.6.1.1.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.4.24`
  Status: `pending` / P1 evidence correction before admission
  Goal: Resolve inherited Rust/Dart serialized-input first-use retention claims without rewriting original evidence.
  Dependencies: Rust79.6.2 and Dart79.6.3 archived-source ordering audits; feature coverage before broader audit.
  Acceptance: Audit relevant inherited Rust/Dart observer epochs/maintained claims, distinguish actual later recovery from before-restoration retention, correct live/book/Knowledge wording and prospectively repair instruments. Preserve originals/missing history; no retroactive first-use credit. Current callable instruments repair ordering under79.6.2/.3; omitted old generated-error wire fields remain unassessed.
  Planned verification: Exact archived instrument/ordering/input identities, meaningful distinguishing controls and focused claim/document checks; canonical at admission/infrastructure boundaries.
  Planned claim verification: Finite source-order/custody evidence with missing historical legs disclosed.
  Schedule: After feature coverage, before23.4 admission; P1, owned alongside4.2/SESSION5. Evidence: docs/checkpoints/array-pipeline-callable-rust-2026-11-11/RESTORE_ORDER.md.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.4.25`
  Status: `completed`
  Goal: Renew bounded task headroom before independent Julia callable pipeline work.
  Dependencies: Clean c97b864fe9e9de16eaff5bcc840e46e97afe1699; unchanged ADR0139 migration and published epoch reader.
  Acceptance: Extract only eligible closed RUST-PARITY commentary from the exact activation source. Preserve every ID/status/CORE field, complete unselected bodies, metadata, whole Current Frontier tail and source modes. Retain actual before-use inputs/outputs/public reader channels, independent preservation/corruptions and current identities. No tools/limits/runtime change; focused docs and normal clean commit before Julia79.6.4.
  Verification tier: `focused`
  Focused checks: Exact migration/public source and all node queries; independent preservation/corruptions/current identities; task/routing/index/Knowledge/book/scope/history/memory/diff/normal hooks.
  Canonical trigger: Final clean push; new infrastructure changes require separate canonical ownership.
  Claim verification: none: Finite exact documentation transformation, no runtime/population/performance/disk-reclamation measurement.
  Activation: Dart all10/post-pointer/brief0/clean Git. Read ADR0139, prior Julia/Dart/legacy-boundary cards, unchanged migration/reader/CORE interfaces, relevant book workflow and RUST-PARITY source metadata/frontier. Exact uppercase boundary and no prior extraction; do not infer modern Rust parity from dated task observations. Broader4.17/18.2 stays separate.
  Outcome:52 ordered IDs/statuses/CORE fields, six complete unselected bodies/prefix/full112804-byte tail exact.46 closed pointers renew48537 current text bytes (212629 to164092). Actual migration/all53 public queries0/empty stderr; first independent readonly0/ten controls/current identities pass. Evidence: docs/checkpoints/task-headroom-rust-2026-11-11/REVIEW.md.
  Acceptance Checklist
  - [x] **REPRODUCE / ISSUE** — Clean Dart leaves about200 task bytes; exact activation source retained.
  - [x] **ROOT CAUSE (WHY + WHERE)** — Closed commentary occupies bounded current collection; existing epoch contracts retain exact source.
  - [x] **FIX** — Unchanged migrator extracts46 eligible closed narratives; no cap/tool/runtime change.
  - [x] **ADDRESSED (verified)** —53 actual public queries exact; first independent readonly0/ten distinguishing corruptions/current identities pass.
  - [x] **NO REGRESSION** —52 ordered IDs/all CORE/statuses/six unselected bodies/metadata/full frontier tail exact.
  - [x] **LOCKSTEP** — Book/Knowledge/roadmap/task/index/live/MEMORY align; focused normal commit precedes Julia79.6.4.
  Known wrapper recurrence: Documentation update exits0 with child6359 setpgid warning; no final PGID/standalone stderr retained. Existing SESSION7 owns repair; no lifecycle claim or recover/purge. Exact observation: docs/checkpoints/task-headroom-rust-2026-11-11/wrapper-notice.json.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.4.26`
  Status: `completed`
  Goal: Perform the next roughly daily safe artifact cleanup after clean Lua callable landing.
  Dependencies: Clean79.6.5; latest daily record November10 15:19UTC. Schedule this near the next24h boundary before another feature assessment.
  Acceptance: Own a bounded same-volume artifact census with active-job/tracked-proof/cache protection. Remove only100%-safe owned artifacts, retaining exact producer/inputs/channels and independent recovery/meaningful controls. Prefer verified archival retirement of this session's completed plain command logs; no ambiguous/shared caches or other repositories/submodule data. Overwrite docs/ARTIFACT_CLEANUP.md latest-only and synchronize docs/normal commit before selection23.1.41. No infrastructure/limit change or broad native-custody claim.
  Verification tier: `focused`
  Focused checks: Exact finite ownership/metadata/copy-verify-use-delete/residue controls, independent readonly recovery, book/task/Knowledge/scope/history/memory/diff and normal hooks.
  Canonical trigger: Final clean push; any infrastructure change requires separate ownership/canonical proof. This leaf changes only dated maintenance data and evidence.
  Claim verification: `docs/claims/TYPE-REFERENCE-BOOK.1.2.23.4.26.json`
  Activation: Clean e5f2cb78ab99192974178ea04177b6cabf283e1e, all10/post-pointer/brief0. Read latest-only November10 record, accepted bounded scanner/independent walker and channel/claim composition contracts, cleanup boundary card and book storage workflow. Inspect eight named root/Rust/log scopes and preserve all unproved candidates; retire only four exact owned completed combined command logs after compressed readback and independent actual use. No shared cache, lifecycle purge, submodule or other-repository write.
  Next-owner reconciliation: Assessment23.1.41 also owns the encountered stale helper inventory's two current-frontier statements (still before Perl result79.6.1.2) and missing .41 link in parent23.1's Children list. Reproduce against this activation Git and repair there; no historical outcome rewrite or feature-completeness inference.
  Acceptance Checklist
  - [x] **REPRODUCE / ISSUE** — Dated census/replay matches1,235 metadata rows in eight scopes; four exact completed-log ownership/metadata/Git identities retained.
  - [x] **ROOT CAUSE (WHY + WHERE)** — Only four owned completed combined logs are redundant plain copies; census membership grants no disposal authority.
  - [x] **FIX** — Compressed byte readback/independent actual use precede exact plain-file retirement; latest-only record advances to November11 15:29UTC.
  - [x] **ADDRESSED (verified)** — Predelete and separate readonly0/empty stderr, fourteen effective reason-sensitive corruptions and four absent residue paths pass; full channels retained.
  - [x] **NO REGRESSION** — All124,012 original content bytes/original mode records survive; every unselected artifact/source/cache stays retained. No physical-reclamation/global-liveness claim; native/OS leg stays4.2.
  - [x] **LOCKSTEP** — Book/Knowledge/live/task/index/scope/history/MEMORY align; focused normal commit precedes23.1.41.
  Outcome: docs/checkpoints/artifact-review-2026-11-11/REVIEW.md and source-bound two-claim record retain explicit census template/producers/index/actual child commands/channels, four original combined logs, metadata/modes/Git records, predelete proof and exact retirement receipt. No runtime/tool/storage-default/limit or other-repository change. Original logs lacked stdout/stderr separation; no retrospective promotion. Parent/full23.4 remains open.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.1.41`
  Status: `completed`
  Goal: Reconcile remaining agreed feature work after bounded ordinary/callable pipeline rollout79.
  Dependencies: Clean79.6.5 and daily4.26; authoritative operation inventory, current task frontiers and existing gap contracts.
  Acceptance: Use canonical inventory/Knowledge records to distinguish remaining agreed implementation from excluded authority and deferred verification. Select and freeze one bounded next feature leaf with independent public RED/healthy controls before production. If no agreed implementation remains, activate the owned deferred-verification prerequisites rather than inferring completeness from samples. Preserve all existing contracts/owners/qualifications, first-use evidence and book alignment; do not broaden authority or run broad matrices in an implementation slice.
  Verification tier: `focused`
  Focused checks: Canonical helper/syntax/authority ledger/function MVP/book and frozen ordinary78/callable79.6 boundaries; finite public Get/descriptor/substitution/dump_parser_source/native/full emitted-fresh observations; independent retained-input recovery/corruptions/current SDK identity; book/Knowledge/task/scope/history/memory/diff and normal hooks.
  Canonical trigger: Full23.4/final clean push after agreed coverage; new authority/infrastructure requires separate ownership. No production or public contract change in this selection leaf.
  Claim verification: none: Finite authored existing-contract questions and exact documentation-preservation distinctions; no operation-population/completeness/performance measurement.
  Activation: Clean e29638a99224be51fe454a1935a428c2a1a9a270, all10/post-pointer/brief0. Read the role/syntax spine/authority ledger, frozen78 and79.6, function MVP/current formal grammar including final-rest qualification, relevant Array/value book and public observer/error/metadata/source-custody interfaces. Ordinary78 excludes unassessed registered-function receivers; assess that bounded existing-MVP question without assuming a defect or peer policy. Keep signature/receiver mapping and broad verification owners separate.
  Owned metadata repairs: Two helper inventory current-frontier statements still precede completed79.6.1.2; parent23.1 Children omits existing41; parent78 Frontier still points to old selection39. Retain activation Git/bodies and exact old/new substitutions, preserving all older outcomes and CORE contracts. Resolve these current-pointer defects in this leaf before clean handoff.
  Original intake:44 authored questions complete actual0/full channels; first inspection14 expectation/readiness failures/24 healthy/six source profiles. Thirteen are supported callable transform targets, including one readiness-only with. The extra constructor_rejection_oracle incorrectly substitutes a literal Array for the established array(...) constructor oracle: actual native/fresh raises wrapped Not a HASH reference, but parent78 does not grant a universal initial-input rejection policy. Preserve original44/questions/assessment/bytes without product-RED credit for that unsupported expectation. Separate qualified45 retains all original sources, classifies that initial policy as a profile and adds the exact established constructor source; require unchanged44 actual records/pairs before freezing implementation. Initial-literal policy1.2.1.3.1 is owned below; do not normalize it in this result-guard leaf.
  Metadata-count check: Existing canonical callable-selection card already qualifies the sealed historical six-field prose to five actual fields under completed79.6.1.2; no new field-count defect. Preserve that erratum/old sealed producer bytes. Its current status/no-repair/peers-pending wording is stale after all five lanes; refresh those current pointers here against committed outcomes.
  Current-status repair: docs/knowledge/array-pipeline-callable-result-selection.md now distinguishes its original7955c16c capture from all five bounded79.6 outcomes, preserving original observations and five-field erratum. Original exact card is recoverable at activation e29638a9; no sealed selection input or runtime/source observation changes.
  Acceptance Checklist
  - [x] **REPRODUCE / ISSUE** — Original44/qualified45 actual source-bound Get/descriptor/handlers/native/full emitted-fresh observations retain13 supported targets/25 healthy/seven profiles.
  - [x] **ROOT CAUSE (WHY + WHERE)** — Public handlers retain DSL and runtime/module compile failures; own transform classifier near5762 excludes registered-function sources. One matching null/no-effects value remains unready; no source-registration or peer verdict.
  - [x] **FIX** — Freeze bounded78.6/independent Perl intake1.0 before production; repair exact helper/task/current-card pointers and qualify unsupported literal oracle separately, with inventory1.2.1.3.1 owned.
  - [x] **ADDRESSED (verified)** — First readonly0/empty stderr/fifteen reason-sensitive controls and current128 named SDK/grammar/intake identities pass;89 actual pairs/178 artifacts survive.
  - [x] **NO REGRESSION** — All44 original full records/module/handler inputs exact after physical prefixes; original expectations/assessment remain unchanged. Existing signatures/producer policies/errors and unselected contracts preserved; no profile PASS/completeness/peer-policy inference.
  - [x] **LOCKSTEP** — Book/Knowledge/inventory/task/index/scope/live/MEMORY align; focused normal commit precedes Perl78.6.1.0.
  Outcome: docs/checkpoints/array-transform-callable-selection-2026-11-11/REVIEW.md freezes shared45 and parent78.6 with independent backend owners. Parent78 receives only its new child/current frontier; receiver inventory receives the P2 initial-literal child. No production/code/schema or public policy movement. Named source/product custody and actual semantic command channels retained; direct qualification composition has actual combined exec output without invented original separate channels. Complete native/cache/transitive/toolchain/OS4.2/SESSION5/full23.4 remains open.
  Formatting check: Initial worktree diff-check exits2 for the newly appended backend paragraph's blank line at EOF. Remove only that extra blank line before staging; no SDK/fixture/observation/producer or rendered Markdown semantics change. Final diff-check must pass.

- ID: `TYPE-REFERENCE-BOOK.1.2.1.3.1`
  Status: `pending` / P2 initial literal receiver-policy reconciliation
  Goal: Establish the canonical initial literal Array/wrong-Hash-consumer policy independently of produced-result guards.
  Reproduction: Selection41 original constructor_rejection_oracle evaluates ["head"].set_key(effectful_key,effectful_value).with(){...}; public native/fresh wrappers report Not a HASH reference with ready1/raw0/fallback0/unresolved0. The established ordinary78 control uses array("head","tail"), not a literal source. Original44 inputs/handlers/modules/full errors remain in docs/checkpoints/array-transform-callable-selection-2026-11-11/intake/.
  Impact/ownership: Current reference inventory cannot treat initial literal policy as a universal produced-result null rejection. Qualify the mistaken selection control now; this owner determines whether the initial behavior violates an existing canonical contract or needs an explicit policy decision before any repair. No silent invalid-input/domain normalization or unowned host-error dismissal.
  Schedule: With receiver inventory1.2.1.3 after bounded agreed feature coverage, before23.4/full per-type admission; P2. Not a blocker to supported callable-transform composition.
  Acceptance: Read canonical initial binding/literal/receiver/error authorities, reproduce with public tools and separate constructor/produced/named/free controls, retain actual effects/full diagnostics and decide the existing target. Repair any established defect in bounded backend leaves with focused RED/GREEN; escalate only genuinely missing authority. Keep original observations intact.
  Planned verification: Focused contract/public evidence; declare actual tier and claim boundary at activation, canonical only for public policy movement/admission.
  Planned claim verification: No new aggregate measurement; initial policy remains unassessed outside the retained exact reproduction.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.1.42`
  Status: `completed` / bounded valid-Array selection; no production change
  Goal: Assess existing open-arity concat_arrays result continuations before declaring agreed feature coverage exhausted.
  Dependencies: All bounded78.6 backend lanes/preceding clean owner; current helper spelling/signature/book authorities and own Perl intake78.6.1.0.
  Reproduction/impact: Original240/terminal48 show ready terminal one-source and extra-operand concat forms with actual S/SX source effects; some later Hash/with compositions lose source effects or remain unresolved. Current78/78.6 explicitly guards free-two/receiver-one only. Do not treat excluded composed failures as accepted policy or use the non-Array extra-operand sample to admit arbitrary input kinds.
  Schedule: Immediately after bounded78.6, before deferred broad verification/full23.4. Own source-linked ordinary/registered-function open-arity intake, with valid additional Array operands and independently acquired backend limits before any implementation.
  Acceptance: Read existing open-arity helper purpose/contract and public book examples, reproduce valid Array-only terminal/composed forms, distinguish initial fallback/input errors/variadic call syntax from result guards, and freeze one bounded next owner without changing arity/type authority. Keep all current sources/outcomes/qualifications and required source/argument effects; no peer verdict or completeness inference.
  Planned verification: Focused canonical source/public probes/independent recovery as needed, docs and normal clean commit before production.
  Planned claim verification: Finite authored selection; declare actual tier/claim boundary at activation.

  Verification tier: `focused`
  Focused checks: Source-bound public Get/descriptor/substitution/native/full emitted observations of valid Array-only ordinary/function one/two/three-source free/receiver terminal and composed forms; exact input/artifact/channel recovery, distinguishing corruptions/current identities and docs/normal hooks. No runtime production change in selection.
  Canonical trigger: Full23.4/final clean push after coverage; any public signature/type or infrastructure movement requires a separate canonical owner.
  Claim verification: none: Finite authored deterministic selection and preservation controls, no population/completeness/performance measurement.
  Activation: Cleand21b84a4c8da663ee2a7600a2dc814d354502612 after Lua78.6.5/all10/post-pointer/brief0/clean Git. Relevant canonical intake/transform cards, book Array helpers/multi-Array example and bounded78/78.6 contracts reviewed. MethodLowering aggregate helper signature remains[1,unbounded] near4222; result classifier near1883 deliberately covers free-two/receiver-one. Begin own public Toolbox acquisition before selecting a repair. Native standalone dumps follow Get internal compilation, emitted bytes precede loading; complete native4.2/SESSION5 stays separate.
  Documentation issue owned: The helper catalog documents only concat_arrays(a1,a2), while the value-helper chapter already shows variadic concatenation and the existing helper contract is open-arity. Reconcile the canonical entry using retained valid terminal probes in this leaf; do not change the runtime signature or grant non-Array authority.

  Acquisition: Prepare/capture/inspection actual0 with empty outer stderr; SDK observer0/empty stderr, syntax0 with the normal syntax-OK stderr, complete named source/grammar/instruments and84 actual emitted-module/standalone-dump pairs retained before fresh loading/native invocation respectively. All84 public records have actual Get/descriptor/substitution/native/fresh data, errors/warnings/field absence and five metadata fields.66 contract passes and18 later-consumer differences have matching supported terminals, no producer prerequisite exposed. No production change.
  Selection: Frozen bounded80 owns all18 findings; public actual handlers show unguarded ordinary free Hash copies, nonpersistent ordinary receiver rejection and raw/unresolved function-result continuations. Existing MethodLowering helper[1,unbounded] versus result-role fixed-two boundary is source-linked, not a new arity policy. Default historical recovery/current identities/docs/normal landing remain pending.

  Acceptance Checklist
  - [x] **REPRODUCE / ISSUE** — Public84 with valid Arrays, corresponding terminal contrasts and full errors/metadata/artifacts retain18 later-consumer gaps;66 contract intents pass.
  - [x] **ROOT CAUSE (WHY + WHERE)** — Public dumps show unguarded/nonpersistent result frames and raw/unresolved function continuations; MethodLowering helper[1,unbounded] versus bounded result-role fixed-two near1883 is source-linked. Exact repair causality remains80.1.
  - [x] **FIX** — Frozen bounded80 contract and independent80.1-.5 repair owners cover every18 finding; catalog corrects existing variadic purpose while retaining original anchor and qualified terminal support. No runtime signature/producer/input policy changes.
  - [x] **ADDRESSED (verified)** — First independent readonly0/empty stderr/fourteen effective controls/current126; actual source/grammar/producer/artifact/channel recovery and five metadata fields gated.
  - [x] **NO REGRESSION** — All84 original records/source bodies/168 artifacts remain immutable;66 healthy intents/needed errors/empty with/canonical-two fences exact. No SDK replay or used-instrument rewrite.
  - [x] **LOCKSTEP** — Book/catalog/backend/spelling spine/Knowledge/live/roadmap/resume/task/index/scope/history align; normal clean selection commit before Perl80.1. Full23.4 remains separate.
  Outcome: docs/checkpoints/array-concat-open-arity-selection-2026-11-12/REVIEW.md. Native standalone dumps follow Get internal compilation; no precompile/native-cache-transitive closure claimed. Every failed program/error/warning/absent fresh field stays explicit. Syntax-OK stderr is retained separately from empty observer/outer stderr. Source seal precedes first reader; its later launcher/result/prose are outside the earlier seal. Current126 is activation/pre-staging only. Complete native4.2/SESSION5/source/context/isolation/registration4.1/historical4.24/raw-error4.28/launcher4.22/SESSION7/shadowing32/literal/excluded policies/declared5.4/formatter/full23.4 remain owned.
  Landing checks: Reference scope1946 members/17 pages, Knowledge1744 facts/12439 question keys, mdBook0 with the existing18.2 search-index warning, original catalog anchor exactly once, memory architecture0, bounded history0 (215/34589 change shard,243/48804 engineering shard) and whitespace0. Normal hooks follow; no full CI or production/runtime/peer verdict.

- ID: `TYPE-REFERENCE-BOOK.1.2.1.4.3`
  Status: `pending` / P2 excluded-shape diagnostics inventory
  Goal: Establish the contextual readiness/diagnostic policy for invalid free-helper calls versus receiver null-shape rejection.
  Dependencies: Receiver/signature inventories1.2.1.3/1.2.1.4; acquired Perl78.6.1.0 original240/terminal48.
  Reproduction: Extra first take/sorted receiver forms on valid registered-function results yield null/no effects/ready1 and bare undef in public handlers; effective-arity-matched free forms yield null/no effects/unready/public unsupported-helper markers. The existing early fluent-shape validator deliberately defines complete-null expressions. Wrong fixed/rest calls separately retain their canonical unresolved-helper boundary with zero raw fallback.
  Impact/ownership: Do not equate a context difference with false readiness or impose a universal free-helper policy on excluded receiver syntax. The unactivated strict-marker proposal78.6.1.1 is superseded here; preserve its evidence without product-RED credit. No current production defect is adjudicated from these metadata fields alone.
  Schedule: With signature/receiver inventory after agreed bounded feature coverage, before full23.4 admission and final per-type reference. This does not block valid78.6 result composition.
  Acceptance: Read exact public readiness/receiver-shape/signature authorities and current fixtures, distinguish valid constant-null rejection from unsupported-helper diagnostics, reproduce required contexts and document their intended policy. Repair any established mismatch with bounded proof, or retain an intentional distinction with explicit source-linked rationale. Escalate only an actual unresolved authority choice; no speculative policy normalization.
  Planned verification: Focused contextual contract/public evidence; classify actual tier/claim boundary before policy changes or admission.
  Planned claim verification: Finite authored policy reconciliation, no completeness/population/performance assertion.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.4.27`
  Status: `completed`
  Goal: Renew bounded task-evidence headroom before independent Rust78.6.2 using unchanged approved closed-commentary epochs.
  Dependencies: Clean398d723bfb5e4e7960141944957e72a4335c7e35; ADR0139/public migration/reader and source-bound preservation contracts.
  Acceptance: Migrate only eligible closed SPEC-LANG-REFERENCE commentary from exact activation; preserve every ordered ID/status/CORE field, open/unselected body, metadata and full Current Frontier/trailing tail. Retain inputs before migration, outputs before queries, exact public all/node recovery, readonly corruptions and current identities. No tool/limit/registry/runtime/policy change; no broad after-coverage audit. Commit before Rust activation.
  Verification tier: `focused`
  Focused checks: Source-bound migration/public all-node queries, independent full-tail/contract/body/mode recovery and corruptions/current inputs; narrative/task gates, book/Knowledge/scope/history/memory/diff and normal hooks.
  Canonical trigger: Final clean push or actual infrastructure change; existing data-only ADR0139 migration remains focused.
  Claim verification: none: Finite exact authored-document preservation/identity controls; no runtime, population, performance or completeness measurement.
  Activation: Clean398d723bf/all10/post-pointer/brief0 confirmed. Perl source/proofs are committed; collection has181 bytes headroom. Read ADR0139, closed Rust/Julia headroom and legacy-frontier fact cards, published migration/reader/CORE contracts. Read-only SPEC-LANG-REFERENCE preflight finds eligible closed commentary and exact uppercase Current Frontier reconstruction. Own this leaf before writes; derive counts from captured source, not a peer epoch.
  Outcome: Existing migration/public queries0/full channels preserve45 ordered IDs/statuses/CORE fields,42 closed pointers/three unchanged bodies/full71681-byte tail.169647 to117394 renews52253 bytes;46 exact public all/node queries/first independent readonly0-empty stderr-ten controls/current target-manifest identities pass. Original templates/actual before-use inputs/outputs/Git source graph retained. No cap/tool/runtime/registry change; no current language-completeness or disk-reclamation claim. Evidence: docs/checkpoints/task-headroom-spec-reference-2026-11-11/REVIEW.md. Independent Rust78.6.2 follows normal clean landing.
  Landing checks: Scope1941 members/17 pages, Knowledge1739 facts/12411 keys, mdBook0, memory architecture0, history pressure0 and whitespace0. Required changelog rollover preserves185 complete lines in segment4928 under existing history policy; current root186 lines/28749 bytes. Normal hooks govern landing; no broad/canonical CI or push.


- ID: `TYPE-REFERENCE-BOOK.1.2.23.4.30`
  Status: `active` / director priority publication-size guard; bounded monitor30.1 focused-complete, publication30.2 pending
  Goal: Keep every outgoing push comfortably below GitHub's2GiB single-push limit; publish around1,500,000,000 estimated bytes even before PNT/batch cadence completes.
  Authority: Director2026-11-12 overrides earlier push-only-at-batch-end/PNT-boundary wording; full CI before every push remains mandatory. Official limit: https://docs.github.com/en/get-started/using-git/troubleshooting-the-2-gb-push-limit.
  Dependencies: Current feature must be handoff-ready before pivot; implemented-normal canonical discovery23.4.1 and existing before-push prerequisites must be satisfied for the exact early publication candidate.
  Acceptance: Measure outgoing HEAD against origin/main using revision-bound serialized pack estimates, not commit count or repository disk size. Record source refs/object scope/producer/options/channels and uncertainty; use same-volume ignored scratch, bounded memory/one pack worker. Monitor after each leaf and before large growth, prepare publication with headroom, then clean exact-HEAD canonical proof/normal workflow/push/post-push monitoring. Never put diagnostic packs into Git or rewrite history/force-push/modify another repository. Keep policy/memory/book/task continuity durable and distinguish estimate from actual negotiated wire size.
  Schedule: From clean Dart102ec3446, complete bounded measurement30.1 first. Monitor after every leaf and before large growth; prepare discovery/full-CI publication with margin and publish around1.5GB regardless PNT/batch cadence. Feature PNT may continue below the preparation boundary; never pivot dirty or wait for cadence when budget requires publication. Existing canonical discovery23.4.1 precedes publication30.2. Old operational measurement/native-custody gaps remain owned until verified or explicitly scoped into the broader4.2/SESSION5 audit.
  Planned verification tier: Select actual tier before changes; mechanical Git/CI/hook changes require canonical proof, documentation/measurement-only work remains scoped under current doctrine.
  Planned claim verification: Declare actual measured-pack scope/producer/input/RED/retention limits before publishing a durable measured claim; native Git/cache/compression/remote negotiation closure must not be implied from a byte estimate.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.4.30.1`
  Status: `completed` / bounded operational proof; qualified landing repairs
  Goal: Establish a reusable read-only outgoing-pack monitor and independently validated committed-HEAD telemetry for the director1.5GB early-push rule.
  Dependencies: Clean Dart102ec3446407543c5ef64f3222bd0fffb5eb3064; all10/post-pointer/brief0/clean verified. Parent30 and canonical Git publication fact own the policy. No Git/CI/hook, storage/path policy, dependency, language or public runtime contract change.
  Acceptance: Retain exact measurement producer/project wrappers and selected non-secret Git pack configuration before use. Freeze actual local HEAD/cached origin refs/object list/commands/options/channels and largest blob; one worker/64m window/same-volume ignored output. Verify streamed bytes/stat/PACK/footer and empty-range control. Independently inspect the actual serialized file and reject wrong-size/checksum/ref/threshold metadata controls; preserve object-scope distinctions and original failures. Keep diagnostic packs out of Git. Publish durable source/receipt pointers, explicit native/physical/toolchain/remote freshness gaps and a next-action decision from actual headroom. Prepare before1.5GB with conservative margin; no automatic push or retired publisher replay.
  Verification tier: `focused`
  Focused checks: One actual committed-range measurement and current-ref checks; independent retained-byte/metadata/counterfactual controls, source/input/channel/mode custody and current identities; book/Knowledge/scope/history/memory/diff and normal hooks. No SDK execution or broad CI for this measurement-only leaf.
  Canonical trigger: Before every actual push, after exact current canonical discovery23.4.1; any later mechanical Git/CI/hook/storage/path/doctrine change is a separate canonical leaf.
  Claim verification: `docs/claims/TYPE-REFERENCE-BOOK.1.2.23.4.30.1.json`
  Activation: Clean102ec3446, branchmain/102 ahead of cached origin4683555e, no jobs/uncommitted files/brief0. Read parent30, current Git publication fact, ADR0073, relevant book CI/publication sections, actual previous estimator and sparse-scope diagnosis. Discovery4.1 key acceptance/large deferred inventory recovered; its full activation read remains before any registration edits. Current producer is checkpoint-only measurement, not CI/hook enforcement. Wider native/transitive/toolchain4.2/SESSION5 and original claim gaps are not implied closed.
  Next: Capture actual producer inputs, measure new committed HEAD, validate independently, then choose feature continuation or pre-push preparation from observed byte margin. Do not replay old intake or failed first normal commit.

  Actual measurement: One serial producer0/empty outer stderr at HEAD102ec3446/base4683555e,102 ahead, explicit no-sparse non-thin1,257,281,519 bytes;45,549 logical/header objects,242,718,481-byte trigger margin. Source/stat/footer/empty-range/ref/config controls0. Raw pack ignored on this volume. Independent validator1: native index0, verify1 because independent.idx makes Git look for independent.pack while the file is outgoing-estimate.pack. Exact native error/commands/channels and original source remain retained. Root cause is this controller's mismatched index/pack stem, not a size observation. Own/fix now in a separate qualified validator: reuse the successful original index with a matching stem, preserve original failure, repeat the incomplete validation epoch only; never remeasure or mutate the used producer.

  Qualified validation: Separate matching-stem validator0/empty stderr reuses the completed original index0; actual verify0 covers all45,549 required objects with zero extras. Full actual file/stat/SHA/footer and32-byte empty-range control pass;12 reason-sensitive receipt/fact corruptions are observed RED. Original validator1/native index0/verify1/source/channels remain unchanged. No new pack or SDK run. Record now declares checked re-derivation/falsification and an explicit physical/native/toolchain durability gap under4.2; no remote freshness/wire/future-size claim. Preparation advisory1.4GB and trigger1.5GB are both false at current1.257GB; continue PNT after monitor commit/recheck while margin permits.

  Completion: Reusable checkpoint-only producer0 records1,257,281,519 bytes/102 commits/all45,549 logical and packed objects/zero extras/242,718,481 trigger margin. Qualified native verify0 and12 falsification controls; first readonly historical recovery0/three controls/current five producer inputs. Original validator1/native index0/verify1/source/channels remain, with successful index reused under matching stem and no new pack. Full physical/native/raw/toolchain durability gap remains4.2/SESSION5; cached remote only, no wire/future guarantee.
  Publication:207 accepted records/231 historical/zero live bindings and four injected live-binding REDs precede shared edits; no old claim/hash/revision refresh. Book/Knowledge/frontiers/live/pointer and actual publication inputs/outputs retained. Full CI not run for this measurement-only leaf; no Git/CI/hook/runtime/storage-policy change or push. Remeasure after clean commit; independent Julia80.4 while margin permits. Canonical discovery4.1/publication30.2 remain before the size-driven push.

  Landing checks: Metadata recovery0/three controls, actual independent validation0/12 controls, current five producer/policy/wrapper/config/ref inputs0, publication0/recovery0/three controls, prose-copyedit0 with exact command/budget preservation. Knowledge1749 facts/12471 keys; scope1951/17 pages; final mdBook0 (known search-index18.2), memory0, document-history0/16 recent rows, pressure0 (changes41166/notes57893 bytes below mandatory rollover), whitespace0. Explicit native gap is added to its open4.2/SESSION5 owner and schedule. Normal hooks govern landing; no full CI or push on this measurement-only leaf.

  Landing defects (owned/fix now): First normal commit1 has eight PASS/two failures. CI book2074 exceeds diagnostics2048; its maintained-reference5000 ceiling does not replace the stricter overlapping diagnostics control. Route the exact new26-line section to the existing Documentation Workflow chapter984/5000, after accepted-claim query, and leave one CI pointer; no cap/registry/new-page change. The old Dart operational gap owner30 is rejected because this activation used in_progress; actual check_claim_verification.py schema recognizes exactly pending/active/blocked as open repair owners. Use active for the still-open parent; do not change the checker contract. Retain original combined log/source/modes and prove both repairs through exact routing and actual parser RED/GREEN before retry. No measurement or SDK replay.

  Qualified landing: First normal1/eight PASS/two failures is preserved in landing-pressure/. New26-line publication section moves intact (heading-only adjustment) to the existing Documentation Workflow page; CI returns2048 with one pointer, workflow1013 stays below5000. Existing registry/SUMMARY/checker/claim hashes and measured values are unchanged. Separate accepted207-record/130-historical/zero-live query and its live-binding RED protect the new destination before editing. Actual unchanged production owner parser gives original in_progress RED, corrected active GREEN, closed RED with exactly one match each; parent30 remains active. Historical landing reader0/three controls recovers complete source/log/mode/route/schema proof without replaying it. Original measurement/validator/publisher/seal remain immutable. Normal retry governs landing; no pack or SDK replay.

  Final qualified checks: Actual rendered CI link/workflow target/command/budgets0 with HTML inputs retained before inspection; CI2048/workflow1013 and both existing budget contracts pass. Knowledge1750/12476 keys; scope1952/17 pages; final mdBook0/known18.2 index warning; memory0/history0/16 recent rows/whitespace0. Unchanged production-parser probe and source/log/mode landing recovery0-three controls confirm both corrections. Normal retry still governs landing; no checker/registry/measurement or SDK change.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.4.30.2`
  Status: `pending`
  Goal: Publish the exact clean candidate around the director1.5GB outgoing-pack budget after all prerequisites.
  Dependencies: Monitor30.1; completed current canonical discovery23.4.1 and existing before-push owners; actual sufficient shared-host RAM; fully staged exact candidate/canonical receipt/normal commit/clean tree.
  Acceptance: Recheck fresh remote identity and outgoing serialized size before data transfer, preserve required producer-reuse policy, run full canonical CI for exact staged/committed candidate, push only root main through normal hooks without force/tags/submodule recursion, and observe remote success/local equality/post-push CI status under hosted-disabled policy. Record receipts/ref identities/size uncertainty and resume PNT. Never approach GitHub2GiB or use retired one-off publishers/history rewrites. No duplicated canonical run when an exact receipt is reusable.
  Planned verification tier: canonical.
  Planned focused checks: Exact current pack/refs, canonical selection prerequisites and normal hooks, post-push remote/local/status checks.
  Planned claim verification: Declare actual measured scope and proof legs at activation; never claim negotiated wire bytes from a local estimate.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.4.31`
  Status: `completed` / dated focused maintenance; full native custody separate
  Goal: Perform the scheduled safe daily artifact review, preserve exact completed owned logs before any duplicate retirement, and restore the missing publication-owner child link.
  Dependencies: Clean Julia a3faaf97292550ba1e3001604e1e379d478bcdd4/all10/post-pointer/brief0 verified; fresh committed-range monitor0; docs/ARTIFACT_CLEANUP.md last2026-11-11T15:29:23.870616+00:00. Run now before long Lua80.5 crosses the daily window.
  Acceptance: Capture fresh metadata in the existing eight named root/Rust/log scopes with configured Cargo target covered, independently compare scandir/lstat rows, and retain all census candidates. Reuse only explicitly captured source templates. Select only exact nonexecuting single-link own logs from completed normal commits; archive full bytes/modes, verify independent actual recovery before unlinking, recheck identity/hash immediately before deletion and prove exact residue. A tracked proof reference or unavailable ownership/liveness evidence means retain. All caches/native products/other repositories/submodules/unselected proof remain protected. Overwrite latest-only cleanup date/summary, sync live docs/book/Knowledge and commit. No physical space-reclamation or global-liveness claim.
  Verification tier: `focused`
  Focused checks: Named-scope primary/independent metadata, altered-evidence controls, exact completed-log all10/post-pointer/Git identities, source/channel/mode custody and independent predelete/default recovery. Exact public parent/leaf task queries after child-link repair; book/Knowledge/scope/history/memory/diff and normal hooks. No SDK or broad regression run.
  Canonical trigger: Final clean push/mechanical infrastructure change; this slice changes only checkpoint data/instruments, task tracking and live documentation under existing cleanup policy.
  Claim verification: `docs/claims/TYPE-REFERENCE-BOOK.1.2.23.4.31.json`
  Activation: Julia a3faaf972/all10/post-pointer/brief0/clean verified; no remaining job. Relevant daily cleanup/current safety fact cards, previous actual scanner/archiver/reader/source contracts and book maintenance section read. Source reuse must preserve actual composition inputs before use; no old writer replay. Operational telemetry at this clean HEAD/cached origin4683555e is1,287,859,376 bytes/104 ahead/212,140,624-byte1.5GB margin, excluding this maintenance slice; independent-current/native durability gaps remain30/4.2. New actual record retains metadata and disclosures. Prepare near1.4GB and publish around1.5GB regardless cadence, with canonical discovery/full CI/normal hooks/clean exact HEAD first.
  Tracking defect (owned/fix now): Public read_task_tree.pl --tree TYPE-REFERENCE-BOOK --id TYPE-REFERENCE-BOOK.1.2.23.4 shows the parent Children list ending at29 although publication owner30 and children30.1/.2 exist. Impact: manual hierarchy omits the new budget owner despite successful stable lookup/index checks. Add30 and this31 exactly once, preserving every old child and the parent admission contract. This is a data repair, not a new checker rule or a claim that all hierarchy omissions are prevented.
  Actual proof: Fresh accepted-template preparation/census/replay0;1316 metadata rows in eight named scopes agree and every census candidate remains. Three exact completed owned normal logs retain133480 content bytes/full original modes before independent predelete0 and exact plain-duplicate retirement at2026-11-12T15:32:21.895461+00:00. Separate postdelete readonly0/empty stderr rejects16 metadata/source/log/channel/parent-link corruptions. Parent30/31 registration changes only the one Children field, and three public parent/leaf queries recover exact nodes. Source helpers precede import; wrappers are recovered at accepted activation Git bytes for historical checks. All original templates/commands/channels remain, with full native/OS/transitive custody gap4.2/SESSION5 and auxiliary pack gaps30/4.2 disclosed.
  Next: Publish the actual dated outcome and latest-only cleanup record. Shared publication query/recovery0 retains209 accepted records/249 historical intersections/zero live and six injected live-binding REDs before book/frontier publication. It follows the separately captured owned task activation/parent-link data fix and does not retroactively claim to precede that fix. Preserve all old claim/hash/revision data; finish book/Knowledge/live docs and normal commit. Fresh size check and independent installed Lua80.5 follow while margin permits.

  Completion: 1316 matching metadata rows/eight scopes retained; three exact completed own combined logs/133480 content bytes/full modes independently recovered before plain-copy retirement. Postdelete readonly0/empty stderr/16 corruption controls and three exact public task queries pass. All other proof/caches/native products/repositories remain retained; no physical reclamation claim. Retirement timestamp2026-11-12T15:32:21.895461+00:00. Parent adds only30/31 links with every other source byte exact; three public queries0. Shared book/frontier query209 accepted records/249 historical/zero live and six injected REDs follows the earlier separately captured task activation/parent data fix. All old claim/hash/revision fields remain unchanged. Actual document producer/reports/documents/modes retained; latest-only cleanup record and16-row live view synchronized. New claims disclose native4.2/SESSION5 and auxiliary telemetry30/4.2 gaps. Remeasure after clean commit, then independent Lua80.5 while margin permits.

  Acceptance Checklist
  - [x] **REPRODUCE / ISSUE** — Due daily record and exact public parent omission30 recovered; no whole-project disposal inference.
  - [x] **ROOT CAUSE (WHY + WHERE)** — Existing policy defines eight scoped metadata walks and exact own completed logs; manual parent Children was not updated for30.
  - [x] **FIX** — Archive/full-mode recovery and independent use precede only three plain duplicate removals; add parent30/31 with other bytes exact.
  - [x] **ADDRESSED (verified)** — Census/replay/predelete/retire/postdelete readonly0-empty stderr/16 effective controls and three public queries pass.
  - [x] **NO REGRESSION** — Census candidates/caches/native/unselected proof/other repositories retained; no shared tool/checker/limit/policy/runtime change or physical-reclamation claim. Full native custody remains4.2/SESSION5.
  - [x] **DOCUMENTATION** — Latest cleanup/book/Knowledge/roadmaps/task/live/pointer synchronized; actual publication images retained, normal checks still govern landing.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.4.31 - review daily artifacts and retain log proof`.
  Evidence: docs/checkpoints/artifact-review-2026-11-12/REVIEW.md; default review.py/historical review_publication.py. All writer modes are completed one-shot; no SDK/full CI/push here.

  Landing preparation: Actual document publication0/independent historical publication recovery0-three controls retain all consumed reports, source/documents/full modes, exact rotated row and separate late driver-origin relation without new first-use credit. Knowledge1752 facts/12486 keys, scope1954 members/17 pages, mdBook0 (known search-index18.2), memory architecture0, history pressure0 (changes298 lines/43192 bytes; notes199/33614) and whitespace0. Book workflow1025/hand-off4999 and current recent rows16 stay within existing budgets. Shared-host memory75% system-wide free before normal gate. No shared tool/checker/limit/policy/runtime change or full CI/push; normal all10/post-pointer/brief0/clean checks still govern landing.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.4.32`
  Status: `completed` / bounded existing data epoch with focused proof
  Goal: Renew bounded task-evidence headroom through a compatible existing closed-task data epoch.
  Dependencies: Clean Lua80.5/9f11029e5/all10/post-pointer/brief0; fresh committed size before further growth.
  Acceptance: Use the published unpartitioned PROJECT-DATA-SSD-ROOTING data interface only. Preserve ordered IDs/all CORE fields/statuses, every unselected body, metadata and complete Current Frontier/trailing bytes. Retain exact activation Git/source, all actual producers/inputs/full modes/channels and whole-source/every-ID queries; independent preservation/corruptions/current identity. Keep tools/limits/schema/runtime and historical feature admission unchanged. Commit before resource4.14/current discovery/publication preparation.
  Verification tier: `focused`
  Focused checks: Existing epoch writer and exact public queries; independent source/CORE/body/full-tail recovery and corruptions/current identities; task metadata/resulting-tree pressure, book/memory/history/scope/normal hooks. No SDK replay.
  Canonical trigger: Full23.4/final clean push; actual tool/policy/infrastructure changes require a separate canonical leaf.
  Claim verification: `docs/claims/TYPE-REFERENCE-BOOK.1.2.23.4.32.json`
  Activation: Clean9f11029e5af9d6168925f532d4c1911637421af3. Lua first normal date/task-cap defects are corrected with exact prior bodies retained; final all10/post-pointer/brief0/clean verified. Task cap has little remaining space, so this data epoch precedes larger infrastructure records. Existing normal-hook archive contract/TASK_TREE_README/published tool and headroom29 template reviewed. SPEC-FORMAT-TERSE is unpartitioned, no Scope/prior-epoch field, one exact uppercase frontier, closed stable states; selection/query counts derive from its own actual source. Audit/qualified-status candidates were not activated. Actual fresh monitor0 at this HEAD/cached origin4683555e is1,352,197,517 bytes/106 ahead/46,757 objects/147,802,483 bytes to1.5GB and47,802,483 to advisory1.4GB. No fresh-remote/wire/future guarantee; auxiliary current-falsification/native gaps30/4.2 remain explicit. Same-volume/serial/shared24GiB policy applies; no foreign repo or dependency implementation writes/reads.

  Source qualification: Actual terse capture1 is retained under docs/checkpoints/task-headroom-terse-2026-11-12. Tool migrate_epoch132 reports no closed narrative capacity before mutation. All189 source records already contain original Narrative pointers, a separate exclusion from later Narrative epoch pointers. The vocabulary-only preflight supplied no capacity credit. Git/source/full-mode identity and absent32 manifest are captured after refusal; no source or tool change occurred. Keep that attempt immutable. The same headroom32 maintenance goal now selects PROJECT-DATA-SSD-ROOTING:22 closed records, no original/epoch pointers or Scope fields, no index, one exact uppercase frontier and no direct machine reference found. A new qualified operation checks actual eligible reductions first; no old cleanup, source reading or SDK work is replayed.


  Acceptance Checklist
  - [x] **REPRODUCE / ISSUE** — Prior Lua normal task-cap failure and compact own-commentary routing leave little room;9f source/input identities retained.
  - [x] **ROOT CAUSE (WHY + WHERE)** — migrate_epoch132 skips original Narrative and epoch pointers; terse189 already compacted. Actual guarded1/unchanged source is independently recovered; rooting17 eligible preflight matches actual selection.
  - [x] **FIX** — Existing rooting epoch32 preserves22 ordered IDs/all CORE/five complete unselected bodies/prefix/full35225-byte tail;17 pointers renew40587 current-text bytes without changing limits/tools.
  - [x] **ADDRESSED (verified)** — Actual migration0/all23 public queries0-empty stderr, first historical readonly0-ten effective corruptions/current source-manifest identity0; prior refusal recovery0-three controls.
  - [x] **NO REGRESSION** — Exact before/after/Git/native command channels/full modes; all contracts/statuses/full tail survive. No original source/tool/claim hash rewrite, SDK/cleanup replay or new parity/physical-reclamation claim.
  - [x] **LOCKSTEP** — Book/Knowledge/roadmaps/task/index/live/pointer/scope/history align; normal hooks govern clean landing before resource4.14/current discovery/publication.
  Outcome: docs/checkpoints/task-headroom-rooting-2026-11-12/REVIEW.md; default review.py/review_refusal.py and public epoch queries. Current identity is pre-staging only. Earlier docs/checkpoints/task-headroom-terse-2026-11-12 stays immutable with no migration credit. Actual before-use producer/report/document images and publication recovery retained.
  Claim boundary: Finite named task/byte-preservation controls; separate operational telemetry record discloses actual9f pack1,352,197,517/106 and current-falsification30/native4.2 gaps.211 accepted records/207 historical intersections/zero live/eight injected REDs precede rooting/book edits after task activation. Original hashes/revisions remain. Full source/context/admission23.4/historical4.24/raw-error4.28/launcher/SESSION7/literal/excluded/declared5.4/formatter remain owned. Fresh size after commit; canonical publication preempts cadence near1.4-1.5GB.
