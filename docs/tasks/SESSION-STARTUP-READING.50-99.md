# SESSION-STARTUP-READING: semantic part 50-99

Current task evidence; navigation and frontier: docs/tasks/SESSION-STARTUP-READING.md.
After an owned edit run: perl tools/update_task_tree_index.pl --tree SESSION-STARTUP-READING

- ID: `SESSION-STARTUP-READING.50`
  Status: `done`
  Goal: Preserve adjacent colon separators after dynamic bare Rust hash keys.
  Dependencies: `.3`/`.4`/`.5`; coordinate malformed-block propagation with `.45`.
  Activation: Clean aa057b107c37fb947950d6c57db1892338fe7e94; canonical .86 parent committed, receipt promoted, brief empty and no pending job. ADR0123 permits scoped repair after targeted reading.
  Verification tier: `focused`
  Focused checks: Public Rust CLI plus Perl Get/call_spec_handler_subst RED/GREEN; both Rust block parser modes, exact AST/scalar spans, full core tests, affected runtime integration and native/reconstructed/generated/emitted carriers; book examples/render, Knowledge/history/memory and all doctrines.
  Canonical trigger: Final clean push boundary; this leaf repairs the existing colon-key contract without changing a neutral contract or generated format.
  Director continuity (September24): Remote main is reverified at a8d34c845; all three SEMULITH reports have published remedies (LS-002 uses the opt-in document entry). The director will notify ARCHOGEN only after LS-004 is verified fixed. No external message or new push is authorized by this status discussion.
  Probe boundary: Exclude set(clé,...) from portable success evidence: uniform_binding_contract.json fixes binding names to ASCII identifiers. Raw Perl lowering retains that unsupported call and runtime_ctx_ref attributes its failure; exact output is retained in .linkedspec-data/scratch/hash-colon50/perl-unsupported-name.stdout. Unicode key values use supported ASCII bindings, quoted keys and computed expressions instead; no identifier expansion is admitted.
  Verification: Core RED4 becomes full core GREEN258; selected runtime226 (source2, hash-key1 covering13x2, integration197, punctuation5, symbol5, binding16), keyword-policy1 and emitted-book1 pass. The final compact/emitted2 rerun passes after unnecessary-mut cleanup, with no first-party warning. Perl shared book26 and public13 exact RED/GREEN pairs pass, including a final replay after Cargo refreshed the CLI to a2058123. Book render/exact source-result extraction, neutral cursor/binding, formatting and task metadata pass. Checkpoints .50-hash-separator.json and .50-verification.json retain exact sources, both correct post-fix binaries, commands, source/log hashes and proof scope. Normal memory/Knowledge/history/doctrine checks govern landing.
  Acceptance: Distinguish the single hash-pair colon from supported identifier/namespace syntax without
    requiring whitespace before the separator. Preserve evaluated dynamic keys and literal quoted keys;
    cover spaced/compact, parenthesized/computed, nested and Unicode key expressions, namespace and keyword
    negative controls, and exact AST/source spans. Verify parser/native and supported reconstructed/generated
    routes, with independent Perl lowering/portable authority. Add recurrence and accurate book examples.
    Coordinate .45 so invalid source rejects while these valid key forms retain their initializer.
  Historical verification (September7): six asserted managed Rust CLI/Perl Toolbox lowering controls show
    spaced and left-space bare keys, compact quoted keys, and compact two-argument computed keys returning
    {"a":7} on Rust. Bare key:7 and key: 7 instead return null with expected-colon warnings at positions
    23/24, despite compile:ok/invoke:ok. Perl lowers all six without an unsupported marker. parse_name
    consumes the colon as an identifier character before parse_hash_literal expects its separator.
  Commit: `SESSION-STARTUP-READING.50 - preserve compact hash-key separators`
  - [x] **REPRODUCE / ISSUE** — Public Rust trace rejects five of13 unchanged sources before repair; Perl Get/call_spec_handler_subst accepts all13 with correct values and no context error.
  - [x] **ROOT CAUSE (WHY + WHERE)** — parse_name consumed the isolated separator; both parser modes and exact namespace/keyword/retired-syntax controls delimit the fix.
  - [x] **FIX** — Stop at isolated colons while retaining namespace-style colon runs and evaluated-key semantics.
  - [x] **ADDRESSED (verified)** — Exact AST/source/scalar spans, native/reconstructed/generated13x2 and independently emitted shared book values pass; initial and final public binaries agree.
  - [x] **NO REGRESSION** — Full core258, selected runtime226, keyword policy and neutral cursor/binding checks pass. No Perl production change; reference book26 passes and activation retains canonical Phase0 1033.
  - [x] **LOCKSTEP** — One included book source is consumed by Perl/Rust tests; current Knowledge/roadmap/live pointers reflect .50 completion, immediate .88 and subsequent containment .16 before .51.
- ID: `SESSION-STARTUP-READING.51`
  Status: `pending`
  Goal: Reconcile and repair Rust cat minimum-arity divergence against the supported helper contract.
  Dependencies: `.3`/`.4`/`.5`; coordinate public cat teaching with `.28.5`.
  Acceptance: Establish the portable minimum-arity and invalid-call result/diagnostic boundary from current
    authority, then align Rust without silently widening the public helper. Cover zero, one, two and
    variadic scalar arguments, null/aggregate failures, evaluated-argument effects and helper-name shadowing;
    verify native and supported reconstructed/generated/emitted routes plus public recurrence. Preserve
    accepted two-or-more concatenation behavior and existing source provenance. Split implementation and
    cross-backend admission if needed; ask only if normative authority remains ambiguous after reconciliation.
  Verification: `pending` repair — a constant control and two-argument cat both return their expected
    text through Rust primary CLI and Perl public Get on an explicit action-edge spec. cat("a") returns
    "a" on Rust and null on Perl, with no exceptions, recorded last_error, or stderr. Perl lowering requires
    at least two arguments (MethodLowering.pm 5330–5332); Rust engine.rs 8213–8222 concatenates converted
    arguments without an arity guard. The public helper table spells cat(value, value, ...). Earlier no-edge
    E probes returned zero for both Perl cases and are excluded as arity evidence under known .27 debt.
  Commit: `pending`
- ID: `SESSION-STARTUP-READING.52`
  Status: `pending`
  Goal: Preserve compact Rust fluent argument whitespace and literal delimiters.
  Dependencies: `.3`/`.4`/`.5`; coordinate standalone teaching with `.41.6`.
  Children: `.52.1`, `.52.2`
  Acceptance: Repair both independently confirmed lexical boundaries without changing helper semantics or
    widening accepted calls. Reconcile supported lifecycle/edge/continuation carriers and public examples.
- ID: `SESSION-STARTUP-READING.52.1`
  Status: `pending`
  Goal: Accept horizontal whitespace before compact Rust fluent argument parentheses.
  Acceptance: Preserve arguments for I.return ("ok") and the tab twin, retaining no-space and braced controls.
    Reconcile scanner/completeness behavior for lifecycle, action, blind, bare and continuation routes;
    preserve named arguments, missing-parenthesis errors, source provenance and typed diagnostics.
    Run native and supported reconstructed/generated controls, update teaching and recurrence.
  Verification: `pending` repair — paired primary Rust CLI/Perl Get controls return "ok" for compact no-space
    and braced-space calls; Rust rejects compact space/tab while Perl returns "ok". The fluent scanner checks
    starts_with('(') before skipping whitespace; I raw-suffix validation then rejects its leftover arguments.
  Commit: `pending`
- ID: `SESSION-STARTUP-READING.52.2`
  Status: `pending`
  Goal: Keep quoted and regex parentheses out of compact fluent argument depth.
  Acceptance: Replace delimiter-only extraction with the established lexical argument boundary rules.
    Lock I.return(")") against the braced twin, then quotes, escaped quotes, regex delimiters, nested calls,
    multiline calls, attached conditions and malformed endings across every actual caller. Preserve exact
    source/diagnostics and valid helper behavior; verify native/generated carriers and public recurrence.
  Verification: `pending` repair — compact I.return(")") fails Rust compilation while its braced twin returns
    ")" on both Rust and Perl; Perl accepts the compact form. extract_paren_content_with_end counts every
    parenthesis without quote/regex state, unlike the separate completeness scanner.
  Additional evidence: Julia .1.31 confirms quoted closing-parenthesis truncation and opening-parenthesis empty-call substitution. JULIA-STARTUP-READING.2.20.1/.2 owns its distinct implementation and supported-route proof; exact controls are in docs/knowledge/julia-spec-lexical-boundary-defects.md.
  Commit: `pending`
- ID: `SESSION-STARTUP-READING.53`
  Status: `pending`
  Goal: Preserve unsupported Rust header-rest suffixes for the same validation as body-line twins.
  Dependencies: `.3`/`.4`/`.5`; coordinate malformed-block propagation with `.45` and public examples with `.41.6`.
  Acceptance: Lock Top:: I { return("ok") } @unexpected against the body-line twin and valid compact/multiline
    controls. Preserve unconsumed invalid text instead of discarding it in parse_inline_body; reconcile
    intentional legacy Raw compatibility without silently widening it. Cover explicit/bare I, recognized
    successors, comments, multiline continuation origin and exact diagnostic positions through supported
    parsed/reconstructed/generated routes. Review the neighboring body loop's unreachable advanced &&
    !consumed_line branch, whose consumed_line is assigned true immediately beforehand; retain correct line
    advancement and split mechanical cleanup if needed. Add recurrence and accurate book coverage.
  Verification: `pending` repair — Rust rejects the body-line invalid suffix but compiles/invokes the header
    form successfully with "ok"; Perl rejects both with Unsupported lifecycle block remainder. Inline parsing
    breaks on None without Raw retention; ordinary body parsing retains an I suffix and validation rejects it.
  Commit: `pending`
- ID: `SESSION-STARTUP-READING.54`
  Status: `pending`
  Goal: Preserve regex-literal braces through Perl and Rust rule-block scanners.
  Dependencies: `.3`/`.4`/`.5`; coordinate existing attached-tail `.9`, rule-block `.45`, and `.41.6` teaching.
  Children: `.54.1`, `.54.2`, `.54.3`
  Acceptance: Keep regex delimiters lexical while preserving existing regex-versus-division distinctions,
    quoted text, nesting, source provenance and malformed-source diagnostics. Do not infer other backend
    outcomes from the two measured routes.
- ID: `SESSION-STARTUP-READING.54.1`
  Status: `pending`
  Goal: Repair Perl bootstrap rule-block regex-brace truncation.
  Acceptance: Lock I { return(matches("}", /}/)) } against quoted-pattern and /x/ controls through the
    bootstrap owner and public Get. Reconcile CURLY_BRACE lexical alternatives and all explicit, bare,
    action, blind and nested callers; keep attached-tail .9 distinct until shared behavior is proven.
    Preserve complete payload/source and opening line, slash escapes/classes/quantifiers, and malformed
    diagnostics. Verify emitted source independently and add recurrence/book coverage.
  Verification: `pending` repair — direct run_bootstrap_parse returns ICODE ending at return(matches("}", /
    with source ending inside /}; both controls retain full payloads. Public Get produces a coderef but
    execution returns null with rule_handler_compile for Top/_default. CURLY_BRACE has brace and quoted-string
    alternatives only; NON_ACTION_CODE_BLOCK stops at its first closing-brace match. Control matches values are
    Perl 1 and Rust true, not a newly investigated boolean representation issue.
  Commit: `pending`
- ID: `SESSION-STARTUP-READING.54.2`
  Status: `pending`
  Goal: Repair Rust rule-block collection and validation for regex-literal braces.
  Acceptance: Align scan_line_for_braces_chars and brace_depth_delta with the accepted literal boundary,
    retaining complete source, line origins and malformed balance diagnostics. Lock matches("}", /}/) against
    quoted-pattern and /x/ controls; cover explicit/bare lifecycle and attached edge bodies, nested literals,
    escapes/classes/quantifiers, multiline quote state and supported serialized/generated carriers.
    Preserve source expression semantics and avoid accepting genuinely unbalanced blocks.
  Verification: `pending` repair — Rust primary CLI rejects the regex-brace lifecycle source at compilation
    while quoted-pattern and ordinary-regex controls execute true. The outer collector and balance validator
    track quotes/braces but no regex state. Complete expression parsing is a separate inner boundary.
  Commit: `pending`
- ID: `SESSION-STARTUP-READING.54.3`
  Status: `pending`
  Goal: Close regex-brace public teaching and recurring parity after the concrete scanner repairs.
  Dependencies: `.54.1`, `.54.2`, `DART-STARTUP-READING.2.2`, and Lua .2.24.3/.2.24.4; reconcile `.9` without treating its distinct scanner as already repaired.
  Acceptance: Reverify portable authority and every supported backend/carrier, own any further gaps before
    admitting broader parity, publish worked regex-brace examples and negatives, and run required canonical
    boundary proof. Preserve dated pre-repair controls and exact recurrence ownership.
  Verification: `pending`; Dart reading .1.5 confirms separate grouped-regex action scanning and lifecycle balance failures. DART-STARTUP-READING.2.2.1/.2.2.2 own their fixes; exact public AST/programmatic controls are in docs/knowledge/dart-regex-brace-scanner-defects.md. No other-backend or emitted outcome is inferred.
  Additional evidence: Julia .1.31 confirms outer source closes at a regex brace before ordinary compilation. JULIA-STARTUP-READING.2.21.1/.2 owns outer scanner repair, downstream balance audit and public recurrence. Explicit/shorthand unterminated controls still reject; exact evidence is docs/knowledge/julia-spec-lexical-boundary-defects.md.
  Commit: `pending`
  Additional evidence: Julia .1.32 isolates three compact regex-brace inputs with full retained action source and identical quiet/traced balance rejection. JULIA-STARTUP-READING.2.21.3 owns downstream Validator437-460 repair; existing .2.21.2 now requires it as well as .2.21.1. Exact evidence: docs/knowledge/julia-function-projection-metadata-gaps.md.
  Additional evidence: Lua .1.22 confirms plain/grouped regex outer truncation and a complete compact regex expression rejected by quote-only lifecycle balancing. LUA-STARTUP-READING.2.24.3/.4 own separate parser/validator repairs and .2.24.6 carrier proof. Compact quoted parentheses/spaces succeed; a quoted string passed as matches pattern correctly returns false under Lua's typed-regex contract. Exact evidence: docs/knowledge/lua-spec-parser-validator-reading-and-lexical-gaps.md.
- ID: `SESSION-STARTUP-READING.55`
  Status: `pending`
  Goal: Preserve large finite numeric values and reconcile their portable text spelling.
  Dependencies: `.3`/`.4`/`.5`; coordinate scalar authority `.20`, cat arity `.51` and public teaching `.28.5`.
  Children: `.55.1`, `.55.2`, `.55.3`
  Acceptance: Keep numeric value preservation distinct from number-to-text spelling. Do not silently clamp
    finite values at a host integer boundary or declare portable spelling from a small fixture alone.
- ID: `SESSION-STARTUP-READING.55.1`
  Status: `pending`
  Goal: Remove Rust finite integral-number saturation at JSON and related conversion boundaries.
  Acceptance: Lock direct positive/negative 1e20 output against 42 and independent native value controls.
    Avoid unchecked f64-to-i64 conversion outside its exact supported range; review to_json, to_str, len, Display,
    nested values, helper/key uses and every actual outward/generated consumer before selecting one coherent
    numeric representation. Include runtime_value_from_json and its progressive/typed-record consumers in
    the round-trip inventory; .3.3.28 adds source evidence only, with no new measured conversion failure.
    Include spec_parser.rs usize_field integer/floating branches and their actual definition-AST producers; .3.3.36 inventories this boundary without claiming a reachable new large-field failure. .3.3.38 adds staged_parser_registry.rs source-span/line integer conversion and its public v1 callers to this same audit.
    Preserve finite-number value, existing small integer output, nonfinite policy
    and signed zero. Cover i64-adjacent representable values, fractions and serialization round trips,
    native/generated/primary CLI routes and portable recurrence; do not promise arbitrary-precision integers.
    Include the nested-write classifier's f64-to-usize boundary: compare the first out-of-range power of two
    and adjacent representable values with ordinary dense append/gap controls; reject or preserve their
    identity explicitly instead of silently saturating the diagnostic path/index through a rounded maximum.
  Verification: `pending` repair — Rust CLI returns 9223372036854775807 for 100000000000000000000 and
    -9223372036854775808 for its negative, with compile:ok/invoke:ok and no stderr. Perl public Get preserves
    positive/negative 1e20; both return 42 for the control. Engine direct execution calls RuntimeValue::to_json,
    whose finite integral branch casts to i64 before serde JSON construction.
    `.3.3.17` adds four native diagnostic controls: append at 0 succeeds; index 1 reports an ordinary gap;
    exact f64 value 18446744073709551616 reports a gap at changed index 18446744073709551615; the next
    representable larger value rejects as an invalid selector. The probe exits 0 with empty stderr;
    existing CLI controls expose only generic invocation failure. Exact artifacts and cause are in the numeric Knowledge card.
  Commit: `pending`
- ID: `SESSION-STARTUP-READING.55.2`
  Status: `pending`
  Goal: Reconcile scalar-text scientific/decimal spelling outside the existing small numeric fixture.
  Acceptance: Apply the reference-owned finite-number text contract to positive/negative magnitudes, small
    fractions, exponents, signed zero and shortest stable spelling. Resolve any remaining normative ambiguity
    before changing the frozen authority; then repair actual divergent consumers without widening cat arity
    or changing null/aggregate rejection. Keep numeric JSON value preservation under .55.1 separate.
  Verification: `pending` repair — cat(100000000000000000000,"") returns the full decimal string on Rust and
    "1e+20" on Perl, with successful execution and no errors. The scalar-text fixture says shortest stable
    decimal text but its numeric examples are only -0.0, 1.0 and 1.25; it does not establish this magnitude.
    Current Rust to_scalar_text formats finite f64 directly, while Perl cat lowering stringifies the host value.
    Julia .1.17 adds decimal-literal cat(100000000000000000000.0, "") as full decimal versus Perl scientific text; exact paired controls remain in docs/knowledge/julia-large-number-and-slice-boundaries.md. Julia .2.9 separately owns numeric value preservation.
  Commit: `pending`
- ID: `SESSION-STARTUP-READING.55.3`
  Status: `pending`
  Goal: Close large-number public guidance and recurring parity after value/spelling repairs.
  Dependencies: `.55.1`, `.55.2`.
  Acceptance: Document the actual finite precision/range and canonical text behavior with worked examples;
    verify exact supported backend and reconstructed/generated/emitted routes before renewing broad parity
    claims. Own any additional gaps, retain dated pre-repair evidence, and run canonical closeout proof.
  Verification: `pending`
  Commit: `pending`
- ID: `SESSION-STARTUP-READING.56`
  Status: `pending`
  Goal: Restore complete Rust built-in function-name reservation without accidental helper shadowing.
  Dependencies: prerequisite .3/.4/.5; coordinate current helper authority and callable/typed-source/gap owners.
  Children: `.56.1`, `.56.2`, `.56.3`
  Acceptance: Reference-owned built-in names must not become user-defined functions through a stale copied list.
    Preserve ordinary custom functions and deliberate callable precedence; do not widen names or hide failures.
- ID: `SESSION-STARTUP-READING.56.1`
  Status: `pending`
  Goal: Freeze current callable-name reservation authority and exact missing-name diagnostics.
  Acceptance: Compare the actual Perl registry resolver and current contract owners with Rust's manual list.
    Lock gap_text and entry_slot rejection beside custom_value success and existing trim rejection; audit
    other current helper/control names, numeric aliases, private/public helper distinctions and intentional
    parameter-name rules. Keep namespace reservation separate from helper arity, invocation and method syntax.
    Establish any wider missing-name population with evidence before expanding the repair.
  Verification: `pending` repair — four paired public native controls at clean activation 75ce8db8 prove
    custom_value() returns "sentinel" on both runtimes and trim definitions are rejected by both.
    Rust accepts gap_text/entry_slot definitions and returns "sentinel"; Perl rejects each at function_registry
    with the exact built-in helper/control collision detail. No timeout; completed native subprocesses.
  Commit: `pending`
- ID: `SESSION-STARTUP-READING.56.2`
  Status: `pending`
  Goal: Repair Rust registry validation and prevent recurrence as helper authority evolves.
  Dependencies: .56.1.
  Acceptance: Reject every authority-bound collision before function body/runtime execution on source and
    reconstructed/programmatic definition routes, ordinary/traced validation and supported compilation paths.
    Replace or mechanically govern the stale is_known_actionir_call_name inventory without admitting retired
    names or blocking valid custom functions. Preserve numeric aliases, lifecycle/runtime reservations, arity,
    parameter rules and callable semantics. Verify exact RED/GREEN and direct dependents.
  Verification: `pending` — validation.rs manual helper-name list omits the two observed gap helpers; Engine
    resolves registered functions before ordinary eager-helper fallback, making the admitted name executable.
    Perl UserFunctionRegistry delegates to MethodLowering's current known-value-call resolver.
  Commit: `pending`
- ID: `SESSION-STARTUP-READING.56.3`
  Status: `pending`
  Goal: Close registry-reservation public teaching and recurring supported-route proof.
  Dependencies: .56.2.
  Acceptance: Reverify supported backends and native/reconstructed/generated/emitted routes, own additional
    gaps, update public namespace examples and negative diagnostics, retain dated pre-repair controls,
    and run the canonical public/cross-backend closeout. No broad registry parity claim before recurrence.
  Verification: `pending`
  Commit: `pending`
- ID: `SESSION-STARTUP-READING.57`
  Status: `pending`
  Goal: Reject discarded named and malformed selectors on AND bare edges.
  Dependencies: prerequisite .3/.4/.5; coordinate rule-local cursor and inter-match gap authored-slot authority.
  Children: `.57.1`, `.57.2`, `.57.3`, `.57.4`
  Acceptance: Blind ownership must not silently discard authored selector syntax. Preserve unselected bare
    calls and valid explicit action selectors; keep this defect separate from existing Perl return-path .27.
- ID: `SESSION-STARTUP-READING.57.1`
  Status: `pending`
  Goal: Freeze complete selector-bearing blind-edge rejection across the two composed contracts.
  Acceptance: Lock plain Child success and numeric Child[0] rejection against named Child[word],
    unknown Child[missing] and malformed Child[!] in AND bare syntax. Align exact portable diagnostics,
    authored selector/source evidence and rejection order with ADR 0044 and current named-slot authority.
    Include explicit blind twins, valid action twins, malformed/unclosed/empty selectors and reconstructed
    AST provenance; resolve genuine contract ambiguity before changing the frozen authority.
  Verification: `pending` repair — five paired native controls accept plain/named/unknown/malformed forms
    on Rust and Perl while numeric [0] is rejected by both. Rust returns ["selected"] for each accepted
    form; Perl returns null even for plain Child, so this does not establish a new Perl return-path defect.
    Four Perl descriptor probes erase every accepted selector into the identical blind Child row with
    regex_index null and no resolved_slot_edges.
  Commit: `pending`
- ID: `SESSION-STARTUP-READING.57.2`
  Status: `pending`
  Goal: Repair Rust AND bare selector validation before blind lowering loses the typed selector.
  Dependencies: .57.1.
  Acceptance: Check typed RegexSelector provenance instead of only legacy numeric target.index; retain
    exact numeric diagnostic compatibility and reject other forbidden authored selector states before
    bcode construction. Cover source/programmatic/serde ASTs, ordinary/traced validation and supported
    complete compile routes; preserve plain blind and numeric/named explicit action controls.
  Verification: `pending` — parse_bare_target_list_prefix sets index only for Numeric. The slot metadata
    pass skips AND bare targets, check_edge_structure tests only index.is_some, and compile_rule lowers
    the first target into a blind entry without its typed selector.
  Commit: `pending`
