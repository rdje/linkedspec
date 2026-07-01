# PERL-ACTIONIR-AST-MIGRATION — Perl text-to-AST migration

- Status: `active` (created 2026-07-01 by explicit user directive)
- Roadmap lane: `Overall roadmap — compiler architecture / variant contract`
- Owner: repo-local workflow

## Goal

Move the Perl reference backend away from ActionIR text-to-text lowering and toward the
same text-to-AST doctrine already used by the Rust expression runtime. The user-facing
`.spec` contract is variant-neutral: every backend must parse `.spec` helper/action
language text into typed AST/IR before lowering or execution. Broad regex macro rewriting
and host-language fallback are migration debt.

## Acceptance Criteria

- The doctrine is recorded in ADR `0011` and the variant-neutral mdBook.
- Perl migration is split before code into narrow leaves; no leaf may replace broad
  lowering behavior without focused probes, phase0 locks, and corpus/oracle checks where
  applicable.
- The first code slice introduces an AST parser seam behind existing behavior before any
  broad lowering path is replaced.
- Text-to-text fallback for supported helper/value surfaces is retired family by family,
  with diagnostics replacing accidental generated-host-language calls.
- The user-defined function implementation must consume this AST path rather than adding
  new textual macro expansion.

## Task Tree

- ID: `PERL-ACTIONIR-AST-MIGRATION`
  Status: `active`
  Goal: Migrate Perl ActionIR helper/action handling from text-to-text lowering to typed
    text-to-AST parsing and lowering.
  Children: `.0`, `.1`, `.2`, `.3`, `.4`, `.5`

- ID: `PERL-ACTIONIR-AST-MIGRATION.0`
  Status: `done` (2026-07-01)
  Goal: Adopt text-to-AST as the cross-variant doctrine before code.
  Acceptance: Record an ADR; update the variant-neutral mdBook; add a Knowledge Map fact;
    update live docs and frontier state. No parser/compiler/runtime code changes.
  Verification: **PASS 2026-07-01.** Wrote ADR `0011`, added Knowledge Map fact
    `text-to-ast-backend-doctrine`, updated the variant-neutral mdBook backend handoff,
    compiler pipeline, formal grammar, and architecture chapters, and synced roadmap,
    task-tree index, and live docs. Regenerated `KNOWLEDGE_MAP.md`. Checks passed:
    `bash scripts/check_memory_architecture.sh`, `bash knowledge-map/scripts/check_knowledge_map.sh`,
    `bash scripts/check_doctrines.sh`, `mdbook build docs/linkedspec-book`, and `git diff --check`.
  Commit: `PERL-ACTIONIR-AST-MIGRATION.0 - adopt text-to-AST doctrine`

- ID: `PERL-ACTIONIR-AST-MIGRATION.1`
  Status: `done` (2026-07-01)
  Goal: Inventory Perl text-to-text ActionIR lowering sites and define the AST node set.
  Acceptance: Enumerate current string-lowering entry points in `ActionIR::*` and
    `RuleIR::EmitContext`; map each supported expression/statement/control shape to an
    AST node; identify behavior-preserving order of replacement. No behavior change.
  Verification: **PASS 2026-07-01.** Inventoried the raw-string boundaries in
    `StatementSplit`, `MethodExpr`, scanner rule families, `Contracts`, `CanonicalEvents`,
    `RewritePipeline`, `MethodLowering`, and `RuleIR::EmitContext`; defined the
    Rust-aligned AST node set and replacement order; added Knowledge Map fact
    `perl-actionir-text-to-ast-inventory`; regenerated `KNOWLEDGE_MAP.md`. Checks passed:
    stale-frontier search, `bash scripts/check_memory_architecture.sh`,
    `bash knowledge-map/scripts/check_knowledge_map.sh`, `bash scripts/check_doctrines.sh`,
    `mdbook build docs/linkedspec-book`, and `git diff --check`.
  Commit: `PERL-ACTIONIR-AST-MIGRATION.1 - inventory Perl ActionIR text lowering`

- ID: `PERL-ACTIONIR-AST-MIGRATION.2`
  Status: `done` (2026-07-01)
  Goal: Introduce a Perl ActionIR AST parser seam behind existing behavior.
  Acceptance: Add focused parser modules/tests for calls, literals, variables, direct
    access, shape literals, blocks, statements, and receiver-dot chains. The seam must
    preserve existing generated behavior until consumers switch over.
  Verification: **PASS 2026-07-01.** Added `LinkedSpec::ActionIR::AST`,
    `LinkedSpec::ActionIR::AST::Parser`, and `t/actionir_ast_parser.t`; wired the focused
    parser test into `tools/run_ci_local.sh`; updated mdBook architecture/status text and
    Knowledge Map fact `perl-actionir-ast-parser-seam`; regenerated `KNOWLEDGE_MAP.md`.
    Checks passed: `perl -Iperl -c perl/LinkedSpec/ActionIR/AST.pm`,
    `perl -Iperl -c perl/LinkedSpec/ActionIR/AST/Parser.pm`,
    `perl -Iperl -c t/actionir_ast_parser.t`, `prove -Iperl t/actionir_ast_parser.t`,
    `prove -q -Iperl t/phase0_regression.t` (1002 tests),
    `bash scripts/check_memory_architecture.sh`,
    `bash knowledge-map/scripts/check_knowledge_map.sh`, `bash scripts/check_doctrines.sh`,
    `mdbook build docs/linkedspec-book`, `git diff --check`,
    `bash -n tools/run_ci_local.sh`, and `bash tools/run_ci_local.sh`.
  Commit: `PERL-ACTIONIR-AST-MIGRATION.2 - add Perl ActionIR AST parser seam`

- ID: `PERL-ACTIONIR-AST-MIGRATION.3`
  Status: `done` (2026-07-01)
  Goal: Replace value-expression and receiver-chain lowering with AST lowering.
  Acceptance: Value calls, helper composition, direct access, shape literals, blocks, and
    receiver-dot chains lower from typed AST nodes, not source-text rescans. Existing phase0
    and terse oracle fixtures remain green; accidental host-call leakage becomes a
    LinkedSpec diagnostic.
  Children: `.3.1`, `.3.2`, `.3.3`, `.3.4`
  Verification: **PASS 2026-07-01.** Split the broad value/receiver migration into
    focused child leaves before code, then completed `.3.1` non-call value AST lowering,
    `.3.2.1`/`.3.2.2` helper-call AST lowering, `.3.2.3` covered-helper diagnostics,
    `.3.3` receiver-chain AST lowering, and `.3.4` return-payload AST traversal.
  Commit: `PERL-ACTIONIR-AST-MIGRATION.3 - split AST value lowering`

- ID: `PERL-ACTIONIR-AST-MIGRATION.3.1`
  Status: `done` (2026-07-01)
  Goal: Introduce the AST value-lowering dispatcher for non-call value nodes.
  Acceptance: `_lower_method_value_expr(...)` parses with `LinkedSpec::ActionIR::AST` and
    dispatches primitive literals, bare scalar reads, direct indexed/nested access, array
    and hash shape literals, and block values from typed nodes. Existing helper-call
    behavior may remain behind an explicit compatibility bridge for this leaf, but these
    supported non-call nodes must no longer depend on fresh source-text rescans.
  Verification: **PASS 2026-07-01.** Added a `MethodLowering` AST dispatcher for
    primitive literals, scoped bare scalar reads, direct indexed/nested access with the
    legacy reserved-segment guard, array/hash shape literals, and block values. Helper
    calls and statement-level side effects remain behind explicit compatibility bridges.
    Added focused `t/actionir_ast_parser.t` coverage proving AST parser use and preserved
    generated output. Checks passed: `perl -Iperl -c perl/LinkedSpec/ActionIR/MethodLowering.pm`,
    `perl -Iperl -c t/actionir_ast_parser.t`, `prove -Iperl t/actionir_ast_parser.t`,
    targeted lowering probes for shapes, blocks, direct access, scalaref key paths, and
    receiver-chain compatibility, and `prove -q -Iperl t/phase0_regression.t` (1002 tests).
  Commit: `PERL-ACTIONIR-AST-MIGRATION.3.1 - lower non-call values from AST`

- ID: `PERL-ACTIONIR-AST-MIGRATION.3.2`
  Status: `split` (2026-07-01)
  Goal: Lower helper-call value composition from AST call nodes.
  Acceptance: Supported value helper calls recursively consume AST argument nodes for
    helper composition and aggregate wrappers. Text fallback is limited to explicitly
    unsupported call families with diagnostics/telemetry, not silent host-call leakage.
  Children: `.3.2.1`, `.3.2.2`, `.3.2.3`
  Verification: **PASS 2026-07-01 (split only).** Split helper-call AST lowering by
    argument-slot risk: value-only helper families first, aggregate/symbol-slot helpers
    second, and diagnostics/host-call leakage retirement third.
  Commit: `PERL-ACTIONIR-AST-MIGRATION.3.2 - split AST helper-call lowering`

