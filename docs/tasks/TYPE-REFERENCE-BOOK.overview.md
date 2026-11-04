# TYPE-REFERENCE-BOOK: Complete navigable per-type language reference

## Metadata

- Tree ID: `TYPE-REFERENCE-BOOK`
- Status: `active` / remaining fluent-family and inter-type feature selection; full reference/admission open
- Roadmap lane: `.spec language documentation / complete type and method reference`
- Created: `2026-10-10`
- Last updated: `2026-11-04`
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
  Children: `.23.1.1`, `.23.1.2`, `.23.1.3`, `.23.1.4`, `.23.1.5`, `.23.1.6`, `.23.1.7`, `.23.1.8`, `.23.1.9`, `.23.1.10`, `.23.1.11`, `.23.1.12`, `.23.1.13`, `.23.1.14`, `.23.1.15`, `.23.1.16`, `.23.1.17`, `.23.1.18`, `.23.1.19`, `.23.1.20`, `.23.1.21`, `.23.1.22`, `.23.1.23`, `.23.1.24`, `.23.1.25`, `.23.1.26`, `.23.1.27`, `.23.1.28`, `.23.1.29`, `.23.1.30`, `.23.1.31`, `.23.1.32`, `.23.1.33`, `.23.1.34`.
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
  Children: `TYPE-REFERENCE-BOOK.1.2.23.3.1`, `.23.3.2`, `.23.3.3`, `.23.3.4`, `.23.3.5`, `.23.3.6`, `.23.3.7`, `.23.3.8`, `.23.3.9`, `.23.3.10`, `.23.3.11`, `.23.3.12`, `.23.3.13`, `.23.3.14`, `.23.3.15`, `.23.3.16`, `.23.3.17`, `.23.3.18`, `.23.3.19`, `.23.3.20`, `.23.3.21`, `.23.3.22`, `.23.3.23`, `.23.3.24`, `.23.3.25`, `.23.3.26`, `.23.3.27`, `.23.3.28.1`, `.23.3.29.1`, `.23.3.29.2`, `.23.3.30`, `.23.3.31`, `.23.3.32`, `.23.3.33`, `.23.3.34`, `.23.3.35`, `.23.3.36`, `.23.3.37`, `.23.3.38`, `.23.3.39`, `.23.3.44`, `.23.3.45`, `.23.3.46`, `.23.3.47`, `.23.3.49`, `.23.3.48`, `.23.3.40`, `.23.3.41`, `.23.3.42`, `.23.3.43`, `.23.3.50`, `.23.3.51`, `.23.3.52`, `.23.3.53`, `.23.3.54`, `.23.3.55`, `.23.3.56`, `.23.3.57`, `.23.3.58`, `.23.3.59`, `.23.3.60`, `.23.3.61`, `.23.3.62`, `.23.3.63`, `.23.3.64`, `.23.3.65`, `.23.3.66`, `.23.3.67`, `.23.3.68`, `.23.3.69`, `.23.3.70`, `.23.3.71`, `.23.3.72`, `.23.3.73`
  Goal: Resolve every verified method-family and type-transition gap through bounded implementation leaves.
  Dependencies: `TYPE-REFERENCE-BOOK.1.2.23.2`
  Acceptance: Before activation create per-operation/family and backend children from the gap matrix. Each owns its contract, native/generated implementation, independent RED/GREEN and source inverses, compatibility, current book examples and separate commit. Existing defect owners remain authoritative. Generic, boolean/null and codeblock operations must follow their real semantics, including dispatch on a callable's yielded value rather than a fabricated codeblock method table.
  Planned tier: Select for each bounded child; public contract/admission changes require canonical proof.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.4`
  Status: `pending`
  Children: `TYPE-REFERENCE-BOOK.1.2.23.4.1`, `TYPE-REFERENCE-BOOK.1.2.23.4.2`, `TYPE-REFERENCE-BOOK.1.2.23.4.3`, `TYPE-REFERENCE-BOOK.1.2.23.4.4`; remaining admission leaves split at activation.
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
  Trigger: Custody67.6 confirms an inherited fixture-glob/changed-nearest-selector mismatch in five named67 packets. Its bounded companion closes only the thirteen specified edges. Reused earlier templates require an explicit review; no additional omission population or runtime regression is inferred without tools.
  Priority/schedule: After ordinary feature coverage, with admission prerequisites and in coordination with SESSION-STARTUP-READING.5 claim/producer audit, before23.4 admission/final push. This owner remains accountable until any explicit transfer; no dirty-feature global audit pivot.
  Acceptance: Inventory actual selected direct consumers and literal/constructed fixture loaders for the earlier captures, beginning source-role families63–66 and expanding through their real dependencies. Compare against retained byte identities, not filename lists or summary receipts alone. Own and repair each demonstrated omission with immutable companions/historical recovery and explicit original-observation limits; re-run focused behavior only where missing freshness or changed evidence requires it. Use distinguishing missing-input/provenance controls, retain actual producers/all direct artifact inputs and verify retrieval. Preserve original captures/results/history, black-box dependency boundaries and existing backend policies. Coordinate broader transitive/toolchain/producer census with its canonical owner; do not claim it from a direct-input inventory. Close only after verified repair and designated canonical proof.
  Planned verification tier: canonical.
  Planned focused checks: Retained-consumer/direct-input audit, historical-source recovery, distinguishing byte/provenance negatives and affected focused suites with exact input identities; original packet/history preservation and claim/book/continuity checks.
  Planned canonical trigger: Admission prerequisite/declared capture-closure closeout before push; infrastructure changes split into explicit canonical leaves if needed.
  Planned claim verification: none: This node schedules review of a demonstrated template-reuse risk; no additional missing-input census, measured repair or current runtime failure is claimed.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.4.1`
  Status: `pending` / P1 canonical admission prerequisite
  Goal: Register new bounded feature regressions in canonical CI before full admission/final push.
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
  Status: `pending`
  Priority: P2; before any append would exceed the existing current-task collection budget.
  Goal: Renew current task collection headroom through another source-bound closed-narrative extraction while retaining every current obligation and all existing ceilings.
  Dependencies: Accepted20.1.10; preserve the selected Count73 feature sequence unless the actual gate would reject further task growth.
  Reproduction/impact: The restored current collection passes its existing aggregate byte cap with less than one percent headroom. Additional evidence can consume this margin, so normal-hook restoration is not a lifetime task-growth allowance. This is a prospective capacity concern, not a current failing gate or arbitrary cap-increase request.
  Schedule: Reassess after bounded Count73; activate earlier if a proposed append would cross the cap. Use the current capacity checker, classify closed narrative in the next suitable owner, retain exact predecessor/retrieval and independent obligation/open-body proof; do not remove current nodes or edit immutable partitions.
  Acceptance: Meaningful renewed headroom within the original aggregate/file/per-part limits, exact source reconstruction, complete current contracts, negative loss/corruption controls, book/continuity updates and normal canonical acceptance for infrastructure.
  Planned verification tier: canonical
  Planned focused checks: Selected owner/source census, exact narrative/current-contract preservation and direct reader/index controls; no unrelated historical audit.
  Planned canonical trigger: Infrastructure acceptance and exact clean push boundary.
  Planned claim verification: none: Prospective capacity owner; actual extraction declares its source-bound proof before acceptance.

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
  Status: `pending` / publication custody closeout
  Goal: Retain the actual size-safe publication outcomes and close disclosed initial planning/evidence gaps after the authorized immediate push.
  Acceptance: Preserve actual publisher source, exact initial/final plans, per-batch commands/exits/log bytes, final local/remote identity and canonical receipt. Recover the initial inline measurement instrument or explicitly retain its historical limitation; add non-mutating wrong-budget/chain controls and a reproducible Git-object input identity/retrieval representation before claiming complete measured pack custody. Preserve all published Git IDs. No oversized upload or history rewrite is required.
  Priority/schedule: After the immediate normal-hook publication and due cleanup23.4.6, before unrelated runtime selection. Own until verified closure; the director-authorized early safe push is not blocked on converting the initial diagnostic into a broader measurement claim.
  Planned verification tier: focused; retain publication artifacts and readonly identity/custody controls only.
  Planned canonical trigger: Any mechanical hook/storage change needs a separate canonical leaf; final clean publication follows the current receipt policy.
  Planned claim verification: Explicitly close the two disclosed legs in the publication-transport-plan claim, with actual retained inputs and scoped RED controls.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.4.8`
  Status: `pending` / P1 repository-growth review
  Goal: Assess future retained-artifact growth against GitHub guidance without losing evidence or rewriting accepted history.
  Trigger/evidence: Actual accepted batch10 warns that docs/checkpoints/signed-array-contract-admission/import-epoch-before.json.gz is50.86MB, above GitHub's50MB recommendation. The initial outgoing thin-pack diagnostic is about9.3GB; that is not the server repository on-disk size. GitHub repository-limits guidance recommends10GB on disk and separately labels per-push/object enforcement. Retain the actual warning and primary-source pointers in the6 checkpoint;7 owns transport input custody.
  Priority/schedule: P1 after already selected Rust Count73.2, peers and copy73.6, before unrelated selection. This advisory review does not retroactively invalidate the accepted publication.
  Acceptance: Use committed Git/public host contracts to separate future artifact growth, original pack estimates, actual object sizes and unknown server storage. Prepare bounded lossless prevention options and their producer/reader/claim implications, with a concrete recommendation. Preserve exact historical blobs/IDs, package stores and proof; no blanket cleanup, force push, history rewrite, other-repository write or off-volume migration. Obtain a director decision only for a concrete change that needs authority outside the existing contract. Own any demonstrated defect through verified repair.
  Planned verification: Read-only source-bound assessment first; focused controls for an agreed bounded repair; canonical only if infrastructure or publication contracts change.
