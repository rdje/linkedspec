# SESSION-STARTUP-READING: semantic part 04-49

Current task evidence; navigation and frontier: docs/tasks/SESSION-STARTUP-READING.md.
After an owned edit run: perl tools/update_task_tree_index.pl --tree SESSION-STARTUP-READING

- ID: `SESSION-STARTUP-READING.4`
  Status: `pending`
  Goal: Read the complete mdBook and check its explanations against the roadmap and codebase.
  Acceptance: Split by SUMMARY.md chapters and bounded ranges before execution; read every chapter and own any verified drift.
  Verification: Physical source reading is complete under .31/.3.2.42: 50 files / 1,956,582 bytes,
    exact baseline identity and nonoverlapping interval/hash proof. Formal codebase/roadmap reconciliation,
    subsequent deltas, and rendered inspection remain pending; .41 owns the additional verified book drift.
  Commit: `pending`
- ID: `SESSION-STARTUP-READING.5`
  Status: `pending`
  Goal: Complete supplied-policy adoption/update comparisons and the startup alignment review before implementation.
  Acceptance: Record local adoption evidence and applicable donor updates; own any required changes; confirm all
    three reading answers Yes. Review and complete `.29` as part of adoption before this closeout, then route to
    the remaining tracked startup repairs before restoring RUST-MUTATION-TESTING.1. During alignment, qualify
    ADR 0055 section 5 against the later all-twenty repair: only explicit overlay components enforce transport
    pre-dispatch denial; unsupplied components stay with native diagnostics. `.3.2.36` records matching neutral/
    embedded policy evidence; preserve historical decision evidence while making its current boundary explicit.
  Verification: `pending`
  Commit: `pending`
- ID: `SESSION-STARTUP-READING.6`
  Status: `done`
  Goal: Reconcile managed-run liveness reporting across restricted and permitted process inspection.
  Acceptance: Use one known live controlled run and compare same-run read-only `--list`, PID/group probes, and
    permitted process inspection; record exact mechanism and locations. Any confirmed false-dead cleanup boundary
    receives a repair leaf and a non-destructive regression plan before recovery is used. No ambiguous deletion.
  Verification tier: `focused`
  Focused checks: Controlled repository-managed live-process probe; read-only restricted/permitted run and process inspection; exact liveness-owner source review; `bash scripts/check_memory_architecture.sh`; `bash scripts/check_doctrines.sh`; both `tools/roll_document_history.pl --check` surfaces; `git diff --check`.
  Canonical trigger: `none` — diagnostic evidence and startup tracking only; any repair requires a separate infrastructure leaf.
  Verification: Controlled 45-second managed run confirms restricted PID/group probes return errno 1 / EPERM
    while permitted probes return success for the same live PIDs. Restricted `--list` says abandoned; permitted
    `--list` says live. Exact source routes all failed kill-zero checks into false-dead recovery authorization.
    No recovery/deletion probe executed; the wrapper exited 0 and permitted census then found zero leftovers.
    Evidence and source locations: `docs/knowledge/project-data-liveness-permission-denial.md`.
  Commit: `SESSION-STARTUP-READING.6 - diagnose denied liveness probes` — Exact causal evidence and owned repair; no production change or deletion test.
- ID: `SESSION-STARTUP-READING.7`
  Status: `pending`
  Goal: Repair permission-denied liveness handling before any managed recovery or mutation workspace workflow.
  Dependencies: `.3`, `.4`, `.5` required-reading completion; `.6` causal evidence.
  Acceptance: Distinguish confirmed absence from denied/unknown PID and group inspection; denied or unknown
    results must retain scratch. Cover wrapper, child, group, normal drain, recovery, and retained-failure purge
    with non-destructive deterministic EPERM/ESRCH tests and a live restricted-process control. Preserve positive
    dead-run cleanup, signal forwarding, PID-reuse conservatism, same-volume storage, and valid marker ownership.
    Verify child process-group establishment before trusting the recorded group identity: `.3.2.27` observed
    a child setpgid EPERM warning followed by successful generation. Its original PGID was not captured;
    a subsequent PID/PGID control matches. Distinguish benign parent/child setup races from failed group
    establishment with controlled evidence, and retain scratch if the group identity cannot be established.
    Update Toolbox/book/KM claims, run focused lifecycle/storage/dependent checks and exact canonical proof.
    Split into bounded children before implementation if needed; reading prerequisites remain mandatory.
  Reading Lua .1.21 recurrence: The managed PUC descriptor run emits child setpgid EPERM for child47639 then passes 912 assertions and exits0. Its original PGID was not captured. A separate control has matching PID/PGID50782 and read-only listing finds zero runs; neither retroactively proves the original group. Existing establishment/failure repair and recovery/purge restrictions remain. Evidence: docs/knowledge/lua-spec-ast-loader-reading-and-validation-gaps.md.
  Integration .5.3 recurrence (September20): Exact concurrent consumer replay captures a clean LuaJIT command with correct values/status0 plus the wrapper's child setpgid EPERM diagnostic for child571. A separate1000-command PID/PGID probe captures a warning for child29222 with actual PID=PGID29222 and parent28526; all1000 commands exit0 with expected groups. This is measured successful establishment in a warned invocation, not proof of its kernel/timing cause or all lifecycle paths. The earlier PUC stream was lost and is not retroactively identified. Preserve this actual warned-group control in the eventual repair; do not filter warnings or waive denied/unknown handling. Source and all .3/.4/.5 prerequisites remain unchanged. Canonical evidence: docs/knowledge/project-data-liveness-permission-denial.md; raw evidence: .linkedspec-data/scratch/backend-integration53.
  Verification: `pending`
  Commit: `pending`
- ID: `SESSION-STARTUP-READING.8`
  Status: `pending`
  Goal: Make bootstrap diagnostic comparison state describe the current invocation.
  Dependencies: `.3`, `.4`, `.5` required-reading completion; `.7` cleanup safety repair precedes this repair.
  Acceptance: Reproduce successful comparison followed by unsuccessful comparison with the shared cache and
    an injected state. Clear stale comparison output on every attempt, including empty/undefined/throwing or
    unavailable comparison paths; preserve primary bootstrap behavior, recursion protection, and successful
    comparison capture. Add focused regression proof, review actual metadata consumers and public explanation,
    update Knowledge and continuity, and commit before returning to Rust mutation setup.
  Verification: `pending` — `.3.2.3` owns the non-destructive diagnostic evidence, not this repair.
  Commit: `pending`
- ID: `SESSION-STARTUP-READING.9`
  Status: `pending`
  Goal: Preserve regex-literal delimiters when reading attached conditional tails.
  Dependencies: `.3`, `.4`, `.5` required-reading completion; repairs `.7` then `.8` precede this repair.
  Acceptance: Lock the observed truncated brace/parenthesis tails and public `matches("}", /}/)` failure with
    quoted-pattern controls. Repair lexical recognition using the established regex-versus-division contract;
    cover escaped slashes, character classes, nested delimiters, quoted text, and action/blind/lifecycle callers.
    Preserve full tail/source positions and exact diagnostics for malformed inputs. Check self-hosted grammar
    alignment, run focused direct/dependent proof, update book/Knowledge/continuity, and commit before mutation setup.
  Verification: `pending` — `.3.2.4` owns diagnosis; no repair is claimed before mandatory reading.
  Commit: `pending`
- ID: `SESSION-STARTUP-READING.10`
  Status: `pending`
  Goal: Eliminate unbound package-variable inputs from the AND_BCODE variant handoff.
  Dependencies: `.3`, `.4`, `.5` required-reading completion; repairs `.7`–`.9` precede this repair.
  Acceptance: Reproduce the isolated argument/global differential from `.3.2.8`; the builder must depend only
    on explicit current inputs. Trace whether the legacy regex/I-block extension has any supported caller and
    either remove its dead handoff or wire supported data at the correct semantic boundary. Preserve ADR 0010
    entry-without-self-match and current blind-call/cursor ownership; do not enable parent regex matching merely
    by forwarding the missing fields. Lock private-state independence and relevant live/generated AND controls,
    reconcile accepted attached I-block behavior, update book/Knowledge as warranted, and commit before mutation
    setup. Split scope before implementation if cross-backend/public contract work is required.
  Verification: `pending` — `.3.2.8` proves the private handoff defect; no public result defect is yet claimed.
  Commit: `pending`
- ID: `SESSION-STARTUP-READING.11`
  Status: `pending`
  Goal: Correct validation diagnostic source context and rule attribution.
  Dependencies: `.3`, `.4`, `.5` required-reading completion; repair `.10` precedes this activity.
  Children: `.11.1`, `.11.2`, `.11.3`
- ID: `SESSION-STARTUP-READING.11.1`
  Status: `pending`
  Goal: Return the actual next source line and preserve zero-valued text in DSL error context.
  Acceptance: Lock first/middle/last/empty/trailing-newline controls and the literal line `0`; correct
    get_dsl_context and its formatter without changing diagnostic position units or validation acceptance.
    Cover direct context, callback detail, and public Get runtime context; update book/Knowledge and commit.
  Verification: `pending` — `.3.2.9` proves current-line repetition and loss of literal `0`.
  Commit: `pending`
- ID: `SESSION-STARTUP-READING.11.2`
  Status: `pending`
  Goal: Report the actual physical occurrence of repeated source lines in validation failures.
  Dependencies: `.11.1`
  Acceptance: Replace content-based first-occurrence lookup with the current line's source offset across
    affected validator/reporting callers. Repeated identical headers must report the second definition;
    repeated text in comments/strings/body members must not steal an error position. Preserve Unicode/CRLF,
    same-line offsets, stable codes, and strict-mode behavior; run direct/public controls, update docs, and commit.
  Verification: `pending` — `.3.2.9` proves a line-4 duplicate reported at line 1.
  Commit: `pending`
- ID: `SESSION-STARTUP-READING.11.3`
  Status: `pending`
  Goal: Attribute invalid regex diagnostics to the containing rule during the regex-validation pass.
  Dependencies: `.11.2`
  Acceptance: Track the current regex-pass owner instead of retaining the final paragraph-pass rule.
    Cover first/middle/last rules, inline and following-line regexes, named/anonymous slots, callbacks,
    and public runtime context. Preserve rejection and codes; reconcile book/Knowledge, verify, and commit.
  Verification: `pending` — `.3.2.9` proves Top's invalid regex is attributed to Next.
  Commit: `pending`
- ID: `SESSION-STARTUP-READING.12`
  Status: `pending`
  Goal: Preserve authored execution order when bare and explicit edges share one ownership family.
  Dependencies: `.3`, `.4`, `.5` required-reading completion; diagnostic repair activity `.11` precedes this repair.
  Acceptance: Lock the bare-before-explicit OR priority and AND child-order failures with all-bare,
    all-explicit, and explicit-before-bare controls. Normalize through one authored sequence so execution,
    dependencies, descriptor edges, and supported generated carriers agree. Preserve lifecycle-generated
    actions, grouped/indexed/named selectors, duplicate slots, repeated families, and mixed-ownership rejection.
    Verify native and emitted/loaded/trace routes plus direct-dependent conformance and backend comparison;
    update book/Knowledge and commit before mutation setup. Split bounded children before implementation if
    carrier/public work exceeds one safe slice. Do not change the existing authored-order contract.
  Verification: `pending` — `.3.2.11` proves native OR/AND failures and isolates the collection/normalization split.
  Commit: `pending`
- ID: `SESSION-STARTUP-READING.13`
  Status: `pending`
  Goal: Preserve attached code by blind-edge occurrence when a rule calls the same target more than once.
  Dependencies: `.3`, `.4`, `.5` required-reading completion; authored-order repair `.12` precedes this repair.
  Acceptance: Lock repeated-target versus equivalent-distinct-target OR/AND controls. Preserve each occurrence's
    code and no-code identity through RuleIR, EmitContext, HandlerIR, dispatch, trace, and supported generated
    carriers; target names alone cannot select an occurrence. Cover different blocks, side effects, no-block
    entries, repeated families, first-match short-circuiting, cursor/recognition state, lifecycle code, and order.
    Verify native and emitted/loaded routes plus direct-dependent conformance and backend comparison; update
    book/Knowledge and commit before mutation setup. Split bounded children before implementation if carrier/
    public work exceeds one safe slice. Repeated targets must remain accepted with their own attached behavior.
  Verification: `pending` — `.3.2.13` proves native AND/OR failures and isolates hash overwrite plus name dispatch.
  Commit: `pending`
- ID: `SESSION-STARTUP-READING.14`
  Status: `pending`
  Goal: Preserve literal data and invocation-local result state in I-block and repeated-action emission.
  Dependencies: `.3`, `.4`, `.5` required-reading completion; blind occurrence repair `.13` precedes this activity.
  Children: `.14.1`, `.14.2`
- ID: `SESSION-STARTUP-READING.14.1`
  Status: `pending`
  Goal: Rewrite executable I-block/repeated-action returns without modifying literals, identifiers, or nested return scopes.
  Acceptance: Lock selected per-regex I-block plain/return/returning payloads and explicit-edge controls, plus
    bounded REP plain/return/return-value cases. Cover all retained return-to-assignment emitter sites.
    Replace whole-string substitution with an appropriate structured or token-aware lowering boundary;
    preserve quote/regex/comment contents, escaped forms, identifiers, nested blocks/functions, actual return
    semantics, and capture bridges. Reconcile every retained AND I-block rewrite site with `.10` handoff
    decisions; prove native and emitted/loaded behavior plus direct-dependent conformance and backend comparison.
    Update book/Knowledge and commit. Split safe children first if the shared lowering change exceeds this slice.
  Verification: `pending` — `.3.2.14` captures I-block literal corruption; `.3.2.15` proves bounded REP corruption too.
  Commit: `pending`
- ID: `SESSION-STARTUP-READING.14.2`
  Status: `pending`
  Goal: Make generated single-acode AND I-block and repeated-acode result storage invocation-local.
  Dependencies: `.14.1`
  Acceptance: Give each invocation its own internal result slot without changing the rule accumulator or
    authored variable identity. Prove package-state independence, no writes to the SpecEntry package slot,
    repeated same-parser and cross-parser calls, recursion, Unicode labels, I-plus-edge collection, and all
    retained handler variants. Verify native/emitted-loaded routes and direct-dependent matrices, update
    book/Knowledge, and commit before mutation setup. Preserve recognition/cursor and return-shape contracts.
  Verification: `pending` — `.3.2.14` proves I-block package dependency; `.3.2.15` also proves REP package writes on plain literals.
  Commit: `pending`
- ID: `SESSION-STARTUP-READING.15`
  Status: `pending`
  Goal: Preserve the containing ActionIR coordinate space through every nested block parser call.
  Dependencies: `.3`, `.4`, `.5` required-reading completion; return/scope repairs `.14` precede this repair.
  Acceptance: Lock eager-brace, attached function-call, and attached control-body offsets with nonzero bases,
    nested levels, leading whitespace, duplicate statement text, Unicode scalars, and CRLF. Preserve correct
    callable-literal, receiver trailing-block, and map_leaves! callback paths. Assert successful AST child spans
    and exact typed syntax/runtime diagnostic spans against authored substrings; verify direct AST, public Get,
    supported generated carriers, and direct-dependent conformance. Preserve rejection, statement semantics,
    diagnostic object payloads, and source-coordinate contracts. Update book/Knowledge and commit before
    mutation setup; split safe children before implementation if public/carrier work exceeds one slice.
  Verification: `pending` — `.3.2.16` proves three omitted base_start handoffs and passing adjacent controls.
  Commit: `pending`
- ID: `SESSION-STARTUP-READING.16`
  Status: `pending`
  Goal: Make emptiness depend on the evaluated DSL value and keep literals out of host symbol lookup.
  Dependencies: `.3`, `.4`, `.5` required-reading completion; nested-span repair `.15` precedes this activity.
  Children: `.16.1`, `.16.2`