- ID: `PERL-ACTIONIR-AST-MIGRATION.3.2.1`
  Status: `done` (2026-07-01)
  Goal: Lower value-only helper-call composition from AST call nodes.
  Acceptance: Scalar normalization, string predicate, coalesce/concat, and numeric helper
    families consume AST argument nodes recursively before invoking the existing Perl
    helper lowering. Helpers with symbol/aggregate-special slots stay on compatibility
    paths. Focused AST-call composition tests and phase0 remain green.
  Verification: **PASS 2026-07-01.** Added a `MethodLowering` AST call dispatcher for
    value-only helper families. Covered call nodes recursively materialize argument ASTs
    before entering the existing Perl helper catalog through the compatibility bridge:
    scalar normalization, string predicates/composition, coalesce/concat, scalar-argument
    numeric helpers, and explicit `num_*` comparisons. Deprecated wrapper aliases
    (`scalar(...)`/`array(...)`/`hash(...)`), aggregate-wrapper, collection, reducer,
    hash, symbol-slot, and receiver-chain helpers remain compatibility paths and are not
    the canonical destination syntax.
    Focused tests prove fake call-node source text is not reused for covered calls.
  Commit: `PERL-ACTIONIR-AST-MIGRATION.3.2.1 - lower value-only helper calls from AST`

- ID: `PERL-ACTIONIR-AST-MIGRATION.3.2.2`
  Status: `done` (2026-07-01)
  Goal: Lower aggregate-wrapper and collection helper calls from AST call nodes.
  Acceptance: Legacy wrapper calls `scalar`, `array`, and `hash` stay classified as
    deprecated compatibility aliases per ADR `0007`, not canonical syntax; any AST lowering
    for them must be slot-policy preserving and retirement-aware. `copy`, `array_copy`,
    `hash_copy`, flat helpers, collection reducers, and hash helpers use explicit AST slot
    policy so symbol-name slots and value-expression slots cannot drift. Existing aggregate
    wrapper quoted-name boundaries remain green.
  Verification: **PASS 2026-07-01.** Added slot-aware AST call dispatch for deprecated
    scalar/array/hash wrappers, copy helpers, flat helpers, array collection helpers,
    numeric reducers with aggregate operands, hash helpers, capture-map/group helpers, and
    hash/array terminal helpers. Covered calls reconstruct helper-call surfaces from typed
    AST node fields before entering the existing Perl helper catalog, preserving symbol
    slots such as `array(items)`/`hash(meta)`, quoted-wrapper literal boundaries, and
    value slots such as counts, keys, delimiters, and nested value-only helper payloads.
    Focused fake-source tests prove covered aggregate helper calls do not reuse call-node
    source text; `mdbook build docs/linkedspec-book`, doctrine/Knowledge Map checks, and
    `bash tools/run_ci_local.sh` remain green with phase0 1002 tests.
  Commit: `PERL-ACTIONIR-AST-MIGRATION.3.2.2 - lower aggregate helper calls from AST`

- ID: `PERL-ACTIONIR-AST-MIGRATION.3.2.3`
  Status: `done` (2026-07-01)
  Goal: Add covered-call diagnostics and retire silent host-call leakage.
  Acceptance: Helper families covered by `.3.2.1` and `.3.2.2` no longer fall through as
    generated host-language calls when their AST form is unsupported; they emit a clear
    LinkedSpec diagnostic/telemetry path instead.
  Verification: **PASS 2026-07-01.** Unsupported AST call forms for helper families
    already owned by `.3.2.1`/`.3.2.2` now lower to a harmless
    `LINKEDSPEC_UNSUPPORTED_ACTIONIR_HELPER:<name>` sentinel expression instead of a
    generated host-language call. `ActionIR::Diagnostics` scans that sentinel into the
    existing unresolved-helper metadata, so descriptor summaries report
    `unresolved_helper_count` / `unresolved_helpers` and mark the rule not
    language-agnostic ready while keeping `raw_perl_dependency_count == 0`. Focused
    tests cover malformed value-only helpers, malformed aggregate helpers, nested
    malformed helpers inside a valid covered helper, and descriptor telemetry. Phase0
    remains green and local CI passes.
  Commit: `PERL-ACTIONIR-AST-MIGRATION.3.2.3 - diagnose unsupported AST helper calls`

- ID: `PERL-ACTIONIR-AST-MIGRATION.3.3`
  Status: `done` (2026-07-01)
  Goal: Replace receiver-dot value-chain normalization with AST `fluent_chain` lowering.
  Acceptance: Function-call receivers, literal receivers, direct-access receivers, shape
    receivers, and block-valued receivers lower by traversing `fluent_chain` nodes,
    typed receiver nodes, and typed call-argument nodes, not by splitting receiver-dot
    source text.
  Verification: **PASS 2026-07-01.** `MethodLowering::_lower_method_value_expr(...)`
    now dispatches AST `fluent_chain` nodes before the legacy receiver-dot text
    normalizers. The dispatcher maps typed receiver/call nodes onto the existing helper
    catalog for the array, hash, string, and number receiver families while preserving
    legacy wrapper behavior, array pipeline helper names, string/hash bridges to array
    terminals, block-valued receivers, numeric terminal continuation behavior, and
    covered-helper diagnostics for unsupported chain forms. Focused fake-source tests
    prove number, string-to-array, block-array, hash-to-array, invalid numeric terminal,
    and unsupported `substr` chain cases do not reuse poisoned chain/call/argument source
    text.
  Commit: `PERL-ACTIONIR-AST-MIGRATION.3.3 - lower receiver chains from AST`

- ID: `PERL-ACTIONIR-AST-MIGRATION.3.4`
  Status: `done` (2026-07-01)
  Goal: Replace return-payload helper substitution with AST traversal and diagnostics.
  Acceptance: `_lower_return_payload_expr(...)` walks typed value/call/chain nodes instead
    of regex-substituting helper-looking source spans; accidental generated host-language
    calls on supported surfaces emit a LinkedSpec diagnostic.
  Verification: **PASS 2026-07-01.** `_lower_return_payload_expr(...)` now parses the
    trimmed payload through `LinkedSpec::ActionIR::AST` and returns the AST-lowered value
    directly for typed nodes before the legacy helper-substitution loop. Focused tests
    poison array/hash/string/call/chain node `source` fields and prove typed return
    payloads lower from AST fields, unsupported covered chain helpers keep the
    `LINKEDSPEC_UNSUPPORTED_ACTIONIR_HELPER:<name>` diagnostic sentinel, and the narrow
    raw compatibility payload `\(my $capt = capture_slice())` still uses the legacy
    fallback. Checks passed: `perl -Iperl -c perl/LinkedSpec/ActionIR/MethodLowering.pm`,
    `perl -Iperl -c t/actionir_ast_parser.t`, `perl -Iperl -c perl/LinkedSpec.pm`,
    `prove -v -Iperl t/actionir_ast_parser.t`, `prove -q -Iperl t/phase0_regression.t`
    (1002 tests), `mdbook build docs/linkedspec-book`, memory/doctrine/Knowledge Map
    gates, `git diff --check`, and `bash tools/run_ci_local.sh`.
  Commit: `PERL-ACTIONIR-AST-MIGRATION.3.4 - lower return payloads from AST`

- ID: `PERL-ACTIONIR-AST-MIGRATION.4`
  Status: `split` (2026-07-01)
  Goal: Replace statement/control lowering with AST lowering.
  Acceptance: Assignments, appends, hash-index mutation, set_key, push helpers,
    return/return_undef, if/when/switch/while forms, and block-local returns lower from AST
    nodes. Existing behavior stays stable.
  Children: `.4.1`, `.4.2`, `.4.3`, `.4.4`
  Verification: **PASS 2026-07-01 (split only).** Split statement/control AST lowering
    by parser support and behavior risk before code: assignment/mutation operator nodes,
    helper-call statements and returns, block-value statement traversal/block-local
    returns, and structured control-flow forms.
  Commit: `PERL-ACTIONIR-AST-MIGRATION.4 - split AST statement lowering`