- ID: `SESSION-STARTUP-READING.57.3`
  Status: `pending`
  Goal: Repair Perl bare-edge normalization without losing authored named/malformed selector evidence.
  Dependencies: .57.1.
  Acceptance: Reject every forbidden selector before creating bcode_entries/normalized_edges, using the
    complete retained selector record rather than only numeric index. Lock exact descriptor rejection,
    structured diagnostics and native/source-generated controls; keep unrelated child-return .27 separate.
  Verification: `pending` — RuleIR blind normalization checks defined(index) only, then stores child/code
    and normalized label/index fields without named-selector provenance. Public Get and descriptor
    controls independently confirm acceptance and projection loss for named/unknown/malformed brackets.
  Commit: `pending`
- ID: `SESSION-STARTUP-READING.57.4`
  Status: `pending`
  Goal: Close selector-rejection public teaching and supported backend/carrier recurrence.
  Dependencies: .57.2, .57.3.
  Acceptance: Audit remaining backends, own/fix additional gaps, verify complete supported reconstructed/
    generated/emitted routes, document explicit action selector examples and forbidden blind forms, and
    run canonical public/cross-backend closeout without renewing broader parity from narrow fixtures.
  Verification: `pending`
  Commit: `pending`
- ID: `SESSION-STARTUP-READING.58`
  Status: `pending`
  Goal: Enforce the active receiver-write guard on final value-block assignments in Rust.
  Dependencies: prerequisite .3/.4/.5; coordinate existing mutation and write-vivification authority.
  Children: `.58.1`, `.58.2`, `.58.3`
  Acceptance: Final and nonfinal placement must not alter same-receiver rejection or pre-evaluation ordering.
    Preserve unrelated bindings, scoped callback values, detached results and post-commit continuation.
- ID: `SESSION-STARTUP-READING.58.1`
  Status: `pending`
  Goal: Repair final-assignment guard dispatch through the shared Rust value-block evaluator.
  Acceptance: Reproduce final scalar/nested assignments beside nonfinal and explicit-return twins; require
    receiver_mutation_reentrant before segment/RHS effects, then route final assignments through the same
    guarded evaluation authority without changing their returned values. Audit scalar/append/hash/nested
    assignment branches and callers, including nested value blocks and callable bodies. Prove exact diagnostics,
    receiver rollback, guard release, unrelated effects and legal same-spelling parameter/local controls.
  Verification: `pending` repair — six paired primary Rust CLI/Perl Get fixtures at acbadc0f show Rust succeeds
    for final tree = {} and tree["x"] = value while Perl rejects both with receiver_mutation_reentrant.
    Nonfinal and explicit-return controls reject on both; unrelated final assignment agrees. eval_block_value
    sends the last statement to eval_block_final_expr, whose direct scalar/nested branches bypass eval_expr's
    assert_receiver_write_expr; the nested-write coordinator and set_scalar do not replace that guard.
  Commit: `pending`
- ID: `SESSION-STARTUP-READING.58.2`
  Status: `pending`
  Goal: Close final-write guard coverage across supported carriers and related callback routes.
  Dependencies: .58.1.
  Acceptance: Run the repaired cases through native/serde/generated-plan/emitted/independently compiled Rust;
    verify source spans and expression-effect ordering rather than accepting generic CLI failure as proof.
    Inspect remaining backends with equivalent bounded controls; own and repair additional measured gaps.
    Preserve declared neutral authority and strengthen recurrence without weakening its rejection contract.
  Verification: `pending` — the six-case September probe establishes Rust direct/primary and Perl public scope
    only; other backends and generated carriers require fresh proof at repair time.
  Commit: `pending`
- ID: `SESSION-STARTUP-READING.58.3`
  Status: `pending`
  Goal: Close public guard examples and recurring proof after final-write repairs.
  Dependencies: .58.1, .58.2.
  Acceptance: Teach final/nonfinal receiver rejection and legal detached callback writes with exact examples;
    update all current guard claims, retain dated pre-repair evidence, and run canonical public/cross-backend
    closeout. Do not equate the currently passing neutral mutations with complete runtime path coverage.
  Verification: `pending`
  Commit: `pending`
- ID: `SESSION-STARTUP-READING.59`
  Status: `pending`
  Goal: Restore consistent statement regex substitution and active-receiver protection.
  Dependencies: prerequisite .3/.4/.5; coordinate .58 shared receiver-guard repair.
  Children: `.59.1`, `.59.2`, `.59.3`, `.59.4`
  Acceptance: Preserve documented ordinary substitution, resolve flag-form and callback lowering discrepancies,
    reject active-receiver writes before effects, and retain pure substr slicing. Exact September evidence is
    in regex-substitution-callback-and-flag-discrepancies; no backend is credited with unmeasured coverage.
- ID: `SESSION-STARTUP-READING.59.1`
  Status: `pending`
  Goal: Repair Perl statement substitution across ordinary and callback lowering.
  Acceptance: Reconcile the public scalar-flags signature with bare-token examples and quoted flag controls.
    Route valid substr/regex_subst statements through their mutation owner inside callbacks and ordinary actions;
    preserve aliases, literal patterns/replacements and flag semantics. Do not silently replace supported
    statements with unsupported-helper markers. Guard active targets before operand effects and preserve legal
    unrelated callback writes. Explicitly diagnose rejected forms without leaking host calls.
  Verification: `pending` repair — ten paired CLI/Get probes show ordinary bare-g substitutions agree, but
    Perl quoted regex_subst leaks a host call, quoted substr yields a marker, and both callback spellings yield
    markers even for unrelated scalar targets. Six callback descriptors record one unresolved helper and ready=0.
    MethodLowering block statement dispatch omits this mutation family; Contracts' ordinary matcher accepts
    bare-word flags only. Retained lowered/generated source proves the actual paths.
  Commit: `pending`
- ID: `SESSION-STARTUP-READING.59.2`
  Status: `pending`
  Goal: Guard Rust regex-substitution targets through the shared receiver identity authority.
  Dependencies: .58.1; coordinate .59.1.
  Acceptance: Recognize every admitted target/signature without intercepting pure substr slicing; reject an
    active receiver before evaluating pattern/replacement/flags. Test scalar/hash/array receiver identity,
    unrelated and same-spelling scoped bindings, final/nonfinal placement, rollback, guard release and
    continuation. Avoid a string-name-only guard or a second competing mutation authority.
  Verification: `pending` repair — Rust primary accepts all four active-receiver controls and returns two
    roots with empty-string leaves. receiver_write_attempt omits substr/regex_subst, while call_helper reads
    the private scalar slot, performs replacement, and calls unguarded set_scalar. Unrelated scalar controls
    correctly produce X. Fresh direct structured diagnostics and effect/rollback proofs remain repair work.
  Commit: `pending`
- ID: `SESSION-STARTUP-READING.59.3`
  Status: `pending`
  Goal: Close substitution composition through supported carriers and remaining backends.
  Dependencies: .59.1, .59.2.
  Acceptance: Add independent permanent regressions for exact values, descriptor readiness, diagnostics,
    target spans and pre-evaluation effects; exercise reconstructed/generated/emitted/standalone routes.
    Probe Dart, Julia, PUC Lua and LuaJIT and fix or explicitly task-own every measured discrepancy.
    Keep the existing neutral contract's receiver-identity invariant and strengthen runtime recurrence.
  Verification: `pending` — September evidence covers primary Rust and live Perl plus diagnostic source
    capture only; captured generated source was inspected, not independently executed.
  Commit: `pending`
- ID: `SESSION-STARTUP-READING.59.4`
  Status: `pending`
  Goal: Align substitution and receiver-write public teaching after repaired recurrence.
  Dependencies: .59.1-.59.3.
  Acceptance: Document exact flags and statement/value boundaries, working unrelated callback substitution,
    active-receiver rejection and invalid-form diagnostics with substantial examples. Reconcile all broad
    helper-guard claims; retain dated defect evidence and run rendered-book plus canonical no-drift closeout.
  Verification: `pending`
  Commit: `pending`
- ID: `SESSION-STARTUP-READING.60`
  Status: `pending`
  Goal: Make Rust array slicing obey documented bounds without panics.
  Dependencies: prerequisite .3/.4/.5; coordinate .55 integer-conversion boundaries.
  Children: `.60.1`, `.60.2`, `.60.3`
  Acceptance: Out-of-range starts return empty arrays; large counts cannot overflow host arithmetic.
- ID: `SESSION-STARTUP-READING.60.1`
  Status: `pending`
  Goal: Repair array slice start/count normalization and safe range construction.
  Acceptance: Reproduce valid, exact-end, beyond-end, empty-array, omitted-count and receiver-form controls.
    Normalize or bound start/count before addition/indexing, preserve nonmutation and ordinary values, and
    cover zero/negative/fractional and host-boundary inputs according to the existing public contract.
  Verification: `pending` repair — .3.3.21 finds four small out-of-range forms panic at engine.rs:9776:49;
    valid and exact-end controls agree with Perl, which returns [] for every out-of-range control.
    Rust-only count 18446744073709551616 at start 1 panics in start+n at 9775:31.
  Commit: `pending`
- ID: `SESSION-STARTUP-READING.60.2`
  Status: `pending`
  Goal: Prove slice safety through supported Rust carriers and equivalent backend boundaries.
  Dependencies: .60.1.
  Acceptance: Add independent exact-value regressions for helper and receiver forms, exercise direct,
    serialized/generated/emitted/standalone consumers, and inspect adjacent take/drop slicing arithmetic.
    Probe remaining backends with bounded inputs; fix or task-own every measured discrepancy.
  Verification: `pending` — the original .60 intake measured primary Rust and public Perl; its captured
    diagnostic source alone did not credit large-count Perl execution or structured carriers.
    Julia .1.17 adds native/reconstructed and executed Perl large-count controls: drop_front throws and slice/substr truncate incorrectly in Julia while the paired Perl controls succeed. Julia .2.10 owns repair; exact replay and carrier limitations live in docs/knowledge/julia-large-number-and-slice-boundaries.md.
    Julia .1.18 confirms safe typed clipping at Int maximum but conversion failure for Float64 1e20. Perl falls back to host substr and returns ab for input_slice(1,1e20) on xabc; its drop_front instead treats scientific spelling as invalid and leaves [1,2]. This owner must reconcile accepted count kinds/ranges and repair or explicitly reject unsafe fallback behavior; exact causal replay is in docs/knowledge/julia-input-slice-arity-and-count-boundaries.md. Julia .2.9 owns conversion, .2.11 arity.
    Lua .1.20 repeats six fresh Perl facade/lowering/source controls: integral max-width clips correctly but floating 1e20 still yields ab; both Lua hosts yield abc for that floating case. Lua .2.13.3/.4 separately own PUC typed-slice integer overflow. Preserve this owner for accepted count policy and Perl fallback repair; no reference result is automatically normative. Exact replay: docs/knowledge/lua-emitter-source-location-reading-and-boundary-gaps.md.
  Commit: `pending`
- ID: `SESSION-STARTUP-READING.60.3`
  Status: `pending`
  Goal: Close slice examples and canonical recurrence after bounds repair.
  Dependencies: .60.1, .60.2.
  Acceptance: Teach exact-end/beyond-end/empty/omitted/large-count behavior with helper/receiver examples;
    keep README bounded and synchronize current Knowledge, public book and recurrence with canonical proof.
  Verification: `pending`
  Commit: `pending`
- ID: `SESSION-STARTUP-READING.61`
  Status: `pending`
  Goal: Preserve scalar helper null and empty-input semantics across runtime dispatch.
  Dependencies: prerequisite .3/.4/.5; retain scalar-text/numeric authority boundaries.
  Children: `.61.1`, `.61.2`, `.61.3`
  Acceptance: Scalar transformations must not convert documented undef results to empty text or zero.
- ID: `SESSION-STARTUP-READING.61.1`
  Status: `pending`
  Goal: Repair Rust null propagation for the seven measured scalar transformations.
  Acceptance: Cover length, trim, lowercase, uppercase, replace_substr, rm_prefix and rm_suffix in helper
    and receiver forms; preserve empty-string/zero/false distinctions, Unicode mapping and array cardinality.
    Guard null before text coercion without broad changes to unrelated dynamic conversion semantics.
  Verification: `pending` repair — exact seven-value controls using literal undef and unbound name null
    both return seven nulls on Perl but [0,"","","","","",""] on Rust. Empty-string controls agree.
    engine.rs 9371 onward converts undef through to_str before producing values; the current helper catalog
    explicitly promises undef for these inputs. null is not the authored undefined literal; undef is.
  Commit: `pending`
- ID: `SESSION-STARTUP-READING.61.2`
  Status: `pending`
  Goal: Audit and repair adjacent scalar predicate and empty-pattern boundaries.
  Dependencies: .61.1.
  Acceptance: Compare documented null predicates and empty old/prefix/suffix behavior against public Perl,
    retaining exact boolean/numeric result kinds and failure/argument policies. Own bounded corrections
    before implementation; do not bless all values merely because a host string conversion accepts them.
  Verification: `pending` repair — literal-undef and unbound-name twins return ["XaXbX",1,1,1,true] on Rust
    versus ["ab",0,0,0,0] on Perl for empty-old replace_substr plus starts_with, ends_with, contains_substr
    and matches against empty boundaries. Generated Perl retains defined guards and the empty-needle branch;
    Rust coerces undef to empty text and delegates empty-old replacement directly to str::replace.
  Commit: `pending`
- ID: `SESSION-STARTUP-READING.61.3`
  Status: `pending`
  Goal: Close scalar-helper carrier recurrence and public no-drift.
  Dependencies: .61.1, .61.2.
  Acceptance: Prove repaired semantics through supported serialized/generated/emitted consumers and bounded
    remaining-backend probes; add independently justified permanent cases and accurate null/empty examples.
    Retain dated evidence, own additional measured gaps, and run rendered-book and canonical closeout.
  Verification: `pending`
  Commit: `pending`
- ID: `SESSION-STARTUP-READING.62`
  Status: `pending`
  Goal: Restore coalesce defined-value selection and short-circuit evaluation.
  Dependencies: prerequisite .3/.4/.5; coordinate scalar value and callable/receiver authorities.
  Children: `.62.1`, `.62.2`, `.62.3`, `.62.4`
  Acceptance: A selected defined value prevents later operand effects; preserve zero/false/empty distinctions.
- ID: `SESSION-STARTUP-READING.62.1`
  Status: `pending`
  Goal: Repair Rust coalesce definedness and lazy operand dispatch.
  Acceptance: Preserve defined empty strings, evaluate operands once left-to-right until selection, and skip
    later writes/errors. Cover undef fallthrough, all-undef, zero/false, selected values and nested calls.
    Reconcile aggregate acceptance explicitly against reference behavior and the public scalar signature;
    do not silently widen that signature or conflate coalesce with coalesce_nonempty.
  Verification: `pending` repair — .3.3.22 probes show Rust replaces defined empty text with fallback and
    executes a later audit assignment after either the first or fallback operand is selected. Perl returns
    the empty string and skips those writes. Rust's lazy-call selector omits coalesce; the helper also tests
    nonempty text. Perl emits nested defined-value ternaries. Existing short_circuits test checks value only.
  Commit: `pending`
- ID: `SESSION-STARTUP-READING.62.2`
  Status: `pending`
  Goal: Reconcile coalesce_nonempty and receiver/value-block dispatch with the reference.
  Dependencies: .62.1.
  Acceptance: Probe and repair later-operand effects for coalesce_nonempty and documented receiver forms;
    distinguish empty-string skipping from truthiness and aggregate coercion. Preserve callback binding
    identity, ordinary helpers, scalar flags and exact argument diagnostics through every admitted route.
  Verification: `pending` repair — two fresh coalesce_nonempty pairs also show Rust executes the late
    audit assignment after first/fallback selection; Perl preserves unset/selected respectively. Both use
    eager Rust operand collection versus nested Perl conditionals. Receiver/value-block proof remains open.
  Commit: `pending`
- ID: `SESSION-STARTUP-READING.62.3`
  Status: `pending`
  Goal: Add permanent default-selection and effect-order recurrence across supported carriers.
  Dependencies: .62.1, .62.2.
  Acceptance: Independently assert selected values, exact effect counts/order and skipped failures in
    native/reconstructed/generated/emitted/standalone consumers; probe remaining backends and repair or
    task-own every measured gap. Preserve typed booleans in diagnostic collectors.
  Verification: `pending` — current primary Rust/live Perl observations and inspected generated source
    do not establish independently executed generated or other-backend behavior.
  Commit: `pending`
- ID: `SESSION-STARTUP-READING.62.4`
  Status: `pending`
  Goal: Close coalesce public examples and canonical no-drift after recurrence.
  Dependencies: .62.1-.62.3.
  Acceptance: Teach defined versus nonempty selection, skipped operand effects, zero/false and argument
    boundaries with accurate helper/receiver examples; reconcile claims and run rendered canonical closeout.
  Verification: `pending`
  Commit: `pending`
- ID: `SESSION-STARTUP-READING.63`
  Status: `pending`
  Goal: Preserve whole-input regex context when matching from a nonzero cursor.
  Dependencies: prerequisite .3/.4/.5; coordinate slot identity, typed source and regex contract owners.
  Children: `.63.1`, `.63.2`, `.63.3`, `.63.4`
  Acceptance: Advancing the cursor must not redefine input-start, line/word boundary or preceding context.
- ID: `SESSION-STARTUP-READING.63.1`
  Status: `pending`
  Goal: Repair Rust combined seek matching without discarding preceding input.
  Acceptance: Match from the current offset against whole input; preserve earliest-start/first-authored
    choice, absolute captures/spans and named group projection. Cover ^, \A, multiline starts, \b/\B,
    positive/negative fixed lookbehind, plain controls, Unicode prefixes and cursor-at-end boundaries.
  Verification: `pending` repair — .3.3.23 six paired collected-rule probes on xhello show five assertion
    discrepancies and plain agreement. helpers.rs seek_match slices input[pos..] before matching;
    Perl LinkedRE matches the original scalar at pos. Exact evidence belongs to the regex-context card.
  Required regression: docs/checkpoints/SESSION-STARTUP-READING.63-lifecycle-cli.json preserves .86.5.3's same-line final-E self-hosted AST failure. Current and clean4ca4f745e grammar both add source_form=explicit on Rust because lifecycle_block_line wins at a suffix boundary. Slot metadata repair leaves this independent defect unchanged; .63.1 must restore the expected physical-line projection.
  Commit: `pending`
- ID: `SESSION-STARTUP-READING.63.2`
  Status: `pending`
  Goal: Reconcile consume and required-slot matching with the same context authority.
  Dependencies: .63.1.
  Acceptance: Apply the corrected offset mechanism consistently to consume_match, seek_slot_match and
    consume_slot_match. Preserve required authored slot identity, duplicate patterns and zero-width
    progress policy; validate low-level cursor bounds without conflating them with normal DSL inputs.
  Verification: `pending` — source shows the same input suffix slicing in consume_match and match_slot;
    the current six behavioral controls exercise ordinary choice seek only. Fresh route proof is required.
  Commit: `pending`
- ID: `SESSION-STARTUP-READING.63.3`
  Status: `pending`
  Goal: Add exact nonzero-cursor assertion recurrence across supported regex carriers and backends.
  Dependencies: .63.1, .63.2.
  Acceptance: Independently assert selected rule sequences and absolute match/capture spans in native,
    reconstructed/generated/emitted/standalone execution; cover other backends and task-own measured
    differences. Prevent suffix-copy regressions and retain valid unanchored/duplicate-slot controls.
  Verification: `pending` — current primary Rust/live Perl results and source inspection are bounded;
    no native/generated independent execution or other-backend signoff is inferred.
  Commit: `pending`
- ID: `SESSION-STARTUP-READING.63.4`
  Status: `pending`
  Goal: Close regex-context public examples and canonical parity after recurrence.
  Dependencies: .63.1-.63.3.
  Acceptance: Explain cursor versus input boundaries and fixed lookbehind with collected examples;
    reconcile regex/current backend claims, render the book, and pass exact canonical closure.
  Verification: `pending`
  Commit: `pending`
- ID: `SESSION-STARTUP-READING.64`
  Status: `pending`
  Goal: Reconcile Rust MCP caught-panic response and process-output guarantees.
  Dependencies: prerequisite .3/.4/.5; coordinate ADR 0055/0058 and native embedding owners.
  Children: `.64.1`, `.64.2`, `.64.3`, `.64.4`
- ID: `SESSION-STARTUP-READING.64.1`
  Status: `pending`
  Goal: Establish library, host panic-hook and output ownership for caught native failures.
  Acceptance: Audit registration, decoded/prepared response and wire catch boundaries; distinguish
    synthetic injection from reachable native failures and response bytes from process stderr.
    Resolve existing embedding/host obligations without silently rewriting the accepted logging contract.
  Verification: `pending` repair — .3.3.25 exact existing panic test passes 1/1 with --nocapture,
    while captured stderr prints its synthetic message and source location; no external reachability claimed.
    .3.3.26 completes the wire source: its catch surrounds dispatch after decoding; Read/Write calls
    are outside it. Ordinary I/O errors and injected panics require distinct proof boundaries.
  Commit: `pending`
- ID: `SESSION-STARTUP-READING.64.2`
  Status: `pending`
  Goal: Repair the owned caught-panic output boundary without changing host-global policy implicitly.
  Dependencies: .64.1.
  Acceptance: Decompose the justified mechanism before implementation; preserve fixed responses,
    silent default/explicit sanitized logging, host hooks, concurrent callers, unwind and shutdown cleanup.
    Do not install or replace a process-global panic hook merely to make the current unit assertion pass.
  Verification: `pending`
  Commit: `pending`
- ID: `SESSION-STARTUP-READING.64.3`
  Status: `pending`
  Goal: Add isolated-process recurrence that independently checks responses and both output streams.
  Dependencies: .64.2.
  Acceptance: Cover synthetic caught failures at each owned boundary, default/explicit logging,
    existing host hooks, repeated/concurrent calls and unaffected success controls. Assert absence of
    raw fixture text/source locations separately from fixed response values; retain abort exclusions.
  Verification: `pending`
  Commit: `pending`
- ID: `SESSION-STARTUP-READING.64.4`
  Status: `pending`
  Goal: Close Rust MCP panic/logging claims with public examples and canonical proof.
  Dependencies: .64.1-.64.3.
  Acceptance: Reconcile ADR 0055/0058, public book, Knowledge and recurring ownership; explain
    host/library boundaries accurately, render the book and pass exact canonical closure.
  Verification: `pending`
  Commit: `pending`
- ID: `SESSION-STARTUP-READING.65`
  Status: `pending`
  Goal: Enforce the MCP payload-byte ceiling equally at EOF, LF and CRLF boundaries.
  Dependencies: prerequisite .3/.4/.5; preserve the current neutral request-limit authority.
  Children: `.65.1`, `.65.2`, `.65.3`
- ID: `SESSION-STARTUP-READING.65.1`
  Status: `pending`
  Goal: Repair Rust final-EOF payload validation before decoding or dispatch.
  Acceptance: Reject every payload above 1,048,576 bytes irrespective of delimiter; preserve exact
    maximum LF/CRLF/EOF acceptance, bounded CR allowance, final frame semantics and fixed parse error.
    Use independently valid padded JSON controls so malformed content cannot mask a missing size check.
  Verification: `pending` repair — .3.3.26 twelve public Rust/Perl controls isolate EOF at maximum+1:
    Rust returns discovery success, Perl -32700. All other eleven pairs agree. Rust EOF sends its
    retained maximum+1 buffer directly to a decoder without the Perl decoder's independent length check.
  Commit: `pending`