- ID: `SESSION-STARTUP-READING.16.1`
  Status: `pending`
  Goal: Apply one typed emptiness rule to literals, bindings, nested reads, and computed values.
  Acceptance: Lock the public literal `"0"` versus bound `"0"` discrepancy, empty-string controls, and
    is_nonempty inversion. Evaluate each expression once and preserve documented undefined/empty scalar,
    array, and hash semantics across conditions, assignments, return values, fluent and attached forms.
    Cover booleans/numeric zero, computed zero text, nested containers, and side effects; compare direct and
    generated/loaded routes plus the direct-dependent backend contract. Update mdBook/Knowledge and commit.
  Verification: `pending` — `.3.2.21` public Get returns empty for literal `"0"`, nonempty for its bound twin.
  Commit: `pending`
- ID: `SESSION-STARTUP-READING.16.2`
  Status: `pending`
  Goal: Prevent numeric and keyword literal tokens from becoming generated host scalar references.
  Dependencies: `.16.1`
  Acceptance: Tighten scalar-symbol recognition or classify typed literal values before lookup, with an audit
    of direct consumers. Lock is_empty numeric/boolean/undef forms, program-name and regex-capture independence,
    valid identifiers, Unicode/name exclusions, and compound-expression boundaries. Preserve binding identity,
    generated diagnostics, and supported emitted/loaded behavior; run direct-dependent proof and update book.
  Verification: `pending` — `.3.2.21` lowering emits `$0` for literal 0 through the permissive scalar extractor.
  Commit: `pending`
- ID: `SESSION-STARTUP-READING.17`
  Status: `pending`
  Goal: Make wrong-kind collection helpers independent of same-named Perl host slots.
  Dependencies: Required reading `.3`/`.4` and policy `.5`; emptiness/literal repair `.16`.
  Children: `.17.1`, `.17.2`
- ID: `SESSION-STARTUP-READING.17.1`
  Status: `pending`
  Goal: Guard array helpers by the evaluated DSL value kind before host-slot fallback.
  Conformance .1.80 extension: Public generated source for the missing.sorted().is_empty() fixture reads undeclared @missing without a scalar binding. Fresh independently loaded public source returns 1 with an empty generated-package host array and 0 with one unrelated host element; an explicit set(missing, []) control returns 1 in both states. This existing isolation repair now includes absent bare receivers as well as wrong-kind operands, preserves legitimate implicit rule accumulators and once-only operand evaluation, and must verify live plus independently loaded source. Evidence/replay: docs/knowledge/perl-wrong-kind-collection-host-slot-drift.md. The .2.14 description audit must not misreport an absent scalar declaration as present.
  Acceptance: Lock count/first/last on wrong-kind values against isolated empty/nonempty same-named host arrays.
    Audit direct array-helper consumers, evaluate operands once, preserve valid binding/array behavior and
    supported generated/loaded routes, and update the book and Knowledge with focused direct-dependent proof.
  Verification: `pending` — intake `.31` records six parser/host-seed controls; no repair has landed.
  Commit: `pending`
- ID: `SESSION-STARTUP-READING.17.2`
  Status: `pending`
  Goal: Apply the same evaluated-value boundary to hash counts, key views, and membership.
  Conformance .1.81 extension: Public count_keys(missing) with an absent bare binding returns 0/1 under empty/populated isolated host hashes in independently loaded generated source; set(missing, {}) stays 0/0. Include absent bare hash operands and loaded-source isolation alongside the existing wrong-kind cases. Four fresh controls pass; ordinary live empty-state checks do not establish seeded live behavior. Exact reproduction: docs/knowledge/perl-wrong-kind-collection-host-slot-drift.md.
  Acceptance: Lock count_keys/sorted_keys/has_key against unrelated host hashes; cover wrong kinds, present null,
    missing keys, evaluated key order, detached views and snapshots, side effects, and supported carriers.
    Reconcile the governed wrong-kind contract before changing results; preserve valid aggregate bindings.
  Verification: `pending`
  Commit: `pending`
- ID: `SESSION-STARTUP-READING.18`
  Status: `pending`
  Goal: Preserve quoted source data through primitive rewriting and canonical-event scanning.
  Dependencies: `.3`/`.4`/`.5`.
  Children: `.18.1`, `.18.2`
- ID: `SESSION-STARTUP-READING.18.1`
  Status: `pending`
  Goal: Prevent primitive set rewriting from modifying text inside a quoted value.
  Acceptance: Turn the recorded quoted set(counter, 2) corruption into a regression; cover both quote forms,
    escaped delimiters, comments, regex literals, nested calls, and genuine executable set operations.
    Use actual lexical/source spans rather than blind substring substitution; preserve downstream source identity.
  Verification: `pending` — PrimitivePipelineRules' unmasked matcher and raw replacement are localized in `.31`.
  Commit: `pending`
- ID: `SESSION-STARTUP-READING.18.2`
  Status: `pending`
  Goal: Emit canonical assignment events only for executable assignment syntax.
  Acceptance: Reject the false ASSIGN event contributed by quoted helper-looking text while retaining real,
    nested, and repeated assignment events, stable order, exact spans, and once-only event production.
    Cover descriptor, generated, and direct-dependent scanner consumers; synchronize public teaching as needed.
  Verification: `pending` — CanonicalEvents independently scans the unmasked quoted spelling.
  Commit: `pending`
- ID: `SESSION-STARTUP-READING.19`
  Status: `pending`
  Goal: Enforce the active map_leaves! receiver guard for dynamic codeblock assignment.
  Dependencies: `.3`/`.4`/`.5`.
  Acceptance: Lock the dynamic-callback bypass alongside the already-rejected direct write. Route nonparameter
    binding writes through resolved receiver identity checks; preserve parameter shadowing, pure function scope,
    atomic traversal/rebind, exception unwinding, detached results, and post-commit continuation.
    Audit all CodeblockRuntime write paths and supported carriers; run direct-dependent mutation/callable proof.
  Verification: `pending` — `.31` records guarded direct assignment versus unguarded dynamic callback writes.
  Commit: `pending`
- ID: `SESSION-STARTUP-READING.20`
  Status: `pending`
  Goal: Remove Unicode-digit truncation and warning-producing scalar numeric coercion.
  Dependencies: `.3`/`.4`/`.5`.
  Children: `.20.1`, `.20.2`
- ID: `SESSION-STARTUP-READING.20.1`
  Status: `pending`
  Goal: Resolve the numeric-string digit language against the normative grammar and independent model.
  Acceptance: Compare Arabic-Indic and mixed-digit strings with ASCII controls across the neutral oracle and
    native routes. Distinguish accepted-digit conversion from unsupported-digit rejection; do not assume ASCII
    rejection or silently bless host truncation. If the governed intent remains ambiguous, ask the director
    before changing it. Own the exact bounded implementation and fixture movement before editing consumers.
  Verification: `pending` — Perl and the neutral Python oracle currently disagree on two recorded strings.
  Commit: `pending`
- ID: `SESSION-STARTUP-READING.20.2`
  Status: `pending`
  Goal: Implement the resolved numeric boundary consistently and without host conversion warnings.
  Dependencies: `.20.1`.
  Acceptance: Apply the resolved rule to all affected numeric consumers and carriers; preserve the governed
    55-case / 18-helper contract, finite-value rules, ASCII controls, and independent expected results.
    Include non-ASCII/mixed-digit negative or positive locks, generated execution, and accurate book examples.
  Verification: `pending`
  Commit: `pending`
- ID: `SESSION-STARTUP-READING.21`
  Status: `pending`
  Goal: Make recognition-token escape validation lexical and independent of compilation order.
  Dependencies: `.3`/`.4`/`.5`.
  Children: `.21.1`, `.21.2`
- ID: `SESSION-STARTUP-READING.21.1`
  Status: `pending`
  Goal: Remove first-token-name caching from recognition-token validation.
  Acceptance: Lock fresh and warmed compiler orders for multiple token names, repeated compilation, Unicode
    identifiers, rejected bare escapes, and valid nonescaping use. Preserve exact diagnostics and authority
    boundaries; a missing compile rejection is not evidence that active authority escaped at runtime.
  Verification: `pending` — the variable-interpolated /o matcher caches the first token name.
  Commit: `pending`
- ID: `SESSION-STARTUP-READING.21.2`
  Status: `pending`
  Goal: Exclude literal/comment occurrences from recognition-token escape detection.
  Acceptance: Preserve quoted token-name text while rejecting actual bare escapes; cover nested value syntax,
    comments, regexes, escaped delimiters, source spans, and supported serialized/generated consumers.
    Run the recognition contract and direct-dependent lifecycle/error controls; update book and Knowledge.
  Verification: `pending` — quoted token-name text is currently misclassified by the raw search.
  Commit: `pending`
- ID: `SESSION-STARTUP-READING.22`
  Status: `pending`
  Goal: Project rule helpers, bindings, and calls independently of an unrelated user-function definition.
  Dependencies: `.3`/`.4`/`.5`.
  Children: `.22.1`, `.22.2`, `.22.3`
- ID: `SESSION-STARTUP-READING.22.1`
  Status: `pending`
  Goal: Bound the native and frozen-model impact of the empty-function early return.
  Acceptance: Reproduce the same valid rule on Perl, Rust, Dart, Julia, PUC Lua, and LuaJIT; retain the
    zero-versus-five record evidence now measured on all five backends/six runtime routes: .3.3.30 adds
    fresh Rust/Perl pairs; the other runtime measurements remain the dated September 6 intake evidence.
    Inventory affected frozen models, digests, bindings, admissions, and public examples. Define a safe
    coordinated repair boundary before changing exact expected data; do not silently adapt an oracle.
  Verification: `pending`
  Commit: `pending`
  Lua .1.19: Fresh public raw queries on both installed hosts reproduce zero helper/binding/call records without a function versus five with an unused function; both independently execute x. The guard still precedes action-owner traversal. Preserve the earlier six-runtime census as dated evidence; these two new host observations do not refresh all backends.
- ID: `SESSION-STARTUP-READING.22.2`
  Status: `pending`
  Goal: Repair the affected projection owners with independently justified shared expectations.
  Dependencies: `.22.1`.
  Acceptance: Include helper-only rules, unused-function twins, actual user functions, binding/call order,
    exact source IDs/spans, and existing function vocabulary. Coordinate inseparable native/model changes
    in the boundary approved by the impact audit; split further before editing if it exceeds a safe slice.
    Preserve query limits, immutable snapshots, compile failures, and unsupported-source exclusions.
  Verification: `pending`
  Commit: `pending`
- ID: `SESSION-STARTUP-READING.22.3`
  Status: `pending`
  Goal: Close supported semantic carriers, MCP projection, and public teaching for the corrected rule records.
  Acceptance: Recompose exact native, serialized/reconstructed, generated/emitted, and MCP behavior where
    supported. Preserve unchanged transport/security contracts and reject stale missing-record expectations.
    Update governed book examples and ownership facts; complete the required canonical closeout.
  Verification: `pending`
  Commit: `pending`
- ID: `SESSION-STARTUP-READING.23`
  Status: `pending`
  Goal: Preserve honest compilation-failure decision and explanation evidence.
  Dependencies: `.3`/`.4`/`.5`.
  Acceptance: Retain the already-correct recognition_token_escape diagnostic code and message while
    replacing its fabricated dependency_resolution decision/dependency_target_missing explanation.
    Keep genuine unknown-rule diagnostics correct, avoid uninitialized blank-target warnings, use honest
    fallback for unclassified failures, and preserve exact source evidence across native/generated/MCP routes.
    Extend the actual failure-class matrix and synchronize the book and existing authority records.
  Verification: `pending` — `.3.2.44` refines .31 with two exact public Get/query controls: the original
    diagnostic code/message survive, but unrelated failure gets a false dependency decision/explanation
    and an undefined-target warning. The bare missing-rule control retains correct code, span, and explanation.
    .3.3.32 Rust missing-rule and out-of-range-slot controls retain correct distinct diagnostics; the
    latter is caught by resolve_selector before slot-failure normalization. Token-use acceptance is .68.
  Julia .1.28 controls: bare Missing preserves native bare_edge_target_undefined and truthful unknown_rule_reference/source/dependency evidence; Child[9] preserves regex_slot_index_out_of_range/resolve_selector and exact authored source without a fabricated decision. The selector guard precedes failure normalization. Exact67-assertion controls live in docs/knowledge/julia-semantic-static-correlation-gaps.md; no Perl repair or full failure-class closure is claimed.
  Commit: `pending`
- ID: `SESSION-STARTUP-READING.24`
  Status: `pending`
  Goal: Preserve the caller's Perl exception state while evaluating lazy trace detail callbacks.
  Dependencies: `.3`/`.4`/`.5`.
  Acceptance: Lock quiet, plain-detail, successful-callback, and throwing-callback cases against the same
    incoming exception. Preserve exception object identity, laziness, nested/reentrant trace calls, parser
    context, and existing callback/sink failure contracts. Audit the direct callback evaluation paths and
    validate supported generated/CLI trace consumers without enabling callbacks at quiet levels.
    Distinguish direct owner/generated calls from dispatch_owner_call: the latter already preserves
    successful-call exception state, including object identity. Do not describe the wrapper as defective.
  Verification: `pending` — direct Trace lazy eval replaces incoming $@ on success/failure/nested detail;
    .3.2.48's 20 controls preserve quiet/plain direct state and all OwnerDispatch-wrapped cases.
  Commit: `pending`
- ID: `SESSION-STARTUP-READING.25`
  Status: `pending`
  Goal: Correct gdcheck tolerance, duplicate-row, and DEFAULT cardinality behavior.
  Dependencies: `.3`/`.4`/`.5`.
  Children: `.25.1`, `.25.2`, `.25.3`
- ID: `SESSION-STARTUP-READING.25.1`
  Status: `pending`
  Goal: Compare signed values using the intended nonnegative tolerance magnitude.
  Acceptance: Lock equal negative values and values within tolerance beside positive twins; cover zero,
    tolerance boundaries, rejected invalid configuration, exact masks, and existing comparison operators.
    Preserve the configured meaning of tolerance and document the resolved signed-value examples.
  Verification: `pending` — signed baseline multiplication reverses the interval for negative values.
  Commit: `pending`
- ID: `SESSION-STARTUP-READING.25.2`
  Status: `pending`
  Goal: Process every duplicate-key row when data is added or removed.
  Acceptance: Lock zero-to-two and two-to-zero duplicate transitions, unequal duplicate counts, stable row
    correspondence/order, every add/remove mask, and unaffected columns. Preserve existing keyed comparison
    semantics rather than dropping all but index zero; add focused utility-level regression examples.
  Verification: `pending` — addition/removal currently uses only each key's first indexed row.
  Commit: `pending`
- ID: `SESSION-STARTUP-READING.25.3`
  Status: `pending`
  Goal: Require exactly one DEFAULT pattern by actual array cardinality.
  Acceptance: Cover zero, one, two, and more-than-nine authored patterns, consistent diagnostics, and valid
    non-DEFAULT entries. Replace the decimal-string length test without broadening the configuration grammar.
  Verification: `pending` — zero and two patterns are accepted because length(@EVAL) tests digit length.
  Commit: `pending`
- ID: `SESSION-STARTUP-READING.26`
  Status: `pending`
  Goal: Make ptchange file IO preserve valid caller filenames and diagnose failed reads/writes.
  Dependencies: `.3`/`.4` and storage-policy review `.5`.
  Acceptance: Replace shell-split input reading and ambiguous output opens; lock plain, spaced, Unicode, and
    metacharacter filenames, unchanged transformation/clock output, and safe read/write failure behavior.
    Resolve the machine-specific shebang and repository-derived default outputs under the reviewed locality
    policy. Use exact owned fixtures and prevent silent empty output or unintended clobbering.
  Verification: `pending` — identical plain/spaced inputs produce preserved text versus empty output, both exit 0.
  Commit: `pending`
- ID: `SESSION-STARTUP-READING.27`
  Status: `pending`
  Goal: Resolve and repair the known Perl lifecycle final-value/E-handler divergence.
  Evidence update: .86.5.2.1 replays no-edge I/E with E{return(42)}: x and y both return7; emitted source omits E. Its explicit-edge twin returns8/undef. The book/test carrier is corrected there; .27.1-.3 still own runtime reconciliation and repair.
  Dependencies: `.3`/`.4`/`.5`.
  Children: `.27.1`, `.27.2`, `.27.3`