- ID: `PERL-ACTIONIR-AST-MIGRATION.4.1`
  Status: `done` (2026-07-01)
  Goal: Lower parsed assignment/mutation operator statement nodes from AST.
  Acceptance: `assign_scalar`, `assign_array_append`, and `assign_hash_index` statement
    nodes lower from typed target/value/key fields instead of re-reading statement source
    text. Existing assignment target-kind inference, source-slot scalar reads, and
    mutation value-slot behavior remain byte-compatible.
  Verification: **PASS 2026-07-01.** `MethodLowering` now consumes AST
    `assign_scalar`, `assign_array_append`, and `assign_hash_index` nodes before the
    legacy statement regex paths. Focused tests poison the original statement text and
    AST `source` fields while proving scalar assignment, array append, and hash-index
    assignment lower from typed target/key/value fields. Checks passed so far:
    `perl -Iperl -c perl/LinkedSpec/ActionIR/MethodLowering.pm`,
    `perl -Iperl -c t/actionir_ast_parser.t`, `perl -Iperl -c perl/LinkedSpec.pm`, and
    `prove -v -Iperl t/actionir_ast_parser.t`; `prove -q -Iperl t/phase0_regression.t`
    passed with 1002 tests; `mdbook build docs/linkedspec-book`,
    memory/doctrine/Knowledge Map gates, `git diff --check`, and `bash tools/run_ci_local.sh`
    passed.
  Commit: `PERL-ACTIONIR-AST-MIGRATION.4.1 - lower statement operators from AST`

- ID: `PERL-ACTIONIR-AST-MIGRATION.4.2`
  Status: `done` (2026-07-01)
  Goal: Lower helper-call statements and returns from AST `call` nodes.
  Acceptance: Statement-form `set`/`assign`, `push`, `set_key`, array end-mutation
    helpers, `return`, and `return_undef` consume typed call names/arguments before
    entering the existing statement helper catalog. Symbol/value slot policies remain
    explicit and unsupported covered helper statements diagnose instead of leaking host
    calls.
  Verification: **PASS 2026-07-01.** `MethodLowering` now consumes AST `call`
    nodes for `return`, `return_undef`, `set_key`, `push`, `push_value`, and
    `push_nonempty`, and AST `fluent_chain` nodes for array end-mutation
    statements. `DeclareMethod` bridges top-level `set`/`assign` through typed
    call arguments. Focused tests poison original text and AST `source` fields
    across the statement helper family, and `push_nonempty(items)` now reports
    an unresolved-helper sentinel instead of leaking a host call. Checks passed:
    syntax checks for touched modules, focused AST parser suite, phase0 1002
    tests, `mdbook build docs/linkedspec-book`, memory/doctrine/Knowledge Map
    gates, `git diff --check`, and `bash tools/run_ci_local.sh`.
  Commit: `PERL-ACTIONIR-AST-MIGRATION.4.2 - lower statement calls from AST`

- ID: `PERL-ACTIONIR-AST-MIGRATION.4.3`
  Status: `done` (2026-07-01)
  Goal: Lower block-value side-effect statements and block-local returns from AST.
  Acceptance: Expression-valued blocks walk `action_block` / `action_stmt` nodes for
    non-final side-effect statements and block-local `return(...)` payloads instead of
    splitting source text inside `_lower_block_value_expr(...)`. Existing block-value
    early-return behavior stays stable.
  Verification: **PASS 2026-07-01.** `_lower_block_value_expr(...)` now routes
    parsed `block_value` nodes into the AST value path before legacy splitting.
    AST block-value lowering consumes `action_stmt.expr` nodes for side effects,
    block-local return payloads, and final expressions, with legacy source fallback
    retained for untyped compatibility surfaces. Checks passed: syntax checks,
    focused AST parser suite with 15 subtests, phase0 1002 tests, `mdbook build
    docs/linkedspec-book`, memory/doctrine/Knowledge Map gates, `git diff --check`,
    and `bash tools/run_ci_local.sh`.
  Commit: `PERL-ACTIONIR-AST-MIGRATION.4.3 - lower block values from AST`

- ID: `PERL-ACTIONIR-AST-MIGRATION.4.4`
  Status: `split` (2026-07-01)
  Goal: Lower structured control-flow statement forms from AST.
  Children: `.4.4.1`, `.4.4.2`, `.4.4.3`, `.4.4.4`
  Acceptance: `if`/`when`/`otherwise`, `switch`/`case`/`default`, and `while` forms lower
    from typed condition/block/case nodes rather than textual marker reconstruction.
    Existing attached-block, fluent-control, and iteration-safety behavior remains stable.
  Verification: **PASS 2026-07-01 (split only).** Split structured-control AST
    lowering before code into parser-node, if/when/otherwise, switch/case/default,
    and while children. Memory/doctrine/Knowledge Map gates and `git diff --check`
    passed.
  Commit: `PERL-ACTIONIR-AST-MIGRATION.4.4 - split structured-control AST lowering`

- ID: `PERL-ACTIONIR-AST-MIGRATION.4.4.1`
  Status: `done` (2026-07-01)
  Goal: Add typed control-flow AST parser nodes and focused parser locks.
  Acceptance: Attached-block and marker-style control forms parse into typed AST nodes
    carrying condition/source/body/case/default fields as applicable, while existing
    production lowering behavior remains unchanged.
  Verification: **PASS 2026-07-01.** `LinkedSpec::ActionIR::AST::Parser`
    now parses attached-block and marker-style structured control forms into typed
    `control_if`, `control_else`, `control_endif`, `control_while`,
    `control_switch`, `control_case`, `control_default`, `control_endcase`, and
    `control_endswitch` nodes. Nodes carry canonical/source keywords, parsed
    condition/source/match expressions, attached body blocks, body source spans,
    and parsed switch case/default branches where applicable. Inline value-form
    `if(...)`/`switch(...)` helpers remain generic `call` nodes so production
    value lowering stays unchanged. Checks passed:
    `perl -Iperl -c perl/LinkedSpec/ActionIR/AST/Parser.pm`,
    `perl -Iperl -c t/actionir_ast_parser.t`,
    `prove -v -Iperl t/actionir_ast_parser.t`, `perl -c perl/LinkedSpec.pm`,
    `perl -c -Iperl t/phase0_regression.t`, and direct
    `perl -Iperl t/phase0_regression.t` with phase0 1002 tests;
    `mdbook build docs/linkedspec-book`; memory, doctrine, and Knowledge Map
    gates; `git diff --check`; and `bash tools/run_ci_local.sh`.
  Commit: `PERL-ACTIONIR-AST-MIGRATION.4.4.1 - parse structured control AST nodes`

- ID: `PERL-ACTIONIR-AST-MIGRATION.4.4.2`
  Status: `done` (2026-07-01)
  Goal: Lower `if`/`when`/`otherwise` statement forms from AST.
  Acceptance: If/elseif/else/endif and when/otherwise forms consume typed condition and
    branch-body nodes before legacy textual marker reconstruction. Existing attached-block
    and fluent-control behavior stays stable.
  Verification: **PASS 2026-07-01.** `LinkedSpec::ActionIR::ControlFlow`
    now parses `if`/`i`/`when`, `elseif`/`elif`, `else`/`otherwise`, and
    `endif` statements through `LinkedSpec::ActionIR::AST`, materializes trusted
    control statements from typed condition/body nodes, then reuses the existing
    branch lowerers. Fake-source focused locks prove original statement text and
    AST `source` fields are not reused for attached if/elseif/else,
    when/otherwise, or marker if/elseif/else/endif. Checks passed:
    `perl -Iperl -c perl/LinkedSpec/ActionIR/ControlFlow.pm`,
    `perl -Iperl -c t/actionir_ast_parser.t`,
    `prove -v -Iperl t/actionir_ast_parser.t`, `perl -c perl/LinkedSpec.pm`,
    `perl -c -Iperl t/phase0_regression.t`, and
    `prove -q -Iperl t/phase0_regression.t` with phase0 1002 tests;
    `mdbook build docs/linkedspec-book`; memory, doctrine, and Knowledge Map
    gates; `git diff --check`; and `bash tools/run_ci_local.sh`.
  Commit: `PERL-ACTIONIR-AST-MIGRATION.4.4.2 - lower if controls from AST`