- ID: `SESSION-STARTUP-READING.65.2`
  Status: `pending`
  Goal: Add exact delimiter/length recurrence and census other MCP runtime boundaries.
  Dependencies: .65.1.
  Acceptance: Cover maximum-1/maximum/maximum+1/maximum+2, EOF/LF/CRLF, lone CR, chunk-split CRLF,
    valid padded UTF-8 frames, overlong draining followed by valid frames and shutdown/log discipline.
    Independently measure all six runtimes and task-own any further discrepancy; preserve current limits.
  Verification: `pending` — six existing Rust wire unit tests pass while the exact public EOF
    maximum+1 control differs; ordinary EOF and maximum CRLF controls alone do not prove their combination.
  Commit: `pending`
- ID: `SESSION-STARTUP-READING.65.3`
  Status: `pending`
  Goal: Close MCP size-boundary public teaching and recurring canonical evidence.
  Dependencies: .65.1-.65.2.
  Acceptance: Reconcile decision/book/Knowledge and neutral/native proof without changing the ceiling
    to match a defect; render the book and run required exact canonical closure.
  Verification: `pending`
  Commit: `pending`
- ID: `SESSION-STARTUP-READING.66`
  Status: `pending`
  Goal: Preserve unique Rust semantic binding occurrences and their exact source references.
  Dependencies: prerequisite .3/.4/.5; coordinate .22 without silently adapting frozen expectations.
  Children: `.66.1`, `.66.2`, `.66.3`
- ID: `SESSION-STARTUP-READING.66.1`
  Status: `pending`
  Goal: Repair repeated binding occurrence allocation and source-reference identity.
  Acceptance: Preserve each same-owner/name assignment as a distinct ordered binding and retain its
    exact source span/excerpt; keep latest-binding resolution separate from occurrence counting.
    Lock one/two/three/four writes, interleaved names, different owners and function/edge scopes with
    independent native expectations. Preserve the no-function gate's separate .22 repair boundary.
  Verification: `pending` repair — .3.3.30 six paired public Rust/Perl queries prove suffixes
    0/1/1/1 versus 0/1/2/3 for four same-name writes. Rust source references for suffix 1 all show the
    final RHS. Counting keys in a latest-binding map saturates at one; repeated source-ref keys overwrite.
  Commit: `pending`
- ID: `SESSION-STARTUP-READING.66.2`
  Status: `pending`
  Goal: Prove semantic query identity, source correlation and recurrence for repeated writes.
  Dependencies: .66.1.
  Acceptance: Check unique IDs, per-occurrence order/excerpts, latest reads and every write relation;
    exercise list/get/page-after/explanation at applicable source ceilings and immutable clone boundaries.
    Add meaningful native recurrence beyond the one-write frozen fixture; inventory shared model/digest
    impact before changing it. Census supported other backends and task-own any discrepancy.
  Verification: `pending` — frozen semantic 6/20/128 and 9/0 rollout, 6/0 admission remain green
    despite the new native duplicate-ID cases. Paging/get/relations are not yet measured here.
  Commit: `pending`
- ID: `SESSION-STARTUP-READING.66.3`
  Status: `pending`
  Goal: Close supported semantic carriers, MCP projection and public binding-identity teaching.
  Dependencies: .66.1-.66.2.
  Acceptance: Cover supported native/reconstruction/generated/MCP consumers, update book/Knowledge
    with exact source and occurrence examples, render and complete required canonical closeout.
  Verification: `pending`
  Commit: `pending`
- ID: `SESSION-STARTUP-READING.67`
  Status: `pending`
  Goal: Make semantic call evidence truthful and preserve calls/source through composite expressions.
  Dependencies: prerequisite .3/.4/.5; coordinate .22 and .66 without merging their distinct causes.
  Children: `.67.1`, `.67.2`, `.67.3`, `.67.4`
- ID: `SESSION-STARTUP-READING.67.1`
  Status: `pending`
  Goal: Derive signature-acceptance evidence from actual compiled callable compatibility.
  Acceptance: Retain the declared signature and supplied argument facts; emit acceptance only when
    justified. Cover zero/exact/excess arguments, fixed/rest/final-codeblock/keyword boundaries and
    unavailable static facts with an honest outcome. Audit model/code/digest impact before changing
    exact expected evidence; preserve target non-execution and unchanged callable runtime semantics.
  Verification: `pending` repair — .3.3.31 paired Rust/Perl queries emit call_signature_accepts for
    zero/two supplied arguments while the same function record requires exactly one. The builders
    unconditionally format acceptance from parameter names/count, independently of compatibility.
  Dart .1.30 control: zero/two arguments fail semantic construction at unresolved typed contracts and separately fail runtime arity checks; exact one argument succeeds. These controls do not reproduce the Perl/Rust false-acceptance response.
  Commit: `pending`
- ID: `SESSION-STARTUP-READING.67.2`
  Status: `pending`
  Goal: Preserve nested call traversal and binding source evidence through supported expression containers.
  Acceptance: Visit typed children in authored preorder for array and other supported composite nodes;
    preserve exact per-call source and binding RHS source independently of whether the RHS is a call.
    Keep dynamic/unsupported call resolution honest; census edge/function/lifecycle ownership and nested
    arguments, chains, conditionals and mixed source shapes. Split before editing if this exceeds a safe slice.
  Verification: `pending` repair — .3.3.31 direct trim and nested trim calls are projected on both
    backends, but [trim(" x ")] loses its active trim call; Perl Get returns ["x"]. Rust also returns null
    binding source where Perl retains the exact array RHS. Both walkers stop on non-call container nodes.
  Dart .1.30 recurrence: public query also omits trim inside [trim(" x ")] and returns null binding source, while typed ActionIR contains the call and direct runtime returns ["x"]. Direct/nested/string controls retain exact source; separate regex-decoy miscorrelation is owned by DART-STARTUP-READING.2.20.
  Julia .1.26 recurrence: public query retains trim inside [trim(" x ")] and separate runtime returns ["x"], but the binding source is null. Preserve binding RHS source independently of outer emitted calls. Exact92-assertion controls in docs/knowledge/julia-semantic-regex-call-source-gap.md do not reproduce wrong-arity acceptance or repeated-binding identity; distinct regex miscorrelation belongs to Julia .2.15.
  Commit: `pending`
  Lua .1.19 recurrence: Public raw queries retain trim inside [trim(" x ")] and runtime returns ["x"], but the binding source is null; literal RHS 1 also has null binding source. The direct trim binding retains its exact RHS. call_emit_statement derives source only from an emitted outer call, while container/literal traversal returns no outer call. Own Lua RHS source independently of child-call emission; wrong regex source stays Lua .2.17-owned.
- ID: `SESSION-STARTUP-READING.67.3`
  Status: `pending`
  Goal: Lock independent call-evidence recurrence and census supported backends/carriers.
  Dependencies: .67.1-.67.2.
  Acceptance: Cross-check signatures/call facts against independent compile/runtime authorities;
    require unique source-correlated call IDs, correct graph/evidence direction and unchanged source
    ceilings. Census all six runtime variants and supported reconstructed/generated/MCP routes; own
    every discrepancy and review any frozen-model/version impact before updating expectations.
  Verification: `pending` — neutral 6/20/128, rollout9/0/admission6/0 pass despite the paired cases.
  Dart .1.30 census: nine public-query/typed-runtime controls add the container recurrence with seven valid/arity-rejection controls. Four same-name assignments retain suffixes 0,1,2,3 and distinct sources, so the Rust .66 identity failure is not reproduced on this Dart route. Other backends/carriers/MCP remain scoped acceptance work.
  Commit: `pending`
- ID: `SESSION-STARTUP-READING.67.4`
  Status: `pending`
  Goal: Close public semantic call teaching and canonical evidence after the corrected projections.
  Dependencies: .67.1-.67.3.
  Acceptance: Reconcile ADR/book/Knowledge with accurate signature and composite-call examples, render
    and pass required exact canonical proof; retain earlier fixture counts as dated scoped evidence.
  Verification: `pending`
  Commit: `pending`
- ID: `SESSION-STARTUP-READING.68`
  Status: `pending`
  Goal: Reject forbidden authored recognition-token uses through the real Rust execution pipeline.
  Dependencies: .3/.4/.5; coordinate .23 and .45 without conflating their separate failure mechanisms.
  Children: `.68.1`, `.68.2`, `.68.3`
- ID: `SESSION-STARTUP-READING.68.1`
  Status: `pending`
  Goal: Preserve token binding identity and enforce actual authored use restrictions.
  Acceptance: Reject copy/return and every contract-forbidden token use with truthful portable fields,
    including active and consumed token cases, while legal recognize/commit/rollback/value returns work.
    Cover assignments, containers, comparisons, functions/codeblocks and serialization without exposing
    opaque tokens or converting their uses to ordinary undefined values; preserve source and rule scope.
  Verification: `pending` repair — .3.3.32 Rust public query/CLI accept return(tx) and active copied=tx;
    CLI returns null without stderr; Perl Get rejects recognition_token_escape. Legal return("ok") agrees.
    Rust stores an Undef scalar beside the private token; ordinary reads never invoke reject_escape.
  Commit: `pending`
- ID: `SESSION-STARTUP-READING.68.2`
  Status: `pending`
  Goal: Prove token-use rejection through authored carriers, not only private authority calls.
  Acceptance: Add independent source-level negative/positive recurrence across native, reconstructed,
    generated-plan and emitted routes; census all six runtime variants and semantic/MCP construction.
    Preserve compile/runtime failure ownership and unchanged linearity, restoration and effect contracts.
  Verification: `pending` — existing Rust negative-token test directly calls the private rejection helper.
  Commit: `pending`
- ID: `SESSION-STARTUP-READING.68.3`
  Status: `pending`
  Goal: Reconcile public token teaching, admission evidence and canonical proof after integration repair.
  Dependencies: .68.1-.68.2.
  Acceptance: Update book/Knowledge with accurate forbidden-use examples and run exact canonical proof.
  Verification: `pending`
  Commit: `pending`
- ID: `SESSION-STARTUP-READING.69`
  Status: `pending`
  Goal: Preserve newline statement boundaries after Rust bare-variable expression lookahead.
  Dependencies: .3/.4/.5; .45 owns warning/drop, .49 owns the distinct regex suffix scanner.
  Acceptance: Lock non-token assignment/read controls; preserve newline/CRLF/semicolon/space/comment
    boundaries while recognizing calls, indexes and fluent continuations with exact source spans.
    Cover native and supported reconstructed/generated routes; synchronize book and recurrence.
  Verification: `pending` repair — .3.3.32 copied=tx newline control warns at byte84 and drops its I block;
    its semicolon twin has no warning. parse_var_or_call consumes whitespace before checking suffixes
    and does not restore it on the plain-variable path. No intended-body execution is inferred from null.
  Commit: `pending`
- ID: `SESSION-STARTUP-READING.70`
  Status: `pending`
  Goal: Preserve complete grouped-edge parsing and exact semantic selector/source correlation.
  Dependencies: .3/.4/.5; coordinate .22/.53/.67 without merging their distinct mechanisms.
  Children: `.70.1`, `.70.2`, `.70.3`

- ID: `SESSION-STARTUP-READING.70.1`
  Status: `pending`
  Goal: Correlate each expanded grouped edge by target identity and authored occurrence.
  Acceptance: Preserve exact resolved selector, shared-block source/span and relation evidence for every
    expanded target. Cover prefix/substring labels, repeated labels, shared selectors, direct/indexed/bare
    groups and separate-member controls; avoid substring or flattened-index joins to physical members.
  Verification: `pending` repair — .3.3.33 paired query controls lose Child[1] evidence after ChildLong;
    Perl's second group edge also loses its source. Three paired Get/CLI controls still return b correctly.
  Dart .1.33: Both ChildLong | Child[1] and Other | Child[1] compile as two shared-selector index-1 edges and execute b, but public semantic index construction throws semantic_static_correlation_failed. The helper expects a bracket immediately after each target and loses the first target selector even without prefix overlap. Separate indexed members succeed. Existing grouped repair owns this Dart recurrence; regex-arrow variants are separately Dart .2.22.
  Commit: `pending`
  Lua .1.18: Both installed hosts compile ChildLong | Child[1] and Other | Child[1] into two index-1 edges and execute b, but semantic construction fails the action-edge identity guard. explicit_target_index scans label occurrences for an adjacent bracket and cannot recover the first target's inherited shared selector. Separate indexed members and the tested regex-arrow control succeed. Preserve this exact Lua cause under the existing shared repair.