- ID: `SESSION-STARTUP-READING.27.1`
  Status: `pending`
  Goal: Reconcile lifecycle return and mode execution against ADR 0020 and exact cross-backend evidence.
  Acceptance: Compare no-edge own-regex, explicit self-edge, I/E, constant-return, final-statement, and traced
    controls. Keep rule entry distinct from mode-driven matching. Do not label Julia wrong or impose a blanket
    own-regex prohibition from the existing Perl failure; ask the director if normative intent remains unresolved.
    Define the required handler/return cases and bounded implementation children before changing behavior.
  Verification: `pending` — the existing lifecycle drift card records the debt; `.31` reverified it. Julia .1.7 adds the no-edge Child:AND E-only case: generated source has no authored E write/return; exact reference controls live in docs/knowledge/julia-recognition-effect-integration-gap.md.
  Commit: `pending`
- ID: `SESSION-STARTUP-READING.27.2`
  Status: `pending`
  Goal: Preserve the lifecycle handlers and final values required by the resolved contract.
  Dependencies: `.27.1`.
  Acceptance: Correct the demonstrated handler omission/return path while preserving rule-entry invariants,
    authored edge order, explicit returns, repetitions, and typed diagnostics. Include direct-dependent
    emitter/SpecEntry and runtime regression proof; split further if the reviewed repair exceeds a safe slice.
  Verification: `pending`
  Commit: `pending`
- ID: `SESSION-STARTUP-READING.27.3`
  Status: `pending`
  Goal: Close supported lifecycle carriers and make the book's lifecycle claims exact.
  Acceptance: Recompose native, generated/loaded, and trace examples on the required backends; reconcile
    action-and-lifecycle-placement, trace API, helper-catalog final-statement claims, and the existing Knowledge
    caveat. Preserve dated evidence and remove a current caveat only when its actual cases pass.
  Verification: `pending`
  Commit: `pending`
- ID: `SESSION-STARTUP-READING.28`
  Status: `pending`
  Goal: Correct demonstrated public teaching drift and cover the real claims in the relevant checkers.
  Dependencies: `.3`/`.4`/`.5`.
  Children: `.28.1`, `.28.2`, `.28.3`, `.28.4`, `.28.5`, `.28.6`, `.28.7`
- ID: `SESSION-STARTUP-READING.28.1`
  Status: `pending`
  Goal: Remove stale logical truthiness/rollout teaching and reject its actual bad paragraphs.
  Acceptance: Align governed current prose with the admitted truth table, including string zero and empty
    aggregates. Add actual-document and wrapped-claim mutations, preserve legitimate historical evidence,
    and reconcile the dated drift card. Keep the already-correct runtime contract unchanged.
  Verification: `pending` — fresh native truth controls pass while the public checker accepts contradictory prose.
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.28.2`
  Status: `pending`
  Goal: Remove the stale remaining-backends hash-selector claim and cover it in mutation public checks.
  Acceptance: Correct the measured paragraph and equivalent current wording; add its actual text and controlled
    variants to the bounded public audit. Preserve all admitted mutation semantics and historical records.
    The checker already normalizes whitespace; fix its missing semantic denial rather than inventing that bug.
  Verification: `pending` — the 63-file public checker passes the observed false remaining-backends claim.
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.28.3`
  Status: `pending`
  Goal: Teach current portable parse_job authoring in the introduction and include that surface in checking.
  Acceptance: Replace the false future/unavailable introduction with the admitted assignment-annotation form.
    Cover reachable public teaching and actual bad-paragraph mutations while retaining reserved import/provider
    and no-outward-authority boundaries. Do not promote parse_job to an arbitrary generic helper.
  Verification: `pending` — the current introduction is absent from the staged public-authoring reader set.
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.28.4`
  Status: `pending`
  Goal: Qualify obsolete semantic rollout/admission counts and check the actual current fields.
  Acceptance: Replace or explicitly date the false current 3/9 and 2/6 sentence against canonical 9/9 and 6/6.
    Cover actual and wrapped wrong-value mutations while preserving historical evidence and all query/MCP
    semantics. Apply the reviewed field-ownership policy rather than guessing that every number is a live count.
  Verification: `pending` — the page is included, but the real public checker returns no error for that sentence.
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.28.5`
  Status: `pending`
  Goal: Correct definedness return-context and cat null-fragment teaching in the helper catalog.
  Acceptance: Replace condition-only claims with precisely supported expression contexts and executable true/
    false examples. Verify return representation before promising portable encoding. Teach cat's null and
    wrong-kind boundary beside the empty-string control; add bounded public regression coverage.
    Preserve current scope/arity and scalar-to-text contracts; no runtime defect is established by these probes.
  Verification: `pending` — returned/nested definedness works; cat with null returns null, not concatenated text.
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.28.6`
  Status: `pending`
  Goal: Replace the host-process termination claim with the actual typed exit_now control contract.
  Acceptance: Show native/generated typed parse unwinding and caller handling at each supported API boundary.
    Cover the actual false process-exit paragraph and controlled variants in diagnostic public checks;
    preserve immediate parse termination, event ordering, host continuation, and exception identity.
  Verification: `pending` — Perl throws RuntimeExitNow and the host continues; the current public checker passes.
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.28.7`
  Status: `pending`
  Goal: Restore precise public aggregate-selector checking for documented negative examples and the actual reference census.
  Dependencies: `.3`/`.4`/`.5`; retain `.28.2` as the distinct false-current-prose repair.
  Children: `.28.7.1`, `.28.7.2`
  Evidence: Lua reading .1.8 confirms the production checker fails unchanged f80a2bde inputs: 62 public files, 35 exact references against expected32, and one unclassified fenced Julia invalid example at project-status.md:857. All public bytes match that HEAD or its rgx gitlink; no source repair is made. See docs/knowledge/lua-interpreter-helper-reading-and-false-delimiter-gap.md.

- ID: `SESSION-STARTUP-READING.28.7.1`
  Status: `pending`
  Goal: Reconcile every current selector reference and teach/check negative example context without weakening authoring rejection.
  Acceptance: Audit all 35 observed references and any subsequent delta, distinguish rejected examples from positive authoring, and repair the bounded context/census contract with explicit evidence. Preserve the Julia callable-body defect example and its repair owner; do not delete evidence or merely raise a counter. Keep executable selector rejection, migration contrasts and source scanner behavior intact.
  Verification: `pending` — sentence_at stops at blank lines around the fenced example; a second baseline census mismatch would remain after only correcting its context.
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.28.7.2`
  Status: `pending`
  Goal: Independently verify public selector examples, census and rejection behavior after the bounded repair.
  Dependencies: `.28.7.1`.
  Acceptance: Exercise actual fenced and inline historical/rejected examples, blank-line/wrapped context variants, added/removed reference census mutations and genuine positive authoring mutations. Run the unmodified production check, its direct dependents and canonical admission at the appropriate boundary; synchronize current book/Knowledge claims while retaining dated failed evidence.
  Verification: `pending`
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.29`
  Status: `pending`
  Goal: Align diagnostic-evidence path coverage with the actual polyglot source and verification surfaces.
  Dependencies: Complete `.3`/`.4` and review adoption scope under `.5`; execute before `.5` adoption closeout.
  Acceptance: Inventory actual governed source/test/contract paths and explicit exclusions; include the omitted
    Dart, Julia, Lua, and tests controls. Add a deterministic path matrix and controlled staged-path RED/GREEN
    proof. Keep documentation-only scope proportional; the evidence gate must not execute recorded Markdown commands.
    Integrate the fix with the reviewed CLAIM verification adoption and required infrastructure proof.
  Verification: `pending` — the actual gate predicate accepts Perl/Rust/t/tools twins but excludes four recorded peers.
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.30`
  Status: `pending`
  Goal: Correct the grouped-edge book example's unproduced child return value.
  Dependencies: `.3`/`.4`/`.5`.
  Acceptance: Teach a valid shared matched-text block or explicit per-edge child calls with complete examples
    for both alternatives. Preserve authored action-block dispatch semantics; do not invent implicit child
    execution or a dynamic-callee API to rescue the prose. Add appropriate example regression coverage,
    reconcile the existing edge ownership fact, and render the corrected book.
  Verification: `pending` — both alternatives return null text in the book form; explicit calls and match_text controls pass.
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.31`
  Status: `done`
  Goal: Persist read-only forward reading, confirmed findings, and repair ownership from the canonical wait.
  Scope: Startup task ownership and evidence, Knowledge retrieval, bounded continuity, and supplied-policy provenance.
  Acceptance: Create exact owners `.17`–`.30` before any remediation; preserve reproduced outcomes, source
    mechanisms, existing-debt links, full/partial reading ranges, and explicit unprobed boundaries.
    Record earlier read-only preparation without marking pending per-leaf checkpoint commits complete.
    Preserve the preceding exact canonical result and route back to `.3.2.22`. No implementation or public-book edits.
  Verification tier: `focused`
  Focused checks: Recorded Toolbox/native controls and source locations; baseline/current identity and interval
    audits; existing Knowledge reconciliation; memory/doctrine/Knowledge/history checks; final scope/diff review.
  Canonical trigger: `none` — startup tracking only; policy, runtime, public, and infrastructure repairs remain separately owned.
  Verification: Recorded Toolbox/native controls, exact source locations, disjoint reading audits, donor
    comparisons, and preceding canonical completion are preserved below. Fourteen Knowledge cards plus the
    existing lifecycle owner distinguish confirmed gaps, unprobed boundaries, and the JSON display artifact.
    All nine doctrines, Knowledge synchronization, memory, both history limits, and staged scope/diff pass.
    Queued checkpoint statuses stay pending; pre-commit rechecks the final candidate.
  Commit: `SESSION-STARTUP-READING.31 - preserve forward reading and own confirmed repairs` — Forward coverage and confirmed findings durably owned; prior canonical success; queued checkpoints remain pending.

- ID: `SESSION-STARTUP-READING.32`
  Status: `pending`
  Goal: Preserve caller-context argument evaluation before any user-function local declaration becomes visible.
  Dependencies: `.3`/`.4`/`.5`.
  Acceptance: Reproduce the scalar local-name collision through Get and emitted source, with literal and
    distinct-name controls; cover aggregate inputs, parameter names, nested calls, rest arguments, and eager
    evaluation order. Separate caller argument evaluation from body-local binding without exposing compiler
    temporary collisions. Add focused RED/GREEN runtime/generated-source proof and direct-dependent callable
    coverage; reconcile the function-execution Knowledge and public contract with the verified implementation.
    Measure other backends before claiming cross-runtime impact or parity.
  Verification: `pending` — Get returns null for `f(temp)` when the body declares local `temp`; literal and
    distinct-name controls return outer. Dumped Perl declares `my $temp` before the argument temporary.
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.33`
  Status: `pending`
  Goal: Reconcile tagged-record argument evaluation and split behavior with the public contract and runtime evidence.
  Dependencies: `.3`/`.4`/`.5`.
  Children: `.33.1`, `.33.2`

- ID: `SESSION-STARTUP-READING.33.1`
  Status: `pending`
  Goal: Bound tagged-record divergence across native/generated runtimes and determine the authoritative contract.
  Acceptance: Replay the exact Perl Get/source controls across all six runtimes. Cover source/delimiter/tag/
    carried-field evaluation count and order, empty/trailing/consecutive items, literal/regex delimiters,
    variable delimiters, scalar receivers, and nested carried-value independence. Reconcile book once-only
    teaching, Lua implementation evidence, Perl-reference policy, and existing corpus expectations before repair.
    Explicitly include empty literal and zero-width regex delimiters, distinguishing leading/trailing empty
    items from empty-source behavior and pure helper results from tagged-record construction.
    Assign separate implementation leaves if the coordinated correction exceeds one safe slice.
  Verification: `pending` — Perl carried field increments twice for a,b, and zero times for empty input;
    tagged splitting drops the trailing empty item retained by ordinary split. See `.3.2.28` evidence.
    `.3.3.15` adds seven paired current Rust/Perl pure-split controls: five empty-source/empty-delimiter
    differences and two equal ordinary controls. Rust adds initial empty fields for empty literal/regex
    delimiters and differs on empty sources; all fourteen compared commands exit zero without stderr.
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.33.2`
  Status: `pending`
  Goal: Implement the reviewed tagged-record and pure-split contract and prevent recurrence in runtime and public examples.
  Dependencies: `.33.1`.
  Acceptance: Add independently justified failing controls, correct affected lowerers/interpreters, and cover
    direct/generated/helper/receiver forms without silently re-blessing oracle data. Include the measured
    Rust/Perl empty-source, empty literal/regex delimiter, Unicode and ordinary control pairs from .3.3.15.
    Preserve non-scope source
    argument ownership and exact record shape. Synchronize the helper reference and Knowledge, add real public
    claim coverage, and run focused direct-dependent plus required cross-runtime admission proof.
  Verification: `pending`
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.34`
  Status: `pending`
  Goal: Preserve executable statements across line comments and every supported newline spelling.
  Dependencies: `.3`/`.4`/`.5`.
  Children: `.34.1`, `.34.2`

- ID: `SESSION-STARTUP-READING.34.1`
  Status: `pending`
  Goal: Preserve structural validation and generated separator placement around inline comments.
  Acceptance: Reproduce LF/CRLF assignment-comment-return failure through public Get, ActionIR diagnostics,
    and emitted source; compare no-comment, explicit-semicolon, comment-only, quoted-hash, and nested cases.
    Preserve lexical ownership and source locations when choosing the generated separator position; an inserted
    semicolon must not become comment text. Cover live and generated routes, update separator teaching and
    Knowledge with exact behavior, and run focused direct-dependent proof before required public signoff.
    Measure other backends before claiming cross-runtime impact; keep the oracle correction independently justified.
  Added acceptance from .86.4.8.2: Inline comment text # pattern/) after an explicit semicolon must not change rule-fragment depth; both direct numeric matches and receiver-call twins lower to1 but public validation rejects. Preserve standalone-comment controls and original diagnostic locations.
  Verification: `pending` — generated $name = "ok" # note; followed by return fails handler compilation for LF/CRLF.
    Public Get returns a wrapper but invocation records an error and no result; see `.3.2.33` evidence.
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.34.2`
  Status: `pending`
  Goal: Terminate CR-only line comments without losing the following authored statement.
  Acceptance: Reproduce the CR-only splitter and public Get loss, with LF/CRLF and explicit-separator controls.
    Correct comment state and generated-host newline handling together; changing only the splitter must not
    leave Perl treating the following statement as comment text. Preserve decoded source locations, quoted/
    regex payloads, EOF comments, and nested/comment-only forms. Add live/generated and direct splitter
    regressions, reconcile all universal-newline claims, render the book, and verify relevant runtime parity.
    Coordinate with `.34.1` without combining independently reviewable repairs.
  Verification: `pending` — Mode clears line-comment state only on LF; CR keeps return in the same statement
    and generated host comment. Public invocation returns no result with no context error.
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.35`
  Status: `pending`
  Goal: Preserve typed boolean literals during dynamic Perl codeblock evaluation.
  Dependencies: `.3`/`.4`/`.5`.
  Acceptance: Reproduce public direct versus dynamic true/false results and inspect the typed AST and
    CodeblockRuntime boolean branch. Preserve JSON boolean identity for returned, assigned, nested-container,
    fixed/rest-argument, and contextual-final-block literals without changing numeric 0/1 or string values.
    Add independently justified neutral and focused live/generated regression evidence; measure other runtimes
    before claiming parity. Reconcile primitive-literal/codeblock teaching and Knowledge, render the book, and
    run direct-dependent callable/logical/value checks plus required public signoff. Keep `.19` receiver-guard
    repair separate; neither defect is closed by the existing callable suite passing.
  Verification: `pending` — `.3.2.34` public controls return true/false directly but 1/0 through cb() literals;
    a true argument stays typed while a dynamic literal array returns [1,0], all without context errors.
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.36`
  Status: `pending`
  Goal: Reconcile MCP validation-error precedence with its accepted ordering and executable proof.
  Dependencies: `.3`/`.4`/`.5`.
  Children: `.36.1`, `.36.2`, `.36.3`