- ID: `PERL-ACTIONIR-AST-MIGRATION.4.4.3`
  Status: `done` (2026-07-01)
  Goal: Lower `switch`/`case`/`default` statement forms from AST.
  Acceptance: Switch source expressions, case match values, default branches, and optional
    endcase/endswitch markers consume typed AST fields while preserving existing switch
    state and branch-order behavior.
  Verification: **PASS 2026-07-01.** `LinkedSpec::ActionIR::ControlFlow`
    now parses `switch`, `case`, `default`, `endcase`, and `endswitch`
    statements through `LinkedSpec::ActionIR::AST`, materializes trusted
    switch source expressions, case match values, attached case/default bodies,
    and end markers from typed fields, and then reuses the existing switch
    stack lowerers. Attached `control_switch` nodes prefer parsed `cases` and
    `default` branch fields over generic body fallback. Fake-source focused
    locks prove original statement text, fake fallback bodies, and AST `source`
    fields are not reused for attached or marker switch controls. Checks
    passed: `perl -Iperl -c perl/LinkedSpec/ActionIR/ControlFlow.pm`,
    `perl -Iperl -c t/actionir_ast_parser.t`,
    `prove -v -Iperl t/actionir_ast_parser.t`, `perl -c perl/LinkedSpec.pm`,
    `perl -c -Iperl t/phase0_regression.t`, and
    `prove -q -Iperl t/phase0_regression.t` with phase0 1002 tests;
    `mdbook build docs/linkedspec-book`; memory, doctrine, and Knowledge Map
    gates; `git diff --check`; and `bash tools/run_ci_local.sh`.
  Commit: `PERL-ACTIONIR-AST-MIGRATION.4.4.3 - lower switch controls from AST`

- ID: `PERL-ACTIONIR-AST-MIGRATION.4.4.4`
  Status: `done` (2026-07-01)
  Goal: Lower `while` statement forms from AST.
  Acceptance: While conditions and attached/marker body statements consume typed AST fields
    while preserving the existing iteration-safety guard and generated behavior.
  Verification: **PASS 2026-07-01.** `LinkedSpec::ActionIR::ControlFlow`
    now parses attached `while(cond) { ... }` statements through
    `LinkedSpec::ActionIR::AST`, materializes trusted loop conditions and
    attached body statements from typed `control_while` fields, and then reuses
    the existing while lowerer with the deterministic 10000-iteration guard.
    Bodyless `while(...)` marker nodes remain parser shape only because the
    current DSL has no `endwhile` product syntax. Fake-source focused locks
    prove original statement text and AST `source` fields are not reused for
    attached while controls. Checks passed: `perl -Iperl -c
    perl/LinkedSpec/ActionIR/ControlFlow.pm`, `perl -Iperl -c
    t/actionir_ast_parser.t`, `prove -v -Iperl t/actionir_ast_parser.t`,
    `perl -c perl/LinkedSpec.pm`, `perl -c -Iperl t/phase0_regression.t`,
    and `prove -q -Iperl t/phase0_regression.t` with phase0 1002 tests;
    `mdbook build docs/linkedspec-book`; memory, doctrine, and Knowledge Map
    gates; `git diff --check`; and `bash tools/run_ci_local.sh`.
  Commit: `PERL-ACTIONIR-AST-MIGRATION.4.4.4 - lower while controls from AST`

- ID: `PERL-ACTIONIR-AST-MIGRATION.5`
  Status: `pending`
  Goal: Retire supported-surface text fallback and unblock user-defined functions on AST.
  Acceptance: Supported helper/value/control surfaces no longer depend on text-to-text
    fallback; unsupported call spellings emit clear diagnostics; user-defined function
    calls are implemented through AST call nodes rather than textual macro expansion. The
    permanent `fn <name>(...) { ... }` grammar belongs in `specs/spec.spec`; bootstrap
    parser support, if any, is temporary migration debt to remove after this AST path can
    carry the surface.
  Verification: `pending`
  Commit: `pending`

## Current Frontier

| Order | Leaf | Status | Why next |
| --- | --- | --- | --- |
| — | `PERL-ACTIONIR-AST-MIGRATION.0` | `done` 2026-07-01 | Doctrine adoption and book alignment before code. |
| — | `PERL-ACTIONIR-AST-MIGRATION.1` | `done` 2026-07-01 | Perl text-to-text lowering inventory, AST node set, and replacement order locked before implementation. |
| — | `PERL-ACTIONIR-AST-MIGRATION.2` | `done` 2026-07-01 | Additive `ActionIR::AST` parser seam and focused parser tests landed without switching lowering consumers. |
| — | `PERL-ACTIONIR-AST-MIGRATION.3` | `split` 2026-07-01 | Parent contract for value-expression and receiver-chain AST lowering. |
| — | `PERL-ACTIONIR-AST-MIGRATION.3.1` | `done` 2026-07-01 | Non-call value nodes now lower from AST. |
| — | `PERL-ACTIONIR-AST-MIGRATION.3.2` | `split` 2026-07-01 | Parent contract for AST helper-call value composition. |
| — | `PERL-ACTIONIR-AST-MIGRATION.3.2.1` | `done` 2026-07-01 | Value-only helper-call composition now lowers from AST call nodes. |
| — | `PERL-ACTIONIR-AST-MIGRATION.3.2.2` | `done` 2026-07-01 | Aggregate-wrapper and collection/hash helper calls now lower from AST call nodes with slot-preserving compatibility. |
| — | `PERL-ACTIONIR-AST-MIGRATION.3.2.3` | `done` 2026-07-01 | Unsupported covered helper-call AST forms now emit unresolved-helper diagnostics instead of generated host calls. |
| — | `PERL-ACTIONIR-AST-MIGRATION.3.3` | `done` 2026-07-01 | Receiver-dot `fluent_chain` value chains now lower from AST receiver/call nodes. |
| — | `PERL-ACTIONIR-AST-MIGRATION.3.4` | `done` 2026-07-01 | Return payloads now enter AST value traversal before the raw fallback. |
| — | `PERL-ACTIONIR-AST-MIGRATION.4` | `split` 2026-07-01 | Statement/control AST lowering split by behavior family before code. |
| — | `PERL-ACTIONIR-AST-MIGRATION.4.1` | `done` 2026-07-01 | Parsed assignment/mutation operator statement nodes now lower from AST fields. |
| — | `PERL-ACTIONIR-AST-MIGRATION.4.2` | `done` 2026-07-01 | Helper-call statements, returns, and array end-mutation receiver statements now lower from AST call/fluent-chain fields. |
| — | `PERL-ACTIONIR-AST-MIGRATION.4.3` | `done` 2026-07-01 | Block-value side effects, block-local returns, and final expressions now lower from AST block/statement fields. |
| — | `PERL-ACTIONIR-AST-MIGRATION.4.4` | `split` 2026-07-01 | Structured control-flow AST lowering split by parser nodes, branch family, switch state, and while safety before code. |
| — | `PERL-ACTIONIR-AST-MIGRATION.4.4.1` | `done` 2026-07-01 | Typed control-flow AST parser nodes and focused parser locks landed before lowering consumers switch over. |
| — | `PERL-ACTIONIR-AST-MIGRATION.4.4.2` | `done` 2026-07-01 | If/when/otherwise statement controls now lower from typed condition/body nodes. |
| — | `PERL-ACTIONIR-AST-MIGRATION.4.4.3` | `done` 2026-07-01 | Switch/case/default statement controls now lower from typed source/match/body/default nodes. |
| — | `PERL-ACTIONIR-AST-MIGRATION.4.4.4` | `done` 2026-07-01 | Attached while statement controls now lower from typed condition/body nodes. |
| 1 | `PERL-ACTIONIR-AST-MIGRATION.5` | `pending` | Retire supported-surface text fallback and unblock user-defined functions on AST. |

## PERL-ACTIONIR-AST-MIGRATION.3.2 Split

AST helper calls need slot-aware migration. Some helper arguments are ordinary value
expressions and can be recursively lowered before invoking the existing helper catalog.
Other slots carry symbols, aggregate wrapper boundaries, regex delimiters, tags, or field
names where premature value lowering would change semantics. `.3.2` is therefore split:

- `.3.2.1`: value-only helper families, including scalar normalization, string
  predicates, coalesce/concat, and numeric helpers;
- `.3.2.2`: legacy aggregate wrappers and collection/hash helpers with explicit
  retirement-aware symbol/value slot policy;
- `.3.2.3`: diagnostics for covered helper-call AST forms that would otherwise leak as
  generated host-language calls.

## PERL-ACTIONIR-AST-MIGRATION.3.1 AST Value Dispatcher

`MethodLowering::_lower_method_value_expr(...)` now parses value input with
`LinkedSpec::ActionIR::AST` before the legacy text cascade. The dispatcher consumes these
typed node families directly:

- primitive literal nodes (`number`, `string`, `boolean`, `regex`, `undef`);
- scoped bare scalar reads in already-supported value slots;
- `indexed_var` and `nested_access`, while preserving the legacy rule that reserved
  path atoms such as `true` and `CAPTURE` leave the whole direct-access expression
  untouched;
- `array_literal` and `hash_literal`;
- `block_value` final values and block-local return payloads.