- ID: `SESSION-STARTUP-READING.70.2`
  Status: `pending`
  Goal: Consume the complete accepted explicit grouped-selector syntax or reject its unsupported remainder.
  Acceptance: Reconcile authoritative grammar and existing Perl/Rust forms before selecting a correction;
    preserve complete targets and their shared block, retain exact unsupported-tail diagnostics and source,
    and keep legacy Raw compatibility bounded. Cover header/body, grouped/bare and per-target/shared
    selector controls without silently adopting new syntax or accepting only the first target.
  Verification: `pending` repair — .3.3.33 per-target-index controls yield one blockless Rust edge versus
    two Perl edges. Rust scans a final group selector only, then drops the unrecognized action remainder.
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.70.3`
  Status: `pending`
  Goal: Close grouped-edge semantic recurrence and public evidence across supported carriers.
  Dependencies: .70.1-.70.2.
  Acceptance: Independently compare parsed/compiled/runtime selectors, exact graph IDs/source/relations
    and observation topology; census all six runtimes and reconstructed/generated/MCP routes. Own every
    discrepancy, split implementation leaves where needed, update book/Knowledge and run canonical proof.
  Verification: `pending` — current neutral fixtures pass despite these additional grouped controls.
  Dart .1.33 recurrence: Preserve eight public native compiled/index/runtime controls: two grouped failures, two regex-arrow failures under Dart .2.22, and four successful controls. All eight execute expected inputs; do not infer emitted, reconstructed, other-backend or MCP reproduction from this checkpoint.
  Commit: `pending`
  Lua .1.18 recurrence: Retain both complete grouped construction failures, successful separate-member and regex-arrow controls, typed compiled selectors and independent runtime values on both installed hosts. Further supported-PUC, reconstructed/generated, observation and MCP census remains pending; existing .2.2 owns primary identity.

- ID: `SESSION-STARTUP-READING.71`
  Status: `pending`
  Goal: Emit Rust-correct string literals that preserve every accepted source identity.
  Dependencies: .3/.4/.5.
  Acceptance: Replace JSON-as-Rust escaping at the typed literal boundary; cover every helper caller, quote/backslash/LF/TAB/Unicode/NUL/backspace/formfeed/U+0001 and literal backslash-u controls. Compile and execute emitted modules to verify exact identity round trips; preserve typed errors, serialized payloads and ten-family plans; update public examples/Knowledge and recurring native generated proof.
  Verification: `pending` repair — .3.3.34 emits all seven nonempty identity controls successfully; ASCII/quoted-whitespace/Unicode compile, four control-character modules fail at the identity literal. See docs/knowledge/rust-generated-source-literal-encoding-gap.md.
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.72`
  Status: `pending`
  Goal: Make generated recognition parse adapters preserve a coherent result contract.
  Dependencies: .3/.4/.5; preserve the established typed-value versus legacy-accumulator distinction.
  Acceptance: Reconcile recognition's plain-parse exception with all options/trace/sink siblings using actual emitted modules, default options/disabled trace/no-sink controls, entry selectors and unused intrinsics. Preserve direct arrays without unwrap heuristics, correct emitted imports, independent native recurrence and book/Knowledge accuracy.
  Verification: `pending` repair — .3.3.34 recognition parse returns "ok", while three inert-option siblings return ["ok"]; non-recognition parse roles all return ["ok"]. The plain-parse rewrite also leaves an unused generated import. See docs/knowledge/rust-generated-recognition-parse-adapter-gap.md.
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.73`
  Status: `pending`
  Goal: Reserve every staged result destination for a complete depth before callback execution.
  Dependencies: .3/.4/.5; preserve deterministic shared append and unpublished-AST failure behavior.
  Acceptance: Reject duplicate non-append destinations, mixed append/replacement claims and queued-marker overlap before callback one; preserve distinct sibling writes and ordered shared appends. Reconcile existing Dart/Julia reservations, implement each missing backend, verify one-depth/recursive/carrier routes with independent callback counts and final AST assertions, and update book/Knowledge plus canonical recurrence.
  Verification: `pending` repair — .3.3.37 Paired Perl/Rust controls in both modes call once before sibling collision/queued-marker rejection and silently overwrite a shared replace target after two calls. Exact evidence belongs in docs/knowledge/staged-target-preparation-gaps.md.
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.74`
  Status: `pending`
  Goal: Validate returned Rust staged markers deeply and reject invalid provenance without arithmetic panic.
  Dependencies: .3/.4/.5; preserve atomic marker node accounting and typed failure policies.
  Acceptance: Reject forbidden nested result keys within markers just as ordinary results; validate text/provenance bounds before queueing, use checked extent/rebase arithmetic, and return typed diagnostics without panic. Cover direct/derived, large extents, nested malformed markers, valid recursive controls and supported carriers; reconcile Julia precedent, public book and canonical recurrence.
  Verification: `pending` repair — .3.3.37 native returned host-key marker succeeds in both modes while an ordinary host-key record rejects; two u64::MAX extents pass one-depth and panic at strictly_decreases:2121 during recursive preparation. Backtrace and controls: docs/knowledge/rust-staged-returned-marker-validation-gaps.md.
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.75`
  Status: `pending`
  Goal: Reject exhausted Rust staged callback authority at the maximum representable call counter.
  Dependencies: .3/.4/.5; preserve cumulative counters across depths and typed admission failure.
  Acceptance: Replace saturating candidate admission with overflow-safe exhaustion logic; cover zero/one remaining call, ordinary exhausted and u64::MAX exhausted authority, no callback on rejection, exact result counters, recursion and carriers. Audit related arithmetic without assuming every saturation is erroneous; align book/Knowledge and canonical recurrence.
  Verification: `pending` repair — .3.3.37 native authority total_calls=max_calls=u64::MAX runs one callback and returns unchanged total; total=max=1 rejects before callback and MAX-1/MAX succeeds once. Source dispatch_resource_check:1784–1793. Evidence: docs/knowledge/rust-staged-call-counter-saturation.md.
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.76`
  Status: `pending`
  Goal: Correct the three SimEnv bare-variable edges that dispatch to the braced-variable handler.
  Dependencies: `.3`, `.4`, `.5`; preserve braced substitution and existing quoting/command behavior.
  Acceptance: Fix the authored dquotes/perl_dquotes/command_substitution targets and governed corpus generation;
    prove bare/braced controls, exact results and diagnostics across current backends, and update public examples.
  Verification: Pending repair; `.3.3.43` preserves twelve paired Perl observations and generated-handler evidence
    in `docs/knowledge/simenv-variable-dispatch-mismatch.md`; only in-memory probe substitutions were made.
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.77`
  Status: `pending`
  Goal: Make the generated-source classifier reject failed child execution independently of pass markers.
  Dependencies: `.3`, `.4`, `.5`; preserve exact full-manifest accounting and useful per-case diagnostics.
  Acceptance: Require host-run process success plus exact marker/accounting evidence; cover success, nonzero,
    signal termination, missing/duplicate/unknown markers and actual emitted Cargo execution. Keep all 105 cases
    unconditional, update governed verifier checks and Knowledge, and finish with canonical proof.
  Verification: Pending repair; `.3.3.51` binds the retained six source-extracted controls in `d6f37492` to
    current classifier source: exit 101 with all 105 markers incorrectly reports 105 passes and exits zero.
    The fresh in-memory status-guard control rejects it; executable proof: docs/knowledge/rust-generated-classifier-child-status-gap.md.
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.78`
  Status: `pending`
  Goal: Keep authored emitted-test Cargo dependencies relative to repository-derived workspaces.
  Dependencies: `.3`, `.4`, `.5`; distinguish generated dependency inputs from ADR 0052.6 tool-cache metadata.
  Acceptance: Audit analogous first-party manifest writers, replace persisted absolute runtime-crate dependencies
    with correct relative paths, and verify actual emitted builds plus moved-workspace dependency resolution.
    Preserve exact parser results, workspace cleanup, same-volume storage and legitimate tool metadata;
    update focused storage/portability regression proof and complete canonical verification.
  Verification: Pending repair; `.3.3.58` binds retained recognition/recursive-observation construction probes
    to their unchanged sources. Both write absolute dependencies; relative controls resolve the same crate.
    Nine source-confirmed writers and five relative controls are inventoried in docs/knowledge/rust-emitted-cargo-manifest-path-portability-gap.md.
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.79`
  Status: `pending`
  Goal: Reject signal-terminated captured Git and verifier children in routing-pressure enforcement.
  Dependencies: `.3`, `.4`, `.5`; preserve ordinary exit diagnostics and captured output.
  Acceptance: Require a valid wait result and successful normal termination before accepting a child.
    Audit sibling captured-process helpers; retain success/nonzero/signal controls, stdout/stderr evidence,
    exact verifier integration and canonical proof without weakening route or pressure enforcement.
  Verification: Pending repair; frozen .3.3.61 source-extracted controls show both routing helpers discard
    signal bits with $? >> 8: SIGTERM is accepted as status zero. An in-memory guard rejects it while
    preserving ordinary success/exit7 behavior. Nine document-history sibling controls correctly reject
    nonzero/signal termination. Evidence: docs/knowledge/routing-verifier-child-signal-status-gap.md.
  Commit: `pending`
- ID: `SESSION-STARTUP-READING.80`
  Status: `pending`
  Goal: Reuse compatible PGEN and RGX build artifacts while preserving every real-input invalidation and test.
  Children: `.80.0`, `.80.1`, `.80.2`, `.80.3`, `.80.4`
  Acceptance: Measure documented public build behavior and LinkedSpec-owned target retention. Report
    dependency issues upstream without implementation inspection or modification. Preserve source/pins,
    compatible artifacts and ordinary correct builds. Startup latency is separately owned by .81.
  Director boundary (2026-09-20): RGX/PGEN are black boxes; only published interfaces/contracts and observable results may guide this work. No internal inspection, causal reconstruction, patches or pin changes. Older implementation-derived notes are removed and cannot authorize future work.
  Earlier build permission (2026-09-13): The prior September10 build-on-update-only/no-rebuild requirement is cancelled. Resume normal Cargo builds, including RGX/PGEN compilation whenever Cargo requests it. Retain caches, preserve nested source/pin work and measure observable build behavior. This performance repair is no longer an integration-guide prerequisite; .80.1-.4 retain correctness and optimization work without a mandatory zero-build lifecycle.
- ID: `SESSION-STARTUP-READING.80.0`
  Status: `done; focused-signoff-complete`
  Goal: Preserve the CI build-reuse and newer-OS launch findings from the preceding capacity verification.
  Scope: Read-only evidence intake, pending repair ownership, Knowledge retrieval, book understanding and continuity.
  Activation: Clean `bef5dafd928ca723b79eda524351a9fb5c1cf66a`; zero-byte brief; promoted canonical receipt;
    containment .10 and every diagnostic job are complete and consumed before this task-tree-first change.
  Acceptance: Preserve the public build-stage baseline and its limits, observed sample outcomes and
    separately gated .80/.81 ownership. Dependency-internal conclusions are removed by director instruction.
    Preserve all earlier task/Knowledge/history evidence, reading coverage, dependency work and source bytes;
    return to DART-STARTUP-READING.1.37 after the focused commit and clean proof.
  Verification tier: `focused`
  Focused checks: Exact source/snapshot/log identities and bounded observation reconciliation; prior-node,
    reading and no-source-change scope review; Knowledge generation/check, all nine doctrines, explicit memory,
    both history-pressure checks, mdBook render/content review, staged scope and whitespace.
  Canonical trigger: `none` — tracking and observed-understanding update only; no runtime, dependency,
    CI, cache, policy, storage, capability or generated-contract implementation changes.
  Checklist: [x] clean activation/task ownership [x] evidence and pending owners [x] Knowledge/book/live lockstep
    [x] focused verification [x] commit/brief/clean handoff.
  Verification: Historical build/sample/receipt intake and Knowledge 1048/8543; implementation-derived
    dependency details removed on September20. Original documentation checks included
    rendered book, memory, both history-pressure checks, all nine doctrines and final scope/whitespace pass.
    The preceding capacity commit passes all nine doctrines, required
    consumers, storage/relocation, CLI 66x2 and Phase 0 1,032/1,032 in 1,163 seconds (Phase 0 only);
    its 25 optional gates/matrices remain skipped. This intake grants no startup reading credit.
  Commit: `SESSION-STARTUP-READING.80.0 - own CI build and startup findings` — Evidence and pending repair ownership only; resume Dart .1.37.
- ID: `SESSION-STARTUP-READING.80.1`
  Status: `pending`
  Goal: Measure cold/repeated public builds and supported consumer configurations.
  Dependencies: `.3`, `.4`, `.5`, `.80.0`.
  Acceptance: Run documented interfaces under managed storage, preserving inputs and caches. Record
    commands, toolchain, pins, exit status and build/test durations separately. Observe outputs without
    inspecting dependency implementation or inferring private freshness mechanisms. No zero-build promise.
- ID: `SESSION-STARTUP-READING.80.2`
  Status: `pending`
  Goal: Track upstream reports and published resolutions for measured dependency build costs.
  Dependencies: `.80.1`.
  Acceptance: Supply a self-contained public-command reproduction and observable result. The upstream
    maintainer owns diagnosis and repair. Verify a supplied resolution through published interfaces;
    do not inspect internals, patch dependency source, reconstruct build steps or change pins.
- ID: `SESSION-STARTUP-READING.80.3`
  Status: `pending`
  Goal: Assess compatible dependency-target retention in recurring drivers that currently discard fresh targets.
  Dependencies: `.80.1`.
  Acceptance: Measure the exact semantic, MCP and duplicate-slot driver lifecycles and their direct dependents.
    If beneficial, retain compatible repository-derived dependency artifacts while keeping fresh caller fixtures
    and deliberate isolation/relocation proof exact. Preserve same-volume storage, ownership and cleanup safety.
    Close not-required only with evidence; do not attribute the main gate's rebuilds to these optional drivers.
  Direction update (2026-09-13): Assess retention as a performance improvement while preserving intentional isolation, preparation and ownership. Normal dependency rebuilds, including recovery from a missing compatible cache, are authorized; no negative compiler guard is required.
- ID: `SESSION-STARTUP-READING.80.4`
  Status: `pending`
  Goal: Admit measured dependency-build reuse with unchanged verification coverage.
  Dependencies: `.80.2`, `.80.3`.
  Acceptance: Run repeated unchanged warm commands and controlled valid-invalidation cases, then the exact
    staged canonical gate. Account for remaining compile/startup/test costs, all flags and intentional cold
    proofs; update book and operational guidance with measured results. Parent .80 closes only after its
    implementation and verification are complete; the independent .81 investigation keeps its own status.
  Direction update (2026-09-13): Report measured cold/warm and valid-invalidation behavior with unchanged correctness coverage. The mandatory proof of zero RGX/PGEN compilation and build-on-update-only enforcement is cancelled. Ordinary Cargo rebuilds are authorized; do not claim reuse when compilation actually occurred.
- ID: `SESSION-STARTUP-READING.81`
  Status: `pending`
  Goal: Diagnose prolonged Rust startup on macOS 26.6.2 and resolve any demonstrated repository-controlled cause.
  Children: `.81.1`, `.81.2`
  Acceptance: Distinguish newer-OS evidence from the controlled macOS 26.5.2 closeout under
    FUTURE-PARITY-BACKLOG.19.3.4. A sampled pre-main location is not an OS/kernel causal diagnosis or a repair.
    Preserve exact tests, project-local storage and operating-system trust.
- ID: `SESSION-STARTUP-READING.81.1`
  Status: `pending`
  Goal: Establish controlled newer-OS launch and compiler/loader evidence independently of build invalidation.
  Dependencies: `.3`, `.4`, `.5`, `.80.0`.
  Acceptance: Use exact immutable-artifact warm twins and fresh serial repository-local controls, recording
    toolchain/OS, hashes, launch/build/test timing and concurrent artifact activity. Keep uninstrumented
    measurements separate from stack samples; temporal order does not establish sampling as a remedy.
    Reconcile the recognition and relocation samples plus the failed compiler-sample attempt. Determine
    whether any remaining cause is repository-controlled before selecting a remedy or external limitation.
  Related Lua observation: .1.2 samples both ABI probes on September 12 inside require/dlopen/mapSegments/fcntl while mapping project-local PCRE2 modules. Exact stacks and runtime identities live in docs/knowledge/lua-native-readme-and-action-ast-reading.md. Retain this cross-language comparison in the controlled newer-OS diagnosis; a loader location alone is not a cause or remedy.
- ID: `SESSION-STARTUP-READING.81.2`
  Status: `pending; conditional on causal evidence`
  Goal: Implement and verify only an evidence-backed newer-OS startup remedy when one is required.
  Dependencies: `.81.1`.
  Acceptance: Own the concrete repair before changes, preserve all tests and storage/portability guarantees,
    and prove cold/warm behavior without weakening trust, stripping provenance, speculative re-signing,
    shared-cache deletion or coverage reduction. If controlled current-OS evidence supports no repository
    repair, record that bounded conclusion explicitly; the older-OS closeout alone cannot close this leaf.
    Any necessary action outside project authority requires a concrete reviewable proposal for the director.
- ID: `SESSION-STARTUP-READING.82`
  Status: `pending`
  Goal: Make semantic query budget enforcement and diagnostics agree with the declared logical-cost contract.
  Dependencies: Startup .3/.4/.5; Julia .1.27 intake; preserve ADR0049 and all existing exact query evidence.
  Evidence: Julia and the neutral evaluator return identical six-control responses. Explain emits two relations under max_relations1 and depth1 under max_depth0, complete with no diagnostic. A list page of one record reports max_records reached despite a budget of two and emitted cost1. Exact mechanisms and replay belong to docs/knowledge/semantic-query-budget-contract-gaps.md.
  Children: `.82.1` contract and independent expectations; `.82.2` neutral evaluator repair; `.82.3` bounded backend repair decomposition; `.82.4` transport/carrier/public closeout.
  Acceptance: Resolve the conflict between reported logical costs, request maxima and page-only boundaries explicitly. Keep all source evidence and canonical hashes until an owned contract migration justifies changes. Every confirmed backend gets implementation ownership; no expectation refresh may merely ratify current wrong results.
  Lua reading .1.17 extension: Both installed Lua hosts return the same six complete budget responses as the neutral evaluator and the prior Julia controls. semantic_query.lua page_stream computes budget limitation from the unpaged remaining stream; explain applies only max_records before reporting relation/depth costs. New .82.3.1 owns bounded Lua implementation/proof after the shared contract/neutral decisions.
- ID: `SESSION-STARTUP-READING.82.1`
  Status: `pending`
  Goal: Freeze exact applicable budgets and page-versus-budget precedence for every semantic query operation.
  Dependencies: Startup prerequisites and Julia .1.27 committed.
  Acceptance: Reconcile ADR0049, neutral operation/cost/page policies, public teaching and MCP effective ceilings. Define independently checkable explain record/relation/depth bounds, decision reservation, zero-depth behavior and limits reached before/at/after a page boundary. Preserve the six intake responses; document any deliberate contract decision and migration impact before changing expected hashes.
  Verification: `pending`
  Commit: `pending`
- ID: `SESSION-STARTUP-READING.82.2`
  Status: `pending`
  Goal: Repair neutral semantic budget selection and diagnostics under the accepted contract.
  Dependencies: .82.1 and startup prerequisites.
  Acceptance: Add independent RED/GREEN expectations for explain secondary relations/depth, zero remaining step allowance, page smaller/equal/larger than budget, after-id continuation, combined ceilings and actual logical cost. Mutation proof must reject coordinated evaluator/fixture drift. Preserve unrelated exact responses and use canonical contract-change verification.
  Verification: `pending`
  Commit: `pending`
- ID: `SESSION-STARTUP-READING.82.3`
  Status: `pending`
  Goal: Census all five native semantic evaluators and create bounded backend implementation children.
  Dependencies: .82.1; source implementations additionally depend on .82.2 and startup prerequisites.
  Acceptance: Reproduce each boundary through Perl, Rust, Dart, Julia, PUC Lua and LuaJIT without assuming parity. Before editing, create one safe implementation child per confirmed backend cause, with independent request/cost/selection evidence and direct-dependent proof. Julia source mechanisms are SemanticQuery906-961 and1049-1066; retain separate source-correlation owners.
  Children: `.82.3.1` owns confirmed Lua implementation/proof; remaining native census and bounded child creation stay pending.
  Verification: `pending`
  Commit: `pending`
  Lua reading .1.17 extension: Both installed Lua hosts return the same six complete budget responses as the neutral evaluator and the prior Julia controls. semantic_query.lua page_stream computes budget limitation from the unpaged remaining stream; explain applies only max_records before reporting relation/depth costs. New .82.3.1 owns bounded Lua implementation/proof after the shared contract/neutral decisions.
- ID: `SESSION-STARTUP-READING.82.3.1`
  Status: `pending`
  Goal: Align Lua semantic budget enforcement and diagnostics with the resolved shared contract.
  Children: `.82.3.1.1` implementation; `.82.3.1.2` independent proof.
  Dependencies: .82.1/.82.2 and startup .3/.4/.5; supported Lua primary identity remains LUA-STARTUP-READING.2.2-owned.
  Evidence: Lua .1.17 independently compares six full raw-neutral graph responses on PUC and LuaJIT to the neutral evaluator; relation/depth overruns and the premature record-budget warning match the existing shared finding.
  Acceptance: Preserve canonical ordering, source ceilings, paging identity and typed/raw-neutral convergence while implementing the resolved applicable cost/budget boundaries. Keep query-evidence false preservation under LUA-STARTUP-READING.2.15 and all source-correlation repairs distinct.
  Verification: `pending`
  Commit: `pending`
- ID: `SESSION-STARTUP-READING.82.3.1.1`
  Status: `pending`
  Goal: Repair Lua explain limits and page-versus-budget boundary selection.
  Dependencies: Parent .82.3.1 prerequisites and independently frozen expectations.
  Acceptance: Apply each contract-required record/relation/depth bound to explain and select deterministic budget/page diagnostics from the boundary actually reached. Preserve after_id, decision/step/relation consistency, all unaffected query hashes and agreed logical costs across both supported host routes.
  Verification: `pending`
  Commit: `pending`
- ID: `SESSION-STARTUP-READING.82.3.1.2`
  Status: `pending`
  Goal: Independently verify Lua query budgets through public entrypoints and composed carriers.
  Dependencies: .82.3.1.1 committed cleanly.
  Acceptance: Cover simultaneous page/record/relation/depth limits, zero-depth explanations, cursor continuations and deterministic complete/incomplete response bodies against independent expectations on supported PUC and LuaJIT. Recompose typed/raw-neutral and applicable MCP proof; preserve source privacy and update book/Knowledge before closing the Lua container.
  Verification: `pending`
  Commit: `pending`
- ID: `SESSION-STARTUP-READING.82.4`
  Status: `pending`
  Goal: Close semantic budget recurrence across supported carriers, MCP and public teaching.
  Dependencies: .82.2 and every .82.3 implementation child; startup prerequisites.
  Acceptance: Prove typed/raw-neutral and supported reconstructed/generated/observed queries, native and SDK MCP effective ceilings, pages and logical costs with unchanged caller state and no target execution. Update public examples/Knowledge/rollout evidence, run designated canonical admission/public proof and close only the verified scope.
  Verification: `pending`
  Commit: `pending`
- ID: `SESSION-STARTUP-READING.83`
  Status: `done`
  Goal: Resolve the historical Lispish document-validation and malformed-token limitations before claiming strict s-expression parsing.
  Children: `.83.1`, `.83.2`, `.83.3`
  Dependencies: Clean integration handoff is complete at 87b35665e. ADR0123 supersedes blanket startup reading; each repair reads its affected contract, code, tests and book.
  Evidence: Integration .2.2 runs34 native Rust cases and independently matches nine complete Perl values. Leading/trailing text and a second form are ignored, an unterminated quote can become an atom, empty square brackets disappear, and a semicolon comment without newline can become content. Get descriptors show seek/default-scan policy, and generated source proves first-child return and no-match null paths. Exact quoted-string codepoints are preserved; no Rust-specific escaping defect was found.
  Historical ownership: PHASE0-BACKHALF-TRIAGE.5.2 fixed the old corpus driver's non-progress loop and described deeper parser/grammar follow-ons without implementing them. This node gives the document/token contract follow-on explicit contract, implementation and verification owners. Its current evidence does not reverify or reopen the dated same-buffer never-undef claim.
  September20 consumer intake: BACKEND-INTEGRATION-GUIDES.8.1 attaches ARCHOGEN/LS-002 complete-input/all-form requirements, ARCHOGEN/LS-003 and SEMULITH/LS-002 token-kind requirements, and SEMULITH/LS-001 reported multiline-string tree corruption with its unverified candidate patch. Exact source-qualified states, snapshots and local-versus-supplied evidence live in docs/knowledge/archogen-rust-lispish-integration.md. Contract .83.1 must resolve compatibility; .83.2 owns actual fixes and .83.3 their independent proof. No report is closed by a documentation warning or this intake. September22 .85 recovers the three SEMULITH identities; the independent quoted-LF repair is .83.2.1. Strict/token design retains .83.1 ownership under ADR0123.
  Acceptance: Establish an explicit complete-document contract, implement the accepted strict path and independently prove it. Preserve existing historical behavior unless a reviewed migration deliberately changes it; a documentation warning alone cannot close this repair.
  Verification: PASS: all 37 unchanged authored cases through each of six public-loader routes (222 outcomes), with 21 process groups per route covering exact values, typed rejection or the Rust text adapter Display, prior-output retention, relative Unicode grammar paths, invalid UTF-8 and missing grammar. Native Rust file replay passes 37 cases/36 groups; historical Lispish passes 26 values/18 groups. The recurring grammar driver adds token round trips and same-engine post-rejection reuse; exact staged canonical proof is mandatory for this admission and enforced by the landing hook. Formal closeout is SEXPR-DOCUMENT-INTEGRATION.2.
  Commit: `SEXPR-DOCUMENT-INTEGRATION.2 - admit complete document integration`
- ID: `SESSION-STARTUP-READING.83.1`
  Status: `done`
  Goal: Define strict Lispish document consumption, token validity and compatibility boundaries.
  Dependencies: Parent .83 prerequisites; .83.2.1 completed at 8259719f8 with clean handoff.
  Activation commit: `8259719f8198a1280c8d91d07a9797ef39e036a8`.
  Verification tier: `focused`
  Focused checks: Source-qualified consumer requirements, independent accepted/rejected examples and Toolbox feasibility probes; compatible output/schema decisions and bounded implementation ownership; Knowledge/memory/history/book/diff and normal doctrine hooks.
  Canonical trigger: Design and unadmitted acceptance planning only; production grammar and public delivery remain implementation/admission-owned. No runtime, gate, dependency or public contract promotion in this leaf.
  Scope: Separate versioned document grammar retaining atom kinds; preserve historical Lispish. Decide syntax, numeric/text spelling, trivia, complete-input errors and native-consumer integration before implementation. Prototype only under repository-local scratch to verify feasibility; do not present planned behavior as delivered.
  Acceptance: Specify one versus multiple top-level forms, leading/trailing text, empty input, missing/extra delimiters, unterminated quotes, bracket/brace forms, newline and EOF comments, and exact escape/token-kind semantics. Reconcile these with the current first-form extraction grammar and decide whether strict behavior is a separate/versioned grammar or a deliberate migration. Record the decision and independent expected values/errors before implementation.
  Consumer acceptance: Include quoted LF versus tab/CR controls, multiline strings followed by sibling forms, parentheses within such strings, numeric-looking quoted versus bare atoms and the four-form eADL case. Specify how skipped leading/interstitial/trailing text is rejected rather than relying only on a final cursor. Preserve the withdrawn hex-underscore and documented adjacency controls; distinguish grammar validation from consumer domain validation.
  Decision: ADR0124 selects SExprDocumentV1.spec, a separate versioned document with all ordered top-level lists and tagged atoms retaining full lexemes. It specifies ASCII trivia/EOF comments, exact numeric classification, literal quoted spelling, malformed-input rejection and no implicit fragment joining. Historical Lispish remains intact. The accepted 37-case authority is tests/sexpr-document-v1/contract.json; it is design evidence, not delivered grammar.
  Verification: PASS: source-qualified report review; 37 independent cases (21 accept/16 reject), 136 Perl assertions including token-spelling reconstruction and the no-skipped-text mutation; four native Rust prototype boundaries with full stdout/stderr/status. The first nonportable infix expression reproduces .45's warned-and-dropped LX block with exit 0/null; documented num_ne(...) fixes the prototype, while .45.1-.45.3 now own the compiler repair before delivery. The exact durable Knowledge proof replays all 136 assertions. Knowledge/memory/history/book/public/diff and normal doctrine hooks govern focused design landing. No production grammar, runtime source, dependency, promotion, canonical gate or push.
  Validation ordering: The first aggregate-public check overlapped Knowledge regeneration and reported a missing marker while the generator writes its output directly. The completed map contains the marker; dependent validation is rerun only after generation. This was an orchestration ordering error, not evidence of a missing fact.
  Commit: `SESSION-STARTUP-READING.83.1 - define kind-preserving document grammar`
- ID: `SESSION-STARTUP-READING.83.2`
  Status: `done`
  Goal: Repair quoted LF compatibility and implement the accepted strict document and token-validation path with bounded ownership.
  Children: `.83.2.1`, `.83.2.2`, `.83.2.3`.
  Dependencies: .83.1 and compiler rejection closeout .45.3 are required for strict/token delivery. Independent .83.2.1 repairs multiline quoted payloads within the historical output shape and may proceed after .85; it must not silently introduce strict validation or atom kinds.
  Acceptance: Decompose concrete grammar, API and any necessary backend work into safe children before edits. Add RED/GREEN proof that omitted text and malformed tokens cannot silently yield an accepted document. Preserve documented historical extraction, native in-process execution, exact strings and agreed head/tail or versioned domain shape; no host-side guess may masquerade as grammar validation.
  Verification: PASS: all 37 unchanged authored cases through each of six public-loader routes (222 outcomes), with 21 process groups per route covering exact values, typed rejection or the Rust text adapter Display, prior-output retention, relative Unicode grammar paths, invalid UTF-8 and missing grammar. Native Rust file replay passes 37 cases/36 groups; historical Lispish passes 26 values/18 groups. The recurring grammar driver adds token round trips and same-engine post-rejection reuse; exact staged canonical proof is mandatory for this admission and enforced by the landing hook. Formal closeout is SEXPR-DOCUMENT-INTEGRATION.2.
  Commit: `SEXPR-DOCUMENT-INTEGRATION.2 - admit complete document integration`
- ID: `SESSION-STARTUP-READING.83.2.1`
  Status: `done`
  Goal: Fix SEMULITH/LS-001 quoted LF tree corruption in the historical Lispish grammar without changing its output contract.
  Dependencies: .85 clean handoff; targeted Toolbox attribution, grammar and existing quote-contract review. This compatible payload repair does not require the broader strict/token design .83.1.
  Activation commit: `392bd5335dbcb9f6eddf2642fc0f70d3d15164df`.
  Verification tier: `focused`
  Focused checks: RED/GREEN shared quote fixtures through Perl and all native primary commands including LuaJIT; Rust eight-report-case file consumer, existing Lispish compatibility, Phase0 smoke and descriptor readiness; memory, histories, book and normal doctrine hooks.
  Canonical trigger: Bounded grammar bug correction preserves historical output and public regex contracts; no admission, gate, toolchain, dependency or generated-format movement. Escalate if cross-backend proof exposes unresolved uncertainty.
  Scope: Quoted-token newline handling, persistent independent regressions, the existing shipped corpus source copy, relevant native consumer compatibility and exact book examples/current verifier counts. Review both quote rules and public regex support; no dependency internals or pins.
  Acceptance: Prove RED/GREEN for the eight supplied cases, exact LF/tab/CR/indentation/siblings/parentheses and quote/escape controls. Preserve historical extraction and string values; distinguish kind-preserving/document-validation follow-ons. Run all affected backend compatibility routes and selected component checks, record actual proof and commit before moving to .83.1.
  Verification: PASS: exact clean-HEAD grammar fails all three final shared fixtures; fixed Phase0 smoke passes 9 assertions, and Perl/Rust/Dart/Julia/PUC Lua/LuaJIT pass 3 fixtures in both default and POSIX environments (36 command legs; 19 aggregate forms plus two isolated quote contexts). Rust passes 26 file values through one engine and all 18 existing verification groups, including all eight byte-exact report inputs/expectations. Descriptor readiness remains 9/9 with 0 blockers; corpus copy is exact and retains its x/y value. Eight root/child quote controls explain and correct the initial invalid root-capture probes without a runtime change. Book, direct public checks, syntax, memory/history/Knowledge/diff and normal nine-doctrine hooks govern focused landing; no canonical run or push.
  Commit: `SESSION-STARTUP-READING.83.2.1 - preserve multiline Lispish quoted strings`

  Acceptance Checklist:
  - [x] **REPRODUCE / ISSUE** — Original eight-report Rust replay has four silent LF failures; final shared fixtures fail against exact pre-fix grammar through bin/linkedspec.
  - [x] **ROOT CAUSE (WHY + WHERE)** — LinkedSpec::get_parser return_descriptor/dump_parser_source traces dependency slots to specs/Lispish.spec:69 and :71: dot excludes LF, so seek dispatch reads quoted payload as syntax. Initial-action entry captures require a matched parent edge; eight root/child controls distinguish that contract.
  - [x] **FIX** — Add (?s) to both quote patterns, synchronize the exact corpus source copy, and add shared authored expectations plus eight unchanged report inputs/values to native file verification.
  - [x] **ADDRESSED (verified)** — FAIL->PASS for all three shared fixtures; 36 native/reference command legs and Rust 26-file/18-group verification PASS. No source guessing, escape decoding or consumer-side repair.
  - [x] **NO REGRESSION** — Phase0 smoke 9, descriptor 9/9, exact x/y corpus and original Rust compatibility/error/deployment groups PASS; controls retain CR/LF/CRLF, Unicode, comments, escapes, adjacency, single quotes and braces.
  - [x] **LOCKSTEP** — Quote source, copied corpus, regression fixture, Rust verifier, book examples and task/Knowledge/live roadmap pointers agree; ordinary focused checks and git diff --check PASS.
- ID: `SESSION-STARTUP-READING.83.2.2`
  Status: `done`
  Activation commit: `eda9cd3dd008784bc7f7993fe09ed5d35665e535`.
  Verification tier: `canonical`
  Focused checks: Consume the independently authored contract in persistent Perl/Rust/Dart/Julia/PUC Lua/LuaJIT tests, with round trips, typed failures and same-engine reuse; prove descriptor readiness and the skipped-text mutation; preserve historical Lispish regressions; run book, Knowledge, memory, history, diff and doctrine checks.
  Canonical trigger: A new public grammar contract and its recurring cross-runtime test registration require exact staged canonical acceptance before landing.
  Goal: Implement SExprDocumentV1.spec and persistent consumers of the accepted document contract.
  Dependencies: .83.1 and .45.3 committed with clean handoffs.
  Scope: The versioned grammar, exact authored expectations, source/descriptor readiness, native regression integration, all five backend integration guides and their shared landing page, and reviewed public chapter inventories (mutation70/selector69); preserve Lispish. Canonical mechanism and inventory evidence: docs/knowledge/sexpr-document-design.md and docs/knowledge/mutation-public-surface-no-drift.md.
  Acceptance: Consume all 37 authored cases without regenerating expected values from the parser. Prove complete recognition, all top-level forms, exact atom kinds/lexemes, both quote/backslash boundaries, EOF comments and atomic rejection. Exercise Perl/Rust/Dart/Julia/PUC Lua/LuaJIT with compiled-engine reuse after failures; retain an independent mutation showing that EOF alone cannot detect skipped text. Add precise further fixtures only when justified by implementation evidence. Run canonical proof for this public grammar implementation boundary before landing.
  Verification: PASS: all 37 authored cases on six native runtimes (222 case outcomes), 21 token-spelling round trips per route and 16 same-engine post-rejection reuse checks per route. Perl has 44 top-level/168 nested assertions including descriptor readiness and the independent catch-all mutation; Rust one complete contract test, Dart 38 tests, Julia 91 assertions, and both Lua routes pass. Three initial Dart EOF-comment failures become green with a portable grammar branch, without changing authored expectations. Historical Lispish quoted-LF fixtures pass 3/3 on Perl, and the new book command returns its exact documented value. Formatting, Dart analysis, shell syntax, book, Knowledge/memory/history/diff and doctrine checks govern landing. The public grammar/recurring-CI boundary requires the exact staged canonical receipt; native file delivery and final report admission remain separate. Complete shipped-inventory proof PASS: Rust auto-discovery parses, validates and compiles all 22 grammars; Perl return_descriptor passes 67 assertions (inventory plus three readiness checks per grammar); the public catalog lists the same 22 filenames exactly once. Current invariant prose no longer embeds a stale fixed count, and the 70/69 public guards retain every semantic mutation check. The Rust integration guide command builds and returns the exact documented two-form tagged value through the public loader and generic native consumer. Direct consumer boundary checks also pass empty documents, ordered two-form input and interstitial-junk rejection with empty stdout.
  Commit: `SESSION-STARTUP-READING.83.2.2 - implement complete s-expression documents`

  Acceptance Checklist:
  - [x] **REPRODUCE / ISSUE** — The independent 37-case contract fixes the required all-form/kind behavior; native Dart reports three EOF-comment failures before the portable branch.
  - [x] **ROOT CAUSE (WHY + WHERE)** — LinkedSpec::Get return_descriptor proves canonical ActionIR readiness; Dart public RuntimeRegexAlternation isolates literal-z behavior, with the unchanged-host-pattern mechanism at dart/lib/src/runtime/matching.dart:1384. Default seek can skip interstitial text, as the independent rejecting-edge mutation proves.
  - [x] **FIX** — Ship a separate Document grammar with ordered forms, exact tagged lexemes, portable EOF comments, explicit rejecting edges and the final cursor guard. Preserve historical Lispish.
  - [x] **ADDRESSED (verified)** — Six native runtime routes PASS all authored values/rejections, round trips and post-rejection reuse; the three Dart EOF cases are FAIL->PASS with unchanged expectations.
  - [x] **NO REGRESSION** — Lispish source remains unchanged; all three historical quoted-LF CLI fixtures PASS. Syntax, Rust formatting and Dart analysis pass; the exact staged canonical gate is the required landing authority.
  - [x] **LOCKSTEP** — The grammar, recurring tests, all five backend integration guides, shared integration landing page, book, roadmap, Knowledge and live pointers describe this grammar delivery; the guides identify Document entry selection and native failure/value handling; the separate native file consumer and final report admission retain their owners.
- ID: `SESSION-STARTUP-READING.83.2.3`
  Status: `done`
  Goal: Deliver a separate native Rust file-consumer path for the tagged complete-document grammar.
  Children: `SEXPR-DOCUMENT-INTEGRATION.1`; clean .83.2.2 dependency is satisfied by 77d7b3db1.
  Scope: A native sexpr_file example using existing public loader/engine APIs and the versioned result; preserve lispish_file's historical adapter. Share only genuinely common file/loader plumbing when needed; no subprocess parsing or guessed token kinds.
  Acceptance: Verify every supplied SEMULITH kind case and all four ARCHOGEN forms, valid/invalid UTF-8 and paths, empty documents, errors without partial document output, multiple files through one engine, executable-relative grammar assets and relocation. Document exact kind/lexeme use and current limits in the public book with examples; preserve all historical file-consumer checks and select the warranted delivery tier.
  Verification: PASS: all 37 unchanged authored cases through each of six public-loader routes (222 outcomes), with 21 process groups per route covering exact values, typed rejection or the Rust text adapter Display, prior-output retention, relative Unicode grammar paths, invalid UTF-8 and missing grammar. Native Rust file replay passes 37 cases/36 groups; historical Lispish passes 26 values/18 groups. The recurring grammar driver adds token round trips and same-engine post-rejection reuse; exact staged canonical proof is mandatory for this admission and enforced by the landing hook. Formal closeout is SEXPR-DOCUMENT-INTEGRATION.2.
  Commit: `SEXPR-DOCUMENT-INTEGRATION.2 - admit complete document integration`
- ID: `SESSION-STARTUP-READING.83.3`
  Status: `done`
  Goal: Independently verify and admit the complete document path across supported native backends; execution owner is docs/tasks/SEXPR-DOCUMENT-INTEGRATION.md.
  Dependencies: Every .83.2 implementation must be completed and committed: .83.2.1, .83.2.2 and native delivery SEXPR-DOCUMENT-INTEGRATION.1. SEXPR-DOCUMENT-INTEGRATION.2 owns final admission and formal .83.2/.83.2.3 parent closeout together.
  Acceptance: Replay exact valid/invalid documents, file/UTF-8/error handling, complete consumption and compiled-engine reuse on Perl, Rust, Dart, Julia, PUC Lua and LuaJIT under their admitted toolchains. Preserve relevant existing corpus coverage without reviving retired applications. Update integration guides, the Lispish walkthrough, Knowledge and task evidence; run canonical admission proof and close only verified scope.
  Verification: PASS: all 37 unchanged authored cases through each of six public-loader routes (222 outcomes), with 21 process groups per route covering exact values, typed rejection or the Rust text adapter Display, prior-output retention, relative Unicode grammar paths, invalid UTF-8 and missing grammar. Native Rust file replay passes 37 cases/36 groups; historical Lispish passes 26 values/18 groups. The recurring grammar driver adds token round trips and same-engine post-rejection reuse; exact staged canonical proof is mandatory for this admission and enforced by the landing hook. Formal closeout is SEXPR-DOCUMENT-INTEGRATION.2.
  Children: `SEXPR-DOCUMENT-INTEGRATION.2`
- ID: `SESSION-STARTUP-READING.84`
  Status: `done`
  Goal: Adopt the director-approved targeted startup and fast ramp-up while preserving the separate full-reading audit.
  Activation commit: `cb47fde46f4ded2a0683f45f6264a4417f1741ff`.
  Verification tier: `focused`
  Focused checks: Review authoritative startup instructions, current frontier and preserved reading evidence; memory architecture, Knowledge synchronization, both history checks, book rendering, direct public-document checks, diff check and normal doctrine hooks.
  Canonical trigger: Director-authorized operating guidance and continuity only; no mechanical doctrine, hook, tool, runtime, public contract, capacity or dependency changes.
  Authorization: On 2026-09-22 the director answered “Yes—use targeted reading and proceed to the bugs” and explicitly requested a fast ramp-up. This supersedes the original paragraph0 full-codebase prerequisite for ordinary fixes.
  Scope: SESSION_BOOTSTRAP.md, AGENTS.md discovery, ADR0123, current task/roadmap/live/book pointers and retrieval. Preserve all existing reading ranges, completion evidence and defect ownership; keep broad reading as a separate deferred audit.
  Acceptance: Startup targets2–5 minutes for context/Git/task recovery; affected requirements/code/contracts/tests/book are read before changes. Only scope-relevant uncertainty expands reading. Existing quality, task ownership, storage, black-box dependency and commit/verification rules remain. Three director-referenced bug reports must be identified before selecting their repair owners.
  Verification: PASS: scoped startup procedure and ADR0123 agree with current memory/task/roadmap/book pointers. Preserve2858 other tracked files/50770871 bytes,348 prior startup and180 conformance task nodes, prior fenced recipes, all immutable history, book headings and parent gitlink; only .84/.85 and two corresponding decision/Knowledge records are added. Memory60 lines, Knowledge1164 facts/9334 keys, histories324/57285 and194/37282 lines/bytes, rendered book, public mutation69/50 and selector68/11 checks pass. No source, hook, gate, timing enforcement or capacity change. Normal nine-doctrine hooks govern focused landing; no canonical run or push.
  Commit: `SESSION-STARTUP-READING.84 - adopt targeted startup and fast ramp-up`
- ID: `SESSION-STARTUP-READING.85`
  Status: `done`
  Goal: Identify the three director-referenced bug reports and route execution to their existing repair owners.
  Activation commit: `8f0cdf6b574c6d18e3af7e60447d70cfe2198739`.
  Verification tier: `focused`
  Focused checks: Reconcile the integration .8.1 report register and source snapshots; independently replay all eight SEMULITH/LS-001 Rust cases with full stdout/stderr/status; Knowledge, memory, histories, book, public-document checks, diff and normal doctrine hooks.
  Canonical trigger: Retrieval and continuity correction only; no source, public contract, gate or dependency changes.
  Scope: Existing BACKEND-INTEGRATION-GUIDES.8.1 report register and its exact SEMULITH snapshot; correct the false missing-identities blocker without requiring the director to repeat repository evidence.
  Dependencies: .84 clean handoff. Report identities were already durable; the prior question resulted from failed retrieval, not missing user input.
  Acceptance: Record the exact three reports, evidence and implementation owners; select the first safe repair using targeted reading, retaining technical dependencies and existing ownership.
  Reports: SEMULITH/LS-001 multiline quoted-string corruption belongs to .83.2.1; SEMULITH/LS-002 atom-kind design request belongs to .83.1/.83.2/.83.3 alongside ARCHOGEN/LS-003; SEMULITH/LS-003 workspace/prerequisite guidance was repaired and verified by integration .8.2/.8.4/.8.5 and final .7. Preserve source-qualified IDs and do not claim downstream report acceptance.
  Verification: The 29-file SEMULITH snapshot matches its retained manifest SHA-256 a77e92fedc744643db03edea346d3619c60c1ac3cb20dc97ab444f7cd82ed3af. Fresh native Rust replay confirms four matching controls and four silently corrupted LF cases, all exits 0 and empty stderr; full results/binary/grammar hashes are in .linkedspec-data/scratch/report-recovery/ls001-current.json. The native consumer/runtime/grammar sources are unchanged since integration 87b35665e. Canonical retrieval is docs/knowledge/archogen-rust-lispish-integration.md; no report is repaired by this routing slice.
  Commit: `SESSION-STARTUP-READING.85 - recover SEMULITH reports and repair ownership`
- ID: `SESSION-STARTUP-READING.86`
  Status: `done`
  Goal: Reconcile and repair Rust symbol-call statement boundaries and the measured Perl scanner disagreements without misclassifying regex literals.
  Children: `SESSION-STARTUP-READING.86.1`, `SESSION-STARTUP-READING.86.2`, `SESSION-STARTUP-READING.86.3`, `SESSION-STARTUP-READING.86.4`, `SESSION-STARTUP-READING.86.5`
  Dependencies: Clean .49 at 4f79298f9; ADR0123 targeted reading applies.
  Acceptance: Preserve following statements and exact callees, source and values through supported carriers. Keep Rust's accepted multiline/escaped/quoted regex literals. Investigate the public Perl EOF and regex controls without inferring they share the Rust cause. Canonical parent closeout follows both bounded repairs.
  Verification: The pre-repair forty-case public comparison and CodeBlock ASTs are recorded in .linkedspec-data/scratch/symbol-boundary86/. All 12 Perl symbol callees accept LF; baseline Rust rejected 11 and silently turned subtraction into an empty-name call returning null. The original slash failure plus seven currently accepted Rust regex controls require separate disambiguation work. Rust .86.1/.86.2 and bounded Perl .86.4/.86.5 are verified; canonical parent .86.3 binds final acceptance through the required staged receipt.
  Commit: Closed by `SESSION-STARTUP-READING.86.3 - close verified scanner repairs in lockstep`; independent defect owners remain open.
- ID: `SESSION-STARTUP-READING.86.1`
  Status: `done`
  Goal: Preserve line-break boundaries and exact callee identity for the eleven non-slash Rust symbol calls.
  Dependencies: Clean .49; current .86 public diagnosis. Slash and Perl scanner controls stay under immediate .86.2.
  Verification tier: `focused`
  Focused checks: Public CLI/Get and both CodeBlock modes RED/GREEN; eleven arithmetic/comparison/assignment symbols, LF/CRLF/CR/horizontal whitespace, EOF/semicolon/nested/negative-number controls; source/compiled serde, generated/emitted routes; core and selected runtime compatibility; book, Knowledge, memory, histories, doctrines and diff.
  Canonical trigger: Bounded existing-call repair with unchanged serialized formats; canonical parent closeout belongs to .86.3.
  Acceptance: Preserve authored line breaks after non-slash symbol calls and their subsequent statements. Subtraction must retain name '-' and return 7 in the measured case. Retain rejected malformed boundaries, negative literals and the exact existing slash/regex behavior. Record slash failures without normalizing their required outcomes.
  Verification: The pre-repair public matrix confirms all eleven LF failures: ten compile rejects and one wrong null. Core AST exposes Call{name:""} for subtraction; parse_expr consumes '-' on failed symbol lookahead, and parse_var_or_call accepts an empty parse_name before '('. Shared boundary scanning loses LF/CRLF before these fallbacks. Corrected core RED has two boundary failures/two compatibility passes. The first test run also exposed an incorrect test assumption that the = callee was already normalized; the public AST corrected it before production changes. Non-slash lookahead now accepts authored LF/CRLF, while slash retains its exact prior discriminator. PASS: 247 core tests and 401 selected runtime tests; the new core target covers 110 symbol/separator/parser combinations, 22 following-write source/span cases and retained compatibility. Three new runtime groups cover 33 symbol assignments, a Unicode-source write and five compatibility cases through source-AST/compiled serde and generated plans. All 14 mutation tests pass, including independent emitted execution after subtraction. Native 44 passes: 39 exact numeric values and five unchanged division rejections owned by .86.2. The exact book example returns 7. Binary SHA-256: 80227ab43b9ef73f56c7884d28151f83f2c6562d0c98bdab35a45bd2255129e5. Book/public checks, Knowledge, memory, histories and normal doctrines are required before landing.
  Commit: This commit; subject `SESSION-STARTUP-READING.86.1 - preserve non-slash symbol call boundaries`.
  - [x] **REPRODUCE / ISSUE** — Public CLI/Get and CodeBlock probe expose ten rejects and one wrong-value non-slash case.
  - [x] **ROOT CAUSE (WHY + WHERE)** — expr.rs symbol boundary lookahead skips line breaks; subtraction then reaches the empty-name fallback.
  - [x] **FIX** — Preserve line-break boundaries for non-slash callees; retain the existing slash decision.
  - [x] **ADDRESSED (verified)** — Exact callees, subsequent AST/source and values agree across supported carriers.
  - [x] **NO REGRESSION** — Focused core/runtime, malformed, negative-literal and unchanged slash/regex controls pass.
  - [x] **LOCKSTEP** — Integration book, Knowledge and live task/roadmap pointers match the verified scope.
- ID: `SESSION-STARTUP-READING.86.2`
  Status: `done`
  Goal: Repair division-call newline recognition while retaining accepted multiline regex interpretations.
  Dependencies: Complete .86.1; use the forty-case public/native/core diagnosis and canonical arithmetic ground truth.
  Verification tier: `focused`
  Focused checks: Slash calls before identifiers/regex/string/other calls, LF/CRLF, nested/quoted/escaped arguments, multiline parenthesized regex, whole-spec source/carriers and exact subsequent values. Classify public Perl EOF/quoted/multiline controls using captured diagnostics and own any distinct repair before implementation.
  Canonical trigger: Parent .86.3; any contract decision must precede implementation and use canonical proof.
  Acceptance: Do not blindly classify newline after /(args) as division: current Rust accepts /(x) followed by LF and y/ as a regex. Preserve all seven measured regex controls and fix division followed by another statement. Retain original failures, use public tools first, split any independently established scanner repair, and stop for director input if the language contract is genuinely ambiguous.
  Verification: Original slash LF/CRLF/space/nested/before-regex forms reject Rust compilation; Perl explicit edges return 7. Rust accepts seven regex controls with exact patterns; some Perl quoted/multiline controls return null or no parser. Bare slash-call EOF rejects Perl Get while its semicolon/named twins work. Full raw evidence is retained; no cause or repair equivalence is inferred.
  Current proof: Core RED exits101 with five failures/one pass. Initial GREEN compile failed on a secondary parser initializer, corrected before rerun. PASS: 254 core tests and 404 selected runtime tests. Seven division core groups cover 24 call/separator combinations in both parser modes, exact retained regex patterns, late-statement retries, Unicode write spans, nested controls/callable candidates, and 1500-statement valid/invalid chains. Runtime coverage includes 12 division/separator combinations, nine mixed/nested cases, exact Unicode writes and the ambiguous regex through source-AST/compiled serde and generated plans. All 15 mutation tests pass, including independently compiled emitted division execution. Native 56 passes: 53 exact integer values and 3 malformed rejections; both book examples pass. Binary SHA-256: bbf40b8165ce72764668b7a02e16c84ddabfcf4b1097d690f5b99956ab38e05d. Book/public, Knowledge, memory/history and normal doctrines are required before landing. Perl discrepancies are separately owned by .86.4/.86.5.
  Commit: This commit; subject `SESSION-STARTUP-READING.86.2 - preserve division newline and regex interpretations`.
  - [x] **REPRODUCE / ISSUE** — Public CLI/Get retain five division newline failures after verified .86.1.
  - [x] **ROOT CAUSE (WHY + WHERE)** — symbol_call_paren_has_expression_boundary erases line breaks; slash fallback preserves multiline regex, so its discriminator needs independent reconciliation.
  - [x] **FIX** — Repair division statement separation while retaining established regex forms and source fidelity.
  - [x] **ADDRESSED (verified)** — Native, source/compiled serde and generated/emitted outcomes retain exact following statements.
  - [x] **NO REGRESSION** — Quote/escape/nesting/multiline/negative and non-slash controls retain their contracts.
  - [x] **LOCKSTEP** — Public examples, Knowledge and live task/roadmap pointers match verified behavior and any separately owned scanner finding.
- ID: `SESSION-STARTUP-READING.86.3`
  Status: `done`
  Goal: Close symbol-call repairs with synchronized public guidance and exact canonical acceptance.
  Dependencies: Verified .86.1/.86.2/.86.4/.86.5; no remaining required repair may be hidden by parent closure.
  Verification tier: `canonical`
  Focused checks: Exact core/runtime/carrier/native and public examples, cursor inventory60 mutations, stable markers4 mutations, repeated-action54 mutations, all backend scope qualifications, task/Knowledge/history/memory and normal doctrines.
  Canonical trigger: Parent closeout on the exact staged candidate; resume .50 after a clean commit.
  Gate reconciliation: The first canonical run passes all nine doctrines then fails the cursor contract migration inventory: dart/test/same_line_regex_slot_grammar_test.dart is an unowned matching consumer. The first canonical attempt stopped at an unowned mode-aware Dart grammar test. Register that exact consumer under the existing Dart group and advance only the current census from76 to77, including contract/checker/stable-marker/book mirrors. Independent JSON comparison preserves every non-census semantic field, fixture, rollout and forbidden claim. Focused cursor proof passes36 families/18 edges/8 parent-child/77 files/60 mutations; stable markers pass8 families/12 markers/15 consumers/4 mutations, and repeated-action passes54 mutations. Earlier dated counts remain unchanged; the failed gate has no receipt.
  Acceptance: Reconcile every measured failure and compatibility control with its verified repair or explicit continuing owner; retain unresolved independent defects and historical evidence without a broad parity claim.
  Verification: Fresh public Rust replay passes56 cases:53 exact integer results and3 malformed rejections, including both published symbol/division examples. Rust production and carrier tests are byte-identical to19ba2e0d5, retaining254 core/404 selected runtime/15 emitted-mutation proof. Perl/spec/Dart sources match verified52408086a, retaining focused240/book103/Phase0 1033,120 exact checkpoint records, composed grammar72 and Dart20/package502/storage25owners47packages/CLI66x2/corpus105. All Perl/Rust book fences remain exact; only reciprocal guide links change and the book renders. All .86 implementation children are done or explicitly superseded. Independent .27/.34/.54.1/.63/.87 and Dart .2.24/.2.25 remain owned; no full optional Dart gate or global defect-free claim. Landing requires successful tools/run_ci_local.sh on the exact staged candidate; its receipt and commit body record the final canonical result.
  Commit: `SESSION-STARTUP-READING.86.3 - close verified scanner repairs in lockstep`

  - [x] **RECOMPOSITION** — Current public controls and unchanged child sources preserve scoped evidence.
  - [x] **OWNERSHIP** — Every measured independent failure retains its existing repair owner.
  - [x] **LOCKSTEP** — Executed book fences, backend qualifications and current task/roadmap/Knowledge pointers agree.
  - [x] **CANONICAL BOUNDARY** — Normal commit hook must validate the successful exact staged receipt before this closeout lands.

- ID: `SESSION-STARTUP-READING.86.4`
  Status: `done`
  Goal: Preserve multiline regex pattern operands in documented Perl action helpers through whole-spec validation.
  Dependencies: Land Rust .86.2 first; captured public diagnostics in .linkedspec-data/scratch/division-boundary86-2/perl-context.jsonl and reproducible sources in docs/knowledge/rust-symbol-call-newline-boundary.md; coordinate .54.1 without conflating regex-brace bootstrap loss.
  Children: `SESSION-STARTUP-READING.86.4.1`, `SESSION-STARTUP-READING.86.4.2`, `SESSION-STARTUP-READING.86.4.3`, `SESSION-STARTUP-READING.86.4.4`, `SESSION-STARTUP-READING.86.4.5`, `SESSION-STARTUP-READING.86.4.6`, `SESSION-STARTUP-READING.86.4.7`, `SESSION-STARTUP-READING.86.4.8`
  Planned tier: focused unless a shared language-contract decision is needed.
  Planned focused proof: Public Get with runtime_ctx_ref, exact lowering and generated source; multiline regex and numeric-division lookalikes, LF/CRLF, following assignments, whole-spec validation and invalid-pattern controls; phase0 plus directly affected scanner tests.
  Planned canonical boundary: Parent .86.3 after .86.5; any contract decision precedes implementation.
  Acceptance: Retain protected helper-pattern newlines and working division-newline statements. Assignment-position observations are compatibility evidence, not a regex-variable requirement after .86.4.2.4. Fix documented helper operands at their actual owners; do not infer unknown backend parity. Synchronize Perl integration/book examples and durable facts.
  Verification: Verified under .86.4.4.2.2: helper13/grouped22/numeric12/original12 retain all59 exact public outcomes and the syntax record; source bytes and error stages are preserved. Production/tests and four book sources match9f81d3162, retaining focused173/book66 and both mutation proofs. Checkpoint syntax and book render pass. Close only measured ordinary-helper work; .87/.2.4/.34/.54.1/.9 and immediate .86.5 retain their defects. Parent .86.3 remains canonical.
  Commit: `SESSION-STARTUP-READING.86.4.4.2.2 - verify public helper and book recomposition`
- ID: `SESSION-STARTUP-READING.86.4.1`
  Status: `done`
  Goal: Reproduce and separate Perl multiline regex segmentation and validation failures before production changes.
  Dependencies: Clean .86.2 at 19ba2e0d5; ADR0123 targeted recovery.
  Verification tier: `focused`
  Focused checks: Public Get/runtime_ctx_ref and call_spec_handler_subst replay; StatementSplit/AST plus whole-fragment versus physical-line Validation probes; policy donor hashes, memory, histories, Knowledge, book and all doctrines.
  Canonical trigger: Parent .86.3; this diagnostic/decomposition slice changes no runtime or contract.
  Acceptance: Preserve reproducible source and independently observed owners; define bounded repairs with compatibility requirements and no false completion of the parent.
  Verification: Public replay reproduces the existing multiline and EOF failures and valid division/regex controls. StatementSplit splits rx = /(x) LF y/ into separate statements; Mode recognizes Perl-prefixed/match-operator slash quoting but not naked DSL literals. Whole-fragment edge scanning ends at depth0 for the literal while physical-line scanning remains at depth1; the numeric division control has the opposite whole/line result. Therefore replacing all line scans with naive whole-source slash scanning would regress division. Fact card perl-multiline-regex-scanner-boundaries retains exact commands. Supplied README/claim/containment donor hashes match the recorded September11 identities; .5/.29 retain adoption ownership. No production fix or new backend acceptance is claimed. The first hook attempt rejected the 8,000-line task limit; remove only 64 blank separators between nodes and prove every nonblank line unchanged before rerunning.
  Commit: This commit; subject `SESSION-STARTUP-READING.86.4.1 - isolate Perl multiline regex scanner failures`.
- ID: `SESSION-STARTUP-READING.86.4.2`
  Status: `done`
  Goal: Reconcile the proposed naked-regex splitter repair against the actual action-language contract.
  Children: `SESSION-STARTUP-READING.86.4.2.1`, `SESSION-STARTUP-READING.86.4.2.2`, `SESSION-STARTUP-READING.86.4.2.3`, `SESSION-STARTUP-READING.86.4.2.4`
  Dependencies: .86.4.1; director's .86.4.2.4 contract audit supersedes the inferred regex-variable requirement.
  Acceptance: Preserve supported regex helper operands and division; distinguish host compatibility from portable value kinds. Do not infer a new regex type from parser acceptance.
  Verification: .86.4.2.4 establishes no portable regex-value contract. Its multiline matches operand lowers and independently executes to1, but public validation fails; .86.4.3 owns that actual defect. The assignment-only splitter expansion and director precedence question are superseded without implementation. Both rejected patches remain evidence, not fixes; earlier partial Phase0 runs remain excluded.
  Commit: Parent reconciled by .86.4.2.4; no splitter change accepted.

- ID: `SESSION-STARTUP-READING.86.4.2.1`
  Status: `done`
  Goal: Establish complete continuation compatibility and resolve whether multiline regex recognition requires a precedence decision.
  Dependencies: Restored clean .86.4.5 checkpoint at 4872ff3d56dd3442bd45ea397a6c7719d66b5d05; resumed director PNT instruction.
  Verification tier: `focused`
  Focused checks: Managed call_spec_handler_subst and public LinkedSpec::Get/runtime_ctx_ref against isolated exact accepted source and the candidate; action AST RED/GREEN and expanded compatibility counterexamples; archived candidate reconstruction, restored source identity/action AST, memory, Knowledge, histories and doctrines.
  Canonical trigger: None for this behavior-free diagnosis and recovery checkpoint; no candidate implementation is accepted.
  Acceptance: Reproducible source, generated code and public values establish the ambiguity; preserve rejected experiments without landing source/tests, own the decision and repair, and leave no verification job or dirty runtime file.
  Verification: Baseline RED fails3/27 groups; the original candidate with expanded quote controls fails36 assertions in1/27 groups; the lexical-continuation candidate passes27/27 but regresses seven expanded compatibility controls. Two public Get and independent action results are7 on accepted source and empty string on the candidate, with no last_error. The new patch reconstructs all four candidate files byte-for-byte; restored source/tests match clean HEAD and action AST passes23/23. Supplied-policy hashes remain unchanged. Memory, Knowledge, histories, rendered book, diff and all normal doctrines are required before landing. No Phase0/full-CI or runtime-repair claim.
  Commit: This commit; subject `SESSION-STARTUP-READING.86.4.2.1 - expose slash precedence conflict before repair`.
- ID: `SESSION-STARTUP-READING.86.4.2.2`
  Status: `superseded`
  Goal: Historical request for a Perl division-versus-regex precedence choice.
  Dependencies: Replaced by the director-requested contract audit .86.4.2.4.
  Acceptance: Withdraw the question because successful host parsing does not establish a supported regex-variable feature; preserve measured evidence without imposing an unsupported language decision.
  Verification: .86.4.2.4 reconciles the four binding kinds and actual helper-operand contract. No precedence authorization is requested or inferred.
  Commit: none - superseded without implementation by .86.4.2.4.

- ID: `SESSION-STARTUP-READING.86.4.2.3`
  Status: `superseded`
  Goal: Historical splitter expansion for assignment-position multiline regex syntax.
  Dependencies: Replaced by .86.4.2.4 scope correction and supported-operand validation repair .86.4.3.
  Acceptance: Do not make assignment to a reusable regex object an acceptance requirement. Preserve source-qualified host compatibility evidence and all existing division behavior.
  Verification: No accepted production change; the documented multiline matches operand already lowers correctly and returns1 independently. Its public validator failure remains .86.4.3-owned.
  Commit: none - superseded without implementation by .86.4.2.4.

- ID: `SESSION-STARTUP-READING.86.4.2.4`
  Status: `done`
  Goal: Audit whether action regex syntax is a documented pattern operand, a first-class runtime kind, or host compatibility before treating the earlier precedence question as a language decision.
  Dependencies: Director request to check mdBook and codebase at clean 7c318569d6f103416bc5dcc6d0fb825b472a86db; no new runtime type or precedence authorization is inferred.
  Verification tier: `focused`
  Focused checks: Canonical value/binding contract and mdBook helper signatures; LinkedSpec::Get/runtime_ctx_ref, call_spec_handler_subst and typed AST probes; first-party parser/evaluator kinds across backends; managed direct-dependent proof, book, memory, Knowledge, histories and doctrines.
  Canonical trigger: None for a read-only behavior audit and correction of teaching/task scope; implementation and contract changes remain separately owned.
  Acceptance: Separate syntax AST tags from runtime value kinds; retain positive helper examples, prove observed scalar/assignment behavior, correct unsupported implications in earlier guidance and own any actual defect.
  Verification: Thirteen Perl public/independent action cases plus the AST probe distinguish supported helper operands from scalar host assignment. The multiline matches operand lowers/executes to1 but fails public validation; .86.4.3 owns it. Five first-party evaluator representations agree with the absence of a governed regex value kind, without claiming full runtime parity. Focused AST/binding/callable suite passes45 top-level tests; four retained-native Rust controls verify revised book examples and scalar patterns; mdBook renders. Direct filter_match and callable matches gaps are owned by .87.1/.87.2. Normal governance checks apply before landing; no runtime change, full-CI claim or push.
  Commit: This commit; subject `SESSION-STARTUP-READING.86.4.2.4 - distinguish regex operands from runtime types`.
- ID: `SESSION-STARTUP-READING.86.4.5`
  Status: `done`
  Goal: Archive the unaccepted .86.4.2 candidate and restore a clean, paused handoff at director request.
  Dependencies: Preserve all candidate bytes and reproducible blocker evidence before restoring accepted source/tests.
  Verification tier: `focused`
  Focused checks: Exact four-file patch reconstruction and source identity; restored action AST target; memory, Knowledge, both history-pressure checks, all doctrines and diff review.
  Canonical trigger: None for this recovery-only archive; .86.3 retains runtime acceptance ownership and push requires canonical proof.
  Acceptance: Commit a recoverable candidate and honest paused pointers; retain .86.4.2 open, no runtime repair or full Phase0 pass claimed, no background job or dirty file left.
  Verification: Exact four-file patch reconstruction matches the saved candidate byte-for-byte; restored source/test identity matches 69689bb41; restored action AST passes23/23. Memory, Knowledge, both histories, diff and all normal doctrine hooks are required before landing. Both interrupted Phase0 runs remain excluded. Public book limitations remain accurate because runtime behavior is unchanged.
  Commit: This commit; subject `SESSION-STARTUP-READING.86.4.5 - preserve paused splitter repair and clean handoff`.
- ID: `SESSION-STARTUP-READING.86.4.3`
  Status: `done`
  Goal: Preserve multiline regex helper-operand lexical state through Perl whole-spec validation.
  Dependencies: .86.4.2.4 audit; matches_multiline in its tracked diagnostic lowers/executes to1 but public validation rejects the following Done rule. Reuse supported operand context without adding a runtime regex kind or imposing assignment regex precedence.
  Verification tier: `focused`
  Focused checks: Public Get/runtime_ctx_ref and descriptors/source; all captured literals/division controls, LF/CRLF, rule-like and directive-like regex payloads, real following rules, lifecycle/action nesting and malformed sources; validation fuzz, gap/slot contracts and Phase0; book, Knowledge, memory/history and doctrines.
  Canonical trigger: .86.3 after public recomposition; no shared contract change in this leaf.
  Acceptance: Retain original source positions and diagnostics, validate actual structure and metadata, and preserve division-newline acceptance; do not broadly hide malformed source or conflate .54.1/.9 bootstrap brace defects.
  Verification: Six-group consumer replay on isolated accepted fd3a2444e Perl/spec sources fails groups1/2/3/5/6; candidate passes6/6. Direct-dependent validation fuzz, gap/duplicate/sparse slots and action AST pass with173 total top-level tests across six files. LF/CRLF, structural-looking payloads, malformed followers, helper/lifecycle values, division and isolated host compatibility, escaped delimiters and exact physical diagnostic attribution are covered. Book renders and memory/Knowledge/history checks pass. Complete Phase0 passes1033/1033 in1211 seconds, including the exact six-group consumer; the earlier interrupted run is excluded. Expanded matrix lowering failures are owned by .86.4.6, required before .86.4.4; no broad helper-family acceptance.
  Commit: This commit; subject `SESSION-STARTUP-READING.86.4.3 - preserve multiline helper pattern validation`.
  - [x] **REPRODUCE / ISSUE** — Public Get/runtime_ctx_ref and call_spec_handler_subst replay the multiline matches validator failure; accepted-source six-group consumer fails five groups.
  - [x] **ROOT CAUSE (WHY + WHERE)** — Validation::_scan_rule_edges_in_fragment loses slash state between lines; y/ consumes closers as translation. A second public validator probe reports line3 instead of real line7 because index finds identical pattern payload first.
  - [x] **FIX** — Shared character-position-preserving helper-pattern structural view plus cumulative diagnostic line offsets; compilation retains authored source and existing slash-call recognition.
  - [x] **ADDRESSED (verified)** — Candidate consumer passes6/6 and focused selected suite passes173 top-level tests; actual lowering gaps stay separately owned.
  - [x] **NO REGRESSION** — Complete Phase0 reaches1..1033, all PASS; focused173 and Perl syntax pass. No new failing names; interrupted runs do not count. Normal staged doctrines are required before commit.
  - [x] **LOCKSTEP** — Book renders; Knowledge, task/roadmap/live pointers and bounded histories record the verified validator and immediate .86.4.6 lowering repair. No whole helper-family or cross-backend closeout.
- ID: `SESSION-STARTUP-READING.86.4.4`
  Status: `done`
  Goal: Recompose the Perl multiline regex repair through public live and standalone generated parsers and close .86.4.
  Children: `.86.4.4.1`, `.86.4.4.2`
  Dependencies: Verified .86.4.2/.86.4.3/.86.4.6/.86.4.7; .86.4.4.2 also requires .86.4.8.
  Planned tier: focused.
  Planned focused proof: Full captured public matrix plus exact pattern/runtime results, public loader, descriptors, independent emitted execution, permanent direct execution of integration-book examples, directly affected Perl gates and documentation/doctrine checks.
  Planned canonical boundary: Parent .86.3.
  Acceptance: Close only the measured Perl multiline scope after all required child repairs pass; preserve the invalid regex negative control and open EOF/brace owners with reproducible evidence.
  Verification: Verified under .86.4.4.2.2: helper13/grouped22/numeric12/original12 retain all59 exact public outcomes and the syntax record; source bytes and error stages are preserved. Production/tests and four book sources match9f81d3162, retaining focused173/book66 and both mutation proofs. Checkpoint syntax and book render pass. Close only measured ordinary-helper work; .87/.2.4/.34/.54.1/.9 and immediate .86.5 retain their defects. Parent .86.3 remains canonical.
  Commit: `SESSION-STARTUP-READING.86.4.4.2.2 - verify public helper and book recomposition`

- ID: `SESSION-STARTUP-READING.86.4.4.1`
  Status: `done`
  Goal: Intake grouped-pattern punctuation failures exposed by public recomposition and own the required repair.
  Verification tier: `focused`
  Focused checks: Tracked 22-case public/splitter/lowered diagnostic, discriminator result, string-pattern twins and retained helper/division audits; unchanged source/test and book-example identities, rendered book, Knowledge/memory/history/doctrine checks.
  Canonical trigger: Parent .86.3 after the repair and public recomposition; no runtime or shared-contract change in this intake.
  Acceptance: Preserve exact reproducer and root cause; make .86.4.8 mandatory before .86.4.4.2, qualify public limitations and retain all numeric compatibility boundaries. No helper-family closeout.
  Verification: Public Get rejects four bare grouped-dot/comma cases at validate_dsl_syntax while eighteen nearby/string/binding controls return exact values. The shared MethodExpr discriminator returns numeric-call true at dot/comma after the first balanced group; validation, statement splitting, CSV and AST regex recognition consume that predicate. Independent checking of the tracked diagnostic verifies all22 unique cases, the four failures/eighteen exact positives, and CSV arity3 only for the bare comma cases. Original helper audit retains its known .87 failures and both division controls return7. Source/tests match9e2c26b1c; all three complete book sources remain byte-identical to its verified16 assertions. Book renders; normal Knowledge/memory/history/doctrine checks govern landing.
  Commit: This commit; subject `SESSION-STARTUP-READING.86.4.4.1 - own grouped regex operand repair`.
  - [x] **REPRODUCE / ISSUE** — Tracked22-case public/lowered/splitter/CSV probe establishes four bare grouped-dot/comma failures and eighteen exact controls.
  - [x] **ROOT CAUSE (WHY + WHERE)** — Shared MethodExpr numeric-call predicate accepts dot/comma after the first balanced group; comma becomes argument3 and continuation statements remain joined.
  - [x] **FIX** — Required implementation owner .86.4.8 precedes .86.4.4.2; this intake does not claim a production repair.
  - [x] **ADDRESSED (verified)** — Reproducer, causal record, working string-pattern alternatives and immediate repair dependency are durable.
  - [x] **NO REGRESSION** — Production/tests match verified9e2c26b1c; helper/division public controls and exact book-source identity are retained. No fresh full Phase0 or canonical claim.
  - [x] **LOCKSTEP** — Rendered book states the measured limitation and string alternative; all current pointers select .86.4.8.
- ID: `SESSION-STARTUP-READING.86.4.4.2`
  Status: `done`
  Goal: Complete public multiline helper recomposition and close .86.4.4/.86.4 after all required repairs.
  Dependencies: .86.4.4.1 and verified .86.4.8, plus .86.4.3/.86.4.6/.86.4.7.
  Children: `.86.4.4.2.1`, `.86.4.4.2.2`
  Planned tier: focused.
  Planned focused proof: Original helper/division/invalid-regex audit plus grouped punctuation; public SpecLoader and independent generated execution; permanent direct execution of all four book examples; relevant Perl contracts and all documentation/doctrines.
  Planned canonical boundary: Parent .86.3 after .86.5.
  Acceptance: Preserve exact values, source/descriptor/error channels and numeric compatibility; close only the measured helper scope, retaining .87/.2.4/EOF owners and no regex runtime type.
  Verification: Verified under .86.4.4.2.2: helper13/grouped22/numeric12/original12 retain all59 exact public outcomes and the syntax record; source bytes and error stages are preserved. Production/tests and four book sources match9f81d3162, retaining focused173/book66 and both mutation proofs. Checkpoint syntax and book render pass. Close only measured ordinary-helper work; .87/.2.4/.34/.54.1/.9 and immediate .86.5 retain their defects. Parent .86.3 remains canonical.
  Commit: `SESSION-STARTUP-READING.86.4.4.2.2 - verify public helper and book recomposition`


- ID: `SESSION-STARTUP-READING.86.4.4.2.1`
  Status: `done`
  Goal: Load the emitted parser's tracing dependency explicitly and execute the exact book examples in fresh processes.
  Dependencies: Verified .86.4.8.2 at af168d2fe; .86.4.4.2 fresh-process diagnosis.
  Verification tier: `focused`
  Focused checks: Public generated-source structured errors, four exact Markdown examples through SpecLoader/descriptors/fresh processes, generated contracts and trace consumers, isolated changed-value/missing-example mutations, syntax, book, memory/Knowledge/history/doctrines.
  Canonical trigger: Parent .86.3 remains the exact public acceptance boundary; no generated-format or runtime contract change.
  Acceptance: Generated plain Execute loads its own required Trace module without caller preloading; retain v2 metadata, authored identities, exact values and trace behavior. Missing or changed examples must fail recurrence.
  Verification: All four cold-process baseline probes fail execute_generated/generated_execution_failed at trace_generated_handler_branch. Adding the explicit emitted Trace import repairs all four; exact book subtest66 and focused9-file/173 tests pass (163 seconds). The changed-result mutation fails only live/generated value assertions; missing-example mutation fails the source count. Final result-object guard replay passes generated7/book66 and the same two mutations. Syntax, unchanged generated contract and both rendered book chapters pass. Forty-eight mutable-ledger blank separators were removed with exact nonblank/order preservation. No new full Phase0 or canonical result is claimed.
  Commit: `SESSION-STARTUP-READING.86.4.4.2.1 - load tracing in fresh generated parsers`

  - [x] **ROOT CAUSE** — Plain emitted handlers require Trace; only the traced entrypoint loaded it.
  - [x] **ISSUE** — Four fresh processes expose the structured failure hidden by prior same-process imports.
  - [x] **FIX** — The generated preamble loads its own Trace dependency explicitly.
  - [x] **ADDRESSED** — Exact Markdown sources pass public loader/descriptors and fresh generated values/metadata.
  - [x] **NO REGRESSION** — Focused173, generated-contract/syntax and both intended-failure mutations pass.
  - [x] **LOCKSTEP** — Book66 recurrence and rendered guidance share authored examples; current records select .86.4.4.2.2.

- ID: `SESSION-STARTUP-READING.86.4.4.2.2`
  Status: `done`
  Goal: Finish public helper recomposition after verified cold-process bootstrap and close .86.4.4.2/.86.4.4/.86.4.
  Dependencies: Verified .86.4.4.2.1 plus the .86.4 helper repairs.
  Verification tier: `focused`
  Focused checks: Original helper/grouped/numeric/malformed controls, public loader/descriptors and exact book/fresh-process recurrence; documentation, Knowledge, histories and doctrines.
  Canonical trigger: Parent .86.3 after .86.5; no broad helper-family or cross-backend claim.
  Acceptance: Reconcile the measured helper scope and preserved rejection with explicit .87/.2.4/.34/EOF/brace owners, then select .86.5.
  Verification: Verified under .86.4.4.2.2: helper13/grouped22/numeric12/original12 retain all59 exact public outcomes and the syntax record; source bytes and error stages are preserved. Production/tests and four book sources match9f81d3162, retaining focused173/book66 and both mutation proofs. Checkpoint syntax and book render pass. Close only measured ordinary-helper work; .87/.2.4/.34/.54.1/.9 and immediate .86.5 retain their defects. Parent .86.3 remains canonical.
  Commit: `SESSION-STARTUP-READING.86.4.4.2.2 - verify public helper and book recomposition`

  - [x] **ROOT CAUSE** — Prior validation/splitting/grouped/Trace owners are verified by their exact public consumers.
  - [x] **ISSUE** — Original malformed and EOF cases remain distinguished from supported helper patterns.
  - [x] **FIX** — All required helper-chain repairs are committed; this leaf closes their bounded recomposition.
  - [x] **ADDRESSED** — All59 public controls and four unchanged executable book sources reconcile.
  - [x] **NO REGRESSION** — Numeric values, source bytes and malformed diagnostics remain exact; verified173/book66 evidence is source-identical.
  - [x] **LOCKSTEP** — Book, Knowledge, roadmaps and live pointers agree on ordinary-helper scope and immediate EOF repair.

- ID: `SESSION-STARTUP-READING.86.4.6`
  Status: `done`
  Goal: Preserve helper regex operands, including multiline patterns, through statement splitting and lowering after whole-spec validation.
  Dependencies: Land .86.4.3 first; supported operands only, no assignment-position regex type or global precedence change.
  Verification tier: `focused`
  Focused checks: Public Get/runtime_ctx_ref, call_spec_handler_subst, StatementSplit/AST and generated source for regex_subst, matches assignment followed by a newline statement, and matches inside statement-form if; LF/CRLF, single-line/semicolon controls, malformed patterns and established division compatibility; Phase0 and direct dependent action tests.
  Canonical trigger: Parent .86.3; public recomposition .86.4.4 requires this repair first.
  Acceptance: Exact returned mutation/continuation/nested-control values and clean runtime error channels; no unlowered host helper calls or lost statement boundaries. Preserve original pattern bytes and once-only execution.
  Verification: Expanded .86.4.3 public matrix exposes regex_subst as an undefined host call, newline following matches as generated-handler compilation failure, and conditional matches as an undefined host call. Validation is independently accepted for these sources; isolated lowering reproduces the first two. StatementSplit::_split_action_ir_statements joins the following statement/endif into the helper fragment in all three probes. StatementSplit::Mode::maybe_enter_slash_quote recognizes host operators but not naked helper operands; the closing y/ opens a two-segment translation and consumes separators. Repair only argument context, preserving the rejected assignment-precedence boundary and adding permanent runtime regressions before closeout.
  Accepted proof: Exact final consumer fails groups5/7 against isolated committed d2af200325 and passes7/7 on the candidate; focused action/dependent suite passes52 top-level tests. Both old division controls independently/publicly return7. LF/CRLF, eight host-operator suffixes, punctuation, once-only mutation and independent emitted execution are covered. Both complete Markdown examples pass11 public/generated assertions and the book renders. Complete Phase0 passes1033/1033 in1545 seconds, including the exact seven-group consumer. Memory/Knowledge and both history-pressure checks pass; normal staged doctrines govern landing.
  Intake: Tracked docs/checkpoints/SESSION-STARTUP-READING.86.4.6.pl establishes physical quoted-subject structural failure for new .86.4.7 and escape-route differences for existing SUPPORTING-SOURCE-READING.2.4. Current regex tests use match_text() to isolate pattern boundaries; neither subject defect is hidden or claimed repaired.
  Commit: This commit; subject `SESSION-STARTUP-READING.86.4.6 - preserve regex helper statement boundaries`.
  - [x] **REPRODUCE / ISSUE** — Exact final consumer fails groups5/7 on isolated d2af200325; public and splitter probes identify joined statements.
  - [x] **ROOT CAUSE (WHY + WHERE)** — StatementSplit::Mode lacks naked helper operands; closing y/ opens translation mode and consumes separators/endif.
  - [x] **FIX** — Core recognizes argument-start slash patterns with the existing numeric-call discriminator; Mode preserves one-segment literal state.
  - [x] **ADDRESSED (verified)** — Focused52 includes LF/CRLF, eight suffixes, punctuation, mutation/continuation/conditional values and emitted execution.
  - [x] **NO REGRESSION** — Full Phase0 1033/1033, syntax and both original public/division controls pass; no assignment precedence change.
  - [x] **LOCKSTEP** — Both complete mdBook examples pass11 direct public/generated assertions; book renders; task/Knowledge/live/roadmap records retain owned subject defects.

- ID: `SESSION-STARTUP-READING.86.4.7`
  Status: `done`
  Goal: Preserve quoted multiline subjects through whole-spec structural validation alongside helper regex operands.
  Intake owner: .86.4.6 public regression expansion; repair before public recomposition .86.4.4.
  Dependencies: Land .86.4.6; keep string escape/value semantics with SUPPORTING-SOURCE-READING.2.4.
  Verification tier: `focused`
  Focused checks: Exact public, validation and lowered execution for both quote styles, LF/CRLF, syntax-looking payloads, following rules and real malformed structure; complete Phase0 and relevant validation/action tests, book examples and doctrines.
  Canonical trigger: Parent .86.3.
  Acceptance: Preserve original quoted bytes, positions and diagnostic ownership without concealing malformed source; prove live and independently emitted execution. No new string escape contract.
  Verification: .86.4.6 expanded public source with physical LF in both assigned subject and regex fails validate_dsl_syntax with Unexpected closing delimiter; isolated lowering executes to ok. Original .86.4.3 helper view skips whole quoted tokens, but downstream rule-edge scans restart quote state on each physical line. Reproduce with the tracked diagnostic before repair; do not count regex-subject fixture substitution as resolving this issue.
  Accepted proof: Exact final nine-group consumer fails groups8/9 on isolated committed36df52e46 and passes9/9 on the candidate. Focused validation/action/gap/slot/binding checks pass198 across eight files; three exact Markdown examples pass16 live/generated assertions and the book renders. The tracked diagnostic retains identical authored/lowered source, returns public ok for physical_subject and preserves all four escape-route records exactly. Complete Phase0 passes1033/1033 in1276 seconds and consumes all nine groups. Memory/Knowledge and both history checks pass (engineering notes below rollover, within warning band); normal staged doctrines govern landing.
  Commit: This commit; subject `SESSION-STARTUP-READING.86.4.7 - preserve multiline quoted subject validation`.
  - [x] **REPRODUCE / ISSUE** — Public/lowered tracked diagnostic and exact isolated36df52e46 replay fail groups8/9 while independent physical_subject lowering returns ok.
  - [x] **ROOT CAUSE (WHY + WHERE)** — Whole-source quote scanning skips token contents, but the physical-line rule-edge scanner still sees those bytes and restarts quote state.
  - [x] **FIX** — Mask complete multiline quoted tokens only within open expression scopes; retain original line endings/positions and compilation source.
  - [x] **ADDRESSED (verified)** — Both quote styles, LF/CRLF, leading/trailing newlines, return/helper/substitution/lifecycle values and four independently emitted cases pass.
  - [x] **NO REGRESSION** — Focused198 and complete Phase0 1033/1033 pass; real malformed source and line7 attribution remain; four escape-route diagnostic records stay byte-identical.
  - [x] **LOCKSTEP** — All three complete mdBook examples pass16 public/generated assertions, book renders, and Knowledge/task/roadmap/live records select .86.4.4.

- ID: `SESSION-STARTUP-READING.86.4.8`
  Status: `done`
  Goal: Reconcile grouped regex-operand punctuation while preserving accepted numeric/host compatibility.
  Children: `SESSION-STARTUP-READING.86.4.8.1`, `SESSION-STARTUP-READING.86.4.8.2`
  Dependencies: .86.4.4.1; no assignment-position regex precedence or runtime-type expansion.
  Acceptance: Supported grouped patterns retain one operand and execute exactly; accepted numeric interpretations and established malformed diagnostics survive. Public closeout .86.4.4.2 waits for verified .86.4.8.2.

- ID: `SESSION-STARTUP-READING.86.4.8.1`
  Status: `done`
  Goal: Preserve the rejected punctuation lookahead and exact numeric compatibility evidence before replacing it.
  Verification tier: `focused`
  Focused checks: Exact12-case public/AST/lowered replay on clean f3f9fc74 and the candidate; archived patch reconstruction; restored production/test identity; existing nine-group consumer; unchanged book-source identities, rendered book, memory/Knowledge/history/doctrine checks.
  Canonical trigger: None for restored-source diagnostic intake; implementation .86.4.8.2 requires full Phase0 and parent .86.3 remains canonical.
  Acceptance: Preserve working numeric, raw-host, quote and receiver outcomes; own the compatible implementation as mandatory .86.4.8.2. No repair acceptance or new precedence decision.
  Verification: Exact12-case authored-source pairs expose accepted array(/(14,2),14/cos) changing [7,14] to [] and a hidden numeric runtime failure, despite all22 earlier punctuation cases passing. Archived patch reconstructs exactly; production/tests match f3f9fc74. Restored nine-group consumer passes; tracked replay, exact book-source identity/rendering, memory/history checks and normal hooks govern landing.
  Commit: `SESSION-STARTUP-READING.86.4.8.1 - preserve grouped operand compatibility evidence`

- ID: `SESSION-STARTUP-READING.86.4.8.2`
  Status: `done`
  Goal: Repair grouped operands using consistent grammar/context recognition across validation, CSV, AST and splitting.
  Dependencies: .86.4.8.1 exact compatibility checkpoint; .86.4.4.1 punctuation checkpoint and .86.4.3/.6/.7 protections.
  Verification tier: `focused`
  Scope constraint: No language or host-compatibility removal is authorized.
  Focused checks: Both permanent diagnostics; grouped dot/comma and flags/quoted payloads, literal/string/binding twins, LF/CRLF, return/continuation/nested/generated routes; numeric calls followed by quotes, receiver chains, comments and host expressions; accepted values and rejected-source diagnostics; direct-dependent action/validation contracts and full Phase0.
  Canonical trigger: Parent .86.3; .86.4.4.2 waits for this repair.
  Acceptance: Fix the measured operand failures without counting a raw_perl AST fallback as a rejected numeric interpretation. A complete-looking slash token alone is insufficient. Preserve [7,14] in the host-cos counterexample, [7,"a/)"] and [8,"a/)"] quote/chain controls, numeric failures and existing assignment boundaries. Quoted regex payload parsing remains included, not parked.
  Verification: Exact baseline completes11 groups and fails only new group10; candidate passes11 groups and focused187 across8 files. Both permanent diagnostics verify repaired grouped patterns and byte-identical nine numeric/error records. All four book sources pass21 live/generated assertions; book renders. Complete final Phase0 passes1033/1033 (Files=1, Tests=1033, 1423 wallclock secs ( 0.44 usr  0.10 sys + 1086.49 cusr 125.81 csys = 1212.84 CPU)); frozen source/test diff a60c6c2d is unchanged. Earlier interrupted run is excluded. Six separate comment probes extend existing .34.1 ownership. Memory/history/Knowledge and normal doctrine hooks govern landing.
  Commit: `SESSION-STARTUP-READING.86.4.8.2 - preserve grouped regex helper operands`

  - [x] **ROOT CAUSE** — Grouped regex punctuation was classified as numeric-call or outer CSV/method syntax.
  - [x] **ISSUE** — Exact public probes and baseline RED isolate grouped helper failure while preserving numeric/raw-host controls.
  - [x] **FIX** — Shared helper context preserves operand roles, source spans, receiver lowering and quoted-return recognition.
  - [x] **ADDRESSED** — Literal/string/binding, LF/CRLF, flags, quoted payload, nested/indexed and generated routes pass.
  - [x] **NO REGRESSION** — Numeric compatibility records are byte-identical; focused187 and final Phase0 1033/1033 pass.
  - [x] **LOCKSTEP** — Four exact book examples pass21 assertions; book/current docs and remaining defect owners agree.

- ID: `SESSION-STARTUP-READING.86.5`
  Status: `done`
  Goal: Reconcile Perl slash-call termination at the end of an outer action block.
  Dependencies: Land .86.2 and .86.4; retained slash_eof/slash_eof_space plus named and semicolon controls; preserve the explicit closing-brace exclusion in the existing regex discriminator.
  Children: `SESSION-STARTUP-READING.86.5.1`, `SESSION-STARTUP-READING.86.5.2`, `SESSION-STARTUP-READING.86.5.3`
  Planned tier: focused.
  Planned focused proof: Public Get/runtime context, isolated lowering, complete outer source and generated execution; bare/spaced slash EOF, semicolon/named twins, escaped and closing-brace regex controls, nested and malformed contexts; phase0 and direct scanner tests.
  Planned canonical boundary: Parent .86.3; no broadened delimiter precedence without prior contract reconciliation.
  Acceptance: Fix end-of-block division rejection without stealing regex syntax. Use the established final-statement separator contract, retain source/diagnostics and malformed rejection, and synchronize integration/book guidance. Resolve a genuine contract ambiguity with the director before code.
  Verification: Children .86.5.1/.86.5.2/.86.5.3 verify line-ending and same-line slash calls plus required slot metadata. Final focused240/book103, six-runtime grammar72 and Phase0 1033 pass. Full-source regex-first precedence remains; .27/.54.1/.34/.87 retain independent repairs. Exact canonical parent .86.3 follows.
  Commit: Verified children .86.5.1, .86.5.2.1, .86.5.2.2 and .86.5.3; canonical closure remains .86.3.


- ID: `SESSION-STARTUP-READING.86.5.1`
  Status: `done`
  Goal: Recognize a bare final slash call before only physical-line-ending block closers.
  Dependencies: .86.5 fixed context diagnosis and verified helper chain; preserve shared MethodExpr precedence.
  Verification tier: `focused`
  Focused checks: Bare/spaced/compact EOF plus named/semicolon/receiver twins, lifecycle/edge/nested and LF/CRLF, complete/escaped/host regex and malformed controls, original public diagnostics, emitted execution, action/validation dependents and full Phase0.
  Canonical trigger: Parent .86.3; .86.5.2 retains same-line following-member repair before parent closure.
  Acceptance: Let outer validation count the true closing braces without changing authored bytes or shared regex-vs-division classification. Complete helper literals and explicit host quote operators remain protected. Do not claim following-member or bootstrap-brace repair.
  Verification: Outer structural depth recognizes only a complete bare slash call followed by line-ending braces; shared MethodExpr precedence and source bytes stay unchanged. Accepted full-source regex interpretations win; only a failed source with a final-call candidate retries. Only the selected attempt publishes diagnostics. Focused9 files/206 and five exact book sources/82 assertions pass. Clean fe516141b baseline completes13 groups and fails only new groups12/13. Fixed15 contexts and original12 change only their bare/spaced EOF outcomes to7; helper13+syntax/grouped22/numeric12 remain exact. Full Phase0 passes1033/1033; frozen source/test diff SHA25691821cd09b9991ce975862b4c83a62b0c899badb8c02fd62a8ed9dd8f89188d5. Syntax and final book render pass. Same-line members stay .86.5.2; numeric callable/grouping are .87.3/.87.4-owned.
  Commit: `SESSION-STARTUP-READING.86.5.1 - validate final line-ending slash calls`
  Artifact hygiene: Removed only the consumed baseline snapshot after112 files/2326149 bytes matched clean fe516141b Git blobs plus the frozen consumer; no symlinks/unknown files and no residue. Rust release/deps have no .bin/.log hits; incremental retains859 .bin/3161569687 bytes as reusable cache, with no .log hits. Removed the interrupted PID88109 PathSearch fixture only after its bytes matched specs/Lispish.spec; no residue. Retain proof logs; final Phase0 is verified and consumed.

  - [x] **ROOT CAUSE** — Both outer scanners consume the real closer after a numeric slash call because the shared regex guard excludes braces.
  - [x] **ISSUE** — Bare/spaced EOF sources fail Get while named/semicolon/receiver controls work.
  - [x] **FIX** — Recognize bounded final-call candidates after full-source regex validation fails; preserve accepted regexes and publish only selected diagnostics.
  - [x] **ADDRESSED** — Live/emitted LF/CRLF and nested forms return7; exact book82 and full Phase0 1033/1033 pass.
  - [x] **NO REGRESSION** — Helper/grouped/numeric records and malformed diagnostics remain exact; complete/host regex routes stay protected.
  - [x] **LOCKSTEP** — Executable book example, accurate restrictions, Knowledge, roadmaps and live owners agree; .86.5.2 is next.

- ID: `SESSION-STARTUP-READING.86.5.2`
  Status: `done`
  Goal: Repair final slash calls followed by same-line rule members, then continue required slot metadata repair .86.5.3 before .86.5 closes.
  Dependencies: Verified .86.5.1; .86.5-contexts next_member/quoted-slash controls and existing accepted regex interpretations.
  Children: `SESSION-STARTUP-READING.86.5.2.1`, `SESSION-STARTUP-READING.86.5.2.2`
  Planned tier: focused.
  Planned focused proof: Lifecycle/action boundaries followed by regexes/lifecycle blocks, original complete-regex compatibility and malformed diagnostics; full affected scanner/validation/generated proof, book and final parent reconciliation.
  Planned canonical boundary: .86.3 after complete .86.5; retain accepted interpretations and do not infer raw-host invalidity.
  Acceptance: Identify actual outer member boundaries without borrowing their slash delimiters into the final arithmetic call or stealing complete regex syntax. Keep independent .87/.54/.34 owners distinct.
  Verification: .86.5.2.1 proves explicit return carriers; .86.5.2.2 verifies same-line slash recognition with focused207/book84 and Phase0 1033. Required independent slot metadata .86.5.3 follows before parent/canonical closure.
  Commit: Children .86.5.2.1 and .86.5.2.2 preserve the complete bounded repair.

- ID: `SESSION-STARTUP-READING.86.5.2.1`
  Status: `done`
  Goal: Make the executable division example prove an explicit action return instead of Perl lifecycle value leakage.
  Dependencies: Verified .86.5.1; .86.5.2 named/semicolon intake; existing perl-lifecycle-final-value-e-drift and .27 ownership.
  Verification tier: `focused`
  Focused checks: Public Get/descriptor/generated-source probes with distinct I/E/edge values; exact Markdown live/fresh-generated assertions and final-call consumer on an explicit edge; syntax, book and doctrines.
  Canonical trigger: Parent .86.3 after .86.5.2.2; this leaf corrects example/test carriers without changing production or the lifecycle contract.
  Acceptance: Show the actual return path with a result different from I's final assignment and a mismatching-input control. Preserve .27 as the lifecycle repair owner; do not claim new E execution.
  Verification: Public/Get and emitted-source diagnosis proves omitted E: old I/regex/E returns7 for x and y despite E{return(42)}; generated source contains only I. Corrected explicit edge returns8 for x and undef/no-error for y. Focused5 files/31 pass; five exact book sources/84 pass. Isolated old-fixture mutation finishes7 groups and fails only book group7. First four sources are unchanged; production matches917b4a42a. Book render and permanent checkpoint pass. .27 retains lifecycle repair; .86.5.2.2 is next; no new Phase0/canonical claim.
  Commit: `SESSION-STARTUP-READING.86.5.2.1 - prove explicit book example returns`
  - [x] **ROOT CAUSE** — Existing .27 omits E in the direct-rule shape and leaks I's final assignment.
  - [x] **ISSUE** — Returning7 alone made the newly published division example a weak execution-path proof.
  - [x] **FIX** — Use an explicit edge with distinct result8 and unmatched-input controls in the book and final-call matrix.
  - [x] **ADDRESSED** — Public/fresh-generated book84 and focused31 pass; restoring the old fixture fails only the expected book group.
  - [x] **NO REGRESSION** — Production and first four book sources are unchanged; all thirteen consumer groups and generated trace dependents pass.
  - [x] **LOCKSTEP** — Book, recurring tests, Knowledge, .27 ownership and live pointers agree; scanner repair resumes under .86.5.2.2.

- ID: `SESSION-STARTUP-READING.86.5.2.2`
  Status: `done`
  Goal: Repair same-line slash-call member boundaries using explicit return carriers; .86.5.3 must follow before .86.5 closes.
  Dependencies: Verified .86.5.2.1, original same-line controls, complete regex compatibility and named-slot contract reconciliation.
  Verification tier: `focused`
  Focused checks: Named/semicolon/bare same-line twins, explicit action results and errors, accepted regex/multiline precedence, emitted execution, direct validator/diagnostic dependents and full Phase0.
  Canonical trigger: Parent .86.3 after completed .86.5; any contract ambiguity precedes implementation.
  Acceptance: Recognize final arithmetic calls before subsequent admitted members without changing established regex precedence; retain independent .27/.54/.34 and named-slot owners.
  Verification: Recognize the balanced slash-call end before an outer brace and following members, retaining full-source regex-first trial selection. Focused9 files/207, exact book84 and rendering pass. Clean fb955602e finishes14 groups and fails only new group14. Exactly8 bare-slash rows in the30-case intake now match named controls; other22 are exact. Original12/helper13+syntax/grouped22/numeric12/multiline5 stay exact. Context15 changes only intended next_member/quoted-slash public outcomes; private fragment scans do not select the full-source interpretation. Slot5 stays exact and required .86.5.3-owned. Full Phase0 passes1033/1033 at frozen diff86881406bf815024ee8c7cf00482ce547ebae315a6165fd350cfe9d258b05a92. No canonical or push claim.
  Commit: `SESSION-STARTUP-READING.86.5.2.2 - validate same-line slash call members`

  - [x] **ROOT CAUSE** — Final slash classification borrowed a later member delimiter and hid the real block closer.
  - [x] **ISSUE** — Bare slash same-line forms failed while named/semicolon twins were accepted.
  - [x] **FIX** — Recognize the balanced call before its closer within the existing regex-first trial.
  - [x] **ADDRESSED** — LF/CRLF live/emitted explicit returns, exact book84 and Phase0 1033 pass.
  - [x] **NO REGRESSION** — Established helper/numeric/multiline outcomes and diagnostic owners remain exact.
  - [x] **LOCKSTEP** — Book, Knowledge and live pointers reflect repaired slash calls and required slot repair .86.5.3.

- ID: `SESSION-STARTUP-READING.86.5.3`
  Status: `done`
  Goal: Preserve regex-slot declarations and identities across same-line rule-body members on Perl.
  Dependencies: Verified .86.5.2.2; permanent .86.5.3 public selector/descriptor controls; ADR0045 and the governed named/anonymous slot contract.
  Scope: Reconcile validation, permanent specs/spec.spec named-declaration grammar and its BootstrapSpec bridge before claiming parsed slot identity; both baseline grammar patterns anchored to the entire physical line.
    Required shield: same-line bare lifecycle blocks are admitted by ADR0094, but the baseline permanent grammar recognized only whole-line bare blocks. The compact bare-assignment control exposes its payload as a false named slot; repair this grammar boundary in the same slice before accepting relaxed declarations.
  Verification tier: `focused`
  Focused checks: Separate/same-line named and anonymous slots before/after lifecycle items, explicit numeric/named selectors, authored order and descriptor identity, malformed/duplicate/source-position controls, actual live/emitted results, metadata dependents, permanent/bridge grammar recurrence, exact corpus mirrors and full Phase0.
  Canonical trigger: Required before .86.5 and canonical .86.3 closure; no new declaration or selector grammar.
  Matrix boundary: The first native grammar run preserves all slot identities but Rust adds source_form=explicit to a same-line final E. Six public current/baseline controls establish the pre-existing .63 input-suffix anchor defect; the lifecycle_block_line branch wins after the cursor despite no physical line start. Preserve that exact failing source under .63, and put E between named members for the common slot-focused matrix rather than normalizing away its extra field. No .63 repair or broad AST parity is claimed here.
  Required portability repair: The revised matrix passes Perl/Rust6x2, then all Dart cases fail. Public loader/engine diagnosis succeeds on the clean grammar and throws FormatException/Invalid group on the candidate bare-block pattern. Dart's exact shipped-pattern bridge recognizes only the old whole-line spelling. Synchronize that first-party bridge with the unchanged permanent grammar, preserving old matching and exact cursor/physical-line alternatives, captures and spans; add current-grammar recurrence and attempt Dart's local gate. The frozen Perl/spec/test hash retains its Phase0 proof only while those files stay exact; any change to them requires final Phase0 again.
  Dart gate boundary: The two attempted complete runs reach exactly the already recorded .2.24 formatter and .2.25 SDK-interface blockers in docs/knowledge/dart-component-gate-sdk-compatibility.md. The formatter's six unrelated edits have identical canonical AST/literal source and are restored to clean HEAD. Run the original remaining test/storage/CLI/corpus stages independently; preserve strict analyzer severity and both repair owners, with no full Dart-gate or SDK-migration claim for this bounded existing-pattern repair.
  Acceptance: Recognize admitted regex members outside code across a physical line without counting action/helper patterns. Preserve exact names/order, numeric/name provenance and diagnostics. Keep lifecycle execution .27 and regex-brace .54.1 separate.
  Verification: Focused checks pass 240 tests across 11 files; six exact book sources pass 103 assertions. Clean4ca4f745e finishes 111 metadata groups and fails only new group4. Fourteen LF/CRLF layouts preserve names/order, selectors, source, live/generated values and permanent grammar nodes; bare payloads remain exact. Typed/Unicode/comment/code/unsupported-tail controls and gap/slot/bare neutral checks pass; four grammar mirrors remain exact. Six slot-focused CLI grammar cases pass on Perl, Rust, Dart, Julia, PUC Lua and LuaJIT in both environments (72 case legs). The unchanged final-E projection defect has a permanent .63 regression and public qualification. Dart exact shipped-pattern recognition now preserves cursor/physical-line semantics, captures, suffixes and three carriers. Focused Dart20 and independent remaining stages pass502 tests/storage25owners47packages/CLI66x2/corpus105. Complete Dart gate attempts remain failed at existing .2.24/.2.25 formatter/SDK blockers; six unrelated formatter edits are restored exactly, without suppression. The72 grammar legs compose retained Perl/Rust passes and fresh Dart/Julia/PUC/LuaJIT passes; neither stopped full-driver attempt is reported green. All 120 final checkpoint records match the preceding candidate after the last bare-block shield; the first five book sources are unchanged. Full Phase0 passes 1033/1033 at frozen diff a80c914626100ac1fbe7c7448a42547574d7adfbc7ec0de8da4aadef88394a32. Book rendering and syntax pass. .86.5 closes its bounded implementation; .86.3 canonical remains pending.
  Commit: `SESSION-STARTUP-READING.86.5.3 - preserve same-line regex slot identity`

  - [x] **ROOT CAUSE** — Whole-line/leading-only metadata and grammar anchors omit adjacent members.
  - [x] **ISSUE** — Public named/numeric selectors reject valid same-line declarations; relaxed grammar also requires bare-code shielding.
  - [x] **FIX** — Observe rule-level slots in the structural scan, preserve typed validation, align permanent/bootstrap member recognition and synchronize Dart exact-pattern recognition.
  - [x] **ADDRESSED** — Live/generated selection, exact metadata, six-runtime grammar72 and Phase0 1033 pass.
  - [x] **NO REGRESSION** — Existing controls, diagnostics, Unicode identity and code/comment exclusions remain covered.
  - [x] **LOCKSTEP** — Six executable Markdown sources, formal grammar, Knowledge and current roadmap/task pointers agree.

- ID: `SESSION-STARTUP-READING.87`
  Status: `pending`
  Goal: Repair existing Perl helper-execution gaps and reconcile grouped-expression lowering, without adding a regex value type.
  Children: `SESSION-STARTUP-READING.87.1`, `SESSION-STARTUP-READING.87.2`, `SESSION-STARTUP-READING.87.3`, `SESSION-STARTUP-READING.87.4`
  Dependencies: .86.4.2.4 public/lowered diagnostic and docs/knowledge/action-regex-operands-and-runtime-kinds.md. Separate from scanner .86; keep that current activity first.
- ID: `SESSION-STARTUP-READING.87.1`
  Status: `pending`
  Goal: Make documented function-position filter_match return its transformed array on Perl.
  Planned tier: focused.
  Planned focused proof: Public/lowered/emitted direct, nested, receiver and statement forms; named/shape/computed arrays, string/literal patterns, once-only evaluation and nonmutation in value position; direct-dependent pipeline tests and book.
  Planned canonical boundary: Final repair-group acceptance/push; broaden if shared contract changes.
  Acceptance: Repair filter_match(["ax","by"], /^a/) falling through as an undefined host function; retain the working receiver form. Reconcile the full affected lowering path before changing it; coordinate FUTURE-PARITY-BACKLOG.5's broader pipeline normalization.
  Verification: .86.4.2.4 public and independent lowered execution fail; receiver returns ["ax"]. MethodLowering's receiver route synthesizes __array_value_filter_match, while the failing direct form remains an unlowered host call. The book promises pure function composition.
  Commit: `pending`
- ID: `SESSION-STARTUP-READING.87.2`
  Status: `pending`
  Goal: Execute the existing matches helper in Perl callable codeblock bodies with string and literal pattern operands.
  Planned tier: focused.
  Planned focused proof: Direct-action versus callable controls; parameter/caller string patterns, literal operand context, exact booleans, scope restoration and failure diagnostics, independently emitted invocation and callable suite.
  Planned canonical boundary: Final repair-group acceptance/push; no new value kind or regex transport contract.
  Acceptance: Repair the missing CodeblockRuntime helper dispatch and operand evaluation together. Preserve static-helper precedence, parameter restoration and typed unsupported-call errors for genuinely unsupported calls.
  Verification: .86.4.2.4 literal operand fails unsupported_codeblock_actionir; string twin fails unknown_helper. CodeblockRuntime::_eval_expr lacks regex operand handling and _eval_call lacks matches; existing finite callable fixtures do not cover this helper.
  Commit: `pending`


- ID: `SESSION-STARTUP-READING.87.3`
  Status: `pending`
  Goal: Execute admitted numeric helpers and symbol aliases inside Perl callable bodies.
  Dependencies: .86.5 public context checkpoint; scalar-numeric and callable contracts; keep current scanner .86 first.
  Planned tier: focused.
  Planned focused proof: Ordinary/callable named/symbol arithmetic, parameter restoration and static precedence, exact numeric/error behavior, fresh emitted invocation and callable/numeric consumers.
  Planned canonical boundary: Repair-group acceptance/push; no new arithmetic or callable contract.
  Acceptance: Repair div(14,2) and /(14,2) callable bodies rejecting unknown_helper; preserve the numeric contract and genuine unknown-call diagnostics.
  Verification: .86.5-contexts nested_named_callable and nested_callable both fail rule_handler_eval with unknown_helper while direct named/receiver arithmetic returns7. CodeblockRuntime::_eval_call has no numeric route and falls through to the caller binding lookup.
  Commit: `pending`
- ID: `SESSION-STARTUP-READING.87.4`
  Status: `pending`
  Goal: Reconcile Perl parenthesized expression handling with the authored-expression contract.
  Dependencies: .86.5-contexts parenthesized/named controls; formal action grammar, AST and value-lowering contracts before implementation.
  Planned tier: focused unless a new grouping contract is required.
  Planned focused proof: Grouped versus direct named/symbol expressions, public AST/lowered/error probes and malformed controls; fix admitted shapes and add direct/generated recurrence.
  Planned canonical boundary: Any contract expansion requires prior decision; routine supported-shape repair uses final repair-group acceptance.
  Acceptance: Determine grouping's supported boundary from canonical records, then repair admitted composition or provide accurate explicit syntax diagnostics. Do not mistake raw-host fallback for validated DSL support or widen grammar from a failing probe alone.
  Verification: out=(/(14,2)) reaches rule_handler_compile/Search pattern not terminated; out=(div(14,2)) reaches rule_handler_eval/undefined host div. Both validate structurally; direct named and receiver controls return7. These are distinct from .86.5 outer validation and remain owned for contract reconciliation and repair.
  Additional boundary: .50/.88 retain (keys)[0] as an unlowered Perl grouped-postfix control with rule_handler_compile/too few arguments for keys; direct keys[0] succeeds. Reconcile its admitted grammar before any expansion; do not advertise the Rust-only grouped control as portable.
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.88`
  Status: `done`
  Goal: Reconcile and repair the Rust indexed-value read discrepancy exposed by .50's hash-key controls.
  Dependencies: Root-cause with public controls during .50; finish and commit .50 before any separate runtime implementation.
  Activation: Clean 4631568ab596943ffb2a1a685f7e84b0cbe0afc2; .50 committed after all focused proof and nine doctrines, post-pointer PASS, brief0 and no pending job.
  Verification tier: `focused`
  Focused checks: Plain binding, direct index, grouped receiver, spaced/compact hash keys, alternate binding names and aggregate controls; exact AST/value/error comparisons with Perl, native/reconstructed/generated/emitted recurrence and affected runtime suites; pure-read contract intake and public claim checks.
  Canonical trigger: Final repair-group acceptance/push; preserve the existing typed-binding and direct-access contracts.
  Acceptance: Locate the loss independently of hash colon tokenization, restore admitted reads without reviving retired aggregate selectors, and synchronize public guidance. Keep the correct expected value; do not bless the observed empty key.
  Verification: Fresh public RED12 wrong values/5 controls becomes Perl17/Rust17 exact GREEN; three unit regression groups fail before repair and the full runtime unit182 passes afterward. Selected hash-key1, indexed18x2 carrier1, integration197 and uniform-binding16 pass (397 total with units). Independently emitted book1 and Perl shared book26 pass; render/exact code blocks, binding-neutral11/7/6/8, formatting and memory pass. Exact commands, source/log/binary identities and scope: docs/checkpoints/SESSION-STARTUP-READING.88-verification.json and .88-indexed-read-repair.json. The initial seven-case diagnostic checkpoint remains retained; grouped Perl access stays .87.4-owned. The pre-main unit wait was sampled and remains .81-owned, then all182 tests completed.
  Commit: `SESSION-STARTUP-READING.88 - read indexed values from current typed bindings`
  - [x] **REPRODUCE / ISSUE** — Public CLI trace and Perl Get/call_spec_handler_subst isolate12 wrong Rust values among17 controls; three regression groups fail on the separately identified pre-fix unit binary.
  - [x] **ROOT CAUSE (WHY + WHERE)** — Engine::eval_expr IndexedVar used get_array, bypassing set_scalar-held typed arrays and exposing stale private storage; nested/bare controls use get_bare_value.
  - [x] **FIX** — Resolve the current typed binding with the existing array_index_value helper, retaining index-expression timing and numeric conversion; missing/wrong-kind reads remain undefined without creating state.
  - [x] **ADDRESSED (verified)** — Exact public17 values, native/reconstructed/generated18x2 and independently emitted shared book source pass; current bindings and detached snapshots replace former null/empty-key results.
  - [x] **NO REGRESSION** — Full runtime unit182 plus selected integration215 pass; uniform selector policy remains intact. Perl production is unchanged; shared book26 and binding-neutral checks pass. Full canonical proof remains designated-boundary work.
  - [x] **LOCKSTEP** — Book includes the tested indexed-read fixture; Knowledge/checkpoints, roadmap/task/live pointers and chronology record the repair and required sequence containment .16, Perl read-purity .89, then .51.