- ID: `SESSION-STARTUP-READING.36.1`
  Status: `pending`
  Goal: Audit competing MCP validation failures against the current normative order.
  Acceptance: Use ADR 0055 section 6, later decisions, neutral artifacts, and public decoded/stdio controls.
    Cover invalid envelope/id, special initialize, missing/malformed metadata, unsupported version, unknown
    method, and invalid tool arguments in combinations. Measure all six runtimes; preserve independent expected
    outcomes and identify exact source branches and missing fixture coverage before changing an oracle.
    Ask for direction only if current normative authorities cannot resolve an actual conflict.
  Verification: `pending` — `.3.2.38` proves Perl checks unknown methods and unsupported version before full
    metadata validation; six cases agree across decoded and stdio routes despite the documented earlier metadata step.
    .3.3.25 also reads the same method/version-before-full-schema branches in Rust mcp_server.rs;
    ADR 0058 still references ADR 0055 ordering. No fresh six-case Rust execution is claimed.
  Reading update: Julia .1.10 adds six exact decoded/stdio controls (12 assertions), matching the recorded Perl sequence while preserving separate pattern-repair ownership. Replay and source mechanism are in docs/knowledge/perl-mcp-validation-error-order-drift.md.
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.36.2`
  Status: `pending`
  Goal: Repair affected MCP dispatch paths with independently justified precedence regressions.
  Dependencies: `.36.1`.
  Acceptance: Decompose affected implementations into bounded owned repair leaves before editing them.
    Preserve the special legacy diagnostic, validated-id handling, silent notifications, error sanitation,
    prepared cancellation/flush cleanup, and native semantic authority. Add mixed-failure neutral and public
    decoded/stdio regressions; run focused direct-dependent proof plus canonical verification for contract changes.
  Verification: `pending`
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.36.3`
  Status: `pending`
  Goal: Close MCP validation-order documentation and recurring proof without drift.
  Dependencies: `.36.2`.
  Acceptance: Reconcile the accepted decision, current book/examples, Knowledge, and exact neutral/runtime
    error-order behavior; render the book and run required six-runtime/contract/canonical proof. Qualify
    historical evidence honestly and close `.36` only after every owned repair and claim agrees.
  Verification: `pending`
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.37`
  Status: `pending`
  Goal: Enforce progressive child resource and diagnostic ceilings with independent cross-runtime proof.
  Dependencies: `.3`/`.4`/`.5`.
  Children: `.37.1`, `.37.2`, `.37.3`

- ID: `SESSION-STARTUP-READING.37.1`
  Status: `pending`
  Goal: Repair progressive effective step and detached-result resource enforcement.
  Acceptance: Reconcile ADR 0080 and the neutral ceiling contract, then census all six runtimes with exact
    boundary controls. Perl currently accepts cost 2 with effective max_steps 1 and returns [1,2,3] with
    max_result_nodes 1. Decompose affected runtime/neutral repairs before editing; independently justify node
    accounting and nested budget inheritance, preserve shared cancellation/deadline/call/depth authority, and
    add adversarial regressions beyond effective-metadata equality. Run required canonical contract proof.
  Verification: `pending` — `.3.2.39` reproduces both cases through the existing Perl private authority;
    the combined authority/carrier suite passes 138 tests and does not establish these enforced boundaries.
  Reading update: Dart .1.15 adds ten private-authority controls in docs/knowledge/dart-progressive-nested-authority-gap.md. Direct cost/result bounds reject, but a nested call runs after the parent callback reports zero remaining steps; widened caller inputs regain extra capability and max_steps/result_nodes 100. Own inherited effective grants and per-child remaining budget, with independent cross-runtime expectations and bounded repair children before implementation.
  Julia reading update: Julia .1.12 adds30 nested and14 direct-limit assertions: direct cost/result caps reject, but nested dispatch runs with parent remaining_steps zero and widened inputs regain extra capability plus100 step/result ceilings. Exact mechanism and replay: docs/knowledge/julia-progressive-authority-boundary-gaps.md; existing .37.1 owns repair decomposition.
  Lua reading update: Lua .1.5 compares unchanged one-step/two-step callback limits on PUC5.5.1 and LuaJIT. A nested callback runs at parent remaining_steps zero; the one-step-left control succeeds and both shared counters charge correctly. dispatch_nested forwards the shared invocation without the parent remaining snapshot. Exact replay and source locations: docs/knowledge/lua-authority-compiled-reading-and-nested-step-gap.md. Existing cross-runtime repair decomposition remains pending.
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.37.2`
  Status: `pending`
  Goal: Repair progressive child diagnostic size and source-detail containment.
  Acceptance: Audit exact current authority for callback input visibility versus outward diagnostics and
    define independently justified expectations. Perl preserves a 57-byte child diagnostic, including caller
    source text, with effective max_diagnostic_bytes 8 and source_detail none. Census all six runtimes;
    decompose affected repairs and add bounded UTF-8/source-safe failure regressions. Preserve typed error
    context and view/chain cleanup. Do not silently rewrite the neutral promise to match current behavior.
  Verification: `pending` — `.3.2.39` roots the unbounded raw child-error copy in dispatch and records the
    separate callback-view observation without assuming it alone establishes an exposure defect.
  Reading update: Dart .1.15 confirms the eight-byte diagnostic limit while a raw callback failure retains source prefix owned-pr at detail none. The callback can read its supplied input. Preserve these separate observations and resolve input-versus-outward detail authority; no exposure conclusion is inferred from input access alone. Exact ten-case replay is in docs/knowledge/dart-progressive-nested-authority-gap.md.
  Julia reading update: Julia .1.12 confirms the eight-byte diagnostic cap and supplied-input visibility. Throwing a source string renders with an opening quote before truncation; the exact retained prefix is a quote plus owned-p. Preserve source-detail interpretation as pending; replay is in docs/knowledge/julia-progressive-authority-boundary-gaps.md.
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.37.3`
  Status: `pending`
  Goal: Close progressive ceiling documentation and recurring proof after all owned repairs.
  Dependencies: `.37.1`/`.37.2`.
  Acceptance: Reconcile the decision, book, neutral artifact/checker, runtime consumers, and Knowledge
    against actual enforced limits; render the book and run required six-runtime and canonical proof.
    Qualify historical admission evidence and close `.37` only after the boundaries agree.
  Verification: `pending`
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.38`
  Status: `pending`
  Goal: Prevent invalidated recognition tokens from restoring obsolete snapshots.
  Dependencies: `.3`/`.4`/`.5`.
  Children: `.38.1`, `.38.2`

- ID: `SESSION-STARTUP-READING.38.1`
  Status: `pending`
  Goal: Repair post-terminal transaction misuse without changing already committed or later frame state.
  Acceptance: Preserve restore-before-report for live token misuse and permanent invalidation after commit/
    rollback. Audit every token operation and source/invocation/generation path, plus all six runtimes; decompose
    affected repairs before editing. Perl currently restores an obsolete snapshot when a committed or rolled-back
    token is reused from another frame/source. Add independent controls that first advance the owner after
    terminal invalidation, assert exact cursor/boundary/mark preservation on rejection, and preserve diagnostic
    precedence under the accepted contract. Check authored/carrier reachability separately from private-host misuse.
  Verification: `pending` — `.3.2.40` reproduces six private-authority controls: both same-frame cases retain
    current state, while four cross-frame/source cases restore cursor/boundary/marks to the old checkpoint.
    .3.3.27 Rust source comparison finds an early invalidated-status return before snapshot restoration;
    this excludes the exact Perl mechanism in that helper, not the pending behavioral/runtime census.
    Julia .1.19 reads RecognitionTransaction633-648: _restore_and_invalidate! returns immediately for invalidated tokens before changing frame/gap snapshots, likewise excluding the exact Perl helper mechanism. This source comparison does not close the separate all-runtime behavioral or authored/carrier census.
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.38.2`
  Status: `pending`
  Goal: Close transaction invalidation claims and recurring proof after the repair.
  Dependencies: `.38.1`.
  Acceptance: Reconcile neutral fixtures, all affected runtime consumers, book/Knowledge, and task history;
    qualify finite historical evidence without claiming an authored token escape from a private API probe.
    Run required six-runtime/canonical proof and render the book before closing `.38`.
  Verification: `pending`
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.39`
  Status: `pending`
  Goal: Preserve the semantic boolean kind through recognition commit.
  Dependencies: `.3`/`.4`/`.5`.
  Acceptance: Reconcile the neutral staged-payload contract and typed primitive authority; census all six
    runtimes and supported carriers with true/false versus numeric one/zero. Perl finish_commit currently
    converts JSON::PP booleans to native numbers. Decompose affected repairs before editing; add type-sensitive
    independent regressions and correct consumer expectations without weakening falsey acceptance. Reconcile
    the book/Knowledge and run required six-runtime/canonical proof. Keep the dynamic-codeblock defect .35 distinct.
  Verification: `pending` — `.3.2.41` runs eight public Get controls: direct true/false serialize as booleans,
    transaction true/false as 1/0; numeric controls agree and every context reports zero errors.
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.40`
  Status: `pending`
  Goal: Restore actual parser state when a live recognition transaction unwinds.
  Dependencies: `.3`/`.4`/`.5`.
  Children: `.40.1`, `.40.2`

- ID: `SESSION-STARTUP-READING.40.1`
  Status: `pending`
  Goal: Repair recognition guard unwind synchronization while preserving the original control error.
  Acceptance: Trace private snapshot restoration through actual cursor/boundary/mark/gap state on every abort
    and missing-terminal path. Public exit_now(7) after a successful attempt leaves Perl input at cursor two,
    although the checkpoint was zero; explicit rollback before exit restores zero. Audit all six runtimes,
    decompose affected repairs, and add exact state plus exception-identity regressions. Preserve committed
    state, falsey payloads, recursive mark isolation, and existing gap transaction semantics.
  Verification: `pending` — `.3.2.41` reproduces four public exit controls with exact status seven and no
    runtime-context errors. _finish_guard restores the private authority during leave but does not apply the
    restored snapshot to actual parser registers before discarding the context.
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.40.2`
  Status: `pending`
  Goal: Close recognition unwind documentation and recurring proof after repair.
  Dependencies: `.40.1`.
  Acceptance: Reconcile neutral/runtime tests, diagnostic control-error behavior, book/Knowledge, and tracked
    claims against actual parser state; render the book and run required six-runtime/canonical proof.
    Preserve the separate post-terminal obsolete-snapshot defect under .38.
  Verification: `pending`
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.41`
  Status: `pending`
  Goal: Reconcile the completely read mdBook with current executable contracts and prevent the measured claim gaps.
  Dependencies: `.3`/`.4`/`.5`.
  Children: `.41.1`, `.41.2`, `.41.3`, `.41.4`, `.41.5`, `.41.6`, `.41.7`, `.41.8`, `.41.9`
  Acceptance: Preserve dated historical evidence while correcting claims presented as current. Every child
    owns bounded authoring and executable claim checks; split implementation before editing if it exceeds
    one safe slice. Coordinate existing .28/.29/.30 and runtime repair owners without double-closing them.

- ID: `SESSION-STARTUP-READING.41.1`
  Status: `pending`
  Goal: Correct staged parse-job authoring, recursive dispatch, and provider-boundary teaching.
  Acceptance: Reconcile design rationale, pipeline overview, EBNF walkthrough, and backend handoff with
    the current assignment-only parse_job contract and all-six-runtime admission. Qualify the historical
    function-body-v1 limitations; preserve current prohibition of ambient loading/provider lookup and the
    separate unimplemented import model. Coordinate .28.3's introduction repair. Exercise the actual
    contradictory paragraphs and all affected chapter paths through meaningful public-checker mutations;
    exact markers alone must not certify surrounding false current prose. Render and run required public proof.
  Verification: `pending` — .3.2.42 records fully read pages and passing neutral/public controls despite
    explicit current unsupported/future claims; fixed path sets and exact denials explain the gap.
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.41.2`
  Status: `pending`
  Goal: Align cursor dispatch, generated routes, and named capture-selector status.
  Acceptance: Reconcile regex/blind-call/generated-handler guides and formal/runtime/backend appendices
    against current rule-local cursor-v2 and admitted named gap capture. Distinguish authored mode policy,
    dispatch-edge matching, public entry, and direct handler execution; remove only false current migration
    claims. Cover affected pages beyond the existing regex link markers and omitted guides. Coordinate .30
    grouped-edge and .27 lifecycle semantics; add independently justified examples, recurrence checks, and render.
    Reconcile rust/README.md subset wording with the unconditional 105-fixture generated classifier,
    retaining its distinction from default canonical execution. Correct ast.rs comments claiming Default
    equals OR+ and Single (&) is choice: rep_min gives 0 versus 1 and is_and includes Single. Preserve
    runtime policy, verify neutral authority, and cover source comments as well as the book prose.
    Correct compiler.rs documentation saying self-recursive edges duplicate parent regexes: the current
    branch and inline tests reuse their existing slots. Qualify its warning/skip commentary against the
    later compiled-slot validator, which rejects missing or out-of-range action targets. Keep standalone
    helper behavior distinct from the complete compilation pipeline; do not change runtime semantics here.
    Correct validation.rs module documentation's obsolete numbered pass reference (check 5 is no longer
    edge-target validation) and incomplete pass inventory against ordinary/traced order; retain strict
    unused-rule behavior and the deliberate default undefined-reference boundary.
    Qualify the ProgressiveDispatchArguments comment in bounded_child_parse_authority.rs that still
    describes a time before static carriers existed; the current host-argument role composes with
    admitted carriers owned by their separate syntax, engine, and generated-source modules.
    Correct engine.rs entry/local-match comments that still describe a rule testing its own regex;
    current selection is over outgoing dispatch patterns, with entry alone independent of that match.
    Include engine test comments claiming top-rule entry and local matches always coincide (chars_5_3_
    entry-start and helpers_5_5_1_match_named); fixture-specific assertions do not establish that identity.
    Preserve the actual first-selected-match fallback and caller match-state restoration boundaries.
    Reconcile runtime lib.rs module prose claiming no code generation with its current source_emitter API;
    preserve the distinction between interpreted host execution and emitted standalone Rust modules.
    Correct engine.rs target-resolver comments at 7892 and rule-label argument comments at 8002 against
    current uniform bare-value reads; these comments must not describe future or always-undef behavior.
    Qualify semantic_index.rs comments that call source-detail queries future work or assign source
    filtering/query to later leaves; the same file now exposes capabilities/query/observation derivation.
    Julia .1.1 additionally identifies julia/README.md lines 474–475 claiming root topology awaits .4.3 despite its admitted top summary. Qualify this current-tense residue with the original milestones intact.
  Verification: `pending` — current guides still describe Julia/Lua v1 adapters and future named selectors;
    the cursor contract's current reader/marker coverage does not enforce those paragraphs.
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.41.3`
  Status: `pending`
  Goal: Reconcile semantic API and MCP backend status across descriptor and handoff teaching.
  Acceptance: Replace descriptor-reference future-native-API claims and qualify historical handoff ledger
    snapshots against current all-six semantic/MCP admission. Coordinate .28.4, .36, and semantic repairs .22/.23/.43; do not imply that
    passing admission closes separately owned call projection or error-order defects. Test actual stale
    paragraphs and current backend status claims, retain dated milestones, and render the book.
    Qualify the Rust .10.4.5 twentieth-response claim in public-api/semantic-introspection.md lines
    1354–1357 against exact consumer evidence: eight routes compare typed events; direct derivation
    checks the query digest; independent emitted compilation checks only value/count/positions/first-last
    kinds. Preserve the canonical expected digest without claiming an unexecuted full emitted query.
    Evidence: docs/knowledge/rust-semantic-runtime-observation.md, startup .3.3.61.
    Also distinguish the composed admission consumer's two emitted-labelled helper routes from independent
    compiled modules; its traced wrappers disable text tracing. Evidence: rust-semantic-introspection-admission Knowledge, .3.3.62.
    Julia .1.1 adds julia/README.md lines 169–207, 243–250 and 311–338: separate historical query/runtime/emitted-boundary snapshots from current complete APIs. Seven exact README examples pass while the finite marker/denial checker accepts those surrounding statements. See julia-package-readme-reading Knowledge.
  Verification: `pending` — descriptor reference lines 96–99 contradict current semantic admission while
    existing public marker/denial checks pass; full handoff reading finds mixed historical/current wording.
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.41.4`
  Status: `pending`
  Goal: Reconcile gap-capture and typed-source current status without erasing historical measurements.
  Acceptance: Correct descriptor-reference Dart pending and diagnostics Lua dormant claims; reconcile
    capture guide current gap and typed-source counts with canonical owners. Keep the public typed-span
    API exclusion and genuinely historical counts explicit. Extend the gap public inventory beyond its
    omitted descriptor/diagnostic chapters and test the observed false-current claims. Run focused neutral
    plus required public proof, render, and coordinate current typed/gap repair owners.
  Verification: `pending` — current gap 9 complete/0 pending and typed 14 complete/0 pending coexist
    with stale current paragraphs; the exact eight-document gap reader omits two affected chapters.
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.41.5`
  Status: `pending`
  Goal: Correct compiler mode, document-input, and leading-trivia API boundaries.
  Dependencies: `.42` for final combined-option contract claims.
  Acceptance: Teach parse_only as an undef stop before compiled-state generation and generate_only as
    source parsing/validation plus generation ending in undef; document source capture separately.
    Distinguish specification-envelope validation from document input. Public entry skips leading trivia
    once; direct descriptor handlers bypass that wrapper. Preserve four input/direct controls and the
    nine-case option/invalid-source matrix, add copyable examples, cover the actual false prose, and render.
    Reverify the separate dual-bootstrap-equivalence claim before changing its scope.
  Verification: `pending` — public empty and ordinary non-spec document input succeed; leading
    blank/comment input starts at cursor 8 publicly and 0 directly. Compiler/API prose conflates those
    boundaries; .42 owns the independent combined-mode false diagnostic.
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.41.6`
  Status: `pending`
  Goal: Resolve remaining lifecycle, helper, authoring, and representation assertions with exact controls.
  Acceptance: Assess the contradictory E/EX/LX ordering tables against family-specific emitted behavior;
    coordinate .27 rather than infer a single global order. Check bare push dispatch, mutation-result
    expressions, num_mod noninteger behavior, zero-progress thresholds, inline comments, fluent child-value
    examples, entry-versus-match captures, and tablegrep precedence statements against existing Knowledge
    and public tools. Check HandlerIR host-code versus language-neutral guidance against adopted decisions.
    These are assessment candidates, not newly established runtime defects. Also correct the confirmed
    stale TOOLBOX section 1 instruction that current Perl must reject bare rule-item blocks: .3.2.42
    public twins and the current standalone contract prove acceptance. Its 15-document reader omits
    TOOLBOX; cover the actual false guidance and controlled variants with the repair. Root any surprise,
    create a bounded repair child before changes, and close each candidate with evidence, public examples, and render.
    Reconcile expr.rs test name parse_shape_literal_rhs_keeps_scalar_assignment_ast_until_target_inference_leaf
    with completed duck-typed assignment and later uniform-binding retirement; retain its AST assertions while
    removing the misleading pending target-inference implication. This is naming debt, not a failed AST check.
    Conformance .1.1 confirms capability_conformance/README.md lines347-348 still calls generic callable-codeblock future, with similar “until” first-class-literal wording at741-742, although current five-backend admission removes that exclusion. The unchanged callable checker passes while checking other required markers and exact denials. Qualify the historical final-codeblock-v3 admission boundary without presenting generic callables as currently future, and test this actual paragraph plus controlled variants; conformance-capability-guide-reading owns exact evidence.
  Verification: `pending` — full-book reading identifies the listed assessment candidates. The additional
    TOOLBOX guidance defect is confirmed at .3.2.44: standalone neutral proof passes 15 documents /
    seven denials / fourteen mutations while omitting that file. No unmeasured runtime failure is claimed.
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.41.7`
  Status: `pending`
  Goal: Align public development commands and verification cadence with adopted workflow and locality.
  Acceptance: Coordinate .29 and policy adoption .5 for actual gate-family/default decisions. Correct
    full-CI-per-behavior-change wording to ADR 0073's focused default and canonical boundaries. Ensure
    every copyable project command runs from the repository root with managed data routing; review direct
    Julia/Dart/Cargo examples and retain documented toolchain dependencies. Make existing task ownership
    explicit for small doc fixes. Replace moving capacity/capability-count duplication with canonical
    pointers or qualified dated evidence; cover actual workflow claims and render without inventing policy.
    Integration .8.5 corrects the Rust README requirement using RGX's published Rust1.95 contract and
    converts its Building block to managed root commands. Native consumer/canonical proof uses1.95.0
    on macOS arm64; no earlier compiler or broader platform floor is established. Retain other command
    and verification-cadence repairs here, and recheck the public contract for future releases. Qualify the
    stale 63-case CLI claim against the 66-case authority and replace direct Cargo examples with root-managed commands.
    Replace TOOLBOX section 4.10's two current 68-mutation claims with the canonical MCP transport
    authority or dated evidence: the unchanged September 7 canonical checker reports 76. Preserve
    genuinely historical 68-count milestones and do not infer an optional matrix rerun from that check.
    Julia .1.1 adds exact bare corpus commands in julia/README.md lines 515 and 963; route them through tools/run_julia_project_data.sh. No unmanaged execution or off-volume write was performed or inferred by this reading. Preserve dated counts while repairing copyable current guidance.
    Julia .1.2 completes README reading and adds the same bare-command defect at lines 964–965; both managed help paths pass. See julia-facade-action-model-reading Knowledge.
    Conformance .1.1 adds capability_conformance/README.md lines330-336: current17/85 contradicts the same guide and exact20/100 manifest; its24 semantic-mutation claim contradicts the current19 exclusion mutations. The same prefix also says current72 cursor migration files versus actual74, repeated-action44 mutations versus54, and logical20 documents/13 denials versus19/14; retain explicitly historical milestones while correcting these present-tense mismatches. The unchanged capability checker passes both paragraphs because public validation checks selected markers/denials only. Correct or explicitly date these actual claims and add meaningful recurrence; exact evidence belongs to conformance-capability-guide-reading.
    Conformance .1.2 finishes the guide and adds lines803-804 current-seventeenth wording and896-897 current80/0/0 wording to the same count repair and actual-paragraph recurrence. Preserve the explicitly dated16/80 callable-admission milestone. Reconcile the named-mark paragraph with its different-rule-label fixture and distinguish generated-plan execution from independently compiled emitted source using complete-named-mark-perl-rust-parity; do not infer a fresh runtime failure.
  Verification: `pending` — local-CI prose says full gate for every behavior change and default toolchain
    independence; current canonical gate runs mandatory backend admissions and reports 20 capabilities/100 states.
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.41.8`
  Status: `pending`
  Goal: Close whole-book alignment and recurrence after the bounded repairs.
  Dependencies: `.41.1`–`.41.7`; related `.28`/`.30` repairs.
  Acceptance: Reconcile all 50 baseline book paths and intervening changes with code, roadmap, task owners,
    decisions, examples, and actual checker coverage. Preserve historical counts as dated observations.
    Render and inspect the book, run exact public/cross-runtime and canonical proof, and close .41 only
    when every child and every confirmed public claim defect has its completed repair evidence.
  Verification: `pending`
  Commit: `pending`
  Additional dependency (Julia .1.34): .41.9 owns the measured mdBook search-index warning; whole-book closure includes its bounded repair and search-usability proof.