Nested unsupported helper calls inside AST-lowered shapes and blocks still pass through an
explicit compatibility bridge. Value-only helper-call composition is now covered by
`.3.2.1`; aggregate/symbol-slot helper calls are covered by `.3.2.2`; covered-call
diagnostics are covered by `.3.2.3`; receiver-dot `fluent_chain` lowering is covered by
`.3.3`; return-payload AST traversal is covered by `.3.4`. Statement/control lowering is
the next migration child.

## PERL-ACTIONIR-AST-MIGRATION.3.2.1 Value-Only Helper Calls

`MethodLowering::_lower_method_value_expr(...)` now dispatches supported AST `call`
nodes for value-only helper families. The dispatcher canonicalizes numeric word aliases,
recursively lowers argument AST nodes, preserves existing bare-variable behavior in
helper-call slots, and then enters the existing Perl helper catalog through the explicit
compatibility bridge with already-lowered argument expressions.

Covered families are scalar normalization, string predicate/composition helpers,
`concat`, `coalesce`, `coalesce_nonempty`, scalar-argument numeric helpers, and explicit
`num_*` comparisons. Aggregate-wrapper, collection, reducer, and hash helpers are now
covered by `.3.2.2`; receiver-chain helpers remain compatibility paths for `.3.3`.

## PERL-ACTIONIR-AST-MIGRATION.3.2.2 Aggregate/Collection Helper Calls

`MethodLowering::_lower_method_value_expr(...)` now dispatches slot-sensitive aggregate
helper families from AST `call` nodes before the legacy text cascade. The dispatcher
normalizes deprecated wrapper aliases (`s`/`a`/`h`, `scalar`/`array`/`hash`) and numeric
word aliases, rebuilds covered helper-call surfaces from typed AST argument nodes, and
then reuses the existing Perl helper catalog through the compatibility bridge.

Covered families include scalar/array/hash wrappers, `array_copy`, `hash_copy`, `copy`,
`flat`/`flat_array`/`flat_hash`, array collection helpers (`count`, `first`, `last`,
`take`, `take_last`, `drop_front`, `drop_back`, `slice`, `concat_arrays`, `split`,
`split_tagged_records`, `sorted`, `reversed`, `contains`, `index_of`, `join_values`,
array pipeline value helpers), aggregate numeric reducers (`num_sum`, `num_avg`,
`num_median`, `num_range`, unary aggregate `num_min`/`num_max`), and hash helpers
(`merge_hash`, value-form `set_key`, `rename_key`, `drop_keys`, `pick_keys`,
`count_keys`, `sorted_keys`, `sorted_values`, `has_key`, entry/match map helpers).

The compatibility policy is still explicit: wrapper calls remain deprecated aliases
per ADR `0007`, not canonical syntax. Slot reconstruction preserves bare symbol tokens
for aggregate/source slots and quoted wrapper payloads as literals, so `array(items)`
continues to read `@items` while `array("items")` constructs a literal payload.
`.3.2.3` covers diagnostics for covered calls that cannot lower cleanly. Receiver-dot
`fluent_chain` lowering is now covered by `.3.3`; return-payload AST traversal is now
covered by `.3.4`.

## PERL-ACTIONIR-AST-MIGRATION.3.2.3 Covered-Call Diagnostics

Malformed helper calls from families already owned by `.3.2.1`/`.3.2.2` no longer survive
as generated Perl calls. Examples before this leaf included `return(substr("abc"))`,
`return(count())`, and nested `return(concat(substr("abc"),"x"))`.

The implementation is deliberately narrow:

- `_lower_method_value_expr(...)` distinguishes unknown calls from known helper-family
  calls. Unknown calls remain future/user-function territory; known helpers that fail
  AST arity or AST argument materialization return a harmless
  `LINKEDSPEC_UNSUPPORTED_ACTIONIR_HELPER:<name>` sentinel expression.
- `ActionIR::Diagnostics::_find_unresolved_action_helpers(...)` scans that sentinel into
  the existing unresolved-helper metadata. Descriptors now report the helper name under
  `unresolved_helpers`, keep `raw_perl_dependency_count == 0`, and mark the rule as not
  language-agnostic ready.
- Supported helper forms remain byte-compatible with the `.3.2.1`/`.3.2.2` behavior.

This is a diagnostics/telemetry leaf, not a user-function implementation leaf.
User-defined functions remain blocked until the remaining AST return and statement/control
migration work is complete.

## PERL-ACTIONIR-AST-MIGRATION.3.3 Receiver-Chain AST Lowering

`MethodLowering::_lower_method_value_expr(...)` now consumes `fluent_chain` AST nodes for
receiver-dot value chains before the legacy receiver-dot text normalizers run. The
dispatcher traverses typed receiver nodes and typed call-argument nodes, then builds the
same helper-family surfaces used by the existing Perl helper catalog.

Covered receiver families:

- array receiver chains, including `join_values(...)` delimiter-first mapping and the
  private array pipeline helper names used for `split_each`, `trim_each`,
  `filter_nonempty`, `lowercase_each`, `uppercase_each`, `uniq`, and `filter_match`;
- hash receiver chains, including bare hash receiver wrapping, `hash_copy`, `flat_hash`,
  `scalaref`, and hash-to-array bridges through `sorted_keys` / `sorted_values`;
- string/scalar receiver chains, including bare scalar receiver wrapping, `concat` / `cat`,
  string terminal helpers, and string-to-array bridging through `split`;
- number receiver chains, including numeric word receiver methods, arity checks, and
  terminal comparison continuation behavior.

The focused `.3.3` test poisons top-level chain source, individual fluent-call source,
receiver source, and argument source fields. It verifies that number chains,
string-to-array chains, block-valued array receivers, hash-to-array chains, invalid
numeric terminal continuations, and unsupported chain helper diagnostics all come from
typed AST fields instead of receiver-dot source splitting. The old text normalizers remain
only as compatibility fallback for expressions the AST parser cannot own yet.

## PERL-ACTIONIR-AST-MIGRATION.3.4 Return-Payload AST Traversal

`MethodLowering::_lower_return_payload_expr(...)` now parses generalized return payloads
through `LinkedSpec::ActionIR::AST` and returns the AST-lowered value for typed nodes
before the legacy helper-substitution loop can run. That means direct shape payloads,
bare scalar reads, primitive literals, nested helper calls, direct/nested access, block
values, and receiver-dot chains reuse the same typed value traversal as
`_lower_method_value_expr(...)`.

The compatibility boundary is deliberately narrow. If the parser reports `raw_perl`, or
if a typed payload cannot lower through the AST value dispatcher, the old raw fallback
remains available for shipped compatibility payloads such as
`\(my $capt = capture_slice())`. Supported typed payloads do not use helper-looking
regex substitution first.

The focused `.3.4` test poisons array/hash/string/call/chain `source` fields and proves
return payloads consume typed AST fields rather than source text. It also locks the
diagnostic behavior for unsupported covered helper chains inside return payloads:
`"abc".substr()` becomes the existing `LINKEDSPEC_UNSUPPORTED_ACTIONIR_HELPER:substr`
sentinel instead of generated host Perl.

## PERL-ACTIONIR-AST-MIGRATION.3 Split

`PERL-ACTIONIR-AST-MIGRATION.3` is intentionally a parent contract, not a single
implementation leaf. The migration touches four different lowering mechanisms with
different risk profiles:

- non-call value nodes in `_lower_method_value_expr(...)`;
- helper-call value composition and aggregate-wrapper call arguments;
- receiver-dot value chains;
- return-payload helper substitution and host-call leakage diagnostics.

Each child must keep existing generated behavior green while removing one text-rescan
surface from the supported ActionIR language. User-defined functions remain blocked behind
the completed `.3` children, because function calls must enter as AST `Call` nodes and may
act as receiver-chain receivers. `.3.3` has now removed the receiver-dot text splitter from
AST-owned value chains; `.3.4` has now moved typed return payloads onto AST traversal.

## PERL-ACTIONIR-AST-MIGRATION.4 Split

Statement/control lowering is broader than one safe code leaf because it combines
already-parsed operator statement nodes, helper-call statements with slot-sensitive
argument policies, expression-valued block side effects, and structured control-flow
forms that may need additional AST parser nodes. `.4` is therefore split before code:

- `.4.1`: use existing `assign_scalar`, `assign_array_append`, and `assign_hash_index`
  nodes for assignment/mutation operator statements;
- `.4.2`: lower statement helper calls and returns from AST `call` nodes while preserving
  symbol/value slot policy;
- `.4.3`: walk `action_block` / `action_stmt` nodes inside block values and block-local
  `return(...)` handling;