- ID: `SESSION-STARTUP-READING.89`
  Status: `done`
  Goal: Restore pure Perl direct reads under the existing write-only creation contract; retain each observed receiver during selector effects; close misleading read-exclusion evidence and public claims.
  Dependencies: Finish .88 and containment .16 cleanly; prioritize this confirmed contract defect before .51. ADR0036/write_vivification_contract.json is unchanged authority.
  Verification tier: `focused`
  Focused checks: Public Get/call_spec_handler_subst RED/GREEN, absent/null roots and missing/null intermediates, existing/wrong-kind controls, dynamic index order and same-binding effects, native/function/independently emitted source, exact neutral read exclusions, affected Perl suites and complete Phase0, executed book example/rendering and ordinary doctrines/history/diff checks.
  Canonical trigger: Escalate for any governed contract/gate/format change; otherwise final clean push boundary.
  Acceptance: Reads return the admitted value without changing binding presence, container shape or identity; repair raw-host autovivification without weakening write semantics or expected results. Audit current runtime read-exclusion coverage, then give its repair explicit scope before changing gates.
  Evidence: .88 probes six public sources; five Perl reads create arrays/fields or replace null despite no handler errors, while Rust preserves all six expected states. The baseline ValueExpr.pm::_lower_direct_nested_access_value_expr emitted raw Perl dereferences. Checkpoint .89-read-purity.json and Knowledge card perl-direct-read-autovivification-gap retain sources, lowering and values; this is a contract defect, not a new feature proposal.
  Activation: Clean 5e72c32b0f185783a8b6b597561e1470ce03c8f7 after containment .16.2 canonical PASS (CLI66x2, Phase01033), normal hooks, promoted receipt, brief0 and consumed jobs. Scoped roadmap, ValueExpr/callers/BindingRuntime, neutral contract, direct-dependent tests and read-purity book sections reviewed; next measure unchanged selector timing before choosing the repair.
  Book scope: Replace the confirmed read-purity limitation with executed native/fresh-source examples after repair; reconcile the adjacent stale single-index-write rollout sentence with its already-admitted five-backend contract. Qualify the separately owned function constructor .90 until its own repair lands.
  Coverage scope at intake: t/write_vivification_perl_contract.t did not execute the three frozen read_exclusion_cases. Extend its runtime proof under this leaf without changing neutral expectations or gate infrastructure. The Python neutral model is not Perl runtime evidence.
  Lowering ownership: Public trace selects MethodLowering's typed-AST direct-access closure; ValueExpr is a separate compact-source path. A ValueExpr-only patch left all public failures unchanged. Both now delegate to one guarded emitter, with the existing lazy OwnerDispatch/error boundary. The original intake's sole-owner attribution was incomplete and is corrected in the Knowledge card.
  Next defect: Function return array(document, observed) exposes literal identifier names because the aggregate argument bridge preserves function-local bare names before the multi-argument constructor can lower them. .90 owns that independent repair immediately after .89 and before .51. The .89 function read test uses the equivalent array literal to isolate read state; the original failing constructor source/results remain .90 intake evidence.
  Composition finding: Existing numeric reducer direct-access rejection is now .91-owned after .90 and before .51. Public Subst plus explicitly pinned baseline owners distinguish the existing source-shape guard from this read repair; update the adjacent numeric book contract accordingly.
  Selector diagnosis: Public Get and independently emitted parsers return null when a selector rebinds its sole-owned receiver, but old2/old1 when an otherwise unused reference retains that same receiver. call_spec_handler_subst plus compiled host operation traces place receiver access before selector execution. A raw eval probe inadvertently retained the old value in its case array. Checkpoint .89-selector-lifetime.json and Knowledge card perl-direct-read-selector-lifetime own the causal controls. Retain a guarded read cursor so unrelated reference retention cannot change the selected value; preserve selector order/count on valid or missing paths and explicit rebindings; wrong-kind reads now evaluate normally and yield null instead of a raw host exception. No portable cross-backend selector-order contract is added.
  Verification: Public six-case replay repairs five mutations and preserves the existing-container control. Final native/fresh-source and neutral suites pass20 top-level groups, including25 direct cases twice per route, functions, selector events/failures, identity and the exact LF/CRLF book source. Seven selected suites compose89 passing groups; affected Phase0 selection passes23 groups plus discovery, and the complete required Phase0 passes1033/1033. Neutral105, public mutation50, storage24, exact book rendering/source/result and syntax checks pass. Checkpoint .89-verification.json retains all logs, rejected attempts, hashes and scope; all nine staged doctrines and both history-pressure checks pass, including memory/pointer, task, storage, Knowledge and cadence gates; staged diff hygiene passes.
  Full Phase0: Files=1, Tests=1033, 1723 wallclock secs ( 0.44 usr  0.09 sys + 1108.17 cusr 187.53 csys = 1296.23 CPU)
  Commit: `SESSION-STARTUP-READING.89 - preserve state in Perl direct reads`

  - [x] **REPRODUCE / ISSUE** — LinkedSpec::Get and call_spec_handler_subst expose state creation in five of six original cases; fresh generated parsers expose receiver-retention dependence. Original neutral consumer omitted all three read exclusions.
  - [x] **ROOT CAUSE (WHY + WHERE)** — MethodLowering's typed-AST closure and ValueExpr's compact path concatenated raw host dereferences. Public trace disproves the initial ValueExpr-only attribution; retained-alias controls isolate receiver lifetime loss.
  - [x] **FIX** — Both callers share hygienic guarded rvalue emission, retaining the base/each receiver and evaluating selectors once. Missing/null/wrong-kind paths yield undef without state creation; authored effects remain. Write semantics and format authorities are unchanged.
  - [x] **ADDRESSED (verified)** — Native and fresh emitted recurrence, exact public replay, presence/state/reference-identity controls, selector errors and independently executed book source pass. Wrong-kind reads no longer raise a raw host dereference exception.
  - [x] **NO REGRESSION** — All selected direct-dependent suites and complete Phase0 pass; neutral write105, public mutation50 and unchanged Perl storage24 pass. Earlier stopped regression runs and the incomplete subset harness are not acceptance evidence.
  - [x] **LOCKSTEP** — Six book pages, one included executable fixture, Knowledge cards/checkpoints, current roadmap/task/live pointers and bounded chronology agree. Function constructor .90 is next, then numeric reducer .91 before .51; no global book/zero-defect or new push claim.