- ID: `SESSION-STARTUP-READING.41.9`
  Status: `pending`
  Goal: Resolve measured mdBook search-index growth while preserving useful public search and complete documentation.
  Dependencies: `.3`/`.4`/`.5`; coordinate .41.8 and existing document-containment owners.
  Evidence: Julia .1.34 book build succeeds but warns at10001369 decoded search bytes;913 section records,7830230 inverted-index bytes and2109423 document-store bytes. Largest bodies include Project Status Ongoing91038 and Documentation pressure containment76931 bytes. No search latency or functional failure is yet measured.
  Acceptance: Establish representative query correctness, payload/transfer and browser parse/search measurements using repository-local artifacts. Decompose before implementation if needed; select a bounded content/search strategy that preserves navigable historical evidence and current teaching. Verify relevant queries and rendered links, document before/after measurements and recurrence ownership, and run the warranted canonical boundary for any public/configuration/mechanical change. Do not merely suppress the warning or infer a speedup from bytes alone.
  Knowledge: docs/knowledge/julia-contract-consumer-reading.md contains dated measurement and replay.
  Verification: `pending`
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.42`
  Status: `pending`
  Goal: Preserve successful mode-only compilation when return_descriptor is also requested.
  Dependencies: `.3`/`.4`/`.5`.
  Acceptance: Reconcile existing compiler option precedence with facade and factory validation. Cover all
    eight parse_only/generate_only/return_descriptor combinations through public Get and get_parser, exact
    source capture, and preservation of genuine compile failures. The compiler's successful undef stop
    must not acquire runtime_owner or parser_factory failure merely because descriptor output is also
    requested. Preserve malformed defined-result rejection and trace classification. Add independently
    justified failing regressions, repair both validators, update API/book/Knowledge under .41.5, and run
    focused direct-dependent plus required public proof. Ask only if a newer normative authority actually
    conflicts with the established option contract.
  Verification: `pending` — the nine-case public Get control finds false runtime_owner/run_get_pipeline
    errors for all three descriptor-plus-mode combinations; the five other combinations and invalid-source
    attribution behave as recorded. Runtime's descriptor-first predicate was introduced by 86d6511c7,
    while Compiler checks parse_only, then generate_only, then return_descriptor. ParserFactory has the
    same descriptor-first result check: eight isolated callback controls independently reproduce its three
    false errors and failed trace classification. The named-source public get_parser matrix remains to be measured.
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.43`
  Status: `pending`
  Goal: Preserve explicit inline lifecycle members in semantic introspection.
  Dependencies: `.3`/`.4`/`.5`.
  Acceptance: Reproduce equivalent header-inline and following-line I blocks through public Get,
    descriptor/source tools, and semantic queries. Both execute return(7), but only the multiline form
    currently produces lifecycle:rule:Top:I:0. The scanner recognizes the header then skips its remaining
    text, leaving no member for lifecycle projection. Reconcile lifecycle/source-span authority, census
    supported inline members and all six runtimes, and decompose affected repairs before editing. Preserve
    authored member order, exact Unicode/newline/header/member spans, function masking, and multiline
    nesting; bare action blocks must not gain an invented explicit I marker. Add independent regressions,
    update semantic teaching/Knowledge, and run focused plus required public/cross-runtime proof.
  Verification: `pending` — four public controls return seven without errors and query successfully;
    explicit inline I has zero lifecycle records, explicit multiline I has one, and both bare controls have
    none. SemanticStaticProjection _scan_source 589–601 ignores _parse_header's tail before member capture.
    This is separate from .22's function-registry gate and .23's fabricated failure explanation.
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.44`
  Status: `pending`
  Goal: Make recursive staged-marker identity safe across retired host-address reuse.
  Dependencies: `.3`/`.4`/`.5`.
  Acceptance: Preserve the distinction between a live previously processed marker and a newly allocated
    marker that could occupy its retired host address. Native ordinary/weak/pool controls currently finish
    all 24 calls without reuse; they do not demonstrate a native failure. An isolated scheduler-refaddr
    substitute that preserves every live identity and recycles only dead weak-reference slots stops after
    three calls and returns an unprocessed marker without error; retained-marker controls finish all 24.
    Audit marker identity lifetime and existing processed/lineage semantics, verify supported host behavior,
    and implement a bounded stable identity strategy with independent recycling/lifetime regressions.
    Preserve intentional same-marker handling, authored path order, failure/stitch policies, source lineage,
    resource ceilings, detached output, and fresh native/generated/reconstructed/emitted invocation state.
    Census the other backends before claiming parity; split bounded repair children before implementation.
    Update Knowledge and relevant book/recurrence evidence; do not relabel the isolated model as observed
    native allocator reuse or close the risk merely because the original fixture suite passes.
  Verification: `pending` — .3.2.46 records native controls and weak-reference lifetime proof, then the
    isolated recycling counterexample. StagedASTEnrichment 156–187 and 793–806 key durable processed/lineage
    state by refaddr after obsolete markers can be released; no installed runtime source was altered.
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.45`
  Status: `done`
  Goal: Reject malformed Rust rule code instead of accepting a warning and dropping the block.
  Dependencies: ADR0123 targeted reading supersedes the blanket startup gate; .83.1 contract checkpoint commits first.
  Children: `.45.1`, `.45.2`, `.45.3`.
  Acceptance: After prerequisite reading, split bounded parser/compiler, carrier-regression, and public alignment leaves before implementation. Make malformed lifecycle/action/blind blocks return precise
    compilation errors; retain valid block behavior and typed diagnostics. Cover all rule-code call sites
    and native/reconstructed/generated routes, census shipped malformed examples, and preserve function-body rejection. Do not broaden accepted syntax or suppress errors to obtain passing tests.
  September22 recurrence: The .83.1 prototype used nonportable infix comparison in an LX block. At the .83.1 activation, Rust exited zero after warning that the block could not parse; compiler.rs:1075-1088 returned Ok(None), and compile_rule:1303-1310 dropped it. The documented num_ne(...) call fixes the prototype spelling, but cannot close compiler rejection. This repair precedes strict-grammar delivery; exact fresh output is .linkedspec-data/scratch/sexpr-contract/compiler-drop-reproduction.json.
  Verification: .45.1 repairs shared-boundary propagation with full Rust component proof; .45.2 verifies public source and artifact boundaries; .45.3 closes the bounded repair through receipt-bound canonical acceptance. Historical eleven-control diagnosis established five malformed rule blocks accepted with
    warning, compile:ok/invoke:ok, and null or fallback 42. Three valid controls and three rejecting
    controls passed their diagnostic assertions. The pre-repair parse_rule_code_block returned Ok(None) outside
    five governed error prefixes, and compile_rule dropped that absent block. Nested-write and mutation
    argument errors also took that path.
  Commit: `SESSION-STARTUP-READING.45.3 - close Rust rule-code rejection repair`