- `.4.4`: split structured control-flow lowering into parser-node, if/when/otherwise,
  switch/case/default, and while children.

The split keeps the `.4` parent acceptance intact while making the first executable leaf
small enough to validate without changing control-flow semantics.

## PERL-ACTIONIR-AST-MIGRATION.4.4 Structured-Control AST Split

Structured control-flow lowering is broad enough to need another split before code:

- `.4.4.1`: typed control-flow AST parser nodes and focused parser locks;
- `.4.4.2`: `if`/`when`/`otherwise` lowering from typed condition/body nodes;
- `.4.4.3`: `switch`/`case`/`default` lowering from typed source/case/default fields;
- `.4.4.4`: `while` lowering from typed condition/body nodes while preserving iteration safety.

This keeps parser node shape, branch-body lowering, switch-state handling, and while safety
on separate verification surfaces.

## PERL-ACTIONIR-AST-MIGRATION.4.4.1 Control-Flow Parser Nodes

`LinkedSpec::ActionIR::AST::Parser` now recognizes structured-control syntax as typed
AST nodes before production lowering switches over:

- `control_if` for `if(...)`, `i(...)`, `when(...)`, `elseif(...)`, and `elif(...)`,
  carrying `branch_role`, `canonical_keyword`, and parsed `condition` fields;
- `control_else` for `else` / `otherwise`, including attached bodies;
- `control_endif` for the bare `endif` marker;
- `control_while` for `while(...)`, with parsed `condition` and optional attached body;
- `control_switch` for `switch(...)`, with parsed `source_expr`, optional attached body,
  parsed `cases`, and optional `default`;
- `control_case`, `control_default`, `control_endcase`, and `control_endswitch` for
  switch branch and marker forms.

Attached bodies are parsed as `action_block` nodes and keep `body_source` /
`body_source_span` for diagnostics and later lowering. Attached switch bodies are also
scanned into typed case/default branches when the payload is made only of attached
`case(...) { ... }` and `default { ... }` branches. Inline value-form `if(cond, a, b)`
and `switch(value, case(...), default(...))` deliberately remain generic `call` nodes;
they are value helpers, not structured-control statements, and their production lowering
was already owned by earlier leaves.

## PERL-ACTIONIR-AST-MIGRATION.4.4.2 If-Family Control AST Lowering

`LinkedSpec::ActionIR::ControlFlow` now runs if-family statements through the typed AST
parser before invoking the existing branch engine. The covered statement family is:

- `if(...)` / `i(...)` / `when(...)`;
- `elseif(...)` / `elif(...)`;
- `else` / `else()` / `otherwise`;
- `endif` / `endif()`.

The bridge does not introduce a new branch engine. It materializes a trusted control
statement from typed condition and body nodes, then lets the established `ControlFlow`
lowerers preserve attached-block implicit close, marker-style `endif`, and
when/otherwise alias semantics. Focused tests poison the original statement text and
every AST `source` field, then prove attached if/elseif/else, when/otherwise, and marker
if/elseif/else/endif output comes from typed fields. At `.4.4.2` completion,
`switch`/`case`/`default` and `while` were still queued for `.4.4.3` and `.4.4.4`;
the switch-family handoff is closed in the `.4.4.3` section below.

## PERL-ACTIONIR-AST-MIGRATION.4.4.3 Switch Control AST Lowering

`LinkedSpec::ActionIR::ControlFlow` now runs switch-family statements through the typed
AST parser before invoking the existing switch stack engine. The covered statement family
is:

- `switch(...)`;
- `case(...)`;
- `default` / `default()`;
- `endcase` / `endcase()`;
- `endswitch` / `endswitch()`.

The bridge materializes trusted statement text from typed `source_expr`, `match`, `body`,
`cases`, and `default` fields, then lets the established `ControlFlow` lowerers preserve
switch-value single evaluation, case branch order, `default` once-only behavior,
attached-switch branch splitting, and marker-style `endcase`/`endswitch` stack closure.
Attached `control_switch` nodes prefer parsed `cases` and `default` branch fields over
the generic attached-body fallback, so parsed branch AST nodes are authoritative when
available. Focused tests poison the original statement text, fake fallback bodies, and
every AST `source` field, then prove attached and marker switch-family output comes from
typed fields. `while` remains queued for `.4.4.4`.

## PERL-ACTIONIR-AST-MIGRATION.4.4.4 While Control AST Lowering

`LinkedSpec::ActionIR::ControlFlow` now runs the existing attached `while(cond) { ... }`
statement loop surface through the typed AST parser before invoking the existing while
lowerer. The bridge materializes trusted statement text from typed `condition` and `body`
fields, then lets the established lowerer preserve condition re-evaluation, body lowering,
and the deterministic 10000-iteration safety guard.

Bodyless `while(...)` marker nodes still parse as `control_while`, but they remain
parser-shape-only for lowering because the current DSL has no `endwhile` control or
marker-style while product syntax. Focused tests poison the original statement text and
every AST `source` field, then prove attached while output comes from typed condition/body
fields while retaining the guard diagnostic.

## PERL-ACTIONIR-AST-MIGRATION.4.1 Assignment/Mutation Operator AST Statements

The first statement-lowering code leaf moves the three assignment-style operator nodes
already parsed by `LinkedSpec::ActionIR::AST::Parser` onto typed-field lowering:

- `assign_scalar` (`name = value`);
- `assign_array_append` (`items += value`);
- `assign_hash_index` (`meta[key] = value`).

`MethodLowering` materializes a trusted helper/action expression from typed AST fields and
then enters the existing assignment/mutation lowering policies. This keeps direct
shape-literal target-kind inference, source-slot scalar reads, mutation value-slot reads,
and hash-key lowering byte-compatible while proving the original statement text and AST
`source` fields are no longer authoritative for these operator statements.

Helper-call statements (`set`, `push`, `set_key`, `return`, `return_undef`) are now covered
by `.4.2`; block-value side effects and block-local returns are now covered by `.4.3`;
structured control-flow statements remain `.4.4`.

## PERL-ACTIONIR-AST-MIGRATION.4.2 Helper-Call Statement AST Lowering

The second statement-lowering code leaf moves statement helper calls onto typed call
materialization before the legacy parser/regex paths:

- `set(...)` / `assign(...)` through `DeclareMethod` and the existing assignment policy;
- `set_key(...)` through the hash mutation key/value policy;
- `push(...)`, `push_value(...)`, and `push_nonempty(...)` through the existing explicit
  append helpers;
- `return(...)` and `return_undef()` through the return statement helpers;
- `items.push_back(...)`, `items.push_front(...)`, `items.pop_back()`, and
  `items.pop_front()` through AST `fluent_chain` receiver/call fields.

The AST bridge materializes supported call arguments from typed fields, then deliberately
re-enters the existing statement helper catalog. This preserves the known slot boundaries:
`push_value` and `push_nonempty` keep their legacy value-expression slot behavior, while
`set_key` and array end mutations keep mutation scalar-read slots. Raw compatibility
arguments such as `scalaref(retv, {content})` and host-style `substr($$STRING, ...)` still
fall back to the legacy path until later migration leaves type those surfaces.

Unsupported covered statement helpers can now surface through the existing unresolved-helper
sentinel path; the focused lock covers `push_nonempty(items)`, which no longer remains as a
generated host helper call.

## PERL-ACTIONIR-AST-MIGRATION.4.3 Block-Value Statement AST Lowering

The third statement-lowering code leaf moves expression-valued block internals onto typed
`block_value` / `action_block` / `action_stmt` fields before the legacy block splitter:

- non-final side-effect statements consume the nested `action_stmt.expr` node;
- block-local `return(...)` payloads consume typed AST call arguments;
- final block expressions consume the final statement expression node;
- the existing guarded `__ls_block_done` / `__ls_block_value` early-return shape remains
  unchanged for non-final `return(...)` inside a block value.

The AST path reuses the existing assignment, statement-call, mutation, and value lowering
policies. Legacy source splitting remains only as fallback for compatibility surfaces the
typed AST path cannot yet represent. Structured control-flow forms remain `.4.4`.

## PERL-ACTIONIR-AST-MIGRATION.2 Parser Seam

The first code slice is additive and read-only with respect to production lowering:

- Added `LinkedSpec::ActionIR::AST` as the public internal facade for the parser seam.
  It lazy-loads `LinkedSpec::ActionIR::AST::Parser` through `OwnerDispatch`.
- Added `LinkedSpec::ActionIR::AST::Parser` to parse helper/action text into typed hash
  nodes with `kind`, `source`, and `source_span` fields.