- ID: `SESSION-STARTUP-READING.90`
  Status: `done`
  Goal: Fix Perl multi-argument array constructors inside user functions returning identifier spellings instead of current values.
  Dependencies: Finish and commit .89 first; this newly confirmed public value defect precedes .51. Preserve the typed aggregate-helper binding interpretation and retired one-argument selector diagnostics.
  Verification tier: `focused`
  Focused checks: Public Get/call_spec_handler_subst/emitted-source RED/GREEN; function parameters and locals, repeated calls, array literal twins, mixed/nested arguments, actual aggregate helpers and exact retirement controls; generated-source, uniform-binding, variadic-function, AST and method-lowering trace suites; complete Phase0, book render, all doctrines, Knowledge Map and bounded histories.
  Canonical trigger: Any governed contract/format/gate/storage movement or cross-cutting uncertainty; final clean push. This bounded Perl repair preserves these authorities.
  Activation: Clean 83ab2ff44219379bcf1e2c46d432ba936b750580, empty commit brief, no live proof jobs. Targeted reading covers the roadmap function/value contract, registered function parameters/local scope, AST aggregate/value dispatch, existing native/generated tests and affected public examples. No whole-repository signoff is claimed.
  Director clarification: In .spec codeblocks, newlines separate statements; a line-ending semicolon is optional and valid, while one between separate statements on the same physical line is required. The book Statement separators section is canonical; the new executable example omits optional line-ending semicolons and retains required same-line separators in controls. This is not a prohibition on optional semicolons.
  Acceptance: array(value, value) reads the same values as [value, value] inside functions; no bare host words, no scope leakage, and no regression to aggregate-helper typed receiver interpretation.
  Evidence: .89's function read probe emits [document, observed] while those lexicals are declared with sigils. Public Get returns literal names and no handler error; standalone source does the same. MethodLowering's lower_ast_aggregate_call_node assigns function-local argument names before its multi-argument array branch can lower them, then emits those raw names. Knowledge/checkpoint perl-function-array-constructor-bare-values retains the independent no-read control.
  Verification: Final constructor tests fail only their new ninth group against explicitly loaded clean 83ab2ff44 MethodLowering and pass 9/9 against the candidate. Native and fresh generated routes each run the 16-case matrix and exact LF/CRLF book example twice. Initial numeric sum control failed independently on baseline and candidate and is now .91 intake; count/first/count_keys/copy controls remain in this matrix. Six selected suites pass 118 top-level results; complete Phase0 passes 1033/1033; checkpoint .90-verification.json retains exact observations, hashes, commands and scope.
  Commit: `SESSION-STARTUP-READING.90 - read function array constructor values`

  Full Phase0: Files=1, Tests=1033, 2452 wallclock secs ( 0.45 usr  0.09 sys + 1130.36 cusr 247.93 csys = 1378.83 CPU); Result: PASS.
  - [x] **REPRODUCE / ISSUE** — LinkedSpec::Get/source dump and fresh emitted source expose literal identifier strings; a local named local emits host syntax failure. The exact final test suite against the explicitly loaded clean activation owner fails only new group9.
  - [x] **ROOT CAUSE (WHY + WHERE)** — MethodLowering's lower_ast_aggregate_call_node preserves function-local argument names for aggregate helpers before constructor value lowering, then emits those names directly into a host array.
  - [x] **FIX** — Exclude multi-argument array constructors from that name-preserving branch; the existing AST value lowerer emits lexical reads. Actual helper lookup and one-identifier selector rejection are unchanged.
  - [x] **ADDRESSED (verified)** — Native and fresh generated matrix plus exact LF/CRLF included book source pass twice per parser. The final old/new failing-group set changes only constructor group9; ordinary rule call_spec_handler_subst also retains typed value reads.
  - [x] **NO REGRESSION** — Six focused suites (118 results), complete Phase0 (1033/1033), unchanged storage (24 owners), selector source inventory, 50 public mutations and syntax pass. Function-parameter numeric rejection is baseline-proved, preserved as failing intake under next .91 and excluded from constructor acceptance.
  - [x] **LOCKSTEP** — Five book pages and the directly included example, optional-semicolon wording, Knowledge/checkpoint records, task/roadmap/live pointers and bounded chronology agree. Final staged doctrines/history/memory/diff checks govern landing. No global book signoff or push claim.