- ID: `SESSION-STARTUP-READING.45.1`
  Status: `done`
  Activation commit: `349bde2b1f349e589c13ac19649147b3dbbc9e9b`.
  Verification tier: `focused`
  Focused checks: Malformed/valid lifecycle and edge RED/GREEN tests, exact public CLI failure controls, complete Rust core/runtime component gate and shipped/corpus compatibility, plus the committed quoted-LF manifest on the rebuilt Rust primary command; Knowledge/memory/history/book/diff and registered doctrines.
  Canonical trigger: Bounded compiler bug correction; no admitted schema or syntax change. Carrier verification .45.2 and designated canonical/public closeout .45.3 remain separate. Escalate if the component gate exposes unresolved cross-cutting uncertainty.
  Goal: Make Rust rule-code parse errors reject compilation through the shared compiler boundary.
  Dependencies: .83.1 clean checkpoint; read current parse_rule_code_block, all callers and their tests using the existing Knowledge diagnosis.
  Scope: Replace warning/drop behavior with attributed compile errors; focused lifecycle/action/blind-call and public CLI regressions. Preserve function-body errors, governed diagnostic detail and all valid code. Do not broaden syntax or suppress warnings to pass.
  Gate prerequisite: The selected Rust formatting check also exposes one pre-existing unformatted assertion in rust/linkedspec-runtime/tests/trace_controls.rs:213. This leaf owns its rustfmt-only normalization before the component gate; source/test behavior is unchanged. The initial formatter log identifies only this existing assertion and the two newly edited Rust files.
  Acceptance: RED/GREEN malformed I/E/LX/action/blind blocks, including the observed invalid comparison, with exact rule/block context; valid twins retain values and clean stderr. Run changed compiler tests and existing shipped/corpus coverage, owning any exposed failures before changing fixtures.
  Verification: PASS: 12 native invalid cases change from warning/compile:ok/invoke:ok to exit 1/compile:error with no input or invocation phase; three valid controls retain 42 and empty stderr. Four persistent core rejection groups are RED before repair; all five groups GREEN afterward (15 malformed contexts and 11 retained valid blocks). Complete Rust component gate PASS: 228 core and 574 runtime tests, including all 197 end-to-end tests, 21 shipped grammars and 105 oracle cases; primary CLI conformance is 66/66 in each default/POSIX environment, and managed-storage checks pass. The committed quoted-LF manifest passes all three cases on the rebuilt primary binary. Callable contract, book, Knowledge/memory/history/public/diff and registered doctrine checks govern focused landing. Separate carrier proof/canonical closeout and parser-cause repairs remain open.
  Commit: `SESSION-STARTUP-READING.45.1 - reject malformed Rust rule code`

  Acceptance Checklist:
  - [x] **REPRODUCE / ISSUE** — Native trace proves compile:ok/invoke:ok for 12 invalid blocks; four persistent core groups fail before repair, while valid code survives.
  - [x] **ROOT CAUSE (WHY + WHERE)** — parse_rule_code_block warned and returned Ok(None); all five compile_rule call sites discarded that missing block before downstream validation. Function-body errors already propagated.
  - [x] **FIX** — Return the parsed CodeBlock or an attributed error; retain optional absent edge code and existing parser details.
  - [x] **ADDRESSED (verified)** — All five core groups and 12 native rejection/three valid controls pass after repair; failures stop before input loading or invocation.
  - [x] **NO REGRESSION** — Complete Rust gate, shipped/corpus values, default/POSIX CLI and three quoted-LF cases pass; valid blocks, function errors and governed diagnostics survive.
  - [x] **LOCKSTEP** — Public Rust guidance, Knowledge, task/frontier and live roadmap pointers describe the verified boundary and separately owned parser/carrier work; scripts/check_memory_architecture.sh, mdBook rendering, public checks and git diff --check PASS.

  Reverify: `bash tools/run_cargo_local.sh test --manifest-path rust/Cargo.toml --locked --offline -p linkedspec-core --test rule_code_rejection`; `bash tools/run_rust_local.sh`; the native/quoted-LF replay and exact final binary identity are recorded in .linkedspec-data/scratch/compiler-rejection45/post-gate-proof.json.
  Workflow evidence: The first normal commit attempt passed eight doctrines and rejected checklist wording: the angle-bracketed Rust generic looked like an unfilled placeholder, and a reference to other unfinished tasks used the forbidden completion-marker word. Plain-language checklist wording preserves the evidence; no gate or runtime code is changed to satisfy the check.

- ID: `SESSION-STARTUP-READING.45.2`
  Status: `done`
  Activation commit: `10893fb714242c13636b4f453635aa459896825a`.
  Verification tier: `focused`
  Focused checks: Fresh source/AST reconstruction, ordinary/traced compilation, public loader and artifact-boundary regressions with valid execution controls; Rust formatting and the changed test target, plus relevant book/Knowledge/memory/history/public/diff checks and normal doctrines. Reuse .45.1's complete Rust compatibility proof only for unchanged production code.
  Canonical trigger: This leaf adds bounded route verification for the compiler correction at 10893fb71 without changing syntax, schemas or production execution. The designated canonical repair closeout remains .45.3; broaden proof if a newly reproduced production defect requires a repair.
  Goal: Verify malformed-code rejection across supported Rust compilation and artifact creation routes.
  Dependencies: .45.1 committed with clean handoff.
  Acceptance: Identify actual public native, serialized/reconstructed and generated/emitted entry routes and prove the rejection reaches each supported boundary before an artifact or accepted result is produced. Retain valid round trips and independently verify diagnostics; do not infer execution from emitted text or claim unrelated parser-panic repair .46.
  Verification: Four focused route tests PASS: eight malformed sources yield 32 ordinary/traced source/reconstructed-AST rejections, 16 path/name-loader rejections and eight failed semantic snapshots with no compiled authority or plan. Valid path/name loads, reconstructed compiled state and generated-plan execution return 42; a freshly compiled emitted module verifies direct/traced 42 and compatibility [42]. Production code is unchanged from 10893fb71; its complete Rust compatibility proof remains applicable. Rust formatting, book, Knowledge/memory/history/public/diff checks and normal doctrines govern landing.
  Commit: `SESSION-STARTUP-READING.45.2 - verify Rust rule-code rejection routes`
  Artifact boundary: Emitters consume CompiledSpec, not raw source. Rebuild older warning/drop artifacts from the original specification; no schema change or recovery of discarded code is claimed. Exact scope and rerun command: docs/knowledge/rust-rule-code-rejection-routes.md.
- ID: `SESSION-STARTUP-READING.45.3`
  Status: `done`
  Activation commit: `30c1ddeeaf22d04dfc11f875636dd7320392cd23`.
  Verification tier: `canonical`
  Focused checks: Retain .45.1 complete Rust component/native proof and .45.2 source/carrier/generated execution proof for unchanged code; align public and durable status, render book, refresh Knowledge, check memory/history/diff and run all doctrines.
  Canonical trigger: Designated parent closeout requires the exact staged-candidate tools/run_ci_local.sh receipt before commit. No optional backend rerun is needed for this documentation-only closeout; the preceding Rust component and carrier proof remains separate and exact.
  Goal: Close the verified Rust compiler rejection repair and resume strict-document implementation.
  Dependencies: .45.1/.45.2 clean handoffs.
  Acceptance: Align public compile-error guidance, Knowledge and all live pointers; distinguish syntax rejection from separately owned Unicode diagnostics and other parser defects. Run the designated canonical closeout gate and close only the verified rule-block error-propagation scope.
  Verification: Compiler correction 10893fb71 passed all core/native regressions and the complete Rust component gate; carrier checkpoint 30c1ddeea passed all four source/AST/loader/semantic/generated route tests. This documentation-only parent closeout retains those exact proofs. Canonical acceptance requires tools/run_ci_local.sh to finish successfully on the exact staged candidate and produce the receipt checked by the normal commit hook; the resulting commit and promoted receipt are the durable gate evidence. Other parser defects and document grammar delivery remain separately owned.
  Commit: `SESSION-STARTUP-READING.45.3 - close Rust rule-code rejection repair`
- ID: `SESSION-STARTUP-READING.46`
  Status: `done`
  Goal: Make Rust malformed-expression diagnostics safe at every UTF-8 boundary.
  Dependencies: Clean 92f58b56c document admission; .45 compiler rejection. ADR0123 supersedes the historical blanket .3/.4/.5 reading prerequisite.
  Verification tier: `focused`
  Focused checks: Direct CodeBlock UTF-8 boundary RED/GREEN; core library and rule-code rejection tests; public compiler/traced/loader/semantic routes and native CLI controls; Rust formatting, book, Knowledge, memory, histories, doctrines and diff hygiene.
  Canonical trigger: none — bounded Rust diagnostic repair; no public contract, dependency, generated format or gate change.
  Acceptance: Preserve scalar positions and bounded meaningful context for ASCII, multibyte and malformed expressions; retain valid Unicode and precise compiler propagation. Revisit the earlier whole-spec ASCII timeout separately before claiming its cause or a CLI Unicode panic.
  Verification: Core RED: 3 pass/1 split-scalar panic. GREEN: 201 core library tests, 4 diagnostic groups, 5 rule-code rejection groups, the primary CLI rejection test and 4 source/AST/traced/loader/semantic/generated route tests pass. Five rebuilt-native controls pass in 1.16–1.19 seconds; the former Unicode exit 101 becomes ordinary compile:error/exit 1. ASCII, valid Unicode, diagnostic byte offsets and structured scalar spans retain their behavior. Rust formatting and mdBook rendering pass. Logs: .linkedspec-data/scratch/utf8-diagnostic46/. The historical 30-second ASCII timeout is not reproduced by the current 80-character control; its exact original body/cause remain unknown and no retrospective cause claim is made.
  Commit: `SESSION-STARTUP-READING.46 - preserve UTF-8 diagnostic boundaries`
  - [x] **REPRODUCE / ISSUE** — Native LinkedSpec CLI --trace low reproduces exit 101 and the split-scalar panic; ASCII/aligned/valid controls retain expected results. Core CodeBlock RED independently fails at byte 40 within e-acute bytes 39..41.
  - [x] **ROOT CAUSE (WHY + WHERE)** — CLI panic names expr.rs:2702: endpoint 47 splits scalar bytes 46..48. unexpected_character_error formats src[pos..pos+40]; native ASCII succeeds in 1.35 seconds, leaving the historical timeout cause unknown.
  - [x] **FIX** — Bound the existing 40-byte excerpt at the preceding scalar boundary; no production catch_unwind, syntax change, byte-position change or structured scalar-span change.
  - [x] **ADDRESSED (verified)** — Both CodeBlock modes pass all UTF-8 alignments; the native panic becomes ordinary compilation rejection through source/AST/traced/loader/semantic/CLI routes, before input loading or execution.
  - [x] **NO REGRESSION** — All selected 210 core and 5 runtime tests pass, including valid generated execution; all five native controls pass. Valid text, scalar spans and legacy byte-position text remain exact; no dependency changes.
  - [x] **LOCKSTEP** — Rust integration/book guidance, Knowledge, roadmap and live recovery pointers record the bounded fix and the historical timeout limitation. Book/formatting pass; focused governance governs landing.
- ID: `SESSION-STARTUP-READING.47`
  Status: `done`
  Goal: Align empty mutation arguments and preserve authored source through the Rust parser/compiler pipeline.
  Children: `SESSION-STARTUP-READING.47.1`, `SESSION-STARTUP-READING.47.2`, `SESSION-STARTUP-READING.47.3`
  Decision: Split inside this active tree after exact CRLF source-retention failure; commit each bounded repair before starting the next. No dirty tree pivot or normalized expectation.
- ID: `SESSION-STARTUP-READING.47.1`
  Status: `done`
  Goal: Align Rust parser and compiled validation for whitespace-only mutation argument lists.
  Dependencies: Clean f7e940254 UTF-8 diagnostic repair; .45 compiler rejection. ADR0123 supersedes the old blanket .3/.4/.5 reading gate.
  Verification tier: `focused`
  Focused checks: Public CLI/Core RED/GREEN; exact source/scalar-span retention and nonempty/forged-argument rejection; native/serde/generated-plan/emitted Rust mutation routes; unchanged neutral mutation checker; direct core/runtime regressions, book, Knowledge, memory, histories, doctrines and diff.
  Canonical trigger: Parent .47.3 runs canonical closeout after .47.1/.47.2; this focused leaf preserves frozen authority and format.
  Acceptance: Accept semantically empty parentheses with exact supplied ActionIR/source-AST text and scalar spans; outer whole-spec capture belongs to .47.2; retain nonempty-argument rejection and corrupted-carrier validation through native and supported reconstructed/generated routes. Reconcile public teaching without normalization or a contract rewrite.
  Verification: PASS: 201 core library tests, 4 diagnostic groups, 5 rule-code rejection groups, 179 runtime library tests and 12 mutation contract tests. Seven whitespace spellings retain exact supplied action source/scalar spans; seven nonempty syntax cases and eight forged projections reject. Native, serde, generated-plan and independently compiled emitted execution agree. Six rebuilt-native controls pass; neutral 4/14/5 syntax and 167+592 mutations pass with byte-identical authority. Book, formatting and public no-drift checks pass; normal governance hooks govern landing. Initial corrected RED rejects the frozen whitespace case with mutation_call_invalid. First post-fix whole-spec run had 179 library/11 mutation passes and one CRLF-retention failure; .47.2 retains that evidence and its unweakened expectation. .47.1 isolates compiler fidelity via public caller-supplied SpecFile action code. Logs: .linkedspec-data/scratch/mutation-arguments47/.
  Commit: `SESSION-STARTUP-READING.47.1 - accept empty mutation argument whitespace`
  - [x] **REPRODUCE / ISSUE** — Native LinkedSpec CLI --trace low succeeds only for (); three semantically empty spellings wrongly stop at compile:error/exit1. Two nonempty controls correctly reject; all six finish in1.20–1.21seconds.
  - [x] **ROOT CAUSE (WHY + WHERE)** — Public compile rejects the unchanged neutral insignificant_whitespace case as receiver_mutation_serialized_state_invalid, reason mutation_call_invalid. compiler.rs::validate_receiver_mutation_block compares the projected args span to literal ().
  - [x] **FIX** — Require opening/closing parentheses and a trim-empty interior through is_empty_argument_list; validate the original span projection without modifying source or coordinates.
  - [x] **ADDRESSED (verified)** — Native, reconstructed and generated carriers agree on values and source/spans for the whitespace matrix; negative mutation controls reject.
  - [x] **NO REGRESSION** — Neutral authority remains byte-identical; focused Rust mutation and direct-dependent tests pass, with prior known .58/.59 exceptions remaining separately owned.
  - [x] **LOCKSTEP** — Rust integration/book, Knowledge and live roadmap/task pointers accurately describe the verified repair and next frontier.

- ID: `SESSION-STARTUP-READING.47.2`
  Status: `done`
  Goal: Preserve accepted multiline Rust action source and coordinates during outer block collection.
  Dependencies: Clean .47.1 validator repair.
  Verification tier: `focused`
  Focused checks: Public parse_spec/source-AST LF/CRLF, blank lines, indentation and Unicode; lifecycle/edge/header collection and remainders; Rust component, mutation and source-carrier proof; book, Knowledge, memory, histories, doctrines and diff.
  Canonical trigger: Parent .47.3 closeout; escalate this leaf if repair uncovers broader contract uncertainty.
  Acceptance: Restore exact accepted block interiors and scalar positions without changing established outer trim or widening multiline-quote/regex-brace syntax; reinstate whole-spec source-fidelity assertions and retain valid execution and rejection controls. Preserve compact-header string values exactly; a native contrast proves two spaces or a tab becomes one space only on the header.
  Verification: .47.1 whole-spec carrier assertion fails: original CRLF becomes LF. parser.rs uses source.lines(), then consume_block_from_rest trims each physical line and rejoins with LF; direct CodeBlock retains exact CRLF. Quoted-newline native/Perl probes both reject, so they establish no accepted string-value corruption or equivalence. Separate native compact-header probes now establish actual corruption: E{return("a  b")} and an authored tab both return a single space; the body-line twin retains two spaces. parse_rule_header fallback reconstructs mode_raw plus one space plus rest_raw. Exact evidence: .linkedspec-data/scratch/action-source47-2/header-literal-before.jsonl and remainder-value-before.jsonl. First component pass: core201 and four source groups pass, one remainder group fails by dropping a blank line; Corrected line-origin handling passes all six source groups and the complete core package. Rebuilt-native25 passes exact header literals, both assignment controls returning4, and retained malformed/multiline-quote rejection. PASS: complete Rust component gate (238 core tests, runtime library179, all integration targets, storage oracle and CLI66/66 twice); six core source groups cover 88 block combinations plus header/remainder/scalar controls. Two runtime groups cover 15 exact literal values and the skipped-assignment regression. All12 mutation tests pass through whole-spec and programmatic source ASTs, serde, generated plans and independently compiled emitted consumers. Final native25 passes with binary SHA256 2025d1ce7556aaae4b5ef516344ed7054e7620bc51d7f454c778938279464be4. Neutral167+592 mutations retain byte-identical authority; book, formatting and public no-drift pass. Logs: .linkedspec-data/scratch/action-source47-2/rust-gate-origin.log and native-after-final.jsonl. Logs: .linkedspec-data/scratch/mutation-arguments47/runtime-green.log and source-fidelity-probe.jsonl.
  Commit: `SESSION-STARTUP-READING.47.2 - retain Rust action source through outer parsing`
  - [x] **REPRODUCE / ISSUE** — Core RED compiles: one compatibility group passes, four exact-source groups fail. Eight native syntax/value controls pass; separate compact-header/body controls prove literal whitespace corruption.
  - [x] **ROOT CAUSE (WHY + WHERE)** — source.lines drops CR, suffix/block trims remove whitespace, and LF joins normalize text. Header fallback synthesizes one space inside quoted literals. A second block on a closing line starts with the cursor already on the next line, so its collector skips that line; the native assignment control wrongly returns3 rather than4.
  - [x] **FIX** — Retain CR-bearing physical lines, raw block interiors and suffixes; restore the exact header tail. Track same-line remainder origins separately from the consumed-line cursor, including the multiline fluent cursor contract. Keep whole-interior trim and existing lexical recognition.
  - [x] **ADDRESSED (verified)** — LF/CRLF/mixed-line, blank/indented, Unicode, lifecycle/edge/header and source/carrier tests pass.
  - [x] **NO REGRESSION** — Complete Rust component proof, native controls and unchanged shared mutation authority pass; known scanner/guard repairs remain separate.
  - [x] **LOCKSTEP** — Public integration guidance, Knowledge, task ownership and live roadmap pointers describe the exact repaired boundary.