- The parser covers `action_block`, `action_stmt`, `call`, `fluent_chain`, `variable`,
  `indexed_var`, `nested_access`, `array_literal`, `hash_literal`, `block_value`,
  `string`, `number`, `boolean`, `regex`, `undef`, `assign_scalar`,
  `assign_array_append`, `assign_hash_index`, and temporary `raw_perl` fallback nodes.
- `ActionStmt` carries `drops_value => 1`, preserving the contract that a standalone
  helper or future user-function call silently drops its value.
- The parser reuses the existing `StatementSplit` and `MethodExpr` seams, then applies an
  AST-only newline refinement for receiver-chain statements. This does not change
  `StatementSplit` or `RewritePipeline` behavior.
- Added focused test coverage in `t/actionir_ast_parser.t` for calls, literals,
  variables, direct access, shapes, block values, assignments, receiver chains with call,
  number, and block receivers, and a guard that current ActionIR lowering remains
  authoritative.

`RewritePipeline`, `MethodLowering`, and `RuleIR::EmitContext` still use the existing
text-lowering path after this leaf. That is intentional: `.3` switches value-expression
and receiver-chain consumers over under behavior locks.

## PERL-ACTIONIR-AST-MIGRATION.1 Inventory

### Current Text Boundaries

- `LinkedSpec::ActionIR::StatementSplit` and `StatementSplit::Core` own the raw
  action-statement splitter. They scan character-by-character, track delimiter and quote
  state, call `MethodExpr::_parse_method_function_expr(...)` for complete method-looking
  statements, and return raw statement strings.
- `LinkedSpec::ActionIR::MethodExpr` owns the smallest current parse seam. It recognizes
  `method(arg1, arg2, ...)`, normalizes short aliases such as `s`/`a`/`h`/`cat`/`set`, and
  splits top-level CSV arguments while preserving nested delimiters and quotes. Its output
  is still raw text, not AST nodes.
- `LinkedSpec::ActionIR::Scanner`, `ScannerCore`, and the scanner rule families inspect
  raw action text with regex/call-shape probes and emit contract-hit event hashes. These
  events are telemetry and canonicalization inputs, not a typed action AST.
- `LinkedSpec::ActionIR::Contracts` still contains many `lower => sub { ... }` callbacks
  that rewrite helper families by source text. Canonical IR-only contracts exist, but the
  compatibility contract catalog still encodes broad text-to-text lowering behavior.
- `LinkedSpec::ActionIR::CanonicalEvents` builds helper events from split raw statements
  and emits `RAW_PERL` fallback events for unrecognized statements. That fallback is
  migration debt for supported helper/value/control surfaces.
- `LinkedSpec::ActionIR::RewritePipeline` is the decisive source-text replacement
  boundary: `_lower_action_code_from_canonical_ir(...)` matches each canonical event's raw
  statement back into the original source with `index(...)` or a flexible whitespace regex,
  then `substr(...)`-replaces that source span with the lowered Perl string.
- `LinkedSpec::ActionIR::MethodLowering` is the largest recursive text parser/lowerer. It
  repeatedly calls `_lower_method_value_expr(...)`, rewrites return payload helper calls
  with regex substitution, splits receiver-dot chains from raw text, normalizes receiver
  chains by constructing helper-call text, and lowers assignment/mutation statements from
  raw method strings.
- `LinkedSpec::RuleIR::EmitContext` is the bridge that applies ActionIR rewriting to
  action/lifecycle code, exposes wrappers for the parser/lowerer helpers, builds rewrite
  metadata, and still discovers automatic working-variable declarations by scanning raw
  pre-lowered code.
- `LinkedSpec::SpecEntry` and `LinkedSpec::Compiler` still emit/eval generated Perl
  handler source. This is outside the first migration boundary: the immediate doctrine
  violation is helper/action text lowering before source emission, not the existence of a
  Perl code-emission backend.

### Rust-Aligned Perl AST Node Set

The Perl parser seam should model the Rust expression/runtime shape instead of inventing a
separate tree:

- `ActionBlock { statements, source_span }` and `ActionStmt { expr, source_span }`.
  Standalone expression statements evaluate and silently drop their value.
- `Call { name, args, source_span }` for helper calls and later user-defined functions.
  Name resolution may classify a `Call` later, but syntax should not become textual macro
  expansion.
- `FluentChain` / `ReceiverChain { receiver, calls }`, where the receiver is any
  expression, including another function call or a block value.
- Value nodes: `Variable`, typed variable reads for scalar/array/hash wrappers,
  `IndexedVar`, `NestedAccess` with explicit access segments, `ArrayLiteral`,
  `HashLiteral`, `BlockValue`, `StringLiteral`, `NumberLiteral`, `BooleanLiteral`,
  `RegexLiteral`, and `Undef`.
- Mutation/assignment nodes aligned with existing Rust variants and Perl helper families:
  `AssignScalar`, `AssignArrayAppend`, `AssignHashIndex`, `SetKey`, `Push`, and
  `ArrayEndMutation`.
- Statement/control nodes: `Declare`, `Return`, `ReturnUndef`, `If`, `While`, `Switch`,
  `Case`, `Default`, `Say`, `Print`, `PrintEach`, `ExitNow`, and `Next`.
- `RawPerl { source, reason }` remains only as a temporary migration boundary for legacy
  compatibility telemetry. New supported surfaces must not add dependencies on it.

All nodes need source spans for diagnostics and parity with today's raw-event telemetry.
Spans replace fragile raw-statement source replacement; they do not disappear.

### Behavior-Preserving Replacement Order

1. `PERL-ACTIONIR-AST-MIGRATION.2`: introduce `ActionIR::AST` parser modules and focused
   parser tests behind existing behavior. Reuse or port the proven delimiter/quote logic
   from `StatementSplit::Core` and `MethodExpr`; run the parser in parallel for
   diagnostics/parity while `RewritePipeline` remains authoritative.
2. `PERL-ACTIONIR-AST-MIGRATION.3`: switch value-expression and receiver-chain lowering
   first. Replace `_lower_method_value_expr(...)`, `_lower_return_payload_expr(...)`, and
   receiver-dot text normalization with AST lowering that still emits Perl source strings.
3. `PERL-ACTIONIR-AST-MIGRATION.4`: switch statement/control lowering after the value
   seam is stable: assignments, array/hash mutations, declarations, returns, if/when,
   switch/case/default, while, block-local return, print/say, exit, and next.
4. `PERL-ACTIONIR-AST-MIGRATION.5`: retire supported-surface `RAW_PERL` fallback and
   unresolved-helper source-text behavior family by family, replacing accidental host-call
   leakage with LinkedSpec diagnostics and enabling user-defined functions through AST
   `Call` nodes.

Automatic working-variable discovery should move from regex scanning to AST traversal as
soon as the parser seam can cover the relevant action/lifecycle blocks.

## Decisions

- `2026-07-01`: The user explicitly rejected Perl source-text lowering as too fragile and
  adopted the Rust-style text-to-AST path as the cross-variant doctrine. Perl must migrate
  carefully; future Julia/Dart backends, and Lua if later adopted, must start from
  text-to-AST rather than text-to-text lowering.
- `2026-07-01`: The user clarified that `fn <name>(...) { ... }` support should not remain
  in the bootstrap parser after the text-to-AST migration; permanent user-function syntax
  belongs in `specs/spec.spec`, with function calls flowing through AST `Call` nodes.

## Verification Log

