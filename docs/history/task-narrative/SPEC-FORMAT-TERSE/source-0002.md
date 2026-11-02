- ID: `SPEC-FORMAT-TERSE.14.1`
  Status: `done` (2026-07-07)
  Goal: Activate and split the trailing block-argument backlog item before implementation.
  Acceptance: The task tree defines the MVP block-argument contract, first callable surface, sequencing, diagnostics,
    and verification expectations before parser/runtime code changes.
  Verification: **PASS 2026-07-07.** Repo was clean before pivoting. Read-only scans identified
    `SPEC-FORMAT-TERSE.14` as the non-closed trailing block/code-block owner. Existing Perl/Rust expression parsers
    already have expression-valued `block_value` / `CodeBlock` concepts, and Rust already models attached
    `while(cond) { ... }` as a call whose final arg is a `BlockValue`; however, general helper/receiver trailing
    block-argument syntax and an explicit non-control invocation surface are not yet shipped. `.14.1` defines the
    MVP as follows:
    `with(value) { ... }` is the first helper-function form block-taking surface; it evaluates `value`, binds the scoped
    scalar context variable `value` for the immediate block execution, restores any prior `value` binding after the
    block, and returns the block result. `return(expr)` inside the block is block-local and returns from the block,
    not from the surrounding rule. `with() { ... }` binds `value` to `undef`. Bare `with { ... }` remains deferred
    because word-plus-brace can be a rule-body lifecycle/code-block form today. Receiver `.with() { ... }` is split
    after helper-function form parity; it binds receiver value as `value` and must preserve receiver-chain behavior. Block
    args must be final-only; inline `{ ... }` as an ordinary parenthesized argument remains the pre-existing
    expression-valued block form and is not the new trailing syntax. Diagnostics must reject non-final trailing
    block use, unknown block-taking callees, and attempts to treat block args as assignable/returnable closure
    values. mdBook documentation is required once behavior ships. Closeout checks pass:
    `bash scripts/check_memory_architecture.sh`, `bash knowledge-map/scripts/check_knowledge_map.sh`,
    `bash scripts/check_doctrines.sh`, and `git diff --check`.
  Commit: `SPEC-FORMAT-TERSE.14.1 - activate trailing block-argument plan`

- ID: `SPEC-FORMAT-TERSE.14.2`
  Status: `done` (2026-07-07)
  Goal: Implement Perl reference helper-function form trailing block arguments for `with(value) { ... }`.
  Acceptance: Perl ActionIR parsing/lowering recognizes `with(value) { ... }` and `with() { ... }` as a helper call
    with a final block argument, lowers it without raw fallback, binds/restores the scoped `value` context variable,
    keeps block-local return semantics, and preserves hash-literal parsing. Focused parser/lowering/runtime tests
    prove `with("x") { return(cat(value, "!")) }` returns `"x!"`, `with() { return(is_undefined(value)) }` returns
    true, and `{ key : value }` remains a hash literal.
  Verification: **PASS 2026-07-07.** `perl/LinkedSpec/ActionIR/AST/Parser.pm` now parses a top-level trailing
    brace after a `callee(...)` head as a flagged final `block_value` argument (`trailing_block_arg`), while attached
    control-flow parsing still owns `if`/`when`/`switch`/`while`. `perl/LinkedSpec/ActionIR/MethodLowering.pm`
    accepts that flagged trailing block only for helper-function form `with`; it evaluates the optional value arg through the
    existing value lowerer, binds a lexical scoped `value` inside an immediate `do { ... }`, reuses the existing
    expression-valued block lowerer for block-local `return(expr)`, and emits the normal unsupported-helper sentinel
    for unknown trailing-block callees. `with() { ... }` binds `value` to `undef`. The slice also added narrow AST
    value lowering for `is_defined(...)` / `is_undefined(...)` so the zero-arg `with()` proof lowers without raw
    fallback. Public mdBook text now documents this as current Perl reference behavior while marking Rust parity,
    bare `with { ... }`, and receiver `.with() { ... }` as follow-ons. Focused probes show
    `return(with("x") { return(cat(value,"!")) })` lowers to a scoped `do` block, `return(with() { return(is_undefined(value)) })`
    lowers through `undef` binding plus `(!defined($value))`, `return({ key : value })` still lowers as a hash
    literal, and `return(unknown("x") { return(value) })` emits
    `LINKEDSPEC_UNSUPPORTED_ACTIONIR_HELPER:unknown`. Checks pass: `perl -c -Iperl` on the touched Perl modules and
    focused tests, `prove -q -Iperl t/actionir_ast_parser.t`, and full `PERL5LIB= prove -q -Iperl
    t/phase0_regression.t` with plan `1..1025`. Closeout checks pass: `mdbook build docs/linkedspec-book`,
    `bash scripts/check_memory_architecture.sh`, `bash knowledge-map/scripts/check_knowledge_map.sh`,
    `bash scripts/check_doctrines.sh`, and `git diff --check`.
  Commit: `SPEC-FORMAT-TERSE.14.2 - add Perl helper trailing blocks`

- ID: `SPEC-FORMAT-TERSE.14.3`
  Status: `done` (completed 2026-07-07)
  Goal: Implement Rust helper-function form parity for `with(value) { ... }`.
  Acceptance: Rust parser/runtime recognizes the same helper-function form trailing block syntax and semantics as the Perl
    reference, including scoped `value` binding/restoration, block-local return behavior, zero-arg `with()`, and
    hash-literal boundary preservation. Add a generated oracle fixture and focused Rust parser/runtime tests.
  Verification: Done — 2026-07-07. Rust `expr` parser now appends a trailing `BlockValue` argument only for
    helper-function form `with(...) { ... }`; validation recognizes `with`; runtime dispatch treats `with` as lazy, evaluates
    the optional value argument before block execution, binds scoped `value`, restores the prior same-name scalar,
    array, hash, bare-kind, and descriptor-read state afterward, and reuses expression-valued block return
    semantics. Focused parser tests lock accepted `with`, hash-literal payloads, and non-`with` rejection. Focused
    runtime tests lock `with("x") { return(cat(value, "!")) }`, `with() { return(is_undefined(value)) }`,
    restoration of an outer `value`, and hash literal payloads. The generated oracle fixture
    `terse_14_3_with_helper_trailing_block` raises the Rust corpus to **94** fixtures and locks the canonical value
    `["inner!","outer","undef",{"stage":"ok"}]`.
    Checks: `cargo fmt --check`, `cargo test -p linkedspec-core trailing_block`,
    `cargo test -p linkedspec-runtime terse_14_3`, `perl tools/gen_oracle_corpus.pl`,
    `cargo test -p linkedspec-runtime oracle_corpus_matches_perl_reference`, `mdbook build docs/linkedspec-book`,
    `bash scripts/check_memory_architecture.sh`, `bash knowledge-map/scripts/check_knowledge_map.sh`,
    `bash scripts/check_doctrines.sh`, and `git diff --check` pass.
  Commit: `SPEC-FORMAT-TERSE.14.3 - add Rust helper trailing blocks`

- ID: `SPEC-FORMAT-TERSE.14.4`
  Status: `done` (completed 2026-07-07)
  Goal: Implement receiver-form trailing block arguments for `.with() { ... }` on compatible value receivers.
  Acceptance: Perl and Rust receiver chains accept a terminal or continuing `.with() { ... }` segment where the
    receiver value is exposed as scoped `value` inside the block. The returned block value feeds later compatible
    receiver-family links or acts as the terminal expression result. Non-final block arguments inside an ordinary
    argument list remain rejected/deferred.
  Verification: Done — 2026-07-07. Perl `ActionIR::AST::Parser` now parses receiver `.with() { ... }` as a fluent
    segment with a flagged final `block_value` argument and receiver-trailing-block metadata. Perl
    `ActionIR::MethodLowering` normalizes that receiver segment to the already-shipped helper-function form `with(receiver)
    { ... }` semantics, preserving scoped lexical `value`, block-local `return(expr)`, outer `value` restoration,
    and continuing receiver chains over the block result. Explicit receiver `.with(value) { ... }` emits the
    standard unsupported-helper sentinel and remains outside the shipped surface. Rust `expr` parsing accepts only
    zero-argument receiver `.with() { ... }`, renders it without putting the block inside the parentheses, and
    rejects explicit receiver args. Rust runtime dispatch detects chains containing receiver `with`, evaluates the
    receiver left-to-right, binds scoped `value`, restores the previous binding, then routes later links through the
    compatible string/array/hash/number receiver families. Focused tests lock terminal receiver blocks, string and
    array continuations, mid-chain receiver blocks, outer binding restoration, unsupported explicit receiver args,
    and no raw/unresolved Perl metadata. The generated oracle fixture
    `terse_14_4_receiver_with_trailing_block` raises the Rust corpus to **95** fixtures and locks
    `["inner!","outer","x !",2,1]`. Side finding recorded during fixture design: using `has_key(...)` as the
    final hash proof exposed an unrelated output-shape mismatch (`perl/LinkedSpec/ActionIR/MethodLowering.pm`
    lowers `has_key` to numeric `1`/`0`, while `rust/linkedspec-runtime/src/engine.rs` returns
    `RuntimeValue::Bool`). The `.14.4` fixture uses `count_keys()` instead so this receiver-block slice stays
    focused; the finding is durable here and in `DEVELOPMENT_NOTES.md` for later prioritization.
    Checks: `perl -c -Iperl perl/LinkedSpec/ActionIR/AST/Parser.pm`,
    `perl -c -Iperl perl/LinkedSpec/ActionIR/MethodLowering.pm`,
    `prove -q -Iperl t/actionir_ast_parser.t`, full
    `PERL5LIB= prove -q -Iperl t/phase0_regression.t` with plan `1..1026`,
    `cargo fmt --manifest-path rust/Cargo.toml --all`,
    `cargo test --manifest-path rust/Cargo.toml -p linkedspec-core trailing_block -- --nocapture`,
    `cargo test --manifest-path rust/Cargo.toml -p linkedspec-runtime terse_14_4 -- --nocapture`,
    `perl -c -Iperl tools/gen_oracle_corpus.pl`, `perl tools/gen_oracle_corpus.pl`, and
    `cargo test --quiet --manifest-path rust/Cargo.toml -p linkedspec-runtime
    oracle_corpus_matches_perl_reference` pass. Public mdBook, live docs, and Knowledge facts were updated in the
    same slice for no drift; `.14.5` remains the final closeout/sweep leaf.
  Commit: `SPEC-FORMAT-TERSE.14.4 - add receiver trailing blocks`

- ID: `SPEC-FORMAT-TERSE.14.5`
  Status: `done` (completed 2026-07-07)
  Goal: Close trailing block-argument docs, mdBook, Knowledge Map, oracle, and no-drift alignment.
  Acceptance: mdBook documents the shipped helper-function and receiver-method `with` block-argument surface with worked examples,
    explicitly states what remains deferred, active tests and generated oracle fixtures are current, Knowledge Map
    retrieval records the durable syntax/semantics fact, and roadmap/task-tree/live docs agree on `.14` status.
  Verification: Done — 2026-07-07. `ROADMAP_V2.md`, mdBook project status, the durable Knowledge fact, live docs,
    and this task tree now agree that the shipped `.14` surface is helper-function form
    `with(value) { ... }` / `with() { ... }` plus receiver-method form `.with() { ... }` on Perl and Rust. The
    explicit deferrals remain bare `with { ... }`, explicit receiver `.with(value) { ... }`, closures, delayed
    callbacks, assignable/returnable block values, and arbitrary non-`with` trailing blocks. The oracle generator
    still emits **95** fixtures after `terse_14_4_receiver_with_trailing_block`, and the Rust oracle corpus matches
    the Perl reference. Checks: focused stale-wording scans, `perl -c -Iperl tools/gen_oracle_corpus.pl`,
    `perl -Iperl tools/gen_oracle_corpus.pl`, `cargo test --manifest-path rust/Cargo.toml -p linkedspec-runtime
    oracle_corpus_matches_perl_reference`, `mdbook build docs/linkedspec-book`,
    `bash knowledge-map/scripts/gen_knowledge_map.sh`, `bash knowledge-map/scripts/check_knowledge_map.sh`,
    `bash scripts/check_memory_architecture.sh`, `bash scripts/check_doctrines.sh`, and `git diff --check` pass.
  Commit: `SPEC-FORMAT-TERSE.14.5 - close trailing block drift`; retained completion note: Final no-drift closeout for helper-function and receiver-method `with` trailing blocks; roadmap/mdBook/KM/live docs/task-tree/oracle agree and `.14` closes.

- ID: `SPEC-FORMAT-TERSE.15`
  Status: `done` (split 2026-07-05 by `.15.1`; RE-SEQUENCED 2026-07-05 to engine-first after the bare-read-gap
    finding; `.15.2.1` design + `.15.2.2` Perl bare-read done 2026-07-05; `.15.2.3` Rust parity done
    2026-07-06; `.15.2.4` source migration done 2026-07-06; `.15.3` Perl retirement done 2026-07-06;
    `.15.4` Rust retirement done 2026-07-06; `.15.5` no-drift closeout done 2026-07-06; frontier `.8`)
  Goal: Make `:name` fully unsupported (user directive 2026-07-05: `:name` shall NOT be supported). The `.15.1`
    audit assumed a source-first migration would be output-preserving, but bare reads are NOT yet honored in every
    value position at `104088e5` (proven: `switch(:kind)`->`good` vs `switch(kind)`->`def`; plus rule-name
    collisions in `spec.spec`/`ebnf.spec`). Order is therefore engine-first: `.15.2` completes bare-name value
    reads everywhere (Perl+Rust) and migrates sources, then `.15.3`/`.15.4` remove `:name` entirely, then `.15.5`
    closes drift.
  Children: `.15.1` (done), `.15.2` (done; split into `.15.2.1` design / `.15.2.2` Perl engine /
    `.15.2.3` Rust engine / `.15.2.4` source migration), `.15.3` (done — Perl `:name` removal),
    `.15.4` (done — Rust `:name` removal), `.15.5` (done — closeout).
  Acceptance: The duck-typed authoring surface uses bare names for variable and parameter reads in value-expression
    positions. `value` reads the current runtime typed value bound to `value`; `:value` is removed from current
    examples, mdBook guidance, generated oracle fixtures, active tests, and Knowledge Map current facts except
    where historical records explicitly discuss the old scalar-slot syntax. Bare names in hash-literal key position
    remain key tokens that stringify to hash keys, so the implementation must preserve a clear grammar/AST boundary
    between value reads and hash key spelling. Explicit typed views/guards use `array(value)` and `hash(value)`,
    not scalar-slot punctuation. Before implementation, the leaf must audit shipped specs, root corpus examples,
    parser/lowering paths, Rust runtime behavior, diagnostics, mdBook, and Knowledge Map facts for `:name` scalar
    references and split child work if the blast radius is larger than one safe slice.
  Verification: **PASS 2026-07-06.** Child leaves completed the engine-first migration/removal sequence. Current
    authored specs, generated corpus inputs, mdBook guidance, active tests, and non-historical Knowledge Map facts
    no longer depend on successful `:name` scalar slots; remaining colon references are rule modes, regex syntax,
    public API wording, retired-diagnostic tests/code, or explicitly historical fact records. Frontier advances to
    `.8`.
  Commit: `SPEC-FORMAT-TERSE.15.5 - close colon scalar-slot drift`

- ID: `SPEC-FORMAT-TERSE.15.1`
  Status: `done` (2026-07-05)
  Goal: Audit colon-prefixed scalar-slot usage and split safe implementation leaves before code.
  Acceptance: Inventory current `:name` use in shipped specs, root corpus examples, Rust oracle fixtures, active
    Perl/Rust tests, parser/lowering/runtime support, mdBook, and Knowledge Map facts. Split follow-on work if
    blast radius is larger than one safe slice.
  Verification: **PASS 2026-07-05.** `rg` scans show `:name`/`:value`/other colon scalar-slot forms across shipped
    specs (`specs/ebnf.spec`, `specs/lib_reader.spec`, `specs/vhdl.spec`, `specs/ds_vhistory.spec`,
    `specs/pplugin.spec`, `specs/spec.spec`, and others), root corpus examples, many Rust oracle fixtures
    (`ebnf_*`, `spec_spec_*`, `vhdl_library_use`, `lispish_x_y`, `terse_*`, and more), mdBook current guidance,
    Knowledge Map facts, `tools/gen_oracle_corpus.pl`, Perl trace/phase0 tests, Rust core/runtime tests, and
    parser/runtime code (`Expr::ScalarSlot`, Perl scalar-slot lowering/extraction). This is too large for one safe
    implementation slice, so `.15` is split into source/doc/corpus migration first, Perl removal second, Rust
    removal third, and a final no-drift closeout.
  Commit: `SPEC-FORMAT-TERSE.15.1 - split colon scalar-slot removal`; retained completion note: Audit/split only: `:name` removal spans specs, corpus, oracle fixtures, mdBook, Knowledge Map facts, tests, generator sources, and Perl/Rust parser/runtime support. Frontier becomes `.15.2` for current-facing migration.

- ID: `SPEC-FORMAT-TERSE.15.2`
  Status: `done` / `closed` (RE-SCOPED 2026-07-05 after the bare-read-gap finding; see Verification Log
    `2026-07-05 SPEC-FORMAT-TERSE.15.2 re-scope`)
  Goal: Complete bare-name value reads across ALL value positions on Perl + Rust so that `:name` becomes fully
    redundant, THEN migrate current authored sources to bare. This is the prerequisite the `.15.1` audit missed.
    At `104088e5`, bare identifiers are NOT read as the bound variable value in `switch(...)`, numeric callees
    (`num_lt(...)`/`num_gt(...)` etc.), `if(...)` conditions, or the second arg of all-bare `push(A, B)`; and in
    `spec.spec`/`ebnf.spec` a bare name that collides with a rule/token name resolves as a rule reference, not a
    variable read. `:name` only worked because it disambiguated variable-read from rule-reference. Per user
    directive 2026-07-05 (`:name` shall NOT be supported), the engine must make bare reads unambiguous FIRST, so
    a migrate-then-remove sequence never depends on `:name`.
  Policy (locked 2026-07-05): in a value-expression position a bare identifier is a variable/parameter read;
    rule references appear only in edge/dispatch positions (`-> Rule`, `call(Rule)`, `=> Rule`, and the all-bare
    child-call `push(RuleA, AccumB)` convention). Scalar push therefore uses `items += value` or
    `push(array(items), value)`, never a colon slot.
  Children: `.15.2.1` (design/inventory, DONE 2026-07-05), `.15.2.2` (Perl engine impl, DONE 2026-07-05),
    `.15.2.3` (Rust parity, DONE 2026-07-06), `.15.2.4` (source migration to bare, DONE 2026-07-06).
  Acceptance: bare reads produce byte-identical reference output to today's `:name` in every value position on
    Perl and Rust and the value-position-vs-edge policy is documented; then all current shipped specs, root
    corpus, generated oracle sources, mdBook examples, and non-historical Knowledge Map facts use bare reads with
    a byte-identical regenerated oracle corpus and green phase0.
  Verification: **PASS 2026-07-06.** The child leaves completed the engine-first sequence and final
    output-preserving migration. Full phase0 passes (`env PERL5LIB= perl -Iperl t/phase0_regression.t`, plan
    `1..1022`); regenerated Rust oracle corpus remains **93** fixtures with no expected JSON/manifest diff; Rust
    corpus oracle passes over all fixtures; mdBook builds; current-surface `:name` scan is clean except rule-mode
    labels, regex syntax, and historical literal strings. Frontier moves to `.15.3` for Perl `:name` removal.
  Commit: `SPEC-FORMAT-TERSE.15.2 - reorder .15 to engine-first (bare-read gap)`; prior node reference: `SPEC-FORMAT-TERSE.15.2.4 - migrate current sources to bare reads`; table label: `SPEC-FORMAT-TERSE.15.2 re-scope`; retained completion note: Recovery + finding: prior uncommitted mess preserved on `recovery/terse-15-uncommitted-20260705`; proved bare reads are not honored in all value positions at `104088e5`, so `.15.2` is re-sequenced engine-first (`.15.2.1`-`.15.2.4`) and `.15.3`/`.15.4` remove `:name` with no compat. No engine/source behavior changed. Frontier becomes `.15.2.1`.

- ID: `SPEC-FORMAT-TERSE.15.2.1`
  Status: `done` (2026-07-05)
  Goal: Inventory every value position where a bare identifier is NOT read as the bound variable today while
    `:name` is (Perl + Rust), and lock the value-position-is-variable-read policy and the edge/child-call
    rule-reference boundary before any engine code.
  Acceptance: A complete list of failing positions with reference-engine evidence (e.g. `switch(:kind)`->`good`
    vs `switch(kind)`->`def`), the collision cases in `spec.spec`/`ebnf.spec`, the Perl lowering seams
    (`ActionIR::MethodLowering`/`ValueExpr`/`FlowExpr`/`ControlFlow`) and Rust parser/runtime seams that must
    change, and the documented policy. No engine behavior changes in this leaf.
  Verification: **PASS 2026-07-05.** Ground truth taken with LinkedSpec's own `LinkedSpec::Get` probe (per
    `TOOLBOX.md`), using DISCRIMINATING values so a bare-fallback yields a different result than a real read.

    FAILING VALUE POSITIONS (bare != `:name` today) — confirmed on the Perl reference engine:
    1. `switch(...)` selector: `{ set(kind,"b"); switch(:kind){...case("b"){"good"}default{"def"}} }` ->
       `:kind`=`good` (reads scalar), `kind`=`def` (bare NOT read).
    2. `num_*(...)` callee args: `{ set(n,10); switch(num_lt(:n,5)){...} }` -> `:n`=`no` (10<5 false),
       `n`=`yes` (bare `n` -> numeric 0, 0<5 true). Same class for `num_gt`/`num_le`/... and other numeric callees.
    3. `if(...)`/`while(...)`/logical conditions: `{ set(c,0); if(:c){"T"}else{"F"} }` -> `:c`=`F` (0 falsy),
       `c`=`T` (bare truthy bareword).
    NON-FAILING (already read bare): plain `return(name)`, assignment RHS, and receiver positions return the bound
    value with or without the colon (`return(:v)`==`return(v)`==`V`).
    RULE-NAME COLLISIONS (load-bearing, shipped specs): in `spec.spec`/`ebnf.spec` a bare name that matches a
    rule/token name (`started`, `top`, `rule`, `on`) resolves as a RULE REFERENCE, not a variable read, collapsing
    the parse (`spec_spec_minimal_rule` -> `[]`) — authoritative real-spec evidence recorded in ADR `0019`. `switch(`
    itself appears in NO shipped spec, so positions 1-3 are fixture/synthetic; the collision class is the real
    migration hazard.

    ENGINE SEAMS THAT MUST CHANGE (identified, not touched):
    - Perl (central): `ActionIR::FlowExpr::_lower_flow_composite_expr` (`perl/LinkedSpec/ActionIR/FlowExpr.pm:319`)
      — the shared condition/logical/value lowering. Its `:name` -> `$name` branch (`:364`,
      `/^:([A-Za-z_]\w*)$/ -> '$'.$1`) has NO bare-identifier counterpart, so a bare atom falls through to a
      literal. This one seam covers if/elseif/while conditions, `not/and/or` logical args, and `num_*` args (num
      helper names are matched at `:374` and their args recursed through the same function at `:422`).
    - Perl (switch selector + case values): `ActionIR::ControlFlow::_control_ast_value_source_expr`
      (`perl/LinkedSpec/ActionIR/ControlFlow.pm:332`, also `:409` for while) and `_lower_switch_case_value_expr`
      (`:104`).
    - Rust (parity): bare identifier parses to `Expr::Variable` (`rust/linkedspec-core/src/expr.rs:1350`; the
      `switch(kind)` selector test asserts `Expr::Variable{name:"kind"}` at `:1788`); `:name` parses to
      `Expr::ScalarSlot` (`:1375`) and evaluates to `ctx.get_scalar(name)` at
      `rust/linkedspec-runtime/src/engine.rs:3287`. `.15.2.3` must make `Expr::Variable` in condition/selector/
      `num_*`-arg value positions read the bound scalar the same way (or prove it already does by probe).

    POLICY LOCKED (value-position-is-variable, ADR `0019`): in a value-expression position a bare identifier is a
    variable/parameter read; rule references appear only in edge/dispatch positions (`-> Rule`, `call(Rule)`,
    `=> Rule`, and the all-bare child-call `push(RuleA, AccumB)`). Scalar push uses `items += value` or
    `push(array(items), value)`, never a colon slot. This composes with the `.11` type-at-assignment duck-typed
    model (already captured under `.11`, per the user's 2026-07-05 note): the *type* of a bare name is fixed at
    assignment time by the RHS shape (scalar <- string/number, array <- `[...]`, hash <- `{ key: value }`,
    code-block <- `{ ... }` with no top-level key), and a bare *read* returns that bound runtime typed value.

    No engine/Perl/Rust/mdBook behavior changed in this leaf (design/inventory only). Probe scripts:
    `scratchpad/probe_15_2_1.pl` and `probe_15_2_1b.pl` (discriminating); KM card
    `terse-bare-read-value-position-gap` reverify reproduces position 1.
  Commit: `pending`

- ID: `SPEC-FORMAT-TERSE.15.2.2`
  Status: `done` (2026-07-05)
  Goal: Perl reference — make bare identifiers read the bound typed value in every value position enumerated by
    `.15.2.1`, with rule references confined to edge/dispatch positions. `:name` keeps working (compat) during
    this transition.
  Acceptance: focused reference-engine probes show bare == `:name` output for every enumerated position; phase0
    stays green (1021 pass plus the one pre-existing unrelated `emit_context_lowers_split_tagged_records_helper`
    failure).
  Verification: **PASS 2026-07-05.** ONE central change closed all three enumerated gaps because if/elseif/while +
    `num_*` + logical conditions all funnel through `ActionIR::FlowExpr::_lower_flow_composite_expr` (via
    `ControlFlow::_lower_control_flow_value_expr`, which delegates), and the switch selector funnels through it too.
    - CHANGE 1 (`perl/LinkedSpec/ActionIR/FlowExpr.pm`, the `passthrough_no_call` site): a lone bare identifier
      (`/\A[A-Za-z_][A-Za-z0-9_]*\z/`) reaching passthrough — provably not `true`/`false`, not `:name`, not a
      primitive literal, not direct nested access, not a helper/method call — now lowers to `$name` (a variable
      read, `decision => 'bare_variable_read'`), mirroring the `:name` scalar_slot branch. Multi-token passthrough
      stays verbatim.
    - CHANGE 2 (`perl/LinkedSpec/ActionIR/ControlFlow.pm`, `_lower_switch_case_value_expr`): a bare word in
      switch-CASE-LABEL position stays a literal tag (a label/key position, analogous to the hash-literal-key
      exemption in ADR `0019`), because Change 1 would otherwise turn `case(foo)` into `eq $foo`. The literal-tag
      decision is now made on the source token (`/^\w+$/` and not `true`/`false`) instead of the pre-`.15.2.2`
      `$lowered eq $trimmed` probe that relied on composite passthrough. So `switch(kind)` reads variable `kind`
      while `case(foo)` matches literal `"foo"`; `case(:name)`/quoted values stay non-literal.
    Evidence (discriminating probes, `scratchpad/probe_15_2_1b.pl`): `switch(kind)`->`good`, `num_lt(n,5)`@n=10->`no`,
    `if(c)`@c=0->`F` — all now equal to their `:name` forms; `:name` forms still work (compat). Focused switch/case
    lowering via `call_spec_handler_subst`: selector `$__ls_switch_value = $kind`, case `eq "foo"`, default branch
    intact — matches the phase0 regex lock. FULL phase0 (`PERL5LIB= perl -Iperl t/phase0_regression.t`): reach
    `ok 1022` (true end, plan `1..1022`), **1021 pass**, only failure `not ok 796`
    (`emit_context_lowers_split_tagged_records_helper`, the pre-existing baseline). `comm` vs baseline `{796}` =
    empty both ways: zero new failures, zero regressions. `perl -c` clean on both changed modules. ENV: phase0
    subprocess tests (e.g. 102 pplugin lazy-load) require `PERL5LIB=` cleared, else the stale
    `pgen/fx/perl` checkout poisons them (unrelated to this change).
  Commit: `pending`

- ID: `SPEC-FORMAT-TERSE.15.2.3`
  Status: `done` (2026-07-06)
  Goal: Rust parity for `.15.2.2` — bare reads in all value positions, same value-position-is-variable policy,
    `:name` still parses during the transition.
  Acceptance: Rust oracle fixtures for the enumerated positions pass with bare reads; `cargo` corpus oracle green.
    If the regenerated corpus exposes pre-existing source drift that blocks the oracle from testing Rust parity,
    the same leaf owns the minimal source correction plus a durable finding, because `.15.2.3` cannot close with
    a red oracle.
  Surfaced findings:
    - `2026-07-06`: The new `.15.2.3` oracle fixture first exposed that Perl statement/attached
      `case(foo)` was literal while inline value `switch(..., case(foo, ...))` still read variable `$foo`.
      Root cause: `MethodLowering::_lower_inline_switch_value_expr` used normal branch-payload lowering for
      the case match argument instead of the statement-switch case-label lowering. This leaf owns making inline
      switch case labels literal too, matching the already-documented `.15.2.2` policy.
    - `2026-07-06`: Regenerating the full oracle corpus exposed stale `spec_spec_*` expected files. TOOLBOX
      `dump_parser_source` + routed trace showed `spec_file` still matched `rule_header` and `regex_anchor`, but
      `specs/spec.spec` initialized `paragraphs = []` / `current = []` as scalar-held arrayrefs after the `.11`
      duck-typed assignment model while `push(rule_header, current)` mutates aggregate `@current`. The leaf owns
      changing those initializations to explicit aggregate `array(...)` targets so the self-hosted spec parser
      and Rust oracle remain aligned.
  Verification: Rust parity landed for the `.15.2.2` value-position-is-variable contract. The runtime now evaluates
    switch case values through a dedicated case-label path: bare `Expr::Variable` labels stringify to the literal
    label name, while quoted values and `:name`/other expressions still evaluate normally. Inline lazy
    `switch(...)` uses the same helper, and statement/attached `switch` shares it too. Focused Rust integration
    tests PASS for `switch(kind)` / `num_lt(n,5)` / `if(c)` bare reads and for bare-vs-`:foo` case-label
    discrimination. `tools/gen_oracle_corpus.pl` adds
    `terse_15_2_3_bare_value_reads_and_case_labels`; regenerated Rust corpus manifest is **93** fixtures and
    `cargo test --manifest-path rust/Cargo.toml -p linkedspec-runtime --test corpus_oracle -- --nocapture` PASS.
    Perl inline value `switch(...)` case-label lowering was corrected after the new oracle exposed a reference-side
    divergence; `perl -c -Iperl perl/LinkedSpec/ActionIR/MethodLowering.pm` PASS. `specs/spec.spec` aggregate
    initialization now uses explicit `array(...)` targets after TOOLBOX/source probes showed the prior
    `paragraphs = []` / `current = []` scalar-held arrays were incompatible with aggregate `push(...)` mutation
    under the `.11` duck-typed model. Direct `LinkedSpec::Get` probe for `Top:: /x/` through `specs/spec.spec`
    returns the expected minimal-rule AST. mdBook switch/case and bare-read guidance, KM fact card, and live docs
    are updated. Full phase0 (`env PERL5LIB= perl -Iperl t/phase0_regression.t`) reaches `ok 1022` / plan
    `1..1022`, with **1021 pass** and only the known baseline `not ok 796`
    (`emit_context_lowers_split_tagged_records_helper`).
  Commit: `SPEC-FORMAT-TERSE.15.2.3 - align Rust bare-read switch parity`; prior node reference: `pending`; retained completion note: Rust bare value reads now match Perl in switch/num/if positions while bare case labels remain literal; inline Perl switch case labels were aligned; `specs/spec.spec` aggregate initialization corrected; corpus oracle is 93 fixtures; frontier becomes `.15.2.4`.

- ID: `SPEC-FORMAT-TERSE.15.2.4`
  Status: `done` (2026-07-06)
  Goal: Migrate current shipped specs, root corpus, generated oracle sources, mdBook examples, and
    non-historical Knowledge Map facts from `:name` to bare reads, now output-preserving because the engine reads
    bare everywhere.
  Acceptance: zero `:name` in current sources (historical records excepted); regenerated oracle corpus is
    byte-identical (`expected.json` unchanged); phase0 green; `cargo` corpus oracle green; mdBook builds.
  Verification: **PASS 2026-07-06.** Current shipped specs, root corpus inputs, `tools/gen_oracle_corpus.pl`,
    generated Rust oracle `input.spec` fixtures, and mdBook current examples were migrated from `:name` scalar-slot
    reads to bare value reads. Rule-mode labels (`:AND`/`:OR`/etc.), regex syntax such as `[[:alpha:]]`, and
    historical literal strings remain valid exclusions from the residue scan. Regenerating the oracle corpus
    produced **93** fixtures with no `expected.json` or `manifest.json` diff. Full phase0 PASS
    (`env PERL5LIB= perl -Iperl t/phase0_regression.t`, plan `1..1022`). Rust corpus oracle PASS over **93**
    fixtures. mdBook build PASS. `git diff --check` PASS.

    Migration fixes landed where source migration exposed load-bearing compatibility seams:
    - `ActionIR::ControlFlow` normalizes parser-backed internal `assign(...)` calls back to `set(...)` when the
      original source was not explicit `assign(...)`.
    - `ActionIR::MethodLowering` keeps `split_tagged_records(...)` first bare argument as the required source
      instead of stripping it through optional-scope normalization.
    - `BootstrapSpec::Core` treats `.return(array_copy(...))`, `.return(hash_copy(...))`, and `.return(copy(...))`
      as general payload returns.
    - `RuleIR::EmitContext` records initialized declarations and single-bare typed wrappers without corrupting
      aggregate/scalar type memory.
    - The Rust runtime lets descriptor scalar bare reads coexist with same-name aggregate accumulators, and
      action-edge `call(child)` blocks publish child `retv` after the attached block completes normally.
    - `array(retv)` remains an aggregate wrapper/read; one-element scalar arrays use `[retv]`.
  Commit: `SPEC-FORMAT-TERSE.15.2.4 - migrate current sources to bare reads`; retained completion note: Current specs/corpus/oracle/mdBook/KM surfaces use bare reads instead of live `:name`; oracle expected JSON stayed unchanged over 93 fixtures; frontier becomes `.15.3`.

- ID: `SPEC-FORMAT-TERSE.15.3`
  Status: `done` (2026-07-06)
  Goal: Remove Perl reference `:name` scalar-slot parsing/lowering ENTIRELY (user directive 2026-07-05: `:name`
    shall NOT be supported). No compatibility retention.
  Acceptance: `:name` in a value position becomes a parse/lowering error carrying a bare-read migration
    diagnostic; no current test depends on `:name`; bare names remain valid value reads in all value positions
    (guaranteed by `.15.2.2`), and hash-literal key token behavior is unchanged.
  Verification: **PASS 2026-07-06.** Perl ActionIR AST parsing now classifies `:name` as retired
    `colon_scalar_slot_removed` instead of `scalar_slot`, and all Perl lowering paths emit the unsupported helper
    sentinel `LINKEDSPEC_UNSUPPORTED_ACTIONIR_HELPER:colon_scalar_slot_use_bare_read` instead of a successful
    scalar read/target. `RuleIR::EmitContext` no longer auto-declares colon scalar slots or traces
    `scalar_slot_fallback`; exact retired forms are diagnosed by the rewrite pipeline. Active Perl tests and phase0
    fixtures were migrated to bare reads. Focused tests PASS:
    `prove -q -Iperl t/actionir_ast_parser.t t/trace_emit_context_bridge.t t/trace_actionir_pipeline.t
    t/trace_actionir_compact_lowerers.t t/trace_actionir_method_lowering.t`.
    Full phase0 PASS with the required clean environment:
    `env PERL5LIB= perl -Iperl t/phase0_regression.t` reaches plan `1..1022`.

    Hard-retirement exposed and fixed several bare-read seams that `:name` compatibility had hidden:
    - optional-scope stripping no longer eats real bare conditions in `if(on, ...)`, `elseif(mid, ...)`, or
      `switch(name, case(...), default(...))`;
    - logical `or(...)` / `and(...)` preserve all bare operands as flow values;
    - `entry_text()` / `match_text()` lower directly in ordinary value positions but remain unresolved inside
      user-function bodies until staged function-body parsing owns them;
    - unchanged/reserved assignment-source tokens delegate to the assignment-source lowerer instead of short-circuiting;
    - flow RHS lowering can be used for flow-valued mutation sources when available; and
    - `count_keys(snapshot)` counts scalar-held hashrefs instead of forcing named-hash storage.
  Commit: `SPEC-FORMAT-TERSE.15.3 - retire Perl colon scalar slots`; retained completion note: Perl `:name` now emits a retired colon-slot diagnostic sentinel instead of a successful scalar read/target; `scalar_slot_fallback` is gone; active Perl tests/fixtures use bare reads; full phase0 passes; frontier becomes `.15.4`.

- ID: `SPEC-FORMAT-TERSE.15.4`
  Status: `done` (2026-07-06)
  Goal: Remove Rust `Expr::ScalarSlot` parsing/runtime support ENTIRELY (user directive 2026-07-05: `:name` shall
    NOT be supported). No compatibility retention.
  Acceptance: the Rust `:name` value primary is deleted and produces a bare-read migration diagnostic; parser/
    runtime/source-emitter tests no longer depend on `:name`; current oracle fixtures pass with bare reads (via
    `.15.2.3`); bare names and hash-literal key boundaries remain correct.
  Verification: **PASS 2026-07-06.** Rust `Expr::ScalarSlot` is removed from the core AST and runtime/source
    emission paths. Parsing a retired colon scalar slot now returns
    `LINKEDSPEC_UNSUPPORTED_ACTIONIR_HELPER:colon_scalar_slot_use_bare_read` and tells authors to use the bare
    variable read. Runtime and source-emitter fixtures use bare reads; generated-plan and interpreted action-edge
    execution pre-dispatches scoped child returns when an attached block reads `retv`, preserving the EBNF/portmap
    action-edge contract. The shipped EBNF spec now uses `rule_header` to avoid the old same-name scalar/array
    `rule` collision, the generated EBNF oracle inputs were refreshed, and the generated corpus case formerly named
    `terse_6_2_3_1_scalar_slot_shorthand` is now `terse_15_4_bare_scalar_payload_readback`.
    Focused checks PASS: `cargo test --manifest-path rust/Cargo.toml -p linkedspec-core expr::tests`,
    `cargo test --manifest-path rust/Cargo.toml -p linkedspec-core compiler::tests`,
    `cargo test --manifest-path rust/Cargo.toml -p linkedspec-runtime --lib`,
    `cargo test --manifest-path rust/Cargo.toml -p linkedspec-runtime --test integration_test`,
    `cargo test --manifest-path rust/Cargo.toml -p linkedspec-runtime --test source_emitter`,
    `cargo test --manifest-path rust/Cargo.toml -p linkedspec-runtime --test trace_controls`,
    `perl -c -Iperl tools/gen_oracle_corpus.pl`, `perl -Iperl tools/gen_oracle_corpus.pl`, and
    `cargo test --manifest-path rust/Cargo.toml -p linkedspec-runtime --test corpus_oracle -- --nocapture`
    (93 fixtures). Full phase0 also PASS (`env PERL5LIB= perl -Iperl t/phase0_regression.t`, plan `1..1022`)
    after the stale EBNF source lock was updated to expect `rule_header`.
  Commit: `SPEC-FORMAT-TERSE.15.4 - retire Rust colon scalar slots`; retained completion note: Rust `Expr::ScalarSlot` parser/runtime/source-emitter support is gone; retired colon scalar slots emit the bare-read migration diagnostic; active Rust fixtures and oracle corpus use bare reads; frontier becomes `.15.5`.

- ID: `SPEC-FORMAT-TERSE.15.5`
  Status: `done` (2026-07-06)
  Goal: Final no-drift closeout for colon scalar-slot removal.
  Acceptance: Stale `:name` scans across current specs/corpora/docs/tests/KM pass, mdBook and oracle corpus are in
    sync, task-tree/live docs record the new surface, and the next frontier advances to `.8` / `.9` as appropriate.
  Verification: **PASS 2026-07-06.** Narrow action-expression scans show no current shipped-spec, generated corpus,
    or mdBook live `:name` examples. Remaining active test/code hits intentionally exercise the retired diagnostic
    sentinel (`LINKEDSPEC_UNSUPPORTED_ACTIONIR_HELPER:colon_scalar_slot_use_bare_read`) or the parser node
    `colon_scalar_slot_removed`; `Expr::ScalarSlot` and `scalar_slot_fallback` survive only in historical
    Knowledge records and one negative trace assertion. The scan exposed two stale Knowledge fact-card references:
    `terse-duck-typed-assignment-perl-reference` now reverifies with bare `items` / `meta`, and
    `terse-string-method-surface-verified` now documents `substr(target, ...)` for statement regex substitution
    after colon-target retirement. Live probes confirm both corrected examples. Oracle generation, Rust
    `corpus_oracle`, mdBook build, Knowledge Map regeneration/check, memory/doctrine checks, diff check, and full
    phase0 pass. Frontier advances to `.8`; `.9` remains pending behind `.8`.
  Commit: `SPEC-FORMAT-TERSE.15.5 - close colon scalar-slot drift`; retained completion note: Final no-drift closeout: stale current-surface scans pass; two stale Knowledge fact-card colon examples corrected; oracle corpus, mdBook, Knowledge Map, memory/doctrine checks, and phase0 pass; `.15` closes and frontier becomes `.8`.

## Current Frontier

| Order | Leaf | Status | Why next |
| --- | --- | --- | --- |
| 1 | `SPEC-FORMAT-TERSE.15.2.1` | `done` | design/inventory: value positions where bare != `:name` enumerated with discriminating evidence (switch/num_*/if); seams pinned (Perl `FlowExpr::_lower_flow_composite_expr:364` + `ControlFlow` selector; Rust `Expr::Variable` vs `ScalarSlot`); value-position-is-variable policy locked |
| 2 | `SPEC-FORMAT-TERSE.15.2.2` | `done` | Perl engine: ONE FlowExpr change (bare→`$name` at passthrough) closed switch/num/if gaps; ControlFlow keeps case labels literal; full phase0 green 1021/1-baseline, `:name` still compat |
| 3 | `SPEC-FORMAT-TERSE.15.2.3` | `done` | Rust engine parity for bare reads in all value positions; Rust corpus oracle now 93 fixtures |
| 4 | `SPEC-FORMAT-TERSE.15.2.4` | `done` | current specs/corpus/oracle/mdBook/KM migrated to bare reads with no oracle expected-output drift |
| 5 | `SPEC-FORMAT-TERSE.15.3` | `done` | Perl `:name` parsing/lowering is hard-retired; current Perl fixtures use bare reads and retired colon slots emit a migration diagnostic sentinel |
| 6 | `SPEC-FORMAT-TERSE.15.4` | `done` | Rust `:name` / `Expr::ScalarSlot` support is hard-retired; current Rust tests and oracle fixtures use bare reads |
| 7 | `SPEC-FORMAT-TERSE.15.5` | `done` | final no-drift closeout for colon scalar-slot removal |
| 8 | `SPEC-FORMAT-TERSE.8.1` | `done` | legacy helper-removal inventory/split completed; remaining successful Perl/Rust compatibility paths and `push_nonempty(...)` replacement risk are classified |
| 9 | `SPEC-FORMAT-TERSE.8.2.1` | `done` | live EBNF `push_nonempty(...)` migrated to explicit `is_nonempty(...)`-guarded `push(...)`; generated EBNF oracle inputs refreshed with no expected-output drift |
| 10 | `SPEC-FORMAT-TERSE.8.2.2.1` | `done` | source-emitter smoke specs now use current helper spellings with explicit aggregate resets; generated-source suite passes |
| 11 | `SPEC-FORMAT-TERSE.8.2.2.2.1` | `done` | non-compat Rust integration smoke fixtures now use current helper spellings; full integration test passes |
| 12 | `SPEC-FORMAT-TERSE.8.2.2.2.2` | `done` | recursive TOP-RULE-AS-NORMAL strings now use current append/snapshot helpers; `declare(...)` retained as Rust scoped-declaration compatibility lock |
| 13 | `SPEC-FORMAT-TERSE.8.2.2.2.3` | `done` | explicit legacy-helper compatibility/equivalence tests now use current-side spellings and label retained old sides as `.8.4` locks |
| 14 | `SPEC-FORMAT-TERSE.8.2.2.2.4` | `done` | later current-feature Rust integration fixture strings migrated where supported |
| 15 | `SPEC-FORMAT-TERSE.8.2.2.2.5` | `done` | Rust integration-test residue classification closed |
| 16 | `SPEC-FORMAT-TERSE.8.2.2.3` | `done` | generated oracle corpus helper fixture inputs migrated/classified with no expected-output drift |
| 17 | `SPEC-FORMAT-TERSE.8.2.2.4` | `done` | Perl phase0 helper strings migrated/classified; full phase0 passes 1022 |
| 18 | `SPEC-FORMAT-TERSE.8.2.2.5` | `done` | active-test/corpus residue scans closed; Rust wrapper-alias residue labelled |
| 19 | `SPEC-FORMAT-TERSE.8.2.3` | `done` | current-facing mdBook/KM helper references migrated; Knowledge Map regenerated |
| 20 | `SPEC-FORMAT-TERSE.8.2.4` | `done` | `.8.2` no-drift scans/gates closed before hard retirement |
| 21 | `SPEC-FORMAT-TERSE.8.3` | `done` | Perl reference legacy helper spellings now diagnose instead of lowering successfully |
| 22 | `SPEC-FORMAT-TERSE.8.4` | `done` | Rust parser/runtime legacy helper spellings and wrapper aliases now diagnose instead of executing successfully |
| 23 | `SPEC-FORMAT-TERSE.8.5` | `done` | public docs/KM/reference cleanup after Perl/Rust hard retirement |
| 24 | `SPEC-FORMAT-TERSE.8.6` | `done` | final helper-retirement no-drift closeout |
| 25 | `SPEC-FORMAT-TERSE.9` | `done` / `closed` | hash-literal association now uses terse `:`; old source-spelled `{ key => value }` is retired and final no-drift scans are closed |
| 26 | `SPEC-FORMAT-TERSE.9.1` | `done` | audit/split hash-literal colon association surface before implementation |
| 27 | `SPEC-FORMAT-TERSE.9.2` | `done` | Perl reference colon hash-literal support during migration window |
| 28 | `SPEC-FORMAT-TERSE.9.3` | `done` | Rust parser/runtime colon hash-literal parity |
| 29 | `SPEC-FORMAT-TERSE.9.4` | `done` | migrated current specs/corpus/docs/KM/tests to colon hash-literal syntax |
| 30 | `SPEC-FORMAT-TERSE.9.5` | `done` | hard-retired old hash-literal `=>` association while preserving blind-call edge `=>` |
| 31 | `SPEC-FORMAT-TERSE.9.6` | `done` | final hash-literal colon no-drift closeout |
| 32 | `SPEC-FORMAT-TERSE.14.1` | `done` | user reactivated trailing block arguments; MVP `with(value) { ... }` contract and implementation split are locked before code |
| 33 | `SPEC-FORMAT-TERSE.14.2` | `done` | Perl reference helper-function form trailing block arguments for `with(value) { ... }` landed with scoped `value`, zero-arg `with()`, and unsupported-callee diagnostics |
| 34 | `SPEC-FORMAT-TERSE.14.3` | `done` | Rust helper-function form parity landed with scoped `value`, zero-arg `with()`, hash payloads, and a 94th oracle fixture |
| 35 | `SPEC-FORMAT-TERSE.14.4` | `done` | receiver `.with() { ... }` trailing block arguments landed with a 95th oracle fixture |
| 36 | `SPEC-FORMAT-TERSE.14.5` | `done` | mdBook/KM/oracle/no-drift closeout for shipped helper-function and receiver-method `.14` surface |
| 37 | `SPEC-FORMAT-TERSE.12.1` | `done` | user reactivated hash-tree traversal; split/spec contract landed before parser/runtime code |
| 38 | `SPEC-FORMAT-TERSE.12.2` | `done` | Perl reference implementation for receiver attached-block traversal landed; phase0 `1..1027` |
| 39 | `SPEC-FORMAT-TERSE.12.3` | `done` | Rust parser/runtime parity landed with the 96th generated oracle fixture |
| 40 | `SPEC-FORMAT-TERSE.12.4` | `done` | mdBook, Knowledge Map, live-doc, and no-drift closeout completed; `.12` exhausted |
| — | `SPEC-FORMAT-TERSE.10.1` | `done` | dynamic/computed direct hash-literal key expressions are ratified as the current contract; no parser/runtime behavior changed |
| — | `SPEC-FORMAT-TERSE.10` | `done` / `closed` | `.10` is exhausted: `{ key_expr : value_expr }` is the accepted direct hash-literal form, bare keys are scalar reads, quoted keys are fixed strings, and old `=>` stays retired |
| — | `SPEC-FORMAT-TERSE.12` | `done` / `closed` | hash-tree attached-block traversal closed through `.12.4`; no current leaf remains |
| 41 | `SPEC-FORMAT-TERSE.13.1` | `done` | user directive reactivated remaining terse-format work; array-tree traversal split before parser/runtime implementation |
| 42 | `SPEC-FORMAT-TERSE.13.2` | `done` | Perl reference implementation for array-tree receiver block traversal landed; phase0 `1..1028` |
| 43 | `SPEC-FORMAT-TERSE.13.3` | `done` | Rust parser/runtime parity plus the 97th generated oracle fixture for array-tree traversal landed |
| 44 | `SPEC-FORMAT-TERSE.13.4` | `done` | mdBook, Knowledge Map, live-doc, task-tree, and no-drift closeout completed; `.13` exhausted |
| 45 | `SPEC-FORMAT-TERSE.13.5` | `done` | parent `SPEC-FORMAT-TERSE` task-tree status reconciled closed; stale split-container active rows converted to historical closed/done wording |
| — | `SPEC-FORMAT-TERSE.13` | `done` / `closed` | array-tree traversal closed through `.13.4`; no current leaf remains |
| — | `SPEC-FORMAT-TERSE` | `done` / `closed` | parent tree closed by `.13.5`; no current PNT-eligible leaf remains |
| — | `SPEC-FORMAT-TERSE.14` | `done` / `closed` | trailing block-argument type closed for helper-function and receiver-method `with` forms without closures; future expansions need new owned leaves |
| — | `SPEC-FORMAT-TERSE.6.1` | `done` | User directive owned under the existing terse-format tree; shipped-spec inventory recorded before any `.spec` edit. |
| — | `SPEC-FORMAT-TERSE.6.2.1` | `done` | shipped specs no longer use active `declare(...)` / `.declare(...)`; focused compile, phase0, and Rust corpus oracle pass |
| — | `SPEC-FORMAT-TERSE.6.2.2` | `done` | shipped specs no longer use active old helper spellings; focused compile, phase0, and Rust corpus oracle pass |
| — | `SPEC-FORMAT-TERSE.6.2.3` | `done` | scalar-slot shorthand and hard retirement of active `scalar(...)` / `assign(...)` spec helper forms are complete |
| — | `SPEC-FORMAT-TERSE.6.2.3.1` | `done` | `:name` scalar-slot shorthand lands on Perl/Rust; phase0 1019; oracle 73 fixtures |
| — | `SPEC-FORMAT-TERSE.6.2.3.2` | `done` | authored specs/corpora use `:name`, `LHS = RHS`, direct shapes, and remembered bare kinds; phase0 1020 |
| — | `SPEC-FORMAT-TERSE.6.2.4` | `done` | shipped specs compile and scan clean; phase0 1020; oracle 73 fixtures; broader docs/corpus sweep owned by `.6.3` |
| — | `SPEC-FORMAT-TERSE.6.3` | `done` | public docs, checked-in corpus/test specs, and current-facing examples use terse replacements; legacy spellings are compatibility/reference-only |
| — | `SPEC-FORMAT-TERSE.6.4` | `done` | historical declaration-helper compatibility policy recorded; later superseded by `.8` hard retirement |
| — | `SPEC-FORMAT-TERSE.7.1` | `done` | supported type-method inventory recorded; string `substr()` already exists as a receiver method; function/statement-only boundaries identified |
| — | `SPEC-FORMAT-TERSE.7.2` | `done` | string/scalar receiver methods already cover the useful pure helper set; `substr()` method/helper equivalence verified on Perl/Rust; no code change |
| — | `SPEC-FORMAT-TERSE.7.3` | `done` | array/list numeric reducer receiver methods landed as terminal links; hash/number boundaries kept explicit; phase0 1021; oracle 74 fixtures |
| — | `SPEC-FORMAT-TERSE.7.4` | `done` | final type-method no-drift sweep closed; current docs/KM/task-tree/roadmap agree on method families and explicit boundaries |
| — | _none_ | `superseded` | frontier reopened by `SPEC-FORMAT-TERSE.8` after the user's 2026-07-04 directive to remove legacy compatibility helpers |
| — | `SPEC-FORMAT-TERSE.0` | `done` | Ratified 2026-06-18 — ADR `0007` (direction Rounds 1–3 + gradual-alias migration + lockstep variants + reference-touching exception + regression gate). |
| — | ~~EXECUTION DECISION PENDING~~ | `resolved` 2026-06-22 | The "usable phase0" gate is **cleared** — `t/phase0_regression.t` 960/960 green + `tools/run_ci_local.sh` EXIT 0 (via `PHASE0-BACKHALF-TRIAGE`). Migration policy already resolved (gradual-alias, ADR `0007`). `.1.x`+ are now PNT-eligible. |
| — | `SPEC-FORMAT-TERSE.1.1.1` | `done` 2026-06-24 | Round 1 — auto-existing working variables (**Perl reference**): the engine now auto-supplies the per-invocation `my` lexical for wrapper-referenced vars; `declare(...)` is now optional. Collector in `RuleIR::EmitContext::_collect_auto_working_var_decls`, injection in `SpecEntry::compile_spec_entry`. 19/20 shipped specs byte-identical (only `tkgui` gains one legit `my`, behavior-preserved); +3 phase0 locks → 968 green; gate EXIT 0; book taught (declare optional). |
| — | `SPEC-FORMAT-TERSE.1.1.2` | `done` 2026-06-24 | Rust lockstep parity for auto-existing variables — assessed **DOABLE, no engine change**: the Rust interpreter's per-parse `RuntimeContext` HashMaps already auto-vivify working vars (no `declare` needed) and are fresh per `execute` (no leak), so auto-existence is inherent (no Perl-style leaky-global hazard to fix). Locked with 5 oracle fixtures (`autoexist_*`, Rust==Perl reference) + 4 integration tests (value anchors, declare/no-declare convergence, per-parse no-leak); cargo 244→248 green; phase0 968 green (Perl untouched). Recursive/REP idiom deferred to `RUST-PARITY` (separate gap, not auto-existence). `.1.1` container now done; `.1.1.1` change is now landed against the universal contract. |
| — | `SPEC-FORMAT-TERSE.1.2` | `done` | Split by inference channel (Perl-first + Rust parity) after a `dump_parser_source` ground-truth pass; Channel 1 and Channel 2 children are complete. KM [[terse-bare-working-vars-engine-gaps]]. |
| — | `SPEC-FORMAT-TERSE.1.2.1` | `done` 2026-06-24 | Channel 1 (Perl) — arg-position bare working-var auto-existence LANDED. Extended `_collect_auto_working_var_decls` (bare `assign`→`$`, `push_value`/`push_nonempty`→`@`; `\s*,` guard keeps wrapped targets on the wrapped path; same dedup) → all 20 specs **byte-identical**; +3 phase0 subtests (17 assertions) → **971 green**; gate EXIT 0; ratio 1.0000; book taught (3 pages). Child-append `push(Rule[,target])`/`.push` target + bare hash (value-position) deferred to Channel 2. |
| — | `SPEC-FORMAT-TERSE.1.2.2` | `done` 2026-06-24 | Rust lockstep parity for `.1.2.1` — LANDED. Unlike `.1.1.2` it REQUIRED a Rust engine change: `resolve_scalar_target`/`resolve_array_target` now map a bare `Expr::Variable` target to the working var (mirroring Perl's `^\w+$` fallback), scoped to the Channel-1 positions via `allow_bare` (push_value/push_nonempty true; array_copy/hash_copy false). Probe: bare `[null]`/`[[]]` → `["ok"]`/`[["a","b"]]` (= wrapped = Perl reference). 2 oracle fixtures + 4 integration tests; cargo 248→252 green; clippy zero-new; phase0 971 (Perl untouched); gate EXIT 0. **Channel 1 complete on both variants.** |
| — | `SPEC-FORMAT-TERSE.1.4` | `done` 2026-06-29 | Helper renames closed on both variants. Split by variant after a TOOLBOX-first `call_spec_handler_subst` ground-truth pass; `.1.4.1` landed the Perl reference + book, and `.1.4.2` landed Rust `Engine::call_helper()` parity with oracle + integration locks. KM [[terse-helper-rename-lowering-sites]]. |
| — | `SPEC-FORMAT-TERSE.1.4.1` | `done` 2026-06-24 | Perl reference — `set`/`cat`/`copy` now lower **byte-identically** to `assign`/`concat`/`array_copy`+`hash_copy` in **every** position. `cat`+`set` via `_normalize_method_name`; `set` statement-level recognition extended at the contract + IR-event scanner + auto-`my` collector; `copy` via a dedicated array-then-hash dispatch + every declare-init / return-payload / FlowExpr-source / type-inference recognizer. All 20 specs byte-identical; `set`==`assign` ActionIR node; real terse spec runs == canonical twin end-to-end; +4 phase0 locks → **975 green**; gate EXIT 0; ratio 1.0000; book taught (3 pages). |
| — | `SPEC-FORMAT-TERSE.1.4.2` | `done` 2026-06-29 | Rust lockstep parity for `.1.4.1` — `Engine::call_helper()` (`engine.rs`): `"assign" \| "set"`, `"concat" \| "cat"`, + a dedicated value-type-dispatching `"copy"` arm. 2 oracle fixtures + 3 integration locks; cargo green; clippy zero-new; phase0 975 untouched; full gate EXIT 0; no book change. |
| — | `SPEC-FORMAT-TERSE.1.3` | `done` 2026-06-29 | Mutation surface closed by mechanism after TOOLBOX-first probes and the `.1.3.2` / `.1.3.3` / `.1.3.4.x` children. KM [[terse-mutation-surface-ground-truth]]. |
| — | `SPEC-FORMAT-TERSE.1.3.1` | `done` 2026-06-29 | Scalar function form audit — `set(name,val)` already lowers/runs like `assign(name,val)` on Perl and Rust via `.1.4.1`/`.1.4.2`; no code needed. |
| — | `SPEC-FORMAT-TERSE.1.3.2` | `done` 2026-06-29 | Array function spelling — `push(target,value)` now lowers/runs like `push_value(target,value)` for unambiguous/non-all-bare value expressions; all-bare `push(A,B)` keeps child-call precedence; Perl reference + Rust oracle/integration locks added. |
| — | `SPEC-FORMAT-TERSE.1.3.3` | `done` 2026-06-29 | Hash function mutation semantics — `set_key(name,key,value)` now mutates a named working hash as a statement on Perl + Rust; pure `set_key(hash_expr,key,value)` remains copy-valued. |
| — | `SPEC-FORMAT-TERSE.1.3.4` | `done` 2026-06-29 | Operator syntax family closed by target/mechanism after KM + TOOLBOX recon: scalar assignment, array append, and hash-index assignment are separate landed implementation leaves. |
| — | `SPEC-FORMAT-TERSE.1.3.4.1` | `done` 2026-06-29 | Scalar assignment operator — `name = value` now lowers/runs identically to `set(name,value)` / `assign(name,value)`, without claiming array/hash operators or Channel 2 bare value reads. |
| — | `SPEC-FORMAT-TERSE.1.3.4.2` | `done` 2026-06-29 | Array append operator — `items += value` now lowers/runs identically to explicit append forms for explicit RHS expressions, auto-exists the array target, and preserves the Channel 2 bare-RHS boundary. |
| — | `SPEC-FORMAT-TERSE.1.3.4.3` | `done` 2026-06-29 | Hash-index assignment operator — `name[key] = value` lowers/runs identically to settled `set_key(name,key,value)` for explicit key/value expressions without broadening Channel 2. |
| — | `SPEC-FORMAT-TERSE.1.5.2` | `done` 2026-06-29 | Primitive literal parity landed: exact primitive literals are typed value expressions on Perl/Rust, `true`/`false` are booleans, and Rust statement-form `if(false)` gates branches. |
| — | `SPEC-FORMAT-TERSE.1.5.3` | `done` 2026-06-29 | Function-call spacing locked: optional whitespace before `(` is accepted at supported helper/value sites, and no-parenthesis helper spellings remain out of scope. |
| — | `SPEC-FORMAT-TERSE.1.5.4` | `done` 2026-06-29 | Statement separator contract landed: newline-or-semicolon separates top-level canonical DSL statements, same-line multiple statements require `;`, nested semicolons stay protected, and Perl/Rust locks agree. |
| — | `SPEC-FORMAT-TERSE.1.5.5` | `done` 2026-06-29 | Direct nested access split before code: explicit segment expressions are separable from bare-segment / Channel 2 value-position reads. |
| — | `SPEC-FORMAT-TERSE.1.5.5.1` | `done` 2026-06-29 | Direct any-depth nested access with explicit path segments (`foo["a"][9]["b"][scalar(z)]`) landed on Perl and Rust. Quoted segments are hash keys; numeric/helper segments are array indexes; bare path atoms stay out of scope. |
| — | `SPEC-FORMAT-TERSE.1.5.5.2` | `superseded` 2026-06-29 | Bare direct-access segments are merged into `.1.2.3`; `[z]` must follow the global value-position bare-word-read model, not a direct-access-only rule. |
| — | `SPEC-FORMAT-TERSE.1.2.3` | `done` 2026-06-29 | Channel 2 split by aggregate-vs-scalar value-read surfaces after KM + TOOLBOX ground truth, then closed through scalar/aggregate value-read parity and RHS-shape/type-inference parity. |
| — | `SPEC-FORMAT-TERSE.1.2.3.1` | `done` 2026-06-29 | Perl aggregate bare value reads now auto-exist safely (`array_copy(items)`, `hash_copy(meta)`, `copy(items)`); phase0 984 green. |
| — | `SPEC-FORMAT-TERSE.1.2.3.2` | `done` 2026-06-29 | Rust aggregate bare value reads now match the Perl reference (`array_copy(items)`, `hash_copy(meta)`, array-first `copy(items)`, and `copy(hash(meta))`) with oracle + integration locks. |
| — | `SPEC-FORMAT-TERSE.1.2.3.3` | `done` 2026-06-29 | Perl scalar bare value reads landed across the split seams: return/assignment sources, mutation key/RHS slots, and direct-access bare path atoms. |
| — | `SPEC-FORMAT-TERSE.1.2.3.3.1` | `done` 2026-06-29 | Perl scalar bare reads in return/assignment source slots landed with auto-`my`, phase0 985 green, and mdBook updated. |
| — | `SPEC-FORMAT-TERSE.1.2.3.3.2` | `done` 2026-06-29 | Perl scalar bare reads in mutation key/RHS slots landed with auto-`my`, phase0 986 green, and mdBook updated. |
| — | `SPEC-FORMAT-TERSE.1.2.3.3.3` | `done` 2026-06-29 | Perl scalar bare reads for direct-access bare path atoms landed with auto-`my`; `foo["a"][z]` matches `foo["a"][scalar(z)]`; phase0 987 green and mdBook updated. |
| — | `SPEC-FORMAT-TERSE.1.2.3.4` | `done` 2026-06-29 | Rust lockstep parity for the accepted scalar bare-read contract landed; parser reservations removed, runtime scalar `Expr::Variable` path locked, oracle corpus 28 fixtures. |
| — | `SPEC-FORMAT-TERSE.1.2.3.5` | `done` 2026-06-29 | RHS-shape/type-inference split before code: Perl shape-literal values, Perl target-kind inference, then Rust parity for each. No engine/book behavior changed. |
| — | `SPEC-FORMAT-TERSE.1.2.3.5.1` | `done` 2026-06-29 | Perl shape-literal value expressions (`[]`/`{}`) landed: non-empty shapes lower through DSL expressions instead of raw Perl barewords; phase0 988 green and mdBook updated. |
| — | `SPEC-FORMAT-TERSE.1.2.3.5.2` | `done` 2026-06-29 | Perl RHS target-kind inference landed: direct RHS shapes infer aggregate bare targets (`name = [value]` -> `@name`, `name = { key => value }` -> `%name`); explicit `scalar(name)` remains scalar payload assignment. |
| — | `SPEC-FORMAT-TERSE.1.2.3.5.3` | `done` 2026-06-29 | Rust shape-literal value parity landed: direct `[]` / `{}` values parse and evaluate recursively, with oracle/integration locks and the `.1.2.3.5.4` target-kind boundary preserved. |
| — | `SPEC-FORMAT-TERSE.1.2.3.5.4` | `done` 2026-06-29 | Rust RHS target-kind inference parity landed: direct shape RHS initializes/replaces array/hash working variables for bare or matching typed aggregate targets, while explicit `scalar(...)` keeps scalar-held payload assignment. |
| — | `SPEC-FORMAT-TERSE.1.6` | `done` 2026-06-29 | Round 1 array end-mutation methods landed on Perl and Rust; phase0 990 green; oracle corpus 33 fixtures. Round 1 is closed. |
| — | `SPEC-FORMAT-TERSE.2.1.1` | `done` 2026-06-29 | Expression-valued block ground truth completed: current Perl/Rust treat `{}` / `{ key => value }` as hash literals and do not have block-valued expression semantics. `.2.1` split by reference/parity and explicit-return depth. |
| — | `SPEC-FORMAT-TERSE.2.1.2` | `done` 2026-06-29 | Perl reference core expression-valued blocks landed: non-empty non-hash `{ ... }` values lower to `do { ... }`, final `return(expr)` is block-local for the core subset, and hash literals keep precedence. |
| — | `SPEC-FORMAT-TERSE.2.1.3` | `done` 2026-06-29 | Rust parity for the accepted Perl-reference core expression-valued block contract landed with parser/runtime locks and a 34-fixture oracle corpus. |
| — | `SPEC-FORMAT-TERSE.2.1.4` | `done` 2026-06-30 | Block-local early `return(expr)` landed for expression-valued blocks on Perl and Rust; `.2.1` is closed. |
| — | `SPEC-FORMAT-TERSE.2.2.1` | `done` 2026-06-30 | Control-flow keyword surface split before code. Split-time inline value-control assumptions were later corrected by `.2.3.4`; attached-block `if`, `when`/`otherwise`, statement `switch`, and `while` became separate landed leaves. |
| — | `SPEC-FORMAT-TERSE.2.2.2` | `done` 2026-06-30 | Perl reference attached-block `if/elseif/else` without raw fallback — LANDED. |
| — | `SPEC-FORMAT-TERSE.2.2.3` | `done` 2026-06-30 | Rust parity for attached-block `if/elseif/else` landed with parser/runtime/oracle locks; attached `if` is now portable on Perl and Rust. |
| — | `SPEC-FORMAT-TERSE.2.2.4` | `done` 2026-06-30 | `when/otherwise` aliases landed on Perl and Rust as normalization over attached `if/else`; oracle corpus 37 fixtures. |
| — | `SPEC-FORMAT-TERSE.2.2.5` | `done` 2026-06-30 | Attached-block `switch/case/default` split and closed: Perl separator/source lock first, Rust parser/runtime parity second. |
| — | `SPEC-FORMAT-TERSE.2.2.5.1` | `done` 2026-06-30 | Perl reference attached-switch separator/source lock landed; compact adjacent branches lower without host residue and phase0/local CI pass. |
| — | `SPEC-FORMAT-TERSE.2.2.5.2` | `done` 2026-06-30 | Rust attached-switch parser/runtime parity landed; oracle corpus 38 fixtures and lazy value-form switch preserved. |
| — | `SPEC-FORMAT-TERSE.2.2.6` | `done` 2026-06-30 | `while(cond) { ... }` split/owned before code, then closed by Perl reference loop/safety and Rust parity. |
| — | `SPEC-FORMAT-TERSE.2.2.6.1` | `done` 2026-06-30 | Perl reference attached `while(cond) { ... }` with deterministic iteration safety landed. |
| — | `SPEC-FORMAT-TERSE.2.2.6.2` | `done` 2026-06-30 | Rust attached-while parser/runtime parity landed with deterministic iteration safety and 39 oracle fixtures. |
| — | `SPEC-FORMAT-TERSE.2.3` | `done` | Split/owned before code: fluent block chains, lifecycle value/drop semantics, Rust parity, full composability, and return-type method chaining were separate leaves; all children are complete. |
| — | `SPEC-FORMAT-TERSE.2.3.1` | `done` 2026-06-30 | Perl reference fluent block-chain contract landed for exact `.when(cond) { ... }.otherwise { ... }` action/lifecycle forms, including the no-dot `otherwise` continuation. |
| — | `SPEC-FORMAT-TERSE.2.3.2` | `done` 2026-06-30 | Lifecycle blocks locked as statement blocks: final ordinary statement values are discarded, top-level `return(expr)` writes the surrounding channel, and expression-valued block-local return stays separate. |
| — | `SPEC-FORMAT-TERSE.2.3.3.1` | `done` 2026-06-30 | Rust action-edge fluent no-arg `.push` / `.return(expr)` parity landed; tclite oracle remains deferred behind separate compact lifecycle/body fluent and default-mode repetition gaps. |
| — | `SPEC-FORMAT-TERSE.2.3.3.2` | `done` 2026-06-30 | Rust attached fluent block payloads landed for action-edge/lifecycle `.when(cond) { ... }` chains with dotted and no-dot fallback tails. |
| — | `SPEC-FORMAT-TERSE.2.3.3.3` | `done` 2026-06-30 | Remaining Rust fluent continuations split into compact lifecycle/body receiver chains, action-edge explicit/flow chains, and `tclite`/default-mode repetition re-enable audit. |
| — | `SPEC-FORMAT-TERSE.2.3.3.3.1` | `done` 2026-06-30 | Rust compact lifecycle/body receiver chains now normalize to lifecycle `CodeBlock` statements and execute. |
| — | `SPEC-FORMAT-TERSE.2.3.3.3.2` | `done` 2026-06-30 | Rust action-edge explicit/flow fluent chains landed for `.push(target)`, `.push(child,target)`, statement-control gating, helper calls, and return continuations. |
| — | `SPEC-FORMAT-TERSE.2.3.3.3.3` | `done` 2026-06-30 | Rust `tclite` oracle retry after fluent parity proved a remaining default-mode recursive repetition gap and split implementation to `.2.3.3.3.3.1`. |
| — | `SPEC-FORMAT-TERSE.2.3.3.3.3.1` | `done` 2026-06-30 | Rust default-mode recursive repetition parity for `tclite` landed, including the two active oracle cases and 41-fixture corpus. |
| — | `SPEC-FORMAT-TERSE.2.3.4` | `done` 2026-06-30 | Full composability audit split unsupported sites before code and added a green deep pure-helper oracle fixture. |
| — | `SPEC-FORMAT-TERSE.2.3.4.1` | `done` 2026-06-30 | Rust helper-context bare aggregate arguments landed for hash- and array-consuming helper slots; corpus 44 fixtures. |
| — | `SPEC-FORMAT-TERSE.2.3.4.2` | `done` 2026-06-30 | Perl inline-composite value controls landed for `if`/`switch` in supported value positions; corpus 46 fixtures. |
| — | `SPEC-FORMAT-TERSE.2.3.5` | `done` 2026-07-01 | Return-type method chaining specified before code and split by type family; no runtime behavior changed. |
| — | `SPEC-FORMAT-TERSE.2.3.5.1` | `done` 2026-07-01 | Array receiver-dot value chains landed on Perl/Rust; phase0 996 green, corpus 47 fixtures, `.1.6` statement-only mutations preserved. |
| — | `SPEC-FORMAT-TERSE.2.3.5.2` | `done` 2026-07-01 | Hash receiver-dot value chains landed on Perl/Rust; corpus 48 fixtures, statement-level hash mutations preserved, Rust `merge_hash` override parity fixed. |
| — | `SPEC-FORMAT-TERSE.2.3.5.3` | `done` 2026-07-01 | String/scalar receiver-dot value chains landed on Perl/Rust; split bridges into array receiver chains, string literal receivers parse on Rust, value-form split/substr payloads are portable, phase0 998 green, corpus 49 fixtures. |
| — | `SPEC-FORMAT-TERSE.2.3.5.4` | `done` 2026-07-01 | Number receiver-dot value chains landed on Perl/Rust; numeric literal receivers parse, comparisons are terminal, value-form numeric comparisons lower on Perl, Rust `num_add`/`num_mul` consume all operands, phase0 999 green, corpus 50 fixtures. |
| — | `SPEC-FORMAT-TERSE.2.3.5.6` | `done` 2026-07-01 | Typed wrapper quoted-name boundary locked: bare aggregate wrapper args read typed working variables; quoted args stay constructor payloads; direct `[...]` / `{...}` shapes are the preferred terse constructors. |
| — | `SPEC-FORMAT-TERSE.2.3.5.5` | `done` 2026-07-01 | Block-valued receiver-dot chaining landed by yielded runtime type; expression-valued blocks feed the existing compatible array/string/hash/number receiver families. |
| — | `SPEC-FORMAT-TERSE.5.0` | `done` 2026-07-01 | Future backend parity ownership is explicit before any non-Rust variant code; ADR `0021` later schedules Dart, Julia, and Lua under `FUTURE-PARITY-BACKLOG`. |
| — | `SPEC-FORMAT-TERSE.3.1` | `done` 2026-07-01 | Edge syntax contract confirmed and locked with existing regression coverage: `->` action edges and `=>` blind-call edges stay as-is; grouped action targets require a shared block; block-less grouping stays invalid. |
| — | `SPEC-FORMAT-TERSE.3.2` | `done` | Arithmetic/comparison call surface split before code: word aliases, symbol callees, and comparison-name policy are separate mechanisms; all children are complete. |
| — | `SPEC-FORMAT-TERSE.3.2.1` | `done` 2026-07-01 | Non-conflicting numeric word aliases map to `num_*` on Perl/Rust; comparison words stayed string helpers until `.3.2.3.3` later flipped them. |
| — | `SPEC-FORMAT-TERSE.4.1` | `done` 2026-07-01 | User-defined function MVP contract/inventory locked before code; implementation split into `.4.2.1`–`.4.2.3` and `.4.3.1`–`.4.3.2`. |
| — | `SPEC-FORMAT-TERSE.4.2.1` | `done` 2026-07-01 | Perl reference function-definition grammar/registry descriptor seam landed; registered calls were intentionally unresolved until `.4.2.2`. |
| — | `SPEC-FORMAT-TERSE.4.2.2` | `done` 2026-07-01 | Perl registered exact-arity value calls now execute in value positions and compatible receiver chains. |
| — | `SPEC-FORMAT-TERSE.4.2.3` | `done` 2026-07-01 | Perl registered standalone calls now lower as `VALUE_DROP`; recursion/unsupported body diagnostics stay unresolved-helper metadata with zero raw fallback. |
| — | `SPEC-FORMAT-TERSE.4.3.1` | `done` 2026-07-02 | Rust parsed/compiled function registry parity landed; runtime call execution remained `.4.3.2`. |
| — | `SPEC-FORMAT-TERSE.4.3.2` | `done` 2026-07-02 | Rust registered user-function calls now execute as values, feed compatible receiver chains, discard standalone results, and pass the Perl/Rust oracle fixture; corpus 54 fixtures. |
| — | `SPEC-FORMAT-TERSE.4.4` | `done` 2026-07-02 | Function MVP surface finalized in the book/KM/task tree; alternate spellings, optional zero-arg parentheses, brace-less bodies, side-effect/caller-mutating functions, recursion, closures/lambdas/currying, and namespaces are explicitly deferred. |
| — | `SPEC-FORMAT-TERSE.3.2.2` | `done` 2026-07-02 | Arithmetic symbol callees `+(...)`, `-(...)`, `*(...)`, `/(...)`, and `%(...)` now map to `num_add`/`num_sub`/`num_mul`/`num_div`/`num_mod` on Perl/Rust while slash regex literals remain regexes. |
| — | `SPEC-FORMAT-TERSE.3.2.3` | `done` | Comparison call surface split before implementation: explicit string bridge first, numeric comparison word aliases next, symbol callees after that; all children are complete. |
| — | `SPEC-FORMAT-TERSE.3.2.3.1` | `done` 2026-07-02 | Explicit `str_eq`/`str_ne`/`str_gt`/`str_ge`/`str_lt`/`str_le` compatibility bridge contract locked before changing bare comparison words; no runtime behavior changed. |
| — | `SPEC-FORMAT-TERSE.3.2.3.2` | `done` 2026-07-02 | Explicit `str_*` string-comparison helpers landed on Perl/Rust; bare comparison words remained string-compatibility aliases until `.3.2.3.3`. |
| — | `SPEC-FORMAT-TERSE.3.2.3.3` | `done` 2026-07-02 | Ordinary comparison word calls now map to numeric `num_*` aliases on Perl/Rust; lexical strings use explicit `str_*`. |
| — | `SPEC-FORMAT-TERSE.3.2.3.4` | `done` 2026-07-02 | Comparison symbol callees `==`, `!=`, `>`, `>=`, `<`, and `<=` now map to numeric `num_*` aliases on Perl/Rust without claiming assignment `=(...)` or blind-call `=>`. |
| — | `SPEC-FORMAT-TERSE.3.3` | `done` 2026-07-02 | Expression-valued assignment plus `=(target,value)` equivalence split before code. Scalar, direct-shape aggregate, array append, hash-index mutation, and compatibility/docs closure are now landed. |
| — | `SPEC-FORMAT-TERSE.3.3.1` | `done` 2026-07-02 | Scalar non-shape assignment expressions now store and return the scalar value on Perl/Rust, including `=(target,value)` and scalar `set`/`assign` compatibility. |
| — | `SPEC-FORMAT-TERSE.3.3.2` | `done` 2026-07-02 | Direct RHS shape assignment expressions now store and return array/hash values on Perl/Rust after target-kind inference; scalar wrapper targets still keep scalar-held payloads. |
| — | `SPEC-FORMAT-TERSE.3.3.3` | `done` 2026-07-02 | Array append and hash-index mutation expression values now mutate and return updated aggregate snapshots on Perl/Rust; corpus 61 fixtures and phase0 1014 green. |
| — | `SPEC-FORMAT-TERSE.3.3.4` | `done` 2026-07-02 | Legacy `assign(...)` compatibility is documented as an alias while public examples prefer `set(...)`/operators; the parent assignment-expression fixture passes on Perl/Rust with 62 corpus fixtures and phase0 1015 green. |
| — | `SPEC-FORMAT-TERSE` | `no PNT-eligible leaf` | All concrete terse implementation/doc-closure leaves in this tree are done. Future backend leaves `.5.1`/`.5.2`/`.5.3` are superseded by `FUTURE-PARITY-BACKLOG`, where Lua is accepted and scheduled after Dart and Julia. |

## Decisions

- `2026-07-08` (**`.10.1` dynamic hash-literal keys ratified, no engine change**).
  The current direct hash-literal surface is intentionally expression-keyed, not fixed-key-only:
  `{ key_expr : value_expr }` parses the key through the normal value-expression grammar up to the top-level
  colon. A bare key name reads the scalar value of that name, so `{ key : value }` uses runtime scalar `key`;
  quote fixed field names as `{ "kind" : value }`. Computed key expressions such as
  `{ cat(prefix,suffix) : value }` are valid. This records existing Perl/Rust behavior from the `.9` colon
  migration and `.15` bare-read policy; no parser/runtime broadening landed in `.10.1`.

- `2026-07-08` (**`.13.1` array-tree traversal split before code**).
  The accepted array-tree MVP reuses the immediate receiver block methods `walk_leaves`, `map_leaves`, and
  `reduce_leaves(initial)` on array-valued receivers. Array roots and nested arrays are traversal nodes; scalar and
  hash values are leaves. Traversal is depth-first in zero-based index order. Callback blocks get scoped `value`,
  `index`, `path`, `depth`, and reduction-only `acc`. This is deliberately symmetric with `.12` hash-tree traversal
  while keeping hashes as leaves inside array trees.

- `2026-07-03` (**`.6.1` user directive — finish the terse-format migration, not a runtime `declare` expansion**).
  The latest directive makes the earlier Round 1 intent actionable: `declare(...)` shall not be used in spec files
  because the terse format has replacements and the helper form is too verbose. This is not a `RUST-PARITY`
  runtime-helper expansion; it belongs under the existing `SPEC-FORMAT-TERSE` tree because `.1.1` already landed
  auto-existing variables and ADR `0007` already chose "canonical-new + deprecated-old-alias, then explicit
  retirement." Active shipped-spec inventory before edits: 70 hits across 13 files under `specs/`. `.6.2` migrates
  those specs first; `.6.3` sweeps public docs/corpus/tests; `.6.4` decides compatibility support only after the
  live spec-file surface is clean.

- `2026-07-02` (**`.3.3.4` assignment-expression closure landed**). The parent `.3.3` contract is now locked
  across scalar assignment values, direct RHS shape aggregate assignment values, array append snapshot values,
  hash-index mutation snapshot values, user-function body assignment, operator-call `=(...)`, canonical
  `set(...)`, and legacy `assign(...)` compatibility. Public mdBook examples prefer `set(...)`, `name = value`,
  `items += value`, and `meta[key] = value`; `assign(...)` remains documented only as a legacy alias with the
  same current value semantics. The closure oracle fixture raises the corpus to **62 fixtures** and phase0 to
  **1015 tests**. No concrete PNT-eligible `SPEC-FORMAT-TERSE` implementation leaf remains after this closure;
  future backend leaves stay deferred/blocked by explicit roadmap decisions.

- `2026-07-02` (**`.3.3.3` mutation assignment expression values landed**). Array append and hash-index
  mutation operators now have expression values on Perl and Rust. `items += value` pushes into the named working
  array and yields the updated array snapshot; `meta[key] = value` writes the named working hash field and yields
  the updated hash snapshot. These snapshot values compose in helper arguments, `return(...)`, expression-valued
  blocks, and compatible receiver chains such as `(items += value).count()` and
  `(meta[key] = value).count_keys()`. Statement behavior is preserved, and the new
  `terse_3_3_3_mutation_assignment_expressions` oracle fixture raises the corpus to **61 fixtures**.

- `2026-07-02` (**`.3.3.2` aggregate assignment expression values landed**). Direct RHS shape assignment now has
  a value contract after target-kind inference: `items = [value]`, `set(items, [value])`, `=(items, [value])`,
  and `set(array(items), [value])` store `@items` and yield the assigned array value; `meta = { key => value }`,
  `set(meta, { key => value })`, and `set(hash(meta), { key => value })` store `%meta` and yield the assigned
  hash value. Explicit `scalar(payload)` remains the scalar-held payload boundary. The implementation keeps
  generated Perl declarations aligned to the inferred target kind and adds the
  `terse_3_3_2_aggregate_assignment_expressions` oracle fixture. Array append and hash-index mutation expression
  values later landed in `.3.3.3`.

- `2026-07-02` (**`.3.3.1` scalar assignment expression values landed**). Scalar non-shape assignment now has
  a value contract: `name = value`, `=(name,value)`, `set(name,value)`, and `assign(name,value)` store the scalar
  and yield the stored value in value positions. This composes in return payloads, helper arguments,
  expression-valued blocks, user-function bodies, and compatible scalar receiver chains. Direct RHS shape
  assignment later landed in `.3.3.2`; array append and hash-index mutation stay deferred to `.3.3.3`.

- `2026-07-02` (**`.3.3` expression-valued assignment split before code**). The destination contract remains:
  `target = value` is canonical, `=(target,value)` is the ordinary operator-call equivalent, legacy
  `assign(target,value)` is migration debt, and assignment expressions evaluate to the value stored after
  assignment and target-kind inference. Current shipped behavior is narrower: scalar assignment, array append,
  and hash-index assignment are statement-level operations today, while value-position assignment forms fail or
  remain unevaluated. Implementation is therefore split into scalar assignment expressions first (`.3.3.1`),
  aggregate target-kind assignment expressions second (`.3.3.2`), append/hash-index mutation expression
  contracts third (`.3.3.3`), and compatibility/docs/oracle closure last (`.3.3.4`). No parser/compiler/runtime
  code changed in this split.

- `2026-07-02` (**`.3.2.3.4` numeric comparison symbol callees implemented**). Comparison symbols
  `==(lhs,rhs)`, `!=(lhs,rhs)`, `>(lhs,rhs)`, `>=(lhs,rhs)`, `<(lhs,rhs)`, and `<=(lhs,rhs)` are now numeric
  aliases for `num_eq`, `num_ne`, `num_gt`, `num_ge`, `num_lt`, and `num_le` on Perl and Rust. They are
  ordinary `callee(args)` calls with no precedence. The implementation deliberately leaves `=(target,value)`
  for `.3.3` and leaves `=>` as the blind-call edge operator.

- `2026-07-02` (**`.3.2.3.3` numeric comparison word aliases implemented**). Bare value-call comparison words
  `eq(lhs,rhs)`, `ne(lhs,rhs)`, `gt(lhs,rhs)`, `ge(lhs,rhs)`, `lt(lhs,rhs)`, and `le(lhs,rhs)` are now numeric
  aliases for `num_eq`, `num_ne`, `num_gt`, `num_ge`, `num_lt`, and `num_le` on Perl and Rust. Lexical string
  comparisons must use the explicit bridge names `str_eq`, `str_ne`, `str_gt`, `str_ge`, `str_lt`, and
  `str_le`; repo-owned lexical comparison sites are migrated accordingly. Comparison symbol callees remain
  `.3.2.3.4`; assignment `=(...)` remains `.3.3`; `=>` remains the blind-call edge operator.

- `2026-07-02` (**`.3.2.3.2` explicit string-comparison helpers implemented**). `str_eq(lhs,rhs)`,
  `str_ne(lhs,rhs)`, `str_gt(lhs,rhs)`, `str_ge(lhs,rhs)`, `str_lt(lhs,rhs)`, and `str_le(lhs,rhs)` are now
  shipped two-argument lexical string predicates on Perl and Rust. New docs/examples should prefer `str_*` for
  text comparisons. Bare `eq`/`ne`/`gt`/`ge`/`lt`/`le` remain runnable string-comparison compatibility aliases
  only until `.3.2.3.3` flips ordinary comparison word calls to numeric `num_*` aliases. This leaf does not add
  comparison symbol callees and does not change number receiver terminals.

- `2026-07-02` (**`.3.2.3.1` explicit string-comparison bridge contract locked**). The bridge names are
  exactly `str_eq(lhs,rhs)`, `str_ne(lhs,rhs)`, `str_gt(lhs,rhs)`, `str_ge(lhs,rhs)`, `str_lt(lhs,rhs)`, and
  `str_le(lhs,rhs)`. They preserve the existing lexical/string comparison semantics of today's bare
  `eq`/`ne`/`gt`/`ge`/`lt`/`le` flow/helper predicates and are intentionally not numeric helpers,
  receiver-dot links, or symbol callees. Public docs must describe the names as accepted bridge names but not
  runnable shipped syntax until `.3.2.3.2` implements them. Bare comparison words cannot become numeric aliases
  until `.3.2.3.2` has landed and repo-owned string examples/tests have either moved to `str_*` or retained
  explicit compatibility coverage.

- `2026-07-02` (**`.3.2.3` comparison call surface split before code**). The accepted canonical comparison
  operator-call surface is numeric and ordinary-call-shaped: `eq`/`==`, `ne`/`!=`, `gt`/`>`, `ge`/`>=`,
  `lt`/`<`, and `le`/`<=` all ultimately map to the existing `num_*` comparison family. That cannot land as
  one code slice because current documented bare `eq`/`ne`/`gt`/`ge`/`lt`/`le` helper behavior is string
  comparison in flow/helper contexts. The migration is therefore split: first lock and implement explicit
  string comparison helpers `str_eq`, `str_ne`, `str_gt`, `str_ge`, `str_lt`, and `str_le`; then flip numeric
  word-call aliases; then add comparison symbol callees. Equality symbol comparison is `==(...)`; raw
  `=(target,value)` remains assignment and is owned by `.3.3`; `=>` remains the blind-call edge operator.
  Current shipped behavior remains unchanged until child implementation leaves land.

- `2026-07-02` (**`.4.4` user-function extension ledger finalized**). The portable MVP surface is now closed at
  top-level `fn name(args) { ... }`, exact explicit arity, explicit zero-arg parentheses (`fn name() { ... }`),
  braced value-oriented bodies, fresh function-local stores, final-expression/`return(expr)` results, value-call
  composition, receiver-chain continuation, and standalone result discard on Perl/Rust. The following are not
  accepted syntax/semantics without a future owning leaf: alternate spellings (`function ... endfunction` and
  `fn ... endfn`), omitted zero-arg parentheses, brace-less bodies, caller-state/parser-state/persistent
  side-effect functions, recursive user functions, closures, lambdas, currying/partial application, and
  namespace/module features.

- `2026-07-01` (**function grammar ownership: `specs/spec.spec`, not bootstrap**). After the text-to-AST
  migration, support for `fn <name>(...) { ... }` must live in `specs/spec.spec`. Bootstrap-parser support for
  that syntax is not a permanent language surface; if a temporary bridge exists during migration, it must be
  removed once the AST path and self-hosted grammar carry user-defined functions.

- `2026-07-01` (**operator calls and assignment expression clarification**). Comparison operators are part of
  the uniform function-call surface: word spellings such as `gt(a,b)`, `ge(a,b)`, `ne(a,b)` and symbol
  spellings such as `>(a,b)`, `>=(a,b)`, `!=(a,b)` are ordinary value-producing calls under the canonical
  contract. `.3.2.3` owns the migration policy because current string-comparison helper behavior still exists
  and must not be broken silently. Assignment is also an expression: canonical `target = value` replaces
  legacy `assign(target,value)`, `=(target,value)` is the operator-call equivalent of `target = value`, and the
  assignment expression's value is the stored value after assignment/target-kind inference. `.3.3` owns the
  expression-valued assignment contract and any necessary split before parser/compiler/runtime code changes.

- `2026-07-01` (**`.4` user-defined function surface accepted and split before code**). User-defined
  functions are useful enough to enter the active terse lane, but the first implementation is intentionally
  narrow and uniform with the existing value-expression model. Accepted MVP: top-level `fn name(args) { ... }`,
  explicit parentheses even for zero args, explicit positional parameters, pure value/block bodies, and no
  recursion/closures/lambdas/currying/implicit caller-state capture. A function call is an ordinary expression:
  it may feed helper arguments, assignment, return, array/hash mutations, and receiver-dot value chains by its
  yielded runtime type. A function call used as a standalone statement silently discards its return value. The
  alternate spellings (`function ... endfunction`, `fn ... endfn`, optional zero-arg parentheses, and
  brace-less bodies) remain deferred until the MVP is portable and documented.

- `2026-07-01` (**`.3.2.1` numeric word aliases landed**). Non-comparison function-form numeric aliases are
  accepted as ordinary helper calls and lower/dispatch to the existing `num_*` family on Perl and Rust:
  `add`, `sub`, `mul`, `div`, `mod`, `abs`, `floor`, `ceil`, `round`, `min`, `max`, `clamp`, `sum`, `avg`,
  `median`, and `range`. The Perl implementation keeps this mapping in value lowering instead of the shared
  parse-normalization seam so existing receiver-dot methods such as `.floor()` and `.add(...)` remain raw
  receiver methods until receiver-chain normalization handles them. This leaf deliberately leaves `+(a,b)` and
  the rest of the arithmetic symbol-callee family to `.3.2.2`, and leaves comparison spelling policy to
  `.3.2.3`; bare `gt(...)` remains the current string comparison helper.

- `2026-07-01` (**`.3.2` arithmetic call surface split before code**). Round 3 arithmetic/comparison calls
  keep one `callee(args)` grammar. The Lisp-prefix `(op a, b)` / `(ge a, b)` form is deliberately not added:
  ordinary nested calls such as `add(mul(a,b), c)` already provide the intended composability without a second
  call grammar. The implementation work is split because current ground truth separates three mechanisms:
  word aliases such as `add(...)` can map to existing `num_*` helpers, symbol callees such as `+(...)` require
  parser/lowering/runtime support on both Perl and Rust, and bare comparison words conflict with the existing
  string comparison helpers documented in the mdBook. Numeric word aliases therefore proceed first, arithmetic
  symbol callees second, and comparison spellings only after the string-vs-numeric policy is explicit.

- `2026-07-01` (**`.3.1` edge syntax contract locked**). Round 3 keeps the existing edge split: `->` remains
  the action-edge surface, and `=>` remains the blind-call surface. Grouped action-edge targets are accepted
  only as a factoring form with one shared block, `-> RuleA | RuleB { ... }`; each listed target still
  dispatches independently. The block-less grouped form `-> RuleA | RuleB` stays invalid, with the validator
  reporting "Grouped action-edge targets require a shared code block". Existing phase0 locks already cover
  parse expansion, acceptance, rejection, and three-target grouping, so this leaf closes as a contract/docs/KM
  lock with no parser/compiler/runtime change.

- `2026-07-01` (**`.2.3.5` return-type method chaining split before code**). Receiver-dot value chains will
  not be implemented by broadening the existing statement-level mutation shortcut. The accepted model is
  receiver-as-first-argument value chaining by return family: an array-returning call can feed another array
  method, a hash-returning call can feed another hash method, and terminal string/number/boolean/scalar calls
  either end the chain or continue only through an explicitly compatible family contract. The `.1.6` array end
  mutations (`push_back`, `push_front`, `pop_back`, `pop_front`) stay statement-only until an array child leaf
  explicitly designs destructive value-returning semantics and proves Perl/Rust parity. Expression-valued
  blocks are values too: block receiver-dot chaining is owned by `.2.3.5.5` and must dispatch by the runtime
  type yielded by the block after the concrete type-family leaves are in place.

- `2026-07-01` (**`.2.3.5.1` array receiver-dot value chains landed**). Array receiver-dot value chains are
  pure helper composition over compatible array-returning helpers and documented array terminals. `join_values`
  keeps its delimiter-first function contract, so `items.join_values("|")` maps to `join_values("|", items)`.
  `split(value, delim)` is intentionally not an array receiver link because its receiver is scalar/string
  input; string receiver chains remain `.2.3.5.3`. The `.1.6` array end mutations stay statement-only.

- `2026-07-01` (**`.2.3.5.2` hash receiver-dot value chains landed**). Hash receiver-dot value chains are
  pure helper composition over compatible hash-returning helpers and documented hash terminals. `sorted_keys`
  and `sorted_values` return arrays and may continue through the array receiver-chain family. Receiver-dot
  `scalaref(key)` reads a field from the current hash value. `set_key(meta, key, value)` and
  `meta[key] = value` remain statement mutations; `meta.set_key(key, value)` is pure unless assigned back.
  Rust `merge_hash` now matches the documented later-argument override rule.

- `2026-07-01` (**`.2.3.5.3` string receiver-dot value chains landed**). String/scalar receiver-dot value
  chains are pure helper composition over compatible string-returning helpers and documented terminals. A bare
  receiver reads the scalar working variable, string literals may be receivers, and `split(delim)` is the
  explicit bridge into the array receiver-chain family. `length`, `starts_with`, `ends_with`,
  `contains_substr`, and `matches` are terminal values and cannot continue through later receiver-dot calls;
  invalid post-terminal continuations return `undef`/`null`. Value-form `split(...)` and `substr(...)` are now
  portable helper payloads.

- `2026-07-01` (**`.2.3.5.4` number receiver-dot value chains landed**). Number receiver-dot value chains are
  pure helper composition over the existing `num_*` helper family. Receiver methods use terse names
  (`abs`, `floor`, `ceil`, `round`, `add`, `sub`, `mul`, `div`, `mod`, `min`, `max`, `clamp`, `eq`, `ne`,
  `gt`, `ge`, `lt`, `le`) and map to `num_*` with the receiver as the first argument. Comparisons are terminal
  boolean values and invalid continuations return `undef`/`null`. Array reducers remained explicit
  array-consuming helpers at that time; later `.7.3` added terminal array/list receiver reducer methods without
  making reducers scalar number receiver links.

- `2026-07-01` (**`.2.3.5.6` typed wrapper quoted-name boundary landed**). The aggregate typed wrappers are
  name-reference forms only when called with exactly one bare name token: `array(foo)` / `a(foo)` read the
  array/list working variable `foo`, and `hash(bar)` / `h(bar)` read the hash/associative-array working
  variable `bar`. Quoted arguments are not aliases for those reads: they stay literal constructor payloads
  under the existing constructor rules. The terse constructor surface is the direct shape syntax (`[...]` and
  `{...}`), which should be preferred in new examples. Runtime scalar-indirect lookup and postfix typed-view
  adapters such as `foo.array()` are explicitly out of scope.

- `2026-07-01` (**`.2.3.5.5` block-valued receiver-dot chains landed**). Expression-valued blocks are ordinary
  receiver values. The block evaluates first, including block-local `return(expr)`, and the yielded value
  selects the already-owned compatible receiver family. Perl array recognition is intentionally exit-shape
  based: a block is array-like only when all visible exits are array-yielding expressions, which prevents
  broad block-as-array misclassification. Rust keeps the same runtime evaluator and only needed parser
  follow-through after block/hash/array primaries.

- `2026-07-01` (**`.5.0` future variant parity ownership split**). The implemented backend set is the Perl
  reference plus the Rust interpreter under `rust/`. ADR `0006`, Phase 8, the mdBook backend handoff chapter,
  and the Knowledge Map define Julia and Dart as accepted future backend targets that must consume identical
  `.spec` files and pass the language-neutral corpus when implemented. This 2026-07-01 split kept Lua outside
  code ownership until an explicit adoption decision existed; ADR `0021` now supplies that decision and moves
  Dart, Julia, and Lua future parity work to `FUTURE-PARITY-BACKLOG`.

- `2026-06-30` (**`.2.3.4.2` Perl inline value-control lowering landed**). Inline-composite `if(...)` and
  `switch(...)` are now portable value expressions in the supported value-consuming slots: `return(...)`,
  assignment RHS, and fluent `.return(...)`. The selected branch payload is the contract. Legacy/action-edge
  return arrays may still contain ordinary string tags for compatibility, but no new oracle, book example, or
  test should require a particular `?...:` tag spelling for this value-control feature. Attached-block
  `if`/`switch` remain the preferred form for substantial multi-statement branch bodies, while inline value
  controls are for constructing values lazily inside an expression position.

- `2026-06-30` (**`.2.3.4.1` Rust helper-context bare aggregate arguments landed**). The Rust fix is
  deliberately helper-position typed, not a global bare-variable change. `Expr::Variable` still evaluates as a
  scalar read; hash-consuming helper slots call a narrow resolver that promotes a bare variable name to
  `ctx.hash_copy(name)` after ordinary evaluation fails to produce a `RuntimeValue::Hash`, and array-consuming
  helper slots do the same with `ctx.array_copy(name)`. That makes `merge_hash(hash_copy(base), overlay)` and
  `count(drop_front(sorted(items)))` match the Perl reference and extends the same snapshot semantics to the
  hash/object helper family (`set_key`, `rename_key`, `drop_keys`, `pick_keys`, `sorted_keys`,
  `sorted_values`, `count_keys`, `has_key`, `scalaref`, `flat_hash`) plus the array helper family (`sorted`,
  `reversed`, `first`, `last`, `take`, `take_last`, `drop_front`, `drop_back`, `slice`, `contains`,
  `index_of`, `num_sum`, `flat_array`) without weakening `.1.2.3.2` aggregate-copy boundaries.

- `2026-06-30` (**`.2.3.4` full composability audit split**). At split time, the accepted portable subset was
  pure value-helper composition with explicit aggregate wrappers where Rust still needed a type-implying
  argument.
  A new green oracle fixture locks
  `count(drop_front(sorted_keys(merge_hash(hash_copy(base), hash(overlay)))))`. The book-shaped bare
  `merge_hash(hash_copy(base), overlay)` works on Perl but returns one key short on Rust because the Rust
  runtime evaluates bare `overlay` as a scalar before `merge_hash` sees evaluated hash arguments; `.2.3.4.1`
  owns that Rust parity gap. Perl inline-composite value controls also cannot be accepted by assertion:
  generated-source probes show `return(if(...))` and `return(switch(...))` do not return the selected branch
  value, and nested helper expressions can fail handler compilation; `.2.3.4.2` owns that reference fix.
  Receiver-dot value/chaining remains `.2.3.5`.

- `2026-06-30` (**`.2.3.3.3.3.1` Rust tclite default repetition landed**). The implementation seam is two
  small parity corrections, not another fluent-chain executor. First, Rust's `RuleMode::Default` is part of
  the repeated-choice family with `rep_min = Some(0)` and no max, matching the historical bare-rule model
  described in the book. Second, parent action-edge dispatch has already matched the child's dependency regex;
  a child `I.return(...)` therefore returns immediately from the child handler before any local re-match or
  later `E` execution. Rust now checks for a preamble return before entering the rule's match loop and restores
  caller return/match state before returning the child value. That is sufficient for `tclite_command_subst`
  (`[]`) and `tclite_double_quote` (`""`) to become active shipped-spec oracle fixtures; broader lifecycle
  return-control cleanup is not claimed by this leaf.

- `2026-06-30` (**`.2.3.3.3.3` tclite retry split**). With compact lifecycle/body receiver chains and
  action-edge explicit/flow fluent chains landed, `tclite` was retried as an oracle fixture instead of being
  reasoned about indirectly. Perl reference probes returned `["?tcl_script:",[["?command_subst:",[]]]]` for
  input `[]` and `["?tcl_script:",[["?double_quote:",[]]]]` for input `""`. Temporarily re-enabling those two
  cases in `tools/gen_oracle_corpus.pl` made the Rust corpus oracle fail only those cases: expected wrapped
  values were the Perl outputs above, and actual `engine.execute` output was `[]` for both. Therefore no
  remaining fluent-continuation blocker is being hidden; the next code slice is a default-mode recursive
  repetition/top-level default-rule dispatch parity implementation leaf, `.2.3.3.3.3.1`. The failing fixtures
  stay out of the committed green corpus until that leaf lands.

- `2026-06-30` (**`.2.3.3.3.2` Rust action-edge explicit/flow fluent chains landed**). The remaining
  action-edge fluent surface is edge-scoped, not a generic body `FluentChain` executor. Multiline dotted
  continuation lines after an action edge now belong to that `ActionEdge`/`AcodeEntry`; runtime execution then
  interprets the call list in order with the same statement-control stack used by structured blocks.
  `.push(target)` means "dispatch the edge's child and append its return value to `target`"; `.push(child,target)`
  makes the child explicit and uses the same return-channel behavior. Branch-local helpers such as `.say(...)`
  execute through normal helper evaluation. This closes the remaining fluent blocker before retrying `tclite`;
  any remaining divergence is now owned by `.2.3.3.3.3` and must be treated as a default-mode repetition audit,
  not hidden behind action-edge fluent support.

- `2026-06-30` (**`.2.3.3.3.1` Rust compact lifecycle fluent chains landed**). The Rust fix belongs in body
  parsing, not in a new compiler/runtime execution model for standalone `BodyElementKind::FluentChain`. A
  lifecycle-marker receiver chain such as `I.declare(...).set(...).return(...)` now normalizes to the same
  statement string as `I { declare(...); set(...); return(...) }`, so `compiler.rs` continues to compile a
  normal lifecycle `CodeBlock` into `preamble` / `ecode` / related slots and `engine.rs` executes the existing
  lifecycle statement model. This keeps `.2.3.3.3.1` out of action-edge explicit/flow semantics, which remain
  `.2.3.3.3.2`.

- `2026-06-30` (**`.2.3.3.1` Rust action-edge fluent continuations landed**). Rust now carries fluent chains on
  `->` action edges through AST, compiled `AcodeEntry`, and runtime dispatch. The accepted no-arg `.push`
  dispatches the matched child, appends the child return to the current rule's same-named accumulator, and
  suppresses the child's return event from leaking into the shared engine accumulator; `.return(expr)` evaluates
  the expression in the current rule/action context and exits without recursively dispatching the close-edge
  child. The tclite oracle was not re-enabled in this slice because this exposed additional non-action-edge
  blockers: compact lifecycle/body fluent forms like `I.return(...)` are still parsed as standalone
  `FluentChain` elements that the compiler drops, and shipped recursive default rules still depend on
  default-mode repetition parity. Those stay owned by follow-on leaves rather than broadening `.2.3.3.1`.

- `2026-06-30` (**`.2.3.2` lifecycle value/drop and return-channel lock**). Lifecycle blocks are statement
  blocks, not expression-valued blocks. Ordinary final statement values are discarded; use a top-level
  `return(expr)` when the lifecycle block must write the surrounding rule/action return channel. That differs
  from expression-valued block `return(expr)`, which is block-local and yields only that value block. Perl
  phase0 now source-locks all seven lifecycle markers and runtime-locks final-statement discard, top-level
  lifecycle return, and block-local return contrast. Rust runtime now has focused `.2.3.2` locks for the same
  value/drop distinction and its existing top-level return-event shape.

- `2026-06-30` (**`.2.3.3` Rust fluent parity split before code**). `.2.3.3` is a container, not one
  implementation leaf. The tclite-unblocking action-edge continuation gap is a narrow parser/compiler/runtime
  seam already owned by `RUST-PARITY.7.5.3`: no-arg `.push` and `.return(expr)` after `->` action edges.
  Attached fluent block payloads (`.when(cond) { ... }.otherwise { ... }`) require different parser and
  runtime representation, and remaining standalone/body fluent-chain drops require their own audit. Frontier
  moves to `.2.3.3.1`.

- `2026-06-30` (**`.2.3.1` Perl fluent block-chain contract landed**). The true-branch probes from the
  `.2.3` split were insufficient: a false `when` condition showed the dotted and no-dot fluent `otherwise`
  continuations were parsed away rather than executed. The correct seam is the bootstrap method-empty chain
  tail parser, not `ActionIR::ControlFlow`: it already knows how to lower attached `otherwise { ... }` once the
  statement reaches it. `.2.3.1` therefore makes the bootstrap parser accept an optional leading dot before
  attached fluent tail clauses, treats `when` as an attached fluent-if head alongside `if`/`i`, and recognizes
  `otherwise` as an attached fallback tail alongside `else`. The accepted Perl reference contract now covers
  both `.when(cond) { ... }.otherwise { ... }` and `.when(cond) { ... } otherwise { ... }` on action-edge and
  lifecycle surfaces.

- `2026-06-30` (**`.2.3` fluent/lifecycle/composability split after ground truth**). `.2.3` is a container,
  not an implementation leaf. TOOLBOX probes show the Perl reference already accepts exact fluent block chains
  on action and lifecycle surfaces (`.when(cond) { ... }.otherwise { ... }`) with no raw fallback, but Rust
  has no expression fluent attached-block payload and still drops some action/body fluent continuations. The
  lifecycle block syntax exists, but "drop the value" needs a precise distinction between discarded final
  expressions and explicit `return(expr)` writing the surrounding rule/action return channel. Nested helper
  composition is real for representative calls, while value-returning receiver-dot methods are still
  unsupported and must not be conflated with the statement-only Round 1 array mutation methods. Therefore the
  split is `.2.3.1` Perl fluent block-chain lock, `.2.3.2` lifecycle value/drop/return-channel lock,
  `.2.3.3` Rust fluent block-chain/action-edge parity, `.2.3.4` full composability audit, and `.2.3.5`
  return-type method chaining design/split.

- `2026-06-29` (**`.2.1` expression-valued blocks split after ground truth**). KM retrieval and TOOLBOX probes
  show this is not one safe implementation leaf. Perl currently treats `{}` and `{ key => value }` as shape
  literals, but block-like values such as `return({ set(x,"a"); x })` lower into invalid generated Perl
  (`return { $x = "a"; x }`) and `set(out, { ... })` takes the aggregate target-inference path. Rust has
  `CodeBlock` statements and hash/array literal `Expr` variants, but no block-expression AST or runtime
  evaluator. Therefore `.2.1.2` owns the Perl reference core, `.2.1.3` owns Rust parity, and `.2.1.4` is kept
  for true block-local early-return semantics if final-only `return(expr)` is not enough.

- `2026-06-29` (**`.2.1.2` Perl-reference core expression-valued blocks landed**). Non-empty brace payloads
  without a top-level `=>` now lower as Perl value blocks in value-consuming slots, while `{}` and
  `{ key => value }` remain hash shape literals. The accepted core supports last-expression values and final
  `return(expr)` as block-local payloads; full early return remains split to `.2.1.4`. Rust parity remains
  split to `.2.1.3`.

- `2026-06-29` (**`.2.1.3` Rust expression-valued block parity owned before code**). Rust code-read shows the
  parity gap is `Expr` plus runtime expression evaluation, not lifecycle block parsing. `parse_expr()` sends
  `{` to `parse_hash_literal()`, preserving `{}` and keyed `=>` hashes but rejecting non-empty non-fat-arrow
  brace payloads. `execute_block()` returns `()`, while `eval_expr()` has no block-value arm. `.2.1.3` owns
  adding parser/runtime parity for the Perl core; `.2.1.4` keeps true mid-block early return.

- `2026-06-29` (**`.2.1.3` Rust expression-valued block parity landed**). Rust now has `Expr::BlockValue` and
  brace disambiguation that preserves `{}` / keyed `=>` hash literals while parsing non-empty non-fat-arrow
  braces as block values. Runtime `eval_block_value()` executes side-effect statements and returns the final
  expression or final `return(expr)` payload. Non-final `return(expr)` is rejected/deferred to `.2.1.4` to
  avoid leaking a surrounding rule return.

- `2026-06-30` (**`.2.1.4` expression-valued block early return landed**). Perl and Rust now support
  `return(expr)` anywhere inside an expression-valued block. The return is block-local: it yields `expr` as
  the block value, skips later statements in that block, and does not set the surrounding rule return channel.
  Hash-literal precedence is unchanged for `{}` and top-level-fat-arrow `{ key => value }`.

- `2026-06-30` (**`.2.2.1` control-flow keyword surface split before code**). `.2.2` is too broad for one
  signoff slice. Perl attached `if(...) { ... } else { ... }` still executes through RAW_PERL fallback and
  is not ActionIR-ready; `when(...) { ... } otherwise { ... }` currently depends on host Perl experimental
  `when` behavior and is not a DSL contract; `while(...) { ... }` is raw. Rust already supports
  statement-marker `if(cond); ... elseif(cond); else(); ... endif()` gating and lazy inline-composite
  `if`/`switch`, but does not parse/execute attached statement blocks for `if`, `switch`, `when`,
  `otherwise`, or `while`. The implementation split is Perl attached-if, Rust attached-if parity,
  `when`/`otherwise`, attached switch/default, and while.

- `2026-06-30` (**`.2.2.5.1` Perl attached-switch separator/source lock landed**). The accepted Perl reference
  rule is splitter-driven: adjacent attached `case(...) { ... }` and `default { ... }` branch bodies must be
  separate DSL statements even when they share one physical line inside a `switch(...) { ... }` body. Once split,
  the existing attached-switch `ControlFlow` lowerers emit the guarded first-match/default sequence. This leaf
  deliberately preserves the statement-separator contract from `.1.5.4`: after the final attached switch block,
  an ordinary same-line statement still needs `;`. At the close of `.2.2.5.1`, Rust parity was still separate
  under `.2.2.5.2`; `.2.2.5.2` has since landed and made attached statement `switch/case/default` portable.

- `2026-06-30` (**`.2.2.5.2` Rust attached-switch parity landed**). Rust implements the accepted attached
  switch contract by normalizing attached branch blocks in `CodeBlock::parse` to statement controls and gating
  those controls with a runtime switch stack. The branch rule is first-match/default, inactive branch side
  effects are skipped, and lazy value-form `switch(expr, case(...), default(...))` remains on the lazy helper
  path. Portable variable-driven switch subjects should use explicit value expressions such as `scalar(kind)`.
  Attached statement `switch/case/default` is now portable; frontier moves to `.2.2.6` for `while`.

- `2026-06-30` (**`.2.2.6` split/owned before code — attached `while(cond) { ... }`**). KM and TOOLBOX
  probes show current Perl keeps `while(...) { ... }` as raw host code (`ready=0 raw=1 fallback=1`) and Rust
  has no attached statement-loop parser/runtime. Split `.2.2.6` into `.2.2.6.1` for the Perl reference
  loop/safety contract and `.2.2.6.2` for Rust parity. The safety contract is explicit: non-terminating loops
  must hit a deterministic iteration guard rather than hang generated parsers. Frontier moves to `.2.2.6.1`.

- `2026-06-30` (**`.2.2.6.1` Perl attached-while loop/safety landed**). Perl now lowers
  `while(cond) { ... }` through ActionIR with no raw fallback or unresolved helper residue. The condition is
  evaluated before every iteration, body statements can mutate the condition state, `return(expr)` returns from
  the surrounding rule/action, and a deterministic 10000-iteration guard prevents parser hangs. Frontier moves
  to `.2.2.6.2` for Rust parity.

- `2026-06-30` (**`.2.2.6.2` Rust attached-while parity landed**). Rust now parses attached
  `while(cond) { ... }` as a lazy statement loop over a parsed body block and executes it with condition
  re-evaluation, normal statement-body semantics, expression-valued block-local `return(expr)`, and the same
  deterministic 10000-iteration guard as the Perl reference. The documented numeric comparison helper family
  is now present on Rust, so the portable counter-loop pattern is covered by the 39-fixture oracle corpus.
  Frontier moves to `.2.3`.

- `2026-06-29` (**`.1.6` array end-mutation methods landed**). The accepted Round 1 array method contract is
  statement-level mutation, not value-returning fluent chaining. A single receiver-dot call with receiver
  `name`, `array(name)`, or `a(name)` mutates the named working array: `push_back(value)` appends,
  `push_front(value)` prepends, `pop_back()` removes the last item, and `pop_front()` removes the first item.
  Push arguments use the settled mutation-slot value rules, including scalar bare reads; pop methods discard
  the removed value. Canonical ActionIR reports `ARRAY_MUTATE` so push and pop share one mutation-family node
  without overloading `PUSH`. Value-returning forms such as `return(items.pop_back())` are deliberately left
  to a later expression-valued/fluent slice.

- `2026-06-29` (**`.1.2.3.5.4` Rust RHS shape target-kind inference landed**). Rust mirrors the accepted
  Perl aggregate target-kind rule for direct RHS shape literals. The runtime classifies only direct
  `Expr::ArrayLiteral` / `Expr::HashLiteral` RHS AST nodes as shape-inference sources, evaluates the shape
  through normal expression evaluation, then replaces the matching runtime aggregate slot for bare targets and
  explicit `array(...)` / `hash(...)` targets. Explicit `scalar(...)` targets are the scalar payload boundary
  and intentionally fall through to scalar assignment. The `.1.2.3.5` split is now closed on both variants.

- `2026-06-29` (**`.1.2.3.5.2` Perl RHS shape target-kind inference landed**). The accepted Perl-reference
  rule is source-driven for bare assignment targets only: a direct array shape RHS (`[]` / `[value]`) initializes
  the bare target as an array working variable, and a direct hash shape RHS (`{}` / `{ key => value }`)
  initializes it as a hash working variable. Therefore `items = [value]`, `set(items, [])`, and
  `assign(items, [value])` assign `@items`, while `meta = { key => value }` and `set(meta, {})` assign `%meta`.
  Non-shape RHS values keep the settled scalar assignment contract (`name = value` -> `$name = $value`).
  Explicit wrappers are the opt-out/override: `set(scalar(payload), [value])` stores the whole array payload in
  `$payload`; `set(array(items), [value])` and `set(hash(meta), { key => value })` remain explicit aggregate
  assignment. Declaration initializer direct shapes use the same member-lowering contract as shape values.
  Rust parity remains split into `.1.2.3.5.3` (shape values) and `.1.2.3.5.4` (target inference).

- `2026-06-29` (**`.1.2.3.5.1` Perl shape-literal value expressions landed**). Direct `[]` / `{}` forms are
  now DSL value expressions on the Perl reference. The accepted shape subset lowers direct array elements,
  hash keys, and hash values through scoped value-expression rules, so `[value]` and `{ key => value }` read
  scalar working variables and auto-supply matching `my` declarations. Bare hash-literal keys are dynamic, not
  fixed strings; write `{ "kind" => value }` for a fixed field name. This leaf intentionally did not implement
  target-kind inference; `.1.2.3.5.2` later accepted aggregate inference for direct RHS shapes. Direct-access
  brackets, hash-index assignment brackets, future block braces, helper calls, and all-bare child-call routing
  stay separate surfaces.

- `2026-06-29` (**`.1.2.3.5` RHS-shape/type-inference split by mechanism**). The remaining Channel 2 shape
  work is not one implementation leaf. At split time, Perl already accepted raw empty `[]` and `{}` in
  value/source slots, but only as scalar arrayref/hashref expressions (`name = []` assigns `$name`, while
  `items += []` mutates
  `@items`; those slots are distinct). Non-empty shapes such as `[value]` and `{ key => value }` passed through
  raw Perl at split time and turned bare identifiers into barewords/strings, not the settled scalar
  working-variable reads. Rust has no bracket/brace value-expression parser. Therefore the first safe leaf is Perl
  shape-literal value expressions (`.1.2.3.5.1`), followed by Perl RHS target-kind inference
  (`.1.2.3.5.2`), then Rust parity for each accepted contract (`.1.2.3.5.3` and `.1.2.3.5.4`). Direct-access
  brackets, hash-index assignment brackets, future block braces, helper-call syntax, and all-bare child-call
  routing must stay protected.

- `2026-06-29` (**`.1.2.3.4` Rust scalar bare-read parity landed**). Rust scalar bare-read parity required
  removing parser reservations, not changing runtime scalar evaluation: `Expr::Variable` already reads
  `RuntimeContext` scalars with `ctx.get_scalar(name)`. Rust now accepts the same scalar read slots as the Perl
  `.1.2.3.3` contract: source slots (`return(value)`, `set(out, value)`, `name = value`), mutation key/RHS slots
  (`items += value`, `meta[key] = value`), and direct-access bare path atoms (`foo["a"][idx]`). One-level
  `name[index]` keeps the legacy indexed-variable parse path. RHS-shape/type inference is not implemented here;
  it is now tracked explicitly as `.1.2.3.5`.

- `2026-06-29` (**`.1.2.3.3.3` Perl direct-access bare path atoms landed**). The accepted direct-access
  bare-path rule is scalar-index: in direct nested access, a non-reserved bare atom inside `[]` reads the scalar
  working variable of that name and indexes an array segment. Therefore `foo["a"][z]` is equivalent to
  `foo["a"][scalar(z)]` and lowers to `$foo->{"a"}->[$z]`, not to a hash-key read. Quoted path segments remain
  hash keys; numeric/helper path segments remain array indexes. Primitive literals and engine locals such as
  `true` and `CAPTURE` are not claimed as path variables. `scalaref(...)` compatibility is intentionally
  unchanged: `scalaref(foo,{"a"}[z])` keeps its historical bare `[z]` path atom, so callers should write
  `[scalar(z)]` inside `scalaref(...)` when they want a working scalar index. This closes the Perl scalar
  `.1.2.3.3` container; Rust scalar parity later landed under `.1.2.3.4`.

- `2026-06-29` (**`.1.2.3.3.2` Perl scalar mutation-slot bare reads landed**). The mutation-slot leaf changes
  only accepted statement mutation value/key slots: array append RHS (`items += VALUE`), statement-level
  named-hash mutation key/RHS (`set_key(meta, KEY, VALUE)`), and hash-index operator key/RHS
  (`meta[KEY] = VALUE`). Non-reserved bare identifiers in those slots lower to scalar working-variable reads
  and get matching `my $NAME` declarations. Target inference is unchanged (`items` is `@items`; `meta` is
  `%meta`), primitive literals keep their typed value semantics, reserved engine locals are not claimed, direct
  path atoms remain deferred, and all-bare `push(A,B)` remains child-call syntax.

- `2026-06-29` (**`.1.2.3.3.1` Perl scalar source-slot bare reads landed**). The source-slot leaf changes only
  return and assignment-like scalar source lowerers: `return(NAME)`, `set(out, NAME)` / `assign(out, NAME)`,
  and scalar operator `out = NAME` now lower to `$NAME` and get a matching per-invocation `my $NAME`. The
  implementation deliberately avoids `_lower_method_value_expr`, so generic helper arguments, array append RHS,
  hash mutation key/RHS slots, and direct path atoms do not advance. Primitive literals remain exact:
  `return(true)` stays a JSON boolean, `return(undef)` stays undef, while prefix identifiers such as
  `trueword`/`undefine` are ordinary scalar reads in these source slots. `push(A,B)` remains child-call syntax.

- `2026-06-29` (**`.1.2.3.3` Perl scalar bare reads split by lowering seam**). The scalar-read owner is still too
  broad for one code slice. TOOLBOX probes show return and assignment-like source slots fall through to raw
  barewords (`return(count)` -> `return count`; `set(out,count)` -> `$out = count`; `name = value` ->
  `$name = value`). Mutation forms use different acceptance gates: `set_key(meta,key,"v")` already lowers the
  bare key as `$key`, but bare values remain raw, while array append and hash-index operator forms reject bare
  RHS/key tokens before lowering. Direct access has its own explicit guard: `foo["a"][z]` remains raw while
  `foo["a"][scalar(z)]` lowers. Therefore `.1.2.3.3` becomes a container with `.1.2.3.3.1` return/assignment
  source slots first, `.1.2.3.3.2` mutation key/RHS slots next, and `.1.2.3.3.3` direct-access bare path atoms
  after the scalar-index rule is explicit. `push(A,B)` remains protected as child-call syntax.

- `2026-06-29` (**`.1.2.3.2` Rust aggregate bare value-read parity landed**). Rust now matches the Perl
  aggregate snapshot-read contract by allowing bare aggregate target names at the aggregate-copy resolver
  call sites: `array_copy(NAME)` and array-first `copy(NAME)` read array `NAME`, while `hash_copy(NAME)` reads
  hash `NAME`; `copy(hash(NAME))` stays the explicit wrapped hash-copy form. The implementation did not change
  generic `Expr::Variable` scalar evaluation or parser acceptance, so scalar bare reads, bare hash-index
  key/RHS forms, and bare direct-access path atoms remain owned by `.1.2.3.3`.

- `2026-06-29` (**`.1.2.3.1` Perl aggregate bare value-read auto-existence landed**). Aggregate snapshot
  helpers are now type-implying read positions on the Perl reference: `array_copy(NAME)` and `copy(NAME)` imply
  the array working variable `NAME`, while `hash_copy(NAME)` implies the hash working variable `NAME`. The
  collector only supplies the missing per-invocation lexical preamble (`my @NAME` / `my %NAME`) for forms that
  already lower to sigiled aggregates; it does not change scalar bare reads (`return(NAME)`), bare RHS/key forms,
  or bare direct-access path atoms. `copy(NAME)` follows the existing array-first `copy` rule. Rust parity landed
  separately in `.1.2.3.2`.

- `2026-06-29` (**`.1.2.3` Channel 2 split by aggregate/scalar value-read surfaces**). TOOLBOX probes and
  code-read show Channel 2 is not one implementation seam. Perl aggregate bare value reads already lower to
  sigiled variables (`array_copy(items)` -> `[@items]`, `hash_copy(meta)` -> `{%meta}`, `copy(items)` ->
  `[@items]`) but lack auto-`my`, so they are a scoped Perl auto-existence leaf. At split time, Rust did not yet
  mirror those bare aggregate value reads because aggregate-copy resolvers kept `allow_bare=false` in value-read
  positions; `.1.2.3.2` has since closed that parity leaf. Scalar-like value reads are separate: Perl still
  emits barewords/raw code for `return(count)`,
  `set(out,count)`, `items += value`, `meta[key] = value`, and `foo["a"][z]`, while Rust already evaluates a
  plain `Expr::Variable` as a scalar read. Therefore `.1.2.3` becomes an active container: `.1.2.3.1` Perl
  aggregate auto-existence, `.1.2.3.2` Rust aggregate parity, `.1.2.3.3` Perl scalar bare reads, `.1.2.3.4`
  Rust scalar parity, and `.1.2.3.5` RHS-shape/type-inference split before code.

- `2026-06-29` (**`.1.5.5.2` merged into `.1.2.3` Channel 2**). A focused reverify after explicit direct
  access landed still showed the same boundary: `foo["a"][9]["b"][scalar(z)]` lowered through the canonical
  dereference path, but `foo["a"][9]["b"][z]` remained raw and `return(z)` remained a bareword. Rust also kept
  bare direct-access segments rejected as Channel 2-reserved at merge time. Therefore `[z]` could not be
  defined locally as a direct-access index rule without pre-empting the broader value-position bare-word-read
  semantics. The work was merged into new `.1.2.3`, which now owns the Channel 2 design/split across
  `return(name)`, bare direct path
  atoms, bare RHS/key expressions, and RHS-shape/type inference.

- `2026-06-29` (**`.1.5.5.1` direct nested access with explicit segments**). The accepted direct-access
  subset is intentionally explicit: `foo["a"][9]["b"][scalar(z)]` is canonical, `foo["a"][9]["b"][z]` is not.
  Quoted string segments (`["a"]` / `['a']`) are hash-key segments. Numeric and helper/value-expression
  segments (`[9]`, `[scalar(z)]`) are array-index segments. Perl lowers the direct path through the same
  dereference semantics as the historical `scalaref(foo,{"a"}[9]{"b"}[scalar(z)])` path, and Rust models the same mixed path with
  `Expr::NestedAccess`. A single one-level non-key `foo[index]` remains the legacy indexed-variable form.
  Bare path atoms remain reserved for `.1.5.5.2` / Channel 2 so this leaf does not pre-empt the global
  bare-value-read model.

- `2026-06-29` (**`.1.5.5` direct nested access split** — explicit segment expressions before bare
  Channel 2 segments). TOOLBOX probes show direct `foo["a"][9]["b"][scalar(z)]` is not a valid lowered value
  expression today: it passes through as `foo["a"][9]["b"][$z]` and generated handler compilation fails near
  `][`. The then-existing `scalaref(foo,{"a"}[9]{"b"}[scalar(z)])` path was the working explicit syntax and
  lowers to `$foo->{"a"}->[9]->{"b"}->[$z]`. Bare path segment `z` is still a bare atom, so the full
  brainstorm spelling `foo["a"][9]["b"][z]` depends on Channel 2 value-position reads. Therefore `.1.5.5`
  becomes a container: `.1.5.5.1` implements explicit path segments first; `.1.5.5.2` owns bare path
  segments / Channel 2 coordination.

- `2026-06-29` (**`.1.5.4` statement separator contract** — newline-or-semicolon, not arbitrary whitespace).
  Newlines are the only implicit top-level DSL statement separator; semicolons remain accepted and are required
  when multiple helper statements share one physical line. Perl and Rust now agree on that boundary:
  `set(name,"a")` newline `return(scalar(name))` lowers/runs, `set(name,"a"); return(scalar(name))` still
  lowers/runs, and `set(name,"a") return(scalar(name))` stays non-canonical/rejected. Perl lowering must emit
  a generated `;` between newline-separated lowered statements because a newline in `.spec` source is not a
  Perl statement terminator. Nested semicolons inside payloads such as `do { my $x = 1; $x }` stay protected.
  Fluent attached-control tails are normalized by Bootstrap into newline-separated helper statements instead
  of weakening the splitter: user-facing `Top.if(...) { ... } elseif(...) { ... } else { ... }` remains
  supported, but ordinary same-line adjacent helpers do not.

- `2026-06-29` (**`.1.5.2` primitive literal parity** — exact literals are typed values, not prefix
  identifiers). The accepted rule is deliberately exact: `"..."`, `'...'`, integer, float, `undef`, `true`,
  and `false` are primitive value expressions; `trueword`, `falsehood`, and `undefine` are identifiers and keep
  the pre-existing bare-word / legacy dispatch behavior. Perl lowers `true`/`false` through `JSON::PP` boolean
  objects so serialized output agrees with Rust typed booleans. Scanner and lowerer guards share that boundary:
  `push(items,false)`, `items += false`, and `meta[true] = false` are explicit value forms, but
  `push(items,trueword)` remains the historical all-bare child-call form. Rust parity required statement-form
  control-flow gating, because Rust expression values were already typed but `if(false); return(...); else();`
  did not skip inactive statements. The statement marker grammar is scoped to one-arg `if`/`elseif` and
  zero-arg `else`/`endif`; multi-arg lazy `if(cond, then, else)` is unchanged.

- `2026-06-29` (**`.1.5` split by value surface, call/separator surface, and access semantics**). `.1.5`
  is not one implementation seam. Ground truth shows four different risk classes: (1) primitive literals are
  partly landed, but Perl `true`/`false` currently execute as the strings `"true"`/`"false"` while Rust has
  typed booleans; (2) optional whitespace before `(` already works at real helper/value sites and mainly needs
  regression locks; (3) newline-separated adjacent DSL statements are detected by `StatementSplit` but still
  generate invalid Perl without an inserted `;`, while Rust currently accepts broader whitespace-separated
  statements; (4) direct any-depth `foo["a"][9]['b'][z]` is still distinct from the existing explicit
  `scalaref(base,path)` helper and must coordinate with Channel 2 value-position bare-word reads. Therefore
  `.1.5` is an active container, `.1.5.1` is the audit/split close-out, and the frontier starts with
  `.1.5.2` primitive literal parity.

- `2026-06-29` (**`.1.3.4.3` hash-index assignment operator** — direct hash mutation, explicit key/value
  expressions). The accepted rule is intentionally narrow: a top-level lifecycle statement `NAME[KEY] = RHS`
  is equivalent to `set_key(NAME, KEY, RHS)` and auto-exists `NAME` as a hash target. `KEY` and `RHS` must be
  explicit expressions under the current DSL (`"stage"`, `cat(...)`, `scalar(key)`, `scalar(value)`, etc.).
  Bare key/RHS identifiers remain reserved because Channel 2 still owns bare value-position working-variable
  reads and RHS-shape inference. Rust mirrors the boundary with a statement-only `AssignHashIndex` AST variant,
  and Perl only records a hash auto-declaration when the same parser accepts the statement. Value-form
  `set_key(hash_expr, key, value)` remains pure/copy-valued.

- `2026-06-29` (**`.1.3.4.2` array append operator** — append statement, not value-position inference).
  The accepted rule is intentionally narrow: top-level `NAME += RHS` is an array-target statement equivalent
  to explicit append only when `RHS` is already an explicit value expression. The LHS is a type-implying array
  target and auto-exists (`my @NAME` on Perl, per-parse array map on Rust). Bare RHS `NAME += value` is not
  accepted because Channel 2 still owns bare value-position working-variable reads; authors must write
  `NAME += scalar(value)` or another explicit expression. This keeps `+=` from re-opening the `push(A,B)`
  child-call ambiguity or silently inventing a bare read model before `.1.2.3`+.

- `2026-06-29` (**`.1.3.4.1` scalar assignment operator** — statement-only target-position assignment, not
  general expression assignment). The accepted rule is intentionally narrow: a top-level lifecycle statement
  `NAME = RHS` is equivalent to `set(NAME,RHS)` / `assign(NAME,RHS)` and auto-exists `NAME` as a scalar target.
  It is parsed/lowered before generic expression evaluation and only for a plain identifier followed by a
  single assignment `=`. This leaf deliberately does not claim equality (`==`), fat-arrow/keyword-arg syntax
  (`=>`, `helper(name=value)`), array append (`+=`), hash-index assignment (`name[key] = value`), nested
  assignment expressions, or Channel 2 value-position bare-word reads. Rust mirrors the boundary with a
  statement-only `AssignScalar` AST variant and rejects it from `eval_expr`.

- `2026-06-29` (**`.1.3.4` split by operator target/mechanism** — scalar assignment first). Evidence says the
  operator family is not one safe implementation slice. On Perl, each operator form is currently a RAW_PERL
  blocker and needs explicit statement recognition/lowering; on Rust, the lifecycle code parser has only
  expression statements and needs statement/AST support before runtime execution. The accepted sequencing is:
  `.1.3.4.1` scalar `name = value` first (minimal assignment statement infrastructure, equivalent to
  `set(name,value)`), then `.1.3.4.2` array `items += value` (append semantics, inherits `.1.3.2`
  child-call/bare-value boundary), then `.1.3.4.3` hash `name[key] = value` (equivalent to settled
  `set_key(name,key,value)`). No engine/book behavior changes in the split slice.

- `2026-06-29` (**`.1.3.3` hash mutation statement** — statement-level `set_key(name,key,value)` mutates a
  named working hash; value-form `set_key(hash_expr,key,value)` remains pure). The accepted rule is
  position-based: top-level `set_key(...)` statements whose first argument names a hash target mutate that
  target directly; nested `set_key(hash(...),...)` remains a copy-valued expression and does not mutate its
  source unless assigned back. Perl implements this as an ASSIGN contract/scanner/lowerer and auto-declares
  bare hash targets as `my %name`; Rust mirrors it in `Engine::execute_block()` before normal expression
  evaluation. This closes the target-position hash mutation gap without claiming Channel 2 value-position
  bare-word reads.

- `2026-06-29` (**`.1.3.2` array function spelling** — conservative `push(target,value)` alias with child-call
  precedence preserved). The accepted rule is intentionally asymmetric: two-argument `push(...)` is an
  explicit-value append only when the second argument is not an all-bare identifier expression. Literals,
  typed wrappers (`scalar(value)`), wrapped targets (`array(items)`), helper value expressions (`cat(...)`),
  and `call(Child)` values are unambiguous and lower identically to `push_value(target,value)`. All-bare forms
  keep the historical child-call meaning because `push(A,B)` already means "call child rule `A` and append into
  accumulator `B`"; changing it would silently break existing `.spec` authoring and contradict the accumulator
  convention audit. A working-variable value therefore still needs an explicit read such as
  `push(items, scalar(value))` or `push_value(items, scalar(value))` until Channel 2 bare value-position reads
  provide a broader disambiguation model.
  The declaration collector for `push(...)` must parse balanced call syntax instead of using a comma-splitting
  regex, because values such as `cat("a","b")` contain nested commas and still need exactly one `my @items`.

- `2026-06-29` (**`.1.3` split by mechanism** — scalar function form already satisfied; array
  function spelling, hash mutation semantics, and operators separated; KM card
  [[terse-mutation-surface-ground-truth]]). TOOLBOX-first probes showed: `set(name,"ok")` and
  `assign(name,"ok")` both lower to `$name = "ok"` and run; `push_value(items,"a")` lowers/runs, but
  `push(items,"a")` passes through Perl lowering as raw `push(items, "a")` and fails handler compilation
  while colliding syntactically with existing child-call `push(Rule, target)`; `return(set_key(name,"k","v"))`
  works in Perl as a pure hash-valued expression but `set_key(name,...)` is not a standalone mutation
  statement and Rust only updates when arg0 already evaluates to a hash; `name = "ok"`, `items += "a"`,
  and `name["k"] = "v"` pass through as invalid/raw Perl and Rust has no assignment/`+=` statement AST.
  Therefore `.1.3` cannot be a single implementation commit without bundling unrelated parser/lowering
  mechanisms and risking the live `push(...)` child-call convention.

- `2026-06-24` (**`.1.4` split by variant** — Perl reference `.1.4.1` + Rust lockstep parity `.1.4.2`;
  grounded by a TOOLBOX-first `call_spec_handler_subst` ground-truth pass, dump-don't-guess; KM card
  [[terse-helper-rename-lowering-sites]]). Per the splitting rule, a Perl-reference engine change and its
  lockstep Rust-parity obligation (ADR 0006) are separable and touch unrelated ownership areas (Perl
  `ActionIR/*` + `t/phase0_regression.t` + book vs Rust `engine.rs` + oracle corpus + cargo tests), which
  COMMIT.md forbids bundling in one commit — mirroring how `.1.1`→`.1.1.1`/`.1.1.2` and
  `.1.2`→`.1.2.1`/`.1.2.2` split. **Confirmed engine facts (own probes, `perl -Iperl` → `perl/LinkedSpec.pm`):**
  the three terse spellings are all currently UNRECOGNIZED — `set(scalar(x),1)`→`set(scalar(x), 1)` (vs
  `assign`→`$x = 1`), `cat("a","b")`→`cat("a","b")` (vs `concat`→the concat do-block), `copy(a(items))`→
  `copy([items])` partial / `copy(h(m))`→`copy(h(m))` (vs `array_copy`→`[@items]` / `hash_copy`→`{%m}`).
  **Three distinct implementation shapes** (why a single `_normalize_method_name` alias does NOT cover the
  leaf): (i) `cat`→`concat` IS a pure rename → the clean home is `_normalize_method_name`
  (`ActionIR/MethodExpr.pm:19-26`, applied pre-lowering — same seam as `s`/`a`/`h`→`scalar`/`array`/`hash`;
  the retired `tail`/`flatten`/`array_values` aliases were the inline-conditional pattern, removed in
  `COMPAT-ALIAS-RETIREMENT.1`). (ii) `set`→`assign` is **statement-level** — `assign` is recognized by the
  raw-text regex `\bassign\s*\(` at `ActionIR/Contracts.pm:1749/1753` and lowered via
  `ActionIR/DeclareMethod._lower_assign_method_statement` + `ActionIR/MethodLowering._lower_assign_statement`,
  a path `_normalize_method_name` does not reach (probe: `set(...)` is fully unrecognized) — so `.1.4.1`
  must add `set` to the statement-level recognition (resolve the exact seam with `dump_parser_source`).
  (iii) `copy` is **not** a pure rename — it unifies `array_copy`/`hash_copy`, so it needs a dedicated
  dispatch in `MethodLowering._lower_method_value_expr` resolving array-then-hash symbol kind (Perl:
  `extract_array_symbol_name` → `[@name]` else `extract_hash_symbol_name` → `{%name}`; Rust: a value-type
  match-arm — Array→clone, Hash→clone). **Rust sites:** all four canonical helpers live in one
  `Engine::call_helper()` match (`rust/linkedspec-runtime/src/engine.rs`: `assign`@711, `array_copy`@735,
  `concat`@820, `hash_copy`@1833; aliases = pipe arms `"array" | "a"`); `.1.4.2` pipes `set`/`cat` and adds a
  separate value-type-dispatching `"copy"` arm (a literal can't repeat across two arms). Direction per ADR
  0007: the new terse names become canonical, old names stay deprecated aliases that lower identically
  (retirement is a later explicit leaf); both spellings must lower byte-identically and the 20 shipped specs
  (old names) must stay byte-identical. `.1.4` is now a container; no engine/book change in this split slice
  — it owns the design + frontier only.
- `2026-06-24` (**`.1.2.1` scope — Channel 1 = unambiguous first-arg value-helper positions only**,
  grounded by `dump_parser_source` probes; dump-don't-guess). The auto-`my` sigil MUST match the sigil the
  lowering actually emits, or the engine would create a dead `my` and leave the real variable still leaky.
  Confirmed lowerings for a bare target: `assign(NAME, …)` → **scalar** `$NAME` (always — `_lower_assign_
  statement` tries `_extract_scalar_symbol_name` first, whose `^(\w+)$` fallback claims any bare name before
  the array/hash branches are reached), and `push_value(NAME, …)` / `push_nonempty(NAME, …)` → **array**
  `@NAME`. These are the unambiguous *first-arg* positions, so Channel 1 collects exactly them. **Deferred
  to Channel 2 (with evidence):** (i) the child-append `push(Rule[, target])` / fluent `.push(target)`
  target — its first arg is a **rule name**, not a working variable, so a naive `push\s*\(\s*(\w+)` would
  wrongly declare the rule; the target is a later positional arg that overlaps with the numeric-index form,
  i.e. genuinely ambiguous; (ii) a bare **hash** target — there is no clean bare hash arg position today:
  `assign(pair, …)` lowers scalar-first (so `assign(pair, set_key(hash(pair),…))` yields a scalar `$pair`
  holding a hashref, separate from the `%pair` the wrapped `hash(pair)` declares), and `set_key(name, …)` is
  a **value-position** read (returns a hashref), which is Channel 2 (value-position bare-word reads +
  RHS-shape). Implementation: a bare arg-position pass added to `_collect_auto_working_var_decls`
  (`RuleIR/EmitContext.pm`) beside the wrapped pass, sharing one `$record` dedup closure; the `\s*,` anchor
  after the bare name keeps a WRAPPED target on the wrapped path (no double-collection). Wrappers stay
  accepted aliases — they become OPTIONAL in these positions, not removed (gradual, ADR 0007). All 20
  shipped specs byte-identical (no un-wrapped arg-position targets in the corpus). KM card
  [[terse-bare-working-vars-engine-gaps]] updated to mark Channel 1 closed.
- `2026-06-24` (**`.1.2` split by inference channel**, grounded by `dump_parser_source` probes —
  dump-don't-guess; KM [[terse-bare-working-vars-engine-gaps]]). Confirmed engine facts for a **bare**
  (un-wrapped) working variable: (1) **arg position** — a bare name already lowers to the correctly-sigil'd
  variable (`assign(count, v)`→`$count = v` via ValueExpr `_extract_scalar_symbol_name`'s `^(\w+)$`
  fallback; `push_value(items,..)`/`.push(items)`→`push @items, ..`) BUT gets **no auto-`my`** (the
  `.1.1.1` collector regex matches only WRAPPED `scalar/array/hash(NAME)`), so it is a leaky package
  global — the exact `.1.1.1` hazard, still open for bare forms; (2) **value position** — a bare word is
  NOT recognized as a variable read (`return(count)`→ bareword `return count ;`, not `$count`); (3)
  **wrapped** refs DO get the auto-`my` (the `.1.1.1` result). So `.1.2` is two inference channels:
  **Channel 1** = arg-position auto-existence (extend the collector to bare type-implying positions;
  self-contained, lowest risk, directly extends `.1.1.1`) → `.1.2.1` (Perl) + `.1.2.2` (Rust parity);
  **Channel 2** = value-position bare-word variable reads + RHS-shape inference (`[]`→array, `{}`→hash;
  var/call/literal disambiguation), which couples with `.1.5` literal syntax → `.1.2.3`+ added once
  `.1.2.1` lands and `.1.5` is designed (not pre-published, to avoid vague placeholders). **Split rule:**
  Perl reference + lockstep Rust parity are separable (ADR 0006), mirroring the `.1.1`→`.1.1.1`/`.1.1.2`
  and `TOP-RULE-AS-NORMAL` `.2`/`.3` splits. Wrappers stay accepted aliases during migration (gradual,
  ADR 0007); shipped specs use them pervasively (declare 87 / assign 103 / scalar 133 / array 134 / hash
  36), so they must keep compiling byte-identically. `.1.2` is now a container; no engine/book change in
  this split slice — it owns the design + frontier only.
- `2026-06-24` (**`.1.1.2` assessment — DOABLE, no engine change**, grounded by throwaway Rust + Perl
  `LinkedSpec::Get` probes — dump-don't-guess). The Perl `.1.1.1` change was a **codegen** fix: generated
  handlers run non-strict, so an undeclared wrapper-referenced working var would silently become a leaky
  package global, and the engine now auto-injects a per-invocation `my` in the preamble. The Rust variant
  is an **interpreter**, not codegen+`eval` — working variables live in per-parse `RuntimeContext` HashMaps
  (`scalars`/`arrays`/`hashes`) that **auto-vivify** on write and read as `Undef`/empty when absent, and
  `Engine::execute` builds a **fresh `RuntimeContext` per call**. So in Rust working variables already
  auto-exist with no `declare`, and a value cannot leak across parses — the leaky-global hazard the Perl
  change fixed simply does not exist here. **Conclusion:** parity holds at the runtime level by
  architecture; the leaf lands as **lockstep regression tests + documentation**, not an engine change
  (adding a dead "collector" to mirror a fix for a non-existent hazard would be ceremony, not parity). The
  proof grammars use the **divergence-free edge-action form** (the `.7.1` oracle proof class), because the
  recursive/REP auto-exist idiom the Perl phase0 locks use is blocked by the separate `RUST-PARITY`
  recursive-grammar / REP-lifecycle gap (verified: those exact specs return `[null]`/`[[]]` on Rust). KM
  card [[rust-working-vars-auto-vivify]]. `declare(...)` stays meaningful for its `=init` seed form.
- `2026-06-23` (**`.1.1` design + split**, grounded by `dump_parser_source` probes — dump-don't-guess;
  KM [[working-vars-no-strict-need-my-lexical]]). Verified engine facts: (i) a rule's `I`-block + all
  edges + `LX` compile into **one** `sub` / **one** lexical scope (`SpecEntry::_build_runtime_handler` /
  `_build_handler_preamble`); `declare(scalar,x)`→`my $x`, `declare(array,x)`→`my @x`,
  `declare(hash,x)`→`my %x` emitted **once** in the preamble (after the auto `my @<label>;` accumulator),
  before the `while(1)` dispatch loop. (ii) Generated handlers run with **no `use strict`**
  (`SpecEntry.pm` has neither `use strict` nor `no strict`), so a working var used WITHOUT `declare`
  silently becomes a **leaky package global** (state-leaks across invocations/recursion) — it does NOT
  fail loudly. So the purpose of auto-existence is to make first-used working vars **per-invocation `my`
  lexicals**. **Design for `.1.1.1`:** a **rule-level** pass collects every typed-wrapper variable
  reference (`scalar(NAME)`/`array(NAME)`/`hash(NAME)` + `s()/a()/h()` aliases, single bare-identifier
  arg) across all of a rule's blocks, takes the sigil from the wrapper (no inference — that is `.1.2`),
  and injects a single `my $NAME`/`@NAME`/`%NAME` into the preamble. **Dedup** against the `@<label>`
  accumulator and any explicit `declare`d name (which keeps emitting its own `my`) so there is no double
  `my`. Injection MUST be preamble-level, not inline-at-first-use — an inline `my` in an edge would
  re-run each dispatch iteration and reset an accumulator. Preserve ratio 1.0000 (ADR `0002`). **Split:**
  Perl reference (`.1.1.1`) vs Rust lockstep parity (`.1.1.2`, ADR `0006`) are separable (mirrors how
  `TOP-RULE-AS-NORMAL` split `.2` Perl vs `.3` Rust); `.1.1` is now a container. No engine/book change in
  this split slice — it owns the design + frontier only.
- `2026-06-18` (design refinement — user inputs, pending ratification in the named leaves): (a)
  **call syntax** for operator/comparison functions — user proposed a Lisp callee-inside-paren form
  `(op a, b)` alongside `op(a, b)`; my recommendation (uniform `callee(args)`, word canonical +
  symbol alias, no `(op …)` form) recorded in Open Questions → ratify in `.3.2`. (b) **everything is
  an expression → typed values**, so operator-functions return a typed value carrying the methods of
  that type, **chainable, and the type may change along the chain** (sharpens `.2.3`'s "method
  chaining by return type"). (c) **semicolons are mandatory between statements on the same line**
  (reconfirms `.1.5` / the card — no change). (d) Guiding principle the user stated for the wider
  codebase (not terse-format-specific, captured in [[feedback_keep-only-portable-cross-variant]]):
  **keep only what can be ported / have a Rust/Dart/Julia/Lua variant** — Perl-only non-portable legacy
  is retirement debt (drives the RTLUtils/FSMGen/VHDL retirement, see Blockers).
- `2026-06-18`: **ACTIVATED + RATIFIED (user).** The user activated the tree (AskUserQuestion choice
  "Activate SPEC-FORMAT-TERSE now", during `SPEC-LANG-REFERENCE.10.5.4`) and reinforced the key
  semantics in their own words across several messages — all consistent with the brainstorm card +
  the Round 1–3 transcription below: `assign(x,v)`→`x = v` (op) / `set`; **no sigils** (bare typed
  identifiers, no `scalar()/array()/hash()` wrappers); type inference at init or by argument position;
  `copy()` unifies `array_copy`/`hash_copy` (arrays + hashes); arrays/hashes/numbers/strings have
  **methods** (chain by return type); **everything is an expression** → typed values, control flow +
  `{}` blocks are expressions. Recorded as ADR
  [`0007`](../decisions/0007-spec-format-terse-direction.md). `.0` done. **Migration policy ratified:
  canonical-new + deprecated-old-alias (gradual), then explicit retirement** (open to a user override
  toward one-shot hard rename). Touching the Perl reference for this evolution is a **user-sanctioned
  exception** to [[feedback_do-not-fix-reference-engine]]. Consequence: `SPEC-LANG-REFERENCE` book
  scorch paused; implementation leaves `.1.x`+ gated by a usable `t/phase0_regression.t`
  (`RTLUTILS-REGEX-HANG`) — execution-order decision surfaced to the user.
- `2026-06-16`: Created tree to formalize the 2026-06-15 brainstorm so the direction is owned and
  pivotable, not just a KM memo. Status `proposed`; implementation deferred until after the RTLUtils
  hang fix (user directive 2026-06-16). *(Superseded 2026-06-18: user activated the tree; `.0` ratified
  the direction. The RTLUtils gate now constrains only the implementation leaves, not `.0`.)*
- `2026-06-16`: The brainstorm is the converged-but-tentative direction (per the card, "no decisions
  finalized"); therefore `.0` ratification + an ADR precede any implementation when the tree is activated.
- Faithful transcription of the brainstorm (so it survives independent of the KM card):
  - **Round 1 (vars/types/mutation/functions):** no `declare`; variables auto-exist on first use; no
    `scalar()/array()/hash()` wrappers (bare words are variables/functions); type inference (RHS shape
    `[]`/`{}`/scalar + arg position); literals `"..."`/`'...'`/`42`/`3.14`/`true`/`false`/`undef`;
    operator+function mutation (`name=val`/`set`, `name+=val`/`push`, `name[k]=v`/`set_key`);
    `copy` replaces `array_copy`/`hash_copy`; `cat` replaces `concat`; nested access
    `foo["a"][9]['b'][z]`; calls always `()` with optional space before `()`; semicolons only for
    multiple same-line statements; array methods `.push_front/.push_back/.pop_front/.pop_back`.
  - **Round 2 (control flow):** everything is an expression; blocks return values; `if/elseif/else`
    (parens-cond, block-body, blocks never in parens); `when`, `otherwise`, `default`, `while`,
    `switch(expr){case(v){}default{}}`; fluent `.when(cond){}.otherwise{}`; lifecycle blocks take a
    block and drop the value; Lisp-style composability; method chaining by return type.
  - **Round 3 (edges + arithmetic):** `->`/`=>` kept; grouped `-> A | B { code }` (block-less `-> A | B`
    invalid); arithmetic/comparisons as functions with word+symbol spellings, single/multi-arg helpers,
    reducers; no operator precedence; deeply composable.
- `2026-06-16` (cross-cut): the Rust `->` edge dispatch bug surfaced during the brainstorm is tracked
  separately ([[rust-edge-semantics-bug]], RUST-PARITY audit) — not part of this format-evolution tree.

## Open Questions

- ~~COMPARISON WORD SPELLINGS~~ **RESOLVED/SPLIT (`.3.2` + `.3.2.3`, 2026-07-02):**
  The user proposes a Lisp-style *callee-inside-paren* prefix form alongside the card's
  callee-before-paren form, and asked for a recommendation. Four candidate spellings of "a ≥ b":
  `>=(a, b)` (symbol callee + `()`), `(>= a, b)` (Lisp prefix, symbol), `ge(a, b)` (word callee +
  `()`), `(ge a, b)` (Lisp prefix, word). **Resolved by `.3.2`:** keep **one**
  uniform `callee(args)` call grammar with **both word and symbol callee spellings** and do **not** add the
  `(op a, b)`
  callee-inside-paren form. Rationale: (i) the card already standardized on `callee(args)` ("calls
  always with `()`"); (ii) full Lisp *composability* (any call nests at any depth) is already
  achieved by `add(mul(a,b), c)` — it doesn't require the `(op …)` *surface syntax*; (iii) a second
  call grammar costs readability (the stated guiding principle) and risks ambiguity with plain
  `(expr)` grouping. Operator-functions return a **typed value** with methods, chainable, and the
  type may change along the chain (consistent with `.2.3`). **Resolved by `.3.2.3`:** bare
  `eq`/`ne`/`gt`/`ge`/`lt`/`le` become future numeric comparison word-call aliases only after an explicit
  string-comparison bridge exists. The bridge spellings are `str_eq`, `str_ne`, `str_gt`, `str_ge`,
  `str_lt`, and `str_le`; implementation is split across `.3.2.3.1` through `.3.2.3.4`.
- ~~Migration policy~~ **RESOLVED (`.0`/ADR 0007, user 2026-06-18):** canonical-new + deprecated-old
  alias (gradual), then explicit retirement.
- Operator forms (`=`, `+=`, `name[k]=v`, `+`/`-`/`>` as function names) interact with the current
  raw-Perl-free / ActionIR-ready invariant — confirm the lowering keeps ratio 1.0000 (verify per leaf).
- ~~Backward compatibility (old helper names)~~ **RESOLVED (ADR 0007):** kept as deprecated aliases
  during migration, retired in a later explicit leaf.

## Blockers

- `.0` (ratify + ADR) is **done** (design-only — not gated). Migration policy is **resolved**
  (gradual-alias, ADR 0007). The remaining gate on the **implementation leaves (`.1.x`+)** was a usable
  `t/phase0_regression.t`.
- **GATE CLEARED 2026-06-22 — implementation leaves `.1.x`+ are now PNT-eligible.** The
  [`LEGACY-VHDL-RETIRE`](LEGACY-VHDL-RETIRE.md) tree retired the Perl-only legacy VHDL/RTL/FSM subsystem
  (clearing `RTLUTILS-REGEX-HANG` — the subtest-110 `add_header_n_context_clause` recursive-regex hang at
  `RTLUtils.pm:104`), and [`NONCORE-QUARANTINE`](NONCORE-QUARANTINE.md) relocated the remaining domain
  island to `noncore/` (which also excised the subtest-131 `HTML::PathLinks::link_path_tokens` smoke that
  had been the SECOND, unrelated back-half hang). The [`PHASE0-BACKHALF-TRIAGE`](PHASE0-BACKHALF-TRIAGE.md)
  tree then triaged + resolved the 173 back-half failures (108 STALE re-blessed TEST-ONLY + 2 user-authorized
  engine defects fixed, ADR `0008`) and the corpus/dark-tail tail. **Result: `t/phase0_regression.t` is
  960/960 GREEN end-to-end and `bash tools/run_ci_local.sh` exits 0** ("[ci] local CI gate passed"). The
  "usable phase0" gate on `.1.x`+ is therefore **satisfied**; those leaves are now PNT-eligible. (This
  reconciliation does NOT start them — that is a separate PNT selection. The migration policy is already
  resolved (gradual-alias, ADR 0007).) See KM card [[rtlutils-regex-hang]] and `PHASE0-BACKHALF-TRIAGE.5`.

## Verification Log

| Date | Leaf | Checks | Result |
| --- | --- | --- | --- |
| `2026-07-08` | `SPEC-FORMAT-TERSE.13.5` | Parent-status reconciliation scans; mdBook build; Knowledge Map regeneration/check; memory architecture, doctrine, task-tree metadata, and whitespace gates | `SPEC-FORMAT-TERSE` top metadata and central index now mark the tree done/closed instead of active-with-empty-frontier. Stale internal split-container `active` rows are historical done/closed rows. No parser/runtime, corpus, or behavioral mdBook semantics changed. |
| `2026-07-08` | `SPEC-FORMAT-TERSE.13.4` | Final array-tree traversal no-drift scans; mdBook build; Knowledge Map regeneration/check; memory architecture, doctrine, task-tree metadata, and whitespace gates | `.13` is closed/exhausted. mdBook helper/reference/formal/backend-handoff/status pages, Knowledge Map facts, live docs, roadmap state, task-tree rows, and the generated 97-fixture oracle manifest agree that array-tree traversal receiver blocks are shipped on Perl/Rust. No parser/runtime or corpus semantics changed in this closeout leaf. |
| `2026-07-08` | `SPEC-FORMAT-TERSE.13.3` | Focused Rust parser tree traversal tests; focused Rust `.13.3` runtime tests; focused `.12.3` hash-tree runtime regression tests; Perl oracle corpus regeneration; Rust 97-fixture corpus oracle | Rust array-tree traversal receiver blocks landed with parser/runtime parity. Array receivers recurse through nested arrays by zero-based index, treat hashes as leaves, bind scoped `value`/`index`/`path`/`depth` plus reduce-only `acc`, preserve `.12` hash-tree behavior, diagnose malformed calls, and feed array continuations after `walk_leaves` / `map_leaves`. Oracle corpus regenerated to **97** fixtures with `terse_13_3_array_tree_traversal_receiver_blocks`; Rust oracle PASS. The then-frontier moved to `.13.4` for docs/KM/no-drift closeout. |
| `2026-07-08` | `SPEC-FORMAT-TERSE.13.2` | Knowledge Map retrieval for hash-tree and array-tree traversal contracts; Perl syntax check for `MethodLowering.pm`; focused lowering/runtime/source-residue probes; `prove -q -Iperl t/actionir_ast_parser.t`; full `PERL5LIB= prove -q -Iperl t/phase0_regression.t`; mdBook status sync; Knowledge fact creation/regeneration; memory/doctrine/diff checks | Perl reference array-tree traversal landed. The same receiver methods now dispatch over hash or array receiver values: hashes keep `.12` sorted-key semantics, arrays traverse nested arrays depth-first by zero-based index with hashes as leaves. Array callbacks bind scoped `value`/`index`/`path`/`depth` plus reduce-only `acc`; empty arrays run no callbacks; scalar receivers return `undef`; `walk_leaves` / `map_leaves` can feed array-family continuations such as `.count()`. Phase0 passes `Files=1, Tests=1028`. The then-frontier moved to `.13.3` for Rust/oracle parity. |
| `2026-07-08` | `SPEC-FORMAT-TERSE.13.1` | Knowledge Map retrieval for hash-tree traversal contract; task-tree split; Knowledge fact creation; Knowledge Map regeneration/check; memory/doctrine/diff checks | `.13` is split before implementation. The accepted MVP is receiver-only `walk_leaves`, `map_leaves`, and `reduce_leaves(initial)` on array-valued receivers with immediate attached blocks, index-order traversal, scoped `value`/`index`/`path`/`depth` bindings plus `acc` for reduction, hash leaves, non-array `undef`, and no parser/runtime behavior change. Frontier becomes `.13.2` for the Perl reference implementation. |
| `2026-07-08` | `SPEC-FORMAT-TERSE.10.1` | Knowledge Map retrieval for hash-literal colon facts; `LinkedSpec::call_spec_handler_subst` probes for bare, computed, and quoted hash-literal keys; direct `LinkedSpec::Get` runtime probe; Rust `expr.rs::parse_hash_literal` and `engine.rs` hash-literal evaluation read; mdBook/KM/live-doc updates; memory/doctrine/diff checks | `.10` is closed as a spec-ratification/no-engine-change leaf. Direct hash literals are expression-keyed (`{ key_expr : value_expr }`): bare keys are scalar reads, quoted keys are fixed strings, computed helper expressions can be keys, old `=>` remains retired, and block-vs-hash precedence is unchanged. Frontier moves to the remaining `SPEC-FORMAT-TERSE.13` backlog item under the user's exhaustion directive. |
| `2026-07-07` | `SPEC-FORMAT-TERSE.14.5` | Final trailing block no-drift scans and wording cleanup; mdBook build; Knowledge Map regeneration/check; oracle generator syntax/regeneration; Rust `oracle_corpus_matches_perl_reference` over **95** fixtures; memory/doctrine/diff gates | Roadmap, mdBook status, Knowledge Map retrieval, live docs, task-tree state, and oracle corpus now agree that trailing block arguments are shipped for helper-function `with(value) { ... }` / `with() { ... }` and receiver-method `.with() { ... }` only. Deferred surfaces remain explicitly unshipped, no parser/runtime behavior changed, and `.14` closes. |
| `2026-07-07` | `SPEC-FORMAT-TERSE.9.6` | Final hash-literal colon no-drift scans across current specs/corpora/generated oracle inputs/docs/mdBook/tests/KM/code; oracle regeneration over **93** fixtures; `prove -q -Iperl t/actionir_ast_parser.t`; focused Rust core/runtime `.9` filters; Rust `corpus_oracle`; full `prove -q -Iperl t/phase0_regression.t`; mdBook/KM/memory/doctrine/diff gates | Current `.spec` source inputs are clean for direct hash-literal `=>`; remaining `=>` owners are blind-call edge syntax, VHDL/source-language associations, generated Perl host output, metadata/test data, value-rendering examples, explicit retired-syntax diagnostics/tests, or historical records. mdBook documents `:` as the current direct hash-literal separator and treats old `{ key => value }` only as retired. Oracle generation remains **93** fixtures, Rust `corpus_oracle` passes, full phase0 PASS: `1..1024`, and `.9` closes with no PNT-eligible child remaining. |
| `2026-07-07` | `SPEC-FORMAT-TERSE.9.5` | Perl/Rust hard-retirement implementation for old hash-literal `=>`; Perl syntax checks for touched ActionIR parser/lowering and phase0 files; `prove -q -Iperl t/actionir_ast_parser.t`; full `prove -q -Iperl t/phase0_regression.t`; focused Rust core parser/compiler and runtime filters for colon success and retired fat-arrow rejection; mdBook/KM/live-doc updates; memory/doctrine/diff/Rust-format checks; full local CI | Old `{ key => value }` no longer succeeds as current ActionIR hash-literal syntax. Perl emits `LINKEDSPEC_UNSUPPORTED_ACTIONIR_HELPER:hash_literal_use_colon` instead of building current hash literals or falling back raw, Rust rejects the retired syntax during parse/compile, and the Rust compiler treats unsupported-ActionIR-helper parse diagnostics as fatal so action code cannot be accepted as `code: None`. The Perl AST multi-argument `array(...)` path now emits already-lowered constructor args directly so generated Perl host hashrefs are not reparsed as retired source fat arrows. Full phase0 PASS: `1..1024`; `tools/run_ci_local.sh` PASS. Frontier becomes `.9.6` for final hash-literal colon no-drift closeout. |
| `2026-07-07` | `SPEC-FORMAT-TERSE.9.4` | Current-source/docs/corpus/KM migration scans; `tools/gen_oracle_corpus.pl` regeneration over **93** fixtures; Perl syntax checks for `tools/gen_oracle_corpus.pl` and `MethodLowering.pm`; focused tkgui descriptor/runtime probes; `prove -q -Iperl t/actionir_ast_parser.t`; full `prove -q -Iperl t/phase0_regression.t`; focused Rust parser/runtime filters for hash literals, `.9.3`, and block-valued receiver chains; Rust corpus oracle; mdBook/KM/live-doc updates; memory/doctrine/diff checks; full local CI | Current-facing direct hash-literal examples now use `{ key : value }`; remaining `=>` is classified as blind-call edge syntax, source-language association, generated Perl host output, Perl metadata, historical material, or explicit migration-window compatibility. The migration exposed and fixed a Perl `MethodLowering.pm` source fallback for colon hash literals inside expression-valued block receiver chains. Phase0 PASS: `1..1023`; `tools/run_ci_local.sh` PASS. Frontier becomes `.9.5` for old hash-literal `=>` hard retirement. |
| `2026-07-07` | `SPEC-FORMAT-TERSE.9.3` | Rust `expr.rs` hash-pair parser/scanner implementation; focused parser unit tests for colon/mixed hash literals, assignment/mutation/expression-valued slots, and `::`/nested separator exclusion; runtime integration test `terse_9_3_colon_hash_literals_parse_and_run`; mdBook/KM/live-doc updates; memory/doctrine/diff checks | Rust now accepts `{ key : value }` hash literals during the migration window while still accepting old `{ key => value }` until hard retirement. Colon hash literals compose in return, direct assignment, mutation RHS, expression-valued assignment, array, receiver-chain, and nested shape contexts; non-pair braces remain expression-valued blocks. Frontier becomes `.9.4` for current-source/docs/corpus migration. |
| `2026-07-07` | `SPEC-FORMAT-TERSE.9.2` | Perl ActionIR AST parser colon-pair implementation; focused parser tests for colon/mixed hash literals and `::` block preservation; phase0 subtest `spec_format_terse_9_2_perl_colon_hash_literal_support`; direct lowering/runtime/generated-source probes; full phase0 with `PERL5LIB=` cleared; mdBook/KM/live-doc updates; memory/doctrine/diff checks | Perl reference now accepts `{ key : value }` hash literals during the migration window while still accepting old `{ key => value }` until hard retirement. Colon hash literals compose in return, assignment, mutation RHS, expression-valued assignment, array, and nested shape contexts; generated Perl host source still emits Perl `=>`; non-pair braces remain block values. Full phase0 PASS: `1..1023`. Frontier becomes `.9.3` for Rust parser/runtime parity. |
| `2026-07-07` | `SPEC-FORMAT-TERSE.9.1` | Hash-literal `=>` classification scans across specs, root corpus, generated Rust oracle corpus, docs/mdBook, tests, Knowledge facts, and parser/runtime support sites; task-tree split; Knowledge fact creation; Knowledge Map regeneration/check; mdBook build; memory/doctrine/diff checks | `.9` is split before implementation. Direct hash-literal `=>` migration candidates are separated from blind-call edge syntax, VHDL/source-language associations, historical material, active fixture strings, and parser/runtime implementation seams. The next active frontier is `.9.2` for Perl reference `{ key : value }` support during the migration window. No parser/runtime behavior changed. |
| `2026-07-07` | `SPEC-FORMAT-TERSE.8.6` | Final retired-helper no-drift scans over executable specs/corpora, tests/code, docs, and Knowledge facts; oracle generator syntax and regeneration; Rust corpus oracle; mdBook/KM/memory/doctrine/diff gates | Current specs/corpora are clean for retired helper calls, remaining old helper names are classified, and the root guide now teaches current `cat(...)`. Oracle regeneration is byte-identical over **93** fixtures; Rust `corpus_oracle` passes **3** tests. Frontier becomes `.9` for hash-literal colon association syntax. |
| `2026-07-07` | `SPEC-FORMAT-TERSE.8.5` | Current-facing root guide/mdBook/Rust README/KM cleanup after Perl/Rust helper hard retirement; historical-policy supersession wording; Knowledge Map regeneration/check; mdBook build; `git diff --check`; live-doc/task-tree updates | Current docs and fact-card `reverify` commands now describe supported helper spellings (`set`, assignments, `push`, `copy`, `cat`, aggregate wrappers, and bare scalar reads). Legacy helper names remain in historical or retired-diagnostic contexts. `KNOWLEDGE_MAP.md` is regenerated from 207 fact cards; mdBook builds. Frontier becomes `.8.6` for final no-drift closeout. |
| `2026-07-06` | `SPEC-FORMAT-TERSE.8.1` | KM retrieval for helper-renaming/retirement facts; `.8` task-node read; `LinkedSpec::call_spec_handler_subst` probe over `assign`, `concat`, `array_copy`, `hash_copy`, `push_value`, `push_nonempty`, `declare`, `scalar`, `s`/`a`/`h`, and declaration aliases; Rust `engine.rs` / `expr.rs` code reads; broad scans over current specs/corpus/docs/tests | `.8` is split before behavior change. Perl already leaves `assign(...)` raw and emits unsupported-helper diagnostics for `scalar(...)` and `s(...)`/`a(...)`/`h(...)`; Perl still lowers declaration helpers, `concat`, aggregate-copy helpers, `push_value`, and `push_nonempty`. Rust still executes `declare`, `array_copy`, `hash_copy`, `concat`, `push_value`, `push_nonempty`, and `array|a` / `hash|h` wrapper aliases. `push_nonempty(...)` has non-trivial empty-filter semantics and no plain `push(...)` equivalent, so `.8.2` owns the current-source migration and replacement decision before hard retirement. |
| `2026-07-06` | `SPEC-FORMAT-TERSE.8.3` | Perl ActionIR parser/lowering retirement of declaration helpers, function-form `concat`, aggregate-copy helpers, `push_value`, and `push_nonempty`; active Perl test fixture migration; focused direct retirement/current-helper probe; `perl -c -Iperl` syntax checks for touched Perl/test files; focused `t/actionir_ast_parser.t`, `t/trace_actionir_compact_lowerers.t`, and `t/phase0_validation_fuzz.t`; full phase0; mdBook/KM/live-doc updates; memory/doctrine/diff checks | Perl old helper spellings now emit `LINKEDSPEC_UNSUPPORTED_ACTIONIR_HELPER:<name>` diagnostics instead of successful lowering. Current `cat(...)`, `copy(...)`, `push(...)`, assignments, typed wrappers, and current receiver methods still lower. Source-method preservation keeps current `cat(...)` distinct from retired `concat(...)` even after parser normalization. Full phase0 PASS: **1022** tests. Frontier becomes `.8.4` for Rust hard retirement. |
| `2026-07-07` | `SPEC-FORMAT-TERSE.8.4` | Rust runtime helper retirement; recursive aggregate reset scoping; current hash receiver `.copy()` parity; Perl ControlFlow source-method preservation for attached blocks; oracle regeneration; focused Rust retirement/TOP-RULE/hash-receiver/corpus tests; full Rust core/runtime package tests; full phase0; mdBook/KM/live-doc updates | Rust old helper spellings now emit `LINKEDSPEC_UNSUPPORTED_ACTIONIR_HELPER:<name>` diagnostics instead of successful execution for `declare`, `array_copy`, `hash_copy`, `concat`, `push_value`, `push_nonempty`, and wrapper aliases `a(...)` / `h(...)`. Current `set(array(...), [])`, `push(...)`, `copy(...)`, `cat(...)`, `array(...)`, `hash(...)`, and receiver `.copy()` spellings preserve corpus parity. Recursive aggregate resets now record rule-local bindings before mutation. Oracle generation remains at **93** fixtures; full Rust core/runtime and phase0 **1022** pass. |
| `2026-07-06` | `SPEC-FORMAT-TERSE.8.2.1` | Task split under `.8.2`; live EBNF source edit; EBNF mdBook walkthrough edit; `perl -c -Iperl tools/gen_oracle_corpus.pl`; `perl -Iperl tools/gen_oracle_corpus.pl`; `LinkedSpec::get_parser("ebnf")` runtime probe; scoped `push_nonempty(...)` scans; Rust `corpus_oracle`; `mdbook build docs/linkedspec-book`; `perl -c -Iperl t/phase0_regression.t`; full `prove -q -Iperl t/phase0_regression.t` after updating the stale source lock | Current live EBNF no longer uses `push_nonempty(...)`. Both optional-capture append branches now evaluate `trim(capture_slice())` once into `logging_annotation_part`, gate with `is_nonempty(...)`, and append through `push(array(logging_annotation), logging_annotation_part)`. Generated EBNF oracle `input.spec` copies changed; `expected.json` did not. `ebnf` still parses `@log_rule("expr", "term")` to the same `logging_annotation` payload. Rust corpus oracle PASS over **93** fixtures; mdBook PASS; phase0 PASS **1022**. |
| `2026-07-06` | `SPEC-FORMAT-TERSE.8.2.2.1` | `.8.2.2` split; source-emitter embedded `.spec` fixture migration; focused old-helper residue scan over `rust/linkedspec-runtime/tests/source_emitter.rs`; `cargo test --manifest-path rust/Cargo.toml -p linkedspec-runtime --test source_emitter` | Rust source-emitter smoke specs now use current helper spellings for aggregate initialization/reset, append, copy, and concatenation. Direct `name = []` was rejected as a migration for named aggregate reset after it failed repeated pair/group snapshot expectations; explicit `set(array(name), [])` preserves the old aggregate-storage semantics. The focused residue scan is clean, and the source-emitter suite passes all **3** tests, including generated Rust parser compile/run proofs. |
| `2026-07-06` | `SPEC-FORMAT-TERSE.8.2.2.2.1` | `.8.2.2.2` split; migrated non-compatibility smoke strings in `rust/linkedspec-runtime/tests/integration_test.rs`; scoped helper-hit scan; focused `full_pipeline` and user-function filters; full Rust integration test | Top-level smoke, user-function, corpus/lifecycle/edge, `retv_5_1`, and `match_5_2` fixtures now use current helper spellings while explicit compatibility and recursive edge-case blocks remain untouched for later children. The scoped old-helper scan's first hit moved to TOP-RULE-AS-NORMAL, outside this child. Full `integration_test` PASS: **172** tests. |
| `2026-07-06` | `SPEC-FORMAT-TERSE.8.2.2.2.2` | TOP-RULE-AS-NORMAL recursive helper-string migration/classification; failed Rust candidate replacing `declare(array, items)` with `set(array(items), [])`; matching Perl probe for both forms; focused Rust TOP-RULE filter; full Rust integration test; mdBook/KM updates | Recursive `sexpr` integration fixtures now use current `push(...)`, `copy(...)`, and `array(...)` append/snapshot spellings. `declare(array, items)` is intentionally retained as a Rust scoped-declaration compatibility lock: the candidate aggregate-reset replacement failed the two Rust recursive value-parity tests while Perl stayed output-equivalent. Full `integration_test` PASS: **172** tests. The Rust hard-retirement task `.8.4` now owns resolving this boundary before `declare(...)` removal. |
| `2026-07-06` | `SPEC-FORMAT-TERSE.8.2.2.2.3` | Migrated/annotated explicit legacy-helper compatibility/equivalence strings in `rust/linkedspec-runtime/tests/integration_test.rs`; focused Rust filters for `terse_1_1_2`, `terse_1_2`, `terse_1_4_2`, and `terse_1_3_2`; full Rust integration test; Rust formatting, memory, doctrine, and whitespace checks | Current-side assertions now use current helper spellings, while retained old helper sides are explicitly labelled as `.8.4` compatibility locks. Later current-feature fixture old spellings remain owned by `.8.2.2.2.4`. Focused filters PASS and full `integration_test` PASS: **172** tests. |
| `2026-07-06` | `SPEC-FORMAT-TERSE.8.2.2.2.4` | Migrated later current-feature Rust integration fixture strings in `rust/linkedspec-runtime/tests/integration_test.rs`; focused Rust filters for `terse_1_`, `terse_2_3`, `rust_parity_7_3_4`, `rust_parity_7_5_2`, `terse_11_3`, and `terse_3_3`; full Rust integration test; Rust formatting and whitespace checks | Later current-feature fixtures now use current `push(...)`, `copy(...)`, and explicit aggregate-setter spellings where supported. A candidate `.copy()` hash receiver rewrite returned `Null`, so documented `.hash_copy()` receiver spellings and wrapper alias `h(...)` remain for `.8.2.2.2.5` classification. Focused filters PASS and full `integration_test` PASS: **172** tests. |
| `2026-07-06` | `SPEC-FORMAT-TERSE.8.2.2.2.5` | Residue scan over `rust/linkedspec-runtime/tests/integration_test.rs`; in-place classification comments for later hash receiver `.hash_copy()` and wrapper alias `h(...)`; Rust formatting | Every remaining old-helper spelling in `integration_test.rs` is gone or explicitly classified. Recursive `declare(...)` is owned by `.8.2.2.2.2`; explicit legacy-helper compatibility strings are owned by `.8.2.2.2.3` and `.8.4`; `.hash_copy()` receiver links are current documented receiver-method surface; and `h(...)` is retained only as a wrapper-alias retirement lock. Rust formatting PASS. |
| `2026-07-06` | `SPEC-FORMAT-TERSE.8.2.2.3` | Generated oracle corpus helper fixture migration in `tools/gen_oracle_corpus.pl`; `perl -c -Iperl tools/gen_oracle_corpus.pl`; `perl -Iperl tools/gen_oracle_corpus.pl`; generated `input.spec` diff review; old-helper residue scan over `rust/linkedspec-runtime/tests/corpus/*/input.spec`; Rust `corpus_oracle`; Rust formatting, whitespace, memory, and doctrine checks | Generated corpus sources now use current `push(...)`/`copy(...)` spellings for current-surface append/snapshot behavior in `autoexist_array_bare_arg` and TOP-RULE recursion fixtures, and incidental setup in the aggregate-copy compatibility fixture now uses `push(...)`. Regeneration emitted **93** fixtures with only expected `input.spec` changes and no `expected.json`/`manifest.json` drift. Remaining generated-corpus residues are classified as declaration compatibility, aggregate-copy compatibility, or current hash receiver-method surface. Rust `corpus_oracle` PASS: **3** tests including the full Perl reference comparison. |
| `2026-07-06` | `SPEC-FORMAT-TERSE.8.2.2.4` | Perl phase0 helper-string migration in `t/phase0_regression.t`; `perl -c -Iperl t/phase0_regression.t`; full phase0 with `PERL5LIB=` cleared; focused old-helper residue scan over the Perl phase0 terse block; Rust formatting, whitespace, memory architecture, and doctrine checks | Current-surface phase0 fixture strings use `cat(...)`, `push(...)`, and `copy(...)` where they are not legacy compatibility locks. Retained old-helper spellings are explicitly classified under scoped-declaration compatibility, `push_nonempty(...)` semantic filtering, aggregate-copy compatibility, helper-renaming equivalence, canonical old-side equivalence, or current `.hash_copy()` receiver-method surface. A failed all-bare `push(words, label)` candidate reconfirmed child-call routing; `push(array(words), label)` preserves current append semantics with a bare RHS. Full phase0 PASS: **1022** tests. |
| `2026-07-06` | `SPEC-FORMAT-TERSE.8.2.2.5` | Focused primary-helper and wrapper-alias residue scans over Rust active tests, generated oracle inputs, generator source, shipped specs, checked-in corpus specs, and the Perl phase0 terse block; Rust integration classification comments for `a(...)` / `h(...)` residue; Rust formatting, whitespace, memory architecture, and doctrine checks | Active-test/corpus cleanup is closed. Root `specs/` and `tests/corpus/` are clean for retired helper spellings. Generated oracle inputs retain only owned declaration, aggregate-copy, and current hash receiver-method categories. Perl phase0 residue remains within `.8.2.2.4` categories. Rust integration wrapper-alias residue is labelled as `.8.4` retirement ownership; scan false positives are input strings such as `(a(b)c)`. |
| `2026-07-06` | `SPEC-FORMAT-TERSE.15.5` | Final colon scalar-slot residue scans across current specs/corpora/mdBook/tests/KM/code; live probes for corrected bare duck-typed assignment and `substr(target, ...)` mutation examples; `perl -c -Iperl tools/gen_oracle_corpus.pl`; `perl -Iperl tools/gen_oracle_corpus.pl`; Rust corpus oracle over **93** fixtures; `mdbook build docs/linkedspec-book`; Knowledge Map regeneration/check; memory/doctrine/diff checks; full phase0 (`env PERL5LIB= perl -Iperl t/phase0_regression.t`, plan `1..1022`) | No current shipped-spec, generated corpus, or mdBook live surface depends on successful `:name` scalar slots. Remaining hits are retired-diagnostic code/tests, rule-mode/regex/public-API colon syntax, or explicitly historical facts. Two stale Knowledge fact-card references were corrected to the post-retirement surface: duck-typed assignment reverifies with bare `items` / `meta`, and regex substitution uses `substr(target, ...)` rather than retired `substr(:target, ...)`. Oracle corpus and mdBook stay in sync. `.15` closes and frontier advances to `.8`; `.9` remains pending behind `.8`. |
| `2026-07-06` | `SPEC-FORMAT-TERSE.15.4` | Rust `Expr::ScalarSlot` AST/runtime/source-emitter retirement; stale Rust fixture migration to bare reads; EBNF `rule_header` source/corpus refresh; generated corpus case rename to `terse_15_4_bare_scalar_payload_readback`; focused core/runtime/source-emitter/trace tests; `perl -c -Iperl tools/gen_oracle_corpus.pl`; `perl -Iperl tools/gen_oracle_corpus.pl`; Rust corpus oracle over **93** fixtures; full phase0 (`env PERL5LIB= perl -Iperl t/phase0_regression.t`, plan `1..1022`) | Rust no longer parses/evaluates `:name` as `Expr::ScalarSlot`; retired colon scalar slots emit `LINKEDSPEC_UNSUPPORTED_ACTIONIR_HELPER:colon_scalar_slot_use_bare_read` with a bare-read migration diagnostic. Runtime and generated-source paths use bare reads, action-edge blocks that read `retv` get the scoped child return, EBNF avoids the same-name scalar/array `rule` collision through `rule_header`, generated EBNF oracle inputs are refreshed, the stale scalar-slot corpus fixture name is replaced with the `.15.4` bare-read case name, and Phase0's source lock now expects `rule_header`. Frontier becomes `.15.5`. |
| `2026-07-06` | `SPEC-FORMAT-TERSE.15.3` | Perl ActionIR AST/lowering/rewrite/EmitContext retirement of colon scalar slots; active fixture migration to bare reads; focused ActionIR/trace tests; `perl -c -Iperl` syntax checks on touched Perl/test modules; full phase0 with `PERL5LIB=` cleared; mdBook/KM/live-doc updates; memory/doctrine/diff checks | Perl `:name` no longer parses or lowers as a successful scalar slot. Retired colon scalar slots produce `LINKEDSPEC_UNSUPPORTED_ACTIONIR_HELPER:colon_scalar_slot_use_bare_read`; `scalar_slot_fallback` trace/declaration behavior is gone. Bare value reads remain valid across the Perl reference, including inline `if`/`elseif`/`switch` conditions, logical `or`/`and` operands, ordinary `entry_text()` / `match_text()` value helpers, assignment RHS passthrough, flow RHS values, and scalar-held hash `count_keys(...)`. Focused tests pass and full phase0 reaches plan `1..1022`. Frontier becomes `.15.4` for Rust `Expr::ScalarSlot` removal. |
| `2026-07-06` | `SPEC-FORMAT-TERSE.15.2.4` | Current shipped-spec/root-corpus/generated-oracle/mdBook migration; `env PERL5LIB= perl -Iperl tools/gen_oracle_corpus.pl`; no Rust oracle `expected.json`/`manifest.json` diff; Rust corpus oracle over **93** fixtures; full phase0 with `PERL5LIB=` cleared; `mdbook build docs/linkedspec-book`; `git diff --check`; current-surface scalar-slot residue scan; KM/live-doc updates | Current sources now use bare value reads instead of live `:name` scalar-slot reads, with rule-mode labels, regex syntax, and historical literal strings treated as scan exclusions. The migration preserved oracle expected JSON, and fixed the load-bearing seams exposed by source migration: control-flow `set(...)` reconstruction, `split_tagged_records(...)` source-arg preservation, copy-return payload classification, declaration/type-memory tracking, Rust action-edge child-return publication order, descriptor scalar bare reads with same-name aggregate accumulators, and `array(retv)` versus `[retv]` constructor semantics. Frontier becomes `.15.3`. |
| `2026-07-06` | `SPEC-FORMAT-TERSE.15.2.3` | Focused Rust `.15.2.3` integration tests; `perl -c -Iperl perl/LinkedSpec/ActionIR/MethodLowering.pm`; `perl -c -Iperl tools/gen_oracle_corpus.pl`; `env PERL5LIB= perl -Iperl tools/gen_oracle_corpus.pl`; Rust corpus oracle over **93** fixtures; `cargo fmt --manifest-path rust/Cargo.toml --all --check`; full phase0 with `PERL5LIB=` cleared; mdBook/KM/live-doc updates | Rust parity for bare reads in switch subjects, numeric/comparison args, and `if(...)` conditions landed while preserving literal bare switch case labels. Inline Perl switch case labels were aligned to the same rule. Regenerated oracle corpus includes `terse_15_2_3_bare_value_reads_and_case_labels`; `specs/spec.spec` aggregate initialization now uses explicit `array(...)` targets after `.11` duck-typed assignment. Rust corpus oracle passes **93** fixtures. Phase0 reaches `ok 1022` with **1021 pass** and only baseline `not ok 796`. Frontier becomes `.15.2.4`. |
| `2026-07-05` | `SPEC-FORMAT-TERSE.15.2 re-scope` | Recovered a prior session's uncommitted intermingled `.15.2/.15.3/.15.4/.8/.9` work onto branch `recovery/terse-15-uncommitted-20260705` and reset `main` to clean `104088e5`; applied the `:name`->bare converter to `specs/*.spec` + `tools/gen_oracle_corpus.pl`, regenerated the oracle corpus, and read the byte-identity gate; direct reference-engine probe (`LinkedSpec::Get`) on `switch(:kind)` vs `switch(kind)`; reverted all source edits back to clean `104088e5`; task-tree engine-first re-sequence | **Source-first migration is NOT output-preserving at `104088e5`.** Bare identifiers are not read as bound variable values in `switch(...)`, numeric callees, `if(...)` conditions, or the second arg of all-bare `push(A,B)`; direct probe: `switch(:kind)`->`'good'` but `switch(kind)`->`'def'`. The byte-identity gate flagged `spec_spec_*`/`ebnf_*` (variable/rule-name collisions) plus the all-bare `push`/`switch`/`while` inline fixtures as load-bearing (bare != `:name`), while most shipped specs (`ds_vhistory`, `lib_reader`, `pplugin`, `simenv`, `tablegrep`, `tkgui`, `vhdl`) were output-preserving. `:name` only worked as variable-vs-rule disambiguation. `.15.2` re-scoped ENGINE-FIRST (`.15.2.1` design, `.15.2.2` Perl, `.15.2.3` Rust, `.15.2.4` migration); `.15.3`/`.15.4` then remove `:name` entirely with no compat (user directive: `:name` shall not be supported). Frontier becomes `.15.2.1`. Baseline phase0 = 1021 pass / 1 pre-existing unrelated fail (test 796 `emit_context_lowers_split_tagged_records_helper`). No committed engine/source behavior changed. See ADR `0019`, KM card `terse-bare-read-value-position-gap`. |
| `2026-07-05` | `SPEC-FORMAT-TERSE.15.1` | Audit scans for `:name`/scalar-slot forms across shipped specs, root corpora, Rust oracle fixtures, mdBook/current guidance, Knowledge Map facts, active Perl/Rust tests, oracle generation sources, and parser/runtime support; task-tree split; live-doc/KM updates; Knowledge Map regeneration/check; memory/doctrine/diff checks | Colon scalar-slot removal is split before implementation. Current `:name` usage is broad enough that hard retirement is unsafe as one slice, so `.15.2` owns current spec/corpus/docs/KM migration to bare reads, `.15.3` owns Perl retirement, `.15.4` owns Rust retirement, and `.15.5` owns final no-drift closeout. No parser/runtime behavior changed. |
| `2026-07-05` | `SPEC-FORMAT-TERSE.11.5` | Current-facing stale-wording scans across `ROADMAP_V2.md`, mdBook, live docs, `docs/knowledge/`, and `KNOWLEDGE_MAP.md`; targeted roadmap/fact-card edits; Knowledge Map regeneration/check; mdBook build; memory/doctrine/diff checks | Duck-typed assignment alignment is closed. Current roadmap and Knowledge Map retrieval now describe direct RHS shapes as typed value binding and keep target-kind inference only as explicitly superseded history. mdBook assignment/container guidance already matched `.11`; oracle corpus remains **92** fixtures. Frontier becomes `.15`. |
| `2026-07-05` | `SPEC-FORMAT-TERSE.11.4` | Perl syntax checks for `ActionIR::MethodLowering`, `RuleIR::EmitContext`, `ActionIR::AST::Parser`, `ActionIR::ControlFlow`, and `Scanner::PrimitivePipelineRules`; focused `LinkedSpec::call_spec_handler_subst` / `LinkedSpec::Get` probes for nested statement/value assignment, scalar-held array root mutation, generated declarations, and descriptor readiness; focused Rust `terse_11_4` integration tests; `perl -Iperl tools/gen_oracle_corpus.pl`; Rust corpus oracle over **92** manifest fixtures; mdBook/KM/doc checks; broad phase0 rerun | Nested mixed value-path assignment landed on Perl/Rust. Multi-segment direct-access lvalues mutate scalar-held array/hash value trees with explicit path guards, no intermediate autovivification, hash-key create/replace, array replace/append-at-len, and `undef`/`null` failure values for missing/wrong/gap paths. Single-segment scalar-held array/hash roots now mutate consistently before named-hash fallback. The oracle corpus includes `terse_11_4_nested_mixed_value_path_assignment`; known `spec_spec_*` generator drift was restored to the existing AST expectations before the passing oracle. Broad phase0 now has only the pre-existing unrelated `emit_context_lowers_split_tagged_records_helper` failure (`1/1022`). Frontier becomes `.11.5`. |
| `2026-07-05` | `SPEC-FORMAT-TERSE.11.3` | Perl syntax/probe checks for scalar-held `copy(...)`, receiver-chain readback, and declaration collection; focused Rust runtime tests for `terse_11_3`, `terse_6_2_3_1_scalar_slot_shorthand_runs`, `terse_3_3_2_aggregate_assignment_expressions_run`, and `terse_3_3_4_assignment_expression_closure_run`; `perl -Iperl tools/gen_oracle_corpus.pl`; Rust corpus oracle; mdBook build; Knowledge Map regenerate/check; memory/doctrine/diff checks; broad phase0 with one unrelated known failure | Rust duck-typed assignment parity landed and the oracle-exposed Perl scalar-held copy/receiver fallback gap was closed. Bare Rust assignment and `set`/`=` helper forms now bind evaluated scalar/array/hash `RuntimeValue`s through the scalar value slot, while explicit `array(...)` / `hash(...)` targets remain aggregate storage. Scalar-held typed views feed typed wrappers, `copy(...)`, aggregate-consuming helper slots, and receiver chains; Perl generated source keeps those scalar-held reads on scalar preambles. Oracle corpus regenerated to **91** fixtures with `.11.3` cases replacing the old `.1.2.3.5.4` target-kind expectations. Phase0's remaining failure is `emit_context_lowers_split_tagged_records_helper`, outside this leaf. Frontier becomes `.11.4`. |
| `2026-07-04` | `SPEC-FORMAT-TERSE.7.4` | KM retrieval for type-method/receiver-chain facts; drift scans for stale `.7` frontier text, 73/74 fixture wording, receiver-family summaries, numeric reducer statements, tests, corpus, and Knowledge Map facts; mdBook build; memory/doctrine/KM/diff gates | No Perl/Rust behavior change needed. Current roadmap, task-tree index, mdBook helper/reference summaries, and Knowledge Map facts now agree that array numeric reducers are terminal array/list receiver methods, not scalar number receiver links; mutation/lifecycle/control/child-dispatch/parser-state/declaration/compatibility helpers remain explicit. `.7` is closed and the `SPEC-FORMAT-TERSE` frontier is empty. |
| `2026-07-04` | `SPEC-FORMAT-TERSE.7.3` | KM retrieval for receiver-chain facts; Perl/Rust receiver classifier and reducer-target audit; Perl lowering/runtime/descriptor probes for `scores.sum()` and `scores.uniq().sum()`; `perl -c -Iperl perl/LinkedSpec/ActionIR/MethodLowering.pm`; `prove -q -Iperl t/phase0_regression.t`; focused Rust `terse_7_3` integration tests; `perl -Iperl tools/gen_oracle_corpus.pl`; Rust `corpus_oracle`; `cargo fmt --manifest-path rust/Cargo.toml --all --check`; `mdbook build docs/linkedspec-book` | Array/list numeric reducers are now terminal receiver methods: `sum`, `avg`, `median`, `range`, `min`, and `max`. Perl composes them after array-returning links, including pure internal array-pipeline links such as `uniq()`, with zero fallback/raw/unresolved descriptor counts. Rust accepts the same receiver methods, treats array terminals as chain-ending, and supports documented single-array `num_min`/`num_max` helper forms. Hash receiver backfill required no new pure methods; mutation/ambiguous helpers remain explicit. Phase0 passes with **1021** tests; oracle corpus passes **74 fixtures**. Frontier becomes `.7.4`. |
| `2026-07-04` | `SPEC-FORMAT-TERSE.7.2` | KM retrieval for string receiver chains; mdBook helper/reference audit; Perl runtime + descriptor probes for method/helper `substr()` equivalence and split bridge; focused Rust `terse_2_3_5_3` test filter | String/scalar method backfill is already satisfied by the current Perl/Rust surface. `substr()` is an accepted receiver method, helper-form and method-form `substr` both return `BCD` in the focused Perl probe, descriptor metadata stays language-agnostic-ready with zero fallback/raw/unresolved counts, and focused Rust tests pass. The useful pure string receiver set from `.7.1` is already implemented and documented; statement regex substitution remains an explicit mutation boundary. Frontier becomes `.7.3`. |
| `2026-07-04` | `SPEC-FORMAT-TERSE.7.1` | KM retrieval for existing receiver-chain facts; Perl/Rust receiver classifier inventory; mdBook helper-catalog receiver-boundary update; Knowledge Map fact card/regeneration/check; focused classifier scans; Rust corpus oracle; mdBook build; memory/doctrine/diff gates; full local CI | Supported runtime receiver families are inventoried before implementation: string/scalar, array/list, hash, and number have existing receiver-method tables; booleans/flow results are terminal; expression-valued blocks and user-function returns dispatch by yielded runtime type. String `substr()` is already in the receiver family, so `.7.2` starts with verification/backfill evidence rather than an implementation assumption. Mutation, lifecycle/control, child-dispatch, parser-state reader, declaration, and compatibility surfaces remain function/statement/lifecycle-only unless a future leaf defines safe receiver semantics. Frontier becomes `.7.2`. |
| `2026-07-04` | `SPEC-FORMAT-TERSE.6.4` | KM retrieval for declare retirement; implementation/doc inventory for declaration helper support; ADR `0018`; mdBook declaration/helper policy updates; Knowledge Map fact card/regeneration/check; declaration-support scans; Rust corpus oracle; mdBook build; memory/doctrine/diff gates; full local CI | Post-migration compatibility retention was the policy at this historical leaf: `declare(...)` and declaration aliases were kept for existing specs, while new authoring/current examples used terse replacements. `SPEC-FORMAT-TERSE.8` later superseded this policy and hard-retired the helpers. Declaration-retirement `.6` closes and frontier becomes `.7.1`. |
| `2026-07-04` | `SPEC-FORMAT-TERSE.6.3` | Current-facing mdBook `declare(...)` / old-helper scans excluding explicit legacy/reference pages; root `tests/corpus` scans; root corpus probes for `simple_grammar`, `tablegrep`, and `lispish`; `perl -Iperl tools/gen_oracle_corpus.pl`; generated-corpus expected-output diff check; Rust corpus oracle (`cargo test --manifest-path rust/Cargo.toml -p linkedspec-runtime --test corpus_oracle -- --nocapture`); `mdbook build docs/linkedspec-book`; `prove -q -Iperl t/phase0_regression.t`; Knowledge Map regeneration/check; full local CI (`bash tools/run_ci_local.sh`) | Public docs and corpus examples now teach terse replacements instead of active `declare(...)` or old helper spellings. Root corpus specs scan clean and probes keep existing outputs. Generated oracle inputs use canonical helpers where old spellings were incidental; expected JSON remains unchanged, and residual old spellings are compatibility/reference-only. Added KM coverage for the bare `merge_hash(base, overlay)` boundary. Phase0 passes with **1020** tests, Rust `corpus_oracle` passes all **73 fixtures**, and full local CI passes. Frontier becomes `.6.4`. |
| `2026-07-04` | `SPEC-FORMAT-TERSE.6.2.4` | Shipped-spec scans for `scalar(...)` / `assign(...)`, `declare(...)`, and old helper spellings; checked-in corpus and mdBook inventory scans; `perl -Iperl -MLinkedSpec` descriptor compile for all 21 shipped specs; `prove -q -Iperl t/phase0_regression.t`; `perl -Iperl tools/gen_oracle_corpus.pl`; Rust corpus oracle (`cargo test --manifest-path rust/Cargo.toml -p linkedspec-runtime --test corpus_oracle -- --nocapture`); `mdbook build docs/linkedspec-book`; generated-corpus diff check; full local CI (`bash tools/run_ci_local.sh`) | Shipped specs compile and scan clean for the retired/currently-forbidden surfaces. Phase0 passes with **1020** tests. Oracle regeneration remains stable at **73 fixtures** with no tracked corpus diff, and Rust `corpus_oracle` passes all fixtures. The public book has no `scalar(...)` / `assign(...)` hits and builds. Broader checked-in corpus/book `declare(...)` and older helper references are not shipped-spec blockers and are now the explicit `.6.3` sweep input. Full local CI passes. Frontier becomes `.6.3`. |
| `2026-07-04` | `SPEC-FORMAT-TERSE.6.2.3.2` | Active authored spec/corpus scan for `scalar(` / `assign(`; mdBook scan; Perl syntax checks for edited ActionIR modules; `prove -q -Iperl t/actionir_ast_parser.t`; `prove -q -Iperl t/phase0_regression.t`; `cargo fmt --manifest-path rust/Cargo.toml --all --check`; focused Rust core/runtime tests for scalar-slot shorthand and remembered bare kind | Authored/current `.spec` no longer supports or uses `scalar(...)` scalar-slot reads or `assign(...)` assignment aliases. `:name` is the scalar-slot spelling; `LHS = RHS` / `set(...)` are assignment forms; initialized bare identifiers remember scalar/array/hash kind. Phase0 passes with **1020** tests. Frontier becomes `.6.2.4`. |
| `2026-07-03` | `SPEC-FORMAT-TERSE.6.2.3.1` | Perl syntax checks for `ActionIR::ValueExpr`, `ActionIR::MethodLowering`, `RuleIR::EmitContext`, and `tools/gen_oracle_corpus.pl`; focused lowering probes for `:name` in return, shape, constructor, and scalar-target positions; `prove -q -Iperl t/phase0_regression.t`; focused Rust core/runtime tests; oracle generator; Rust corpus oracle; mdBook/KM/live-doc updates | `:name` now reads scalar slot `name` on Perl/Rust. `set(:payload, [value])` keeps scalar-held direct-shape payload assignment while bare direct-shape targets still infer aggregates. Phase0 passes with **1019** tests, the generated oracle corpus reaches **73 fixtures**, and Rust `corpus_oracle` passes over all 73 including `terse_6_2_3_1_scalar_slot_shorthand`. Frontier becomes `.6.2.3.2` for shipped-spec wrapper migration. |
| `2026-07-03` | `SPEC-FORMAT-TERSE.6.2.2` | `rg -n '\b(assign|push_value|array_copy|hash_copy|concat)\s*\(' specs`; `rg -n '^\s*(?:if|elseif)\(.*\);\s*$|^\s*else\(\);\s*$' specs/portmap.spec`; registered descriptor compile for all 21 shipped specs; `perl -c -Iperl t/phase0_regression.t`; `prove -q -Iperl t/phase0_regression.t`; `cargo test --quiet --manifest-path rust/linkedspec-runtime/Cargo.toml --test corpus_oracle` | Shipped specs no longer use active old helper spellings. `portmap.spec` no longer keeps redundant standalone flow-marker separators. Stale phase0 source expectations now assert the canonical terse spellings. Phase0 passes with **1018** tests and the Rust oracle corpus passes over **66 fixtures**. Frontier becomes `.6.2.3` for typed-wrapper/direct-shape cleanup. |
| `2026-07-03` | `SPEC-FORMAT-TERSE.6.2.1` | `rg -n 'declare\(|\.declare\(' specs`; focused `perl -Iperl -MLinkedSpec` descriptor compile for all 13 edited shipped specs; `prove -q -Iperl t/phase0_regression.t`; `cargo test --quiet --manifest-path rust/linkedspec-runtime/Cargo.toml --test corpus_oracle`; Knowledge Map/memory/doctrine/diff checks; `mdbook build docs/linkedspec-book`; `bash tools/run_ci_local.sh` | Shipped specs no longer use active `declare(...)` or fluent `.declare(...)`. `BNF`, `ds_vhistory`, `ebnf`, `hlink_substitution`, `lib_reader`, `Lispish`, `portmap`, `pplugin`, `sdce`, `simenv`, `spec`, `tablegrep`, and `vhdl` compile after the migration. Stale phase0 expectations now assert the replacement assignment/capture/source-read nodes instead of `DECLARE`. Phase0 passes with **1018** tests, the Rust oracle corpus passes over **66 fixtures**, mdBook builds, and the full local CI gate passes. Frontier becomes `.6.2.2` for old helper spelling cleanup. |
| `2026-07-03` | `SPEC-FORMAT-TERSE.6.1` | `rg -n '(^|[.{;[:space:]])declare\(' specs`; `rg -l '(^|[.{;[:space:]])declare\(' specs`; task-tree/roadmap/live-doc/mdBook/KM ownership updates; no `.spec` edits | User directive owned under `SPEC-FORMAT-TERSE`; 70 active shipped-spec hits across 13 files inventoried; next executable leaf `.6.2` migrates specs before any runtime-helper expansion or oracle fixture change. |
| `2026-07-02` | `SPEC-FORMAT-TERSE.3.3.4` | mdBook `assign(...)` public-example audit; phase0 closure lock; focused Rust runtime closure test; oracle generator; Rust corpus oracle; mdBook build; Knowledge Map regenerate/check; memory/doctrine/diff checks; full local CI | Assignment-expression closure landed. Scalar, direct-shape aggregate, append, hash-index, user-function body, receiver-chain, canonical `set(...)`, operator, and legacy `assign(...)` compatibility forms now compose in one Perl/Rust corpus fixture. Public examples prefer `set(...)`/operator assignment; `assign(...)` remains a legacy alias reference. Corpus reaches **62 fixtures**, phase0 reaches **1015 tests**, and the `SPEC-FORMAT-TERSE` active roadmap has no remaining concrete PNT-eligible leaf. |
| `2026-07-02` | `SPEC-FORMAT-TERSE.3.3.3` | Perl syntax checks for `ActionIR::MethodLowering`, `RuleIR::EmitContext`, and `t/phase0_regression.t`; focused `t/actionir_ast_parser.t`; focused Rust parser tests for assignment expressions and parenthesized mutation receiver chains; focused Rust runtime `.3.3.3`; oracle generator; Rust corpus oracle; full phase0; mdBook/live-doc/KM updates; phase0/full gates before commit | Array append and hash-index mutation expressions now mutate and return updated aggregate snapshots on Perl/Rust. `items += value` yields the updated array, `meta[key] = value` yields the updated hash, and both feed helper args, returns, block values, and compatible receiver chains. Oracle corpus reaches **61 fixtures** and phase0 reaches **1014 tests**. Frontier becomes `.3.3.4`. |
| `2026-07-02` | `SPEC-FORMAT-TERSE.3.3.2` | Perl syntax checks for `ActionIR::MethodLowering` and `RuleIR::EmitContext`; focused `t/actionir_ast_parser.t`; generated-source declaration probes for direct-shape assignment expression targets; focused Rust core scalar-assignment parser tests; focused Rust runtime `.3.3.2`; oracle generator; Rust corpus oracle; full phase0; mdBook/live-doc/KM updates; phase0/full gates before commit | Direct RHS shape assignment expressions now store and return assigned arrays/hashes on Perl/Rust. Bare targets infer `@`/`%` from the direct shape RHS, typed `array(...)`/`hash(...)` targets match the shape, and explicit `scalar(...)` targets keep scalar-held payloads. Oracle corpus reaches **60 fixtures** and phase0 reaches **1013 tests**. Frontier becomes `.3.3.3`. |
| `2026-07-02` | `SPEC-FORMAT-TERSE.3.3.1` | Perl syntax checks for ActionIR method parsing/lowering; focused `t/actionir_ast_parser.t`; focused Perl runtime/source probe for scalar assignment expressions; focused Rust parser tests for `=(...)`, scalar assignment args, and keyword-arg boundaries; focused Rust runtime `.3.3.1`; oracle generator and Rust corpus oracle; mdBook/live-doc/KM updates; phase0/full gates before commit | Scalar assignment expressions now store and return their assigned scalar value on Perl/Rust. `name = value`, `=(name,value)`, `set(name,value)`, and `assign(name,value)` work in scalar value positions. Direct RHS shape assignment values later landed in `.3.3.2`; array append values and hash-index mutation values later landed in `.3.3.3`. Oracle corpus reaches **59 fixtures** and phase0 reaches **1012 tests**. Frontier becomes `.3.3.2`. |
| `2026-07-02` | `SPEC-FORMAT-TERSE.3.3` | KM retrieval (`terse-expression-valued-assignment-and-operator-calls`, `terse-mutation-surface-ground-truth`); TOOLBOX `call_spec_handler_subst` and `LinkedSpec::Get` probes for statement assignment vs value-position assignment; Rust source/test audit for expression-level assignment diagnostics; mdBook drift correction; Knowledge Map regenerate/check; memory/doctrine/diff checks; full local CI | Expression-valued assignment was split before code. At split time, scalar assignment, array append, and hash-index assignment were still statement-only, and `=(target,value)` was not runnable yet. The first implementation child was `.3.3.1` for scalar assignment expression values and scalar `=(target,value)` equivalence. |
| `2026-07-02` | `SPEC-FORMAT-TERSE.3.2.3.4` | KM retrieval (`terse-numeric-comparison-symbol-callees`, `terse-numeric-comparison-word-aliases`, `terse-comparison-call-surface-split`, `spec-arithmetic-call-surface-ground-truth`); Perl syntax checks for ActionIR symbol parsing/lowering and phase0; focused Perl lowering/runtime/source probes for comparison symbols, slash division, `str_*`, and single-equals deferral; oracle generator; focused Rust parser/runtime symbol-callee locks; Rust corpus oracle; phase0; mdBook build; Knowledge Map regenerate/check; memory/doctrine/diff checks; full local CI | Comparison symbol callees `==`/`!=`/`>`/`>=`/`<`/`<=` now route to numeric `num_*` comparison helpers on Perl/Rust. Rust argument parsing now requires a real identifier before treating `name=expr` as a keyword arg, so `==(...)` parses as a symbol call. Slash regex/division behavior remains intact, lexical strings use `str_*`, and `=(target,value)` stays `.3.3`. Oracle corpus reaches **58 fixtures** and phase0 reaches **1011 tests**. Frontier becomes `.3.3`. |
| `2026-07-02` | `SPEC-FORMAT-TERSE.3.2.3.3` | KM retrieval (`terse-numeric-comparison-word-aliases`, `terse-string-comparison-bridge-contract`, `terse-comparison-call-surface-split`, `spec-arithmetic-call-surface-ground-truth`); Perl syntax checks for ActionIR comparison/lowering contracts and phase0; focused Perl lowering/runtime/source probes for numeric bare words and lexical `str_*`; oracle generator; focused Rust runtime comparison-word lock; Rust corpus oracle; phase0; mdBook build; Knowledge Map regenerate/check; memory/doctrine/diff checks; full local CI | Bare value-call comparison words `eq`/`ne`/`gt`/`ge`/`lt`/`le` now route to numeric `num_*` comparison helpers on Perl/Rust. Explicit `str_*` remains the lexical string surface, and shipped specs/tests with lexical bare comparison intent moved to `str_*`. Comparison symbol callees remain `.3.2.3.4`; assignment `=(...)` remains `.3.3`. Oracle corpus reaches **57 fixtures** and phase0 reaches **1010 tests** after the focused numeric-word lock. Frontier becomes `.3.2.3.4`. |
| `2026-07-02` | `SPEC-FORMAT-TERSE.3.2.3.2` | KM retrieval (`terse-string-comparison-bridge-contract`, `terse-comparison-call-surface-split`, `spec-arithmetic-call-surface-ground-truth`); Perl syntax checks for ActionIR comparison/lowering contracts and phase0; focused Rust runtime string-comparison helper lock; oracle generator; Rust corpus oracle; phase0; mdBook build; Knowledge Map regenerate/check; memory/doctrine/diff checks; full local CI | Explicit `str_eq`/`str_ne`/`str_gt`/`str_ge`/`str_lt`/`str_le` helpers landed on Perl/Rust as lexical string predicates. Bare comparison words remain string-compatibility aliases until `.3.2.3.3`; numeric comparisons remain `num_*` or number receiver terminals; comparison symbol callees remain `.3.2.3.4`. Oracle corpus reaches **56 fixtures** and phase0 reaches **1009 tests** after the focused string-helper lock. Frontier becomes `.3.2.3.3`. |
| `2026-07-02` | `SPEC-FORMAT-TERSE.3.2.3.1` | KM retrieval (`terse-comparison-call-surface-split`, `spec-arithmetic-call-surface-ground-truth`); source re-read of `ActionIR/FlowExpr.pm` string/numeric comparison dispatch; mdBook string/numeric comparison wording audit; `perl -Iperl -c perl/LinkedSpec/ActionIR/FlowExpr.pm`; Knowledge Map regenerate/check; memory/doctrine/diff checks; mdBook build; full local CI | Explicit string bridge contract locked before code. The accepted names are `str_eq`/`str_ne`/`str_gt`/`str_ge`/`str_lt`/`str_le`; they preserve today's lexical string comparison semantics and are not numeric helpers, receiver-dot links, or symbol callees. The book states these names are accepted but not shipped until `.3.2.3.2`; current runtime behavior is unchanged. Full local CI passed with phase0 1008. Frontier becomes `.3.2.3.2`. |
| `2026-07-02` | `SPEC-FORMAT-TERSE.3.2.3` | KM retrieval (`spec-arithmetic-call-surface-ground-truth`, `terse-expression-valued-assignment-and-operator-calls`); TOOLBOX `call_spec_handler_subst`/runtime/flow probes for bare comparison words, numeric comparison helpers, receiver numeric comparisons, and comparison symbol calls; Perl source reads of `ActionIR/MethodExpr.pm`, `ActionIR/FlowExpr.pm`, `ActionIR/MethodLowering.pm`, `ActionIR/AST/Parser.pm`, `BootstrapSpec/Core.pm`, and `Validation.pm`; Rust source reads of `linkedspec-core/src/expr.rs`, `linkedspec-core/src/validation.rs`, and `linkedspec-runtime/src/engine.rs`; mdBook comparison-helper audit | Comparison call surface split before code. Current shipped behavior remains unchanged: `num_*` comparisons and receiver `.gt(...)`-style terminals are numeric, bare `eq`/`ne`/`gt`/`ge`/`lt`/`le` are string comparisons in documented flow/helper contexts, and comparison symbol callees are not implemented. The future canonical numeric comparison call surface is word + symbol aliases over `num_*`, but implementation is split behind an explicit `str_*` string-comparison bridge. Frontier becomes `.3.2.3.1`. |
| `2026-07-02` | `SPEC-FORMAT-TERSE.4.4` | mdBook/function-surface audit; Knowledge Map regenerate/check; memory/doctrine/diff checks; full local CI | Function MVP surface finalized after Perl/Rust parity. The book, task tree, and Knowledge Map now state the accepted explicit-paren braced `fn` contract and explicitly defer alternate spellings, optional zero-arg parentheses, brace-less bodies, caller-state/persistent side-effect functions, recursion, closures/lambdas/currying, and namespaces. No parser/compiler/runtime code changed. |
| `2026-07-02` | `SPEC-FORMAT-TERSE.4.3.2` | `cargo fmt --all`; focused Rust runtime `terse_4_3_2`; oracle generator; Rust corpus oracle; `cargo test -p linkedspec-runtime --lib`; `cargo test -p linkedspec-core`; mdBook build; Knowledge Map regenerate/check; memory/doctrine/diff checks; full local CI | Rust user-function runtime parity landed. Registered calls resolve before helper fallback, execute with eager caller-context args and fresh function-local variable stores, return body values into compatible receiver chains, diagnose wrong arity/recursion, and standalone calls discard results. Oracle corpus now includes `terse_4_3_2_user_function_runtime` and passes with **54 fixtures**. |
| `2026-07-02` | `SPEC-FORMAT-TERSE.4.3.1` | Rust code review; `cargo fmt --all --check`; `cargo test -p linkedspec-core`; `cargo test -p linkedspec-runtime --lib`; `cargo test -p linkedspec-runtime --test corpus_oracle`; `mdbook build docs/linkedspec-book`; Knowledge Map regenerate/check; memory/doctrine/diff checks; full local CI | Rust function-definition AST/compiler registry parity landed. `SpecFile` records top-level function definitions before or between rules, `validate()` rejects duplicate/collision/parameter hazards before runtime, and `CompiledSpec` carries `CompiledUserFunction` records with parsed `CodeBlock` bodies and source metadata. Runtime call execution and oracle fixtures remain `.4.3.2`. |
| `2026-07-01` | `SPEC-FORMAT-TERSE.4.2.3` | Syntax checks for `CanonicalEvents.pm`, `Contracts.pm`, `MethodLowering.pm`, `RuleIR/EmitContext.pm`, and `t/phase0_regression.t`; TOOLBOX descriptor/runtime probes for standalone registered calls, standalone receiver chains, unregistered standalone calls, direct/mutual recursion, parser-state helper bodies, host-code-shaped bodies, and nested function syntax; `prove -Iperl t/actionir_ast_parser.t`; `prove -Iperl t/phase0_regression.t`; `mdbook build docs/linkedspec-book`; memory/doctrine/Knowledge Map/diff checks; full local CI | Perl registered standalone user-function calls lower to `VALUE_DROP` with zero raw fallback/unresolved helpers and language-agnostic readiness. Nested user-function calls now pass function-local parameter values, not bare parameter names. Recursion and unsupported function-body constructs stay deterministic unresolved-helper diagnostics with zero raw fallback. Phase0 PASS with **1007 tests** and full local CI PASS. |
| `2026-07-01` | `SPEC-FORMAT-TERSE.4.2.2` | Syntax checks for `MethodLowering.pm`, `Compiler.pm`, `SpecEntry.pm`, `RuleIR/EmitContext.pm`, and `t/phase0_regression.t`; focused integrated probes for registered calls in return/assignment/mutation/helper/receiver-chain slots; phase0 user-function execution regression locks; mdBook build; memory/doctrine/Knowledge Map/diff checks; full local CI | Perl registered user-function value calls execute for exact arity. The compiler threads the function registry into rule ActionIR lowering; generated calls eagerly evaluate args, bind fresh function-local params/locals, and return final-expression or `return(expr)` payloads. Wrong-arity registered calls remain unresolved-helper diagnostics with zero raw fallback. Standalone discard, recursion rejection, and purity diagnostics remain `.4.2.3`. |
| `2026-07-01` | `SPEC-FORMAT-TERSE.4.2.1` | Syntax checks for `perl/LinkedSpec/UserFunctionRegistry.pm`, `Compiler.pm`, `CompilerState.pm`, and `t/phase0_regression.t`; focused descriptor probes for registry projection and duplicate/built-in/rule-label/parameter/malformed diagnostics; `specs/spec.spec` descriptor compile; focused AST suite; `mdbook build docs/linkedspec-book`; memory/doctrine/Knowledge Map/diff checks; full local CI | Perl function-definition grammar/registry descriptor seam landed. `specs/spec.spec` owns the active `function_definition` part; the Perl reference bridge strips top-level functions before ordinary bootstrap while preserving line numbers; descriptors expose `functions`, `meta.function_order`, and `meta.function_count`. Registered value-position calls remain unresolved-helper diagnostics until `.4.2.2`. `specs/spec.spec` ratio remains 1.0000; full local CI PASS with phase0 1005 tests. |
| `2026-07-01` | `SPEC-FORMAT-TERSE.4.1` | KM retrieval (`terse-user-defined-functions-mvp-contract`, `spec-spec-self-hosted-grammar`, Perl ActionIR fallback facts); source reads of `specs/spec.spec`, bootstrap parser, Perl ActionIR AST/lowering, Rust expression/parser/compiler/runtime, oracle generator, and mdBook compiler/backend chapters; TOOLBOX probes for `user_fn(...)` in return, assignment, mutation, receiver-chain, and standalone slots; Knowledge Map card/map update; memory/doctrine/KM/diff checks | User-defined function MVP contract and implementation inventory locked before code. Current ground truth: `specs/spec.spec` owns final `fn` grammar but has no active definition rule yet; bootstrap has no first-class `fn` support; Perl AST parses user-call shapes and value slots diagnose unknown calls through unresolved-helper metadata while standalone unknown calls remain raw; Rust parses call/fluent shapes but unknown helper fallback returns `undef` with a warning. `.4.2` is split into Perl grammar/registry, value-call execution, and standalone-discard/purity leaves; `.4.3` is split into Rust registry and runtime/oracle parity. No parser/compiler/runtime code changed. |
| `2026-07-01` | `SPEC-FORMAT-TERSE.4` | User direction captured; KM retrieval for expression-valued blocks and receiver-dot chains; new KM card `terse-user-defined-functions-mvp-contract` + regenerated `KNOWLEDGE_MAP.md`; task-tree/index/roadmap/live-doc sync; `bash scripts/check_memory_architecture.sh`; `bash knowledge-map/scripts/check_knowledge_map.sh`; `bash scripts/check_doctrines.sh`; `git diff --check`; targeted stale-frontier `rg` search | User-defined pure functions are owned and split before implementation. The accepted MVP is top-level `fn name(args) { ... }` with explicit parentheses, pure value/block bodies, explicit positional parameters, no implicit caller-state capture, and no recursion/closures/lambdas/currying. Function calls are ordinary values that may feed receiver-dot chains; standalone call results are silently discarded. Follow-up decision: final `fn` grammar belongs in `specs/spec.spec`; bootstrap-parser support is temporary migration debt to remove after text-to-AST handoff. Frontier becomes `.4.1` before returning to `.3.2.2`. No parser/compiler/runtime code changed. |
| `2026-07-01` | `SPEC-FORMAT-TERSE.2.3.5` | KM retrieval; full bootstrap/roadmap/mdBook/core-code read; TOOLBOX `call_spec_handler_subst` probes for statement receiver-dot mutations, value-position receiver-dot forms, and function-style pure helper composition; mdBook stale inline-control wording audit | Return-type method chaining split before code. Current ground truth: statement-only `.1.6` receiver-dot mutations lower/run, value-position/chained receiver-dot forms remain unsupported, Rust parses `Expr::FluentChain` but only executes single-call array end mutations as statement side effects. Child leaves `.2.3.5.1`–`.2.3.5.4` now own array/hash/string/number receiver-chain implementation. |
| `2026-07-01` | `SPEC-FORMAT-TERSE.2.3.5.1` | Perl syntax checks and receiver-chain probes; `prove -q -Iperl t/phase0_regression.t`; focused Rust parser/runtime tests (`parse_array_receiver_value_chain`, `terse_2_3_5_1`); `perl -Iperl tools/gen_oracle_corpus.pl`; Rust `corpus_oracle`; mdBook build; memory/doctrine/KM/diff checks | Array receiver-dot value chains landed. Pure array links compose through array-returning helpers, terminals return documented values, receiver-dot `join_values` preserves delimiter-first helper semantics, `split_each` flattens with the supplied delimiter on Rust, and `.1.6` end mutations remain statement-only. Phase0 PASS (996 tests); oracle corpus PASS over 47 fixtures. |
| `2026-07-01` | `SPEC-FORMAT-TERSE.2.3.5.2` | Perl syntax checks and hash receiver-chain probes; focused Rust parser/runtime tests (`parse_hash_receiver_value_chain`, `terse_2_3_5_2`); `perl -Iperl tools/gen_oracle_corpus.pl`; Rust `corpus_oracle`; mdBook build; memory/doctrine/KM/diff checks | Hash receiver-dot value chains landed. Hash-returning links compose through hash helpers, `sorted_keys`/`sorted_values` bridge into array receiver chains, receiver-dot `scalaref` reads hash fields, statement hash mutations stay statement-only, and Rust `merge_hash` later-argument override parity is fixed. Phase0 PASS (997 tests); oracle corpus PASS over 48 fixtures. |
| `2026-07-01` | `SPEC-FORMAT-TERSE.2.3.5.3` | Perl syntax checks for `MethodLowering.pm`, `t/phase0_regression.t`, and oracle generator; focused lowering/runtime/source probes; focused Rust parser/runtime tests (`parse_string`, `terse_2_3_5_3`); `perl -Iperl tools/gen_oracle_corpus.pl`; Rust `corpus_oracle`; phase0 (`prove -q -Iperl t/phase0_regression.t`) | String receiver-dot value chains landed. String-returning links compose from bare scalar, explicit scalar, capture, and string-literal receivers; `split(delim)` bridges into array receiver chains; terminal string methods end the chain with `undef`/`null` on invalid continuations; value-form `split(...)` and `substr(...)` lower as portable helper payloads. Phase0 PASS (998 tests); oracle corpus PASS over 49 fixtures. |
| `2026-07-01` | `SPEC-FORMAT-TERSE.2.3.5.4` | Perl syntax checks for `MethodLowering.pm`, `t/phase0_regression.t`, and oracle generator; focused lowering/runtime/source probes; focused Rust parser/runtime tests (`parse_number_receiver`, `parse_decimal_number_receiver`, `terse_2_3_5_4`); `perl -Iperl tools/gen_oracle_corpus.pl`; Rust `corpus_oracle`; phase0 (`prove -q -Iperl t/phase0_regression.t`) | Number receiver-dot value chains landed. Numeric links compose through `num_*` helpers, integer/decimal literal receivers parse, comparison methods are terminal, value-form numeric comparisons lower on Perl, Rust `num_add`/`num_mul` consume all operands, and statement/lifecycle methods such as `declare(...)` remain outside terse receiver methods. Phase0 PASS (999 tests); oracle corpus PASS over 50 fixtures. |
| `2026-07-01` | `SPEC-FORMAT-TERSE.2.3.5.6` | Perl syntax checks for `MethodLowering.pm`, `ValueExpr.pm`, `t/phase0_regression.t`, and oracle generator; focused lowering/runtime/source probes for bare vs quoted aggregate wrappers and direct shapes; full phase0 (`prove -q -Iperl t/phase0_regression.t`); focused Rust `.2.3.5.6` integration tests; `perl -Iperl tools/gen_oracle_corpus.pl`; Rust `corpus_oracle`; `mdbook build docs/linkedspec-book`; Knowledge Map/memory/doctrine/diff/local CI gates | Typed wrapper quoted-name boundaries landed. Bare `array(foo)` / `a(foo)` and `hash(bar)` / `h(bar)` are explicit aggregate working-variable reads; quoted wrapper arguments remain literal constructor payloads and are not scalar-indirect aliases; direct `[...]` and `{...}` shapes are the preferred terse constructors. Perl generic value-expression lowering now recognizes direct shape literals in helper composition and avoids reserving primitive literals or inappropriate engine locals as aggregate symbols. Phase0 PASS (1000 tests); oracle corpus PASS over 51 fixtures. |
| `2026-07-01` | `SPEC-FORMAT-TERSE.2.3.5.5` | Perl syntax checks for `MethodLowering.pm`, `t/phase0_regression.t`, and oracle generator; focused Perl lowering/runtime probes; focused Rust parser/runtime tests (`parse_block_valued_receiver_chain`, `terse_2_3_5_5`); `perl -Iperl tools/gen_oracle_corpus.pl`; Rust `corpus_oracle`; full phase0 (`prove -q -Iperl t/phase0_regression.t`); `mdbook build docs/linkedspec-book`; Knowledge Map/memory/doctrine/diff checks | Block-valued receiver-dot chains landed. Expression-valued blocks now feed their yielded array/string/hash/number values into the compatible receiver-family chains; Perl array-yielding blocks use narrow visible-exit recognition and Rust parses fluent chains after block/hash/array primaries. Phase0 PASS (1001 tests); oracle corpus PASS over 52 fixtures. |
| `2026-07-01` | `SPEC-FORMAT-TERSE.5.0` | Full bootstrap/roadmap/mdBook/codebase read; ADR `0006` + Phase 8/9 task-tree audit; `rg` source inventory for Julia/Dart/Lua implementation paths; Knowledge Map backend fact correction; mdBook backend-handoff status update; memory/doctrine/KM/diff checks; `mdbook build docs/linkedspec-book` | Future variant parity ownership landed before any non-Rust variant code. Implemented backends are Perl reference and Rust; later ADR `0021` adopts Lua and schedules Dart, Julia, and Lua in `FUTURE-PARITY-BACKLOG`. No parser/compiler/runtime code changed. |
| `2026-07-01` | `SPEC-FORMAT-TERSE.3.1` | Existing phase0 locks audited (`bootstrap_grouped_action_edge_targets_share_one_code_block`, `validation_accepts_grouped_action_edge_targets_with_shared_code_block`, `validation_rejects_grouped_action_edge_targets_without_shared_code_block`, `validation_accepts_grouped_action_edge_with_three_targets`); focused `perl -Iperl` validation/bootstrap probes for grouped shared-block acceptance, two-target `ACODE` expansion, and block-less grouped-target rejection; full phase0 (`prove -q -Iperl t/phase0_regression.t`, 1001 tests); `bash tools/run_ci_local.sh`; mdBook boundary wording; Knowledge Map fact card | Edge syntax contract locked without parser/compiler/runtime code change. `->` action edges and `=>` blind-call edges stay as-is. Grouped targets are valid only with one shared `{ ... }` block; the block-less `-> A | B` form stays invalid with the existing diagnostic. Frontier becomes `.3.2` for arithmetic/comparison function spellings. |
| `2026-07-01` | `SPEC-FORMAT-TERSE.3.2` | Knowledge Map retrieval (`spec-format-brainstorm-rounds-1-3`, `terse-number-receiver-value-chains`, `terse-composability-audit-boundaries`); TOOLBOX `call_spec_handler_subst`/runtime/flow-lowering probes for `num_*`, bare word aliases, symbol callees, and comparison helpers; source reads of Perl `MethodExpr`/`MethodLowering` and Rust expression parser/runtime helper dispatch; mdBook comparison-helper audit; memory/doctrine/KM/diff checks | Arithmetic/comparison call surface split before code. Current ground truth: `num_*` helpers are the implemented numeric family, bare `add(...)`/`sum(...)` do not lower as numeric helpers, symbol callees are not parsed portably, raw Perl can misinterpret `+(2,3)`, and bare `eq`/`gt`/etc. are current string comparisons. Frontier becomes `.3.2.1` for non-conflicting numeric word aliases. |
| `2026-07-01` | `SPEC-FORMAT-TERSE.3.2.1` | Perl syntax checks for `MethodExpr.pm`, `MethodLowering.pm`, `FlowExpr.pm`, `BootstrapSpec/Core.pm`, phase0, and oracle generator; focused Perl lowering/runtime probes for numeric aliases, comparison boundary, and receiver-chain preservation; `perl -Iperl tools/gen_oracle_corpus.pl`; Rust corpus oracle; full phase0 (`prove -q -Iperl t/phase0_regression.t`); focused Rust integration test; `mdbook build docs/linkedspec-book` | Numeric word aliases landed on Perl/Rust. `add`/`sub`/`mul`/`div`/`mod`, unary/rounding helpers, `min`/`max`/`clamp`, and reducers `sum`/`avg`/`median`/`range` now dispatch to the existing `num_*` family. Receiver-dot number chains remain stable because Perl aliasing happens after receiver normalization. Bare `gt(...)` remains string comparison. Phase0 PASS (1002 tests); oracle corpus PASS over 53 fixtures. Frontier becomes `.3.2.2`. |
| `2026-07-02` | `SPEC-FORMAT-TERSE.3.2.2` | Perl syntax checks for `MethodExpr.pm`, `AST/Parser.pm`, `Validation.pm`, `BootstrapSpec/Core.pm`, `MethodLowering.pm`, and `FlowExpr.pm`; TOOLBOX lowering/runtime/source probes for `+(...)`, `-(...)`, `*(...)`, `/(...)`, `%(...)`, nested symbol calls, and slash-regex preservation; full phase0 (`prove -q -Iperl t/phase0_regression.t`); Rust core parser tests; focused Rust runtime `.3.2.2` integration test; `perl -Iperl tools/gen_oracle_corpus.pl`; Rust corpus oracle; Rust core suite | Arithmetic symbol callees landed on Perl/Rust. `+(a,b)`, `-(a,b)`, `*(a,b)`, `/(a,b)`, and `%(a,b)` now dispatch to the existing numeric helper family without raw host fallback, while slash-regex literals such as `/(\))/` and `/(?<!\\)}/` remain regexes. Phase0 PASS (1008 tests); oracle corpus PASS over 55 fixtures. Broader full Rust runtime integration also confirmed `.3.2.2` passes, but still contains unrelated stale short-wrapper alias tests from the earlier `s/a/h` retirement baseline. Frontier becomes `.3.2.3`. |
| `2026-06-16` | `SPEC-FORMAT-TERSE` | Transcription faithful to `docs/knowledge/spec-format-brainstorm-rounds-1-3.md` | Done — all Rounds 1–3 captured as leaves; Round 4+ as a discovery leaf |
| `2026-06-18` | `SPEC-FORMAT-TERSE.0` | ADR `0007` written + indexed; cross-checked Rounds 1–3 vs the user's 2026-06-18 clarifications (all consistent); `scripts/check_memory_architecture.sh`; KM gate | self-check + KM gate pass. Direction ratified; migration policy = gradual alias; tree `proposed`→`active`. Design-only — regression gate N/A to `.0`. No engine/book change |
| `2026-06-23` | `SPEC-FORMAT-TERSE.1.1` (split) | `dump_parser_source` ground-truth probes (scratchpad `probe_autovar*.pl`, dump-don't-transcribe) establishing the one-scope / non-strict / preamble-`my` model; `grep -c 'use strict' perl/LinkedSpec/SpecEntry.pm` = 0; baseline `scripts/check_memory_architecture.sh`, `scripts/check_doctrines.sh` (2/2), KM gate all EXIT 0 | Split `.1.1` → `.1.1.1`+`.1.1.2`; design recorded; KM card [[working-vars-no-strict-need-my-lexical]] added (map regenerated). Docs/tree/KM-only — no engine/book change, so phase0 N/A to the split slice |
| `2026-06-24` | `SPEC-FORMAT-TERSE.1.1.1` | `dump_parser_source` ground truth (no-declare leaky-global → injected `my`); all-20-specs generated-source diff (mine vs git-stashed code files); `tkgui` parse-output before/after incl. a 2nd same-process parse; `perl -c`; +3 phase0 locks; `bash tools/run_ci_local.sh`; `mdbook build` | **19/20 specs byte-identical**; only `tkgui` differs (+1 legit `my $subgui_name;`, parse output identical before/after); Lispish `a(undef)`→`my @undef` false-positive caught by the diff + fixed (reserved-literal exclusion); **phase0 965→968 green**; gate **EXIT 0** ("Result: PASS", 968); `mdbook build` EXIT 0; ratio 1.0000 preserved (phase0 all-target guard green) |
| `2026-06-24` | `SPEC-FORMAT-TERSE.1.1.2` | Throwaway Rust + Perl `LinkedSpec::Get` probes (dump-don't-guess) on the same minimal grammars; read `runtime.rs`/`engine.rs` variable model; `tools/gen_oracle_corpus.pl` (5 new `autoexist_*` fixtures, existing 2 byte-identical); `cargo test`; `cargo clippy`; `perl -c` generator; `bash tools/run_ci_local.sh`; `mdbook build` | **Assessed DOABLE, no engine change** — Rust HashMaps auto-vivify + fresh ctx per parse ⇒ auto-existence inherent, no leaky-global hazard. Cross-variant proof: scalar no-declare Perl `"ok"`/Rust `["ok"]`; array no-declare Perl `["a","b"]`/Rust `[["a","b"]]`; declare twins identical; `array(undef)` Perl `[null]`/Rust `[[null]]` (= Perl reference wrapped one level). **cargo 244→248 green**; all **7 oracle fixtures PASS**; clippy zero-new (engine.rs 11 = baseline; test files add 0); `perl -c` OK; **phase0 968 green** (Perl untouched), gate **EXIT 0**; `mdbook build` EXIT 0. Recursive/REP idiom deferred to `RUST-PARITY` (separate gap). |
| `2026-06-24` | `SPEC-FORMAT-TERSE.1.2` (split) | `dump_parser_source` ground-truth probes (`perl -Iperl -MLinkedSpec`, `generate_only`+`runtime_ctx_ref`; scratchpad `probe_terse_1_2.pl` + isolated one-liners, dump-don't-guess); confirmed `perl -Iperl` loads `perl/LinkedSpec.pm` (stale `PERL5LIB` present); `perl -c` on `ValueExpr.pm`/`MethodLowering.pm`/`EmitContext.pm`; `grep` wrapper-usage census across `specs/*.spec`; baseline `scripts/check_memory_architecture.sh` + `scripts/check_doctrines.sh` + KM gate | Split `.1.2` → `.1.2.1` (Perl, Channel 1) + `.1.2.2` (Rust parity); Channel 2 (`.1.2.3`+) recorded as a follow-on (not pre-published). Ground truth: bare arg-position var lowers right but no auto-`my` (leaky global); bare value-position word is not a var read (`return count`); wrapped path auto-exists (`.1.1.1`). KM card [[terse-bare-working-vars-engine-gaps]] added (map regenerated). DOCS/TREE/KM only — no engine/book change, so phase0 N/A to the split slice |
| `2026-06-24` | `SPEC-FORMAT-TERSE.1.2.1` | `dump_parser_source` ground truth (scratchpad `probe_terse_1_2_1.pl`, isolated bare forms, dump-don't-guess); all-20-specs generated-source diff (mine vs git-stashed `EmitContext.pm`); `perl -c` on `EmitContext.pm`/`LinkedSpec.pm` + `t/phase0_regression.t`; +3 phase0 locks; `bash tools/run_ci_local.sh`; `mdbook build` | Collector extended (bare arg-position pass; `assign`→`$`, `push_value`/`push_nonempty`→`@`; `\s*,` guard keeps wrapped on the wrapped path; shared `$record` dedup). **All 20 specs byte-identical (0 diff)**; bare forms now emit the preamble `my` (incl. `assign(pair, set_key(hash(pair),…))` → both `my %pair` + `my $pair`); **phase0 968→971 green**; gate **EXIT 0** ("[ci] local CI gate passed", 971); ratio 1.0000; `mdbook build` EXIT 0. Book (3 pages) taught bare arg-position auto-existence + corrected the outdated "arg-position is later" note. Child-append/`.push` target + bare hash deferred to Channel 2. |
| `2026-06-24` | `SPEC-FORMAT-TERSE.1.2.2` | Throwaway Rust integration probe (bare vs wrapped, dump-don't-guess); read `engine.rs` resolvers; `tools/gen_oracle_corpus.pl` +2 fixtures (regenerated, existing 7 byte-identical); `cargo test`; `cargo clippy`; `perl -c gen_oracle_corpus.pl`; `bash tools/run_ci_local.sh` | **REQUIRED a Rust engine change** (contrast `.1.1.2`): bare `Expr::Variable` target fell through to `val.to_str()` → probe `[null]`/`[[]]`. Added bare-target acceptance to `resolve_scalar_target` + `resolve_array_target` (`allow_bare` gate; push targets true, array_copy/hash_copy false) → probe now `["ok"]`/`[["a","b"]]` (= wrapped = Perl reference). 2 oracle fixtures (`autoexist_{scalar,array}_bare_arg`) + 4 `terse_1_2_2_*` integration tests; **cargo 248→252 green**, 9/9 oracle PASS, clippy zero-new (engine.rs 11 baseline; flattened my `if allow_bare` nest to a tuple `if let`), `perl -c` OK; **phase0 971 green** (Perl untouched), gate **EXIT 0**; no book change (variant-agnostic). Channel 1 complete on both variants. |
| `2026-06-24` | `SPEC-FORMAT-TERSE.1.4` (split) | TOOLBOX `call_spec_handler_subst` ground-truth probes (`perl -Iperl -MLinkedSpec`, dump-don't-guess; `perl -Iperl` confirmed `perl/LinkedSpec.pm` over the stale `PERL5LIB`); read the alias seam `ActionIR/MethodExpr.pm` + the `assign`/`concat`/`array_copy`/`hash_copy` lowering sites; Rust mapping of `Engine::call_helper()`; baseline `scripts/check_doctrines.sh` (MEMORY-ARCH + KNOWLEDGE-MAP) + KM regenerate | Split `.1.4` → `.1.4.1` (Perl) + `.1.4.2` (Rust parity). Ground truth: `set`/`cat`/`copy` all currently UNRECOGNIZED (`set`→passthrough vs `assign`→`$x = 1`; `cat`→passthrough vs `concat`→do-block; `copy(a(x))`→`copy([items])` partial / `copy(h(x))`→passthrough vs `array_copy`→`[@items]` / `hash_copy`→`{%m}`). Three shapes: `cat`=pure rename (`_normalize_method_name`); `set`=statement-level (`Contracts.pm`/`DeclareMethod` — not reached by normalization); `copy`=unified array-vs-hash dispatch (`MethodLowering`). KM card [[terse-helper-rename-lowering-sites]] added (map regenerated). DOCS/TREE/KM only — no engine/book change, so phase0 N/A to the split slice |
| `2026-06-24` | `SPEC-FORMAT-TERSE.1.4.1` | TOOLBOX-first `call_spec_handler_subst` parity sweep (4 headline + 11 composed forms, dump-don't-guess); `return_descriptor` ASSIGN-node parity for `set`; end-to-end `LinkedSpec::Get` run of a terse spec vs its canonical twin; all-20-specs generated-source baseline-vs-mine diff (STDOUT capture via `dump_parser_source`); `perl -c` on all 8 edited modules; +4 phase0 locks; `bash tools/run_ci_local.sh`; `mdbook build`; doctrine driver + KM regenerate | Aliases recognized at **every** site each canonical name is (normalize seam + 3 raw-text `set` scanners + `copy` dispatch + declare-init/return-payload/FlowExpr-source/type-inference recognizers). **All 4 headline + 11 composed forms byte-equal to canonical**; `set`==`assign` ASSIGN node; terse spec runs == canonical twin (`["a!","b!","c!"]`, stable on re-run). **All 20 specs byte-identical (0 diff)** — every alias add is new-spelling-guarded. **phase0 971→975 green**; gate **EXIT 0** ("Result: PASS", 975); ratio 1.0000; `mdbook build` EXIT 0. Book (3 pages) taught the renames as canonical + old names as deprecated (not-retired) aliases. KM [[terse-helper-rename-lowering-sites]] updated (landed; reverify proves parity). |
| `2026-06-29` | `SPEC-FORMAT-TERSE.1.4.2` | Rust code-read + implementation in `Engine::call_helper()`; `perl -c tools/gen_oracle_corpus.pl`; `perl -Iperl tools/gen_oracle_corpus.pl`; focused `cargo test --manifest-path rust/linkedspec-runtime/Cargo.toml terse_1_4_2 -- --nocapture`; `cargo test --manifest-path rust/linkedspec-runtime/Cargo.toml --test corpus_oracle -- --nocapture`; full `cargo test --manifest-path rust/linkedspec-runtime/Cargo.toml`; `cargo clippy --manifest-path rust/linkedspec-runtime/Cargo.toml`; `perl -Iperl t/phase0_regression.t`; `bash tools/run_ci_local.sh`; doctrine + KM gates | Rust now recognizes `set`/`cat` via canonical match arms and unified `copy` via a dedicated array/hash value-copy arm. Added `resolve_hash_target` and one-bare-variable `hash`/`h` reference handling so `copy(h(m))` converges with `hash_copy(h(m))`; bare value-position reads remain deferred. 2 new oracle fixtures (`terse_1_4_2_set_cat_copy_array`, `terse_1_4_2_copy_hash_symbol_empty`) + 3 integration tests. Focused Rust tests PASS; corpus oracle PASS over 11 fixtures; full runtime suite PASS (116 unit + corpus-oracle harness + 36 integration tests); clippy EXIT 0 with existing 13-warning baseline only; phase0 stays **975 green**; full local gate EXIT 0. No book change; `.1.4` container done. |
| `2026-06-29` | `SPEC-FORMAT-TERSE.1.3` (split) | Knowledge Map retrieval first; read `.1.3` acceptance + relevant mdBook/helper cards; TOOLBOX `call_spec_handler_subst` probe over function/operator forms; minimal `LinkedSpec::Get` runtime probes; Rust `expr.rs`/`engine.rs` code-read; KM regenerate | Split `.1.3` by mechanism. `set(name,val)` already lowers/runs like `assign(name,val)` and is locked by `.1.4`; `push_value(name,val)` lowers/runs but requested `push(name,val)` passes through Perl as raw child-call-shaped `push(...)` and fails handler compilation, while conflicting with existing `push(Rule,target)` convention; `set_key(name,k,v)` works as a Perl pure hash value in return/source paths but not as a standalone mutation statement, and Rust only updates if arg0 is already a hash; operators `name = val`, `items += val`, `name["k"] = val` pass through as raw/invalid Perl and Rust has no assignment AST. `.1.3.1` audit done; next `.1.3.2`. No engine/book change, so phase0/cargo N/A to split slice beyond doctrine/KM checks. |
| `2026-06-29` | `SPEC-FORMAT-TERSE.1.3.2` | TOOLBOX `call_spec_handler_subst` lowerings for explicit append vs child-call forms; descriptor/runtime probe; `dump_parser_source` lock for nested/comma value; `perl -c` edited Perl modules + test/generator; `prove -q -Iperl t/phase0_regression.t`; `perl -Iperl tools/gen_oracle_corpus.pl`; focused Rust integration test; Rust corpus oracle; `mdbook build`; Knowledge Map gate; `scripts/check_memory_architecture.sh`; `bash tools/run_ci_local.sh` | Perl recognizes `push(target,value)` as explicit-value append for unambiguous/non-all-bare value expressions while preserving all-bare child-call precedence. `push(items,"a")`, `push(items, scalar(retv))`, `push(array(items), scalar(retv))`, `push(items, call(Leaf))`, and `push(items, cat("a","b"))` lower like `push_value`; `push(items, value)`, `push(Leaf, items)`, and indexed child-call forms stay child calls. Descriptor/runtime probe has zero fallback/unresolved and returns `["a","b"]`; nested/comma source dump has exactly one `my @items`; phase0 PASS (975); focused Rust test PASS; corpus oracle PASS over 12 fixtures; mdBook build EXIT 0; Knowledge Map and memory-architecture checks OK; full local gate EXIT 0. |
| `2026-06-29` | `SPEC-FORMAT-TERSE.1.3.3` | TOOLBOX `call_spec_handler_subst` lowerings for mutation vs pure value form; descriptor/runtime/source-dump probes; `perl -c` edited Perl modules + test/generator; `prove -q -Iperl t/phase0_regression.t`; `perl -Iperl tools/gen_oracle_corpus.pl`; focused Rust `terse_1_3_3`; Rust corpus oracle; `mdbook build`; Knowledge Map gate; `scripts/check_memory_architecture.sh`; `scripts/check_doctrines.sh`; `bash tools/run_ci_local.sh` | Perl recognizes `set_key(name,key,value)` as a statement-level named-hash mutation and emits `my %name` for a bare hash target. Nested `set_key(hash_expr,key,value)` remains pure/copy-valued. Rust mirrors statement mutation in `Engine::execute_block()` and keeps value helper behavior in `call_helper()`. Phase0 PASS (976); focused Rust tests PASS; corpus oracle PASS over 13 fixtures; mdBook build EXIT 0; Knowledge Map, memory-architecture, doctrine checks, and full local gate OK. |
| `2026-06-29` | `SPEC-FORMAT-TERSE.1.3.4` (split) | KM retrieval; TOOLBOX `call_spec_handler_subst` for operator forms vs settled function forms; `return_descriptor` on a spec containing all three operators; Rust `expr.rs` + `engine.rs` code-read | Split `.1.3.4` into `.1.3.4.1` scalar assignment, `.1.3.4.2` array append, `.1.3.4.3` hash-index assignment. Perl reports `name = "ok"`, `items += "a"`, and `name["k"] = "v"` as three RAW_PERL/language-agnostic blockers while settled function forms lower. Rust lifecycle code is expression-statement-only (`Stmt { expr }`) and has no assignment/append/hash-set statement variants. No engine/book behavior change; split slice owns sequencing and frontier only. |
| `2026-06-29` | `SPEC-FORMAT-TERSE.1.3.4.1` | TOOLBOX lowerings for scalar operator vs `set(...)`; descriptor/source/runtime probes; `perl -c` edited Perl modules + test/generator; `prove -q -Iperl t/phase0_regression.t`; `perl -Iperl tools/gen_oracle_corpus.pl`; focused Rust core `scalar_assignment`; focused Rust runtime `terse_1_3_4_1`; full Rust runtime suite; `mdbook build`; Knowledge Map, memory-architecture, doctrine, and full local CI gates | Perl recognizes top-level `NAME = RHS` as an ASSIGN statement and auto-declares the scalar target; Rust parses and executes statement-only `AssignScalar`. `name = cat(...)` lowers identically to `set(name, cat(...))`; `name == ...`, `items += ...`, `name[key] = ...`, and keyword-arg `name=...` remain out of scope. Phase0 PASS (`1..977`); oracle corpus regenerated with 14 fixtures; focused Rust tests PASS; full runtime suite PASS (116 unit + corpus-oracle harness + 41 integration tests); public book and KM updated. |
| `2026-06-29` | `SPEC-FORMAT-TERSE.1.3.4.2` | TOOLBOX lowerings for array operator vs `push(...)` / `push_value(...)`; descriptor/source/runtime probes; `perl -c` edited Perl modules + test/generator; `prove -q -Iperl t/phase0_regression.t`; `perl -Iperl tools/gen_oracle_corpus.pl`; focused Rust core `array_append`; focused Rust core `scalar_assignment`; focused Rust runtime `terse_1_3_4_2`; Rust corpus oracle; full Rust runtime suite; `mdbook build`; Knowledge Map, memory-architecture, doctrine, and full local CI gates | Perl recognizes top-level `NAME += RHS` as a PUSH statement and auto-declares the array target; Rust parses and executes statement-only `AssignArrayAppend`. `items += "a"`, `items += cat(...)`, and `items += scalar(value)` lower/run like explicit append forms; `items += value`, `items ++`, scalar assignment, and hash-index assignment stay separate. Phase0 PASS (`1..978`); oracle corpus regenerated with 15 fixtures; focused Rust tests PASS; full Rust runtime suite PASS (116 unit + corpus-oracle harness + 43 integration tests); public book and KM updated. |
| `2026-06-29` | `SPEC-FORMAT-TERSE.1.3.4.3` | TOOLBOX lowerings for hash-index operator vs `set_key(...)`; `perl -c` edited Perl modules + test/generator; `prove -q -Iperl t/phase0_regression.t`; `perl -Iperl tools/gen_oracle_corpus.pl`; focused Rust core `hash_index`; focused Rust core `scalar_assignment`; focused Rust core `array_append`; focused Rust runtime `terse_1_3_4_3`; Rust corpus oracle; full Rust runtime suite; `mdbook build`; Knowledge Map, memory-architecture, doctrine, and full local CI gates | Perl recognizes top-level `NAME[KEY] = RHS` as an ASSIGN statement and auto-declares the hash target; Rust parses and executes statement-only `AssignHashIndex`. `meta["stage"] = "v"`, `meta[cat("s","tage")] = cat("v","!")`, and `meta[scalar(key)] = scalar(value)` lower/run like `set_key(...)`; bare key/RHS forms remain deferred to Channel 2. Phase0 PASS (`1..979`); oracle corpus regenerated with 16 fixtures; focused Rust tests PASS; full Rust runtime suite PASS; public book and KM updated. |
| `2026-06-29` | `SPEC-FORMAT-TERSE.1.5.1` (split) | KM retrieval first; TOOLBOX `call_spec_handler_subst` probes for literals, call spacing, direct nested access, and `scalaref(...)`; `LinkedSpec::Get` runtime probes for literal values and separator behavior; `StatementSplit` probes; Perl/Rust code-read (`StatementSplit`, `MethodExpr`, `ValueExpr`, `MethodLowering`, Rust `expr.rs`/`engine.rs`); focused Rust parser tests (`parse_`, `hash_index`); `knowledge-map/scripts/check_knowledge_map.sh`; `scripts/check_memory_architecture.sh`; `scripts/check_doctrines.sh`; `git diff --check` | Split `.1.5` into `.1.5.2` literal parity, `.1.5.3` call-spacing locks, `.1.5.4` separator semantics, and `.1.5.5` direct nested access. Ground truth: Perl strings/numbers/`undef` run, but `true`/`false` are strings; call spacing works at supported helper/value sites; newline-separated lowered statements fail on Perl without `;`; direct nested access is not lowered and Rust only has single array-index `IndexedVar`. KM card [[terse-literals-calls-separators-access-ground-truth]] added. DOCS/TREE/KM only — no engine/book behavior change, so phase0 N/A to split slice. |
| `2026-06-29` | `SPEC-FORMAT-TERSE.1.5.2` | Syntax checks on edited Perl ActionIR modules/test/generator; `env PERL5LIB= prove -q -Iperl t/phase0_regression.t`; `perl -Iperl tools/gen_oracle_corpus.pl`; focused Rust `.1.5.2` integration tests; Rust corpus oracle; full Rust runtime suite; `mdbook build docs/linkedspec-book`; Knowledge Map regenerate/check; memory/doctrine checks; `git diff --check`; `bash tools/run_ci_local.sh` | Perl now lowers exact primitive literals through a shared helper, with `true`/`false` as `JSON::PP` booleans and exact-prefix boundaries preserved. Scanner/lowerer guards treat primitive literals as explicit values in `push`, `+=`, and hash-index assignment. Rust statement-form `if/elseif/else/endif` now gates lifecycle statements so `if(false)` selects the `else` branch. Phase0 PASS (`1..980`); oracle corpus regenerated with 18 fixtures; focused Rust tests PASS (2); corpus oracle PASS over 18 fixtures; full runtime/mdBook/KM/memory/doctrine/local gates green. |
| `2026-06-29` | `SPEC-FORMAT-TERSE.1.5.3` | Syntax checks on edited Perl test/generator; focused Rust parser `.1.5.3` tests; focused Rust runtime `.1.5.3` integration test; `perl -Iperl tools/gen_oracle_corpus.pl`; Rust corpus oracle; `env PERL5LIB= prove -q -Iperl t/phase0_regression.t`; `mdbook build docs/linkedspec-book`; Knowledge Map regenerate/check; memory/doctrine checks; `git diff --check`; `bash tools/run_ci_local.sh` | Helper calls keep mandatory `callee(args)` parentheses while optional whitespace before `(` is accepted at supported statement/value sites. Perl locks spaced-vs-tight equality for `return`, `set`, nested helpers, operator RHS calls, and hash-index key/RHS calls; no-parenthesis spellings stay raw/out of helper recognition. Rust parser/runtime/oracle locks prove the same contract. Phase0 PASS (`1..981`); oracle corpus regenerated with 19 fixtures; focused Rust tests PASS; corpus oracle PASS over 19 fixtures; full runtime/mdBook/KM/memory/doctrine/local gates green. |
| `2026-06-29` | `SPEC-FORMAT-TERSE.1.5.4` | Syntax checks on edited Perl modules/test/generator; TOOLBOX lowerings and runtime probes for newline/semicolon/same-line cases; `env PERL5LIB= prove -q -Iperl t/phase0_regression.t`; `perl -Iperl tools/gen_oracle_corpus.pl`; focused Rust core separator tests; focused Rust runtime `.1.5.4` integration test; Rust corpus oracle; full Rust runtime suite; `mdbook build docs/linkedspec-book`; Knowledge Map regenerate/check; memory/doctrine checks; `git diff --check`; `bash tools/run_ci_local.sh` | Newline and semicolon are the statement separators; same-line whitespace is not. Perl `StatementSplit` only implicit-splits across line breaks, `RewritePipeline` emits generated Perl terminators for newline-separated canonical statements, and Bootstrap normalizes fluent attached-control tails with internal newlines. Rust parser/runtime locks enforce the same contract. Phase0 PASS (`1..982`); oracle corpus regenerated with 20 fixtures; focused Rust tests PASS; corpus oracle PASS over 20 fixtures; full runtime/mdBook/KM/memory/doctrine/local gates green. |
| `2026-06-29` | `SPEC-FORMAT-TERSE.1.5.5` (split) | KM retrieval; TOOLBOX `call_spec_handler_subst` probes comparing direct bracket access against `scalaref(...)`; `LinkedSpec::Get` generated-source/runtime probe for direct access; Perl code-read (`ValueExpr`, `MethodLowering`); Rust code-read (`expr.rs`, `engine.rs`); Knowledge Map regenerate/check; memory/doctrine checks; `git diff --check` | Split `.1.5.5` into `.1.5.5.1` explicit-segment direct access and `.1.5.5.2` bare path-segment / Channel 2 coordination. Direct `foo["a"][9]["b"][scalar(z)]` currently emits invalid Perl-shaped `foo["a"][9]["b"][$z]`, while `scalaref(foo,{"a"}[9]{"b"}[scalar(z)])` lowers correctly. Bare segment `z` remains a Channel 2 value-position read problem. No engine/book behavior change, so phase0/cargo/local CI are N/A to the split slice beyond doctrine/memory/KM checks. |
| `2026-06-29` | `SPEC-FORMAT-TERSE.1.5.5.1` | TOOLBOX lowerings for direct access vs `scalaref(...)`; generated-source/runtime probe; Perl syntax checks (`ValueExpr.pm`, `MethodLowering.pm`, `EmitContext.pm`, phase0, oracle generator); focused Rust parser/runtime tests; oracle regeneration; Rust corpus oracle; full phase0; full Rust runtime suite; `mdbook build docs/linkedspec-book`; Knowledge Map regenerate/check; memory/doctrine checks; `git diff --check`; `bash tools/run_ci_local.sh` | Direct nested access with explicit path segments landed. Perl lowers `foo["a"][9]["b"][scalar(z)]` to `$foo->{"a"}->[9]->{"b"}->[$z]` and leaves bare `[z]` outside canonical lowering. Rust parses mixed/multi-segment explicit paths as `NestedAccess`, preserves one-level `name[index]` as `IndexedVar`, rejects bare nested path atoms as Channel 2-reserved, and evaluates mixed hash/array paths from the scalar-held base value. Phase0/Rust/oracle/book/KM/memory/doctrine/local gates green. |
| `2026-06-29` | `SPEC-FORMAT-TERSE.1.5.5.2` | KM retrieval; TOOLBOX `call_spec_handler_subst` reverify for explicit direct access, bare direct access, `scalaref(...)`, and `return(z)`; Rust focused parser rejection lock `parse_direct_nested_access_rejects_bare_segments`; memory/doctrine/KM checks; `git diff --check` | `.1.5.5.2` is superseded into `.1.2.3`. Reverify shows `foo["a"][9]["b"][z]` and `return(z)` still share the same bare value-position-read gap, while explicit `[scalar(z)]` works. No engine/book behavior changed; the next executable frontier is `.1.2.3`, which owns the global Channel 2 design/split. |
| `2026-06-29` | `SPEC-FORMAT-TERSE.1.2.3` (split) | KM retrieval; TOOLBOX `call_spec_handler_subst` probes for scalar-like bare reads, aggregate bare reads, direct bare access, and mutation RHS/key blockers; `dump_parser_source` probes for aggregate bare reads; Perl code-read (`ValueExpr`, `MethodLowering`); Rust code-read (`expr.rs`, `engine.rs` resolver/eval paths); Knowledge Map regenerate/check; memory/doctrine checks; `git diff --check` | Split Channel 2 into aggregate and scalar value-read surfaces. Perl aggregate bare reads lower but lack auto-`my`; Rust aggregate-copy value-read resolvers keep bare reads out; Perl scalar-like reads remain bareword/raw while Rust variables already evaluate as scalar reads. No engine/book behavior change. Frontier becomes `.1.2.3.1`. |
| `2026-06-29` | `SPEC-FORMAT-TERSE.1.2.3.1` | Perl syntax checks (`EmitContext.pm`, `phase0_regression.t`); focused generated-source/runtime/no-leak probe for `array_copy(items)`, `hash_copy(meta)`, `copy(items)`; `prove -q -Iperl t/phase0_regression.t`; `mdbook build docs/linkedspec-book`; Knowledge Map regenerate/check; memory/doctrine/diff checks; `bash tools/run_ci_local.sh` | Perl aggregate bare value reads now auto-exist safely. `_collect_auto_working_var_decls` collects `array_copy(NAME)` and `copy(NAME)` as array reads and `hash_copy(NAME)` as hash reads, deduping with wrapped/declared/mutation paths and skipping reserved literals. Phase0 PASS (`1..984`, including the new 17-assertion subtest with same-parser array/hash reruns); mdBook/KM/local CI PASS. Frontier becomes `.1.2.3.2` for Rust parity. |
| `2026-06-29` | `SPEC-FORMAT-TERSE.1.2.3.2` | `cargo fmt --manifest-path rust/linkedspec-runtime/Cargo.toml`; `perl -c tools/gen_oracle_corpus.pl`; focused Rust runtime `terse_1_2_3_2`; focused Rust core `parse_direct_nested_access_rejects_bare_segments`; `perl -Iperl tools/gen_oracle_corpus.pl`; Rust corpus oracle; full Rust runtime suite; `cargo clippy --manifest-path rust/linkedspec-runtime/Cargo.toml`; phase0; mdBook; KM/memory/doctrine/diff checks; full local CI | Rust aggregate bare value reads now match the Perl reference. `array_copy(NAME)` / `copy(NAME)` resolve bare names as array working vars, `hash_copy(NAME)` resolves bare names as hash working vars, and `copy(hash(NAME))` stays the explicit hash path. Added 4 integration locks + 4 oracle fixtures; corpus oracle PASS over 25 fixtures; full runtime PASS (116 unit tests, 25 oracle fixtures, 54 integration tests); clippy EXIT 0 with existing warnings only. Scalar bare reads and bare direct-access path atoms remain deferred to `.1.2.3.3`. |
| `2026-06-29` | `SPEC-FORMAT-TERSE.1.2.3.3` (split) | KM retrieval; TOOLBOX `call_spec_handler_subst` probes for return/assignment bare reads, named hash mutation key/value slots, array append and hash-index operator blockers, direct-access path atoms, `scalaref(...)`, `scalar(container,key)`, and all-bare `push(A,B)`; Perl code-read (`ValueExpr`, `MethodLowering`, scanner, auto-var collector); Knowledge Map regenerate/check; memory/doctrine checks; `git diff --check` | Split Perl scalar bare reads by lowering seam before code. Return/assignment-like source slots remain raw barewords; mutation key/RHS forms are split because named `set_key` already lowers bare keys but not values while operator forms reject bare key/RHS tokens before lowering; direct access keeps a separate bare-segment guard and needs the scalar-index rule stated explicitly. No engine/book behavior changed. Frontier becomes `.1.2.3.3.1`. |
| `2026-06-29` | `SPEC-FORMAT-TERSE.1.2.3.3.1` | Perl syntax checks (`ValueExpr.pm`, `MethodLowering.pm`, `EmitContext.pm`, `phase0_regression.t`); TOOLBOX lowering probes; focused generated-source/runtime/no-leak probe; `prove -q -Iperl t/phase0_regression.t`; `mdbook build docs/linkedspec-book`; Knowledge Map/memory/doctrine/diff checks; full local CI | Perl scalar source-slot bare reads landed. `return(NAME)`, `set/assign(out, NAME)`, and `out = NAME` now lower to `$NAME` and auto-supply a per-invocation scalar lexical; primitive literals remain exact; deferred mutation/direct/child-call boundaries are locked. Phase0 PASS (`1..985`, 24 new assertions); mdBook updated. Frontier becomes `.1.2.3.3.2`. |
| `2026-06-29` | `SPEC-FORMAT-TERSE.1.2.3.3.2` | Perl syntax checks (`MethodLowering.pm`, `PrimitivePipelineRules.pm`, `EmitContext.pm`, `phase0_regression.t`); TOOLBOX lowering probes; `prove -q -Iperl t/phase0_regression.t`; `mdbook build docs/linkedspec-book`; Knowledge Map/memory/doctrine/diff checks; full local CI | Perl scalar mutation-slot bare reads landed. `items += VALUE`, `set_key(meta, KEY, VALUE)`, and `meta[KEY] = VALUE` now lower non-reserved bare key/RHS identifiers to `$KEY` / `$VALUE` and auto-supply per-invocation scalar lexicals, while target inference, literals, reserved engine locals, direct `[z]`, and all-bare `push(...)` child-call routing remain unchanged. Phase0 PASS (`1..986`, 29 new assertions); mdBook/KM/local CI PASS. Frontier becomes `.1.2.3.3.3`. |
| `2026-06-29` | `SPEC-FORMAT-TERSE.1.2.3.3.3` | Perl syntax checks (`ValueExpr.pm`, `EmitContext.pm`, `phase0_regression.t`); TOOLBOX lowering probes; `prove -q -Iperl t/phase0_regression.t`; `mdbook build docs/linkedspec-book`; Knowledge Map/memory/doctrine/diff checks; full local CI | Perl direct-access bare path atoms landed. `foo["a"][z]` now lowers like `foo["a"][scalar(z)]` to `$foo->{"a"}->[$z]` and auto-supplies a per-invocation scalar lexical for `z`; quoted path segments remain hash keys, numeric/helper segments remain array indexes, reserved atoms remain unclaimed, and `scalaref(...)` compatibility is unchanged. Phase0 PASS (`1..987`, 18 new assertions); mdBook/KM/memory/doctrine/local CI PASS. Frontier becomes `.1.2.3.4`. |
| `2026-06-29` | `SPEC-FORMAT-TERSE.1.2.3.4` | Focused Rust core parser tests (`parse_scalar_bare_reads_in_mutation_slots`, `parse_direct_nested_access_accepts_bare_segments`); focused Rust runtime `terse_1_2_3_4`; `perl -Iperl tools/gen_oracle_corpus.pl`; Rust corpus oracle; `mdbook build docs/linkedspec-book`; Knowledge Map/memory/doctrine/diff checks; full local CI | Rust scalar bare-read parity landed. The parser now accepts bare scalar variables in source slots, mutation key/RHS slots, and multi-segment direct-access path atoms; runtime behavior uses the existing `Expr::Variable` scalar read path. Added 2 integration locks + 3 oracle fixtures; corpus oracle PASS over 28 fixtures; mdBook/KM/memory/doctrine/local CI PASS. Frontier becomes `.1.2.3.5` for RHS-shape/type-inference split. |
| `2026-06-29` | `SPEC-FORMAT-TERSE.1.2.3.5` | Knowledge Map retrieval; TOOLBOX `call_spec_handler_subst` probes for empty and non-empty `[]`/`{}` forms; `LinkedSpec::Get` runtime/source dumps for scalar-vs-aggregate slot separation; Rust `expr.rs` code-read; Knowledge Map/memory/doctrine/diff checks | Split RHS-shape/type-inference into concrete children before code. Perl raw empty shapes work as scalar value expressions but do not initialize aggregate working variables; non-empty shapes currently need expression-aware lowering; Rust cannot parse bracket/brace value expressions. No engine/book behavior changed. Frontier becomes `.1.2.3.5.1`. |
| `2026-06-29` | `SPEC-FORMAT-TERSE.1.2.3.5.1` | Perl syntax checks (`MethodLowering.pm`, `EmitContext.pm`, `phase0_regression.t`); TOOLBOX lowering probes; generated-source/runtime shape-literal probe; `prove -q -Iperl t/phase0_regression.t`; `mdbook build docs/linkedspec-book`; Knowledge Map/memory/doctrine/diff checks | Perl shape-literal value expressions landed. `[]` / `{}` now lower as DSL values; direct shape elements, keys, and values compose with primitive literals, helper calls, direct access, nested shapes, and scalar bare reads. `{ key => value }` lowers to `{$key => $value}`, so fixed field names must be quoted. Target-kind inference was deferred to `.1.2.3.5.2`. Phase0 PASS (`988` tests); mdBook/KM/live docs updated. Frontier becomes `.1.2.3.5.2`. |
| `2026-06-29` | `SPEC-FORMAT-TERSE.1.2.3.5.2` | Perl syntax checks (`MethodLowering.pm`, `DeclareMethod.pm`, `EmitContext.pm`, `phase0_regression.t`); TOOLBOX lowering probes; generated-source/runtime array/hash/scalar-boundary probes; `prove -q -Iperl t/phase0_regression.t`; `mdbook build docs/linkedspec-book`; Knowledge Map/memory/doctrine/diff checks; full local CI | Perl RHS shape target-kind inference landed. Bare assignment targets now infer aggregate kind from direct RHS shapes: `name = [value]` / `set(name, [])` assign `@name`, and `name = { key => value }` / `assign(name, {})` assign `%name`; explicit `scalar(name)` keeps scalar payload assignment. Declaration initializer shapes now lower direct members before unwrapping. Phase0 PASS (`989` tests); full local CI PASS. Frontier becomes `.1.2.3.5.3`. |
| `2026-06-29` | `SPEC-FORMAT-TERSE.1.2.3.5.3` | Focused Rust core parser tests (`cargo test --quiet --manifest-path rust/Cargo.toml -p linkedspec-core shape_literal`); focused Rust runtime tests (`cargo test --quiet --manifest-path rust/Cargo.toml -p linkedspec-runtime terse_1_2_3_5_3`); `perl -Iperl tools/gen_oracle_corpus.pl`; Rust corpus oracle (`cargo test --quiet --manifest-path rust/Cargo.toml -p linkedspec-runtime oracle_corpus_matches_perl_reference`); mdBook build; Knowledge Map regenerate/check; memory/doctrine/diff checks; full local CI | Rust shape-literal value parity landed. `Expr::ArrayLiteral` / `Expr::HashLiteral` parse direct `[]` / `{}` values recursively, and `Engine::eval_expr` evaluates members through the normal expression path into `RuntimeValue::Array` / `RuntimeValue::Hash`. Added parser/runtime boundary locks plus two oracle fixtures, bringing the corpus oracle to 30 fixtures. `name = [value]` still parses/evaluates as scalar payload assignment until `.1.2.3.5.4` implements Rust target-kind inference. Frontier becomes `.1.2.3.5.4`. |
| `2026-06-29` | `SPEC-FORMAT-TERSE.1.2.3.5.4` | Focused Rust runtime tests (`cargo test --quiet --manifest-path rust/Cargo.toml -p linkedspec-runtime terse_1_2_3_5_4`); `perl -Iperl tools/gen_oracle_corpus.pl`; Rust corpus oracle (`cargo test --quiet --manifest-path rust/Cargo.toml -p linkedspec-runtime oracle_corpus_matches_perl_reference`); mdBook build; Knowledge Map regenerate/check; memory/doctrine/diff checks; full local CI | Rust RHS shape target-kind inference parity landed. Direct array/hash RHS literals now replace the runtime aggregate slot for bare or matching typed aggregate targets (`items = [value]`, `set(array(items), [value])`, `meta = { key => value }`, `set(hash(meta), { key => value })`), while explicit `scalar(payload)` keeps scalar-held shape payload assignment. Added 3 integration locks + 2 oracle fixtures, bringing the corpus oracle to 32 fixtures. Frontier becomes `.1.6`. |
| `2026-06-29` | `SPEC-FORMAT-TERSE.1.6` | Perl syntax checks (`MethodLowering.pm`, `Contracts.pm`, `Scanner/PrimitivePipelineRules.pm`, `RuleIR/EmitContext.pm`); TOOLBOX lowering/runtime/source probes; focused Rust core parser test (`parse_array_end_mutation_fluent_receivers`); focused Rust runtime tests (`cargo test --quiet --manifest-path rust/Cargo.toml -p linkedspec-runtime terse_1_6`); `perl -Iperl tools/gen_oracle_corpus.pl`; Rust corpus oracle (`cargo test --quiet --manifest-path rust/Cargo.toml -p linkedspec-runtime oracle_corpus_matches_perl_reference`); `prove -q -Iperl t/phase0_regression.t` | Array end-mutation methods landed. Perl lowers statement-level `push_back`/`push_front`/`pop_back`/`pop_front` receiver-dot calls to array working-variable mutations, records canonical `ARRAY_MUTATE`, and auto-supplies the receiver array plus push-value scalar reads. Rust executes the same statement forms in `Engine::execute_block`; pop methods discard the removed value. Oracle corpus regenerated to 33 fixtures; phase0 PASS (`990` tests). Round 1 is closed and the frontier becomes `.2.1`. |
| `2026-06-29` | `SPEC-FORMAT-TERSE.2.1.1` (split) | KM retrieval (`spec-format-brainstorm-rounds-1-3`, `terse-statement-separator-contract`, `terse-array-end-mutation-methods`, `rust-retv-propagation`, `actionir-lowering-stack`); TOOLBOX `call_spec_handler_subst` probes for `{}` / `{ key => value }` / block-shaped values; `LinkedSpec::Get` runtime and generated-source probes; Perl code-read (`MethodLowering`, `EmitContext`); Rust code-read (`expr.rs`, `engine.rs`); Knowledge Map regenerate/check; memory/doctrine/diff checks | Split `.2.1` before code. Current Perl supports hash shape literals but block-shaped values lower into invalid hash/block Perl (`return { $x = "a"; x }`) or aggregate target inference (`%out = (...)`); Rust has statement `CodeBlock` and hash/array literal values but no block-expression AST/runtime. Frontier becomes `.2.1.2` for the Perl reference core; Rust parity and full block-local early return stay split. |
| `2026-06-29` | `SPEC-FORMAT-TERSE.2.1.2` | Perl syntax checks (`MethodLowering.pm`, `RuleIR/EmitContext.pm`, `phase0_regression.t`); TOOLBOX lowering/runtime probes; `prove -q -Iperl t/phase0_regression.t`; mdBook build; Knowledge Map regenerate/check; memory/doctrine/diff checks; `tools/run_ci_local.sh` | Perl-reference core expression-valued blocks landed. Non-empty non-hash brace payloads lower as `do { ... }` values in return payloads, assignment sources, and nested value payloads; final `return(expr)` inside the block is block-local for this core subset. `{}` and `{ key => value }` remain hash literals, and hash literal final expressions are forced as scalar hashrefs inside block values. Phase0 PASS (`991` tests). Full local CI PASS. Frontier becomes `.2.1.3` Rust parity. |
| `2026-06-29` | `SPEC-FORMAT-TERSE.2.1.3` (ownership) | KM retrieval (`terse-expression-valued-blocks-ground-truth`, `terse-perl-expression-valued-blocks`); Rust code-read (`Expr`, `parse_expr()`, `parse_hash_literal()`, `execute_block()`, `eval_expr()`); mdBook build; Knowledge Map regenerate/check; memory/doctrine/diff checks | Rust expression-valued block parity owned before code. Rust currently has statement-only `CodeBlock`, hash/array value expressions, and no block-value `Expr` or evaluator. `{}` and keyed `=>` hash literals must keep precedence; non-empty non-fat-arrow braces become block values in the implementation slice. Frontier remains `.2.1.3` implementation. |
| `2026-06-29` | `SPEC-FORMAT-TERSE.2.1.3` | Focused Rust core parser tests (`cargo test --quiet --manifest-path rust/Cargo.toml -p linkedspec-core expression_valued_block`); focused Rust runtime tests (`cargo test --quiet --manifest-path rust/Cargo.toml -p linkedspec-runtime terse_2_1_3`); `perl -Iperl tools/gen_oracle_corpus.pl`; Rust corpus oracle (`cargo test --quiet --manifest-path rust/Cargo.toml -p linkedspec-runtime oracle_corpus_matches_perl_reference`); full Rust core package; full Rust runtime package; `mdbook build docs/linkedspec-book`; Knowledge Map regenerate/check; memory/doctrine/diff checks; `bash tools/run_ci_local.sh` | Rust expression-valued block parity landed. `Expr::BlockValue` plus `parse_brace_expr()` preserve hash literals and parse non-empty non-fat-arrow braces as block values; runtime `eval_block_value()` returns the final expression or final `return(expr)` payload. Added `terse_2_1_3_expression_valued_blocks`, bringing the oracle corpus to **34 fixtures**. Full local CI PASS (`991` phase0 tests). Frontier becomes `.2.1.4`. |
| `2026-06-30` | `SPEC-FORMAT-TERSE.2.1.4` | Perl syntax checks (`MethodLowering.pm`, phase0, oracle generator); TOOLBOX lowering/runtime probes for non-final `return(expr)` block values; focused Rust runtime tests (`cargo test --quiet --manifest-path rust/Cargo.toml -p linkedspec-runtime terse_2_1_4_expression_valued_block`); `perl -Iperl tools/gen_oracle_corpus.pl`; Rust corpus oracle; phase0; mdBook build; Knowledge Map regenerate/check; memory/doctrine/diff checks; full local CI | Block-local early `return(expr)` landed for expression-valued blocks on Perl and Rust. Perl emits a guarded `do { ... }` value wrapper for blocks with a non-final return and keeps compact output for existing core forms. Rust `eval_block_value()` now returns an active `return(expr)` payload immediately without setting the rule return channel. Added `terse_2_1_4_expression_valued_block_early_return`, bringing the oracle corpus to **35 fixtures**. Frontier becomes `.2.2`. |
| `2026-06-30` | `SPEC-FORMAT-TERSE.2.2.1` (split) | KM retrieval (`spec-format-brainstorm-rounds-1-3`, `terse-statement-separator-contract`, `terse-primitive-literal-parity`, `scanner-rule-family-architecture`); TOOLBOX `call_spec_handler_subst` probes for attached `if`, `when`/`otherwise`, `while`, and attached `switch`; `LinkedSpec::Get(..., return_descriptor => 1)` metadata probes for ActionIR readiness/raw fallback; Perl code-read (`ControlFlow.pm`, `FlowExpr.pm`, `Scanner/FlowRules.pm`); Rust code-read (`expr.rs`, `engine.rs`); focused Rust parser test `parse_lifecycle_block_content` | Split `.2.2` before code. At split time, the contract was believed to be statement-marker `if(cond); ... elseif(cond); else(); ... endif()` plus inline-composite lazy `if`/`switch`; `.2.3.4` later corrected the inline value-control portability boundary and split Perl value lowering to `.2.3.4.2`. Perl attached `if`, `when`/`otherwise`, and `while` were not ActionIR-ready; Rust had no attached statement-block parser/runtime for the new keyword surface. mdBook/KM/live docs aligned; frontier became `.2.2.2`. |
| `2026-06-30` | `SPEC-FORMAT-TERSE.2.2.2` | Perl syntax checks; TOOLBOX compact attached-if lowering/metadata/runtime probes; phase0 (`prove -q -Iperl t/phase0_regression.t`); mdBook build; Knowledge Map regenerate/check; memory/doctrine/diff checks; full local CI | Perl attached-block `if/elseif/else` landed. `StatementSplit::Core` splits compact same-line `} elseif/else {` branch continuations so the existing ActionIR control-flow lowering can emit the selected branch without raw fallback. Frontier becomes `.2.2.3` Rust parity. |
| `2026-06-30` | `SPEC-FORMAT-TERSE.2.2.3` | Focused Rust core parser tests (`cargo test --quiet --manifest-path rust/Cargo.toml -p linkedspec-core attached_if`); focused Rust runtime tests (`cargo test --quiet --manifest-path rust/Cargo.toml -p linkedspec-runtime terse_2_2_3`); `perl tools/gen_oracle_corpus.pl`; Rust corpus oracle; mdBook build; Knowledge Map regenerate/check; memory/doctrine/diff checks | Rust attached-block `if/elseif/else` parity landed. `CodeBlock::parse` normalizes attached branch bodies into the existing marker-control sequence and reuses `handle_statement_if_control` at runtime. Added oracle fixture `terse_2_2_3_attached_if_blocks`, bringing the corpus to **36 fixtures**. Attached `if` is now portable on Perl and Rust; frontier becomes `.2.2.4` for `when/otherwise`. |
| `2026-06-30` | `SPEC-FORMAT-TERSE.2.2.4` (ownership) | KM retrieval (`terse-control-flow-keyword-surface-ground-truth`, `spec-format-brainstorm-rounds-1-3`); TOOLBOX lowering/descriptor/runtime/generated-source probes for `when/otherwise`; Perl flow code-read (`StatementSplit::Core`, `Scanner::FlowRules`, `Contracts`, `ControlFlow`); Rust code-read (`expr.rs`, `engine.rs`) | Owned `when/otherwise` before code. Current Perl leaves the combined form raw, warns via host experimental `when`, and returns the wrong branch for the true-condition probe. Implementation should normalize `when(cond)` to attached `if(cond)` and `otherwise` to attached `else`, reusing existing Perl control-flow lowering and Rust marker-gating runtime. Frontier remains `.2.2.4` implementation. |
| `2026-06-30` | `SPEC-FORMAT-TERSE.2.2.4` | Perl syntax checks; TOOLBOX lowering/descriptor/runtime/generated-source probe; focused Rust core parser test (`cargo test --quiet --manifest-path rust/Cargo.toml -p linkedspec-core when_otherwise`); focused Rust runtime test (`cargo test --quiet --manifest-path rust/Cargo.toml -p linkedspec-runtime terse_2_2_4`); `perl -Iperl tools/gen_oracle_corpus.pl`; Rust corpus oracle; `prove -q -Iperl t/phase0_regression.t`; mdBook build; Knowledge Map/memory/doctrine/diff checks; full local CI | `when/otherwise` aliases landed. Perl recognizes the aliases in statement splitting, scanner/contract matching, and `ControlFlow` lowering, while avoiding host Perl `when`. Rust parser normalizes attached `when` / `otherwise` branches to existing `if` / `else` / `endif` statements and reuses the runtime branch engine. Oracle corpus now has **37 fixtures**. Phase0 PASS (`Files=1, Tests=991`); full local CI PASS. Frontier becomes `.2.2.5`. |
| `2026-06-30` | `SPEC-FORMAT-TERSE.2.2.5` (split/ownership) | KM retrieval (`terse-control-flow-keyword-surface-ground-truth`, `terse-statement-separator-contract`, `spec-format-brainstorm-rounds-1-3`); TOOLBOX descriptor/lowering/runtime probes for attached `switch/case/default`; Perl code-read (`ControlFlow.pm`, `StatementSplit::Core`); Rust code-read (`expr.rs`, `engine.rs`); focused Rust value-form switch tests | Split and owned attached `switch/case/default` before code. Perl has partial attached-switch machinery, but adjacent branch blocks without explicit separators can leave unresolved `case` residue or host-like `default` labels in generated source. Rust has lazy value-form `switch` runtime support but no attached `switch/case/default` statement parser. Frontier becomes `.2.2.5.1` for the Perl separator/source lock, then `.2.2.5.2` Rust parity. |
| `2026-06-30` | `SPEC-FORMAT-TERSE.2.2.5.1` | Perl syntax checks; TOOLBOX descriptor/lowering/runtime/generated-source probes for compact attached switch; `prove -q -Iperl t/phase0_regression.t`; mdBook build; Knowledge Map regenerate/check; memory/doctrine/diff checks; full local CI | Perl attached `switch/case/default` separator/source lock landed. `StatementSplit::Core` now splits adjacent attached `case/default` branches so descriptor metadata reports `ready=1 raw=0 unresolved=0`, generated handlers have no host-shaped branch residue, runtime selects first/later/default branches correctly, and a same-line statement after the final switch still requires `;`. Phase0 PASS (`Files=1, Tests=991`); full local CI PASS. Frontier becomes `.2.2.5.2` Rust parity. |
| `2026-06-30` | `SPEC-FORMAT-TERSE.2.2.5.2` | Perl syntax checks; phase0 (`prove -q -Iperl t/phase0_regression.t`); focused Rust core parser tests (`cargo test -p linkedspec-core attached_switch -- --nocapture` from `rust/`); focused Rust runtime tests (`cargo test -p linkedspec-runtime terse_2_2_5_2 -- --nocapture` from `rust/`); lazy value-form switch regression (`cargo test -p linkedspec-runtime cond_switch -- --nocapture` from `rust/`); `perl -Iperl tools/gen_oracle_corpus.pl`; Rust corpus oracle; mdBook build; Knowledge Map regenerate/check; memory/doctrine/diff checks; full local CI | Rust attached `switch/case/default` parity landed. `CodeBlock::parse` normalizes attached switch branch bodies to statement controls, `Engine` gates them with a switch stack beside statement-if gating, inactive branch side effects are skipped, lazy value-form switch remains intact, and the oracle corpus now has **38 fixtures**. Phase0 PASS (`Files=1, Tests=991`); full local CI PASS. Frontier becomes `.2.2.6` (`while`). |
| `2026-06-30` | `SPEC-FORMAT-TERSE.2.2.6` (split/ownership) | KM retrieval (`terse-control-flow-keyword-surface-ground-truth`, `spec-format-brainstorm-rounds-1-3`, `top-rule-recursion-forward-progress-guard`); TOOLBOX lowering/descriptor probes for `while(false) { ... }` and `while(true) { ... }`; Perl code-read (`ControlFlow.pm`, `Contracts.pm`, `Scanner/FlowRules.pm`, `StatementSplit::Core`); Rust code-read (`expr.rs`, `engine.rs`) | Split and owned attached `while(cond) { ... }` before code. Perl currently lowers the attached form as raw host code (`ready=0 raw=1 fallback=1 unresolved=0`), while Rust has no attached statement-loop parser/runtime. Frontier becomes `.2.2.6.1` for the Perl reference loop/safety contract; `.2.2.6.2` will provide Rust parity. |
| `2026-06-30` | `SPEC-FORMAT-TERSE.2.2.6.1` | Perl syntax checks; TOOLBOX lowering/descriptor/runtime/generated-source probes; `prove -q -Iperl t/phase0_regression.t`; mdBook build; Knowledge Map regenerate/check; memory/doctrine/diff checks; full local CI | Perl attached `while(cond) { ... }` loop/safety landed. `ControlFlow` lowers attached while through ActionIR as a guarded host loop, scanner/contract/canonical metadata report `WHILE`, counted loops re-evaluate conditions, `return(expr)` keeps rule/action return semantics, and non-terminating loops hit the deterministic 10000-iteration guard. Phase0 PASS (`Files=1, Tests=992`); full local CI PASS. Frontier becomes `.2.2.6.2` Rust parity. |
| `2026-06-30` | `SPEC-FORMAT-TERSE.2.2.6.2` | Focused Rust core parser tests (`cargo test --quiet --manifest-path rust/linkedspec-core/Cargo.toml attached_while`); focused Rust runtime tests (`cargo test --quiet --manifest-path rust/linkedspec-runtime/Cargo.toml terse_2_2_6_2`); full Rust core/runtime package tests; oracle generator syntax/regeneration; Rust corpus oracle; mdBook build; Knowledge Map regenerate/check; memory/doctrine/diff checks; full local CI | Rust attached `while(cond) { ... }` parity landed. `expr.rs` parses attached while as a lazy loop over a parsed body block, `engine.rs` re-evaluates conditions and executes bodies with normal statement semantics, expression-valued blocks keep block-local `return(expr)`, and non-terminating loops use the same 10000-iteration safety diagnostic as Perl. Added oracle fixture `terse_2_2_6_2_attached_while_blocks`, bringing the corpus to **39 fixtures**. Frontier becomes `.2.3`. |
| `2026-06-30` | `SPEC-FORMAT-TERSE.2.3` (split/ownership) | KM retrieval (`spec-format-brainstorm-rounds-1-3`, `terse-control-flow-keyword-surface-ground-truth`, `method-like-dsl-migration-status`, `terse-array-end-mutation-methods`, `rust-perl-output-oracle`); TOOLBOX descriptor/runtime probes for exact action and lifecycle `.when(cond) { ... }.otherwise { ... }`; lifecycle block value/return probes; nested-helper and receiver-dot value-method probes; Perl code-read (`BootstrapSpec::Core`, `ActionIR::ControlFlow`); Rust code-read (`expr.rs`, `parser.rs`, `compiler.rs`, `engine.rs`) | Split and owned `.2.3` before code. Perl already accepts exact fluent block-chain forms on action and lifecycle surfaces with `ready=1 raw=0 fallback=0 unresolved=0`; Rust attached statement blocks are portable, but fluent attached-block payloads/action-edge continuations are not. Lifecycle blocks need a separate value-drop/return-channel lock. Full composability and return-type method chaining are separate surfaces; array end mutations remain statement-only. Frontier becomes `.2.3.1`. |
| `2026-06-30` | `SPEC-FORMAT-TERSE.2.3.1` | TOOLBOX false-branch reverify for dotted and no-dot fluent `otherwise`; Perl syntax checks (`perl -c perl/LinkedSpec/BootstrapSpec/Core.pm`, `perl -c t/phase0_regression.t`); phase0 (`prove -q -Iperl t/phase0_regression.t`); mdBook build; Knowledge Map regenerate/check; memory/doctrine/diff checks | Perl reference fluent `when/otherwise` block chains landed. The bootstrap parser now preserves attached fallback tails after `.when(...) { ... }`, with or without the dot before `otherwise`. New phase0 locks prove action-edge and lifecycle false-branch fallback execution, descriptor cleanliness (`ready=1 fallback=0 raw=0 unresolved=0`), and no generated host `when`/`otherwise` residue. Phase0 PASS (`Files=1, Tests=993`). Frontier becomes `.2.3.2`. |
| `2026-06-30` | `SPEC-FORMAT-TERSE.2.3.2` | Perl syntax check (`perl -c t/phase0_regression.t`); phase0 (`prove -q -Iperl t/phase0_regression.t`); focused Rust runtime (`cargo test --quiet --manifest-path rust/linkedspec-runtime/Cargo.toml terse_2_3_2`); mdBook build; Knowledge Map regenerate/check; memory/doctrine/diff checks; full local CI | Lifecycle block value/drop semantics are locked. Phase0 source-locks all seven lifecycle markers and runtime-locks final ordinary statement discard, top-level Perl lifecycle return-channel behavior, and expression-valued block-local return contrast. Rust focused tests lock statement-value discard, top-level lifecycle return-event recording, and expression-block local return. Phase0 PASS (`Files=1, Tests=994`); full local CI PASS. Frontier becomes `.2.3.3`. |
| `2026-06-30` | `SPEC-FORMAT-TERSE.2.3.3.1` | Focused Rust core (`cargo test --quiet --manifest-path rust/linkedspec-core/Cargo.toml fluent_chain`); focused Rust runtime (`cargo test --quiet --manifest-path rust/linkedspec-runtime/Cargo.toml terse_2_3_3_1 -- --nocapture`); full Rust core/runtime package tests; `perl -c tools/gen_oracle_corpus.pl`; mdBook build; Knowledge Map regenerate/check; memory/doctrine/diff checks; full local CI | Rust action-edge fluent continuations landed. `ActionEdge` / `AcodeEntry` now carry fluent-chain metadata and runtime dispatch executes no-arg `.push`, `.return(expr)`, and `.return_undef` with parent-visible return-channel semantics. Focused locks cover child return capture, child return-event suppression, close-edge return without recursive child redispatch, and `.return_undef` without an accumulator event. Full local CI PASS (`Files=1, Tests=994`). `tclite` oracle remains deferred behind compact lifecycle/body fluent forms and default-mode repetition parity. Frontier becomes `.2.3.3.2`. |
| `2026-06-30` | `SPEC-FORMAT-TERSE.2.3.3.2` | Focused Rust core (`cargo test --quiet --manifest-path rust/linkedspec-core/Cargo.toml attached_fluent -- --nocapture`); focused Rust runtime (`cargo test --quiet --manifest-path rust/linkedspec-runtime/Cargo.toml terse_2_3_3_2 -- --nocapture`); full Rust core/runtime package tests; mdBook build; Knowledge Map regenerate/check; memory/doctrine/diff checks; full local CI | Rust attached fluent block payloads landed. The Rust body parser now normalizes action-edge and lifecycle `.when(cond) { ... }` receiver-fluent block chains to existing attached statement blocks, accepts dotted and no-dot `otherwise` fallback tails, and preserves multiline fallback payloads after `}.otherwise {`. Focused runtime locks cover both fallback spellings on both action-edge and lifecycle surfaces. Full local CI PASS (`Files=1, Tests=994`). Frontier becomes `.2.3.3.3`. |
| `2026-06-30` | `SPEC-FORMAT-TERSE.2.3.3.3` | KM retrieval; Perl reference probes for compact lifecycle and action-edge fluent forms; shipped-spec/code search (`I.return`, `I.declare(...).return(...)`, action-edge `.push(...)`); Rust parser/compiler/runtime code-read; focused Rust `.2.3.3.2` regression test | Split remaining Rust fluent continuation work before code. Lifecycle/body receiver chains are dropped through standalone `BodyElementKind::FluentChain`; action-edge metadata exists but only no-arg `.push` / `.return(expr)` / `.return_undef` execute; `tclite` re-enable waits until those fluent children land and then gets its own default-mode repetition audit if still divergent. Frontier becomes `.2.3.3.3.1`. |
| `2026-06-30` | `SPEC-FORMAT-TERSE.2.3.3.3.1` | Focused Rust core (`cargo test --quiet --manifest-path rust/linkedspec-core/Cargo.toml lifecycle_compact -- --nocapture`); focused Rust runtime (`cargo test --quiet --manifest-path rust/linkedspec-runtime/Cargo.toml terse_2_3_3_3_1 -- --nocapture`); full Rust core/runtime package tests; mdBook build; oracle generator syntax; Knowledge Map regenerate/check; memory/doctrine/diff checks; full local CI; rustfmt on touched Rust files | Rust compact lifecycle/body receiver chains landed. The Rust parser now normalizes lifecycle-marker receiver chains such as `I.return(...)` and `I.declare(...).set(...).return(...)` into lifecycle `CodeBlock` statement strings instead of leaving a dropped standalone `FluentChain`. Parser locks cover multiline body and regex-first header-line inline placement with no surviving lifecycle-surface `FluentChain`; compiler locks prove compact `I`/`E` chains populate lifecycle code slots; runtime locks prove return-channel behavior and ordered declaration/mutation execution. Full local CI PASS. Frontier becomes `.2.3.3.3.2`. |
| `2026-06-30` | `SPEC-FORMAT-TERSE.2.3.3.3.2` | Perl reference probes for shipped `ebnf.spec` action-edge fluent forms; focused Rust core parser (`cargo test --quiet --manifest-path rust/linkedspec-core/Cargo.toml parse_action_edge_multiline_fluent_flow_chain -- --nocapture`) and compiler (`cargo test --quiet --manifest-path rust/linkedspec-core/Cargo.toml compile_multiline_action_edge_fluent_flow_chain -- --nocapture`); focused Rust runtime (`cargo test --quiet --manifest-path rust/linkedspec-runtime/Cargo.toml terse_2_3_3_3_2 -- --nocapture`); no-arg action-edge regression (`cargo test --quiet --manifest-path rust/linkedspec-runtime/Cargo.toml terse_2_3_3_1_action_edge_fluent_push_appends_child_return -- --nocapture`); full Rust core/runtime package tests; mdBook build; oracle generator syntax; Knowledge Map regenerate/check; memory/doctrine/diff checks; full local CI | Rust action-edge explicit/flow fluent chains landed. The Rust parser now keeps multiline dotted action-edge continuations on the preceding edge; the runtime executes `.push(target)`, `.push(child,target)`, `.if/.else/.endif` gating, `.say(...)`, `.return(expr)`, and `.return_undef()` with parent-visible child return-channel semantics. Full local CI PASS. Frontier becomes `.2.3.3.3.3`. |
| `2026-06-30` | `SPEC-FORMAT-TERSE.2.3.3.3.3` | Perl reference probes for `tclite` inputs `[]` and `""`; temporary `tools/gen_oracle_corpus.pl` re-enable of `tclite_command_subst` and `tclite_double_quote`; diagnostic Rust corpus oracle run (`cargo test --quiet --manifest-path rust/linkedspec-runtime/Cargo.toml --test corpus_oracle -- --nocapture`); committed green-corpus restoration; oracle generator syntax/regeneration; Rust corpus oracle; mdBook build; Knowledge Map regenerate/check; memory/doctrine/diff checks; full local CI | Rust `tclite` retry after fluent parity split to implementation. Perl returns tagged `tcl_script` values for both inputs, but Rust still returns `[]` for the two temporarily re-enabled fixtures while the other 39 fixtures pass. The remaining blocker is default-mode recursive repetition/top-level default-rule dispatch parity, not fluent-continuation support. Failing fixtures stay out of the committed corpus until `.2.3.3.3.3.1`; frontier becomes `.2.3.3.3.3.1`. |
| `2026-06-30` | `SPEC-FORMAT-TERSE.2.3.3.3.3.1` | KM/toolbox probes for Perl `tclite` and minimal edge-only grammars; focused Rust core (`cargo test --quiet --manifest-path rust/linkedspec-core/Cargo.toml compile_default_mode_is_zero_min_repeated_choice -- --nocapture`); focused Rust runtime (`cargo test --quiet --manifest-path rust/linkedspec-runtime/Cargo.toml default_mode_repeats_action_edge_choices_and_allows_zero_matches -- --nocapture`); lifecycle expectation locks (`terse_2_3_2_lifecycle_return_records_surrounding_rule_return`, `terse_2_3_3_3_1`); capture-helper regression families (`helpers_5_5_3`, `helpers_5_5_4`); `perl -c tools/gen_oracle_corpus.pl`; `perl -Iperl tools/gen_oracle_corpus.pl`; Rust corpus oracle; mdBook build; Knowledge Map regenerate/check; memory/doctrine/diff checks; full local CI | Rust default-mode recursive repetition parity landed. `RuleMode::Default` now compiles as zero-min repeated choice, and Rust exits immediately after an `I`/preamble return before local entry-regex re-matching. One-match capture-helper/lifecycle-order tests now spell `OR{1,1}` explicitly; `tclite_command_subst` and `tclite_double_quote` are active oracle fixtures; corpus oracle PASS over 41 fixtures. Frontier becomes `.2.3.4`. |
| `2026-06-30` | `SPEC-FORMAT-TERSE.2.3.4` | KM retrieval; TOOLBOX lowering/runtime/generated-source probes for deep pure helpers, bare aggregate helper arguments, inline value `if`/`switch`, and receiver-dot method value/chaining; Rust parser/runtime code-read; diagnostic Rust corpus oracle with bare `merge_hash(..., overlay)`; final `perl -Iperl tools/gen_oracle_corpus.pl`; final Rust corpus oracle (`cargo test --quiet --manifest-path rust/linkedspec-runtime/Cargo.toml --test corpus_oracle -- --nocapture`) | Full composability audit split unsupported surfaces before code. Pure helper nesting is portable with explicit aggregate wrappers and is now locked by `terse_2_3_4_deep_pure_helper_composition`; final corpus oracle PASS over 42 fixtures. Diagnostic bare `overlay` in `merge_hash(hash_copy(base), overlay)` returned Perl `2` but Rust `1`, so `.2.3.4.1` owns Rust helper-context aggregate bare reads. Perl generated-source probes for inline value `if`/`switch` show selected branch values are not returned and nested helper forms can fail handler compilation, so `.2.3.4.2` owns that reference fix. Frontier becomes `.2.3.4.1`. |
| `2026-06-30` | `SPEC-FORMAT-TERSE.2.3.4.1` | Focused Rust runtime (`cargo test --quiet --manifest-path rust/linkedspec-runtime/Cargo.toml terse_2_3_4_1 -- --nocapture`); oracle generator (`perl -Iperl tools/gen_oracle_corpus.pl`); Rust corpus oracle (`cargo test --quiet --manifest-path rust/linkedspec-runtime/Cargo.toml --test corpus_oracle -- --nocapture`) | Rust helper-context bare aggregate arguments landed. `hash_consuming_arg(...)` and `array_consuming_arg(...)` promote bare names to aggregate snapshots only in helper slots whose callee contract implies that aggregate kind; `merge_hash(hash_copy(base), overlay)` now matches the explicit `hash(overlay)` wrapper, and `count(drop_front(sorted(items)))` matches the Perl oracle. Added `terse_2_3_4_1_bare_hash_helper_arg_composition` and `terse_2_3_4_1_bare_array_helper_arg_composition`; corpus oracle PASS over 44 fixtures. Frontier becomes `.2.3.4.2`. |
| `2026-06-30` | `SPEC-FORMAT-TERSE.2.3.4.2` | Perl syntax checks for changed ActionIR modules and oracle generator; focused Perl lowering/runtime probes for inline `if`/`switch` return, assignment RHS, nested predicates, expression-valued block branches, and fluent `.return(...)`; phase0 (`prove -q -Iperl t/phase0_regression.t`); oracle generator (`perl -Iperl tools/gen_oracle_corpus.pl`); Rust corpus oracle (`cargo test --quiet --manifest-path rust/linkedspec-runtime/Cargo.toml --test corpus_oracle -- --nocapture`) | Perl inline value-control lowering landed. `if(...)` and `switch(...)` now return selected branch payloads in supported value positions; inline branch payloads compose with helpers and expression-valued blocks; fluent checks assert payload values without requiring a specific compatibility tag string. Added `terse_2_3_4_2_inline_if_value_control` and `terse_2_3_4_2_inline_switch_value_control`; phase0 PASS with 995 tests and corpus oracle PASS over 46 fixtures. Frontier becomes `.2.3.5`. |

## Commit Log

Canonical task-node Commit fields retain every consolidated table label, reference and note. Exact source and
Git comparison are owned by `LIVE-DOCUMENT-PRESSURE-CONTAINMENT.6`; no acceptance or verification field changes.
The following historical captions remain in table form because the strict consolidation match did not resolve them.

| Leaf | Commit subject or reference | Notes |
| --- | --- | --- |
| `SPEC-FORMAT-TERSE` (creation) | (in the `SPEC-FORMAT-TERSE.0` activation commit) | Tree was created `proposed` in an earlier session; first commit lands with `.0`. |
| `SPEC-FORMAT-TERSE.1.1.2` | `SPEC-FORMAT-TERSE.1.1.2 — Rust lockstep parity for auto-existing variables (oracle + integration locks; no engine change)` | Assessed DOABLE: Rust interpreter's per-parse `RuntimeContext` HashMaps already auto-vivify working vars (no `declare` needed) and are fresh per `execute` (no leak) — no Perl-style leaky-global hazard, so no engine code change. Locked with 5 `autoexist_*` oracle fixtures (`tools/gen_oracle_corpus.pl`) + 4 `terse_1_1_2_*` integration tests; cargo 244→248 green, 7/7 oracle fixtures PASS, clippy zero-new, phase0 968 green (Perl untouched), gate EXIT 0. `.1.1` container done. Recursive/REP idiom deferred to `RUST-PARITY`. KM card [[rust-working-vars-auto-vivify]]. |
| `SPEC-FORMAT-TERSE.1.4.2` | `SPEC-FORMAT-TERSE.1.4.2 — Rust recognize terse helper renames (engine + oracle + integration locks)` | Rust `Engine::call_helper()` now treats `set` as `assign`, `cat` as `concat`, and `copy` as unified array/hash copy; `hash`/`h` one-bare-variable references align `copy(h(m))` with `hash_copy(h(m))`. 2 oracle fixtures + 3 integration locks; cargo suite green; clippy zero-new; phase0 975 untouched; full gate EXIT 0; no book change. `.1.4` container done; next frontier `.1.3`. |
| `SPEC-FORMAT-TERSE.1.5.1` (split) | `SPEC-FORMAT-TERSE.1.5 — split literals/access/call/separator surface` | `.1.5` is now an active container. `.1.5.1` closed the audit/split: primitive literal parity, call-spacing locks, separator semantics, and direct nested access are separate leaves. KM [[terse-literals-calls-separators-access-ground-truth]]. DOCS/TREE/KM only — no engine/book behavior change. |

## Changelog

- `2026-07-06`: **`.8.1` DONE/SPLIT - legacy helper retirement inventory.**
  `.8` is now split before behavior changes. Current probes/code reads show which compatibility helper spellings
  still succeed on Perl/Rust and which are already retired/diagnostic. The active implementation frontier is
  `.8.2`, which owns current-source/test/corpus/doc migration and the `push_nonempty(...)` replacement decision
  before hard-retiring Perl and Rust helper support.

- `2026-07-06`: **`.15.5` DONE - colon scalar-slot no-drift closeout.**
  Current shipped specs, generated corpus inputs, mdBook guidance, active tests, and non-historical Knowledge Map
  facts no longer depend on successful `:name` scalar-slot syntax. Stale scans leave only retired-diagnostic
  code/tests, rule-mode/regex/public-API colon syntax, or historical records. Two stale Knowledge fact-card
  references were corrected to the current bare-read surface. `.15` closes; frontier moves to `.8` for legacy
  helper-removal, with `.9` still pending behind it.

- `2026-07-05`: **`.15.2` RE-SCOPED engine-first + recovery.** A prior session left the working tree dirty with
  uncommitted, intermingled `.15.2/.15.3/.15.4/.8/.9` work (phase0 RED); it is preserved on branch
  `recovery/terse-15-uncommitted-20260705` and `main` is reset clean to `104088e5`. Attempting the source-first
  `.15.2` migration proved it is NOT output-preserving at `104088e5`: bare identifiers are not read as bound
  variable values in `switch(...)`, numeric callees, `if(...)` conditions, or all-bare `push(A,B)` second args,
  and collide with rule names in `spec.spec`/`ebnf.spec` (direct probe: `switch(:kind)`->`'good'` vs
  `switch(kind)`->`'def'`). Per the user directive that `:name` shall NOT be supported, `.15` is re-sequenced
  ENGINE-FIRST: `.15.2.1` design, `.15.2.2` Perl bare-read completion, `.15.2.3` Rust parity, `.15.2.4` source
  migration; then `.15.3`/`.15.4` remove `:name` entirely (no compat), then `.15.5` closes drift. See ADR `0019`
  and KM card `terse-bare-read-value-position-gap`. Frontier moves to `.15.2.1`.
- `2026-07-05`: **`.11.5` DONE — duck-typed assignment alignment closed.**
  Current roadmap and Knowledge Map retrieval now describe direct RHS shapes as typed value binding. Historical
  target-kind inference remains documented only as superseded history. The mdBook already matched `.11`; oracle
  corpus remains **92** fixtures. Frontier moves to `.15`.

- `2026-07-05`: **`.11.4` DONE — nested mixed value-path assignment landed.**
  Perl and Rust now support direct-access lvalues such as `payload["items"][0]["name"] = value` in statement and
  value contexts. Intermediate containers must already exist with the required shape; final hash keys may be
  created/replaced; final array indexes may replace existing elements or append exactly at len. Missing
  intermediates, wrong-shape transitions, and array gaps return `undef`/`null` and leave the root unchanged.
  Single-segment scalar-held array/hash roots also mutate consistently before falling back to named hash storage.
  Oracle corpus moves to **92** fixtures. Frontier moves to `.11.5`.

- `2026-07-05`: **`.11.3` DONE — Rust duck-typed assignment parity landed.**
  Rust now matches the Perl `.11.2` value-binding contract. Bare `name = value`, `set(name, value)`, and
  `=(name, value)` bind scalar, array, or hash RHS values as the variable's current typed value; direct RHS shape
  no longer retags bare targets into array/hash aggregate storage. Explicit `array(...)` / `hash(...)` targets
  remain aggregate storage, and scalar-held typed snapshots feed `array(name)`, `hash(name)`, `copy(...)`,
  aggregate-consuming helper slots, and compatible receiver chains. The same leaf closed the Perl reference
  fallback order for scalar-held `copy(name)` and bare array receiver chains after the oracle exposed the mismatch.
  Frontier moves to `.11.4`.

- `2026-07-05`: **`.15` OWNED — remove colon scalar references from duck-typed surface.**
  User directive logs the removal of `:name` scalar variable references now that variables are duck-typed runtime
  values. Future current-facing syntax reads variables/parameters as bare names in value positions, while bare
  hash-literal keys remain stringified key tokens in key position.

- `2026-07-05`: **`.14` DEFERRED/SPEC BACKLOG — trailing block arguments without closures.**
  User directive tracked the generalization from hash-tree attached blocks to a block-argument type accepted only as
  the final argument to helpers and receiver methods. The preferred future spelling is trailing-block syntax such
  as `fn(args) { ... }`, with zero-arg `fn { ... }` possible if grammar-safe. This leaf explicitly does not adopt
  closures, assignable blocks, returnable blocks, or implicit caller-state capture.
- `2026-07-07`: **`.14.1` DONE — trailing block arguments reactivated and split before code.**
  User directive picked the non-closed task tree that talks about trailing code blocks, confirming
  `SPEC-FORMAT-TERSE.14` as the owner. The MVP surface is now `with(value) { ... }` / `with() { ... }` first:
  the helper evaluates the value, binds scoped scalar `value` for immediate block execution, restores any prior
  `value` afterward, and returns the block result. Bare `with { ... }` remains deferred because word-plus-brace is
  already a rule-body lifecycle/code-block shape. Receiver `.with() { ... }`, Rust parity, and mdBook/KM/oracle
  closeout are separate leaves. Frontier moves to `.14.2`.
- `2026-07-07`: **`.14.2` DONE — Perl helper-function form trailing block arguments.**
  The Perl ActionIR AST parser now turns `with(value) { ... }` and `with() { ... }` into a helper call with a
  flagged final `block_value` argument. MethodLowering accepts the flagged trailing block only for `with`, binds a
  scoped lexical `value` during immediate block execution, preserves block-local `return(expr)`, keeps `{ key :
  value }` as a hash literal, and reports unsupported trailing-block callees with the standard unsupported-helper
  sentinel. mdBook documents the Perl reference surface without claiming Rust parity. Frontier moves to `.14.3`.
- `2026-07-07`: **`.14.3` DONE — Rust helper-function form trailing block parity.**
  Rust now parses and executes helper-function form `with(value) { ... }` / `with() { ... }` with the same immediate
  non-closure semantics as the Perl reference: scoped `value`, block-local `return(expr)`, outer binding
  restoration, zero-arg `undef`, and hash-literal boundary preservation. The generated oracle corpus now has
  **94** fixtures after adding `terse_14_3_with_helper_trailing_block`; focused parser/runtime tests and the full
  corpus oracle pass. Frontier moves to `.14.4`.
- `2026-07-07`: **`.14.4` DONE — receiver-form trailing block arguments.**
  Perl and Rust now accept receiver `.with() { ... }` as an immediate trailing block argument. The receiver value is
  scoped as `value`, the block result can be terminal or can continue into compatible receiver-family links, and
  explicit receiver `.with(value) { ... }` remains rejected/deferred. The generated oracle corpus now has **95**
  fixtures after adding `terse_14_4_receiver_with_trailing_block`; full phase0 passes 1026 tests and the Rust
  corpus oracle passes. Frontier moves to `.14.5`.
- `2026-07-07`: **`.14.5` DONE — trailing block no-drift closeout.**
  The shipped `.14` surface is explicitly helper-function form `with(value) { ... }` / `with() { ... }` plus
  receiver-method form `.with() { ... }` on Perl and Rust. `ROADMAP_V2.md`, mdBook project status, the Knowledge
  fact, task-tree rows, live docs, and the generated 95-fixture oracle corpus agree on that state. No parser/runtime
  behavior changed; bare `with { ... }`, explicit receiver `.with(value) { ... }`, closures, delayed callbacks,
  assignable/returnable blocks, and arbitrary non-`with` trailing blocks remain deferred behind future owned leaves.
  `SPEC-FORMAT-TERSE.14` is closed.

- `2026-07-08`: **`.12.3` LANDED — Rust hash-tree traversal receiver blocks and oracle parity.**
  Rust now accepts and executes `walk_leaves`, `map_leaves`, and `reduce_leaves(initial)` receiver attached-block
  calls with the same `.12` semantics as the Perl reference. The parser preserves the trailing block shape, runtime
  traversal is sorted depth-first over hash interior nodes, arrays are leaves, callback bindings are scoped and
  restored, non-hash receivers return `undef` without callbacks, malformed missing-block calls diagnose explicitly,
  and `walk_leaves` / `map_leaves` results compose with hash-family continuations. The generated oracle corpus now
  has 96 fixtures after `terse_12_3_hash_tree_traversal_receiver_blocks`, and the full Rust corpus oracle passes.
  Frontier moves to `.12.4` for mdBook, Knowledge Map, live-doc, and no-drift closeout.

- `2026-07-08`: **`.12.2` LANDED — Perl hash-tree traversal receiver blocks.**
  Perl now accepts `walk_leaves`, `map_leaves`, and `reduce_leaves(initial)` receiver attached-block calls and
  lowers them to immediate sorted depth-first traversal over hash-root/hash-interior value trees. Arrays are leaf
  values, non-hash receivers return `undef` without callbacks, malformed calls diagnose with
  `LINKEDSPEC_UNSUPPORTED_ACTIONIR_HELPER:<method>`, and callbacks get scoped `value`, `key`, `path`, `depth`,
  plus reduction-only `acc`. Focused AST and phase0 locks cover parsing, lowering, valid/empty/non-hash runtime
  behavior, side effects, continuation through `count_keys`, scoped binding restoration, descriptor readiness, and
  generated-source residue. Phase0 now passes `1..1027`; frontier moves to `.12.3` for Rust parity and oracle.

- `2026-07-08`: **`.10.1` DONE — dynamic hash-literal key contract ratified.**
  User directive reactivated the remaining `SPEC-FORMAT-TERSE` parked work. `.10` is now closed without
  parser/runtime changes: direct hash literals are expression-keyed (`{ key_expr : value_expr }`), bare keys are
  scalar reads, quoted keys are fixed fields, computed helper expressions can supply keys, old `=>` remains
  retired, and block-vs-hash precedence is unchanged. mdBook and Knowledge Map now state the contract explicitly.
  The then-frontier moved to `.13` for the remaining array-tree traversal backlog item.

- `2026-07-08`: **`.13.1` DONE — array-tree traversal split before implementation.**
  The accepted MVP uses the same immediate receiver block method names as hash-tree traversal:
  `array_value.walk_leaves() { ... }`, `array_value.map_leaves() { ... }`, and
  `array_value.reduce_leaves(initial) { ... }`. Array roots and nested arrays are traversal nodes; scalar and hash
  values are leaves. Traversal is depth-first in zero-based index order. Callback blocks get scoped `value`,
  `index`, `path`, `depth`, and reduction-only `acc`. No parser/runtime behavior changed. Frontier moves to
  `.13.2` for the Perl reference implementation.

- `2026-07-08`: **`.13.2` DONE — Perl reference array-tree traversal receiver blocks.**
  Perl now lowers the shared `walk_leaves`, `map_leaves`, and `reduce_leaves(initial)` receiver methods through a
  runtime tree-dispatch path. Hash receivers keep the `.12` sorted-key traversal contract, while array receivers
  traverse nested arrays depth-first by zero-based index and treat hash values as leaves. Array callbacks receive
  scoped `value`, `index`, `path`, `depth`, and reduction-only `acc`; scalar receivers return `undef` without
  running callbacks. Focused AST locks and the full phase0 regression pass (`Files=1, Tests=1028`) cover lowering,
  runtime behavior, side effects, continuation through `.count()`, scoped restoration, descriptor readiness, and
  generated-source residue. Frontier moves to `.13.3` for Rust parser/runtime parity and the generated oracle
  fixture.

- `2026-07-08`: **`.13.3` DONE — Rust array-tree traversal receiver blocks and oracle parity.**
  Rust now parses and executes array-valued `walk_leaves`, `map_leaves`, and `reduce_leaves(initial)` receiver
  trailing blocks through shared tree traversal dispatch. Hash receivers preserve `.12` sorted-key traversal;
  array receivers recurse through nested arrays by zero-based index, treat hashes as leaves, bind scoped
  `value`/`index`/`path`/`depth` plus reduce-only `acc`, and return `undef` without callbacks for scalar receivers.
  Focused Rust parser/runtime and hash-tree regression tests pass. The generated oracle corpus now has **97**
  fixtures after `terse_13_3_array_tree_traversal_receiver_blocks`, and the Rust corpus oracle passes. The
  then-frontier moved to `.13.4` for docs/KM/no-drift closeout.

- `2026-07-08`: **`.13.4` DONE — array-tree traversal docs/KM/no-drift closeout.**
  mdBook helper/reference/formal/backend-handoff/status pages, Knowledge Map facts, live docs, roadmap state,
  task-tree rows, and the generated 97-fixture oracle manifest now agree that array-tree traversal receiver blocks
  are shipped on Perl/Rust. Final drift scans found no current-facing Rust-pending wording, callback-binding drift,
  or stale current corpus count. No parser/runtime or corpus semantics changed. `.13` is closed/exhausted.

- `2026-07-08`: **`.13.5` DONE — parent terse task-tree status closeout.**
  The parent `SPEC-FORMAT-TERSE` task-tree and central index now mark the tree `done` / `closed` instead of
  `active` with an empty frontier. Stale internal split-container rows that still looked live are now historical
  done/closed rows. No parser/runtime, corpus, or behavioral mdBook semantics changed.

- `2026-07-05`: **`.12`/`.13` DEFERRED/BACKLOG — tree traversal attached-block ideas.**
  User directive tracked hash-tree traversal methods with attached code blocks as future spec work and clarified
  that hash-tree leaves are scalar or array values. The analogous array-tree traversal idea is tracked as a
  lower-priority backlog item. Neither leaf is implementation-active unless explicitly reactivated.

- `2026-07-05`: **`.11` ACTIVE — duck-typed assignment semantics.**
  User directive adopts duck-typed variable binding as the active assignment direction: `name = value` binds a
  typed value, including array/hash RHS values, without exposing Perl `$/@/%` storage classes as the spec model.
  The leaf is now the active spec-first assignment-semantics owner, including nested mixed array/hash tree
  references and assignments in arbitrary combinations, and must coordinate with `.8` helper-removal fallout and
  `.9` colon hash-literal syntax before implementation lands.

- `2026-07-04`: **`.8` OWNED — legacy compatibility helper support removal.**
  User directive supersedes the `.6.4` compatibility-retention policy for this unreleased project. The next slice
  removes remaining compatibility-only helper spellings from Perl/Rust, tests/corpus, mdBook, Knowledge Map, and
  roadmap/live docs so the terse surface is the only accepted current helper surface.

- `2026-07-04`: **`.9` OWNED — colon hash-literal association syntax.**
  User directive replaces Perlish `{ key => value }` hash-literal association with terse `{ key : value }` syntax.
  The leaf is queued behind `.8` so compatibility-helper removal can land as its own committed slice before the
  hash-literal parser/docs migration.

- `2026-07-07`: **`.9.1` DONE — hash-literal colon migration split/inventory.**
  Current `=>` occurrences are owned before implementation: blind-call edge syntax remains distinct and valid,
  VHDL/source-language associations remain untouched, direct hash-literal association migrates under `.9.2`-`.9.6`,
  and parser/runtime support sites are identified on Perl and Rust. Frontier moves to `.9.2`.

- `2026-07-07`: **`.9.2` DONE — Perl reference colon hash-literal support.**
  Perl direct hash literals now accept `{ key : value }` in the ActionIR AST parser/lowering path while old
  `{ key => value }` remains available only during the migration window. Nested shapes, quoted keys, direct RHS
  assignment, hash-index mutation RHS, expression-valued assignment forms, generated Perl host fat arrows, and
  block-vs-hash precedence are locked by focused parser tests and full phase0. Frontier moves to `.9.3`.

- `2026-07-07`: **`.9.3` DONE — Rust colon hash-literal parity.**
  Rust direct hash literals accepted `{ key : value }` in the ActionIR expression parser/runtime path while old
  `{ key => value }` remained available only during the migration window before `.9.5`. Nested shapes, direct assignment RHS,
  hash-index mutation RHS, expression-valued assignment forms, direct hash receiver chains, mixed old/new
  separators, and block-vs-hash precedence are locked by focused parser/runtime tests. Frontier moves to `.9.4`.

- `2026-07-07`: **`.9.4` DONE — current source/docs/corpus/KM migrated to colon hash-literal syntax.**
  Current-facing `.spec` sources, generated oracle inputs, active tests, mdBook examples, root docs, and current
  Knowledge facts now use `{ key : value }` for direct hash-literal association. Remaining `=>` occurrences are
  classified as blind-call edge syntax, VHDL/source-language associations, generated Perl host-output hashrefs,
  Perl metadata hashes, historical/changelog material, or explicit mixed old/new compatibility coverage. The
  migration exposed and fixed a Perl `MethodLowering.pm` source fallback for colon hash literals inside
  expression-valued block receiver chains. Frontier moves to `.9.5`.

- `2026-07-07`: **`.9.5` DONE — old hash-literal fat arrows retired.**
  Perl and Rust now reject old `{ key => value }` as current ActionIR hash-literal syntax and point authors to
  `{ key : value }`. Perl routes retired direct hash-literal fat arrows to the
  `LINKEDSPEC_UNSUPPORTED_ACTIONIR_HELPER:hash_literal_use_colon` diagnostic instead of current AST or raw
  fallback lowering, and Rust treats the same retired parse diagnostic as a compile error rather than silently
  accepting dropped action code. Blind-call edge `=> Rule` remains valid. Frontier moves to `.9.6`.

- `2026-07-07`: **`.9.6` DONE — hash-literal colon no-drift closed.**
  Current specs, corpus inputs, generated oracle inputs, tests, docs/mdBook, current Knowledge facts, and
  implementation-support scans show no unclassified current direct hash-literal `=>`. Remaining `=>` owners are
  blind-call edge syntax, VHDL/source-language associations, generated Perl host output, Perl metadata/test data,
  explicit retired-diagnostic locks, value-rendering examples, or historical records. Oracle regeneration stays at
  **93** fixtures, Rust `corpus_oracle` passes, full phase0 passes `1..1024`, and `.9` has no PNT-eligible child
  remaining.

- `2026-07-04`: **`.10` DEFERRED/POTENTIAL — dynamic/computed hash-literal keys.**
  User directive tracked a possible future implementation for dynamic/computed hash-literal keys, but only if the
  spec explicitly defines the syntax and semantics first. This was later resolved by `.10.1`, which ratified the
  existing expression-keyed contract without parser/runtime changes.

- `2026-07-04`: **`.6.4` DONE — historical declaration-helper compatibility policy locked.**
  `declare(...)` and declaration aliases were kept as legacy compatibility for existing specs after the terse
  migration, but they were excluded from new shipped specs, current-facing examples, and root corpus examples.
  `SPEC-FORMAT-TERSE.8` later superseded this retention policy and hard-retired the helpers. Declaration-retirement
  `.6` is closed; frontier moves to `.7.1`.

- `2026-07-04`: **`.6.3` DONE — public docs and corpus examples swept to the terse surface.**
  Current-facing mdBook examples and root corpus specs now use auto-existing variables, assignments, direct
  shape literals, `push(...)`, `copy(...)`, and `cat(...)` instead of active `declare(...)` or old helper names.
  The root `tests/corpus` specs scan clean and focused probes preserve their existing outputs. Generated Rust
  oracle fixture inputs use canonical helper spellings where the old name was incidental; residual old spellings
  are isolated to compatibility fixtures or explicit legacy/reference documentation. Added KM coverage for the
  `merge_hash(copy(hash(base)), overlay)` boundary. Oracle regeneration remains **73 fixtures**, Rust
  `corpus_oracle` passes, and mdBook builds. Frontier moves to `.6.4`.

- `2026-07-04`: **`.6.2.4` DONE — final shipped-spec terse-surface verification and no-drift inventory.**
  All 21 shipped `specs/*.spec` files descriptor-compile from this checkout with `perl -Iperl`, and shipped-spec
  scans are clean for retired `scalar(...)` / `assign(...)`, active `declare(...)` / `.declare(...)`, and older
  helper spellings (`push_value`, `array_copy`, `hash_copy`, `concat`). Phase0 is **1020 green**; oracle
  regeneration remains stable at **73 fixtures** with no tracked corpus diff; Rust `corpus_oracle` passes; and
  the mdBook builds with no `scalar(...)` / `assign(...)` hits. Broader checked-in corpus and public-book
  `declare(...)` / older-helper references are intentionally carried into `.6.3`, which now owns the docs,
  corpus/test-spec, and example sweep.

- `2026-07-03`: **`.6.2.1` DONE — shipped specs no longer use active `declare(...)`.**
  The 70 active declaration hits inventoried by `.6.1` were migrated across 13 shipped specs to terse
  assignments and reset forms. Fluent `I.declare(...)` chains that only existed for declaration ceremony now use
  structured blocks with `name = value`, `name = undef`, or `items = []`, while old helper spellings such as
  `assign`, `push_value`, `array_copy`, `hash_copy`, and `concat` are intentionally left to `.6.2.2` and wrapper
  cleanup is left to `.6.2.3`. `rg -n 'declare\(|\.declare\(' specs` is clean; all edited shipped specs compile;
  phase0 is **1018 green**; the Rust oracle corpus is green over **66 fixtures**. The user's broader directive to
  audit/backfill useful methods on supported types, including string `substr()`, is tracked as future lane `.7`
  and starts with an inventory before code.

- `2026-07-03`: **`.6.1` DONE — declaration migration owned under terse format.** The user directive that
  `declare(...)` shall not be used in spec files is now owned by `SPEC-FORMAT-TERSE.6`, implementing the
  existing Round 1/ADR `0007` migration promise. Inventory found 70 active `declare(...)` hits across 13 shipped
  specs. No `.spec` file changed in this ownership slice; frontier moves to `.6.2`.

- `2026-07-02`: **`.3.3.4` LANDED — assignment-expression closure and legacy spelling cleanup.**
  The full `.3.3` assignment-expression family is now closed on Perl/Rust: scalar assignments, direct-shape
  array/hash assignments, `items += value`, `meta[key] = value`, `=(target,value)`, canonical `set(...)`,
  user-function body assignment, receiver-chain terminals, and legacy `assign(...)` compatibility compose in one
  portable fixture. Public mdBook examples now prefer `set(...)` or operator assignment; `assign(...)` remains
  only as a documented legacy alias with current value semantics. The oracle corpus is **62 fixtures**, phase0 is
  **1015 green**, and the `SPEC-FORMAT-TERSE` tree had no remaining concrete PNT-eligible implementation leaf at
  that time.

- `2026-07-02`: **`.3.3.3` LANDED — mutation assignment expression values.**
  Array append and hash-index mutation operators now mutate and yield updated aggregate snapshots on Perl/Rust:
  `items += value` returns the updated array, and `meta[key] = value` returns the updated hash. Snapshot values
  compose in `return(...)`, helper arguments, expression-valued blocks, and compatible receiver chains such as
  `(items += value).count()` and `(meta[key] = value).count_keys()`. Statement behavior is preserved. The oracle
  corpus is **61 fixtures**, phase0 is **1014 green**, and the frontier moves to `.3.3.4` for legacy function
  spelling cleanup and full assignment-expression closure.

- `2026-07-02`: **`.3.3.2` LANDED — aggregate assignment expression values.**
  Direct RHS shape assignments now store and yield aggregate values after target-kind inference on Perl/Rust:
  `items = [value]`, `set(items, [value])`, `=(items, [value])`, and matching `array(items)` targets yield the
  assigned array; `meta = { key => value }`, `set(meta, { key => value })`, and matching `hash(meta)` targets
  yield the assigned hash. Explicit `scalar(payload)` keeps scalar-held shape payloads. The oracle corpus is
  **60 fixtures**, phase0 is **1013 green**, and the frontier moves to `.3.3.3` for array append/hash-index
  mutation expression values.

- `2026-07-02`: **`.3.3.1` DONE — scalar assignment expression values shipped.**
  Scalar non-shape assignment now composes as a value on Perl and Rust. `name = value`, `=(name,value)`,
  `set(name,value)`, and legacy `assign(name,value)` store the scalar and yield the stored value in
  `return(...)`, helper arguments, expression-valued blocks, user-function bodies, and compatible scalar
  receiver chains. Direct RHS shape assignment expression values, array append values, and hash-index mutation
  values remain split follow-ons. Frontier moves to `.3.3.2`.

- `2026-07-02`: **`.3.3` SPLIT/DONE — expression-valued assignment split before code.**
  The assignment-expression destination contract is now owned without changing parser/compiler/runtime
  behavior: `target = value` remains canonical, `=(target,value)` is the planned operator-call equivalent, and
  legacy `assign(target,value)` stays migration debt. TOOLBOX probes and Rust source audit confirm the current
  shipped implementation is still statement-only for scalar assignment, array append, and hash-index
  assignment. The implementation is split into scalar expression values (`.3.3.1`), aggregate target-kind
  expression values (`.3.3.2`), append/hash-index mutation expression values (`.3.3.3`), and compatibility/docs
  closure (`.3.3.4`). Frontier moves to `.3.3.1`.

- `2026-07-02`: **`.3.2.3.4` DONE — numeric comparison symbol callees shipped.**
  Comparison symbol callees `==`, `!=`, `>`, `>=`, `<`, and `<=` now lower/dispatch as numeric aliases for
  `num_eq`, `num_ne`, `num_gt`, `num_ge`, `num_lt`, and `num_le` on Perl and Rust. Rust argument parsing no
  longer misclassifies `==(...)` as an empty keyword argument. Slash regex/division behavior remains intact,
  lexical string comparisons remain `str_*`, `=(target,value)` remains `.3.3`, and `=>` remains blind-call.
  Added phase0, Rust parser/runtime, and oracle locks; corpus reaches 58 fixtures and phase0 reaches 1011
  tests. Frontier moves to `.3.3`.

- `2026-07-02`: **`.3.2.3.3` DONE — numeric comparison word aliases shipped.**
  Bare value-call `eq`, `ne`, `gt`, `ge`, `lt`, and `le` now lower/dispatch as numeric aliases for
  `num_eq`, `num_ne`, `num_gt`, `num_ge`, `num_lt`, and `num_le` on Perl and Rust. Explicit `str_eq`,
  `str_ne`, `str_gt`, `str_ge`, `str_lt`, and `str_le` remain the lexical string comparison surface, and
  repo-owned specs/tests with string comparison intent have moved to `str_*`. Added phase0, Rust runtime, and
  oracle locks; corpus reaches 57 fixtures and phase0 reaches 1010 tests. Frontier moves to `.3.2.3.4`.

- `2026-07-02`: **`.3.2.3.2` DONE — explicit string-comparison helpers shipped.**
  `str_eq`, `str_ne`, `str_gt`, `str_ge`, `str_lt`, and `str_le` now lower/dispatch as portable lexical
  string predicates on Perl and Rust. The book now prefers `str_*` for new text comparisons. Bare
  `eq`/`ne`/`gt`/`ge`/`lt`/`le` remain runnable string-comparison compatibility aliases until `.3.2.3.3` flips
  ordinary comparison word calls to numeric `num_*` aliases. Added phase0, Rust runtime, and oracle locks;
  corpus reaches 56 fixtures and phase0 reaches 1009 tests. Frontier moves to `.3.2.3.3`.

- `2026-07-02`: **`.3.2.3.1` DONE — explicit string bridge contract locked.**
  `str_eq`, `str_ne`, `str_gt`, `str_ge`, `str_lt`, and `str_le` are now the accepted bridge names for today's
  lexical string comparison semantics. The public book names the bridge but marks it as not shipped until the
  implementation leaf `.3.2.3.2`; bare `eq`/`ne`/`gt`/`ge`/`lt`/`le` remain current string helpers until then.
  No parser/compiler/runtime code changed. Frontier moves to `.3.2.3.2`.

- `2026-07-02`: **`.3.2.3` SPLIT/OWNED — comparison call surface migration split.**
  The comparison operator-call contract is now owned before implementation. The future canonical numeric
  surface is ordinary `callee(args)` calls with word and symbol spellings: `eq`/`==`, `ne`/`!=`, `gt`/`>`,
  `ge`/`>=`, `lt`/`<`, and `le`/`<=`, all mapping to the existing `num_*` comparison family. Because current
  bare comparison words are documented string comparisons, implementation is split behind explicit
  `str_eq`/`str_ne`/`str_gt`/`str_ge`/`str_lt`/`str_le` string helpers. Then-frontier moved to `.3.2.3.1`;
  the later symbol implementation moved the active frontier to `.3.3`. No parser/compiler/runtime behavior
  changed in this split slice.

- `2026-07-02`: **`.4.4` DONE — function MVP surface and deferred extension ledger finalized.**
  The public book, task tree, and retrieval cards now make the accepted user-function surface explicit after
  Perl/Rust parity: top-level `fn name(args) { ... }`, explicit parentheses for every arity, braced
  value-oriented bodies, exact arity, fresh function-local stores, final-expression/`return(expr)` results,
  value-call composition, receiver-chain continuation, and standalone result discard. Alternate spellings,
  omitted zero-arg parentheses, brace-less bodies, caller-state/parser-state/persistent side-effect functions,
  recursive user functions, closures, lambdas, currying/partial application, and namespace/module features are
  explicitly deferred. Frontier moves back to `.3.2.2`.

- `2026-07-02`: **`.4.3.2` DONE — Rust user-function runtime and oracle parity landed.**
  Rust registered user-function calls now resolve before ordinary helper fallback, evaluate arguments eagerly in
  the caller context, bind params into fresh function-local scalar/array/hash stores, evaluate compiled
  `CodeBlock` bodies, and return final-expression or `return(expr)` values. Returned arrays, hashes, strings,
  and numbers feed compatible receiver-dot chains. Standalone registered calls execute and discard their result.
  Wrong arity and direct/mutual recursion diagnose deterministically. The oracle corpus adds
  `terse_4_3_2_user_function_runtime`, bringing the corpus to **54 fixtures**. Frontier moves to `.4.4` for the
  final function-surface/deferral ledger before `.3.2.2`.

- `2026-07-02`: **`.4.3.1` DONE — Rust function-definition AST/compiler registry parity landed.**
  Rust `.spec` parsing now recognizes top-level `fn name(args) { ... }` declarations before or between rule
  paragraphs and stores them on `SpecFile.functions` with ordered params, exact arity, original source,
  body source, and source/body spans. Rust validation rejects duplicate functions, rule-label collisions,
  helper/control-name collisions including `.3.2.1` numeric word aliases, lifecycle/runtime/function-keyword
  collisions, invalid params, duplicate params, and reserved params before runtime. Rust compilation now projects the registry into `CompiledSpec.functions` as
  `CompiledUserFunction` records whose bodies are parsed into `CodeBlock` values, with compile diagnostics for
  invalid body code. This is intentionally registry-only: Rust user-function call execution, standalone discard,
  receiver-chain continuation, and oracle fixtures remain `.4.3.2`. Frontier moves to `.4.3.2`.

- `2026-07-01`: **`.4.2.3` DONE — Perl standalone user-function discard and hardening landed.**
  Registered standalone calls and receiver chains now enter the canonical ActionIR pipeline as `VALUE_DROP`
  events using the compiled function registry, so values are computed through ordinary user-function lowering and
  then discarded without raw fallback. The implementation also fixes nested user-function calls whose arguments
  are function-local params, ensuring parameter values are passed rather than bare parameter names. Phase0 locks
  direct and mutual recursion diagnostics plus parser-state helper bodies, host-code-shaped bodies, and nested
  function syntax as unresolved-helper diagnostics with zero raw fallback. Unregistered standalone calls remain
  raw compatibility debt. Frontier moves to `.4.3.1`.

- `2026-07-01`: **`.4.2.2` DONE — Perl registered user-function value-call execution landed.**
  Registered exact-arity calls now resolve during ActionIR lowering after the compiler threads the function
  registry into per-rule emit contexts. Arguments are evaluated eagerly in the caller, positional params bind in a
  fresh function-local scope, function body AST statements lower to a value-producing expression, and final
  expressions or `return(expr)` payloads become the call value. Phase0 locks cover `return(...)`, assignment RHS,
  array append RHS, hash mutation value, helper arguments, final-expression bodies, non-final function-local
  `return(expr)`, compatible receiver-dot chains from returned values, and local/caller shadowing. Wrong-arity
  registered calls stay unresolved-helper diagnostics with zero raw fallback. Standalone discard, recursion
  rejection, purity diagnostics, and unsupported body-effect hardening remain `.4.2.3`. Frontier moves to
  `.4.2.3`.

- `2026-07-01`: **`.4.2.1` DONE — Perl function-definition grammar/registry descriptor seam landed.**
  `specs/spec.spec` now has an active `function_definition` rule for top-level `fn name(args) { body }` and a
  `spec_file` dispatch edge for it. The Perl reference uses a temporary pre-bootstrap registry bridge to extract
  those definitions before ordinary validation/bootstrap, preserving line numbers in the stripped source. Public
  descriptors now expose `functions`, `meta.function_order`, and `meta.function_count`; each registered
  definition records name, params, arity, source/body spans, body source, and body AST. Duplicate definitions,
  invalid/duplicate params, reserved symbols, built-in helper/control-name collisions, and rule-label collisions
  are rejected before runtime. This leaf deliberately does not execute registered function calls: value-position
  calls still report unresolved-helper diagnostics with zero raw fallback until `.4.2.2`. Frontier moves to
  `.4.2.2`.

- `2026-07-01`: **`.4.1` DONE — user-defined function contract/inventory locked.**
  The MVP grammar and semantics are now explicit before implementation: top-level `fn name(args) { ... }`,
  exact explicit arity, eager argument evaluation, fresh function-local positional parameters and local working
  variables, pure value/block bodies, no implicit caller-state capture, no recursion, no closures/lambdas/currying,
  no host-code escape, and no parser-state or side-effect helpers in the MVP. Function calls are value
  expressions that may feed helper arguments, assignments, returns, mutation values, expression-valued blocks,
  and compatible receiver-dot chains; standalone calls compute and silently discard the returned value.
  Function names share the helper call surface, so definitions must not collide with built-in helper/control/
  lifecycle names, rule labels, reserved runtime symbols, or other function definitions. Inventory showed the
  implementation is broader than one signoff slice, so `.4.2` is now split into Perl grammar/registry,
  value-call execution, and discard/purity hardening leaves, while `.4.3` is split into Rust registry and
  runtime/oracle parity. Frontier moves to `.4.2.1`.

- `2026-07-01`: **`.4` SPLIT/OWNED — user-defined pure functions.**
  User-defined `.spec` functions are now task-tree owned before implementation. The MVP contract starts with
  top-level `fn name(args) { ... }`, explicit parentheses for every arity, explicit positional parameters,
  pure value/block bodies, and no implicit caller-state capture, recursion, closures, lambdas, or currying.
  Function calls are ordinary value expressions: their results can feed helper arguments, assignments,
  returns, mutation value slots, and receiver-dot chains; a standalone call silently drops the returned value.
  Follow-up user decision: final `fn` syntax belongs in `specs/spec.spec`; bootstrap-parser support is temporary
  migration debt to remove after text-to-AST handoff.
  Frontier moves to `.4.1` for the contract/inventory leaf, with `.3.2.2` still queued afterward.

- `2026-07-01`: **`.2.3.5.5` LANDED — block-valued receiver-dot chains.**
  Expression-valued blocks now work as receivers for the existing compatible array/string/hash/number value
  chains. The block evaluates first, including block-local `return(expr)`, then the yielded value feeds the
  first receiver method's helper family. Perl now recognizes array-yielding block exits narrowly enough for
  `{ [3, 1, 2] }.sorted().join_values(",")` and
  `{ return(["x", "y"]); ["bad"] }.join_values("|")` without treating every block as an array. Rust now parses
  fluent chains after block/hash/array primaries, using its existing runtime evaluator for non-variable
  receivers. Phase0 is 1001 green, the Rust oracle corpus is 52 fixtures, and the receiver-chain family is
  complete.

- `2026-07-01`: **`.2.3.5.6` LANDED — aggregate wrapper quoted-name boundaries.**
  Bare aggregate wrappers remain typed working-variable reads: `array(foo)` / `a(foo)` read `@foo`, and
  `hash(bar)` / `h(bar)` read `%bar`. Quoted wrapper arguments are not aliases and are not scalar-indirect
  lookups: `array("foo")` / `array('foo')` are literal constructor payloads, while quoted hash arguments are
  fixed-key constructor payloads under the existing arity rules. The mdBook now prefers direct terse shape
  constructors (`[...]`, `{...}`, `[]`, `{}`) for new array/hash construction examples, and postfix
  `foo.array()`-style typed-view adapters remain out of scope. Phase0 is 1000 green, the Rust oracle corpus is
  51 fixtures, and the then-frontier returned to `.2.3.5.5`.

- `2026-07-01`: **`.2.3.5.4` LANDED — number receiver-dot value chains.**
  Number receiver-dot chains now compose through the existing `num_*` helper family on Perl and Rust:
  `score.abs().ceil().add(2, 3).mul(2).sub(1).div(2).clamp(0, 20).max(5).min(12)`,
  `5.mod(2)`, and `3.5.floor().add(1)` are locked. Comparison methods such as `gt`/`le` are terminal values;
  invalid later receiver calls return `undef`/`null`. Numeric array reducers remained explicit array-consuming
  helpers at that time; later `.7.3` added terminal array/list receiver reducer methods without making reducers
  scalar number receiver links. Statement/lifecycle calls such as `declare(...)` are not receiver methods. Phase0 is 999 green,
  the Rust oracle corpus is 50 fixtures, and the then-frontier moved to `.2.3.5.5`.

- `2026-06-30`: **`.2.3.4.2` LANDED — Perl inline value-control lowering.**
  Inline-composite `if(...)` and `switch(...)` now return selected branch payloads on the Perl reference in
  `return(...)`, assignment RHS, and fluent `.return(...)` value positions. Branch payloads compose with nested
  helpers and expression-valued blocks; fluent/action-edge checks assert payload values without making any
  `?...:` compatibility tag spelling mandatory. The new
  `terse_2_3_4_2_inline_if_value_control` and
  `terse_2_3_4_2_inline_switch_value_control` oracle fixtures bring `corpus_oracle` to 46 passing fixtures.
  Frontier moves to `.2.3.5`.

- `2026-06-30`: **`.2.3.4.1` LANDED — Rust helper-context bare aggregate arguments.**
  Rust now snapshots bare working-variable names only in hash- or array-consuming helper argument slots, so
  `merge_hash(hash_copy(base), overlay)` and `count(drop_front(sorted(items)))` match Perl without changing
  ordinary bare scalar reads. Focused runtime locks cover the merge case, the broader hash/object helper family,
  and the array helper family; the new `terse_2_3_4_1_bare_hash_helper_arg_composition` and
  `terse_2_3_4_1_bare_array_helper_arg_composition` oracle fixtures bring `corpus_oracle` to 44 passing
  fixtures. Frontier moves to `.2.3.4.2`.

- `2026-06-30`: **`.2.3.4` AUDIT/SPLIT — full composability boundaries.** Pure helper nesting is portable
  with explicit aggregate wrappers and is locked by a new oracle fixture
  `terse_2_3_4_deep_pure_helper_composition`; the Rust corpus now passes with 42 fixtures. Unsupported sites
  are split before code: `.2.3.4.1` owns Rust helper-context aggregate bare reads such as
  `merge_hash(hash_copy(base), overlay)`, and `.2.3.4.2` owns Perl inline-composite value-control lowering for
  `return(if(...))` / `return(switch(...))`. Receiver-dot value/chaining remains `.2.3.5`. Frontier moves to
  `.2.3.4.1`.

- `2026-06-30`: **`.2.3.3.3.3.1` LANDED — Rust `tclite` default-mode repetition parity.**
  Rust now treats bare default rules as zero-min repeated-choice loops and honors child-rule `I.return(...)`
  before local entry-regex re-matching. The shipped `tclite_command_subst` (`[]`) and `tclite_double_quote`
  (`""`) oracle cases are active again; `corpus_oracle` passes with 41 fixtures. Frontier moves to `.2.3.4`.

- `2026-06-30`: **`.2.3.3.3.3` AUDIT/SPLIT — Rust `tclite` retry after fluent parity.**
  Perl reference probes show `tclite` returns `["?tcl_script:",[["?command_subst:",[]]]]` for `[]` and
  `["?tcl_script:",[["?double_quote:",[]]]]` for `""`. Temporarily re-enabling those oracle fixtures made the
  Rust corpus oracle fail exactly those two cases: expected the wrapped Perl values, actual `[]` for both,
  while the other 39 fixtures passed. The failing fixtures were not committed in the split slice; `.2.3.3.3.3.1`
  later landed default-mode recursive repetition parity and re-enabled them. Frontier moved to `.2.3.3.3.3.1`.

- `2026-06-30`: **`.2.3.3.3.2` LANDED — Rust action-edge explicit/flow fluent chains.**
  Rust now keeps multiline dotted continuations after an action edge attached to that edge and executes
  explicit/flow continuations beyond the earlier no-arg subset. `.push(target)` and `.push(child,target)`
  dispatch the child and append its return to the explicit target accumulator; `.if/.else/.endif` gates later
  fluent calls; branch-local helpers such as `.say(...)` use normal helper evaluation; and
  `.return_undef()` keeps the action-edge return path. The next frontier is `.2.3.3.3.3`, the `tclite`
  oracle/default-mode repetition audit.

- `2026-06-30`: **`.2.3.3.3.1` LANDED — Rust compact lifecycle fluent chains.**
  Rust now parses accepted lifecycle-marker receiver chains such as `I.return(...)` and
  `I.declare(...).set(...).return(...)` into executable lifecycle `CodeBlock` statements rather than leaving a
  standalone `FluentChain` for the compiler to drop. Focused parser/compiler/runtime locks pass, mdBook/KM/live
  docs are updated, and the next frontier is `.2.3.3.3.2` action-edge explicit/flow fluent chains.

- `2026-06-30`: **`.2.3.3.3` SPLIT — remaining Rust fluent continuations.**
  The leaf was too broad for one signoff implementation slice. Rust lifecycle/body compact chains such as
  `I.return(...)` currently parse as a lifecycle marker plus standalone `FluentChain` and are dropped by the
  compiler; action-edge explicit/flow chains need separate runtime semantics beyond the no-arg subset; `tclite`
  re-enable waits until those fluent children land, then gets a focused default-mode repetition audit if still
  divergent. Frontier moves to `.2.3.3.3.1`.

- `2026-06-30`: **`.2.3.3.2` LANDED — Rust attached fluent block payloads.**
  Rust now parses action-edge and lifecycle-marker `.when(cond) { ... }` receiver-fluent block chains and
  normalizes them to existing attached `when/otherwise` statement blocks. Dotted `.otherwise { ... }` and
  no-dot `otherwise { ... }` fallback tails execute on both surfaces, including multiline `}.otherwise {`
  placement. Focused Rust parser/runtime locks PASS. Frontier moves to `.2.3.3.3`.

- `2026-06-30`: **`.2.3.3.1` LANDED — Rust action-edge fluent continuations.**
  Rust now carries fluent chains on `->` action edges through AST, compiled `AcodeEntry`, and runtime dispatch.
  No-arg `.push` captures the child rule return, suppresses child return-event leakage, and appends to the
  current rule accumulator. `.return(expr)` / `.return_undef` return through the current rule/action channel
  without redispatching the close-edge child; `.return_undef` stays accumulator-silent. Full local CI PASS
  (`Files=1, Tests=994`). `tclite` remains deferred behind compact lifecycle/body fluent forms and default-mode
  repetition parity. Frontier moves to `.2.3.3.2`.

- `2026-06-30`: **`.2.3.2` LANDED — lifecycle value/drop return-channel lock.**
  Lifecycle blocks are statement blocks: final ordinary statement values are discarded, top-level
  `return(expr)` writes the surrounding return channel, and expression-valued block-local return stays local.
  Phase0 source-locks all seven lifecycle markers and runtime-locks the value/drop distinction. Phase0 is
  **994 green**. Frontier moves to `.2.3.3`.

- `2026-06-30`: **`.2.3.1` LANDED — Perl fluent `when/otherwise` block-chain contract.**
  Bootstrap now keeps attached fallback tails after fluent `.when(...) { ... }` chains, including both dotted
  `.otherwise { ... }` and no-dot `otherwise { ... }` continuations. Phase0 locks cover action-edge and
  lifecycle false-branch fallback execution, descriptor cleanliness, and generated-source residue. Phase0 is
  **993 green**. Frontier moves to `.2.3.2`.

- `2026-06-30`: **`.2.3` SPLIT/OWNED BEFORE CODE — fluent control-flow, lifecycle blocks, full
  composability, and method chaining.** Perl reference already accepts exact action/lifecycle
  `.when(cond) { ... }.otherwise { ... }` fluent block chains, but Rust does not yet support the same fluent
  attached-block/action-edge surface and lifecycle value-drop semantics need a separate lock. Full
  composability and return-type method chaining are split into their own leaves rather than treated as one
  parser/runtime change. Frontier moves to `.2.3.1`.

- `2026-06-30`: **`.2.2.6` SPLIT/OWNED BEFORE CODE — attached `while(cond) { ... }`.**
  Current Perl lowers attached while as raw host code, and Rust has no attached statement-loop parser/runtime.
  Split into `.2.2.6.1` Perl reference loop/safety and `.2.2.6.2` Rust parity. The loop safety rule is part of
  the contract: a non-terminating loop must hit a deterministic iteration guard instead of hanging. Frontier
  moves to `.2.2.6.1`.

- `2026-06-30`: **`.2.2.6.1` LANDED — Perl attached `while(cond) { ... }` loop/safety.**
  Perl lowers attached while through ActionIR without raw fallback or unresolved helper residue. The accepted
  contract includes pre-iteration condition evaluation, ordinary body statement execution, surrounding-rule
  `return(expr)` semantics, and the deterministic 10000-iteration guard. Frontier moves to `.2.2.6.2`.

- `2026-06-30`: **`.2.2.6.2` LANDED — Rust attached `while(cond) { ... }` parity.**
  Rust parses attached while as a lazy loop over a parsed body block and executes it with condition
  re-evaluation, normal statement-body semantics, expression-valued block-local `return(expr)`, and the same
  10000-iteration safety diagnostic as Perl. Numeric comparison helper parity closes the documented counter
  loop pattern. Oracle corpus now has **39 fixtures**. Frontier moves to `.2.3`.

- `2026-06-30`: **`.2.2.5.2` LANDED — Rust attached `switch/case/default` parity.**
  `CodeBlock::parse` now lowers attached switch branch blocks into `switch` / `case` / `default` /
  `endswitch` statement controls, and `Engine` gates those controls with a switch stack in lifecycle and
  expression-valued blocks. Focused parser/runtime/lazy-switch checks pass; oracle corpus now has **38
  fixtures**. Frontier moves to `.2.2.6` (`while`).

- `2026-06-30`: **`.2.2.5.1` LANDED — Perl attached `switch/case/default` separator/source lock.**
  `StatementSplit::Core` now splits adjacent attached `case(...) { ... }` and `default { ... }` branch bodies
  before same-line branch continuations. Compact attached switch lowers with `ready=1 raw=0 unresolved=0`, no
  host-shaped branch residue, and first/later/default runtime selection locked. The `.1.5.4` separator rule
  remains: a following same-line ordinary statement needs `;`. Frontier moves to `.2.2.5.2` Rust parity.

- `2026-06-30`: **`.2.2.5` SPLIT/OWNED BEFORE CODE — attached `switch/case/default`.**
  TOOLBOX probes show this surface is not one safe implementation leaf: Perl has partial attached-switch
  lowering but adjacent branch blocks without explicit separators can leave unresolved `case` or host-like
  `default` residue, while Rust only has the lazy value-form `switch(...)` helper and no attached statement
  parser. Split `.2.2.5` into `.2.2.5.1` Perl separator/source lock and `.2.2.5.2` Rust parity. Frontier moves
  to `.2.2.5.1`.

- `2026-06-30`: **`.2.2.4` LANDED — `when/otherwise` conditional aliases.**
  Perl now recognizes attached `when(cond) { ... } otherwise { ... }` at the existing splitter,
  scanner/contract, and `ControlFlow` seams, lowers it as canonical `if/else`, and no longer leaks host Perl
  `when` into generated handlers. Rust normalizes the same attached form in `CodeBlock::parse` to existing
  `if`/`else`/`endif` statement controls. Added focused Perl/Rust locks plus oracle fixture
  `terse_2_2_4_when_otherwise_aliases` (corpus **37 fixtures**). Frontier moves to `.2.2.5` attached
  `switch/case/default`.

- `2026-06-30`: **`.2.2.4` OWNED BEFORE CODE — `when/otherwise` aliases.**
  TOOLBOX probes show the current combined `when(true) { ... } otherwise { ... }` form is raw
  (`ready=0 raw=1 unresolved=2`), emits Perl's host `when is experimental` warning in generated handlers, and
  returns the wrong branch in the true-condition runtime probe. The accepted implementation boundary is alias
  normalization: `when(cond) { ... }` maps to attached `if(cond) { ... }`, and `otherwise { ... }` maps to
  attached `else { ... }`. Perl changes should live in the existing statement-split/scanner/contract/control-flow
  seams; Rust should normalize in `CodeBlock::parse` and reuse `handle_statement_if_control`. No behavior
  changed in this ownership slice.

- `2026-06-30`: **`.2.2.3` LANDED — Rust attached-block if parity.**
  Rust now parses attached `if(cond) { ... } elseif(cond2) { ... } else { ... }` statement chains in
  `CodeBlock::parse` and normalizes them to the existing `if` / `elseif` / `else` / `endif` marker-control
  sequence. Runtime branch gating reuses `Engine::handle_statement_if_control`; no second branch runtime was
  added. Focused parser/runtime locks and the new `terse_2_2_3_attached_if_blocks` oracle fixture keep
  marker-form `if(cond); ... endif()` and inline-composite `if(...)` behavior unchanged. Attached-block `if`
  is now portable on Perl and Rust; frontier moves to `.2.2.4` (`when/otherwise`).

- `2026-06-30`: **`.2.2.3` OWNED BEFORE CODE — Rust attached-block if parity.**
  Code-read narrowed the Rust parity slice. `CodeBlock::parse` has expression-valued blocks and
  semicolon/newline statement separation, but no attached statement-block parser for
  `if(...) { ... } elseif(...) { ... } else { ... }`. Runtime already gates statement-marker branches in both
  lifecycle blocks and expression-valued block evaluation through `handle_statement_if_control`, so the Rust
  implementation should parse attached branch bodies into that existing model. Focused parser smoke passed.

- `2026-06-30`: **`.2.2.2` DONE — Perl attached-block if/elseif/else landed.**
  `StatementSplit::Core` now splits a complete attached `if`/`elseif` branch body before same-line attached
  `elseif(...) { ... }` and bare `else { ... }` continuations. Compact
  `if(cond) { ... } elseif(cond2) { ... } else { ... }` now lowers through ActionIR with no raw fallback and
  executes only the selected branch. Existing marker-form `if(cond); ... endif()` and inline-composite
  `if(...)` behavior is unchanged. Frontier moves to `.2.2.3` for Rust parity.

- `2026-06-30`: **`.2.2.2` OWNED BEFORE CODE — Perl attached-block if/elseif/else.**
  TOOLBOX probes and code-read narrowed the Perl reference implementation seam. Newline-separated attached
  branches already lower without raw fallback:
  `if(cond) { ... }\nelseif(cond2) { ... }\nelse { ... }`. Compact same-line chains such as
  `if(cond) { ... } elseif(cond2) { ... } else { ... }` still remain one raw statement because
  `StatementSplit::Core` does not split a complete attached branch before a same-line `elseif`/`else`
  continuation. Scanner/ControlFlow/RewritePipeline already support the individual branch statements; the
  implementation slice must preserve marker-form and inline-composite `if` behavior.

- `2026-06-30`: **`.2.2.1` DONE / `.2.2.2` OWNED NEXT — control-flow keyword surface split.**
  `.2.2` became an active container with concrete implementation leaves. At split time, portable support was the
  statement-marker `if(cond); ... else(); ... endif()` family and inline-composite lazy `if`/`switch`.
  Attached-block `if`, `when`/`otherwise`, statement-level switch blocks, and `while` still needed
  implementation work. The next leaf was `.2.2.2`, the Perl reference attached-block `if/elseif/else` path.

- `2026-06-30`: **`.2.1.4` DONE — expression-valued block early return landed.**
  Perl and Rust now support `return(expr)` anywhere inside an expression-valued block. The block-local return
  yields `expr`, skips later statements in the block, and does not set the surrounding rule return channel.
  Oracle corpus is **35 fixtures**; `.2.1` is closed and frontier moves to `.2.2`.

- `2026-06-30`: **`.2.1.4` OWNED BEFORE CODE — block-local explicit-return follow-through.**
  The leaf now owns the investigation/implementation of true mid-block `return(expr)` inside expression-valued
  blocks, preserving block-local semantics without leaking into the surrounding rule return channel.

- `2026-06-29`: **`.2.1.3` DONE — Rust expression-valued block parity landed.**
  Rust now parses and evaluates core expression-valued blocks with `Expr::BlockValue`, while preserving empty
  and keyed hash literals. Final expressions and final `return(expr)` yield block values; non-final
  `return(expr)` remains deferred to `.2.1.4`. Oracle corpus is **34 fixtures**.

- `2026-06-29`: **`.2.1.3` OWNED BEFORE CODE — Rust expression-valued block parity.**
  Rust parser/runtime seams are recorded before implementation. The leaf owns adding a block-value `Expr` path
  while preserving `{}` / keyed `=>` hash literals, evaluating side-effect statements, and returning the final
  expression or final `return(expr)` payload. True mid-block early return remains `.2.1.4`.

- `2026-06-29`: **`.2.1.2` DONE — Perl-reference core expression-valued blocks landed.**
  Non-empty brace payloads without a top-level `=>` now lower as value blocks in Perl reference return
  payloads, assignment sources, and nested value payloads. The block returns its final expression, or a final
  `return(expr)` payload. `{}` and `{ key => value }` remain hash shape literals; Rust parity remains `.2.1.3`.

- `2026-06-29`: **`.2.1.1` DONE / `.2.1.2` OWNED BEFORE CODE — expression-valued blocks split.**
  KM and TOOLBOX ground truth showed expression-valued blocks are a multi-seam feature, not one safe slice.
  `{}` and `{ key => value }` stay hash shape literals; non-empty brace payloads without top-level `=>` need
  distinct block-expression lowering/evaluation. `.2.1.2` now owns the Perl reference core; Rust parity and
  full block-local early return remain separate children.

- `2026-06-29`: **`.2.1` PICKED / OWNED BEFORE CODE — expression-valued blocks.**
  PNT moved to Round 2 after `.1.6` closed Round 1. This ownership slice records `.2.1` as the active leaf
  before implementation; the next action is KM retrieval plus TOOLBOX/code-read ground truth and a split
  decision if expression-valued blocks are broader than one signoff slice.

- `2026-06-29`: **`.1.6` DONE — array end-mutation methods landed and Round 1 closed.**
  Perl and Rust now accept the statement-level receiver-dot methods `items.push_back(value)`,
  `items.push_front(value)`, `items.pop_back()`, and `items.pop_front()` over named working arrays, including
  `array(items)` / `a(items)` receiver aliases. Push values use mutation-slot value semantics, so bare values
  read scalar working variables; pop methods discard the removed value. Perl reports canonical `ARRAY_MUTATE`
  with zero fallback, Rust executes the same statement forms, phase0 PASS (`990` tests), and the oracle corpus
  is now **33 fixtures**. Frontier -> `.2.1`.

- `2026-06-29`: **`.1.2.3.5.4` DONE — Rust RHS shape target-kind inference parity landed.**
  Rust now mirrors the accepted Perl aggregate target-kind contract for direct RHS shape literals. `items =
  [value]`, `set(items, [value])`, and `set(array(items), [value])` replace the runtime array working variable;
  `meta = { key => value }`, `assign(meta, { key => value })`, and `set(hash(meta), { key => value })` replace
  the runtime hash working variable. Explicit `scalar(payload)` keeps scalar-held shape payload assignment, so
  `set(scalar(payload), [value])` does not initialize array working variable `payload`. Added Rust runtime locks
  and two Perl-oracle fixtures, bringing the corpus oracle to 32 fixtures. Frontier -> `.1.6`.

- `2026-06-29`: **`.1.2.3.5.3` DONE — Rust shape-literal value parity landed.**
  Rust now parses direct array/hash shape literals as value expressions and evaluates them through normal
  expression recursion. Direct shape elements, keys, and values compose with scalar bare reads, primitive
  literals, helper calls, direct access, and nested shapes; quoted hash keys remain fixed field names. Added Rust
  parser/runtime locks and two Perl-oracle fixtures, bringing the corpus oracle to 30 fixtures. This leaf
  deliberately preserves the `.1.2.3.5.4` boundary: `name = [value]` on Rust remains scalar-held shape payload
  assignment until Rust mirrors the Perl aggregate target-kind inference contract. Frontier -> `.1.2.3.5.4`.

- `2026-06-29`: **`.1.2.3.5.2` DONE — Perl RHS shape target-kind inference landed.**
  Direct RHS shape literals infer aggregate targets when the assignment target is bare: `items = [value]` /
  `set(items, [])` assign array working variable `@items`, and `meta = { key => value }` / `set(meta, {})`
  assign hash working variable `%meta`. Non-shape RHS values remain scalar assignment, and explicit
  `scalar(name)` targets preserve scalar-held array/hash payload assignment. Direct shape initializers in
  `declare(array, ...)` and `declare(hash, ...)` now unwrap lowered shape members instead of raw payload text.
  Phase0 PASS (`989` tests); mdBook/KM/live docs updated; full local CI PASS. Frontier -> `.1.2.3.5.3`.

- `2026-06-29`: **`.1.2.3.5.1` DONE — Perl shape-literal value expressions landed.**
  Direct `[]` / `{}` shapes now lower as DSL value expressions on the Perl reference. Non-empty shapes lower
  through accepted value-expression rules, so `[value]` and `{ key => value }` read scalar working variables
  and auto-supply `my $value` / `my $key`; fixed hash field names must be quoted. Target inference was deferred
  to `.1.2.3.5.2`. Phase0 PASS (`988` tests); mdBook updated. Frontier -> `.1.2.3.5.2`.

- `2026-06-29`: **`.1.2.3.5` DONE/SPLIT — RHS-shape/type inference split by mechanism.**
  Ground truth shows raw empty `[]`/`{}` already pass through Perl as scalar value expressions, but do not
  initialize aggregate working variables; non-empty shapes need expression-aware lowering before settled scalar
  reads compose inside shapes; Rust has no bracket/brace value-expression parser. The next children are
  `.1.2.3.5.1` Perl shape-literal values, `.1.2.3.5.2` Perl target-kind inference, then `.1.2.3.5.3` /
  `.1.2.3.5.4` Rust parity. No engine/book behavior changed. Frontier -> `.1.2.3.5.1`.

- `2026-06-29`: **`.1.2.3.4` DONE — Rust scalar bare-read parity landed.**
  Rust now accepts bare scalar working-variable reads in the accepted scalar slots: `return(value)`,
  `set(out, value)`, `name = value`, `items += value`, `meta[key] = value`, and `foo["a"][idx]`. Runtime
  evaluation already read `Expr::Variable` from the scalar working map, so the slice removes parser
  reservations and locks the behavior with Rust parser/runtime tests plus three new oracle fixtures. RHS-shape
  inference stays later and is now tracked as `.1.2.3.5`. Oracle corpus PASS over 28 fixtures; mdBook/KM/local
  gates PASS. Frontier -> `.1.2.3.5`.

- `2026-06-29`: **`.1.2.3.3.3` DONE — Perl direct-access bare path atoms landed.**
  `foo["a"][z]` now lowers like `foo["a"][scalar(z)]` to `$foo->{"a"}->[$z]` and auto-supplies one
  `my $z` per rule when needed. Quoted path segments remain hash keys, numeric/helper segments remain array
  indexes, primitive literals and engine locals are not claimed, `scalaref(...)` keeps its historical path
  semantics, and RHS-shape inference is still later. Phase0 PASS (`1..987`); mdBook updated. Frontier ->
  `.1.2.3.4`.

- `2026-06-29`: **`.1.2.3.3.2` DONE — Perl scalar mutation-slot bare reads landed.**
  `items += VALUE`, `set_key(meta, KEY, VALUE)`, and `meta[KEY] = VALUE` now lower non-reserved bare
  key/RHS identifiers to scalar working-variable reads and auto-supply one `my $NAME` per rule when needed.
  Target inference is unchanged (`@items` / `%meta`), primitive literals stay exact, reserved engine locals
  are not claimed, direct path atoms remain deferred, and all-bare `push(A,B)` remains child-call syntax.
  Phase0 PASS (`1..986`); mdBook updated. Frontier -> `.1.2.3.3.3`.

- `2026-06-29`: **`.1.2.3.3.1` DONE — Perl scalar source-slot bare reads landed.**
  `return(NAME)`, `set(out, NAME)` / `assign(out, NAME)`, and scalar operator `out = NAME` now lower to
  scalar working-variable reads and auto-supply one `my $NAME` per rule when needed. Primitive literals remain
  exact; `trueword` / `undefine` are scalar identifiers in these source slots. Mutation key/RHS slots, direct
  path atoms, generic helper arguments, and all-bare `push(A,B)` remain outside this leaf. Phase0 PASS
  (`1..985`); mdBook updated. Frontier -> `.1.2.3.3.2`.

- `2026-06-29`: **`.1.2.3.3` SPLIT — Perl scalar bare reads divided by lowering seam.**
  TOOLBOX probes and code-read show the remaining scalar Channel 2 work is not one safe code change:
  return/assignment source slots still emit raw barewords; mutation key/RHS slots cross scanner/lowerer guards;
  direct-access bare path atoms have an explicit rejection and need the scalar-index rule stated. Added
  `.1.2.3.3.1` (return/assignment source slots), `.1.2.3.3.2` (mutation key/RHS slots), and `.1.2.3.3.3`
  (direct-access bare path atoms). No engine/book behavior change. Frontier -> `.1.2.3.3.1`.

- `2026-06-29`: **`.1.2.3.2` DONE — Rust aggregate bare value-read parity landed.**
  `array_copy`, `hash_copy`, and `copy` now pass bare aggregate names through the same target resolvers used by
  mutation/typed-wrapper paths, with `copy(NAME)` preserving the array-first rule and `copy(hash(NAME))`
  preserving the explicit hash form. Added 4 Rust integration locks and 4 Perl-oracle fixtures; corpus oracle
  PASS over 25 fixtures; full Rust runtime suite PASS (116 unit tests, 25 oracle fixtures, 54 integration
  tests); clippy EXIT 0 with existing warning baseline. Scalar bare reads, bare key/RHS forms, and bare direct
  access remain deferred. Frontier -> `.1.2.3.3`.

- `2026-06-29`: **`.1.2.3.1` DONE — Perl aggregate bare value-read auto-existence landed.**
  `_collect_auto_working_var_decls` now collects aggregate bare snapshot reads that already lower to sigiled
  aggregate variables: `array_copy(NAME)` and `copy(NAME)` auto-supply `my @NAME`, while `hash_copy(NAME)`
  auto-supplies `my %NAME`. The collector remains literal-masked, reserved-name guarded, and deduped against
  wrapped/declared/mutation paths. Scalar bare reads (`return(NAME)`), bare RHS/key forms, and bare direct-access
  path atoms remain deferred to the scalar Channel 2 leaves. Focused source/runtime/no-leak probe PASS; phase0
  PASS (`1..984`, 17 assertions in the new subtest). Book/KM/live docs updated. Frontier -> `.1.2.3.2`.

- `2026-06-29`: **`.1.2.3` SPLIT — Channel 2 divided by aggregate vs scalar value-read surfaces.**
  TOOLBOX/code-read ground truth shows aggregate bare value reads already lower on Perl but lack safe
  auto-existence, Rust keeps those bare reads out of aggregate-copy resolvers, and scalar-like value reads are
  still a separate Perl bareword/raw-code problem. Added `.1.2.3.1` (Perl aggregate auto-existence),
  `.1.2.3.2` (Rust aggregate parity), `.1.2.3.3` (Perl scalar bare reads), and `.1.2.3.4` (Rust scalar
  parity). No engine/book behavior change. Frontier -> `.1.2.3.1`.

- `2026-06-29`: **`.1.5.5.2` SUPERSEDED/MERGED — bare direct-access path atoms now owned by `.1.2.3`.**
  KM + TOOLBOX reverify after `.1.5.5.1` confirmed `foo["a"][9]["b"][z]` remains raw while
  `return(z)` remains a bareword; Rust keeps the parser rejection lock. Implementing `[z]` locally would
  smuggle Channel 2 into direct access, so the coherent owner is new `.1.2.3` (value-position bare-word reads
  + RHS-shape/type inference). No engine/book behavior change. Frontier -> `.1.2.3`.

- `2026-06-29`: **`.1.5.5.1` DONE — direct nested access with explicit path segments landed.**
  Perl lowers direct mixed access through the same dereference semantics as `scalaref(...)`: quoted string
  segments become hash keys and numeric/helper segments become array indexes. Rust now has a `NestedAccess`
  expression with key/index segments and evaluates it from the scalar-held base payload. One-level
  `name[index]` stays the legacy indexed-variable form, and bare path atoms such as `[z]` remain deferred to
  `.1.5.5.2` / Channel 2. Phase0/Rust/oracle/book/KM/local gates green. Frontier -> `.1.5.5.2`.

- `2026-06-29`: **`.1.5.5` SPLIT — direct nested access divided by the Channel 2 boundary.**
  TOOLBOX probes show direct `foo["a"][9]["b"][scalar(z)]` is not yet a valid lowered value expression:
  it passes through as `foo["a"][9]["b"][$z]` and generated handler compilation fails near `][`.
  Existing-at-the-time `scalaref(foo,{"a"}[9]{"b"}[scalar(z)])` was the working explicit form and lowered to
  `$foo->{"a"}->[9]->{"b"}->[$z]`. Bare segment `z` is still not a variable read, so the full brainstorm
  spelling `foo["a"][9]["b"][z]` is deferred to Channel 2. `.1.5.5.1` now owns explicit-segment direct
  access; `.1.5.5.2` owns bare-segment/Channel-2 coordination. No engine/book behavior change in this split
  slice. Frontier -> `.1.5.5.1`.

- `2026-06-29`: **`.1.5.4` DONE — statement separator contract landed.**
  Newline and semicolon are now the only top-level canonical DSL statement separators. Perl emits generated
  terminators for newline-separated lowered statements, so `set(name,"a")` followed by
  `return(scalar(name))` compiles and runs; semicolon-separated statements preserve the author semicolon.
  Plain same-line whitespace is not a separator: adjacent helper statements on one physical line require `;`
  and otherwise remain explicit blockers, matching Rust parser rejection. Nested semicolons inside expression
  payloads remain protected, and Bootstrap keeps fluent attached-control tails working by inserting internal
  newlines. Verification: phase0 PASS (`1..982`), oracle corpus 20 fixtures, focused Rust parser/runtime tests
  PASS, Rust corpus oracle PASS, full Rust runtime PASS, mdBook/KM updated, and final gates green. Frontier ->
  `.1.5.5`.

- `2026-06-29`: **`.1.5.3` DONE — function-call spacing and mandatory-call-parentheses locks landed.**
  Helper calls keep the uniform `callee(args)` shape. Optional whitespace before `(` is accepted at supported
  statement/value sites including `return (value)`, `set (name,value)`, `cat ("a","b")`, `scalar (name)`,
  operator RHS calls, and hash-index key/RHS calls. No-parenthesis helper spellings remain out of scope:
  `set name,"v"`, `return scalar name`, and `return(cat "a","b")` are not helper calls. Verification: phase0
  PASS (`1..981`), oracle corpus 19 fixtures, focused Rust parser/runtime tests PASS, Rust corpus oracle PASS,
  book/KM updated, and final gates green. Frontier -> `.1.5.4`.

- `2026-06-29`: **`.1.5.2` DONE — primitive literal parity landed on Perl and Rust.**
  Exact primitive literals (`"..."`, `'...'`, numbers, `undef`, `true`, `false`) are now typed value
  expressions in return payloads, mutation RHS positions, hash-index keys/values, and flow predicates.
  Perl lowers `true`/`false` to `JSON::PP` booleans instead of strings, and exact matching keeps
  `trueword`/`undefine` outside the literal path. Scanner/lowerer/legacy child-call guards agree that
  `push(items,false)` is an explicit append while non-literal all-bare forms keep their old child-call
  meaning. Rust gained statement-form `if/elseif/else/endif` gating so `if(false)` skips inactive branch
  statements; the lazy value-form `if(cond,then,else)` helper is unchanged. Verification: phase0 PASS
  (`1..980`), oracle corpus 18 fixtures, focused Rust `.1.5.2` tests PASS, Rust corpus oracle PASS, book/KM
  updated, and final gates green. Frontier -> `.1.5.3`.

- `2026-06-29`: **`.1.5` SPLIT — literal/nested-access/call/semicolon surface decomposed before code.**
  KM retrieval plus TOOLBOX/code-read showed the original leaf crossed four independent seams. Primitive
  literals need parity work because Perl currently returns `true`/`false` as strings while Rust has typed
  booleans. Optional whitespace before `(` works at supported call sites and needs focused locks. Statement
  separators need a dedicated parity leaf: `StatementSplit` detects adjacent newline statements, but Perl
  lowering emits invalid generated code without `;`, while Rust accepts broader whitespace-separated
  statements. Direct any-depth nested access remains open and must coordinate with Channel 2 bare
  value-position reads. `.1.5.1` audit/split is done; frontier -> `.1.5.2`.

- `2026-06-29`: **`.1.3.4.3` DONE — hash-index assignment operator `name[key] = value` landed on Perl and
  Rust.** Top-level `NAME[KEY] = RHS` now lowers/runs like `set_key(NAME, KEY, RHS)` for explicit key/value
  expressions, and bare hash targets auto-exist as per-invocation lexicals on the Perl reference. Rust gained a
  statement-only `AssignHashIndex` AST/execution path and rejects that form in nested value evaluation. The
  accepted boundary is narrow by design: `meta["stage"] = "v"`, `meta[cat("s","tage")] = cat("v","!")`, and
  `meta[scalar(key)] = scalar(value)` work; bare key/RHS identifiers remain pending behind Channel 2; pure
  value-form `set_key(hash_expr, key, value)` remains copy-valued. Verification: TOOLBOX parity probes, phase0
  PASS (`1..979`), oracle corpus regenerated with 16 fixtures, focused Rust core/runtime tests PASS, Rust
  corpus oracle PASS, mdBook/KM updated, and final gates green. `.1.3.4` and `.1.3` are now closed. Frontier →
  `.1.5`.

- `2026-06-29`: **`.1.3.4.2` DONE — array append operator `items += value` landed on Perl and Rust.**
  Top-level `NAME += RHS` now lowers/runs like explicit append forms for explicit RHS expressions, and bare
  array targets auto-exist as per-invocation lexicals on the Perl reference. Rust gained a statement-only
  `AssignArrayAppend` AST/execution path and rejects that form in nested value evaluation. The accepted
  boundary is narrow by design: `items += scalar(value)` works, while `items += value` remains pending behind
  Channel 2; child-call `push(A,B)`, increment-like syntax, scalar assignment, and hash-index assignment remain
  separate. Verification: TOOLBOX parity probes, descriptor/source/runtime probes, phase0 PASS (`1..978`),
  oracle corpus regenerated with 15 fixtures, focused Rust core/runtime tests PASS, Rust corpus oracle PASS,
  mdBook/KM updated, and final gates green. Frontier → `.1.3.4.3`.

- `2026-06-29`: **`.1.3.4.1` DONE — scalar assignment operator `name = value` landed on Perl and Rust.**
  Top-level `NAME = RHS` now lowers/runs like `set(NAME,RHS)` / `assign(NAME,RHS)`, and bare scalar targets
  auto-exist as per-invocation lexicals on the Perl reference. Rust gained a statement-only `AssignScalar`
  AST/execution path and rejects that form in nested value evaluation. The accepted boundary is narrow by
  design: equality, append, hash-index assignment, helper keyword args, nested assignments, and Channel 2
  bare value-position reads remain pending. Verification: TOOLBOX parity probes, descriptor/source/runtime
  probes, phase0 PASS (`1..977`), oracle corpus regenerated with 14 fixtures, focused Rust core/runtime tests
  PASS, full Rust runtime suite PASS, mdBook/KM updated, and final gates green. Frontier → `.1.3.4.2`.

- `2026-06-29`: **`.1.3.4` SPLIT — operator syntax family decomposed into scalar, array, and hash
  implementation leaves.** KM retrieval plus TOOLBOX probes confirmed `name = "ok"`, `items += "a"`, and
  `name["k"] = "v"` still pass through as RAW_PERL blockers on Perl, while the settled function forms
  (`set(...)`, `push(...)` for unambiguous value expressions, `set_key(...)`) lower correctly. A descriptor
  probe on a spec containing all three operators reports three `RAW_PERL` fallback events and three
  language-agnostic blocker statements. Rust code-read shows lifecycle code is parsed as `Stmt { expr }`, with
  no assignment/append/hash-set statement variants, so all operators also need parser/AST/runtime support
  before execution. `.1.3.4` is now a container: `.1.3.4.1` scalar `name = value`, `.1.3.4.2` array
  `items += value`, `.1.3.4.3` hash `name[key] = value`. No engine/book behavior change in this split slice;
  frontier → `.1.3.4.1`.

- `2026-06-29`: **`.1.3.3` DONE — hash function mutation statement `set_key(name,key,value)` landed while
  preserving pure `set_key(hash_expr,key,value)`.** Perl now recognizes top-level `set_key(...)` as an ASSIGN
  statement when the first argument names a hash target, lowering it to direct `$name{key} = value` mutation
  and auto-supplying exactly one preamble `my %name` for bare targets. Rust mirrors this in
  `Engine::execute_block()` by recognizing top-level `set_key(...)` before normal expression evaluation and
  calling `RuntimeContext::set_hash_entry`. Nested/value-form `set_key(hash(...), key, value)` remains the
  pure copy-valued helper and is locked not to mutate the source hash. Added +1 phase0 subtest, 2 Rust
  integration tests, and oracle fixture `terse_1_3_3_set_key_statement_hash`; book + KM updated. Verification:
  phase0 PASS (976); focused Rust `terse_1_3_3` PASS; corpus oracle PASS over 13 fixtures; mdBook build EXIT
  0; Knowledge Map + memory-architecture + doctrine checks OK. Frontier → `.1.3.4` (operator syntax family).

- `2026-06-29`: **`.1.3.2` DONE — array function spelling `push(target,value)` landed without breaking
  child-call `push(...)`.** Selected disambiguation: `push(target,value)` is an explicit-value append when the
  value expression is unambiguous/non-all-bare (`"literal"`, `scalar(value)`, `array(target)` + wrapped value,
  helper values like `cat(...)`, or `call(Child)`). All-bare two-identifier `push(A,B)` keeps the child-call
  meaning (`A` rule into `B` accumulator); append a working-variable value as `push(items, scalar(value))`
  or `push_value(items, scalar(value))` until Channel 2 bare value-position reads land. Perl recognition extended in
  the `push_value` contract/scanner/lowering path, and the auto-array collector now uses a balanced parser scan
  for `push(...)` so nested comma values such as `cat("a","b")` declare exactly one target array. Rust already
  had the `"push_value" | "push"` runtime alias; this slice locks it with a Perl-oracle fixture and integration
  test. Verification: TOOLBOX lowerings prove explicit append vs child-call precedence; descriptor/runtime probe
  returns `["a","b"]` with zero fallback/unresolved; source dump for nested/comma value has one `my @items`;
  phase0 PASS (975); focused Rust test PASS; corpus oracle PASS over 12 fixtures; mdBook build EXIT 0;
  Knowledge Map + memory-architecture checks OK; full local gate EXIT 0. Book/KM/live docs updated. Frontier →
  `.1.3.3` (hash function mutation semantics).

- `2026-06-29`: **`.1.3` SPLIT — mutation surface separated by mechanism; `.1.3.1` scalar function
  audit done; frontier → `.1.3.2`.** Knowledge Map retrieval first found the `.1.2` bare-target and
  accumulator-convention constraints. TOOLBOX probes then showed the leaf cannot be one implementation slice:
  `set(name,"ok")` already equals `assign(name,"ok")` and runs; `push_value(items,"a")` lowers/runs, but
  requested `push(items,"a")` passes through as raw Perl and conflicts with the existing
  `push(Rule[,target[,index]])` child-call convention; `return(set_key(name,"k","v"))` works as a pure Perl
  hash value but `set_key(name,...)` is not a standalone mutation statement and Rust only updates when arg0 is
  already a hash; `name = "ok"`, `items += "a"`, and `name["k"] = "v"` pass through as invalid/raw Perl, and
  Rust has no assignment statement AST. Created KM [[terse-mutation-surface-ground-truth]]; no engine/book
  change.

- `2026-06-29`: **`.1.4.2` DONE — Rust lockstep parity for terse helper renames.** `Engine::call_helper()`
  now recognizes `set` through the `assign` arm and `cat` through the `concat` arm, and adds a dedicated
  `copy` arm that clones array/hash values or resolves wrapped array/hash targets by kind. Added
  `resolve_hash_target` and one-bare-variable `hash`/`h` target reads so `copy(h(m))` matches
  `hash_copy(h(m))` without broadening deferred Channel 2 bare value-position reads. Locked with 2 Perl-oracle
  fixtures (`terse_1_4_2_set_cat_copy_array`, `terse_1_4_2_copy_hash_symbol_empty`) and 3 integration tests
  (`set`+`cat`+`copy(array)`, hash target/hash value copy, per-parse bare `set` target). Verification:
  generator `perl -c` OK; oracle regeneration OK; focused `terse_1_4_2` PASS; corpus oracle PASS (11
  fixtures); full Rust runtime suite PASS (116 unit + 36 integration + oracle harness); `cargo clippy` zero-new
  against the existing 13-warning baseline; phase0 **975 green**; full local gate EXIT 0. No book change
  because `.1.4.1` already documented the variant-neutral helper contract. **`.1.4` container done; next
  frontier: `.1.3`** (mutation surface, scope/split first).

- `2026-06-24`: **`.1.4.1` DONE — Perl reference: terse helper renames `set`/`cat`/`copy` lower
  identically to `assign`/`concat`/`array_copy`+`hash_copy`.** PNT (user-directed loop, fresh session)
  implemented the first `.1.4` child. **TOOLBOX-first** `call_spec_handler_subst` ground truth
  (dump-don't-guess; `perl -Iperl` confirmed `perl/LinkedSpec.pm`) re-verified the gap, then implemented the
  three shapes the split pass prescribed **plus every other site each canonical name is recognized**, so the
  aliases are true byte-identical aliases everywhere: (i) `cat`→`concat` + `set`→`assign` in
  `_normalize_method_name` (`ActionIR/MethodExpr.pm`); (ii) `set` statement-level recognition extended
  (`\bassign\s*\(`→`\b(?:assign|set)\s*\(`) at the `assign_value` contract (`Contracts.pm`), its IR-event
  scanner (`Scanner/PrimitivePipelineRules.pm`), and the bare-arg auto-`my` collector (`RuleIR/EmitContext.pm`,
  so bare `set` auto-exists like `assign` — `.1.2.1` parity); (iii) a dedicated array-then-hash `copy` dispatch
  in `MethodLowering._lower_method_value_expr`, plus `copy` added to the declare-init recognizers
  (`DeclareMethod` 136/163), the return-payload guard+rewriter lists (`MethodLowering` 1650/1658), the FlowExpr
  value-expr prefix list (assignment-source path), the bootstrap general-payload gate (`Core.pm`, `cat`), and
  the four `looks_like_{array,hash}_value_expr` recognizers (so `copy` stays first-class in numeric-reducer /
  `coalesce` array-vs-hash type inference, resolving kind array-first). **Proof:** `call_spec_handler_subst`
  byte-equal for the 4 headline + 11 composed forms (assignment source scalar/array/hash, push value, nested
  return payload, `num_sum`/`num_avg`/`coalesce` over `copy`); `set` produces the same `ASSIGN` canonical
  ActionIR node as `assign`; a real terse spec (`set`+`cat`+`copy`) runs end-to-end **byte-identical** to its
  canonical twin (`["a!","b!","c!"]`, stable on re-run); **all 20 shipped specs byte-identical (0 diff)** — every
  alias add is guarded by the new spelling, which no shipped spec uses. **+4 phase0 subtests / 31 assertions**
  (`spec_format_terse_1_4_1_*`): **phase0 971→975 green**; `bash tools/run_ci_local.sh` **EXIT 0** ("Result:
  PASS", 975); ratio 1.0000; `perl -c` clean on all 8 edited modules; `mdbook build` EXIT 0. **Book (3):**
  `appendix/helper-contract-catalog.md` (per-helper Terse-spelling lines + a new "Terse Helper Renames"
  subsection), `dsl/value-container-flow-helper-reference.md`, `dsl/declaration-helper-reference.md` — taught
  the renames as canonical with the old names as deprecated (not-yet-retired) aliases. KM card
  [[terse-helper-rename-lowering-sites]] updated (`.1.4.1` landed; full site list; reverify now proves parity;
  map regenerated). Frontier → `.1.4.2` (Rust `Engine::call_helper()` lockstep parity). The `.1.4.1` change is
  "landed against the universal contract" only once `.1.4.2` closes.
- `2026-06-24`: **`.1.4` SPLIT → `.1.4.1` (Perl reference) + `.1.4.2` (Rust parity).** PNT (user-directed
  loop, fresh session) picked `.1.4` (helper renames `assign`→`set`, `concat`→`cat`,
  `array_copy`/`hash_copy`→`copy`, the next terse-format implementation leaf) and, instead of coding, split
  it after a **TOOLBOX-first `call_spec_handler_subst` ground-truth pass** (dump-don't-guess; `perl -Iperl`
  confirmed it loads `perl/LinkedSpec.pm` over the stale `PERL5LIB`). The probes proved the three terse
  spellings are all currently **UNRECOGNIZED**: `set(scalar(x),1)`→`set(scalar(x), 1)` (vs `assign`→`$x = 1`),
  `cat("a","b")`→`cat("a","b")` (vs `concat`→the concat do-block), `copy(a(items))`→`copy([items])` partial /
  `copy(h(m))`→`copy(h(m))` (vs `array_copy`→`[@items]` / `hash_copy`→`{%m}`). The change has **three distinct
  implementation shapes** spanning **two variants with separable ownership** (Perl `ActionIR/*` + phase0 +
  book vs Rust `engine.rs` + oracle + cargo — COMMIT.md forbids bundling), so per the splitting rule
  (mirroring `.1.1`→`.1.1.1`/`.1.1.2` and `.1.2`→`.1.2.1`/`.1.2.2`, ADR 0006) `.1.4` became a container with
  `.1.4.1` (Perl reference) + `.1.4.2` (Rust lockstep parity). **Ground truth (own probes + code read):**
  `cat`→`concat` is a pure rename → `_normalize_method_name` (`ActionIR/MethodExpr.pm:19-26`, applied
  pre-lowering, same seam as `s`/`a`/`h`); `set`→`assign` is **statement-level** (`ActionIR/Contracts.pm:1749/1753`
  `\bassign\s*\(` + `DeclareMethod` + `MethodLowering._lower_assign_statement`) and is NOT reached by
  `_normalize_method_name` alone (so `.1.4.1` extends the statement-level recognition); `copy` is **not** a
  pure rename — it unifies `array_copy`/`hash_copy` and needs a dedicated dispatch in
  `MethodLowering._lower_method_value_expr` resolving array-then-hash symbol kind (`[@name]` else `{%name}`).
  Rust: all four canonical helpers live in one `Engine::call_helper()` match
  (`rust/linkedspec-runtime/src/engine.rs`: `assign`@711, `array_copy`@735, `concat`@820, `hash_copy`@1833;
  aliases = pipe arms); `.1.4.2` pipes `set`/`cat` and adds a separate value-type-dispatching `"copy"` arm.
  Direction per ADR 0007: new terse names canonical, old names deprecated aliases that lower identically
  (retirement is a later explicit leaf); the 20 shipped specs (old names) must stay byte-identical. Recorded
  the ground truth in Decisions + KM card [[terse-helper-rename-lowering-sites]] (map regenerated). Frontier
  → `.1.4.1`. **DOCS/TREE/KM only — no engine or book change** in this split slice; baseline doctrine + KM
  gates green. Next PNT: implement `.1.4.1` (Perl reference — `cat`/`set`/`copy` recognition; signoff-critical
  codegen; dump-don't-guess, all-20-specs byte-identical proof).
- `2026-06-24`: **`.1.2.2` DONE — Rust lockstep parity for `.1.2.1`; it REQUIRED a Rust engine change
  (unlike `.1.1.2`).** PNT (user-directed, single-leaf cadence). **TOOLBOX-first** throwaway Rust integration
  probe (parse→validate→compile→execute, dump-don't-guess) on bare-vs-wrapped specs: although the
  interpreter's per-parse `RuntimeContext` HashMaps auto-vivify (the `.1.1.2` finding), a **bare** arg-position
  target was NOT reaching the working var — `resolve_scalar_target`/`resolve_array_target`
  (`rust/linkedspec-runtime/src/engine.rs`) only extracted the name from a WRAPPED `scalar(VAR)`/`array(VAR)`
  Call; a bare `Expr::Variable` fell through to `val.to_str()` (evaluated value → `""`). Probe BEFORE: bare
  `assign(v,"ok")`→`[null]`, bare `push_value(items,..)`→`[[]]` vs wrapped `["ok"]`/`[["a","b"]]` — a genuine
  divergence from the Perl `.1.2.1` reference. **Fix:** both resolvers now also accept a bare `Expr::Variable`
  target and return its name (mirroring Perl's `^(\w+)$` fallback in `ValueExpr::_extract_*_symbol_name`); the
  HashMap then auto-vivifies it (no `declare`; fresh ctx per `execute` ⇒ no leak). Scoped to Channel-1 target
  positions via an `allow_bare` flag — `true` for `push_value`/`push_nonempty`, `false` for the value-position
  reads `array_copy`/`hash_copy` (bare value-position reads are Channel 2, not this leaf). Probe AFTER: bare ==
  wrapped (`["ok"]`, `[["a","b"]]`). **Locked:** 2 oracle fixtures `autoexist_{scalar,array}_bare_arg`
  (`tools/gen_oracle_corpus.pl`, regenerated — existing 7 byte-identical; `corpus_oracle` checks Rust == the
  Perl reference) + 4 `terse_1_2_2_*` integration tests (scalar/array/push_nonempty value anchors,
  bare==wrapped==declare convergence, per-parse no-leak via same-engine re-run). **cargo 248→252 green**, 9/9
  oracle PASS, `cargo clippy` zero-new (engine.rs 11 baseline — my added `if allow_bare` nest flattened to a
  tuple `if let`; test file adds 0), `perl -c gen_oracle_corpus.pl` OK; **phase0 971 green** (Perl untouched),
  `bash tools/run_ci_local.sh` **EXIT 0**; no book change (variant-agnostic — `.1.2.1` already taught the
  contract; Rust now conforms). KM card [[terse-bare-working-vars-engine-gaps]] updated (Rust parity + the
  engine-change contrast with `.1.1.2`). **`.1.2` Channel 1 complete on BOTH variants;** `.1.2` stays `active`
  (Channel 2 `.1.2.3`+ pending, added once `.1.5` is designed). Frontier → `.1.4` (helper renames). Recursive/REP
  idiom stays deferred to `RUST-PARITY`.
- `2026-06-24`: **`.1.2.1` DONE — Perl arg-position bare working-variable auto-existence (Channel 1).**
  PNT (user-directed, fresh session) implemented the first `.1.2` child. **TOOLBOX-first
  `dump_parser_source` ground truth** (scratchpad `probe_terse_1_2_1.pl`, isolated bare forms,
  dump-don't-guess; `perl -Iperl` confirmed `perl/LinkedSpec.pm` loads over the stale `PERL5LIB`) proved a
  bare `assign(count,…)` lowers to `$count = …` and a bare `push_value(items,…)`/`push_nonempty` to
  `push @items` (`_lower_assign_statement` extracts scalar first; the push family is array) — each via the
  `^(\w+)$` fallback in `ValueExpr::_extract_*_symbol_name` — but neither got a preamble `my` (the `.1.1.1`
  collector matched only WRAPPED forms), leaving a leaky package global. **Fix:** extended
  `RuleIR::EmitContext::_collect_auto_working_var_decls` with a second collection pass (refactored the
  per-ref add into a shared `$record` closure) that scans the literal-masked RAW blocks for a bare working
  var in a type-implying *first-arg* position and records it with the **position-implied** sigil —
  `assign`→`$`, `push_value`/`push_nonempty`→`@`. The `\s*,` after the bare name means a WRAPPED target
  (name then `(`) is NOT matched by the bare pattern — it stays on the wrapped path; both dedup (by
  sigil+name, vs the `@<label>` accumulator + any same-sigil `my`) to one `my`. **Proof:** generated source
  for all 20 shipped specs, mine-vs-stashed, diffed = **0 diff** (the corpus has no un-wrapped arg-position
  targets — cleaner than `.1.1.1`); isolated bare probes now emit the `my` (and
  `assign(pair, set_key(hash(pair),…))` correctly declares BOTH `my %pair` (wrapped) and `my $pair` (the
  bare assign target — a separate scalar holding the hashref, previously leaky)). **+3 phase0 subtests /
  17 assertions** (`spec_format_terse_1_2_1_*`: bare scalar+array+push_nonempty auto-exist with the `my` in
  the preamble before `while(1)`; deferred `.push(target)` boundary; dedup vs wrapped/declare = single `my`;
  integrated per-invocation no-leak run-twice): **phase0 968→971 green**; `bash tools/run_ci_local.sh`
  **EXIT 0** ("[ci] local CI gate passed", 971); ratio 1.0000; `mdbook build` EXIT 0. **Book (3):**
  `dsl/declaration-helper-reference.md` (taught wrapper-optional-in-arg-position + corrected the outdated
  "argument position is a later step" note), `appendix/helper-contract-catalog.md` §1 + the
  `assign`/`push_value`/`push_nonempty` entries, and `dsl/value-container-flow-helper-reference.md`.
  **Scope (signoff):** Channel 1 covers the unambiguous first-arg value-helper positions only; the
  child-append `push(Rule[, target])` / fluent `.push(target)` target (first arg is a rule name —
  ambiguous) and the bare HASH target (no clean arg-position trigger — `set_key(name,…)` is a value-position
  read) are Channel 2, explicitly deferred. KM [[terse-bare-working-vars-engine-gaps]] updated (Channel 1
  closed). Frontier → `.1.2.2` (Rust lockstep parity — likely holds by architecture; assess + lock next).
- `2026-06-24`: **`.1.2` SPLIT → `.1.2.1` (Perl, Channel 1) + `.1.2.2` (Rust parity).** PNT (user-directed
  loop, fresh session) picked `.1.2` (remove container wrappers + type inference, the next terse-format
  implementation leaf) and, instead of coding, split it after a **TOOLBOX-first `dump_parser_source`
  ground-truth pass** (dump-don't-guess; `perl -Iperl` confirmed it loads `perl/LinkedSpec.pm` over the
  stale `PERL5LIB`). The dumps proved a **bare** (un-wrapped) working variable has two distinct,
  separately-sized behaviors → two inference channels: **Channel 1 (arg position)** — a bare name already
  lowers to the correctly-sigil'd variable (`assign(count,v)`→`$count = v`; `push_value(items,..)`→
  `push @items, ..`) BUT gets **no auto-`my`** (the `.1.1.1` collector matches only WRAPPED
  `scalar/array/hash(NAME)`), so it is a **leaky package global** — the exact `.1.1.1` hazard, still open
  for bare forms; and **Channel 2 (value position)** — a bare word is **not** recognized as a variable
  read (`return(count)`→ bareword `return count ;`, not `$count`), which plus RHS-shape inference
  (`[]`→array, `{}`→hash) needs var/call/literal disambiguation and couples with `.1.5` literals.
  Per the splitting rule (Perl reference + lockstep Rust parity are separable, ADR 0006 — mirroring
  `.1.1`→`.1.1.1`/`.1.1.2`), made `.1.2` a container and added `.1.2.1` (Perl, Channel 1: arg-position
  bare working-var auto-existence — the self-contained, lowest-risk first slice that directly extends the
  `.1.1.1` collector and closes the leaky-global gap) + `.1.2.2` (Rust parity). Channel 2 leaves
  (`.1.2.3`+) are **not** pre-published — they are added once `.1.2.1` lands and `.1.5` literal syntax is
  designed (avoiding vague placeholders). Wrappers stay accepted aliases during migration (gradual, ADR
  0007); the shipped corpus uses them pervasively (declare 87 / assign 103 / scalar 133 / array 134 / hash
  36), so they must keep compiling byte-identically. Recorded the ground truth in Decisions + KM card
  [[terse-bare-working-vars-engine-gaps]] (map regenerated). Frontier → `.1.2.1`. **DOCS/TREE/KM only —
  no engine or book change** in this split slice; baseline gates green. Next PNT: implement `.1.2.1`
  (signoff-critical Perl codegen — a fresh session is reasonable; bootstrap, dump-don't-guess).
- `2026-06-24`: **`.1.1.2` DONE — Rust lockstep parity for auto-existing variables (no engine change).**
  PNT (user-directed loop, fresh session) assessed the Rust parity for `.1.1.1` per the leaf's
  blocked-vs-doable instruction. **TOOLBOX-first ground truth** (throwaway Rust integration probe +
  `perl -Iperl` `LinkedSpec::Get` probe on the same minimal grammars; read `rust/linkedspec-runtime/src/
  {runtime,engine}.rs`): the Rust variant is an **interpreter** (no codegen/`eval`), so working variables
  live in per-parse `RuntimeContext` HashMaps (`scalars`/`arrays`/`hashes`) that **auto-vivify** on write
  and read as `Undef`/empty when absent, and `Engine::execute` builds a **fresh `RuntimeContext` per
  call**. So working variables **already auto-exist** with no `declare`, and a value cannot leak across
  parses — the leaky-package-global hazard the Perl `.1.1.1` change fixed (non-strict generated handlers)
  simply does not exist in Rust. **Outcome: DOABLE, no engine change** — parity holds by architecture; the
  leaf lands as lockstep regression tests + docs. **Cross-variant proof** (divergence-free edge-action
  form = the `.7.1` oracle proof class; recursive/REP forms are blocked by the separate `RUST-PARITY` gap,
  verified returning `[null]`/`[[]]`): scalar no-declare Perl `"ok"`/Rust `["ok"]`; array no-declare Perl
  `["a","b"]`/Rust `[["a","b"]]`; declare twins identical; `array(undef)` Perl `[null]`/Rust `[[null]]` —
  Rust == Perl reference wrapped one level. **Locked:** 5 oracle fixtures `autoexist_{scalar,array}_
  {no_declare,declare}` + `autoexist_undef_literal` (added to `tools/gen_oracle_corpus.pl`, regenerated;
  existing 2 byte-identical) + 4 `terse_1_1_2_*` integration tests (value anchors, declare/no-declare
  convergence, per-parse no-leak via same-engine re-run). **cargo test 244→248 green**; all **7 oracle
  fixtures PASS**; `cargo clippy` zero-new source/test warnings; `perl -c tools/gen_oracle_corpus.pl` OK;
  **phase0 968 green** (Perl untouched), `bash tools/run_ci_local.sh` **EXIT 0**; `mdbook build` EXIT 0
  (no book change — variant-agnostic, `.1.1.1` already taught the contract; Rust now conforms). KM card
  [[rust-working-vars-auto-vivify]] (map regenerated). **`.1.1` container done; `.1.1.1` is now landed
  against the universal contract (ADR 0006/0007). Next: `.1.2`** (remove wrappers + type inference).
- `2026-06-24`: **`.1.1.1` DONE — Perl auto-existing working variables.** PNT (user-directed loop start)
  implemented the first terse-format engine leaf. TOOLBOX-first `dump_parser_source` ground truth confirmed
  the no-declare hazard (bare leaky-global `$count`/`@items`) and the fix shape. Added a rule-level
  collector `RuleIR::EmitContext::_collect_auto_working_var_decls` (+ literal-masker
  `_mask_action_code_literals`): scans the RAW pre-lowering blocks (NOT regex slots) for
  single-bare-identifier typed-wrapper refs, sigil-from-wrapper, dedup vs `@<label>` accumulator + any
  same-sigil `my` already in the lowered code, excludes DSL literals (`undef`/`true`/`false`) + engine
  handler locals; returned as `auto_var_decls`, injected into the preamble by
  `SpecEntry::compile_spec_entry` (empty ⇒ byte-identical). **Proof:** all-20-specs source diff (mine vs
  git-stashed) = **19/20 byte-identical**; only `tkgui` differs (+1 legit `my $subgui_name;` for its genuinely
  undeclared working scalar) with **identical parse output before/after** (incl. a 2nd same-process parse — no
  leak). A Lispish `a(undef)` false positive was caught by the diff and fixed (reserved-literal exclusion).
  **+3 phase0 locks** (no-declare scalar+array work + no cross-parse leak; declare-path single-`my`;
  reserved-literal not auto-declared): **phase0 965→968 green**; `bash tools/run_ci_local.sh` **EXIT 0**;
  ratio 1.0000; `mdbook build` EXIT 0. Book taught auto-existence (declare optional) in 3 pages; examples not
  re-authored (later gradual leaf). KM card [[working-vars-no-strict-need-my-lexical]] updated to
  status-implemented. **Next: `.1.1.2`** (Rust lockstep parity — now PNT-eligible to assess; ADR 0007/0006).
- `2026-06-23`: **`.1.1` SPLIT → `.1.1.1` (Perl reference) + `.1.1.2` (Rust lockstep parity).** PNT picked
  `.1.1` (auto-existing variables, first terse-format implementation leaf) and a `dump_parser_source`
  ground-truth pass (TOOLBOX-first; scratchpad `probe_autovar*.pl`) showed it is too broad for one signoff
  slice: it is a multi-module Perl reference-engine change (a rule-level variable-collection pass feeding the
  handler preamble) **plus** a lockstep Rust parity obligation (ADR `0006`). Per the PNT splitting rule, split
  `.1.1` into `.1.1.1` (Perl) + `.1.1.2` (Rust), made `.1.1` a container, moved the frontier to `.1.1.1`, and
  recorded the verified design (one-scope handler / non-strict-handler leaky-global hazard / preamble-`my`
  injection / wrapper→sigil / dedup vs accumulator+declare / ratio-1.0000) in Decisions + KM card
  [[working-vars-no-strict-need-my-lexical]] (map regenerated). Docs/tree/KM-only — **no engine or book change**
  in this slice. Next PNT: implement `.1.1.1`.
- `2026-06-22`: **Implementation gate CLEARED — `.1.x`+ now PNT-eligible.** The usable-`t/phase0_regression.t`
  gate on the implementation leaves is satisfied: `LEGACY-VHDL-RETIRE` cleared `RTLUTILS-REGEX-HANG`,
  `NONCORE-QUARANTINE` relocated the rest of the domain island (excising the second back-half hang's smoke),
  and `PHASE0-BACKHALF-TRIAGE` resolved the 173 back-half failures + the corpus/dark-tail tail → phase0 is
  **960/960 green** and `bash tools/run_ci_local.sh` exits **0**. Migration policy was already resolved
  (gradual-alias, ADR `0007`), so no remaining decision blocks `.1.1`. Status reconciliation recorded
  cross-tree in `PHASE0-BACKHALF-TRIAGE.5.3.2.1`; this tree's design + leaves are unchanged (no engine/book
  change here — the implementation leaves are a future PNT selection).
- `2026-06-18`: **Activated + ratified (`.0` done).** The user activated the tree during
  `SPEC-LANG-REFERENCE.10.5.4` (AskUserQuestion: "Activate SPEC-FORMAT-TERSE now") and reinforced the
  terse semantics over several messages (`assign`→`=`/`set`; no-sigil typed bare identifiers; type
  inference at init / by arg position; `copy()` unifies array+hash; arrays/hashes/numbers/strings have
  methods; everything-is-an-expression). Wrote ADR `0007` ratifying Rounds 1–3 + the gradual-alias
  migration policy + lockstep-all-variants + the user-sanctioned reference-touching exception + the
  regression-gate requirement; indexed it. Status `proposed`→`active`. The `SPEC-LANG-REFERENCE` book
  scorch is paused for this pivot. Implementation leaves `.1.x`+ remain gated by `RTLUTILS-REGEX-HANG`
  + a user confirmation of the migration policy — both surfaced to the user. No engine/book change.
- `2026-06-16`: Created tree; transcribed the 2026-06-15 brainstorm (Rounds 1–3) into pickable leaves;
  parked as `proposed` pending the RTLUtils hang fix.
