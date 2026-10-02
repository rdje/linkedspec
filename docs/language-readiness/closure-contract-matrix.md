# Language closure matrix and freeze plan

Owner: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.2.1`. Reviewed 2026-10-01 from clean
`6052760272a37702698745c866220679e7e13646`, after canonical finite-inventory closeout.
This is a source-located design plan. It changes no semantic authority, runtime,
admission, generated format, public API or numerical limit.

Subsequent `.1.2.2` freezes operation/scope/reference structure as
`capability_conformance/language_closure_contract.json` (`linkedspec-language-closure-v1`).
Its independent checker is structural governance only. The original design below
retains its review date; deterministic/resource/failure policy and independent
reconciliation have separate owners. Subsequent `.1.2.3` freezes scoped policies,
preserving the original 66 bindings and adding24 (90 total) with 632 reason-sensitive
mutations/four controls. The dated review is docs/language-readiness/closure-policy-boundaries.md.
Independent reconciliation remains `.1.2.4`-owned. The original plan below retains its review context.

## Claim boundary

ADR0064 defines the **target**: normal parsing, extraction and transformation
objectives use portable authored mechanisms rather than routine host escapes.
The **current evidence** is the two inventories, finite gap list and three-objective
reconciliation under `docs/language-readiness/`. Those finite probes establish
their exact grammars, inputs, results, spans, carriers and recovery routes.
They establish neither arbitrary grammar coverage nor whole-format readiness.

**Partial** means a separately owned implementation or proof exception to an
existing contract. **Unassessed** means an objective or guarantee has not been
established. Neither becomes a missing primitive by inference. An admitted family
can have a narrower partial boundary; the manifest's100/0/0 is not a defect count.

The closure authority will reference existing meanings, retain compatibility
exclusions and expose partial/unassessed obligations. It will not promote every
backend operation merely by listing it. Named fixed-parameter arguments retain
their approved, parked `PARSER-AUTHORING-APIS.4` owner. No optional frontend,
recursive user-function, lexical-closure or general bang-method extension is selected.

## Authority register

Every file below is rooted at `capability_conformance/`; its `format` is1.
Contract identities and JSON pointers locate meaning, rather than duplicating
whole fixtures or interpreting old rollout prose as current admission.

| File | Exact contract identity | Relevant JSON pointers |
| --- | --- | --- |
| `root_rule_selection_contract.json` | `linkedspec-root-rule-selection-v1` | `/precedence`, `/validation`, `/selector` |
| `rule_local_cursor_contract.json` | `linkedspec-rule-local-cursor-v1` | `/policy/and_cursor`, `/policy/or_default_cursor`, `/policy/child_cursor`, `/policy/global_override` |
| `typed_source_location_contract.json` | `linkedspec-typed-source-location-v1` | `/policy/source_identity`, `/policy/span`, `/policy/transactions`, `/policy/progress`, `/recursive_observations` |
| `recognition_transaction_contract.json` | `linkedspec-recognition-transaction-v1` | `/authored_surface/result_separation`, `/policy/attempt_result`, `/policy/commit`, `/policy/rollback`, `/policy/progress`, `/effect_model` |
| `inter_match_gap_capture_contract.json` | `linkedspec-inter-match-gap-capture-v1` | `/authored_surfaces`, `/segmentation_cases`, `/lifecycle_matrix` |
| `uniform_binding_contract.json` | `linkedspec-uniform-binding-v1` | `/policy/binding`, `/policy/host_storage`, `/policy/wrong_kind`, `/constructor_policy` |
| `callable_signature_contract.json` | `linkedspec-callable-signature-v1` | `/policy/arguments`, `/policy/rest_binding`, `/policy/overloads`, `/policy/results` |
| `callable_codeblock_contract.json` | `linkedspec-callable-codeblock-v1` | `/policy/context`, `/policy/parameters`, `/policy/results`, `/policy/closures` |
| `logical_helper_contract.json` | `linkedspec-logical-helper-v1` | `/policy/evaluation`, `/policy/truthiness`, `/policy/lazy_controls` |
| `scalar_numeric_contract.json` | `linkedspec-scalar-numeric-v1` | `/policy/accepted_number`, `/policy/aggregate_reducers`, `/policy/invalid_input`, `/policy/round` |
| `write_vivification_contract.json` | `linkedspec-write-vivification-v1` | `/policy/evaluation_order`, `/policy/post_evaluation_snapshot`, `/policy/atomic_commit`, `/policy/detachment` |
| `map_leaves_mutation_contract.json` | `linkedspec-map-leaves-mutation-v1` | `/policy/traversal`, `/policy/reentrancy`, `/policy/failure_effects`, `/policy/continuation` |
| `write_map_leaves_composition_contract.json` | `linkedspec-write-map-leaves-composition-v1` | `/requires`, `/policy/identity_guard`, `/policy/later_callback_failure`, `/policy/post_commit` |
| `progressive_span_dispatch_contract.json` | `linkedspec-progressive-span-dispatch-v1` | `/authored_surface/availability`, `/policy/registry`, `/policy/ceilings`, `/policy/progress`, `/policy/bounds` |
| `staged_ast_enrichment_contract.json` | `linkedspec-staged-ast-enrichment-v1` | `/policy/authority`, `/policy/queue`, `/policy/state`, `/policy/failure`, `/policy/detachment` |
| `diagnostic_output_contract.json` | `linkedspec-diagnostic-output-v1` | `/policy/delivery`, `/policy/result_neutrality`, `/policy/sink_failure`, `/policy/exit_now` |

The two inventory ledgers supply backend consumer paths and evidence dates. The
contracts' rollout/recurring fields, current manifest and producing task records
supply admission where present. The three mutation artifacts intentionally retain
pre-implementation status strings: admission and recurrence are owned by
`FUTURE-PARITY-BACKLOG.19.7-.19.9`, not by rewriting those frozen strings.
ADRs0056,0080,0088 and0042 own source/cursor, private progressive composition,
staged scheduling and diagnostic delivery; ADR0064 owns the closure direction.

## What authored code may do

| Dimension | Target and current mechanism | Exact boundary / proof obligation |
| --- | --- | --- |
| Compute | Typed scalar/aggregate expressions, fixed/final-rest pure functions, deferred callable blocks, eager helpers and selected controls | Explicit once-only evaluation and value kinds belong to each authority. Function and callback recursion, defaults and named calls are outside the current callable contracts. Broad mixed-control composition is unassessed and Dart has an owned exception. |
| Recognize | Declared linked rules, intrinsic seek/consume families and advancing rule recursion | Entry selection does not itself match the entry regex. AND consumes, OR/default seeks; children retain their own policy. Strict prefix/gap/end checks remain authored. No general left recursion or systemic backtracking is inferred. |
| Observe | Caller-authorized source, current typed bindings, capture boundaries/marks, source-bound matches/gaps and detached recursive records | Public projections use Unicode-scalar half-open provenance. Internal Position/Span and detached records do not grant live source or dispatch authority. Copied text, gaps and arbitrary spans are not new public staged operands. |
| Mutate | Invocation working state, explicit cursor/boundary/mark operations, typed nested writes and guarded root-kind leaf transformation | Cursor restore/rewind changes cursor only. Recognition rollback is a different bounded operation. Root publication is atomic under its owner; completed expression or unrelated callback effects are not globally rolled back. |
| Return | Owner-approved typed values, capture text/records, ordinary child payloads and detached mutation/staged results | Match presence, payload truthiness and payload kind remain distinct. Private tokens/live handles cannot cross their boundaries. A partial type-preservation or detachment repair blocks the affected claim. |
| Emit diagnostics | Explicit diagnostic helpers deliver ordered typed events to an optional caller-installed sink | No sink means quiet execution; events do not enter parse results or trace. Sink failure propagates immediately. Authored helpers do not select a host stdout/file/network destination. |
| Obtain authority | Caller supplies input, entry selection, supported options and any precompiled registry/operational grants | Authored data, parser IDs, source spans, markers and results do not authorize loads, compilation, provider queries or registry mutation. Private progressive admission does not create an outward API. |

Ordinary portable authoring and caller orchestration are separate. A caller may
load authorized source or install a sink/compiled child registry through documented
APIs. The child `.spec` still owns recognition; a host callback implementing the
grammar would not establish the self-containment objective. Raw host fallback,
legacy plugin behavior and compatibility aliases are excluded from the preferred
portable closure claim. They are not evidence of default ambient non-authority.

## State, scopes and publication

| Context | State visible / restored | Consequence |
| --- | --- | --- |
| Rule invocation | Source/cursor/capture lifecycle and scoped declared working state; the nesting/context probes explicitly restore their recursive authored state | Rule recursion is not pure-function recursion. No automatic rollback of arbitrary user state or AST is claimed. |
| Pure user function | Eager caller arguments, then fresh function-local parameters and working variables | No implicit caller-state capture, persistent caller mutation or recursive call. The historical MVP scope is recorded in `docs/knowledge/terse-user-defined-functions-mvp-contract.md`; the signature authority extends final-rest binding. |
| Deferred codeblock | Construction executes nothing and captures no environment; invocation uses live caller nonparameters with copied temporary parameters restored afterward | Nonparameter mutation can persist. Return is block-local. Codeblock scope is not lexical closure scope. |
| Recognition attempt | One source/rule/invocation-bound linear token, one attempt and one terminal; staged payload separate from strict match boolean | Commit preserves recognized cursor/boundary/marks; rollback restores their owning snapshot. The closed effect graph excludes arbitrary writes, output, dynamic calls and dispatch. Known token/abort/type exceptions remain partial. |
| Recursive observation | Existing monotonic invocation authority and one immediately detached record | No second stack, retained parse history or live frame. Accepted exit is nullable and outcome is separate from payload. |
| Nested write | Segment expressions then RHS, followed by post-evaluation root snapshot and isolated structural publication | A later structural failure preserves completed expression effects. Reads never vivify. |
| Leaf transformation | Resolved receiver identity, isolated original-shape root-kind traversal and copied callback frames | Receiver failure prevents its publication, while earlier unrelated effects persist. Continuation runs after commit and cannot retroactively undo it. |
| Composed child parse | Fresh child parser state; caller-frozen registry and narrowing operational authority | Private synchronous dispatch leaves parent cursor unchanged. Staged children run after the complete parent AST and share only the scheduler's specified monotone authority. |

## Determinism, progress, resources and failure

Determinism must specify the canonical program, decoded source/identity, explicit
typed inputs/options and caller authority. Cancellation/deadline observations and
sink behavior are operational inputs, not authored clock/network access. Ordered
rule selection, once-only evaluation, root-kind traversal and staged typed-path
ordering have existing authorities. No timing-independent outcome, regex
preemption, unrestricted-depth or performance guarantee follows from finite proof.

Progress is scoped. The typed-source target requires cursor advance or a
well-founded decreasing measure. Recognition/observation enforce stricter cursor
advance during active accepted repetition/recursive edges; one-shot zero-width
recognition remains legal. Ordinary same-position rule recursion has dated guard
evidence, while its general diagnostics/repetition limits require separate review.
Staged/progressive child work does not satisfy parent cursor progress; its own
chain, containment, depth/call/step and cancellation rules apply.

The runtime appendix's general threshold and error prose is a review input, not
an independently admitted universal limit or failure schema. `.1.2.3` must reconcile
it with scoped authorities and public projections, coordinating startup `.41.2`.
Freeze inherited resource policies and explicitly unresolved limits; do not choose
new global numbers. Progressive source-detail interpretation versus authorized
parser input remains with startup `.37.2`; no confidentiality guarantee is inferred.

Failure/publication must remain a matrix, not one universal transaction:

- Recognition distinguishes miss/falsey payload/typed misuse and has recognition-only restoration.
- Nested structural failure preserves the post-expression binding state; evaluation errors propagate unchanged.
- Leaf callback failure preserves receiver state and completed unrelated effects; continuation failure follows a completed commit.
- Private progressive dispatch is fail-only; it does not imply retry or fallback.
- Staged `fail`, `keep_text` and `diagnostic_node` have separate publication and sidecar policies.
- Diagnostic sink failure and typed exit stop later work. Public loader/carrier error projections retain their own schema/channel; the native Rust text probe is Display-only.

## Partial and unassessed obligations

`docs/language-readiness/finite-gap-list.md` retains the original repair
owners, priorities and dependencies. This matrix additionally follows already-owned
exceptions relevant to the broader closure statement; it discovers no new runtime defect:

| Boundary | Existing pending owner | Before dependent promotion |
| --- | --- | --- |
| Dynamic codeblock receiver writes | `SESSION-STARTUP-READING.19` | Validate resolved receiver identity through dynamic callback writes and supported carriers. |
| Token text and compilation order | `SESSION-STARTUP-READING.21` | Establish lexical escape validation and compile-order independence. |
| Dynamic codeblock boolean literals | `SESSION-STARTUP-READING.35` | Distinguish JSON booleans from numeric0/1 through literal/aggregate/callable carriers. |
| Recognition commit boolean payloads | `SESSION-STARTUP-READING.39` | Establish kind preservation separately from falsey acceptance. |

These supplement, not replace, recognition `.38/.40`, host-slot `.17`, mutation
`.58/.59`, numeric `.94/.95`, Dart mixed-control, staged/progressive resource and
backend proof obligations in the finite ledger. Their `.3/.4/.5` reading/policy
dependencies remain intact. Do not promote through a successful workaround.

Unassessed objectives retain `.1.3` selection and `.1.4` evidence-backed audit:
indentation, quotes/escapes/comments, richer diagnostics/recovery, callable/control/
mixed-tree transformation composition, general resources/performance and whole
formats. Speculative AST rollback, expanded staged operands and additional callable
semantics require an agreed objective before extension.

Default authored filesystem/process/network/environment/clock/randomness/package/
FFI authority is excluded by ADR0064. This policy and compatibility exclusion are
not an execution sandbox proof. Explicit caller transports, trusted precompiled
authority and diagnostic delivery stay documented host responsibilities.

## Bounded freeze plan

| Leaf | Deliverable | Verification / admission boundary |
| --- | --- | --- |
| `.1.2.2` | One versioned neutral closure artifact and independent structural validator for included/excluded operations, source identity, distinct scopes, typed results, state/effect/publication boundaries and authority references | Bind exact identities/relevant semantic anchors and proof owners, preserving frozen historical strings and current partial status. Reason-sensitive mutations must challenge each dimension and reject unrelated-error substitution. Canonical tier; no runtime/profile-only mechanism or backend promotion. |
| `.1.2.3` | Explicit deterministic inputs/order, scoped progress, inherited resources, failure channels and ambient non-authority | Review ordinary guards and appendix prose before claims; distinguish target/current/partial/unassessed, caller input from outward detail and selected finite accounting from global bounds. Bind unresolved policies to existing repair owners. Canonical tier; no unsupported numerical/security guarantee. |
| `.1.2.4` | Independent matrix/artifact/validator/book reconciliation | Preserve original authorities and admission states, verify all declared partial/deferred owners and exact claim limits, then run staged canonical proof for definition-parent closeout. This does not close runtime repairs or prove whole-format closure. |
| `.1.3` | Bounded selected composition objectives, neutral fixtures/mutations and six-runtime recurrence split before implementation | Preserve original three probes; select independent positive/negative, effect, value-kind and failure/publication oracles. Complete affected repair prerequisites before dependent promotion. |

New authority/checker paths are selected by `.1.2.2` before creation. Use the
repository-local wrappers and existing neutral/runtime owners. Structural validation
is governance proof, not an evaluator for the authored objective. Only `.1.4` may
select new missing primitives from minimized public failures against agreed requirements.

## Reverification

Check all sixteen format/identity/pointer rows, current supplemental task statuses
through `tools/read_task_tree.pl`, and the original objective audit. Run affected
existing public/neutral guards, `bash tools/run_mdbook_local.sh`, Knowledge/memory/
history/doctrine checks and `git diff --check`. This design leaf runs no new backend
objective and changes no executable authority. Normative freeze and final parent
acceptance remain with the named canonical leaves.