| Date | Leaf | Checks | Result |
| --- | --- | --- | --- |
| `2026-07-01` | `PERL-ACTIONIR-AST-MIGRATION.4.4.4` | Added `ControlFlow` AST bridge for attached while controls; added focused fake-source locks for typed condition/body lowering and guard preservation; syntax checks; focused AST parser suite with 19 subtests; phase0 1002 tests; mdBook/doctrine/KM/diff checks; full local CI | Attached while structured controls now lower from typed condition/body AST fields while preserving the existing iteration-safety guard. Frontier moves to `.5`. |
| `2026-07-01` | `PERL-ACTIONIR-AST-MIGRATION.4.4.3` | Added `ControlFlow` AST bridge for switch, case, default, endcase, and endswitch; added focused fake-source locks for attached switch/case/default and marker switch/case/endcase/default/endswitch; syntax checks; focused AST parser suite with 18 subtests; phase0 1002 tests; mdBook/doctrine/KM/diff checks; full local CI | Switch-family structured controls now lower from typed source/match/body/default AST fields while preserving existing switch stack semantics. Frontier moves to `.4.4.4`. |
| `2026-07-01` | `PERL-ACTIONIR-AST-MIGRATION.4.4.2` | Added `ControlFlow` AST bridge for if/i/when, elseif/elif, else/otherwise, and endif; added focused fake-source locks for attached if/elseif/else, when/otherwise, and marker if/elseif/else/endif; syntax checks; focused AST parser suite with 17 subtests; phase0 1002 tests; mdBook/doctrine/KM/diff checks; full local CI | If-family structured controls now lower from typed condition/body AST fields while preserving existing branch semantics. Frontier moves to `.4.4.3`. |
| `2026-07-01` | `PERL-ACTIONIR-AST-MIGRATION.4.4.1` | Added typed control-flow AST parser nodes for attached and marker forms; added focused parser locks for if/when/elseif/elif/else/otherwise/endif/switch/case/default/endcase/endswitch/while, bare and parenthesized markers, plus inline value-helper boundaries; syntax checks; focused AST parser suite with 16 subtests; direct phase0 1002 tests; mdBook/doctrine/KM/diff checks; full local CI | Structured control forms now parse into typed AST nodes with parsed condition/source/match/body/case/default fields while production lowering remains unchanged. Frontier moves to `.4.4.2`. |
| `2026-07-01` | `PERL-ACTIONIR-AST-MIGRATION.4.4` | Split structured-control AST lowering into `.4.4.1` parser nodes, `.4.4.2` if/when/otherwise, `.4.4.3` switch/case/default, and `.4.4.4` while; memory/doctrine/KM/diff checks | Structured-control migration is now owned by focused children before code. Frontier moves to `.4.4.1`. |
| `2026-07-01` | `PERL-ACTIONIR-AST-MIGRATION.4.3` | Added AST block-value bridge, AST side-effect statement lowering inside block values, focused fake-source tests, syntax checks, focused AST parser suite with 15 subtests, phase0 1002 tests, mdBook/doctrine/KM/diff checks, and full local CI | Block-value side effects, block-local returns, and final expressions now consume AST block/statement fields before legacy source-text fallback. Frontier moves to `.4.4`. |
| `2026-07-01` | `PERL-ACTIONIR-AST-MIGRATION.4.2` | Added typed AST statement-call dispatcher, top-level `set`/`assign` bridge, array end-mutation fluent-chain lowering, scanner sentinel path for unsupported `push_nonempty`, focused fake-source tests, syntax checks, focused AST parser suite, phase0 1002 tests, mdBook/doctrine/KM/diff checks, and full local CI | Helper-call statements and returns now consume AST call/fluent-chain fields before legacy source-text paths. Frontier moves to `.4.3`. |
| `2026-07-01` | `PERL-ACTIONIR-AST-MIGRATION.4.1` | Added typed AST assignment/mutation operator materialization and focused fake-source tests for scalar assignment, array append, and hash-index assignment; syntax checks; focused AST parser suite; phase0 1002 tests; mdBook/doctrine/KM/diff checks; full local CI | Assignment/mutation operator statements now consume typed AST node fields before legacy source-text regex paths. Frontier moves to `.4.2`. |
| `2026-07-01` | `PERL-ACTIONIR-AST-MIGRATION.4` | Split statement/control AST lowering into `.4.1` assignment/mutation operator nodes, `.4.2` helper-call statements and returns, `.4.3` block-value side-effect traversal/block-local returns, and `.4.4` structured control-flow forms | Statement/control migration is now owned by focused children before code. Frontier moves to `.4.1`. |
| `2026-07-01` | `PERL-ACTIONIR-AST-MIGRATION.3.4` | Added return-payload AST fast path before raw fallback; focused fake-source tests for typed return arrays/hashes/strings/calls/chains, bare scalar source-slot payloads, unsupported covered chain diagnostics, and raw compatibility payloads; syntax checks; focused AST parser suite; phase0 1002 tests; mdBook/doctrine/KM/diff checks; full local CI | Typed return payloads now consume AST value/call/chain nodes before legacy helper-substitution fallback. Frontier moves to `.4`. |
| `2026-07-01` | `PERL-ACTIONIR-AST-MIGRATION.3.3` | Added AST `fluent_chain` receiver-chain dispatcher; focused fake-source tests for number, string-to-array, block-array, hash-to-array, invalid numeric terminal continuation, and unsupported chain helper diagnostics; targeted public lowering probes | Receiver-dot value chains now consume typed AST receiver/call nodes before legacy receiver-dot text normalization. Frontier moves to `.3.4`. |
| `2026-07-01` | `PERL-ACTIONIR-AST-MIGRATION.3.2.3` | Added unsupported covered-helper sentinel lowering and diagnostics scan; focused tests for malformed value-only, aggregate, and nested helper calls plus descriptor metadata; targeted public lowering probes; mdBook/doctrine/KM/diff checks; phase0 1002 tests; full local CI | Covered helper families no longer leak unsupported AST forms as generated host-language calls. Unsupported covered forms now report unresolved-helper diagnostics with zero raw-Perl fallback. Frontier moves to `.3.3`. |
| `2026-07-01` | `PERL-ACTIONIR-AST-MIGRATION.3.2.2` | Added slot-aware AST aggregate-call dispatcher; focused fake-source AST tests for wrappers, copy, reducers, collection, and hash helpers; targeted public lowering probes; mdBook/doctrine/KM checks; local CI with phase0 1002 tests | Aggregate-wrapper and collection/hash helper calls now consume AST call nodes before helper lowering while preserving deprecated wrapper compatibility, symbol slots, and quoted-name boundaries. Frontier moves to `.3.2.3`. |
| `2026-07-01` | `PERL-ACTIONIR-AST-MIGRATION.3.2.1` | Added AST call dispatcher for value-only helper families; focused fake-source AST call tests; targeted public lowering probes for string, numeric, regex predicate, and coalesce/concat composition | Value-only helper-call composition now consumes AST call nodes before helper lowering; aggregate/symbol-slot helper families were left to `.3.2.2`. |
| `2026-07-01` | `PERL-ACTIONIR-AST-MIGRATION.3.2` | Split AST helper-call lowering into `.3.2.1` value-only helpers, `.3.2.2` aggregate/symbol-slot helpers, and `.3.2.3` diagnostics/host-call leakage retirement | Helper-call AST migration is owned by slot-risk-specific children before code. Frontier moves to `.3.2.1`. |
| `2026-07-01` | `PERL-ACTIONIR-AST-MIGRATION.3.1` | Added `MethodLowering` AST dispatcher for non-call value nodes; focused AST parser/lowering test; targeted lowering probes; phase0 1002 tests | Perl non-call value expressions now lower from AST nodes for literals, scoped bare scalar reads, direct access, shapes, and block values. Helper-call composition, receiver chains, statement/control lowering, and return-payload substitution remain queued. |
| `2026-07-01` | `PERL-ACTIONIR-AST-MIGRATION.3` | Split broad `.3` into `.3.1` non-call value dispatcher, `.3.2` AST helper-call composition, `.3.3` AST receiver chains, and `.3.4` AST return-payload traversal/diagnostics | Value/receiver migration is now owned by narrow children before code. Frontier moves to `.3.1`. |
| `2026-07-01` | `PERL-ACTIONIR-AST-MIGRATION.2` | Added `ActionIR::AST` / `AST::Parser`; focused parser tests; local CI test wiring; KM fact `perl-actionir-ast-parser-seam` + regenerated map; mdBook backend/pipeline/owner-tree status; syntax/focused/phase0/local-CI/diff/memory/doctrine/KM checks | Additive Perl AST parser seam exists behind current lowering behavior. Parser covers calls, literals, variables, direct access, shapes, block values, statements, assignments, and receiver chains; `.3` is the next consumer migration leaf. |
| `2026-07-01` | `PERL-ACTIONIR-AST-MIGRATION.1` | Perl ActionIR text-lowering inventory; Rust-aligned AST node set; replacement order; KM fact `perl-actionir-text-to-ast-inventory` + regenerated map; roadmap/task-tree/live-doc sync; stale-frontier, memory/doctrine/KM/diff checks; mdBook build | Perl text-to-text lowering boundaries are mapped before code. Parser seam `.2` is the next frontier; no parser/compiler/runtime code changed. |
| `2026-07-01` | `PERL-ACTIONIR-AST-MIGRATION.0` | ADR `0011`; KM fact `text-to-ast-backend-doctrine` + regenerated map; mdBook backend-handoff/pipeline/formal/architecture updates; roadmap/task-tree/live-doc sync; memory/doctrine/KM/diff checks; mdBook build | Text-to-AST adopted as a cross-variant doctrine before code. Perl ActionIR text-to-text lowering is now migration debt; future backends must parse helper/action text into typed AST/IR before lowering/execution. No parser/compiler/runtime code changed. |