- ID: `SESSION-STARTUP-READING.47.3`
  Status: `done`
  Goal: Close the verified mutation-argument/source-fidelity repair and resume .49.
  Dependencies: Clean .47.1/.47.2 repairs.
  Verification tier: `canonical`
  Focused checks: Reconcile exact native/source/carrier proofs and immutable neutral authority; update all live/public pointers, render book and run memory/history/Knowledge/doctrines/diff checks.
  Canonical trigger: Designated parent closeout requires exact staged-candidate tools/run_ci_local.sh receipt before commit. Retain preceding Rust component proof; optional backend matrices are not selected for this documentation-only closeout.
  Acceptance: Close only verified argument and source-fidelity scope; preserve .49 and .52-.54/.58-.59 ownership and record canonical receipt evidence.
  Verification: Validator repair a6ff64e56 and source repair 01c40fd3f are committed and verified. The latter passes the complete Rust component gate, core238, all runtime targets, storage and CLI66x2; final native25 uses SHA256 2025d1ce7556aaae4b5ef516344ed7054e7620bc51d7f454c778938279464be4. Whole-spec/programmatic, serialized, generated and independently compiled emitted carriers preserve the tested source and values. Neutral authority retains167+592 mutation proof. This documentation-only closeout requires successful canonical tools/run_ci_local.sh on the exact staged candidate and its receipt before landing; the commit body and promoted receipt record the result. Separate .49/.52-.54/.58-.59 defects remain open.
  Commit: `SESSION-STARTUP-READING.47.3 - close Rust mutation argument and source repairs`

- ID: `SESSION-STARTUP-READING.49`
  Status: `done`
  Goal: Preserve Rust statement boundaries after unflagged regex literals.
  Dependencies: Clean .47 closeout; .45 error propagation is repaired. ADR0123 supersedes the blanket reading prerequisite.
  Verification tier: `focused`
  Focused checks: Public CLI/Core RED/GREEN; regex flags, LF/CRLF and statement boundaries; exact source/AST, native/serde/generated/emitted routes; relevant Rust core/runtime compatibility, Perl public oracle, book, Knowledge, memory, histories, doctrines and diff.
  Canonical trigger: Ordinary bounded parser repair retains existing regex semantics and formats; no new canonical boundary before a milestone or push.
  Acceptance: Keep regex suffix flags adjacent to their closing slash and preserve following
    newline/semicolon statement separators. Compare unflagged and flagged regex assignments, ordinary
    string assignments, CRLF and whitespace boundaries, and arithmetic slash-call controls. Retain
    subsequent assignment AST/source spans through native and supported serialized/reconstructed/generated
    routes. Coordinate with .45 so malformed blocks reject, while this valid newline form compiles and
    returns seven. Do not silently expand or redefine regex flag semantics; split wider changes before
    implementation.
  Historical pre-.45 verification: Four managed native CLI controls all exit zero. Semicolon-separated regex assignment, adjacent-flag regex plus newline, and string plus newline return seven without warnings. Unflagged regex plus newline returns null with a parse-I-block warning at byte 13 and compile:ok/invoke:ok. expr.rs parse_regex skips whitespace before scanning ASCII suffix letters, consuming the newline and following out identifier; .45's compiler path then drops the invalidated block. The separate core harness timed out during rustc compilation and never ran; its exact scratch absence was verified.
  Current proof: Scoped core RED has 4 failures/1 pass; GREEN has 5 passes; all 243 core tests pass. PASS: 243 core tests; 397 selected runtime tests (179 library, 197 integration, 2 source-fidelity, 3 regex, 13 mutation, 3 corpus groups covering 105 fixtures). The regex target checks 32 assignments, exact nested-write source, 3 valid and 3 invalid controls across source/compiled serde and generated plans. The new mutation case also passes independently compiled emitted execution. Native: 22 checks pass (16 return 7, 3 malformed inputs reject, 3 symbol-call rejections remain owned by .86); the exact book example returns 7. Binary SHA-256: 2675f2ffb467b123ef6e866b3765c68232a519aac42f6771ed620eef8e0e4e24. All 12 explicit-edge Perl cases return 7. Book/public checks, Knowledge, memory, histories and doctrines are required before landing; exact command logs are under .linkedspec-data/scratch/regex-boundary49/. Original arithmetic failure is retained under immediate .86; no-edge Perl value comparisons remain excluded under .27.
  Commit: This commit; subject `SESSION-STARTUP-READING.49 - preserve regex statement boundaries`.
  - [x] **REPRODUCE / ISSUE** — LinkedSpec CLI --trace low and public Get reproduce the three Rust-only newline failures; the untouched core test target reports exact parser errors and a lost identifier statement.
  - [x] **ROOT CAUSE (WHY + WHERE)** — expr.rs::parse_regex calls skip_whitespace before consuming suffix letters; the following out/flag identifier is consumed. CodeBlock reports the missing separator at byte13, or silently retains only one statement for /x/ followed by flag.
  - [x] **FIX** — Remove parse_regex whitespace skipping before the unchanged adjacent ASCII suffix loop. Preserve the existing pattern-only carrier; .86 owns the separate symbol-call lookahead.
  - [x] **ADDRESSED (verified)** — Exact statements/source and native/reconstructed/generated values agree after repair.
  - [x] **NO REGRESSION** — Focused Rust compatibility and valid/invalid controls pass; separately owned defects remain open.
  - [x] **LOCKSTEP** — Rust integration/book, Knowledge, roadmap and task/live pointers match the verified boundary.

### Forward reading and confirmed findings preserved by `.31`
The exact `.3.2.21` canonical candidate stayed frozen while read-only preparation continued. This intake
preserves that preparation before its queued reading checkpoints are committed. It grants no runtime repair,
policy adoption, public-book change, or codebase-wide signoff. The existing `.3.2.22`–`.3.2.54` owners still
require their individual comprehension/Knowledge/live-document checkpoints and commits; none is bulk-closed.
#### Exact forward Perl reading
All 89 baseline Perl entries have now been read in full, including generated material. All current Perl bytes
remain identical to `baeb984e36a94a15951cd23d4c52def5064cdaca`. The committed checkpoint before this intake credits
29 whole files through `.3.2.21`. The following actual read-only coverage is durable; each named leaf's existing
Scope remains the exact path/range owner. MCP byte fragments are inclusive, one-based offsets within its blob.
| Queued checkpoint | Untruncated reading chunks within its existing Scope | Scoped lines/fragments; bytes |
| --- | --- | ---: |
| `.3.2.22` | MethodExpr 1–150 / 151–298 | 298; 7,800 |
| `.3.2.23` | MethodLowering 1–195 / 196–405 / 406–605 / 606–815 / 816–1010 / 1011–1210 / 1211–1405 / 1406–1495 | 1,495; 61,967 |
| `.3.2.24` | MethodLowering 1496–1700 / 1701–1905 / 1906–2110 / 2111–2290 / 2291–2378 | 883; 33,969 |
| `.3.2.25` | MethodLowering 2379–2585 / 2586–2795 / 2796–3005 / 3006–3210 / 3211–3410 / 3411–3580 / 3581–3743 | 1,365; 65,506 |
| `.3.2.26` | MethodLowering 3744–3940 / 3941–4135 / 4136–4325 / 4326–4520 / 4521–4715 / 4716–4911; the second range was repeated without truncation | 1,168; 58,949 |
| `.3.2.27` | MethodLowering 4912–5065 / 5066–5230 / 5231–5390 / 5391–5535 / 5536–5680 / 5681–5810 / 5811–5942 | 1,031; 64,411 |
| `.3.2.28` | MethodLowering 5943–6110 / 6111–6280 / 6281–6445 / 6446–6610 / 6611–6810 / 6811–7010 / 7011–7245 | 1,303; 64,878 |
| `.3.2.29` | MethodLowering 7246–7450 / 7451–7655 / 7656–7855 / 7856–8057; ProgressiveSpanDispatch 1–165 | 977; 36,165 |
| `.3.2.30` | RewritePipeline 1–185 / 186–370 / 371–555 / 556–745; Scanner 1–90; FlowRules 1–175 / 176–338 | 1,173; 41,839 |
| `.3.2.31` | LegacyRules 1–195 / 196–390 / 391–585 / 586–780 / 781–980 / 981–1179; PrimitiveBasicRules 1–135 / 136–254 | 1,433; 41,163 |
| `.3.2.32` | PrimitivePipelineRules 1–190 / 191–380 / 381–571; RecognitionTransactionRules 1–124; ScannerCore 1–223; StagedParseJob 1–195 / 196–393; StatementSplit 1–44 | 1,355; 48,756 |
| `.3.2.33` | StatementSplit Core 1–210 / 211–419, Mode 1–214, ActionIR Trace 1–124; ValueExpr 1–175 / 176–350 / 351–520 / 521–666 | 1,423; 47,678 |
| `.3.2.34` | BindingRuntime 1–210 / 211–422; CallableContract 1–135; CodeblockRuntime 1–200 / 201–403; InterMatchGapRuntime 1–150 / 151–291; MCPContract 1–13 | 1,264; 39,889 |
| `.3.2.35` | MCPContract bytes 391–16774 / 16775–33158 | 1; 32,768 |
| `.3.2.36` | MCPContract bytes 33159–65926, consumed in bounded byte output | 1; 32,768 |
| `.3.2.37` | MCPContract bytes 65927–83273 | 1; 17,347 |
| `.3.2.38` | MCPContract 15–21; MCPContractRuntime 1–160 / 161–300; MCPServer 1–160 / 161–325 / 326–490 / 491–648; MCPWire 1–210 / 211–419; Numeric 1–110 | 1,484; 51,303 |
| `.3.2.39` | PluginBridge 1–199; PluginRegistry 1–130; ProgressiveSpanDispatch 1–225 / 226–455 / 456–685 / 686–937; ProgressiveSpanDispatchPolicy 1–58 and ProgressiveSpanDispatchRuntime 1–172 | 1,496; 52,208 |
| `.3.2.40` | RecognitionTransaction 1–220 / 221–440 / 441–655; its Policy 1–140 / 141–269 | 924; 33,632 |
| `.3.2.41` | RecognitionTransactionRuntime 1–230 / 231–460 / 461–681; RecursiveObservationPolicy 1–71; RuntimeDiagnosticOutput 1–145 / 146–247; RuntimeLogical 1–96; RuntimeSemanticObservation 1–174 | 1,269; 39,210 |
| `.3.2.42` | SemanticCallProjection 1–195 / 196–385 / 386–570 / 571–753; SemanticIndex 1–190 / 191–395 | 1,148; 37,003 |
| `.3.2.43` | SemanticQuery 1–200 / 201–400 / 401–596; SemanticRuntimeProjection 1–214; SemanticSourceMap 1–172 | 982; 35,427 |
| `.3.2.44` | SemanticStaticProjection 1–225 / 226–455 / 456–685 / 686–890 / 891–1067 | 1,067; 34,029 |
| `.3.2.45` | SourceLocation 1–230 / 231–465 / 466–700 | 700; 21,209 |
| `.3.2.46` | StagedASTEnrichment 1–220 / 221–440 / 441–670 / 671–900 / 901–1130 / 1131–1355 / 1356–1498 | 1,498; 49,952 |
| `.3.2.47` | StagedASTEnrichment 1499–1720 / 1721–1940 / 1941–2013; StagedASTEnrichmentRuntime 1–120; StagedParseJob 1–180 / 181–352; StagedParseJobPolicy 1–59; StagedParserRegistry 1–170 / 171–328 | 1,374; 43,289 |
| `.3.2.48` | Trace 1–185 / 186–365 / 366–521 | 521; 16,259 |
| `.3.2.49` | UnicodeCaseMapping 1–1500, consumed in smaller complete table ranges | 1,500; 32,073 |
| `.3.2.50` | UnicodeCaseMapping 1501–3000, consumed in smaller complete table ranges | 1,500; 32,854 |
| `.3.2.51` | UnicodeCaseMapping 3001–3835, consumed in smaller complete table ranges | 835; 17,404 |
| `.3.2.52` | UnicodeXIDContinue 1–855, complete generated range records | 855; 17,340 |
| `.3.2.53` | UserFunctionRegistry 1–205 / 206–410 / 411–605 / 606–773; PPlugin 1–175 / 176–331; PathSearch 1–47; env.conf 1–51 | 1,202; 45,829 |
| `.3.2.54` | gdcheck 1–225 / 226–431; htmlcss_driver 1–166; ptchange 1–125 / 126–242 | 839; 22,702 |
The 82,883-byte MCP payload on logical line 14 was also decoded and reconciled with its 35-frame material.
Its three fragment SHA-256 values are 7846664315f28f00563a9dac88632f47f5c8fbf531ff10215724620764f2df19,
5b77ebfcc05b4bf50d90ad0891f87665cc3709c45579df37452a5e76e280dc10, and
0c3751e106207329bacee0b2b0dfde9916242054364fcac63f493df47670c616.
UnicodeCaseMapping's complete file is 3,835 lines / 82,331 bytes. UnicodeXIDContinue contains the existing
806 generated ranges; its existing digest is d1b00bda47306e61ee20a7f63db783f98b15d8d15b876c7506bc4b79ecebc0bb.
The exact-byte encoding audit found only gdcheck comment lines 164/165/167 with raw 0xb5; those bytes were
read through escaped byte representations. No source conversion or runtime encoding defect is claimed.
#### Confirmed runtime and tooling findings
- `.17`: Six public Get parsers were each compiled once with proper runtime context and run against isolated
  empty/populated host slots. Wrong-kind count/first/last changed from 0/null/null to 2/first/last;
  count_keys/sorted_keys/has_key changed from 0/[]/0 to 1/[k]/1. Context errors stayed null and local seeds
  were restored. MethodLowering's array fallback around 5793–5860 and hash/view/member paths around 6115–6400
  use helper-looking names as host slot candidates before enforcing the evaluated value kind.
- `.18`: A quoted value containing set(counter, 2) is rewritten even without an executable set call, and
  contributes a false ASSIGN event. Toolbox output localizes the unmasked PrimitivePipelineRules matcher
  (132–150), raw RewritePipeline replacement, and independent CanonicalEvents search (249–267). Lexical repair
  and canonical-event repair are separately owned; source data must remain source data.
- `.19`: Direct receiver assignment inside map_leaves! hits the typed guard; public Get returns a runtime_handler
  failure with null result and a retained typed detail object. A dynamic codeblock
  assignment bypasses it: the traversal can produce [a:X,a:X] or return a detached shadow with a changed
  tree while the original path remains unchanged. CodeblockRuntime's write_binding/eval-assignment paths
  (96/238) bypass the resolved guard enforced by BindingRuntime (76/96). Parameter shadowing remains
  distinct from nonparameter writes; no arbitrary caller-capture feature is authorized.