- ID: `SESSION-STARTUP-READING.91`
  Status: `pending`
  Goal: Repair Perl numeric reducers rejecting direct-access expressions that yield arrays.
  Dependencies: Finish .89 and .90 cleanly, then this confirmed value-composition defect before .51. Preserve wrong-kind/empty/nonnumeric policy and selector single evaluation.
  Planned tier: focused for a bounded Perl lowering correction; canonical for any governed contract/format movement.
  Planned focused proof: Public Get/call_spec_handler_subst and fresh emitted RED/GREEN; sum/num_sum/direct receiver, literal and bound twins, missing/wrong-kind arrays, function values and helper compositions; audit other reducer arms before choosing a safe implementation scope; complete Phase0 and executed book examples.
  Planned canonical boundary: Any governed contract/format/gate movement and final clean push.
  Acceptance: A direct read yielding [3,1,2] is consumed as the same array value as its literal/binding twin, without an unsupported-helper sentinel or duplicate selector evaluation.
  Evidence: .89 compatibility probes show sum(document["items"]), num_sum(document["items"]) and document["items"].sum() return null on both the current candidate and an isolated, explicitly loaded pair of activation-commit MethodLowering/ValueExpr owners; the literal and explicit sorted-chain twins return6, while assigning the direct read to a binding before sum also returns null. Public call_spec_handler_subst emits LINKEDSPEC_UNSUPPORTED_ACTIONIR_HELPER:num_sum. MethodLowering's num_sum arm rejects sources through FlowExpr::_looks_like_array_value_expr before its value lowering; that spelling classifier does not admit direct access. Count, array/scalar chains, hash count, branch and append controls remain correct; the missing-path fallback changes only by the intended .89 purity repair.
  Verification: Confirmed intake and causal lowering evidence, not repair acceptance. Checkpoint .91-numeric-direct-read.json and Knowledge card perl-numeric-reducer-direct-read-rejection retain sources, values, loaded baseline identity, and the distinction from an initial invalid library-precedence attempt. No production change for .91 in the .89 slice.
  Additional .90 intake: fn total(items) { return(sum(items)) } with [3,1,2] returns null and emits LINKEDSPEC_UNSUPPORTED_ACTIONIR_HELPER:num_sum on both explicitly loaded clean 83ab2ff44 MethodLowering and the .90 candidate. No handler error; exact source and owner identity are preserved in .90 verification evidence. Include function parameters in the reducer repair; this independent baseline failure is excluded from the constructor acceptance matrix, whose count/first/count_keys/copy controls remain required.
  Commit: `pending`