- `.20`: num_add on the string containing U+0661 and 1 returns 1 with a host warning in Perl; the neutral
  Python oracle returns 2. Mixed ASCII 1 plus U+0662 yields 2 with a warning versus the model's 13.
  Numeric's Unicode \d acceptance followed by host 0+ conversion (23–25) explains truncation. The intended
  digit language must be resolved from authority; this intake does not assume that ASCII rejection is correct.
- `.21`: Quoted transaction-token text is falsely diagnosed as escape. Separately, warming the compiler
  with token ticket before compiling a bare tx escape makes the latter accept with INVALIDATED/error-null
  state; a fresh bare tx case rejects. RecognitionTransactionPolicy 186–190 interpolates a token name into
  a /o regex, caching the first name. No runtime escape of active authority was demonstrated.
- `.22`: On the same Top rule whose self-edge assigns trim(" x ") then returns the binding, Perl, Dart,
  Julia, PUC Lua, and LuaJIT compile/query successfully but return no helper/binding/call records. Prepending
  an unused function produces exactly helper:trim, helper:return, binding:edge:rule:Top:0:value:0, and calls
  call:edge:rule:Top:0:0 / :1, in order. Empty-function early returns precede rule projection in Perl
  SemanticCallProjection 94, Dart semantic_call_projection.dart 113, Julia SemanticCallProjection.jl 87, and Lua
  semantic_static_projection.lua 1828. Rust remains unprobed. The earlier Julia I-block control returned []
  in both cases and is not proof of this guard; its edge-only action-owner scope was read explicitly.
- `.23`: Get correctly rejects recognition_token_escape, but static semantic projection fabricates
  dependency_target_missing with a blank target and an uninitialized warning. A genuine missing-rule
  control is correct. SemanticStaticProjection's unconditional dependency-failure path (314 onward; 402/416/418)
  loses the actual failure class; it must preserve evidence or use an honest fallback.
- `.24`: A seeded $@ survives quiet trace and plain detail. A successful lazy detail callback replaces it
  with an empty value; a throwing callback replaces it with its own error. Trace 398–439, especially the
  unlocalized eval at 423, is the cause. Exception identity, nested trace, and parser context are repair criteria.
- `.25`: gdcheck marks equal -100 values as below tolerance and -100 to -95 as above at tolerance 10;
  positive twins are unmarked. Its signed margin reverses the interval. Adding/removing two duplicate-key
  rows processes only index zero. DEFAULT with zero or two patterns is accepted because length(@EVAL)
  measures the count's decimal digit length rather than requiring one element.
- `.26`: A managed Open3 argv-list caller supplied identical plain.txt and "with space.txt" inputs.
  ptchange preserved the plain input but emitted empty output for the spaced path, both exit 0; cat's
  stderr shows path splitting. The script uses qx(cat $ARGV[0]) at 30, two-argument output opens at 132/155,
  and a machine-specific shebang. This is a valid-filename failure; arbitrary command execution was not tested.
- `.27`: The existing perl-lifecycle-final-value-e-drift card and ADR 0020 were read before probing.
  Top's no-edge /x/ with E return(match_text()) gives Perl 0 and Julia "x", including Julia trace.
  Explicit self-edge return controls produce "x" on both. Perl's no-edge E constant gives 0; its I constant
  works; E after edge assignment gives null. Full generated source omits regex/E handling: the default
  HandlerVariantEmitter builder (100–115) returns undef without action code, while SpecEntry passes E code
  without a usable handler (143–186/287–295). Julia's mode execution keeps its own regex. Reconcile intent;
  do not infer that Julia is wrong or erase the existing accurately scoped Perl caveat.
- `.29`: An extracted copy of the actual diagnostic gate predicate was executed on eight lexical path
  controls, without changing the index. Perl/Rust/t/tools paths are governed; Dart/Julia/Lua/tests peers are
  excluded by scripts/check_diagnosis_evidence.sh 21–29. These are path-classification controls, not file
  existence claims or full staged-hook proof. The existing evidence-shape-only limitation remains explicit.
- `.30`: Public Get and complete generated-source inspection show the book's grouped edge returns
  {kind:token,text:null} for both bare and quoted alternatives. Explicit per-edge retv=call(target) returns
  bare-child/quoted-child; a shared match_text block returns the corresponding raw text. All contexts are
  error-free. HandlerVariantEmitter's action dispatcher (489–519) emits authored blocks and does not
  synthesize the missing child call. The documentation fix must preserve that semantic boundary.
#### Measured public-checker gaps
- `.28.1`: The full value/container helper reference still calls string zero false, empty aggregates true,
  and the five-backend rollout pending at 1431–1436, with a stale pending heading at 1273. Five public Perl
  truth controls match the admitted contract. The actual logical checker passes 17 truth cases / 10 helpers /
  3 effect cases / 8 complete and its 19-document / 14-denial / 26-mutation public checks. Its required markers
  and exact denial strings omit the real contradictory paragraph (source 256–399 and 815–829).
- `.28.2`: The values/containers guide's 76–77 paragraph retains the prior-backends hash-selector claim,
  although the same chapter records all-five-backend closure. The actual mutation public checker passes
  63 files / 14 documents / 11 example classes / 10 denials / 50 mutations. It already normalizes whitespace
  (257–281); its denial inventory (154–172) lacks the observed claim.
- `.28.3`: What LinkedSpec Is 32–43 says parse_job is future/unavailable. The existing portable authoring
  owner proves the current assignment-annotation form. The staged contract checker passes 123 neutral
  mutations and public 6/17/10/129; its actual public reader excludes that introduction
  (412 onward, 1438–1448, 1557–1567). Reserved import/provider boundaries remain unchanged.
- `.28.4`: Semantic Introspection near 984 says the global ledgers are "now 3/9 and 2/6" instead of 9/9 and
  6/6. The real public_contract_text_errors function receives the page with that sentence and returns [].
  All 28 declared pages are present; the gap is denial coverage, not a missing page. The checker passes
  6 groups / 20 queries / 128 mutations and current 9/0 plus 6/0 ledgers.
- `.28.5`: Helper Catalog 298/313 says definedness is condition-only despite its own current expression
  support note. Four true and four false returned/nested-with controls all compile/run without error;
  Perl represents those observed results as 1 and empty string. MethodLowering 4114/4116 emits defined/
  !defined for values, while FlowExpr 474–487 handles conditions. The catalog's cat entry says undef
  fragments become empty text, but cat("a",undef,"b") and its array twin return null, whereas the empty-string
  twin returns "ab". Full emitted once-only part-list/null-guard code and MethodLowering 5330 onward agree
  with the existing scalar-to-text contract. No portable return-encoding promise follows from these Perl probes.
- `.28.6`: Helper Catalog near 1281 claims exit_now terminates the parser process. The host demonstrably
  continues after catching LinkedSpec::RuntimeExitNow with kind runtime_exit_now, rule Top, status 2;
  context error stays null and the following return is not executed. RuntimeDiagnosticOutput 180–191
  constructs, marks, and throws the typed object. The actual diagnostic checker passes 3 helpers / 11
  render rows / 6 scenarios / 8 complete / 20 mutations; its catalog markers and single old-suffix denial
  do not cover the false process-exit paragraph (190–310/639–649).
#### Supporting book and tool reading
The following complete book sources are baseline-identical. Existing partial reads inside them are not added
twice. Full source reading is distinct from a rendered-book inspection, and `.4` still owns formal chapter
decomposition, remaining reading, and alignment.
| Book path below `docs/linkedspec-book/` | Full lines; bytes |
| --- | ---: |
| `.gitignore` | 1; 6 |
| `book.toml` | 15; 347 |
| `src/SUMMARY.md` | 76; 3,354 |
| `src/index.md` | 40; 2,133 |
| `src/overview/what-is-linkedspec.md` | 99; 6,691 |
| `src/overview/documentation-layers.md` | 63; 3,020 |
| `src/dsl/action-and-lifecycle-placement.md` | 658; 24,890 |
| `src/public-api/native-spec-loading.md` | 375; 22,275 |
| `src/public-api/plugin-registry.md` | 63; 3,278 |
| `src/public-api/trace-api.md` | 636; 39,386 |
| `src/public-api/semantic-introspection.md` | 4,282; 290,387 |
| `src/dsl/value-container-flow-helper-reference.md` | 1,831; 87,584 |
| `src/dsl/values-containers-and-flow-helpers.md` | 662; 32,595 |
| `src/appendix/helper-contract-catalog.md` | 1,943; 120,603 |
The previous partial `development/local-ci-and-regression.md` ranges 1897–1943 and 1988–2004 remain covered.
Together these are 16 disjoint completed ranges / 640,041 bytes; all remaining book source is 1,316,541 bytes.
Independent LF-byte interval and hash accounting covers all 50 baseline paths / 1,956,582 bytes exactly once.
Semantic Introspection's full SHA-256 is 1d7f3db65618c8169f8e49c9532024b95300a0d09beea8004a42e381fccf6fd5;
Helper Catalog's is 36874564ee5bc3a2bef85cc05560dedf1d251c3a4052b2c71abb2ecceb6cb1c7.
All large chapters were consumed in smaller untruncated chunks; preloaded but unreturned tool output was not
counted until it was emitted and read.
Supporting tooling now also includes complete `tools/project_data_env.sh` 1–288,
`tools/test_project_data_process_locality.sh` 1–329, and the Dart/Lua/Julia project-data wrappers.
The diagnostic evidence gate was reread in full. Supporting native source ranges for `.22` were Dart's
semantic call projection 92–180, Julia's call projection 73–155 and action-owner helper 1009–1078,
and Lua's static projection 1820–1935; these do not complete the native files or their reading lanes.
#### Resolved questions and remaining ownership
- `array.length` in the variadic-function example is already supported; the existing variadic-function fact
  resolves the question. Semantic explain budgets are operation-specific under ADR 0049. Neither becomes a defect.
- Managed startup-only Julia controls for ordinary, one-interior-empty, and two-interior-empty depot fields
  yield local depots with optional system depots, always with user_depot_present false. Startup/history and
  package loading were disabled; exact temporary inputs were cleaned. No home-depot access defect is established.
- Both baseline and current Git contain exactly thirteen parked `noncore/plugin/*.plg` paths. The existing
  PPlugin transition card's nineteen-file count is dated June evidence; `.3.2.53` will qualify it and record
  the current census in that owner. The book's thirteen-file count is correct; enumeration is not plugin reading.
- Existing lifecycle debt remains linked to ADR 0020 and its original card. No duplicated lifecycle discovery,
  speculative Julia failure, or new implicit grouped-edge child-call behavior is claimed.
- MethodExpr's focused control independently confirms three authored values in a distinct returned array,
  two values through legacy/fixed-arity fallback, an unchanged original list, and rejection below minimum arity.
#### Supplied-policy comparison evidence
All donor reads were explicitly authorized, read-only, and scoped to the supplied files. Each donor's scoped
Git status was clean when compared. These records preserve provenance; `.5` still owns adoption decisions,
mechanical changes, and final alignment after required reading.
- fsmgen `README_POLICY.md`: 187 lines / 9,849 bytes; SHA-256
  882682fa1ace703ae68726b8532a4ad24fe2c8a271bae4e07b859bd197a621c9.
  Latest file change is `1f0443b3a4e654f8460ba6eda272c53e1d8b642d` (August 20).
  The complete latest diff changes only fsmgen's local adoption note from a pinned capacity to a derived
  downward ratchet; the neutral body is unchanged. LinkedSpec already adopted its own independent
  128-line / 6,144-byte README boundary under ADR 0063 and subsequent routing closure. Do not copy donor caps.
- fsmgen `docs/LIVE_DOCUMENT_SIZE_CONTAINMENT_ADOPTION_GUIDE.md`: 431 lines / 21,327 bytes; SHA-256
  8f77fa39c9bcb9cfc43166259a627a6ced64682030088400b727dccc5d674a53.
  Latest file change is `727e0d0861efeb8288b23ccd75e6b751c2fdc771` (September 5).
  Its latest seven-line update distinguishes stable delegated checker success from duplicated changing
  registry cardinality; exact counts remain valid for fixed synthetic fixtures. The complete guide also
  classifies derived-on-read, verified copies, authored intent, and immutable evidence, with explicit field
  ownership and lossless migration. LinkedSpec's README/memory/history systems implement parts of these
  principles; this is not evidence that the whole donor package is adopted. Review actual fields/consumers in `.5`.
- pgen `docs/CLAIM_VERIFICATION.md`: 285 lines / 18,166 bytes; SHA-256
  9f99df25209c43afb74d77e348dd2d0cdb68ce96cf17a4f272ede8328f6046bd.
  Latest file change is `178251cceeae72173db20db3f409db4abc7e517c` (August 30).
  The added section 4.1 distinguishes prose, numbers, and named-instance claims; contract numbers require
  exact gated evidence, while deterministic populations and explicit patterns are the authoring standard.
  The complete policy requires independent rederivation, revert/reapply RED proof, and independent falsification,
  with durable inputs and bidirectional history coverage. No explicit local adoption filename/phrase was found;
  that does not imply all principles are absent. Existing TASK-ACCEPTANCE checks evidence shape and deliberately
  do not execute Markdown commands. `.29` owns its measured path gap and runs before `.5` adoption closeout.
September 11 group .1.6 recheck: all three supplied files were fully reread, read-only; their
SHA-256 identities above are unchanged. No donor revision or local adoption is claimed by this check.
#### Remaining reading preparation
Read-only decomposition drafts are preparation and carry no source-reading credit. Git plus the existing
disjoint class selectors remain the inventory authority; no additional tracked manifest was introduced.
Independent validators checked object identities, LF/decoded-byte intervals, exact-once coverage, empty files,
and the 1,500-line / 65,536-byte budgets. Formal child creation and manual boundary review still precede reading.
| Pending lane | Baseline paths | Stored bytes | Draft reading groups |
| --- | ---: | ---: | ---: |
| Rust | 412 | 3,533,382 | 67 |
| Dart | 115 | 2,471,305 | 57 |
| Julia | 95 | 2,693,170 | 53 |
| Lua | 99 | 2,732,450 | 51 |
| Specs/configuration/noncore | 158 | 964,256 | 19 |
| Shared verification/Unicode inputs | 160 | 5,422,313 | 144 |
| Repository tools | 143 | 2,381,957 | 38 |
The native drafts preserve two empty Rust fixtures and two oversized generated-line fragments each for
Rust/Dart/Lua. Shared verification includes all four pinned gzip objects and their 3,352,036 decoded bytes;
its total reading representation is 8,257,059 bytes. The sole current tooling delta is the owned
`doctrine/readme_stability/routes.jsonl` history-capacity change; it is explicitly accounted for.
The book draft follows SUMMARY order and leaves 48 pending ranges; one project-status boundary still needs
manual review. Root guidance classifies all 28 paths: nine recorded full reads, five prescribed memory/history
retrieval surfaces, and fourteen pending maintained documents (1,354,206 bytes). Pending root text is
baseline-identical. These draft counts do not imply that their content was read or that their future leaves exist.
#### Preceding canonical completion
The unchanged staged candidate for `.3.2.21` completed canonical CI with exit 0 at 2026-09-06 13:58:18 UTC.
The receipt binds base `ba9a494caa79fdd6fca7833d5bfc1fbce727fc9d` and candidate SHA-256
`d3dd218a7cbce4742b9bb857f67a54bdaba85ef6c01510ffeb9f1725e83064af`.
Mandatory checks passed, including both 66/66 CLI environments, Phase 0 1,032 tests, and the complete six-family
process-locality oracle. Optional environment-selected matrices were unset and skipped normally; no broader
optional-coverage claim follows. The commit hooks passed all nine doctrines, the post-commit activation pointer
passed, and the receipt was promoted to `17d3e919118430d4fad0e31d6c1a4a8e2d9dc333`. The brief was cleared to
zero bytes and Git was clean before activating `.31`; no background job remains.