- ID: `SESSION-STARTUP-READING.92`
  Status: `pending`
  Goal: Make Phase0's real legacy PathSearch fallback verification independent of repository build/cache tree size while preserving genuine fallback coverage.
  Dependencies: Finish .90 and .91 cleanly; this confirmed verification-cost defect precedes .51. Do not weaken the required complete Phase0 gate or delete retained build caches.
  Planned tier: canonical if verification/storage infrastructure changes; select the actual tier at activation under ADR0073.
  Planned focused proof: Read the legacy contract and complete fallback consumer, then use a bounded repository-local fixture with the real public resolver/PathSearch behavior; prove actual fallback, single call, success/miss diagnostics, isolation from existing cache/state, cleanup and an adversarial large excluded tree. Measure cold discovery separately from parser work. Own any remaining production discovery issue explicitly without silently changing compatibility.
  Planned canonical boundary: Test/storage infrastructure or public resolution-policy movement; final clean push.
  Acceptance: Ordinary Phase0 fallback coverage does not recursively enumerate unrelated build/cache/dependency storage, remains representative of the legacy API, and leaves no fixture or process behind. The portable SpecLoader contract is unchanged.
  Evidence: During .90's unmodified full Phase0 run, process37696 retains its exact PID-owned fallback fixture. A one-second read-only sample at22m40s finds all83 main-thread samples in stat/lstat; lsof reports cwd rust/target/debug/deps. The fallback subtest calls LinkedSpec::get_parser after creating t/tmp_phase1_pathsearch/phase1_pathsearch_fallback_37696.spec; PathSearch::go initializes its process-wide search list with unpruned File::Find over the repository root. No dependency implementation was inspected and no live fixture/cache was removed. Knowledge card phase0-legacy-pathsearch-generated-tree-scan and .90 checkpoint retain bounded evidence.
  Verification: Intake confirms a real verification-cost coupling, not a constructor regression or portable SpecLoader defect. The same uninterrupted .90 run subsequently passes 1033/1033 in 2452 seconds; that establishes .90 acceptance, not .92 implementation.
  Commit: `pending`
