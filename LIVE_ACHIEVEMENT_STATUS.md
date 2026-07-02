# LIVE ACHIEVEMENT STATUS
Current execution status for interruption-safe batch workflow recovery.

## Active Batch
- BWFSC target: PNT cycle started 2026-05-16 after PHASE2-DSL-FRONTEND completion and PHASE1A-CLOSE-OUT close-out.
- Push policy: **push every 300 commits** (per 2026-06-16 user directive; raised from 200). Otherwise do not push mid-batch. Currently tracking via `git status -sb` ahead-count.
- Stop policy: stop early only for a real blocker such as unresolved failing tests, ambiguous roadmap direction, conflict with user changes, or a slice expanding beyond a safe boundary.

## Latest Completed Slice
- 2026-07-02: **SPEC-FORMAT-TERSE.3.2.3.4 — numeric comparison symbol callees landed**
  (PERL ACTIONIR + RUST PARSER/RUNTIME + PHASE0 + ORACLE + BOOK/KM).
  Comparison symbol callees are now portable numeric helper calls: `==(a,b)`, `!=(a,b)`, `>(a,b)`,
  `>=(a,b)`, `<(a,b)`, and `<=(a,b)` parse as ordinary `callee(args)` forms and dispatch to
  `num_eq`, `num_ne`, `num_gt`, `num_ge`, `num_lt`, and `num_le` on Perl and Rust.

  The compatibility boundaries are locked: slash regex literals and arithmetic slash calls keep the `.3.2.2`
  behavior; lexical string comparisons stay on `str_eq`/`str_ne`/`str_gt`/`str_ge`/`str_lt`/`str_le`; raw
  `=(target,value)` assignment operator calls remain `.3.3`; and `=>` remains the blind-call edge operator.

  **Verification:** Perl syntax checks PASS; focused Perl lowering/runtime/source probes PASS; focused Rust
  parser/runtime `.3.2.3.4` PASS; oracle regeneration produced **58 fixtures** including
  `terse_3_2_3_4_numeric_comparison_symbol_callees`; Rust corpus oracle PASS; phase0 PASS with **1011 tests**;
  mdBook, Knowledge Map, memory/doctrine/diff checks, and full local CI PASS.

  **Frontier:** `SPEC-FORMAT-TERSE.3.3` (expression-valued assignment and `=(target,value)` equivalence).

- 2026-07-02: **SPEC-FORMAT-TERSE.3.2.3.3 — numeric comparison word aliases landed**
  (PERL ACTIONIR + RUST RUNTIME + SHIPPED SPEC MIGRATION + PHASE0 + ORACLE + BOOK/KM).
  Bare value-call comparison words now use numeric semantics: `eq`, `ne`, `gt`, `ge`, `lt`, and `le` map to
  `num_eq`, `num_ne`, `num_gt`, `num_ge`, `num_lt`, and `num_le` on Perl and Rust. Explicit `num_*` calls and
  number receiver terminals such as `score.gt(3)` remain accepted numeric comparisons.

  Lexical string comparisons are now the explicit `str_eq`, `str_ne`, `str_gt`, `str_ge`, `str_lt`, and
  `str_le` family. Repo-owned specs and phase0 examples that relied on bare word string comparison were
  migrated to `str_*`, including `portmap`, `spec`, `ds_vhistory`, and `simenv` sites. Comparison symbol
  callees remain `.3.2.3.4`.

  **Verification:** Perl syntax checks PASS; focused Perl lowering/runtime/source probes PASS; focused Rust
  runtime `.3.2.3.3` PASS; oracle regeneration produced **57 fixtures** including
  `terse_3_2_3_3_numeric_comparison_word_aliases`; Rust corpus oracle PASS; phase0 PASS with **1010 tests**;
  mdBook, Knowledge Map, memory/doctrine/diff checks, and full local CI PASS.

  **Frontier:** `SPEC-FORMAT-TERSE.3.2.3.4` (numeric comparison symbol callees), then `.3.3`.

- 2026-07-02: **SPEC-FORMAT-TERSE.3.2.3.2 — explicit string comparison helpers landed**
  (PERL ACTIONIR + RUST RUNTIME + PHASE0 + ORACLE + BOOK/KM).
  The explicit string-comparison bridge is now runnable: `str_eq`, `str_ne`, `str_gt`, `str_ge`, `str_lt`, and
  `str_le` lower/dispatch as lexical string predicates on Perl and Rust. These names are now preferred for new
  text comparisons.

  Bare `eq(...)`, `ne(...)`, `gt(...)`, `ge(...)`, `lt(...)`, and `le(...)` remain runnable string-comparison
  compatibility aliases until `.3.2.3.3` flips ordinary comparison word calls to numeric `num_*` aliases.
  Comparison symbol callees remain `.3.2.3.4`.

  **Verification:** Perl syntax checks PASS; focused Rust runtime `.3.2.3.2` PASS; oracle regeneration produced
  **56 fixtures** including `terse_3_2_3_2_string_comparison_helpers`; Rust corpus oracle PASS; phase0 PASS with
  **1009 tests**; mdBook, Knowledge Map, memory/doctrine/diff checks, and full local CI PASS.

  **Then-frontier:** `SPEC-FORMAT-TERSE.3.2.3.3` (now done), then `.3.2.3.4` and `.3.3`.

- 2026-07-02: **SPEC-FORMAT-TERSE.3.2.3.1 — string comparison bridge contract locked**
  (TASK TREE + ROADMAP + BOOK/KM + LIVE DOCS; **no parser/compiler/runtime code change**).
  The explicit string-comparison bridge names are now contract-locked before implementation:
  `str_eq`, `str_ne`, `str_gt`, `str_ge`, `str_lt`, and `str_le`. They preserve today's lexical string
  comparison semantics and are intentionally not numeric helpers, receiver-dot links, or symbol callees.

  Current shipped behavior remains unchanged. Bare `eq(...)`, `ne(...)`, `gt(...)`, `ge(...)`, `lt(...)`, and
  `le(...)` are still the runnable string comparison helpers. The book names `str_*` as the accepted bridge but
  states that those names are not shipped until `.3.2.3.2` implements them.

  **Verification:** `perl -Iperl -c perl/LinkedSpec/ActionIR/FlowExpr.pm` PASS; Knowledge Map regenerate/check
  PASS; memory/doctrine/diff checks PASS; mdBook build PASS; full local CI PASS with phase0 **1008 tests**.

  **Then-frontier:** `SPEC-FORMAT-TERSE.3.2.3.2` (now done), then `.3.2.3.3`, `.3.2.3.4`, and `.3.3`.

- 2026-07-02: **SPEC-FORMAT-TERSE.3.2.3 — comparison call surface split/owned**
  (TASK TREE + ROADMAP + BOOK/KM + LIVE DOCS; **no parser/compiler/runtime code change**).
  The comparison operator-call migration is now split before implementation. Current shipped behavior remains:
  numeric comparisons use `num_eq`/`num_ne`/`num_gt`/`num_ge`/`num_lt`/`num_le` or receiver terminals such as
  `score.gt(3)`, while bare `eq(...)`, `ne(...)`, `gt(...)`, `ge(...)`, `lt(...)`, and `le(...)` remain string
  comparisons in documented flow/helper contexts.

  The future canonical numeric comparison call surface is ordinary `callee(args)` form with word/symbol pairs:
  `eq`/`==`, `ne`/`!=`, `gt`/`>`, `ge`/`>=`, `lt`/`<`, and `le`/`<=`, all mapping to the existing `num_*`
  comparison helpers. Because of the string-compatibility conflict, the implementation frontier is split:
  `.3.2.3.1` string bridge contract, `.3.2.3.2` explicit `str_*` helpers, `.3.2.3.3` numeric comparison word
  aliases, and `.3.2.3.4` comparison symbol callees.

  **Verification:** focused KM/TOOLBOX/source/mdBook audit complete; Knowledge Map regenerate/check PASS;
  memory/doctrine/diff checks PASS; mdBook build PASS; full local CI PASS with phase0 **1008 tests**.

  **Then-frontier:** `SPEC-FORMAT-TERSE.3.2.3.1` (explicit string-comparison bridge contract; now done),
  then `.3.2.3.2`, `.3.2.3.3`, `.3.2.3.4`, and `.3.3`.

- 2026-07-02: **SPEC-FORMAT-TERSE.3.2.2 — arithmetic symbol callees landed**
  (PERL ACTIONIR + RUST PARSER/RUNTIME + PHASE0 + ORACLE + BOOK/KM).
  Arithmetic symbol calls are now portable helper calls: `+(a,b)`, `-(a,b)`, `*(a,b)`, `/(a,b)`, and `%(a,b)`
  parse as ordinary `callee(args)` forms and dispatch to `num_add`, `num_sub`, `num_mul`, `num_div`, and
  `num_mod` on both Perl and Rust. Nested symbol calls compose through the same numeric helper family.

  Slash-call recognition is intentionally narrow. The scanner accepts `/(` as division only with a balanced
  parenthesized argument list and a safe call boundary, while preserving slash regex literals such as `/(\))/`
  and `/(?<!\\)}/`.

  **Verification:** Perl syntax checks PASS; focused Perl lowering/runtime/source probes PASS; full phase0 PASS
  with **1008 tests**; oracle regeneration produced **55 fixtures** including
  `terse_3_2_2_arithmetic_symbol_callees`; Rust corpus oracle PASS; Rust core PASS; focused Rust runtime `.3.2.2`
  PASS; mdBook, memory/Knowledge Map/doctrine/diff checks, and full local CI PASS. A broader full Rust runtime
  integration run also shows the new `.3.2.2` test passing but still contains unrelated stale `s(...)`/`a(...)`/`h(...)`
  short-wrapper tests from the prior alias-retirement baseline.

  **Then-frontier:** `SPEC-FORMAT-TERSE.3.2.3` (later split through `.3.2.3.4` before `.3.3`), then `.3.3`.

- 2026-07-02: **SPEC-FORMAT-TERSE.4.4 — user-function surface finalized**
  (BOOK + TASK TREE + KNOWLEDGE MAP + LIVE DOCS).
  The public contract now closes the portable user-function MVP after Perl/Rust parity: top-level
  `fn name(args) { ... }`, explicit parentheses for every arity including `fn name() { ... }`, braced
  value-oriented bodies, exact arity, fresh function-local stores, final-expression or `return(expr)` results,
  ordinary value-call composition, compatible receiver-chain continuation, and standalone result discard.

  The deferred ledger is explicit: `function ... endfunction`, `fn ... endfn`, optional zero-arg parentheses,
  brace-less bodies, caller-state/parser-state/persistent side-effect functions, recursive user functions,
  closures, lambdas, currying/partial application, and namespace/module features require future task-tree
  ownership before any implementation.

  **Verification:** mdBook build, memory/doctrine/Knowledge Map checks, diff check, and full local CI all pass.
  No parser/compiler/runtime code changed.

  **Frontier:** `SPEC-FORMAT-TERSE.3.2.2` (arithmetic symbol callees), then `.3.2.3`, `.3.3`.

- 2026-07-02: **SPEC-FORMAT-TERSE.4.3.2 — Rust user-function runtime parity landed**
  (RUST RUNTIME + ORACLE CORPUS + BOOK/KM/LIVE DOCS).
  Rust registered user-function calls now resolve before ordinary helper fallback, check exact arity, evaluate
  arguments eagerly in the caller context, bind params into fresh function-local scalar/array/hash stores, and
  evaluate compiled function `CodeBlock` bodies for final-expression or `return(expr)` results.

  Returned values feed compatible receiver-dot chains by runtime type, so user functions can return arrays,
  hashes, strings, and numbers into the existing fluent value-chain surface. Standalone registered calls execute
  through the same value path and discard their result. Function-local variables are restored away after return,
  and direct/mutual recursion diagnoses deterministically.

  **Verification:** focused Rust runtime `.4.3.2` locks PASS; oracle generation PASS; Rust corpus oracle PASS
  with **54 fixtures** including `terse_4_3_2_user_function_runtime`; Rust runtime lib and Rust core suites PASS;
  mdBook build, memory/doctrine/Knowledge Map checks, diff check, and full local CI all pass.

  **Frontier:** `SPEC-FORMAT-TERSE.4.4` (function surface finalization and deferred extension ledger), then
  `.3.2.2`, `.3.2.3`.

- 2026-07-02: **SPEC-FORMAT-TERSE.4.3.1 — Rust user-function registry parity landed**
  (RUST AST/PARSER/VALIDATION/COMPILER + BOOK/KM/LIVE DOCS).
  Rust `.spec` parsing now extracts top-level `fn name(args) { ... }` declarations before or between rule
  paragraphs into `SpecFile.functions`, preserving ordered params, exact arity, source/body spans, original
  source, and body source. Rule parsing is preserved, and function definitions do not become raw rule body text.

  Rust validation rejects duplicate functions, rule-label collisions, helper/control-name collisions including
  numeric word aliases, lifecycle/runtime/function-keyword collisions, invalid params, duplicate params, and
  reserved params before runtime. Rust compilation now projects definitions into `CompiledSpec.functions` as `CompiledUserFunction`
  records with parsed `CodeBlock` bodies and source metadata. Runtime user-call execution remains explicitly
  unclaimed until `.4.3.2`.

  **Verification:** Rust format check, `linkedspec-core`, `linkedspec-runtime --lib`, Rust corpus oracle, mdBook
  build, memory/doctrine/Knowledge Map checks, diff check, and full local CI all pass.

  **Frontier:** `SPEC-FORMAT-TERSE.4.3.2` (Rust user-function runtime parity and oracle fixtures), then
  `.3.2.2`, `.3.2.3`.

- 2026-07-01: **SPEC-FORMAT-TERSE.4.2.3 — Perl user-function standalone discard/hardening landed**
  (ACTIONIR CANONICAL EVENTS + VALUE_DROP + METHOD LOWERING + PHASE0 + BOOK/KM/LIVE DOCS).
  Registered standalone `fn name(...)` calls and receiver chains now compute their value through the same
  user-function lowering path as value-position calls, then discard it as canonical `VALUE_DROP` with zero raw
  fallback. The classifier is registry-aware, so unknown unregistered standalone calls remain raw compatibility
  debt instead of being swept into the user-function path.

  Phase0 also locks nested user-function parameter passing, direct and mutual recursion diagnostics,
  parser-state helper bodies, host-code-shaped bodies, and nested function syntax as unresolved-helper metadata
  with zero raw fallback. Focused AST suite, full phase0 (**1007 tests**), mdBook build, memory/doctrine/Knowledge
  Map checks, diff check, and full local CI all pass.

  **Frontier:** `SPEC-FORMAT-TERSE.4.3.1` (Rust function-definition AST/compiler registry parity), then
  `.4.3.2`, `.3.2.2`, `.3.2.3`.

- 2026-07-01: **SPEC-FORMAT-TERSE.4.2.2 — Perl user-function value-call execution landed**
  (COMPILER REGISTRY THREADING + ACTIONIR METHOD LOWERING + PHASE0 + BOOK/KM/LIVE DOCS).
  Registered exact-arity `fn name(args) { ... }` calls now execute in Perl value positions instead of remaining
  unresolved-helper diagnostics. Calls evaluate args eagerly in the caller, bind positional params into fresh
  function-local lexicals, lower body AST statements inside a value-producing `do { ... }`, and return either a
  final expression or function-local `return(expr)` payload.

  Phase0 locks composition through `return(...)`, assignment RHS, array append RHS, hash mutation value, helper
  arguments, returned-value receiver chains, final-expression bodies, non-final function-local returns, and
  local/caller shadowing. Wrong-arity registered calls remain unresolved-helper metadata with zero raw fallback.
  Standalone result discard, recursion/purity hardening, and unsupported body-effect diagnostics landed in
  `.4.2.3`; Rust parity remains tracked under `.4.3`.

  **Frontier after this historical leaf:** `.4.2.3`, then `.4.3.1`, `.4.3.2`, `.3.2.2`, `.3.2.3`.

- 2026-07-01: **SPEC-FORMAT-TERSE.4.2.1 — Perl user-function registry seam landed**
  (SPEC.SPEC + PERL COMPILER STATE/DESCRIPTOR + PHASE0 + BOOK/KM/LIVE DOCS; registry-only leaf).
  `specs/spec.spec` now has an active `function_definition` part for top-level `fn name(args) { body }` and
  dispatches it from `spec_file`. The Perl reference uses a documented temporary pre-bootstrap registry bridge:
  it extracts top-level function definitions, strips them from the source passed to ordinary validation/bootstrap
  while preserving newlines, parses bodies through the ActionIR AST block parser, and attaches the registry to
  compiled state.
  **Descriptor:** public descriptors now expose `functions`, `meta.function_order`, and `meta.function_count`.
  Each definition records ordered params, arity, source/body spans, body source, and `body_ast`. Diagnostics reject
  duplicate functions, invalid/duplicate params, reserved runtime/lifecycle/function symbols, built-in helper or
  control-name collisions, and rule-label collisions before runtime.
  **Boundary:** registered value-position calls still diagnose as unresolved helpers with zero raw fallback and
  remain not ActionIR-ready until `.4.2.2`; standalone discard and purity hardening remain `.4.2.3`.
  **Verification:** Perl syntax checks PASS for registry/compiler/compiler-state/phase0; focused descriptor probes
  PASS; `specs/spec.spec` descriptor compile ratio **1.0000**; focused AST suite PASS; `mdbook build
  docs/linkedspec-book`, memory architecture, Knowledge Map, doctrine registry, and `git diff --check` PASS;
  `bash tools/run_ci_local.sh` PASS with phase0 **1005 tests**.
  **Frontier:** `SPEC-FORMAT-TERSE.4.2.2` (Perl user-function value-call execution), then `.4.2.3`, `.4.3.1`,
  `.4.3.2`, and `.3.2.2`.
- 2026-07-01: **SPEC-FORMAT-TERSE.4.1 — user-function contract/inventory locked**
  (TASK TREE + ROADMAP + BOOK/KM/LIVE DOCS; **no parser/compiler/runtime code change**). The function MVP is
  now exact before implementation: top-level `fn name(args) { ... }`, exact arity, eager argument evaluation,
  fresh function-local parameter/work-variable scope, pure value/block body, final-expression or `return(expr)`
  result, receiver-chain composition from returned values, and silent discard for standalone user-function call
  statements. Collision boundaries are explicit: function names must not collide with built-in helpers,
  control/lifecycle keywords, rule labels, reserved runtime symbols, or another function definition; parameters
  must be unique valid non-reserved identifiers.
  **Inventory:** `specs/spec.spec` owns final function grammar but has no active `function_definition` rule yet.
  Bootstrap has no first-class `fn` support. Perl ActionIR already parses user-call shapes and diagnoses
  value-position unknown calls through unresolved-helper metadata; standalone unknown calls remain raw until the
  registry owns discard. Rust already parses call/fluent expression shapes, but unknown names fall through
  `Engine::call_helper` to warning+`undef`; Rust needs a registry resolver before helper fallback.
  **Verification:** focused TOOLBOX probes PASS; source/book inventory complete; Knowledge Map regenerate/check,
  memory architecture, doctrine registry, `mdbook build docs/linkedspec-book`, `git diff --check`, and
  `bash tools/run_ci_local.sh` PASS. Full local CI included phase0 **1004 tests**.
  **Frontier:** `SPEC-FORMAT-TERSE.4.2.1` (Perl function-definition grammar/registry seam), then `.4.2.2`,
  `.4.2.3`, `.4.3.1`, `.4.3.2`, and `.3.2.2`.
- 2026-07-01: **PERL-ACTIONIR-AST-MIGRATION.5.4 — `fn` grammar ownership locked**
  (SPEC.SPEC POLICY + PHASE0 LOCK + BOOK/KM/LIVE DOCS). `specs/spec.spec` now states that permanent
  `fn name(args) { ... }` grammar belongs to the self-hosted grammar surface, not to lasting hardcoded bootstrap
  support. Phase0 locks prove `BootstrapSpec.pm` and `BootstrapSpec/Core.pm` have no `fn name(...)` grammar
  pattern or named function-definition node support; current bootstrap parsing of `fn`-shaped text yields only
  generic unsupported paragraph content, not a structured function node/payload.
  **Verification:** `perl -Iperl -c t/phase0_regression.t` PASS; direct bootstrap parse probe PASS; targeted
  source `rg` PASS; `prove -Iperl t/phase0_regression.t` PASS with phase0 **1004 tests**; `mdbook build
  docs/linkedspec-book`, memory architecture, Knowledge Map, doctrine registry, `git diff --check`, and
  `bash tools/run_ci_local.sh` PASS.
  **Frontier:** Perl ActionIR text-to-AST migration is closed by this leaf; PNT returns to
  `SPEC-FORMAT-TERSE.4.1` for user-defined function contract/inventory.
- 2026-07-01: **PERL-ACTIONIR-AST-MIGRATION.5.3.2 — unknown AST value calls diagnose**
  (PERL ACTIONIR + FOCUSED TEST + PHASE0 + BOOK/KM/LIVE DOCS). Unknown typed calls in return/value positions
  now diagnose through `LINKEDSPEC_UNSUPPORTED_ACTIONIR_HELPER:<name>` instead of leaking generated host calls.
  `return(user_fn("x"))` and `return(user_fn("x").trim())` no longer emit host `user_fn(...)`; descriptor
  metadata records unresolved helper `user_fn` and blocks language-agnostic readiness. Existing DSL and
  compatibility helper names are fenced as known so declaration aliases, retired return helpers, source-boundary
  helpers, internal trace calls, and statement-only array mutation methods are not mistaken for future user
  functions. Standalone unknown function-shaped statements remain raw until the function registry owns discard
  semantics.
  **Verification:** syntax checks PASS for touched ActionIR modules and `t/actionir_ast_parser.t`; focused
  probes PASS for unknown return calls/chains, supported `call(...)`/`input_text()` payloads, flow helper
  composition, declaration aliases, and unsupported array mutation value chains; `prove -Iperl
  t/actionir_ast_parser.t` PASS with **20 subtests**; `prove -Iperl t/phase0_regression.t` PASS with phase0
  **1003 tests**; `mdbook build docs/linkedspec-book`, memory architecture, Knowledge Map, doctrine registry,
  `git diff --check`, and `bash tools/run_ci_local.sh` PASS.
  **Then-frontier:** `PERL-ACTIONIR-AST-MIGRATION.5.4`, now complete.
- 2026-07-01: **PERL-ACTIONIR-AST-MIGRATION.5.3.1 — short wrapper aliases retired**
  (PERL ACTIONIR + RUST CORE/RUNTIME + SPECS/FIXTURES + PHASE0 + BOOK/KM/LIVE DOCS). `s(...)`, `a(...)`, and
  `h(...)` are no longer canonical wrapper spellings. Repo-owned specs, corpus fixtures, tests, root guides, and
  mdBook examples now use `scalar(...)`, `array(...)`, and `hash(...)`. Perl lowering no longer normalizes the
  short names into long wrappers; residual calls diagnose as `LINKEDSPEC_UNSUPPORTED_ACTIONIR_HELPER:s|a|h`
  with zero raw-Perl fallback. Rust core/runtime wrapper examples and dispatch paths now use the canonical names.
  **Verification:** residual shorthand scan over specs/corpora clean; syntax checks PASS for touched ActionIR
  modules/tests; `prove -Iperl t/actionir_ast_parser.t` PASS; `prove -Iperl t/phase0_regression.t` PASS with
  phase0 **1003 tests**; `cargo test --manifest-path rust/Cargo.toml -p linkedspec-core --lib` PASS with **140
  tests**; `cargo test --manifest-path rust/Cargo.toml -p linkedspec-runtime --lib` PASS with **117 tests**;
  `mdbook build docs/linkedspec-book`, memory architecture, Knowledge Map, doctrine registry, `git diff --check`,
  and `bash tools/run_ci_local.sh` PASS.
  **Frontier:** `PERL-ACTIONIR-AST-MIGRATION.5.3.2` user-function AST call handoff.
- 2026-07-01: **PERL-ACTIONIR-AST-MIGRATION.5.3 — short wrapper alias retirement split**
  (TASK TREE + LIVE DOCS + KM; **no parser/compiler/runtime code change**). User clarified that `s(...)`,
  `a(...)`, and `h(...)` should be retired too. Read-only discovery found active use in shipped specs, phase0
  locks, and book examples, so the former `.5.3` user-function handoff leaf was split: `.5.3.1` retired the
  shorthand wrapper aliases and `.5.3.2` completed the value-position user-function AST diagnostic handoff.
  **Verification:** usage discovery completed; memory/doctrine/Knowledge Map gates PASS; `git diff --check` PASS.
  **Frontier:** `PERL-ACTIONIR-AST-MIGRATION.5.3.1` retire `s(...)`, `a(...)`, and `h(...)`.
- 2026-07-01: **PERL-ACTIONIR-AST-MIGRATION.5.2 — dropped value statement lowering**
  (PERL ACTIONIR + FOCUSED TEST + BOOK/KM/LIVE DOCS). Supported standalone value statements that already parse
  into typed ActionIR AST value nodes now lower as discarded values through a `VALUE_DROP` contract. `trim(" x ")`,
  `concat("a","b")`, and simple receiver chains such as `" x ".trim()` no longer remain raw host-call text; they
  lower through the existing value-expression dispatcher and then discard the result. Malformed covered standalone
  helpers still report unresolved-helper metadata with zero raw fallback, compatibility `s(...)`/`a(...)`/`h(...)`
  substitution still returns value expressions, and unknown user-function-shaped calls/chains stay raw for `.5.3`.
  **Verification:** syntax checks PASS for touched ActionIR modules and `t/actionir_ast_parser.t`; focused
  `t/actionir_ast_parser.t` PASS with **20 subtests**; `prove -q -Iperl t/phase0_regression.t` PASS with phase0
  **1002 tests**; `mdbook build docs/linkedspec-book` PASS; memory/doctrine/Knowledge Map gates PASS;
  `git diff --check` PASS; `bash tools/run_ci_local.sh` PASS.
  **Frontier:** `PERL-ACTIONIR-AST-MIGRATION.5.3` prepare user-function calls to resolve through AST call nodes.
- 2026-07-01: **PERL-ACTIONIR-AST-MIGRATION.5.1 — fallback-boundary audit**
  (TASK TREE + BOOK/KM/LIVE DOCS; **no parser/compiler/runtime code change**). The remaining Perl ActionIR
  fallback boundary is now classified before code. Malformed AST-covered helper forms already use
  unresolved-helper diagnostics with zero raw fallback; retired helpers and non-DSL host-shaped statements stay
  explicit compatibility debt; narrow return payload compatibility remains fenced; all-bare `push(A,B)` remains
  the child-call ambiguity contract. Unknown typed calls/chains such as `return(user_fn("x"))` and
  `return(user_fn("x").trim())` were the real handoff risk because they lowered as generated host calls
  and reported ready at the time; `.5.3.2` has since resolved value-position cases as diagnostics. Targeted search found no current
  lasting `fn <name>(...) { ... }` grammar in bootstrap or `specs/spec.spec`; `.5.4` still owns the grammar/proof
  lock.
  **Verification:** TOOLBOX `call_spec_handler_subst`, descriptor, and AST parser probes PASS; code reads
  completed for the lowering/metadata seams. `mdbook build docs/linkedspec-book` PASS; memory/doctrine/Knowledge
  Map gates PASS; `git diff --check` PASS; `bash tools/run_ci_local.sh` PASS with focused AST suite and phase0
  **1002 tests**.
  **Frontier:** `PERL-ACTIONIR-AST-MIGRATION.5.2` retire AST-covered supported-surface fallback leakage without
  disturbing the fenced compatibility debt.
- 2026-07-01: **PERL-ACTIONIR-AST-MIGRATION.5 — fallback retirement and function handoff split**
  (TASK TREE + LIVE DOCS; **no parser/compiler/runtime code change**). The final Perl ActionIR AST migration
  parent is now split before code into `.5.1` fallback-boundary audit, `.5.2` AST-covered supported-surface
  fallback leakage retirement, `.5.3` user-function AST call handoff, and `.5.4` `specs/spec.spec` function
  grammar plus bootstrap-parser retirement lock. The split preserves the user decision that lasting
  `fn <name>(...) { ... }` grammar belongs in `specs/spec.spec`, while bootstrap parser support is temporary
  migration debt to remove or prove absent after the AST path can carry the surface.
  **Verification:** `mdbook build docs/linkedspec-book` PASS; memory/doctrine/Knowledge Map gates PASS;
  `git diff --check` PASS.
  **Frontier:** `PERL-ACTIONIR-AST-MIGRATION.5.1` audit the remaining supported-surface text fallback boundary
  before code.
- 2026-07-01: **PERL-ACTIONIR-AST-MIGRATION.4.4.4 — while control lowering from AST**
  (PERL ACTIONIR CONTROLFLOW + FOCUSED TEST + BOOK/KM/LIVE DOCS). `LinkedSpec::ActionIR::ControlFlow` now
  parses attached `while(cond) { ... }` statements through the ActionIR AST parser before reusing the existing
  while lowerer. Loop conditions and attached body statements materialize from typed AST fields, not original
  statement text or AST `source` strings. Generated loop shape, condition re-evaluation, body lowering, and the
  deterministic 10000-iteration safety guard stay stable. Bodyless `while(...)` marker nodes remain parser
  shape only because the current DSL has no `endwhile` product syntax.
  **Verification:** `perl -Iperl -c perl/LinkedSpec/ActionIR/ControlFlow.pm` PASS;
  `perl -Iperl -c t/actionir_ast_parser.t` PASS; `prove -v -Iperl t/actionir_ast_parser.t` PASS with **19
  focused subtests**; `perl -c perl/LinkedSpec.pm` PASS; `perl -c -Iperl t/phase0_regression.t` PASS;
  `prove -q -Iperl t/phase0_regression.t` PASS with phase0 **1002 tests**; `mdbook build
  docs/linkedspec-book` PASS; memory/doctrine/Knowledge Map gates PASS; `git diff --check` PASS; `bash
  tools/run_ci_local.sh` PASS.
  **Frontier:** `PERL-ACTIONIR-AST-MIGRATION.5` retire supported-surface text fallback and unblock
  user-defined functions on the AST path; split before code if needed.
- 2026-07-01: **PERL-ACTIONIR-AST-MIGRATION.4.4.3 — switch-family control lowering from AST**
  (PERL ACTIONIR CONTROLFLOW + FOCUSED TEST + BOOK/KM/LIVE DOCS). `LinkedSpec::ActionIR::ControlFlow` now
  parses `switch`, `case`, `default`, `endcase`, and `endswitch` statements through the ActionIR AST parser
  before reusing the existing switch stack lowering engine. Switch source expressions, case match values,
  attached case/default bodies, parsed switch branch lists, and end markers materialize from typed AST fields,
  not original statement text, fake fallback bodies, or AST `source` strings. Generated switch shape,
  switch-source single evaluation, case ordering, default-once behavior, attached-switch body handling, and
  marker `endcase`/`endswitch` stack closure stay stable.
  **Verification:** `perl -Iperl -c perl/LinkedSpec/ActionIR/ControlFlow.pm` PASS;
  `perl -Iperl -c t/actionir_ast_parser.t` PASS; `prove -v -Iperl t/actionir_ast_parser.t` PASS with **18
  focused subtests**; `perl -c perl/LinkedSpec.pm` PASS; `perl -c -Iperl t/phase0_regression.t` PASS;
  `prove -q -Iperl t/phase0_regression.t` PASS with phase0 **1002 tests**; `mdbook build
  docs/linkedspec-book` PASS; memory/doctrine/Knowledge Map gates PASS; `git diff --check` PASS; `bash
  tools/run_ci_local.sh` PASS.
  **Frontier:** `PERL-ACTIONIR-AST-MIGRATION.4.4.4` lower `while` statement forms from typed condition/body
  nodes while preserving the iteration-safety guard.
- 2026-07-01: **PERL-ACTIONIR-AST-MIGRATION.4.4.2 — if-family control lowering from AST**
  (PERL ACTIONIR CONTROLFLOW + FOCUSED TEST + BOOK/KM/LIVE DOCS). `LinkedSpec::ActionIR::ControlFlow` now
  parses `if`/`i`/`when`, `elseif`/`elif`, `else`/`otherwise`, and `endif` statements through the ActionIR AST
  parser before reusing the existing branch lowering engine. Conditions and attached bodies materialize from
  typed AST fields, not original statement text or AST `source` strings; generated branch shape, implicit-close
  behavior, marker `endif`, and when/otherwise alias semantics stay stable.
  **Verification:** `perl -Iperl -c perl/LinkedSpec/ActionIR/ControlFlow.pm` PASS;
  `perl -Iperl -c t/actionir_ast_parser.t` PASS; `prove -v -Iperl t/actionir_ast_parser.t` PASS with **17
  focused subtests**; `perl -c perl/LinkedSpec.pm` PASS; `perl -c -Iperl t/phase0_regression.t` PASS;
  `prove -q -Iperl t/phase0_regression.t` PASS with phase0 **1002 tests**; `mdbook build
  docs/linkedspec-book` PASS; memory/doctrine/Knowledge Map gates PASS; `git diff --check` PASS; `bash
  tools/run_ci_local.sh` PASS.
  **Frontier:** `PERL-ACTIONIR-AST-MIGRATION.4.4.3` lower `switch`/`case`/`default` statement forms from typed
  source/match/body/default nodes.
- 2026-07-01: **PERL-ACTIONIR-AST-MIGRATION.4.4.1 — structured control AST parser nodes**
  (PERL ACTIONIR AST PARSER + FOCUSED TEST + BOOK/KM/LIVE DOCS; **production lowering unchanged**).
  `LinkedSpec::ActionIR::AST::Parser` now parses attached-block and marker control-flow forms into typed
  `control_if`, `control_else`, `control_endif`, `control_while`, `control_switch`, `control_case`,
  `control_default`, `control_endcase`, and `control_endswitch` nodes. Conditions, switch source expressions,
  case match expressions, attached bodies, body source spans, and switch case/default branches are typed where
  applicable. Inline value-form `if(...)` / `switch(...)` helpers still parse as generic `call` nodes.
  **Verification:** `perl -Iperl -c perl/LinkedSpec/ActionIR/AST/Parser.pm` PASS;
  `perl -Iperl -c t/actionir_ast_parser.t` PASS; `prove -v -Iperl t/actionir_ast_parser.t` PASS with **16
  focused subtests**; `perl -c perl/LinkedSpec.pm` PASS; `perl -c -Iperl t/phase0_regression.t` PASS; direct
  `perl -Iperl t/phase0_regression.t` PASS with phase0 **1002 tests**; `mdbook build docs/linkedspec-book`
  PASS; memory/doctrine/Knowledge Map gates PASS; `git diff --check` PASS; `bash tools/run_ci_local.sh` PASS.
  **Frontier:** `PERL-ACTIONIR-AST-MIGRATION.4.4.2` lower `if`/`when`/`otherwise` statement forms from typed
  condition/body nodes.
- 2026-07-01: **PERL-ACTIONIR-AST-MIGRATION.4.4 — structured-control AST lowering split**
  (TASK TREE + ROADMAP/LIVE DOCS; **no runtime behavior change**). The broad structured-control migration is
  now split before code into `.4.4.1` typed control-flow AST parser nodes and node-shape locks, `.4.4.2`
  `if`/`when`/`otherwise` lowering from AST, `.4.4.3` `switch`/`case`/`default` lowering from AST, and `.4.4.4`
  `while` lowering from AST while preserving iteration-safety behavior.
  **Verification:** memory/doctrine/Knowledge Map gates PASS; `git diff --check` PASS.
  **Frontier:** `PERL-ACTIONIR-AST-MIGRATION.4.4.1` add typed control-flow AST parser nodes and focused parser
  locks before switching lowering consumers.
- 2026-07-01: **PERL-ACTIONIR-AST-MIGRATION.4.3 — block-value side effects and block-local returns from AST**
  (PERL ACTIONIR + FOCUSED TEST + BOOK/KM/LIVE DOCS). `MethodLowering` now routes parsed `block_value` nodes
  into the AST value path before legacy block splitting. Inside AST block values, non-final side-effect
  statements lower from typed `action_stmt.expr` nodes, block-local `return(...)` payloads lower from typed call
  arguments, and final expressions lower from typed statement expressions while the existing guarded early-return
  wrapper stays stable.
  **Verification:** `perl -Iperl -c perl/LinkedSpec/ActionIR/MethodLowering.pm` PASS;
  `perl -Iperl -c t/actionir_ast_parser.t` PASS; `prove -q -Iperl t/actionir_ast_parser.t` PASS with **15
  focused subtests**; `prove -q -Iperl t/phase0_regression.t` PASS with phase0 **1002 tests**; `mdbook build
  docs/linkedspec-book` PASS; memory/doctrine/Knowledge Map gates PASS; `git diff --check` PASS; `bash
  tools/run_ci_local.sh` PASS.
  **Frontier:** `PERL-ACTIONIR-AST-MIGRATION.4.4` split structured control-flow statement AST lowering.
- 2026-07-01: **PERL-ACTIONIR-AST-MIGRATION.4.2 — helper-call statements and returns from AST**
  (PERL ACTIONIR + SCANNER DIAGNOSTIC + FOCUSED TEST + BOOK/KM/LIVE DOCS). `MethodLowering` now consumes typed
  AST `call` nodes for `return`, `return_undef`, `set_key`, `push`, `push_value`, and `push_nonempty`, and
  typed `fluent_chain` nodes for array end-mutation statements. `DeclareMethod` bridges top-level `set`/`assign`
  through the same AST materialization while preserving the synthetic dependency-builder contract.
  **Verification:** `perl -Iperl -c perl/LinkedSpec/ActionIR/MethodLowering.pm` PASS;
  `perl -Iperl -c perl/LinkedSpec/ActionIR/DeclareMethod.pm` PASS; `perl -Iperl -c
  perl/LinkedSpec/ActionIR/Scanner/PrimitivePipelineRules.pm` PASS; `perl -Iperl -c
  t/actionir_ast_parser.t` PASS; `prove -v -Iperl t/actionir_ast_parser.t` PASS; `prove -q -Iperl
  t/phase0_regression.t` PASS with phase0 **1002 tests**; `mdbook build docs/linkedspec-book` PASS;
  memory/doctrine/Knowledge Map gates PASS; `git diff --check` PASS; `bash tools/run_ci_local.sh` PASS.
  **Frontier:** `PERL-ACTIONIR-AST-MIGRATION.4.3` lower block-value side-effect statements and block-local
  returns from AST block/statement nodes.
- 2026-07-01: **PERL-ACTIONIR-AST-MIGRATION.4.1 — assignment/mutation statement operators from AST**
  (PERL ACTIONIR + FOCUSED TEST + BOOK/KM/LIVE DOCS). `MethodLowering` now consumes typed AST
  `assign_scalar`, `assign_array_append`, and `assign_hash_index` nodes before the legacy statement-regex
  paths. The implementation materializes trusted helper/action expression text from typed AST fields, then
  enters the existing scalar assignment, array append, and hash-index mutation policies so target-kind
  inference, source-slot scalar reads, mutation value-slot reads, and hash-key lowering stay stable.
  **Verification:** `perl -Iperl -c perl/LinkedSpec/ActionIR/MethodLowering.pm` PASS;
  `perl -Iperl -c t/actionir_ast_parser.t` PASS; `perl -Iperl -c perl/LinkedSpec.pm` PASS;
  `prove -v -Iperl t/actionir_ast_parser.t` PASS; `prove -q -Iperl t/phase0_regression.t` PASS with phase0
  **1002 tests**; `mdbook build docs/linkedspec-book` PASS; memory/doctrine/Knowledge Map gates PASS;
  `git diff --check` PASS; `bash tools/run_ci_local.sh` PASS.
  **Frontier:** `PERL-ACTIONIR-AST-MIGRATION.4.2` lower helper-call statements and returns from AST call nodes.
- 2026-07-01: **PERL-ACTIONIR-AST-MIGRATION.4 — statement/control AST lowering split**
  (TASK TREE + ROADMAP/LIVE DOCS; **no runtime behavior change**). The broad statement/control migration is
  now split before code into `.4.1` assignment/mutation operator AST nodes, `.4.2` helper-call statements and
  returns, `.4.3` block-value side-effect traversal and block-local returns, and `.4.4` structured
  control-flow forms. This keeps assignment operators, helper calls, expression-valued blocks, and control
  syntax on separate verification surfaces.
  **Frontier:** `PERL-ACTIONIR-AST-MIGRATION.4.1` lower parsed assignment/mutation operator statement nodes
  from AST.
- 2026-07-01: **PERL-ACTIONIR-AST-MIGRATION.3.4 — return-payload AST traversal landed**
  (PERL ACTIONIR + FOCUSED TEST + BOOK/KM/LIVE DOCS). `MethodLowering::_lower_return_payload_expr(...)` now
  parses generalized return payloads through `LinkedSpec::ActionIR::AST` and returns AST-lowered typed values
  before the legacy helper-substitution loop. Direct shapes, nested helper calls, direct/nested access, block
  values, receiver chains, primitive literals, and bare scalar reads now share the typed value traversal used by
  `_lower_method_value_expr(...)`. AST `variable` payloads still route through scalar source-slot reads, so
  `return(count)` stays `return $count`; raw compatibility payloads such as `\(my $capt = capture_slice())`
  keep the narrow legacy fallback.
  **Verification:** `perl -Iperl -c perl/LinkedSpec/ActionIR/MethodLowering.pm` PASS;
  `perl -Iperl -c t/actionir_ast_parser.t` PASS; `perl -Iperl -c perl/LinkedSpec.pm` PASS;
  `prove -v -Iperl t/actionir_ast_parser.t` PASS; `prove -q -Iperl t/phase0_regression.t` PASS with phase0
  **1002 tests**; `mdbook build docs/linkedspec-book` PASS; memory/doctrine/Knowledge Map gates PASS;
  `git diff --check` PASS; `bash tools/run_ci_local.sh` PASS.
  **Frontier:** `PERL-ACTIONIR-AST-MIGRATION.4` replace statement/control lowering with AST lowering.
- 2026-07-01: **PERL-ACTIONIR-AST-MIGRATION.3.3 — receiver-dot `fluent_chain` AST lowering landed**
  (PERL ACTIONIR + FOCUSED TEST + BOOK/KM/LIVE DOCS). `MethodLowering::_lower_method_value_expr(...)` now
  consumes AST `fluent_chain` nodes for receiver-dot value chains before the legacy receiver-dot text
  normalizers. The dispatcher traverses typed receiver/call/argument nodes for array, hash, string, and number
  receiver families, then reuses the existing Perl helper catalog through the compatibility bridge. Existing
  behavior is preserved for bare scalar/hash receiver wrapping, array pipeline helper names, block-valued
  receivers, string/hash bridges to array terminals, `join_values` delimiter-first mapping, numeric arity
  checks, and numeric terminal continuation behavior.
  **Verification:** `perl -Iperl -c perl/LinkedSpec/ActionIR/MethodLowering.pm` PASS;
  `perl -Iperl -c t/actionir_ast_parser.t` PASS; `prove -v -Iperl t/actionir_ast_parser.t` PASS; targeted
  public lowering probes PASS; `mdbook build docs/linkedspec-book` PASS; memory/doctrine/Knowledge Map gates
  PASS; `prove -q -Iperl t/phase0_regression.t` PASS with phase0 **1002 tests**; `bash tools/run_ci_local.sh`
  PASS.
  **Frontier:** `PERL-ACTIONIR-AST-MIGRATION.3.4` replace return-payload helper substitution with AST
  traversal/diagnostics, then `.4` statement/control AST lowering.
- 2026-07-01: **PERL-ACTIONIR-AST-MIGRATION.3.2.3 — covered-call diagnostics landed**
  (PERL ACTIONIR + DIAGNOSTICS + FOCUSED TEST + BOOK/KM/LIVE DOCS). Unsupported AST call forms for helper
  families already owned by `.3.2.1`/`.3.2.2` no longer lower into generated host-language calls. Known helper
  calls that fail covered AST arity or argument materialization now become a harmless
  `LINKEDSPEC_UNSUPPORTED_ACTIONIR_HELPER:<name>` sentinel expression, and `ActionIR::Diagnostics` reports that
  sentinel through the existing unresolved-helper metadata while keeping `raw_perl_dependency_count == 0`.
  Unknown calls remain reserved for the future user-function path.
  **Verification:** `perl -Iperl -c perl/LinkedSpec/ActionIR/MethodLowering.pm` PASS;
  `perl -Iperl -c perl/LinkedSpec/ActionIR/Diagnostics.pm` PASS; `perl -Iperl -c t/actionir_ast_parser.t`
  PASS; `prove -v -Iperl t/actionir_ast_parser.t` PASS; targeted public lowering probes PASS;
  `prove -q -Iperl t/phase0_regression.t` PASS with phase0 **1002 tests**; `mdbook build
  docs/linkedspec-book` PASS; memory/doctrine/Knowledge Map gates PASS; `bash tools/run_ci_local.sh` PASS.
  **Frontier:** `PERL-ACTIONIR-AST-MIGRATION.3.3` replace receiver-dot `fluent_chain` lowering with AST
  traversal, then `.3.4` return-payload AST traversal.
- 2026-07-01: **PERL-ACTIONIR-AST-MIGRATION.3.2.2 — aggregate helper calls from AST**
  (PERL ACTIONIR + FOCUSED TEST + BOOK/KM/LIVE DOCS). `MethodLowering::_lower_method_value_expr(...)` now
  dispatches deprecated wrapper aliases plus aggregate-wrapper, collection, reducer, and hash helper families
  from AST `call` nodes before the legacy text cascade. Covered calls rebuild helper surfaces from typed AST
  fields, preserving aggregate symbol slots, quoted-wrapper literal boundaries, and nested value-only payloads
  before reusing the existing Perl helper catalog through the compatibility bridge.
  **Verification:** `perl -Iperl -c perl/LinkedSpec/ActionIR/MethodLowering.pm` PASS;
  `perl -Iperl -c t/actionir_ast_parser.t` PASS; `prove -Iperl t/actionir_ast_parser.t` PASS; targeted public
  lowering probes PASS; `mdbook build docs/linkedspec-book` PASS; `bash tools/run_ci_local.sh` PASS with
  phase0 **1002 tests**.
  **Then-frontier:** `PERL-ACTIONIR-AST-MIGRATION.3.2.3` (now completed above), then `.3.3`.
- 2026-07-01: **PERL-ACTIONIR-AST-MIGRATION.3.2.1 — value-only helper calls from AST**
  (PERL ACTIONIR + FOCUSED TEST + BOOK/KM/LIVE DOCS). `MethodLowering::_lower_method_value_expr(...)` now
  dispatches supported AST `call` nodes for scalar normalization, string predicate/composition,
  coalesce/concat, scalar-argument numeric helpers, and explicit `num_*` comparisons. Covered calls
  recursively materialize argument AST nodes before reusing the existing Perl helper catalog through the
  compatibility bridge. At that leaf, deprecated wrapper aliases such as `scalar(...)`/`array(...)`/
  `hash(...)`, aggregate-wrapper, collection, reducer, hash, symbol-slot, and receiver-chain helpers stayed
  queued and were not the canonical destination syntax; `.3.2.2` above now covers the aggregate/helper subset.
  **Verification:** `perl -Iperl -c perl/LinkedSpec/ActionIR/MethodLowering.pm` PASS;
  `perl -Iperl -c t/actionir_ast_parser.t` PASS; `prove -Iperl t/actionir_ast_parser.t` PASS; targeted public
  lowering probes PASS.
  **Frontier:** `PERL-ACTIONIR-AST-MIGRATION.3.2.2` lower aggregate-wrapper and collection helper calls from
  AST call nodes.
- 2026-07-01: **PERL-ACTIONIR-AST-MIGRATION.3.2 — AST helper-call lowering split**
  (TASK TREE + ROADMAP/LIVE DOCS; **no runtime behavior change**). Helper-call AST lowering is now split by
  argument-slot risk: `.3.2.1` value-only helper families, `.3.2.2` aggregate wrappers and collection/hash
  helpers with explicit symbol/value slot policy, and `.3.2.3` diagnostics for covered calls that would
  otherwise leak as generated host-language calls.
  **Frontier:** `PERL-ACTIONIR-AST-MIGRATION.3.2.1` lower value-only helper-call composition from AST call
  nodes.
- 2026-07-01: **PERL-ACTIONIR-AST-MIGRATION.3.1 — non-call value AST lowering dispatcher landed**
  (PERL ACTIONIR + FOCUSED TEST + BOOK/KM/LIVE DOCS). `MethodLowering::_lower_method_value_expr(...)` now
  parses through `LinkedSpec::ActionIR::AST` and lowers primitive literals, scoped bare scalar reads, direct
  indexed/nested access, array/hash shape literals, and block values from typed nodes. Direct-access reserved
  path atoms such as `true` and `CAPTURE` still preserve the legacy fallback behavior. Helper calls and
  statement-level block side effects use an explicit compatibility bridge until later children replace those
  surfaces.
  **Verification:** `prove -Iperl t/actionir_ast_parser.t` PASS; `prove -q -Iperl t/phase0_regression.t` PASS
  with **1002 tests**.
  **Frontier:** `PERL-ACTIONIR-AST-MIGRATION.3.2` lower helper-call value composition from AST call nodes.
- 2026-07-01: **PERL-ACTIONIR-AST-MIGRATION.3 — value/receiver AST lowering split**
  (TASK TREE + ROADMAP/LIVE DOCS; **no runtime behavior change**). The broad `.3` parent is now divided into
  four executable children: `.3.1` non-call value AST dispatcher, `.3.2` AST helper-call composition, `.3.3`
  AST receiver-dot value chains, and `.3.4` AST return-payload traversal plus diagnostics. This keeps
  user-defined functions blocked until function calls can enter the Perl reference as typed AST `Call` nodes
  and act as ordinary receiver-chain-capable value expressions.
  **Frontier:** `PERL-ACTIONIR-AST-MIGRATION.3.1` introduce the AST value-lowering dispatcher for non-call
  value nodes.
- 2026-07-01: **PERL-ACTIONIR-AST-MIGRATION.2 — Perl ActionIR AST parser seam added**
  (PERL ACTIONIR + FOCUSED TEST + BOOK/KM/LIVE DOCS; **existing lowering unchanged**). Added
  `LinkedSpec::ActionIR::AST` and `LinkedSpec::ActionIR::AST::Parser` as an additive typed parser seam behind
  the current ActionIR rewrite pipeline. The parser covers action blocks/statements, calls, standalone
  expression-value drops, receiver chains, variables, direct access, shape literals, block values, primitive
  literals, and scalar/array/hash assignment nodes with source spans. Focused tests lock function-call,
  numeric-literal, and block-valued receivers; current `call_spec_handler_subst` lowering remains authoritative.
  **Frontier:** `PERL-ACTIONIR-AST-MIGRATION.3` replace value-expression and receiver-chain lowering with AST
  lowering before user-defined functions proceed.
- 2026-07-01: **PERL-ACTIONIR-AST-MIGRATION.1 — Perl ActionIR text-lowering inventory locked**
  (TASK TREE + KM + LIVE DOCS; **no runtime behavior change**). The current Perl text-to-text boundaries are
  now explicitly mapped: raw statement splitting in `StatementSplit`, method-call text parsing in `MethodExpr`,
  raw contract scanners, contract lower callbacks, canonical `RAW_PERL` fallback, source-span replacement in
  `RewritePipeline`, recursive raw expression/receiver lowering in `MethodLowering`, and the
  `RuleIR::EmitContext` bridge/auto-working-var scanners. The replacement model is Rust-aligned
  `ActionBlock`/`ActionStmt` plus typed `Call`, `FluentChain`, value, mutation, and control nodes with source
  spans. Standalone expression statements silently drop their values, so future user-function calls remain
  ordinary expressions.
  **Then-frontier:** `PERL-ACTIONIR-AST-MIGRATION.2` (now completed above), then `.3`.
- 2026-07-01: **PERL-ACTIONIR-AST-MIGRATION.0 — text-to-AST doctrine adopted**
  (ADR + TASK TREE + BOOK/KM/LIVE DOCS; **no runtime behavior change**). The Rust-style text-to-AST path is now
  the cross-variant doctrine: helper/action language must parse into typed AST/IR before lowering, execution, or
  code emission. Perl ActionIR text-to-text lowering is migration debt; future Julia/Dart backends must start
  with AST, and Lua inherits the same rule if later adopted. User-defined functions must be implemented through
  AST call/function nodes, not textual macros.
  **Then-frontier:** `PERL-ACTIONIR-AST-MIGRATION.1` (now completed above), then `.2`.
- 2026-07-01: **SPEC-FORMAT-TERSE.4 — user-defined function surface owned**
  (TASK TREE + ROADMAP/LIVE DOCS; **no runtime behavior change**). User-defined pure functions are now the
  active Round 4 terse-language surface. The MVP contract starts with top-level `fn name(args) { ... }`,
  explicit parentheses for zero and nonzero arities, pure value/block bodies, explicit positional parameters,
  and no recursion/closures/lambdas/currying/implicit caller-state capture. Function calls are ordinary value
  expressions: their results can feed helpers, assignments, returns, mutations, and receiver-dot chains; if a
  call is used as a standalone statement, its value is silently dropped. The durable grammar decision is that
  function syntax belongs in `specs/spec.spec`; any bootstrap-parser `fn <name>(...) { ... }` support is
  temporary migration debt to remove after the text-to-AST path can carry the surface.
  **Then-frontier:** `SPEC-FORMAT-TERSE.4.1` contract/inventory before code (now complete; current frontier is
  `.4.2.1`), then `.3.2.2` arithmetic symbol callees.
- 2026-07-01: **SPEC-FORMAT-TERSE.3.2.1 — numeric word aliases landed**
  (PERL ACTIONIR + RUST RUNTIME + PHASE0 + ORACLE + BOOK/KM). Function-form aliases `add`, `sub`, `mul`,
  `div`, `mod`, `abs`, `floor`, `ceil`, `round`, `min`, `max`, `clamp`, `sum`, `avg`, `median`, and `range`
  now dispatch to the existing `num_*` helper family on Perl and Rust. Existing `num_*` spellings remain
  accepted.
  **Boundary:** arithmetic symbol callees such as `+(a,b)` remain `.3.2.2`; comparison words remain
  `.3.2.3`. `gt(10, 2)` is still the existing string comparison helper, not a numeric alias.
  **Verification:** Perl syntax checks PASS; focused Perl probes PASS, including receiver-chain preservation;
  phase0 PASS with **1002 tests**; oracle regeneration produced **53 fixtures**; Rust `corpus_oracle` PASS
  over 53 fixtures; focused Rust integration PASS; mdBook build PASS.
  **Frontier:** `SPEC-FORMAT-TERSE.3.2.2`, then `.3.2.3`, then `.4`.
- 2026-07-01: **SPEC-FORMAT-TERSE.3.2 — arithmetic/comparison call surface split**
  (TASK TREE + KM + LIVE DOCS; **no runtime behavior change**). Round 3 arithmetic/comparison calls are now
  split before code. At split time, ground truth showed the implemented numeric family was `num_*`; bare
  `add(...)`/`sum(...)` did not yet lower as numeric helpers; symbol callees such as `+(...)` were not portable
  parser inputs and raw Perl could misinterpret them if they fell through; and bare
  `eq`/`ne`/`gt`/`ge`/`lt`/`le` are current string comparisons in the book/lowering path.
  **Decision:** keep one `callee(args)` grammar; do not add the `(op a, b)` Lisp-prefix form. Split children:
  `.3.2.1` numeric word aliases, `.3.2.2` arithmetic symbol callees, `.3.2.3` comparison spelling policy.
  **Frontier:** `SPEC-FORMAT-TERSE.3.2.1`, then `.3.2.2`, `.3.2.3`, `.4`.
- 2026-07-01: **SPEC-FORMAT-TERSE.3.1 — edge syntax contract locked**
  (TASK TREE + BOOK + KM + LIVE DOCS; **no runtime behavior change**). Round 3 keeps the existing edge split:
  `->` is the action-edge surface and `=>` is the blind-call surface. Grouped action-edge targets remain valid
  only as shared-block factoring (`-> RuleA | RuleB { ... }`); the block-less grouped form `-> RuleA | RuleB`
  stays invalid with the existing "Grouped action-edge targets require a shared code block" diagnostic.
  **Verification:** audited existing phase0 locks for shared-block parse expansion, validation acceptance,
  missing-block rejection, and three-target grouping; focused `perl -Iperl` probes confirmed shared-block
  acceptance, two-target `ACODE` expansion, and block-less rejection; full phase0 passed (`prove -q -Iperl
  t/phase0_regression.t`, 1001 tests); local CI passed; mdBook formal/action chapters and KM fact card
  updated.
  **Then-frontier:** `SPEC-FORMAT-TERSE.3.2` (now split above), then `.4`.
- 2026-07-01: **SPEC-FORMAT-TERSE.5.0 — future variant parity ownership/inventory landed**
  (TASK TREE + KM + BOOK STATUS + LIVE DOCS; **no runtime behavior change**). The active terse tree now has a
  concrete ownership container for future backend parity before any non-Rust variant code. Current implemented
  backends are the Perl reference and the Rust interpreter under `rust/`. Julia and Dart remain the accepted
  future backend targets from ADR `0006` and Phase 8, but are deferred to dedicated backend implementation
  task trees before code. Lua is not adopted by the current ADR/book/codebase set and is blocked on an explicit
  decision record before any task-tree leaf or implementation can exist.
  **Verification:** full bootstrap/roadmap/mdBook/codebase read completed; source inventory found no tracked
  Julia/Dart/Lua implementation paths outside the unrelated nested `rgx` checkout; Knowledge Map backend fact
  corrected from the stale pre-Phase-9 "Perl only" wording; backend handoff chapter status updated to the
  current 52-fixture Rust corpus state; no parser/compiler/runtime code changed.
  **Then-frontier:** `SPEC-FORMAT-TERSE.3.1` (now completed above), then `.3.2`, then `.4`.
- 2026-07-01: **SPEC-FORMAT-TERSE.2.3.5.5 — block-valued receiver-dot chains landed**
  (PERL ACTIONIR + RUST PARSER/RUNTIME + PHASE0 + ORACLE + BOOK/KM). Expression-valued blocks can now be
  receivers for the existing compatible array/string/hash/number value-chain families. The block evaluates
  first; its yielded value feeds the helper family selected by the first receiver method. Locked examples:
  `{ [3, 1, 2] }.sorted().join_values(",")`, `{ return(["x", "y"]); ["bad"] }.join_values("|")`,
  `{ set(raw, " a-b "); raw }.trim().split("-").count()`,
  `{ { "b" => 2, "a" => 1 } }.sorted_keys().join_values(",")`, and `{ 3.5 }.floor().add(2)`.
  **Verification:** Perl syntax checks PASS; focused Perl probes PASS; focused Rust `.2.3.5.5` parser/runtime
  locks PASS; oracle regeneration produced **52 fixtures**; Rust `corpus_oracle` PASS over 52 fixtures;
  phase0 PASS with **1001 tests**; mdBook/KM/live docs updated.
  **Then-frontier:** `SPEC-FORMAT-TERSE.5.0` (now completed above).
- 2026-07-01: **SPEC-FORMAT-TERSE.2.3.5.6 — aggregate wrapper quoted-name boundaries landed**
  (PERL ACTIONIR + RUST LOCKS + PHASE0 + ORACLE + BOOK/KM). Bare aggregate wrappers remain explicit typed
  working-variable reads: `array(foo)` / `a(foo)` read `@foo`, and `hash(bar)` / `h(bar)` read `%bar`.
  Quoted wrapper arguments are not aliases and are not scalar-indirect lookups: `array("foo")` /
  `array('foo')` are literal array-constructor payloads, and quoted hash constructor arguments are fixed-key
  payloads under the existing arity rules. Direct `[...]` / `{...}` shapes are now the preferred terse
  array/hash constructor examples in the variant-neutral mdBook; `foo.array()`-style postfix typed views stay
  out of scope.
  **Verification:** Perl syntax checks PASS; focused lowering/runtime/source probes PASS; phase0 PASS with
  **1000 tests**; focused Rust `.2.3.5.6` locks PASS; oracle regeneration produced **51 fixtures**; Rust
  `corpus_oracle` PASS over 51 fixtures; mdBook/KM/live docs updated.
  **Then-frontier:** `SPEC-FORMAT-TERSE.2.3.5.5` (now completed above), then `SPEC-FORMAT-TERSE.5.0` (now
  completed above).
- 2026-07-01: **SPEC-FORMAT-TERSE.2.3.5.4 — number receiver-dot value chains landed**
  (PERL ACTIONIR + RUST PARSER/RUNTIME + PHASE0 + ORACLE + BOOK/KM). Pure numeric helper chains now work from
  scalar, integer-literal, and decimal-literal receivers on Perl and Rust:
  `score.abs().ceil().add(2, 3).mul(2).sub(1).div(2).clamp(0, 20).max(5).min(12)`,
  `5.mod(2)`, `3.5.floor().add(1)`, and `3.5.round()` are locked. Comparison receiver methods (`eq`, `ne`,
  `gt`, `ge`, `lt`, `le`) are terminal values; invalid continuations return `undef`/`null`. Numeric array
  reducers remain explicit array-consuming helpers, and statement/lifecycle calls such as `declare(...)` are
  not terse receiver methods.
  **Verification:** Rustfmt PASS on touched Rust files; Perl syntax checks PASS; focused Rust parser/runtime
  locks PASS; oracle regeneration produced **50 fixtures**; Rust `corpus_oracle` PASS over 50 fixtures;
  phase0 PASS with **999 tests**; mdBook/KM/live docs updated.
  **Then-frontier:** `SPEC-FORMAT-TERSE.2.3.5.5` (now completed above).
- 2026-07-01: **SPEC-FORMAT-TERSE.2.3.5.3 — string receiver-dot value chains landed**
  (PERL ACTIONIR + RUST PARSER/RUNTIME + PHASE0 + ORACLE + BOOK/KM). Pure string/scalar helper chains now
  work from scalar and string-literal receivers on Perl and Rust:
  `raw.trim().lowercase().replace_substr("-", "_")`, `raw.trim().split("-").trim_each().join_values("|")`,
  and `"abcdef".substr(1, 3).uppercase()` are locked. String-returning links compose; `split(delim)` bridges
  explicitly into the array receiver family; terminal methods (`length`, `starts_with`, `ends_with`,
  `contains_substr`, `matches`) end the chain and invalid continuations return `undef`/`null`. Value-form
  `split(...)` and `substr(...)` now lower as portable helper payloads.
  **Verification:** Perl syntax checks PASS; phase0 PASS with **998 tests**; focused Rust parser/runtime locks
  PASS; oracle regeneration produced **49 fixtures**; Rust `corpus_oracle` PASS over 49 fixtures; mdBook/KM/live
  docs updated.
  **Then-frontier:** `SPEC-FORMAT-TERSE.2.3.5.4` (now completed above).
- 2026-07-01: **SPEC-FORMAT-TERSE.2.3.5.2 — hash receiver-dot value chains landed**
  (PERL ACTIONIR + RUST RUNTIME + PHASE0 + ORACLE + BOOK/KM). Pure hash helper chains now work from a hash
  receiver on Perl and Rust: `meta.set_key("stage", "normalized").count_keys()`,
  `meta.merge_hash(hash(extra)).scalaref("a")`, and
  `meta.sorted_keys().join_values(",")` are locked. Hash-returning links feed later hash helpers, while
  `sorted_keys()` / `sorted_values()` bridge into array receiver chains. Statement-level `set_key(meta, ...)`
  and `meta[key] = value` remain the mutating forms; receiver-dot `meta.set_key(...)` is pure unless assigned
  back. Rust `merge_hash` now matches the documented later-argument override contract.
  **Verification:** Perl syntax checks PASS; phase0 PASS with **997 tests**; focused Rust parser/runtime locks
  PASS; oracle regeneration produced **48 fixtures**; Rust `corpus_oracle` PASS over 48 fixtures; mdBook/KM/live
  docs updated.
  **Then-frontier:** `SPEC-FORMAT-TERSE.2.3.5.3` (now completed above).
- 2026-07-01: **SPEC-FORMAT-TERSE.2.3.5.1 — array receiver-dot value chains landed**
  (PERL ACTIONIR + RUST RUNTIME + PHASE0 + ORACLE + BOOK/KM). Pure array helper chains now work from an array
  receiver on Perl and Rust: `items.sorted().drop_front(2).first()`, `items.uniq().join_values(",")`,
  `items.filter_match(/^a$/).count()`, and `phrases.split_each("-").filter_match(/^aa$/).count()` are locked.
  Receiver-dot `join_values` preserves the delimiter-first helper contract. Public function-style pipeline
  lowering keeps its legacy source shape; the new pure array-value path is scoped to receiver-dot chains. The
  `.1.6` end mutations remain statement-only and return `undef` without mutating in value slots.
  **Verification:** Perl syntax checks PASS; phase0 PASS with **996 tests**; focused Rust parser/runtime locks
  PASS; oracle regeneration produced **47 fixtures**; Rust `corpus_oracle` PASS over 47 fixtures; mdBook/KM/live
  docs updated.
  **Then-frontier:** `SPEC-FORMAT-TERSE.2.3.5.2` (now completed above).
- 2026-07-01: **SPEC-FORMAT-TERSE.2.3.5 — return-type method chaining split**
  (TASK TREE + BOOK/KM/LIVE DOCS; **no runtime behavior change**). The receiver-dot value-chain model is now
  specified before implementation and split by return family. `.2.3.5.1` owns array receiver-dot value chains;
  `.2.3.5.2`, `.2.3.5.3`, and `.2.3.5.4` own hash, string, and number families. Current `.1.6`
  receiver-dot array end mutations remain statement-only: `push_back`/`push_front` mutate, `pop_back`/
  `pop_front` discard the removed value, and value-position/chained forms stay out of contract until a child
  leaf defines them explicitly. The mdBook inline-control wording is now aligned with `.2.3.4.2`: inline
  `if(...)` and `switch(...)` are portable lazy value helpers in `return(...)`, assignment RHS, and fluent
  `.return(...)` slots.
  **Verification:** LinkedSpec TOOLBOX probes recorded the Perl receiver-chain boundary; Rust source read
  confirmed the parser/runtime split; mdBook build, Knowledge Map, memory, doctrine, and diff checks PASS.
  **Then-frontier:** `SPEC-FORMAT-TERSE.2.3.5.1` (now completed above).
- 2026-06-30: **SPEC-FORMAT-TERSE.2.3.4.2 — Perl inline-composite value control lowering landed**
  (PERL ACTIONIR + PHASE0 + ORACLE + BOOK/KM). Inline `if(...)` and `switch(...)` now produce selected branch
  values on the Perl reference in supported value-consuming slots: `return(...)`, assignment RHS, and fluent
  `.return(...)`. The implementation keeps statement-control forms separate, lowers flow literal
  `true`/`false` to host `1`/`0`, supports `elseif(...)`, `else(...)`, and the Rust-compatible plain third
  `if` fallback, evaluates `switch` sources once, and recurses auto-working-variable discovery through inline
  control payloads and expression-valued branch blocks. `tools/gen_oracle_corpus.pl` added
  `terse_2_3_4_2_inline_if_value_control` and
  `terse_2_3_4_2_inline_switch_value_control`; Rust `corpus_oracle` now passes with **46 fixtures**. The
  asserted portable contract is the selected payload value, not any specific legacy/action-edge `?...:` tag
  string.
  **Verification:** changed Perl module syntax checks PASS; phase0 PASS with **995 tests**; oracle
  regeneration PASS; Rust `corpus_oracle` PASS over 46 fixtures. Full gates are recorded in the commit
  workflow.
  **Frontier: `SPEC-FORMAT-TERSE.2.3.5`** (return-type method chaining design and first implementation split).
- 2026-06-30: **SPEC-FORMAT-TERSE.2.3.4.1 — Rust helper-context bare aggregate argument parity landed**
  (RUST RUNTIME + ORACLE + BOOK/KM). Rust now treats bare working-variable names as typed aggregate snapshots
  only in helper argument slots whose callee contract already implies a hash or array, closing the audited
  `merge_hash(hash_copy(base), overlay)` mismatch and the matching array-helper surface without changing
  ordinary bare-variable scalar reads. Focused runtime locks cover the merge case, the broader hash/object
  helper family (`set_key`, `rename_key`, `drop_keys`, `pick_keys`, `sorted_keys`, `has_key`, `scalaref`,
  `flat_hash`), and the array helper family (`sorted`, `reversed`, `first`, `last`, `take`, `drop_front`,
  `contains`, `index_of`, `num_sum`, `flat_array`). `tools/gen_oracle_corpus.pl` added
  `terse_2_3_4_1_bare_hash_helper_arg_composition` and
  `terse_2_3_4_1_bare_array_helper_arg_composition`; Rust `corpus_oracle` now passes with **44 fixtures**.
  **Verification:** focused Rust runtime `terse_2_3_4_1` PASS; oracle regeneration PASS; Rust
  `corpus_oracle` PASS over 44 fixtures. Full gates are recorded in the commit workflow.
  **Frontier: `SPEC-FORMAT-TERSE.2.3.4.2`** (Perl inline-composite value-control lowering).
- 2026-06-30: **SPEC-FORMAT-TERSE.2.3.4 — full composability audit split**
  (AUDIT/TREE/BOOK/KM + ORACLE FIXTURE; **no runtime behavior change**). Pure value-helper nesting is now
  locked by the new `terse_2_3_4_deep_pure_helper_composition` oracle fixture:
  `count(drop_front(sorted_keys(merge_hash(hash_copy(base), hash(overlay)))))`; the Rust corpus passes with
  **42 fixtures**. The unsupported sites were split before code: `.2.3.4.1` owns Rust helper-context aggregate
  bare reads after diagnostic `merge_hash(hash_copy(base), overlay)` returned Perl `2` but Rust `1`, and
  `.2.3.4.2` owns Perl inline-composite value-control lowering after generated-source probes showed
  `return(if(...))` / `return(switch(...))` do not reliably return selected branch values. Receiver-dot
  value/chaining remains `.2.3.5`.
  **Verification:** TOOLBOX probes; diagnostic Rust corpus mismatch; final oracle regeneration; Rust
  `corpus_oracle` PASS over 42 fixtures; mdBook/KM/memory/doctrine/diff and local CI are recorded in commit
  workflow.
  **Frontier: `SPEC-FORMAT-TERSE.2.3.4.1`** (Rust helper-context aggregate bare reads).
- 2026-06-30: **SPEC-FORMAT-TERSE.2.3.3.3.3.1 — Rust `tclite` default-mode repetition parity landed**
  (RUST CORE/RUNTIME + ORACLE + BOOK/KM). Rust now treats bare default rules as zero-min repeated-choice loops
  and honors `I`/preamble `return(expr)` as an immediate child-invocation return before local entry-regex
  matching. That matches the Perl dispatch model used by shipped `tclite` bracket and quote children.
  `tools/gen_oracle_corpus.pl` restored `tclite_command_subst` (`[]`) and `tclite_double_quote` (`""`); the
  regenerated corpus now has **41 fixtures** and both cases pass with the tagged Perl-reference `tcl_script`
  values. **Verification:** focused Rust core/runtime/default-mode and lifecycle locks PASS; oracle generator
  syntax/regeneration PASS; Rust `corpus_oracle` PASS over 41 fixtures; mdBook/KM/memory/doctrine/diff and full
  local CI are recorded in commit workflow.
  **Frontier: `SPEC-FORMAT-TERSE.2.3.4`** (full composability audit and follow-on split).
- 2026-06-30: **SPEC-FORMAT-TERSE.2.3.3.3.3 — Rust `tclite` oracle retry split**
  (AUDIT/TREE/KM/BOOK STATUS; **no runtime behavior change**). After Rust compact lifecycle/body receiver
  chains and action-edge explicit/flow fluent chains landed, the deferred `tclite` oracle cases were retried.
  Perl returns `["?tcl_script:",[["?command_subst:",[]]]]` for `[]` and
  `["?tcl_script:",[["?double_quote:",[]]]]` for `""`; temporarily re-enabled Rust fixtures still produced
  actual `[]` for both, while the other 39 corpus fixtures passed. The failing fixtures remain out of the
  committed green corpus. **Verification:** Perl reference probes complete; diagnostic Rust corpus oracle
  exposed exactly the two `tclite` failures; final green-corpus regeneration/oracle, mdBook, KM, memory/
  doctrine/diff checks, and full local CI are recorded in commit workflow.
  **Frontier: `SPEC-FORMAT-TERSE.2.3.3.3.3.1`** (Rust default-mode recursive repetition parity for `tclite`).
- 2026-06-30: **SPEC-FORMAT-TERSE.2.3.3.3.2 — Rust action-edge explicit/flow fluent chains landed**
  (RUST PARSER + COMPILER/RUNTIME LOCKS + BOOK/KM). Rust now preserves multiline dotted continuations after an
  action edge on the preceding `ActionEdge` and executes the explicit/flow subset: `.push(target)`,
  `.push(child,target)`, `.if/.else/.endif` gating, helper calls such as `.say(...)`, and
  `.return_undef()`/`.return(expr)` continuations. Explicit pushes dispatch the child and append the captured
  child return value to the named target accumulator without leaking the child's accumulator events.
  **Verification:** focused Rust core action-edge flow-chain locks PASS; focused Rust runtime
  `terse_2_3_3_3_2` PASS; existing no-arg action-edge regression PASS; full Rust core/runtime package tests,
  mdBook build, oracle generator syntax, KM regenerate/check, memory/doctrine/diff checks, and full local CI
  PASS in commit workflow.
  **Frontier: `SPEC-FORMAT-TERSE.2.3.3.3.3`** (Rust `tclite` oracle re-enable / default-mode repetition audit).
- 2026-06-30: **SPEC-FORMAT-TERSE.2.3.3.3.1 — Rust compact lifecycle fluent chains landed**
  (RUST PARSER + COMPILER/RUNTIME LOCKS + BOOK/KM). Rust now normalizes compact lifecycle/body receiver chains
  such as `I.return(...)`, `E.return(...)`, and `I.declare(...).set(...).return(...)` into executable lifecycle
  `CodeBlock` statements instead of leaving a standalone `FluentChain` for the compiler to drop. Focused locks
  cover multiline body placement, regex-first header-line inline placement, compiler lifecycle-slot population,
  return-channel behavior, and ordered declaration/mutation chains.
  **Verification:** focused Rust core `lifecycle_compact` PASS; focused Rust runtime `terse_2_3_3_3_1` PASS;
  full Rust core/runtime package tests PASS; mdBook build PASS; oracle generator syntax PASS; KM
  regenerate/check PASS; memory/doctrine/diff checks PASS; full local CI PASS. Rustfmt ran on touched Rust
  files.
  **Frontier: `SPEC-FORMAT-TERSE.2.3.3.3.2`** (Rust action-edge explicit/flow fluent chains).
- 2026-06-30: **SPEC-FORMAT-TERSE.2.3.3.3 — remaining Rust fluent continuations split**
  (DOCS/TREE/KM ONLY; **no engine behavior change**). The remaining Rust fluent parity work is now split:
  `.2.3.3.3.1` owns compact lifecycle/body receiver chains such as `I.return(...)` and
  `I.declare(...).return(...)`; `.2.3.3.3.2` owns action-edge explicit/flow chains such as
  `.push(child,target)` and `.if(...).push(...).else().return_undef().endif()`; `.2.3.3.3.3` owns `tclite`
  re-enable/default-mode repetition audit after fluent parity lands.
  **Verification:** KM retrieval; Perl reference probes; shipped-spec/code search; Rust parser/compiler/runtime
  code-read; focused Rust `.2.3.3.2` regression test PASS; KM/memory/doctrine/diff checks PASS.
  **Frontier: `SPEC-FORMAT-TERSE.2.3.3.3.1`** (Rust compact lifecycle/body receiver chains).
- 2026-06-30: **SPEC-FORMAT-TERSE.2.3.3.2 — Rust attached fluent block payloads landed**
  (RUST PARSER + RUNTIME LOCKS + BOOK/KM). Rust now parses action-edge and lifecycle-marker
  `.when(cond) { ... }` receiver-fluent block chains by normalizing them to existing attached
  `when/otherwise` statement blocks. Dotted `.otherwise { ... }` and no-dot `otherwise { ... }` fallback tails
  execute on both surfaces, including multiline `}.otherwise {` placement.
  **Verification:** focused Rust core `attached_fluent` PASS; focused Rust runtime `terse_2_3_3_2` PASS;
  full Rust core/runtime package tests PASS; mdBook/KM/memory/doctrine/diff checks PASS; full local CI PASS
  (`Files=1, Tests=994`). Compact lifecycle/body fluent chains such as `I.return(...)` remain the next Rust
  fluent-parity surface.
  **Frontier: `SPEC-FORMAT-TERSE.2.3.3.3`** (Rust remaining body/standalone fluent continuation audit and
  implementation split).
- 2026-06-30: **SPEC-FORMAT-TERSE.2.3.3.1 — Rust action-edge fluent continuations landed**
  (RUST PARSER + COMPILER + RUNTIME + BOOK/KM LOCKS). Rust now preserves fluent chains on `->` action edges
  through AST and compiled `AcodeEntry` metadata. No-arg `.push` dispatches the matched child, captures its
  rule return, suppresses child return-event leakage from the shared accumulator, and appends the value to the
  current rule accumulator. `.return(expr)` and `.return_undef` return through the current rule/action channel
  without recursively dispatching the close-edge child.
  **Verification:** focused Rust core `fluent_chain` PASS; focused Rust runtime `terse_2_3_3_1` PASS; full Rust
  core/runtime packages PASS; mdBook/KM/memory/doctrine/diff checks PASS; full local CI PASS
  (`Files=1, Tests=994`). The `tclite` oracle remains deferred behind compact lifecycle/body fluent forms
  (`I.return(...)`) and default-mode repetition parity, both tracked as follow-on work.
  **Frontier: `SPEC-FORMAT-TERSE.2.3.3.2`** (Rust attached fluent block payloads for
  `.when(cond) { ... }.otherwise { ... }`).
- 2026-06-30: **SPEC-FORMAT-TERSE.2.3.2 — lifecycle value/drop return-channel lock landed**
  (PHASE0 + RUST RUNTIME + BOOK/KM LOCKS). Lifecycle blocks are now documented and regression-locked as
  statement blocks, not expression-valued blocks. Final ordinary statement values are discarded; top-level
  lifecycle/action `return(expr)` writes the surrounding return channel; expression-valued block
  `return(expr)` remains block-local. Perl phase0 source-locks all seven lifecycle markers and runtime-locks
  the three-way distinction. Rust focused tests lock value discard, top-level lifecycle return-event recording,
  and expression-block local return contrast.
  **Verification:** Perl syntax check PASS; phase0 PASS (`Files=1, Tests=994`); focused Rust runtime
  `terse_2_3_2` PASS; mdBook/KM/memory/doctrine/diff checks PASS; full local CI PASS.
  **Frontier: `SPEC-FORMAT-TERSE.2.3.3`** (Rust fluent block-chain/action-edge parity, coordinated with
  `RUST-PARITY.7.5.3`).
- 2026-06-30: **SPEC-FORMAT-TERSE.2.3.1 — Perl fluent `when/otherwise` block chains landed**
  (PERL BOOTSTRAP + PHASE0 + BOOK/KM LOCKS). Perl now preserves attached fallback tails after fluent
  `.when(cond) { ... }` chains. Both `.otherwise { ... }` and no-dot `otherwise { ... }` continuations execute
  on action-edge and lifecycle surfaces. The new locks use false `when` conditions so fallback execution is
  actually proven, not hidden by a selected first branch.
  **Verification:** Perl syntax checks PASS; phase0 PASS (`Files=1, Tests=993`); mdBook/KM/memory/doctrine/
  diff checks PASS.
  **Frontier: `SPEC-FORMAT-TERSE.2.3.2`** (lifecycle block value-drop and explicit `return(expr)` channel
  semantics lock).
- 2026-06-30: **SPEC-FORMAT-TERSE.2.3 — fluent/lifecycle/composability surface split/owned**
  (DOCS/TREE/KM ONLY; **no engine behavior change**). `.2.3` was too broad for one signoff slice. KM +
  TOOLBOX probes show the Perl reference already accepts exact action/lifecycle
  `.when(cond) { ... }.otherwise { ... }` fluent block chains with `ready=1 raw=0 fallback=0 unresolved=0`,
  while Rust still lacks fluent attached-block/action-edge parity. Lifecycle block syntax is present, but final
  expression value dropping versus explicit `return(expr)` rule-channel behavior needs a focused semantic lock.
  Full nested composability and return-type method chaining are also separate surfaces; Round 1 receiver-dot
  array methods remain statement-only.
  **Verification:** KM retrieval; TOOLBOX descriptor/runtime probes; Perl/Rust code-read; mdBook/KM/memory/
  doctrine/diff checks PASS.
  **Frontier: `SPEC-FORMAT-TERSE.2.3.1`** (Perl reference fluent block-chain contract lock).
- 2026-06-30: **SPEC-FORMAT-TERSE.2.2.6.2 — Rust attached `while(cond) { ... }` parity landed**
  (RUST PARSER + RUNTIME LOOP + ORACLE/BOOK/KM LOCKS). Rust now parses attached `while(cond) { ... }` as a
  lazy statement loop, re-evaluates the condition before each iteration, executes body statements while true,
  and composes with existing attached `if`/`switch` bodies. The same deterministic safety diagnostic is used
  after 10000 iterations, and expression-valued block bodies keep block-local `return(expr)` semantics.
  Rust also gained the documented numeric comparison helper family needed by the portable counter-loop pattern.
  **Verification:** focused Rust parser `attached_while` PASS; focused Rust runtime `terse_2_2_6_2` PASS;
  full Rust core/runtime package tests PASS; oracle corpus regenerated to **39 fixtures** with
  `terse_2_2_6_2_attached_while_blocks`; Rust corpus oracle PASS; mdBook/KM/memory/doctrine/diff checks PASS;
  full local CI PASS (`Files=1, Tests=992`).
  **Frontier: `SPEC-FORMAT-TERSE.2.3`** (fluent control-flow/lifecycle-block/full composability discovery and split).
- 2026-06-30: **SPEC-FORMAT-TERSE.2.2.6.1 — Perl attached `while(cond) { ... }` loop/safety landed**
  (PERL ACTIONIR + PHASE0 + BOOK/KM LOCKS). Perl now lowers attached `while(cond) { ... }` through ActionIR
  with no raw fallback or unresolved helper residue. Conditions are evaluated before each iteration; body
  statements run while true; `return(expr)` inside the loop returns from the surrounding rule/action. Each loop
  gets a deterministic local guard (`LinkedSpec while iteration safety limit exceeded after 10000 iterations`)
  so non-terminating loops return control to the parser instead of hanging. Same-line statement separator rules
  remain unchanged: a following ordinary statement still needs `;`.
  **Verification:** Perl syntax checks PASS; TOOLBOX lowering/descriptor/runtime/source probes PASS; phase0
  PASS (`Files=1, Tests=992`); mdBook/KM/memory/doctrine/diff checks PASS; full local CI PASS.
  **Frontier: `SPEC-FORMAT-TERSE.2.2.6.2`** (Rust attached-while parser/runtime parity).
- 2026-06-30: **SPEC-FORMAT-TERSE.2.2.6 — attached `while(cond) { ... }` split/owned before code**
  (DOCS/TREE/KM ONLY; **no engine behavior change**). KM + TOOLBOX probes show current Perl lowers
  `while(false) { return("bad") }` as raw host code (`ready=0 raw=1 fallback=1 unresolved=0`), while Rust has
  no attached statement-loop parser/runtime. The leaf is split into `.2.2.6.1` for the Perl reference
  loop/safety contract and `.2.2.6.2` for Rust parity. The safety rule is now explicit: non-terminating loops
  must trip a deterministic iteration guard instead of hanging generated parsers.
  **Verification:** KM retrieval; TOOLBOX lowering/descriptor probes; Perl/Rust code-read.
  **Frontier: `SPEC-FORMAT-TERSE.2.2.6.1`** (Perl reference attached `while` loop with iteration safety).
- 2026-06-30: **SPEC-FORMAT-TERSE.2.2.5.2 — Rust attached `switch/case/default` parity landed**
  (RUST PARSER + RUNTIME STACK + ORACLE/BOOK/KM LOCKS). Rust now parses attached switch blocks:
  `switch(expr) { case(v) { ... } case(w) { ... } default { ... } }` and normalizes them to
  `switch` / `case` / `default` / `endswitch` statement controls. The runtime now gates statement switch
  branches with first-match/default semantics beside the existing if stack, so inactive branch side effects do
  not run. The existing lazy value-form `switch(expr, case(...), default(...))` remains unchanged.
  **Verification:** Perl syntax checks PASS; phase0 PASS (`Files=1, Tests=991`); focused Rust parser
  `attached_switch` PASS; focused Rust runtime `terse_2_2_5_2` PASS; lazy value-form `cond_switch` PASS; Rust
  corpus oracle PASS with **38 fixtures** including `terse_2_2_5_2_attached_switch_blocks`; mdBook/KM/memory/
  doctrine/diff checks PASS; full local CI PASS.
  **Frontier: `SPEC-FORMAT-TERSE.2.2.6`** (`while(cond) { ... }` statement loop with progress safety).
- 2026-06-30: **SPEC-FORMAT-TERSE.2.2.5.1 — Perl attached `switch/case/default` separator/source lock landed**
  (PERL ACTIONIR + PHASE0 + BOOK/KM LOCKS). Compact attached switch bodies now split adjacent branch blocks:
  `switch(expr) { case(v) { ... } case(w) { ... } default { ... } }` lowers through ActionIR with no host-shaped
  `case(...)` / `default { ... }` residue, no raw fallback, and no unresolved helper residue. Runtime locks cover
  first-match, later-case, and default selection. The existing separator contract is unchanged: an ordinary
  same-line statement after the final attached switch still requires `;`.
  **Verification:** Perl syntax checks PASS; TOOLBOX descriptor/lowering/runtime/source probes PASS; phase0 PASS
  (`Files=1, Tests=991`); mdBook/KM/memory/doctrine/diff checks PASS; full local CI PASS.
  **Frontier: `SPEC-FORMAT-TERSE.2.2.5.2`** (Rust attached-switch parser/runtime parity).
- 2026-06-30: **SPEC-FORMAT-TERSE.2.2.5 — attached `switch/case/default` split/owned before code**
  (DOCS/TREE/KM ONLY; **no engine behavior change**). KM and TOOLBOX probes show the broad attached-switch
  surface needs two implementation leaves: Perl first, Rust second. Perl has partial attached-switch lowering,
  but adjacent `case/default` branch blocks can leave unresolved `case(...) { ... }` residue or host-like
  `default { ... }` labels in generated source. Rust has lazy value-form `switch(...)` runtime tests, but no
  attached `switch/case/default` parser in `CodeBlock::parse`.
  **Verification:** KM retrieval; TOOLBOX descriptor/lowering/runtime probes; Perl/Rust code-read; focused Rust
  value-form switch tests PASS with existing warning baseline; memory/doctrine/diff checks.
  **Frontier: `SPEC-FORMAT-TERSE.2.2.5.1`** (Perl reference attached-switch separator/source lock).
- 2026-06-30: **SPEC-FORMAT-TERSE.2.2.4 — `when/otherwise` aliases landed**
  (PERL ACTIONIR + RUST PARSER + ORACLE/KM/BOOK). Attached `when(cond) { ... } otherwise { ... }` now lowers as
  the portable alias form for attached `if(cond) { ... } else { ... }`. Perl recognizes the aliases in the
  statement splitter, scanner/contract patterns, and `ControlFlow`, so generated handlers avoid host Perl
  `when`. Rust normalizes the attached aliases in `CodeBlock::parse` to existing `if`/`else`/`endif` statements
  and reuses `handle_statement_if_control`.
  **Verification:** Perl syntax checks PASS; TOOLBOX lowering/descriptor/runtime/source probe PASS; focused
  Rust core `when_otherwise` PASS; focused Rust runtime `terse_2_2_4` PASS; Rust oracle corpus PASS; oracle
  corpus regenerated to **37 fixtures**; phase0 PASS (`Files=1, Tests=991`); mdBook/KM/memory/doctrine/diff
  checks PASS; full local CI PASS.
  **Frontier: `SPEC-FORMAT-TERSE.2.2.5`** (attached-block `switch/case/default` parity and separator lock).
- 2026-06-30: **SPEC-FORMAT-TERSE.2.2.4 — `when/otherwise` owned before code**
  (DOCS/TREE/KM ONLY; **no engine behavior change**). TOOLBOX probes show current `when/otherwise` is not DSL
  control flow: the combined attached form stays raw, descriptor metadata is `ready=0 raw=1 unresolved=2`,
  generated handlers emit Perl's experimental-`when` warning, and the runtime probe returns the `otherwise`
  branch for `when(true)`. The leaf is now scoped as alias normalization over the landed attached-if model:
  `when(cond) { ... }` maps to attached `if(cond) { ... }`, and `otherwise { ... }` maps to attached
  `else { ... }`. Rust should normalize in `CodeBlock::parse` and reuse the existing marker runtime.
  **Verification:** KM retrieval; TOOLBOX lowering/descriptor/runtime/generated-source probes; Perl/Rust
  code-read.
  **Frontier: `SPEC-FORMAT-TERSE.2.2.4`** (implementation of `when/otherwise` aliases).
- 2026-06-30: **SPEC-FORMAT-TERSE.2.2.3 — Rust attached-block if landed**
  (RUST PARSER + RUNTIME LOCKS + ORACLE/KM/BOOK). Rust now accepts portable attached-block `if/elseif/else`
  chains: `if(cond) { ... } elseif(cond2) { ... } else { ... }`. `CodeBlock::parse` normalizes attached
  branch bodies into the existing marker-control sequence with an implicit `endif`, and the runtime reuses
  `Engine::handle_statement_if_control` instead of adding a second branch engine. Marker-form and
  inline-composite `if` behavior remain unchanged, and a same-line statement after the final attached branch
  still requires `;`.
  **Verification:** focused Rust core parser `attached_if` PASS; focused Rust runtime `terse_2_2_3` PASS;
  oracle corpus regenerated to **36 fixtures** and corpus oracle PASS; mdBook/KM/live docs updated.
  **Frontier: `SPEC-FORMAT-TERSE.2.2.4`** (`when/otherwise` conditional aliases; own before code).
- 2026-06-30: **SPEC-FORMAT-TERSE.2.2.3 — Rust attached-block if owned before code**
  (DOCS/TREE/KM ONLY; **no engine behavior change**). Rust parity for the Perl `.2.2.2` attached-if contract is
  now scoped. `CodeBlock::parse` lacks attached branch parsing, while runtime already has marker-form branch
  gating through `handle_statement_if_control`. The implementation should parse attached branch bodies into the
  existing statement-control model and preserve inline-composite `if` plus marker-form `if(...); ... endif()`.
  **Verification:** Rust code-read; focused Rust parser smoke PASS (`parse_lifecycle_block_content`, known
  nested `rgx` warning noise); Knowledge Map regenerate/check PASS; memory/doctrine/diff checks PASS.
  **Frontier: `SPEC-FORMAT-TERSE.2.2.3`** (implementation of Rust attached-block `if/elseif/else` parity).
- 2026-06-30: **SPEC-FORMAT-TERSE.2.2.2 — Perl attached-block if landed**
  (PERL ACTIONIR + PHASE0 + BOOK/KM LOCKS). Compact attached-block `if/elseif/else` now works on the Perl
  reference without explicit `endif`: `if(cond) { ... } elseif(cond2) { ... } else { ... }` splits into branch
  statements, lowers without raw fallback, and executes only the selected branch. Marker-form and
  inline-composite `if` behavior remains unchanged. The mdBook documents this as Perl-reference support, not
  yet the portable cross-backend contract.
  **Verification:** Perl syntax checks PASS; TOOLBOX lowering/metadata/runtime probes PASS; phase0 PASS
  (`t/phase0_regression.t`, **991 tests**); mdBook build PASS; Knowledge Map regenerate/check PASS;
  memory/doctrine/diff checks PASS.
  **Frontier: `SPEC-FORMAT-TERSE.2.2.3`** (Rust parity for attached-block `if/elseif/else`).
- 2026-06-30: **SPEC-FORMAT-TERSE.2.2.2 — Perl attached-block if owned before code**
  (DOCS/TREE/KM ONLY; **no engine behavior change**). TOOLBOX probes narrowed the Perl implementation boundary:
  newline-separated attached branches already lower through ActionIR, but compact same-line chains such as
  `if(cond) { ... } elseif(cond2) { ... } else { ... }` still fall back to raw Perl. Code-read points the
  implementation at `StatementSplit::Core`; scanner/lowering/rewrite support for individual attached branch
  statements already exists.
  **Verification:** TOOLBOX lowering/metadata probes; Perl code-read; Knowledge Map regenerate/check PASS;
  memory/doctrine/diff checks PASS.
  **Frontier: `SPEC-FORMAT-TERSE.2.2.2`** (implementation of the same-line attached-branch split).
- 2026-06-30: **SPEC-FORMAT-TERSE.2.2.1 — control-flow keyword surface split**
  (DOCS/TREE/KM/BOOK ALIGNMENT; **no engine behavior change**). Round 2 control flow is now decomposed into
  signoff-sized leaves. Current portable support is statement-marker `if(cond); ... elseif(cond); else();
  ... endif()` plus inline-composite lazy `if`/`switch`. Attached-block `if`, `when`/`otherwise`,
  statement-level `switch` blocks, and `while` remain separate implementation work. The mdBook now calls out
  this boundary instead of presenting attached-block control flow as fully portable.
  **Verification:** TOOLBOX lowering/runtime/metadata probes; Perl/Rust code-read; focused Rust parser check
  PASS; mdBook build PASS; Knowledge Map regenerate/check PASS; memory/doctrine/diff checks PASS.
  **Frontier: `SPEC-FORMAT-TERSE.2.2.2`** (Perl reference attached-block `if/elseif/else`; own before code).
- 2026-06-30: **SPEC-FORMAT-TERSE.2.1.4 — expression-valued block early return landed**
  (PERL ACTIONIR + RUST RUNTIME + ORACLE/KM/BOOK LOCKS). Expression-valued blocks now support block-local
  early `return(expr)` on both variants. `return({ return("a"); "b" })` yields `"a"`; assignment-source block
  values skip later statements after the return payload; nested block values preserve hash-literal payloads.
  `{}` and `{ key => value }` still remain hash shape literals, and the block-local return does not leak into
  the surrounding rule return channel.
  **Verification:** Perl syntax checks PASS; TOOLBOX lowering/runtime probes PASS; focused Rust `.2.1.4`
  runtime locks PASS; oracle corpus regenerated to **35 fixtures** and corpus oracle PASS; phase0 PASS
  (`t/phase0_regression.t`, **991 tests**); mdBook/KM/memory/doctrine/diff checks PASS; full local CI PASS.
  **Frontier: `SPEC-FORMAT-TERSE.2.2`** (Round 2 control-flow keyword surface; own before code).
- 2026-06-29: **SPEC-FORMAT-TERSE.2.1.3 — Rust expression-valued block parity landed**
  (RUST PARSER/RUNTIME + ORACLE/KM/BOOK LOCKS). Rust now matches the Perl-reference core block-value subset:
  non-empty brace payloads without a top-level `=>` parse as `Expr::BlockValue`, `{}` and `{ key => value }`
  remain hash literals, side-effect statements run in order, and the final expression or final `return(expr)`
  yields the block value. True mid-block early return remains `.2.1.4`; Rust rejects non-final `return(expr)`
  inside block values instead of leaking a rule return.
  **Verification:** focused Rust core parser locks PASS; focused Rust runtime `.2.1.3` locks PASS; oracle
  corpus regenerated to **34 fixtures** and corpus oracle PASS; full Rust core package PASS; full Rust runtime
  package PASS; mdBook/KM/memory/doctrine/diff checks PASS; full local CI PASS (`tools/run_ci_local.sh`,
  phase0 **991** tests).
  **Frontier: `SPEC-FORMAT-TERSE.2.1.4`** (true block-local early-return follow-through, if still needed).
- 2026-06-29: **SPEC-FORMAT-TERSE.2.1.3 — Rust expression-valued block parity owned before code**
  (DOCS/TREE/KM ONLY; **no Rust engine, oracle, fixture, mdBook behavior, or Perl behavior change**). Rust
  parity is now scoped to the accepted Perl-reference core: non-empty brace payloads without a top-level `=>`
  should become block-value expressions, while `{}` and `{ key => value }` remain hash literals. Code-read
  identified the implementation seams as `Expr`/brace parsing in `rust/linkedspec-core/src/expr.rs` and a
  value-returning block evaluator in `rust/linkedspec-runtime/src/engine.rs`; true mid-block early return stays
  `.2.1.4`.
  **Verification:** Rust code-read; mdBook build PASS; Knowledge Map regenerate/check PASS;
  memory/doctrine/diff checks PASS.
  **Frontier: `SPEC-FORMAT-TERSE.2.1.3`** (implementation of Rust parser/runtime parity).
- 2026-06-29: **SPEC-FORMAT-TERSE.2.1.2 — Perl-reference core expression-valued blocks landed**
  (PERL ACTIONIR + AUTO-DECL + PHASE0 + BOOK/KM LOCKS). The Perl reference now accepts non-empty brace
  payloads without a top-level `=>` as value blocks in value-consuming sites. Blocks evaluate their statements
  and return the final expression; a final `return(expr)` is treated as block-local for this core subset. `{}` and
  `{ key => value }` remain hash shape literals, and nested final hash literals are preserved as hashrefs.
  Full block-local early return remains split to `.2.1.4`; Rust parity remains `.2.1.3`.
  **Verification:** Perl syntax checks PASS; TOOLBOX lowering/runtime probes PASS; phase0 PASS
  (`t/phase0_regression.t`, **991 tests**); mdBook build PASS; Knowledge Map regenerate/check PASS;
  memory/doctrine/diff checks PASS; full local CI PASS.
  **Frontier: `SPEC-FORMAT-TERSE.2.1.3`** (Rust parity for core expression-valued blocks).
- 2026-06-29: **SPEC-FORMAT-TERSE.2.1.1 — expression-valued block split completed**
  (DOCS/TREE/KM ONLY; **no engine, fixture, or mdBook behavior change**). KM retrieval, TOOLBOX probes, and
  code-read showed expression-valued blocks cross too many seams for one implementation leaf. `{}` and
  `{ key => value }` remain hash shape literals. Non-empty brace payloads without a top-level `=>` currently
  fail as value blocks: Perl emits invalid generated Perl for forms like `return({ set(x,"a"); x })`, and Rust
  has no block-expression AST/runtime path. The split children are `.2.1.2` Perl reference core,
  `.2.1.3` Rust parity, and `.2.1.4` full block-local explicit-return follow-through if needed.
  **Verification:** KM retrieval; TOOLBOX lowering/runtime/source probes; Perl/Rust code-read; KM/memory/doctrine/diff checks.
  **Frontier: `SPEC-FORMAT-TERSE.2.1.2`** (Perl reference core expression-valued blocks; owned before code).
- 2026-06-29: **SPEC-FORMAT-TERSE.1.6 — array end-mutation methods landed**
  (PERL ACTIONIR + RUST RUNTIME + ORACLE/KM/BOOK LOCKS). Statement-level receiver-dot methods now mutate named
  working arrays on both variants: `items.push_back(value)`, `items.push_front(value)`, `items.pop_back()`,
  and `items.pop_front()`. Receivers may be bare or explicit `array(items)` / `a(items)`; push values use the
  settled mutation-slot value rules, so bare push values read scalar working variables; pop methods discard the
  removed value. Perl reports canonical `ARRAY_MUTATE` with zero fallback and auto-supplies one `my @items`
  plus push-value scalar declarations as needed. Rust executes the same statement forms in
  `Engine::execute_block`.
  **Verification:** Perl syntax checks PASS; TOOLBOX lowering/runtime/source probes PASS; focused Rust
  parser/runtime `.1.6` locks PASS; oracle corpus regenerated to **33 fixtures** and corpus oracle PASS;
  phase0 PASS (`t/phase0_regression.t`, **990 tests**).
  **Frontier: `SPEC-FORMAT-TERSE.2.1`** (Round 2 expression-valued blocks; ground-truth/split before code).
- 2026-06-29: **SPEC-FORMAT-TERSE.1.2.3.5.4 — Rust RHS shape target-kind inference parity landed**
  (RUST RUNTIME + ORACLE/KM). Rust now matches the Perl target-kind rule accepted in `.1.2.3.5.2`: direct RHS
  shape literals infer aggregate working-variable targets when the assignment target is bare or explicitly
  aggregate-typed. `items = [value]`, `set(items, [])`, and `set(array(items), [value])` replace the runtime
  array working variable; `meta = { key => value }`, `assign(meta, {})`, and `set(hash(meta), { key => value })`
  replace the runtime hash working variable. Explicit scalar targets remain scalar payload assignments:
  `set(scalar(payload), [value])` stores the array payload in scalar `payload`.
  **Verification:** focused Rust runtime `.1.2.3.5.4` locks PASS; oracle corpus regenerated to **32 fixtures**
  and corpus oracle PASS.
  **Frontier: `SPEC-FORMAT-TERSE.1.6`** (own before code: array end-mutation methods).
- 2026-06-29: **SPEC-FORMAT-TERSE.1.2.3.5.3 — Rust shape-literal value parity landed**
  (RUST AST/PARSER + RUNTIME + ORACLE). Rust now accepts direct `[]` / `{}` shape literals as value
  expressions in the same accepted value slots as Perl `.1.2.3.5.1`: return payloads, scalar assignment
  sources, array append RHS values, hash-index assignment RHS values, and nested payloads. Shape members reuse
  normal Rust expression evaluation, so `[value, cat("a","b"), true, []]` and
  `{ key => value, "fixed" => [value] }` preserve typed nested payloads and scalar bare reads. Rust target-kind
  inference is intentionally still deferred: `name = [value]` remains a scalar-held array payload until
  `.1.2.3.5.4`.
  **Verification:** focused Rust parser locks PASS; focused Rust runtime `.1.2.3.5.3` locks PASS; oracle corpus
  regenerated to **30 fixtures** and corpus oracle PASS.
  **Frontier: `SPEC-FORMAT-TERSE.1.2.3.5.4`** (Rust RHS target-kind inference parity).
- 2026-06-29: **SPEC-FORMAT-TERSE.1.2.3.5.2 — Perl RHS shape target-kind inference landed**
  (PERL ACTIONIR + DECLARE INIT + AUTO-DECL + PHASE0 + BOOK/KM LOCKS). Direct RHS shape literals now infer the
  aggregate kind of a bare assignment target on the Perl reference: `items = [value]` / `set(items, [])` assign
  array working variable `@items`, and `meta = { key => value }` / `assign(meta, {})` assign hash working
  variable `%meta`. Non-shape RHS values remain scalar assignment, and explicit `scalar(name)` targets keep
  scalar-held payload behavior (`set(scalar(payload), [value])` -> `$payload = [$value]`). Typed array/hash
  declaration initializers now unwrap lowered direct shapes, so `declare(array, items=[value, cat("a","b")])`
  and `declare(hash, meta={ key => value, "fixed" => [value] })` compose with scalar bare reads and helper
  values.
  **Verification:** Perl syntax checks PASS; TOOLBOX lowering/runtime/source probes PASS; phase0 PASS
  (`t/phase0_regression.t`, **989 tests**); mdBook/KM/memory/doctrine/diff checks PASS; full local CI PASS.
  **Frontier: `SPEC-FORMAT-TERSE.1.2.3.5.3`** (Rust shape-literal value parity).
- 2026-06-29: **SPEC-FORMAT-TERSE.1.2.3.5.1 — Perl shape-literal value expressions landed**
  (PERL ACTIONIR + AUTO-DECL + PHASE0 + BOOK/KM LOCKS). Direct `[]` / `{}` shapes are now DSL value
  expressions on the Perl reference instead of raw Perl passthrough. Empty shapes still lower as `[]` / `{}`;
  non-empty shapes lower their elements, keys, and values through the accepted value-expression rules, so
  `[value]` and `{ key => value }` read scalar working variables and auto-supply `my $value` / `my $key` when
  needed. Fixed hash field names must be quoted (`{ "kind" => value }`). Target-kind inference is unchanged:
  `name = [value]` still assigns scalar `name` to an array payload and does not infer `@name`.
  **Verification:** Perl syntax checks PASS; TOOLBOX lowering/runtime/source probes PASS; phase0 PASS
  (`t/phase0_regression.t`, **988 tests**); mdBook updated.
  **Frontier: `SPEC-FORMAT-TERSE.1.2.3.5.2`** (Perl RHS target-kind inference).
- 2026-06-29: **SPEC-FORMAT-TERSE.1.2.3.5 — RHS-shape/type-inference split completed**
  (DOCS/TREE/KM ONLY; **no engine, fixture, or mdBook behavior change**). KM + TOOLBOX/source/runtime/code-read
  probes showed the remaining Channel 2 shape work is too broad for one implementation leaf. Perl already
  accepted empty `[]`/`{}` as raw scalar value expressions at split time, but `name = []` / `name = {}` assign
  scalar `$name` / `$meta`-style slots rather than initializing aggregate working variables. Non-empty shapes such as
  `[value]` and `{ key => value }` passed through raw Perl at split time, so bare identifiers became
  barewords/strings rather than the settled scalar working-variable reads before `.1.2.3.5.1`. Rust currently
  has no bracket/brace value-expression parser. The split children are `.1.2.3.5.1` Perl shape-literal values,
  `.1.2.3.5.2` Perl RHS target-kind inference, `.1.2.3.5.3` Rust shape-literal parity, and `.1.2.3.5.4`
  Rust target-inference parity.
  **Verification:** KM/TOOLBOX/source/runtime/code-read probes completed; KM/memory/doctrine/diff checks run for
  the slice.
  **Frontier: `SPEC-FORMAT-TERSE.1.2.3.5.1`** (Perl shape-literal value expressions).
- 2026-06-29: **SPEC-FORMAT-TERSE.1.2.3.4 — Rust scalar bare-read parity landed**
  (RUST PARSER + RUNTIME LOCKS + ORACLE/KM). Rust now accepts the scalar bare-read contract already landed on
  the Perl reference: `return(value)`, `set(out, value)`, `name = value`, `items += value`,
  `set_key(meta, key, value)`, `meta[key] = value`, and direct-access path indexes such as `foo["a"][idx]`
  all evaluate bare identifiers through the existing scalar working-variable read path. The runtime already
  evaluated `Expr::Variable` as `ctx.get_scalar(name)`; this slice removed obsolete parser reservations and
  added parser/runtime/oracle locks. RHS-shape `[]`/`{}` inference and expression-valued blocks remain later,
  all-bare `push(A,B)` remains child-call syntax, and the remaining Channel 2 shape work is now tracked as
  `SPEC-FORMAT-TERSE.1.2.3.5`.
  **Verification:** focused Rust parser tests PASS; focused Rust runtime `.1.2.3.4` tests PASS; oracle corpus
  regenerated to **28 fixtures** and corpus oracle PASS; mdBook build PASS; KM/memory/doctrine/diff checks
  PASS; full local CI PASS.
  **Frontier: `SPEC-FORMAT-TERSE.1.2.3.5`** (RHS-shape/type-inference split before code).
- 2026-06-29: **SPEC-FORMAT-TERSE.1.2.3.3.3 — Perl direct-access bare path atoms landed**
  (PERL ACTIONIR + AUTO-DECL + PHASE0 + BOOK/KM LOCKS). Non-reserved bare atoms inside direct-access bracket
  paths now read scalar working variables as array indexes: `foo["a"][z]` lowers/runs like
  `foo["a"][scalar(z)]` (`$foo->{"a"}->[$z]`) and auto-supplies one per-invocation `my $z` when needed.
  Quoted path segments remain hash keys, numeric/helper segments remain array indexes, primitive literals and
  engine locals are not claimed, `scalaref(...)` keeps its historical path semantics, RHS-shape inference is
  still later, and all-bare `push(A,B)` remains child-call syntax.
  **Verification:** Perl syntax checks PASS; TOOLBOX lowering probes PASS; phase0 PASS (`1..987`);
  mdBook build PASS; KM/memory/doctrine/diff checks PASS; full local CI PASS.
  **Frontier: `SPEC-FORMAT-TERSE.1.2.3.4`** (Rust scalar bare-read parity).
- 2026-06-29: **SPEC-FORMAT-TERSE.1.2.3.3.2 — Perl scalar mutation-slot bare reads landed**
  (PERL ACTIONIR + SCANNER + PHASE0 + BOOK/KM LOCKS). `items += VALUE`,
  `set_key(meta, KEY, VALUE)`, and `meta[KEY] = VALUE` now read non-reserved bare key/RHS identifiers as scalar
  working variables and auto-supply one per-invocation `my $NAME` when needed. Target inference is unchanged
  (`@items` / `%meta`), primitive literals stay exact, reserved engine locals are not claimed, direct path atoms
  remain deferred, and all-bare `push(A,B)` remains child-call syntax.
  **Verification:** Perl syntax checks PASS; TOOLBOX lowering probes PASS; phase0 PASS (`1..986`);
  mdBook/KM/local CI PASS.
  **Frontier: `SPEC-FORMAT-TERSE.1.2.3.3.3`** (Perl direct-access bare path atoms).
- 2026-06-29: **SPEC-FORMAT-TERSE.1.2.3.3.1 — Perl scalar source-slot bare reads landed**
  (PERL ACTIONIR + PHASE0 + BOOK/KM LOCKS). `return(NAME)`, `set(out, NAME)` / `assign(out, NAME)`, and
  scalar operator `out = NAME` now read scalar working variable `NAME` and auto-supply one per-invocation
  `my $NAME` when needed. Primitive literals remain exact (`true`/`false`/`undef`), while prefix identifiers
  such as `trueword` are scalar identifiers in these source slots. This does **not** advance array append RHS,
  hash mutation key/RHS slots, direct path atoms, generic helper arguments, or all-bare child-call `push(A,B)`.
  **Verification:** Perl syntax checks PASS; TOOLBOX/source/runtime probes PASS; phase0 PASS (`1..985`);
  mdBook/KM/local CI PASS.
  **Frontier: `SPEC-FORMAT-TERSE.1.2.3.3.2`** (Perl mutation key/RHS scalar slots).
- 2026-06-29: **SPEC-FORMAT-TERSE.1.2.3.3 — Perl scalar bare reads split by lowering seam**
  (DOCS/TREE/KM ONLY; **no engine, fixture, or mdBook behavior change**). TOOLBOX probes showed the remaining
  scalar Channel 2 work is not one implementation seam. Return/assignment source slots still emit raw barewords
  (`return(count)`, `set(out,count)`, `name = value`); named hash mutation already lowers a bare key through
  `$key` but not a bare value; array append and hash-index operator forms reject bare RHS/key tokens before
  lowering; direct `foo["a"][z]` remains raw while explicit `[scalar(z)]` works. `.1.2.3.3` is now a container:
  `.1.2.3.3.1` return/assignment source slots, `.1.2.3.3.2` mutation key/RHS slots, and `.1.2.3.3.3`
  direct-access bare path atoms. **Verification:** TOOLBOX lowering probes PASS; KM/memory/doctrine/diff checks
  green.
  **Frontier: `SPEC-FORMAT-TERSE.1.2.3.3.1`** (Perl scalar source-slot bare reads).
- 2026-06-29: **SPEC-FORMAT-TERSE.1.2.3.2 — Rust aggregate bare value-read parity landed**
  (RUST ENGINE + ORACLE + INTEGRATION LOCKS; **no mdBook prose change needed because `.1.2.3.1` already taught
  the variant-neutral contract**). Rust aggregate snapshot helpers now resolve bare working-variable reads like
  the Perl reference: `array_copy(items)` and array-first `copy(items)` read array `items`, while
  `hash_copy(meta)` reads hash `meta`; `copy(hash(meta))` remains the explicit hash-copy spelling. The change is
  scoped to aggregate resolver call sites and does **not** advance scalar bare reads, bare hash-index key/RHS
  forms, or bare direct-access path atoms. **Verification:** focused Rust `.1.2.3.2` tests PASS; focused Rust
  bare direct-access rejection PASS; oracle corpus regenerated to **25 fixtures** and corpus oracle PASS; full
  Rust runtime suite PASS (116 unit tests, 25 oracle fixtures, 54 integration tests); clippy EXIT 0 with the
  existing warning baseline; phase0/mdBook/KM/local CI PASS.
  **Frontier: `SPEC-FORMAT-TERSE.1.2.3.3`** (Perl scalar bare value reads).
- 2026-06-29: **SPEC-FORMAT-TERSE.1.2.3.1 — Perl aggregate bare value-read auto-existence landed**
  (PERL ACTIONIR + PHASE0 + BOOK/KM LOCKS). Aggregate bare reads that already lower to sigiled Perl aggregates
  now get safe per-invocation declarations: `array_copy(items)` and array-first `copy(items)` auto-supply
  `my @items`, while `hash_copy(meta)` auto-supplies `my %meta`. Wrapped/declared paths dedup unchanged; reserved
  literals such as `undef` are still skipped. Same-parser array/hash reruns prove the targets do not leak across
  parses. This does **not** advance scalar bare reads (`return(count)`), bare RHS/key forms, or bare direct-access
  atoms. **Verification:** Perl syntax checks PASS; focused generated-source/runtime/no-leak probe PASS; phase0
  PASS (`1..984`); mdBook/KM/local CI PASS.
  **Frontier: `SPEC-FORMAT-TERSE.1.2.3.2`** (Rust parity for aggregate bare value reads).
- 2026-06-29: **SPEC-FORMAT-TERSE.1.2.3 — Channel 2 value reads split by aggregate/scalar surfaces**
  (DOCS/TREE/KM ONLY; **no engine, fixture, or mdBook behavior change**). KM + TOOLBOX/code-read ground truth
  showed Channel 2 is not one implementation seam. Perl aggregate bare value reads already lower
  (`array_copy(items)` -> `[@items]`, `hash_copy(meta)` -> `{%meta}`, `copy(items)` -> `[@items]`) but do not
  get safe preamble declarations, so they still risk non-strict package globals. Rust keeps bare aggregate
  value reads out of aggregate-copy resolvers. Scalar-like value reads remain separate: Perl still emits
  bareword/raw forms for `return(count)`, `set(out,count)`, `items += value`, `meta[key] = value`, and
  `foo["a"][z]`, while Rust already evaluates plain variables as scalar reads. **Verification:** TOOLBOX
  lowering/source probes PASS; KM/memory/doctrine/diff checks green.
  **Frontier: `SPEC-FORMAT-TERSE.1.2.3.1`** (Perl aggregate bare value-read auto-existence).
- 2026-06-29: **SPEC-FORMAT-TERSE.1.5.5.2 — bare direct-access coordination merged into Channel 2**
  (DOCS/TREE/KM ONLY; **no engine, fixture, or mdBook behavior change**). KM retrieval plus TOOLBOX reverify
  showed the post-`.1.5.5.1` boundary is unchanged: `foo["a"][9]["b"][scalar(z)]` lowers through the canonical
  dereference path, but `foo["a"][9]["b"][z]` remains raw and `return(z)` remains a bareword. Rust keeps the
  parser rejection lock for bare direct-access segments. Therefore the full brainstorm spelling cannot be
  implemented as a direct-access-local rule without pre-empting global Channel 2 semantics. `.1.5.5.2` is
  superseded/merged into new `.1.2.3`, which owns value-position bare-word reads, bare RHS/key expressions,
  bare direct-access path atoms, and RHS-shape/type inference. **Verification:** TOOLBOX reverify PASS; focused
  Rust parser rejection lock PASS; KM/memory/doctrine/diff checks green.
  **Frontier: `SPEC-FORMAT-TERSE.1.2.3`** (Channel 2 design/split).
- 2026-06-29: **SPEC-FORMAT-TERSE.1.5.5.1 — direct nested access with explicit segments landed**
  (PERL ACTIONIR + RUST PARSER/RUNTIME + ORACLE + BOOK/KM LOCKS). Direct mixed access such as
  `foo["a"][9]["b"][scalar(z)]` now works on both variants. Perl lowers it to
  `$foo->{"a"}->[9]->{"b"}->[$z]`, matching the existing explicit `scalaref(...)` path; Rust parses it as
  `NestedAccess` and walks the scalar-held base payload through hash-key and array-index segments. Quoted
  string segments are hash keys; numeric/helper segments are array indexes. Bare path atoms such as `[z]`
  remain deferred to `.1.5.5.2` / Channel 2, and `scalaref(base,path)` remains accepted. **Verification:**
  phase0 PASS, Rust focused parser/runtime tests PASS, Rust corpus oracle PASS over 21 fixtures, full Rust
  runtime PASS, mdBook/KM/memory/doctrine/local gates green.
  **Frontier: `SPEC-FORMAT-TERSE.1.5.5.2`** (bare path-segment / Channel 2 coordination).
- 2026-06-29: **SPEC-FORMAT-TERSE.1.5.5 — direct nested access split by Channel 2 boundary**
  (DOCS/TREE/KM ONLY; **no engine, fixture, or mdBook behavior change**). Split-time KM + TOOLBOX probes showed
  direct `foo["a"][9]["b"][scalar(z)]` was not yet a valid lowered value expression: it passed through as
  `foo["a"][9]["b"][$z]` and generated handler compilation failed near `][`. The existing
  `scalaref(foo,{"a"}[9]{"b"}[scalar(z)])` path remains the working explicit syntax and lowers to
  `$foo->{"a"}->[9]->{"b"}->[$z]`. Bare segment `z` remains Channel 2 value-position-read work. `.1.5.5` is
  now a container: `.1.5.5.1` explicit path segments first, `.1.5.5.2` bare-segment/Channel-2 coordination.
  **Frontier: `SPEC-FORMAT-TERSE.1.5.5.1`** (direct nested access with explicit path segments).
- 2026-06-29: **SPEC-FORMAT-TERSE.1.5.4 — statement separator contract landed**
  (PERL ACTIONIR + BOOTSTRAP NORMALIZATION + RUST PARSER/RUNTIME + ORACLE + BOOK/KM LOCKS). Newlines now
  separate top-level canonical DSL statements, and semicolons remain accepted and required for multiple
  statements on one physical line. Perl lowering emits valid generated Perl for newline-separated statements
  such as `set(name,"a")` followed by `return(scalar(name))`; same-line adjacent helpers without `;` stay
  explicit non-canonical blockers, matching Rust parser rejection. Nested semicolons inside expression payloads
  remain protected. Bootstrap normalizes captured fluent attached-control tails with internal newlines so
  `Top.if(...) { ... } elseif(...) { ... } else { ... }` remains supported without weakening the same-line
  rule. **Verification:** phase0 PASS (`1..982`), oracle corpus regenerated with 20 fixtures, focused Rust
  parser/runtime `.1.5.4` tests PASS, Rust corpus oracle PASS over 20 fixtures, full Rust runtime PASS,
  mdBook/KM/memory/doctrine/local gates green.
  **Frontier: `SPEC-FORMAT-TERSE.1.5.5`** (direct nested access surface).
- 2026-06-29: **SPEC-FORMAT-TERSE.1.5.3 — call spacing and mandatory-call-parentheses locks landed**
  (PERL PHASE0 + RUST PARSER/RUNTIME + ORACLE + BOOK/KM LOCKS). Helper calls keep the uniform
  `callee(args)` shape, while optional whitespace before the opening parenthesis is accepted at supported
  statement and value-expression sites: `return (value)`, `set (name, value)`, nested `cat ("a","b")` /
  `scalar (name)`, array-append RHS calls, and hash-index key/RHS calls. No-parenthesis helper spellings
  remain out of scope: `set name,"v"`, `return scalar name`, and `return(cat "a","b")` are not claimed as
  helper calls. **Verification:** phase0 PASS (`1..981`), oracle corpus regenerated with 19 fixtures, focused
  Rust parser/runtime `.1.5.3` tests PASS, Rust corpus oracle PASS over 19 fixtures, mdBook/KM/memory/doctrine
  gates green. **Frontier: `SPEC-FORMAT-TERSE.1.5.4`** (statement separator contract).
- 2026-06-29: **SPEC-FORMAT-TERSE.1.5.2 — primitive literal parity landed**
  (PERL ACTIONIR + RUST RUNTIME FLOW + BOOK + PHASE0/RUST/ORACLE LOCKS). Primitive literals are now typed
  value expressions across return payloads, assignments, appends, hash-index keys/values, and flow predicates:
  quoted strings stay strings, numbers stay numeric, `undef` becomes null, and `true`/`false` become JSON
  booleans. Perl lowers booleans through `JSON::PP`, with exact matching so `trueword`/`undefine` remain
  identifiers; scanner/legacy disambiguation now treats `push(items,false)` as a value append while preserving
  all-bare child-call behavior for non-literal identifiers. Rust gained statement-form `if/elseif/else/endif`
  gating so `if(false)` skips the then branch; value-form `if(cond,then,else)` is unchanged. **Verification:**
  phase0 PASS (`1..980`), oracle corpus regenerated with 18 fixtures, focused Rust `.1.5.2` tests PASS, Rust
  corpus oracle PASS over 18 fixtures, mdBook/KM/memory/doctrine/local gates green. **Frontier:
  `SPEC-FORMAT-TERSE.1.5.3`** (function-call spacing and mandatory-parentheses locks).
- 2026-06-29: **SPEC-FORMAT-TERSE.1.5 — literal/nested-access/call/semicolon surface split before code**
  (DOCS/TREE/KM ONLY; **no engine, fixture, or mdBook behavior change**). PNT selected `.1.5` and ran KM +
  TOOLBOX/code-read first. Ground truth: Perl strings/numbers/`undef` already run, but `true`/`false` return
  strings while Rust has typed booleans; optional whitespace before `(` works at supported helper/value sites;
  newline-separated adjacent lowered statements still fail on Perl without `;`, while Rust accepts broader
  whitespace-separated statements; direct `foo["a"][9]['b'][z]` is not lowered on Perl and Rust only has
  single array-index access. `.1.5` is now an active container: `.1.5.1` audit/split done, `.1.5.2` primitive
  literal parity, `.1.5.3` call-spacing locks, `.1.5.4` separator semantics, `.1.5.5` direct nested access.
  **Frontier: `SPEC-FORMAT-TERSE.1.5.2`**.
- 2026-06-29: **SPEC-FORMAT-TERSE.1.3.4.3 — hash-index assignment operator `name[key] = value` landed**
  (PERL ACTIONIR + RUST PARSER/RUNTIME + BOOK + PHASE0/RUST/ORACLE LOCKS). Top-level `NAME[KEY] = VALUE`
  now lowers/runs identically to the settled named-hash mutation form `set_key(NAME, KEY, VALUE)` when the key
  and value are explicit expressions. Perl recognizes it through an ASSIGN contract/scanner/lowering path and
  auto-supplies one `my %NAME` preamble for a bare hash target; Rust parses it as statement-only
  `AssignHashIndex`, evaluates the key to a string, and mutates the per-parse hash map. Boundaries remain
  explicit: `meta["stage"] = "v"`, `meta[cat("s","tage")] = cat("v","!")`, and
  `meta[scalar(key)] = scalar(value)` work, while bare key/RHS forms such as `meta[key] = "v"` and
  `meta["stage"] = value` stay deferred to Channel 2. **Verification:** TOOLBOX parity probes; phase0 PASS
  (`1..979`); oracle corpus regenerated with 16 fixtures; focused Rust core/runtime tests PASS; Rust corpus
  oracle PASS; mdBook + KM + memory/doctrine + local CI gates green. **Frontier:
  `SPEC-FORMAT-TERSE.1.5`** (literal/nested-access/call/semicolon surface; scope/split first).
- 2026-06-29: **SPEC-FORMAT-TERSE.1.3.4.2 — array append operator `items += value` landed** (PERL
  ACTIONIR + RUST PARSER/RUNTIME + BOOK + PHASE0/RUST/ORACLE LOCKS). Top-level `NAME += RHS` now lowers/runs
  identically to the settled explicit append forms for explicit RHS expressions. Perl recognizes it through a
  PUSH contract/scanner/lowering path and auto-supplies one `my @NAME` preamble for a bare array target; Rust
  parses it as statement-only `AssignArrayAppend`, evaluates the RHS, and appends through the per-parse array
  map. Boundaries remain explicit: `items += scalar(value)` works, while bare `items += value` stays deferred
  to Channel 2; child-call `push(A,B)`, increment-like `items ++`, scalar assignment, and hash-index
  assignment are not conflated. **Verification:** TOOLBOX parity probes; descriptor/source/runtime probes
  (`PUSH,RETURN`, fallback 0, one array declaration); phase0 PASS (`1..978`); oracle corpus regenerated with
  15 fixtures; focused Rust core/runtime tests PASS; Rust corpus oracle PASS; mdBook + KM + memory/doctrine +
  local CI gates green. **Frontier: `SPEC-FORMAT-TERSE.1.3.4.3`** (hash-index assignment operator).
- 2026-06-29: **SPEC-FORMAT-TERSE.1.3.4.1 — scalar assignment operator `name = value` landed** (PERL
  ACTIONIR + RUST PARSER/RUNTIME + BOOK + PHASE0/RUST/ORACLE LOCKS). Top-level `NAME = RHS` now lowers/runs
  identically to `set(NAME,RHS)` / `assign(NAME,RHS)`. Perl recognizes it through an ASSIGN
  contract/scanner/lowering path and auto-supplies one `my $NAME` preamble for a bare scalar target; Rust parses
  it as statement-only `AssignScalar`, executes it with `RuntimeContext::set_scalar`, and rejects nested
  assignment expressions. Boundaries remain explicit: equality, array append, hash-index assignment, helper
  keyword args, nested assignment expressions, and Channel 2 bare value-position reads are still separate
  pending work. **Verification:** TOOLBOX parity probes; descriptor/source/runtime probes (`ASSIGN,RETURN`,
  fallback 0, one scalar declaration); phase0 PASS (`1..977`); oracle corpus regenerated with 14 fixtures;
  focused Rust core/runtime tests PASS; full Rust runtime suite PASS (116 unit + corpus-oracle harness + 41
  integration tests); mdBook + KM + memory/doctrine + local CI gates green. **Frontier:
  `SPEC-FORMAT-TERSE.1.3.4.2`** (array append operator).
- 2026-06-29: **SPEC-FORMAT-TERSE.1.3.4 — operator syntax family split into scalar, array, and hash leaves**
  (DOCS/TREE/KM ONLY; **no engine, test, fixture, or mdBook behavior change**). PNT selected the next frontier
  after `.1.3.3` and ran the required KM + TOOLBOX recon before code. Ground truth: `name = "ok"`,
  `items += "a"`, and `name["k"] = "v"` still pass through unchanged as RAW_PERL blockers on Perl; the settled
  function forms `set(...)`, `push(...)` for unambiguous value expressions, and `set_key(...)` lower correctly.
  A descriptor probe over all three operator forms reports three `RAW_PERL` fallback events and three
  language-agnostic blocker statements. Rust code-read shows lifecycle code is expression-statement-only
  (`Stmt { expr }`) and has no assignment/append/hash-set statement variants. `.1.3.4` is now a container:
  `.1.3.4.1` scalar `name = value`, `.1.3.4.2` array `items += value`, `.1.3.4.3` hash `name[key] = value`.
  **Frontier: `SPEC-FORMAT-TERSE.1.3.4.1`** (scalar assignment operator).
- 2026-06-29: **SPEC-FORMAT-TERSE.1.3.3 — hash function mutation `set_key(name,key,value)` landed while
  preserving pure `set_key(hash_expr,key,value)`** (PERL ACTIONIR + RUST ENGINE + BOOK + PHASE0/RUST/ORACLE
  LOCKS). Top-level `set_key(name,key,value)` is now a statement-level named-hash mutation: Perl lowers it to
  direct `$name{key} = value` assignment and auto-supplies one preamble `my %name` for a bare target; Rust
  handles top-level `set_key(...)` before generic expression evaluation and mutates the named runtime hash.
  Nested/value-form `set_key(hash(meta), key, value)` remains a pure copy helper and is locked not to mutate the
  source hash. Added the `set_key_statement` ASSIGN contract/scanner/lowering path, EmitContext bare-hash
  collector coverage, Rust `execute_set_key_statement`, +1 phase0 subtest, 2 Rust integration tests, oracle
  fixture `terse_1_3_3_set_key_statement_hash`, book updates, and KM updates. **Verification:** TOOLBOX
  lowerings distinguish mutation vs pure value form; descriptor/source/runtime probes show ASSIGN recognition,
  one `my %meta`, same-parser stability, and non-mutating nested pure behavior; phase0 PASS (976); focused Rust
  `terse_1_3_3` PASS; corpus oracle PASS over 13 fixtures; mdBook build EXIT 0; Knowledge Map +
  memory-architecture + doctrine checks OK; full local gate EXIT 0. **Frontier:
  `SPEC-FORMAT-TERSE.1.3.4`** (operator syntax family).
- 2026-06-29: **SPEC-FORMAT-TERSE.1.3.2 — array function spelling `push(target,value)` landed while preserving
  child-call `push(...)`** (PERL ACTIONIR + BOOK + PHASE0 LOCKS + RUST ORACLE/INTEGRATION LOCKS; **no Rust
  engine change**). Selected conservative disambiguation: `push(target,value)` lowers/runs like
  `push_value(target,value)` only for unambiguous/non-all-bare value expressions (`"literal"`,
  `scalar(value)`, helper values such as `cat(...)`, or `call(Child)`). All-bare `push(A,B)` keeps the
  child-call meaning (`A` rule into `B` accumulator); appending a working-variable value remains
  `push(items, scalar(value))` or `push_value(items, scalar(value))` until Channel 2 bare value-position reads land.
  Perl recognition now accepts the alias in the `push_value` contract/scanner/lowering path, and the auto-array
  collector uses a balanced parser-backed scan so nested comma values such as `cat("a","b")` declare exactly
  one `my @items`. Rust already accepted `"push_value" | "push"`; this slice locks it with a Perl-oracle fixture
  and integration test. **Verification:** TOOLBOX lowerings prove explicit append vs child-call precedence;
  descriptor/runtime probe returns `["a","b"]` with zero fallback/unresolved; source dump for nested/comma value
  has one `my @items`; phase0 PASS (975); focused Rust test PASS; corpus oracle PASS over 12 fixtures; mdBook
  build EXIT 0; Knowledge Map + memory-architecture checks OK; full local gate EXIT 0. **Frontier:
  `SPEC-FORMAT-TERSE.1.3.3`** (hash function mutation semantics).
- 2026-06-29: **SPEC-FORMAT-TERSE.1.3 — split mutation surface by mechanism; record push/operator ground truth** (DOCS/TREE/KM only; **no engine, test, fixture, or mdBook behavior change**). TOOLBOX-first probes showed `.1.3` is too broad for one signoff implementation slice: `set(name, "ok")` is already satisfied by `.1.4.1`/`.1.4.2` (`set` lowers/runs like `assign`); `push_value(items, "a")` worked while requested `push(items, "a")` still needed a child-call-preserving disambiguation; `set_key(name, "k", "v")` is currently a pure hash-valued expression, not a standalone mutation statement across variants; and operator forms (`name = v`, `items += v`, `name["k"] = v`) are raw/invalid Perl today while Rust has no assignment/plus-equals statement AST. Split `.1.3` into `.1.3.1` scalar function-form audit (DONE by `.1.4` evidence), `.1.3.2` array function spelling, `.1.3.3` hash mutation semantics, and `.1.3.4` operator syntax. Added KM card [[terse-mutation-surface-ground-truth]] and regenerated the map. `.1.3.2` is now done in the slice above.
- 2026-06-29: **SPEC-FORMAT-TERSE.1.4.2 — Rust lockstep parity for terse helper renames** (RUST ENGINE + 2 oracle fixtures + 3 integration locks; **no book change, Perl untouched**). Closed the `.1.4` helper-rename container on the Rust variant (ADR 0006). `Engine::call_helper()` now recognizes `set` through the `assign` arm and `cat` through the `concat` arm, and adds a dedicated unified `copy` arm that clones materialized arrays/hashes or resolves wrapped array/hash targets by kind. Added `resolve_hash_target` plus one-bare-variable `hash`/`h` target reads so `copy(h(m))` matches `hash_copy(h(m))`; deferred Channel 2 bare value-position reads remain out of scope. **Locked:** Perl-oracle fixtures `terse_1_4_2_set_cat_copy_array` and `terse_1_4_2_copy_hash_symbol_empty`; Rust integration tests for `set`+`cat`+`copy(array)`, hash target/hash value copy, and per-parse bare `set` target semantics. **Verification:** generator syntax OK; oracle regeneration OK; focused `terse_1_4_2` tests PASS; corpus oracle PASS over 11 fixtures; full Rust runtime suite PASS (116 unit + 36 integration + oracle harness); `cargo clippy` EXIT 0 with existing 13-warning baseline only; phase0 **975 green** (Perl untouched); `bash tools/run_ci_local.sh` EXIT 0. `.1.4.1` is now landed against the universal contract on both variants; **`.1.4` container done. Next: `SPEC-FORMAT-TERSE.1.3`** (mutation surface — scope/split before code).
- 2026-06-24: **SPEC-FORMAT-TERSE.1.4.1 — Perl reference: terse renames `set`/`cat`/`copy` lower byte-identically to `assign`/`concat`/`array_copy`+`hash_copy`** (ENGINE: 8 modules + BOOK: 3 pages + 4 phase0 locks). First `.1.4` child, in the user-directed PNT loop. **TOOLBOX-first** `call_spec_handler_subst` ground truth (dump-don't-guess; `perl -Iperl`→`perl/LinkedSpec.pm`) re-verified the gap, then recognized the aliases at **every** site each canonical name is recognized (the headline probe passing was a false "done" — composed positions like `set(x, cat(a,b))` / `assign(x, copy(a(y)))` still emitted raw un-lowered helpers until every recognizer learned the alias): (i) `cat`→`concat`+`set`→`assign` in `_normalize_method_name` (`ActionIR/MethodExpr.pm`); (ii) `set` raw-text statement recognition extended `\b(?:assign|set)\s*\(` at the `assign_value` contract (`Contracts.pm`), its IR-event scanner (`Scanner/PrimitivePipelineRules.pm` — so `set`==`assign` ASSIGN node), and the bare-arg auto-`my` collector (`RuleIR/EmitContext.pm` — bare `set` auto-exists, `.1.2.1` parity); (iii) a dedicated array-then-hash `copy` dispatch in `MethodLowering._lower_method_value_expr` + `copy` at `DeclareMethod` 136/163, the return-payload guard+rewriter lists (`MethodLowering` 1650/1658), `FlowExpr.pm:270` (assignment-source path), `BootstrapSpec/Core.pm` (`cat`), and the four `looks_like_{array,hash}_value_expr` recognizers (`MethodLowering`+`FlowExpr`) — `copy`'s kind resolved array-first so it stays first-class in numeric-reducer/`coalesce` type inference (`copy` is type-ambiguous, so it could NOT be added to a flat method-set — it had to RESOLVE kind, else `coalesce`'s array-vs-hash disambiguation breaks). **Proof:** `call_spec_handler_subst` byte-equal for 4 headline + 11 composed forms; `return_descriptor` `set`==`assign` ASSIGN node; a real terse spec (`set`+`cat`+`copy`) runs **byte-identical** to its canonical twin end-to-end (`["a!","b!","c!"]`, stable on re-run = per-invocation lexicals); generated source for **all 20 shipped specs byte-identical (0 diff)** (every alias add is guarded by the new spelling, which no shipped spec uses — so the broad `looks_like` edits carry zero corpus risk by construction). **+4 phase0 subtests / 31 assertions** (`spec_format_terse_1_4_1_*`) → **phase0 971→975 green**; `bash tools/run_ci_local.sh` **EXIT 0** ("Result: PASS", 975); ratio 1.0000; `perl -c` clean on all 8 modules; `mdbook build` EXIT 0; doctrine driver 2/2. **Book (3):** `appendix/helper-contract-catalog.md` (per-helper Terse-spelling lines + a "Terse Helper Renames" subsection), `dsl/value-container-flow-helper-reference.md`, `dsl/declaration-helper-reference.md` — renames canonical, old names deprecated (not-yet-retired). KM card [[terse-helper-rename-lowering-sites]] updated (landed; full site list; reverify proves parity). **Next: `SPEC-FORMAT-TERSE.1.4.2`** (Rust `Engine::call_helper()` lockstep parity — pipe `set`/`cat`, add a value-type-dispatching `copy` arm; oracle + integration locks mirroring `.1.2.2`).
- 2026-06-24: **SPEC-FORMAT-TERSE.1.4 — SPLIT into `.1.4.1` (Perl reference) + `.1.4.2` (Rust parity)** (DOCS/TREE/KM only; **no engine/book change**). PNT (user-directed loop, fresh session) picked `.1.4` (helper renames `assign`→`set`, `concat`→`cat`, `array_copy`/`hash_copy`→`copy`) and split it after a TOOLBOX-first `call_spec_handler_subst` ground-truth pass — too broad for one signoff slice. Ground truth (dump-don't-guess; `perl -Iperl`→`perl/LinkedSpec.pm`): the three terse spellings are all currently **UNRECOGNIZED** — `set(scalar(x),1)`→`set(scalar(x), 1)` (vs `assign`→`$x = 1`), `cat("a","b")`→`cat("a","b")` (vs `concat`→the concat do-block), `copy(a(items))`→`copy([items])` partial / `copy(h(m))`→`copy(h(m))` (vs `array_copy`→`[@items]` / `hash_copy`→`{%m}`). **Three implementation shapes:** `cat`→`concat` = pure rename via `_normalize_method_name` (`ActionIR/MethodExpr.pm:19-26`); `set`→`assign` = STATEMENT-level (`ActionIR/Contracts.pm:1749/1753` `\bassign\s*\(` + `DeclareMethod` + `MethodLowering._lower_assign_statement`) — NOT reached by normalization; `copy` = unified array-vs-hash dispatch in `MethodLowering._lower_method_value_expr` (array sym then hash sym). **Rust:** all four canonical helpers in one `Engine::call_helper()` match (`engine.rs`: `assign`@711, `array_copy`@735, `concat`@820, `hash_copy`@1833; pipe-arm aliases); `.1.4.2` pipes `set`/`cat` + adds a separate value-type-dispatching `"copy"` arm. Split Perl-first by variant (Perl reference + lockstep Rust parity separable, ADR 0006 — mirroring `.1.1`→`.1.1.1`/`.1.1.2` and `.1.2`→`.1.2.1`/`.1.2.2`): `.1.4.1` (Perl) + `.1.4.2` (Rust parity). Direction (ADR 0007): new terse names canonical, old names deprecated aliases that lower identically (retirement later); the 20 shipped specs (old names) must stay byte-identical. KM card [[terse-helper-rename-lowering-sites]] (map regenerated, 49 facts); `scripts/check_doctrines.sh` (MEMORY-ARCH + KNOWLEDGE-MAP) EXIT 0; no engine/book change (phase0 stays 971, N/A to a split slice; cargo 252). Frontier → `.1.4.1`. **Next:** implement `.1.4.1` (Perl reference — recognize `set`/`cat`/`copy`; signoff-critical codegen; all-20-specs byte-identical proof).
- 2026-06-24: **SPEC-FORMAT-TERSE.1.2.2 — Rust lockstep parity for arg-position bare working-variable auto-existence** (RUST ENGINE + 2 oracle fixtures + 4 integration locks; **no book change, Perl untouched**). The lockstep-parity follow-on to `.1.2.1` (ADR 0006), in the user-directed single-leaf PNT cadence. **REQUIRED a Rust engine change (unlike `.1.1.2`).** TOOLBOX-first throwaway Rust probe (bare-vs-wrapped, dump-don't-guess): the interpreter's HashMaps auto-vivify (the `.1.1.2` finding), but a **bare** arg-position target was not reaching the working var — `resolve_scalar_target`/`resolve_array_target` (`rust/linkedspec-runtime/src/engine.rs`) only un-wrapped `scalar(VAR)`/`array(VAR)` Calls; a bare `Expr::Variable` fell through to `val.to_str()` (→`""`). Probe BEFORE: bare scalar `[null]`, bare array `[[]]` vs wrapped `["ok"]`/`[["a","b"]]` (divergence from Perl). **Fix:** both resolvers now also accept a bare `Expr::Variable` target and return its name (mirroring Perl's `^(\w+)$` fallback); per-parse HashMap auto-vivifies (no declare, fresh ctx per execute ⇒ no leak). Scoped to Channel-1 positions via an `allow_bare` flag (true for push_value/push_nonempty; false for value-reads array_copy/hash_copy = Channel 2). Probe AFTER: bare == wrapped (`["ok"]`/`[["a","b"]]`). **Locked:** 2 oracle fixtures `autoexist_{scalar,array}_bare_arg` (regenerated; existing 7 byte-identical; `corpus_oracle` checks Rust == Perl reference) + 4 `terse_1_2_2_*` integration tests (value anchors, bare==wrapped==declare convergence, per-parse no-leak). **cargo 248→252 green**, 9/9 oracle PASS, clippy zero-new (engine.rs 11 baseline; flattened the `if allow_bare` nest to a tuple `if let`), `perl -c gen_oracle_corpus.pl` OK; **phase0 971 green** (Perl untouched), `bash tools/run_ci_local.sh` **EXIT 0**. KM card [[terse-bare-working-vars-engine-gaps]] updated (Rust parity + engine-change contrast with `.1.1.2`). **Channel 1 complete on BOTH variants; `.1.2.1` landed against the universal contract.** `.1.2` stays `active` (Channel 2 `.1.2.3`+ pending). **Next: `SPEC-FORMAT-TERSE.1.4`** (helper renames `assign`→`set`, `concat`→`cat`, `array_copy`/`hash_copy`→`copy`; old names aliased).
- 2026-06-24: **SPEC-FORMAT-TERSE.1.2.1 — Perl arg-position bare working-variable auto-existence (Channel 1)** (ENGINE + BOOK + 3 phase0 locks). First implementation child of the `.1.2` split, executed in the user-directed PNT loop (single-leaf PNT). Extended the `.1.1.1` collector `RuleIR::EmitContext::_collect_auto_working_var_decls` with a bare arg-position pass (shared `$record` dedup closure): alongside the WRAPPED typed-wrapper refs it now also collects a **bare** working var in a type-implying *first-arg* helper position with the **position-implied** sigil — `assign(NAME,…)`→`my $NAME` (scalar; the assign target always lowers scalar-first), `push_value`/`push_nonempty(NAME,…)`→`my @NAME` (array) — closing the leaky-package-global gap for bare arg-position forms. The `\s*,` after the bare name keeps a WRAPPED target on the `.1.1.1` wrapped path (no double-collection); both dedup to one `my`. **TOOLBOX-first** (`dump_parser_source`, `probe_terse_1_2_1.pl`, isolated bare forms): before, bare `assign(count,…)`/`push_value(items,…)` lowered to `$count`/`push @items` with NO `my` (leaky); after, each gets one preamble `my`; `assign(pair, set_key(hash(pair),…))` now declares both `my %pair` (wrapped) and `my $pair` (bare assign target). **Proof:** all-20-specs generated-source diff (mine vs git-stashed) = **0 diff** (corpus wraps every arg-position target — cleaner than `.1.1.1`'s 19/20). **+3 phase0 subtests / 17 assertions** (`spec_format_terse_1_2_1_*`: bare scalar+array+push_nonempty auto-exist with the `my` before `while(1)`; sigil-follows-lowering; only-the-target declared; deferred `.push` boundary; dedup vs wrapped/declare = single `my`; integrated per-invocation no-leak run-twice) → **phase0 968→971 green**; `bash tools/run_ci_local.sh` **EXIT 0** (971); ratio 1.0000; `mdbook build` EXIT 0. Book (3 pages) taught wrapper-optional-in-arg-position + corrected the outdated "argument position is a later step" note (variant-agnostic). **Scope (signoff):** Channel 1 = unambiguous first-arg value-helper positions only; child-append `push(Rule[,target])`/`.push(target)` target (rule-name first arg — ambiguous) + bare hash (value-position read) deferred to Channel 2. KM card [[terse-bare-working-vars-engine-gaps]] updated (Channel 1 closed). **Next: `SPEC-FORMAT-TERSE.1.2.2`** (Rust lockstep parity for `.1.2.1` — likely holds by architecture; assess + lock).
- 2026-06-24: **SPEC-FORMAT-TERSE.1.2 — SPLIT into `.1.2.1` (Perl, Channel 1) + `.1.2.2` (Rust parity)** (DOCS/TREE/KM only; **no engine/book change**). PNT (user-directed loop, fresh session) picked `.1.2` (remove container wrappers + type inference) and split it after a TOOLBOX-first `dump_parser_source` ground-truth pass — too broad for one signoff slice. Ground truth (dump-don't-guess): a **bare** (un-wrapped) working var has two inference channels — (1) **arg position** already lowers to the correctly-sigil'd variable (`assign(count,v)`→`$count=v`; `push_value(items,..)`→`push @items`) BUT gets **no auto-`my`** (the `.1.1.1` collector matches only WRAPPED forms) → leaky package global; (2) **value position** is NOT a variable read (`return(count)`→ bareword `return count ;`, not `$count`) + RHS-shape `[]`/`{}` inference. Split Perl-first by channel (Perl reference + lockstep Rust parity separable, ADR 0006 — mirroring `.1.1`→`.1.1.1`/`.1.1.2`): `.1.2.1` (Perl, arg-position bare working-var auto-existence — closes the leaky-global gap, extends the `.1.1.1` collector) + `.1.2.2` (Rust parity). Channel 2 (`.1.2.3`+, value-position reads + RHS-shape) added once `.1.2.1` lands + `.1.5` literal syntax designed (not pre-published — no vague placeholders). Wrappers stay accepted aliases (gradual, ADR 0007); shipped corpus uses them pervasively (declare 87 / assign 103 / scalar 133 / array 134 / hash 36) → must stay byte-identical. KM card [[terse-bare-working-vars-engine-gaps]] (map regenerated); memory-arch + doctrine + KM gates EXIT 0; `perl -c` clean on the landing modules; phase0 stays 968 (untouched, N/A to a docs slice). Frontier → `.1.2.1` (signoff-critical Perl codegen — a fresh session is reasonable). **Next:** implement `.1.2.1`.
- 2026-06-24: **SPEC-FORMAT-TERSE.1.1.2 — Rust lockstep parity for auto-existing working variables** (ORACLE + INTEGRATION locks; **NO engine change**). The lockstep-parity follow-on to `.1.1.1` (ADR `0006`), executed in the user-directed PNT loop on a fresh session. **Assessed blocked-vs-doable = DOABLE, no engine change** (TOOLBOX-first: throwaway Rust + `perl -Iperl` `LinkedSpec::Get` probes on the same minimal grammars; read `rust/linkedspec-runtime/src/{runtime,engine}.rs`, dump-don't-guess): the Rust variant is an **interpreter** (no codegen/`eval`), so working variables live in per-parse `RuntimeContext` HashMaps (`scalars`/`arrays`/`hashes`) that **auto-vivify** on write (`set_scalar`=`insert`, `push_value`=`entry().or_default().push`) and read as `Undef`/empty when absent, and `Engine::execute` builds a **fresh `RuntimeContext` per call** — so working variables **already auto-exist** with no `declare(...)` and a value never leaks across parses (the Rust analogue of Perl's per-invocation `my`). The Perl `.1.1.1` change was a codegen fix for a non-strict leaky-package-global hazard the Rust interpreter does not have, so parity holds **by architecture**; the leaf lands as lockstep regression tests + docs (not an engine change — adding a dead "collector" to mirror a non-existent hazard would be ceremony, not parity). **Cross-variant proof** (divergence-free edge-action form = the `.7.1` oracle proof class; recursive/REP forms are blocked by the separate `RUST-PARITY` recursive-grammar/REP-lifecycle gap, verified `[null]`/`[[]]`): scalar no-declare Perl `"ok"`/Rust `["ok"]`; array no-declare Perl `["a","b"]`/Rust `[["a","b"]]`; declare twins identical; `array(undef)` Perl `[null]`/Rust `[[null]]` — Rust == Perl reference wrapped one level. **Locked:** 5 oracle corpus fixtures `autoexist_{scalar,array}_{no_declare,declare}` + `autoexist_undef_literal` (`tools/gen_oracle_corpus.pl`, regenerated — existing 2 byte-identical; `corpus_oracle.rs` checks each vs the Perl reference) + 4 `terse_1_1_2_*` integration tests (value anchors, declare/no-declare convergence, per-parse no-leak via same-engine re-run). **cargo test 244→248 green**; all **7 oracle fixtures PASS**; `cargo clippy` zero-new source/test warnings; `perl -c tools/gen_oracle_corpus.pl` OK; **phase0 968 green** (Perl untouched), `bash tools/run_ci_local.sh` **EXIT 0**; `mdbook build` EXIT 0 (no book change — variant-agnostic; `.1.1.1` already taught the contract, Rust now conforms). KM card [[rust-working-vars-auto-vivify]] (map regenerated, 47 facts). **`.1.1` container done; `.1.1.1` is now landed against the universal contract. Next: `SPEC-FORMAT-TERSE.1.2`** (remove `scalar()/array()/hash()` wrappers + type inference).
- 2026-06-24: **SPEC-FORMAT-TERSE.1.1.1 — Perl auto-existing working variables** (ENGINE + BOOK + 3 phase0 locks). First terse-format (ADR `0007`) *implementation* leaf, executed in the user-directed PNT loop. The engine now auto-supplies one preamble `my $NAME`/`@NAME`/`%NAME` for any working variable referenced through a typed wrapper (`scalar(NAME)`/`array(NAME)`/`hash(NAME)` + `s/a/h`) so `declare(...)` is optional — making the variable a per-invocation lexical instead of a leaky package global (non-strict handlers; KM [[working-vars-no-strict-need-my-lexical]]). **TOOLBOX-first** (`dump_parser_source` ground truth). New rule-level collector `RuleIR::EmitContext::_collect_auto_working_var_decls` (+ literal-masker `_mask_action_code_literals`): scans RAW pre-lowering blocks (NOT regex slots) for single-bare-identifier wrapper refs, sigil-from-wrapper, dedup vs `@<label>` accumulator + same-sigil `my` already in the lowered code (declare/raw-my), excludes DSL literals (`undef`/`true`/`false`) + engine handler locals; injected into the preamble by `SpecEntry::compile_spec_entry` (empty ⇒ byte-identical). **Proof:** generated source for all 20 shipped specs (mine vs git-stashed) = **19/20 byte-identical** — only `tkgui` differs (+1 legit `my $subgui_name;` for its genuinely undeclared working scalar; parse output identical before/after incl. a 2nd same-process parse = no leak); a Lispish `a(undef)`→`my @undef` false positive was caught by the diff + fixed (reserved-literal exclusion). **+3 phase0 locks** (no-declare scalar+array work + no cross-parse leak; declare-path single-`my`; reserved-literal excluded) → **phase0 965→968 green**; `bash tools/run_ci_local.sh` **EXIT 0** (968); ratio 1.0000; `mdbook build` EXIT 0. Book taught auto-existence (declare optional) in `dsl/declaration-helper-reference.md`, `appendix/helper-contract-catalog.md` §1 (+ corrected `assign` contract), `dsl/value-container-flow-helper-reference.md`; examples not re-authored. **Next: `SPEC-FORMAT-TERSE.1.1.2`** (Rust lockstep parity — now PNT-eligible to assess).
- 2026-06-23: **ROADMAP-DRIFT-RECONCILE.0 — own the deferred ROADMAP.md / ARCHITECTURE_STATE.md drift** (TRACKING-ONLY; no code/book/roadmap-content/KM change). Fresh-session bootstrap (full README→MEMORY_ARCHITECTURE→SESSION_BOOTSTRAP→MEMORY→COMMIT→TASK_TREE→ROADMAP_V2 read + delegated `LinkedSpec.pm`-import-tree, mdBook, and full-`ROADMAP.md` analyses) confirmed readiness and surfaced a drift finding: long-form `ROADMAP.md` has diverged from `ROADMAP_V2.md` + the tree ledger (no `SPEC-FORMAT-TERSE`/terse mention; `declare(...)` shown as permanently required; still lists `RTLUtils`+36-`.plg` as live — misses `LEGACY-VHDL-RETIRE` deletion + `NONCORE-QUARANTINE` → `noncore/` + `perl/` core-only + the phase0 count; Rust-only multi-backend framing). `ARCHITECTURE_STATE.md` mildly stale (dated 2026-06-14; model still broadly accurate). Per the user's **PNT-loop start + "Defer — track as a new leaf"** decisions (AskUserQuestion 2026-06-23), created the `ROADMAP-DRIFT-RECONCILE` tree (`active`; leaves `.1` ROADMAP.md / `.2` ARCHITECTURE_STATE.md, `pending`-deferred behind the active terse track) + indexed it, so the drift is owned without interrupting the signoff-critical `.1.1.1` engine change. **Verification:** tracking-only — self-check + doctrine driver + KM gate green via the pre-commit hook; phase0 965 unaffected. **Next: implement `SPEC-FORMAT-TERSE.1.1.1`** (Perl auto-existing variables) per the recorded design.
- 2026-06-23: **SPEC-FORMAT-TERSE.1.1 — split into `.1.1.1` (Perl) + `.1.1.2` (Rust parity); record the auto-existing-variable design + KM card** (DOCS/TREE/KM only; no engine/book change). Bootstrap-then-PNT on a fresh session (full README→MEMORY_ARCHITECTURE→MEMORY→SESSION_BOOTSTRAP→COMMIT→TASK_TREE→ROADMAP_V2 read + ARCHITECTURE_STATE/TOOLBOX + delegated `LinkedSpec.pm`-import-tree & mdBook surveys) landed on the next action: PNT into the terse-format track (`SPEC-FORMAT-TERSE`, ADR `0007`), first leaf `.1.1` (auto-existing variables). **TOOLBOX-first ground truth** (`dump_parser_source` probes, scratchpad `probe_autovar*.pl`, dump-don't-transcribe) established: a rule's `I`+edges+`LX` = ONE lexical scope (`declare` emits its `my` ONCE in the preamble before the `while(1)` loop); generated handlers run with **NO `use strict`** (`SpecEntry.pm` has neither), so a working var without `declare` silently becomes a **leaky package global** (state-leaks across invocations/recursion), not a loud error — which is exactly what auto-existence fixes (make first-used working vars per-invocation `my` lexicals). That makes `.1.1` too broad for one signoff slice (multi-module Perl engine change + lockstep Rust parity, ADR `0006`), so per the PNT splitting rule **split `.1.1`** → `.1.1.1` (Perl reference: rule-level wrapper-reference collection → preamble `my`-injection, sigil from wrapper, dedup vs `@<label>`+explicit-declares, ratio 1.0000) + `.1.1.2` (Rust lockstep parity, follow-on); `.1.1` is now a container; frontier → `.1.1.1`. Recorded the verified design in the tree Decisions + KM card [[working-vars-no-strict-need-my-lexical]] (map regenerated); synced `docs/TASK_TREE.md` (SPEC-FORMAT-TERSE is now the current focus; TOP-RULE-AS-NORMAL acceptance MET). **Verification:** `scripts/check_memory_architecture.sh` + `scripts/check_doctrines.sh` (2/2) + KM gate all green; phase0 baseline 965 unchanged (no engine/test/book touched). **Next: implement `SPEC-FORMAT-TERSE.1.1.1`** (Perl auto-existing variables) per the recorded design, then `.1.1.2` (Rust parity).
- 2026-06-23: **TOP-RULE-AS-NORMAL.4 — book reconciliation to the top-rule-as-ordinary model; closes the tree's last executable leaf** (BOOK+TEST+DOC; no engine/spec change). Bootstrap-then-PNT on a fresh session (README→MEMORY_ARCHITECTURE→MEMORY→SESSION_BOOTSTRAP→COMMIT→TASK_TREE + the `TOP-RULE-AS-NORMAL` tree + ADR `0010` + the KM cards) landed on the next action `.4`. Per ADR `0010`, reconciled the mdBook to "the top (`::`) rule is an ordinary rule entered first": demoted the law claims ("Body rule only", "regex never on the `::` entry rule", "needs at least two rules", "normal shape of every `.spec`") to **recommended idiom** across **6 book files** (`spec-files-and-rule-paragraphs.md`, `formal-grammar.md`, `rule-modes-and-parse-modes.md`, `worked-spec-walkthrough.md`, `what-is-linkedspec.md`, `helper-contract-catalog.md` — the last found by a whole-book grep sweep, not the `.4` named list). Added the canonical model section + the `entry_*` (entering match) vs `match_*` (own match, post-match edge) rule + the consume-before-recurse termination rule (`formal-grammar.md` **§5.4**, phrased as a backend MUST — cross-variant-confirmed by `.3.1`) + the recursive-top-rule-needs-`LX` model. **De-footgunned** the `Pair::AND` regex-on-top example: it read `entry_text()` (→`{name:null,value:null}` — a top rule has no entering match) → fixed to a post-match edge + `match_group(0)`, folding the bare `\s*=\s*` separator into the name slot (→`{name:"name",value:"value"}`). **Fixed a correctness bug**: the worked-walkthrough's `'a = 1, b = 2'`→two-pair output was a `seek` result shown in the `consume` context (under `consume` only the first pair matches) — reframed as the consume-vs-seek distinction. **Every example verified via `LinkedSpec::Get`** (dump-don't-transcribe, `verify4*.pl`); `mdbook build` EXIT 0 (cross-ref anchor verified from generated HTML); book variant-agnostic. **+1 phase0 lock** `top_rule_as_normal_regex_on_top_reads_own_match_with_match_family` (3 assertions): **phase0 964→965 green**; KM card [[top-rule-reads-own-match-with-match-family]] (map regenerated). Discovered (tracked, out of scope): a bare edge-less `AND` middle slot is a positional anchor that is not separately consumed (illustrative sketches only). `bash tools/run_ci_local.sh` EXIT 0; doctrine driver 2/2 PASS. **Marked `.4` `done`; `TOP-RULE-AS-NORMAL` acceptance MET — tree stays `active` only because `.3.2` (value parity) is `blocked` on `RUST-PARITY`; frontier EMPTY. Next PNT: the next active tree (`SPEC-FORMAT-TERSE.1.x`).**
- 2026-06-23: **TOP-RULE-AS-NORMAL.3.1 — Rust forward-progress / consume-before-recurse termination guard (mirror of `.2.1`); split `.3`** (RUST variant only; no Perl/spec change). Bootstrap-then-PNT on a fresh session (README→MEMORY_ARCHITECTURE→MEMORY→SESSION_BOOTSTRAP→COMMIT→TASK_TREE + the `TOP-RULE-AS-NORMAL` tree + ADR 0010 + the KM card) landed on the next action `.3`. **Reproduce-first (TOOLBOX, dump-don't-transcribe):** drove the four Perl phase0 top-rule grammars through the Rust pipeline (`parse_spec`→`validate`→`compile`→`Engine::execute`; baseline `cargo build` clean, 242 tests green). The cross-variant gap is **two independent layers**: **(a) termination** — `top:: /a/ I{return(call(top))}` on `aaa` made Rust recurse natively through `Engine::execute_rule` (the `call(rule)` helper, NO guard) → **stack overflow → SIGABRT**, vs Perl's clean `undef`; **(b) value** — Rust returns nulls for ALL recursive S-expression cases, *including the standard body idiom* (`top:: -> sexpr` wrapper → `[[null],[null]]`), so (b) is the **general recursive-grammar parse gap** owned by `RUST-PARITY` (Lispish already deferred per `tests/corpus_oracle.rs`), NOT a top-rule-as-ordinary issue. **Split `.3` → `.3.1`** (termination, this slice) **+ `.3.2`** (value, `blocked` on `RUST-PARITY`). **Fix (`.3.1`):** the Rust mirror of the `.2.1` `(rule,pos)` cutoff — `recursion_active: HashSet<(String,usize)>` on `RuntimeContext` (`enter_recursion`/`exit_recursion`) + a thin `Engine::execute_rule` guard wrapper around the renamed `execute_rule_inner` (re-entry at an active `(label,pos)` ⇒ return `undef`; removed on both Ok+Err exit paths). A no-consume cycle now terminates cleanly and returns `[null]` = Perl's `undef` wrapped one level by the documented Perl↔Rust accumulator output-shape rule; legitimate consume-before-recurse recursion (advances `ctx.pos` first) untouched. **Verification:** 2 new self-protecting integration locks (`top_rule_as_normal_3_1_no_consume_recursion_terminates` ⇒ `[null]`; `..._consume_before_recurse_is_not_cut` ⇒ array); **full Rust suite 242→244 green** (core/unit/corpus unchanged); changed-lib clippy clean (pre-existing `clippy --tests` debt untouched); **phase0 964/964** + `bash tools/run_ci_local.sh` **EXIT 0** (Perl untouched). KM card [[top-rule-recursion-forward-progress-guard]] updated with the Rust parity. **Next: `.4`** (book reconciliation — termination guarantee + recursive-top-rule-needs-`LX`); `.3.2` re-enters the frontier when `RUST-PARITY` lands recursive-grammar parse parity.
- 2026-06-23: **TOP-RULE-AS-NORMAL.2.2 — confirmed top re-entry recursion already works with the `LX` accumulator idiom (NO engine defect; engine frozen) + 1 phase0 lock; closed `.2`** (TEST+DOC only). Resumed `.2.2` after a transient sandbox-classifier outage cleared. **TOOLBOX `probe9.pl` (dump-don't-transcribe)** confirmed the `.2.1`-discovered "gap" is NOT an engine defect: a recursive rule used directly AS the top rule parses with an `LX` accumulator-return — `(a)`→`[["a"]]`, `(a(b)c)`→`[["a",["b"],"c"]]`, `(a) (b)`→`[["a"],["b"]]`. **Root cause of the earlier `null`:** the default-handler `while(1)`'s no-match branch uses the default `lxcode = return undef`, so a bare accumulating top rule's outermost frame discards its accumulator at EOF — the **missing-`LX` authoring case** (the documented `top:: -> x .push` + `LX{...}` idiom applies to recursive top rules too). The decisive `(a) (b)` case shows TOP and BODY are **different grammars (different arity)**: TOP accumulates the SEQUENCE of top-level forms, BODY (`top:: -> sexpr {return(call(sexpr))}`) returns ONE form (`["a"]`). So ADR `0010`'s authorized engine change was **NOT needed** for the value (only `.2.1`'s termination guard was) — the engine already treats the top rule as ordinary. **Added phase0 lock** `top_rule_as_normal_recursion_with_lx_parses_sequence`; **phase0 963→964 green**; `bash tools/run_ci_local.sh` **EXIT 0** ("Result: PASS", 964); zero regression; engine untouched. Marked `.2`+`.2.2` `done`; updated KM card [[top-rule-recursion-forward-progress-guard]] with the resolution. The recursive-top-rule-needs-`LX` book doc is deferred to `.4`. **Next (user's call): `TOP-RULE-AS-NORMAL.3`** (Rust cross-variant parity for the `.2.1` termination guard + top-recursion-with-`LX`) or `.4` (book).
- 2026-06-23: **TOP-RULE-AS-NORMAL.2.1 — forward-progress / consume-before-recurse termination guard (ENGINE: `perl/LinkedSpec/SpecEntry.pm`) + 3 phase0 locks; split `.2`; discovered the `.2.2` top-recursion value gap**. Bootstrap-then-implement on a fresh session (the user chose "implement the engine slice now, then stop for review before `.3`/`.4`"). **TOOLBOX ground-truth first** (scratchpad probes 1–7): `call_spec_handler_subst` pinned the REAL recursion seam — `call(rule)`/`-> rule` lower to `&{$$descr{spec}{$rule}{handler}}(...)` (`Contracts.pm:134`/`MethodLowering.pm:332`), and `{handler}` is the `SpecEntry::_build_runtime_handler` closure (`SpecEntry.pm:438`), so **every cross-rule call + recursion** flows through ONE real-Perl closure (the `dump_parser_source` `&{…{$rule}}` form is a simplified artifact, NOT the runtime). A fork+SIGKILL battery showed the per-handler `while(1)` + `LinkedRE::or` `/gc` matching is **already** forward-progress-safe (no zero-width grammar hangs); the ONE reproduced engine hang was an unconditional no-consume self-tail-call (`top:: /a/ I{return(call(top))}` → OOM). **Fix:** a precise **(rule, pos) active-stack non-progress cutoff** in that closure (file-lexical `%__ls_recursion_active`) — re-entry at a position already active for the rule ⇒ `return undef`; legitimate consume-before-recurse recursion advances `pos()` first so it never fires. **Verification:** `perl -c` clean; E4 hang→`null`; consume-recursion unchanged; **phase0 960→963** (3 new locks: no-consume terminates+undef, body S-expr parses `(a(b)c)`→`["a",["b"],"c"]`, top-recursion terminates); `bash tools/run_ci_local.sh` **EXIT 0** ("Result: PASS"); zero regression. KM card [[top-rule-recursion-forward-progress-guard]]. **Discovered + split `.2`→`.2.1` (done) + `.2.2` (pending):** a recursive rule AS the top rule returns `null` while the identical body rule parses — an entry-alignment divergence; the `.2.1` top lock pins TERMINATION only. **Next (PAUSED for user review): `TOP-RULE-AS-NORMAL.2.2`** (top re-entry VALUE correctness — trace the runtime `{handler}` to root-cause the leading-token off-by-one, then a minimal regression-locked engine change), then `.3` (Rust parity), `.4` (book).
- 2026-06-23: **TOP-RULE-AS-NORMAL.1 — own the lane + read-only investigation; ADR 0010 authorizes touching the Perl engine to treat the top rule as an ordinary rule entered first; PHASE0-BACKHALF-TRIAGE.6 superseded + that tree CLOSED (DOC-ONLY)**. A design discussion off the `PHASE0-BACKHALF-TRIAGE.6` book `:AND` reconciliation escalated: the user reframed the top rule as an ordinary rule merely entered first (`::` = entry marker; no-regex dispatch loop = idiom not law; recursion allowed w/ consume-before-recurse termination) and **authorized touching the Perl variant** — captured in **ADR 0010** (scoped engine-frozen exception, cross-variant parity required). **Read-only investigation** (TOOLBOX: `LinkedSpec::Get`, `generate_only`+`dump_parser_source`, codegen grep) corrected the model: the top rule is just `&{$descr->{spec}{$top_rule}}(...)` (`Compiler.pm:1006`); `while(1)` is mode-driven; `Pair::AND`+regex already compiles as a normal AND handler (the `.3` fix) — so the OPEN gap is **top re-entry recursion + termination** (naive top-recursion hangs; Lispish body-recursion is green). **No engine/spec/test/book code touched.** Created the active `TOP-RULE-AS-NORMAL` tree (`.1` done; `.2` Perl impl, `.3` parity, `.4` book), wrote + indexed ADR 0010, wrote a new KM card [[top-rule-is-ordinary-rule-entered-first]] + corrected the stale `[]` claim in [[spec-top-rule-no-regex-two-rule-minimum]], superseded `PHASE0-BACKHALF-TRIAGE.6` and flipped that tree to `done` (moved to Completed). **Verification:** `scripts/check_memory_architecture.sh` + `scripts/check_doctrines.sh` green; KM map regenerates clean; phase0 unaffected (960/960). **Next: `TOP-RULE-AS-NORMAL.2`** (Perl engine — confirm matrix + enable top re-entry recursion + forward-progress guard + phase0 locks; **recommended for a fresh session** — signoff-critical codegen), then `.3` (cross-variant parity), `.4` (book).
- 2026-06-22: **PHASE0-BACKHALF-TRIAGE.5.3.2.2 — narrative-doc + book drift sync (DOC-ONLY): the product/architecture surfaces now reflect the deleted (RTLUtils/FSMGen/VHDL::ConstantEval) vs relocated-to-`noncore/` module reality; `LEGACY-VHDL-RETIRE` + `NONCORE-QUARANTINE` both CLOSED**. Bootstrap-then-PNT on a fresh session (README→MEMORY_ARCHITECTURE→MEMORY→SESSION_BOOTSTRAP→COMMIT→TASK_TREE + the downstream trees + a delegated `LinkedSpec.pm`-import-tree analysis) landed on the active frontier leaf `.5.3.2.2`, the deferred `LEGACY-VHDL-RETIRE.5` body. **No engine/spec/test/book-behavior change** — only `ROADMAP_V2.md`, `ARCHITECTURE_STATE.md`, the two named mdBook files, the 3 downstream task trees, the index, and the live docs. Ground-truth from `git`/filesystem (+ Explore agent): 3 modules + 6 `.plg` deleted (`06496b4`), 12 owners + 13 `.plg` relocated to `noncore/` (`336bded`/`2baddbd`), `generic_fake_memory_module.plg`/`wrapgen.plg` deleted earlier (`cffac62`). Guarded content-anchored transforms replaced: the ARCHITECTURE_STATE owner-tree block + owner-migration bullets + legacy-plugin-branch prose; the 16 stale ROADMAP_V2 "Plugin modernization note" bullets (+ a dated Update on the historical tracker cell); the book's `## plugin/`→`## noncore/plugin/` section + corpus/CI-input mentions; the book owner-tree migration narrative. **Verification:** `mdbook build docs/linkedspec-book` EXIT 0; `git grep` confirms no deleted/relocated module presented as a live `perl/` owner; book variant-agnostic; phase0 960/960 unaffected; `scripts/check_memory_architecture.sh` + `scripts/check_doctrines.sh` green. **Flipped `LEGACY-VHDL-RETIRE.5` + `NONCORE-QUARANTINE.V` → `done` — both trees CLOSED** (`NONCORE-QUARANTINE.N` deferred as an explicit Non-Goal); moved both to the Completed index; containers `.5.3.2`/`.5.3`/`.5` → `done`. **Next: `.6`** (book `:AND` reconciliation — the now-fixed `::AND`+regex+return form vs the book's "Body rule only"/"no regex on top" idiom; **likely needs a short user policy check**), or PNT into `SPEC-FORMAT-TERSE.1.x`.
- 2026-06-22: **PHASE0-BACKHALF-TRIAGE.5.3.2.1 — status & continuity reconciliation: flip the downstream gates now both phase0 (960/960) and the full local gate (`tools/run_ci_local.sh` EXIT 0) are green (DOC-ONLY)**. Bootstrap-then-PNT on a fresh session (README→MEMORY_ARCHITECTURE→MEMORY→SESSION_BOOTSTRAP→COMMIT→TASK_TREE + the 5 downstream trees + delegated `LinkedSpec.pm`-import-tree & mdBook analysis) landed on the active frontier leaf `.5.3.2`. **No engine/spec/test/book code touched** — only task-tree ledgers, `docs/TASK_TREE.md`, one KM card, and the live continuity docs. **Split** `.5.3.2` (too broad — 3 trees + index + KM + ~4 narrative/product docs incl. 2 mdBook files + live docs; the book/architecture drift is a distinct pre-existing concern = deferred `LEGACY-VHDL-RETIRE.5` body) → `.5.3.2.1` (this, status & continuity) + `.5.3.2.2` (narrative-doc + book drift, next). **Flips:** `NONCORE-QUARANTINE.V` blocker (the ~173) CLEARED → `pending`; `LEGACY-VHDL-RETIRE.4` `blocked`→`done` (RTLUtils hang cleared + full gate green; the subtest-131 `HTML::PathLinks` hang moot — its smoke was excised by `NONCORE-QUARANTINE.3`) + `.5` cleared→`pending`; `SPEC-FORMAT-TERSE` implementation-gate CLEARED (`.1.x`+ now PNT-eligible, NOT started — migration policy already gradual-alias, ADR `0007`); synced the `docs/TASK_TREE.md` index (4 trees) + gave the `rtlutils-regex-hang` KM card a "Resolution" section + refreshed evidence/reverify. **Verification:** doc-only — `scripts/check_memory_architecture.sh` + the doctrine driver `scripts/check_doctrines.sh` (2/2) green; KM map regenerated/staged by the pre-commit hook; `grep` confirms no residual "blocked by phase0 / by the 173 / not green" in the ledgers. Book unaffected. **Next: `.5.3.2.2`** (narrative-doc + book drift sync: `ROADMAP_V2`/`ARCHITECTURE_STATE` owner-tree + 2 mdBook files + the `generic_fake_memory_module.plg`/`wrapgen.plg`/`ceil_log2` drift; then flip `LEGACY-VHDL-RETIRE.5` + `NONCORE-QUARANTINE.V` → `done`), then `.6` (book `:AND`).
- 2026-06-22: **PHASE0-BACKHALF-TRIAGE.5.3.1 — drop the stale `plugin/` reference in `tools/run_ci_local.sh`; the full local gate now passes green end-to-end**. CI tooling only — **no engine/spec/production code touched** (only `tools/run_ci_local.sh` + task-tree/live docs). Scoping `.5.3` (flip the downstream gates) surfaced that the "full local gate green" acceptance was itself RED: `tools/run_ci_local.sh` (the E4 source-of-truth gate since hosted CI is disabled, ADR `0004`) died at `require_tracked_tree plugin` → "required directory missing: plugin", EXIT 1, *before phase0 ran* — `NONCORE-QUARANTINE.3` rmdir'd `plugin/` (the 13 `.plg` moved to `noncore/plugin/`) but left `plugin` in two of the gate's pathspec lists (the **same leftover class as `.5.1`/`.5.4`**). Split `.5.3` → `.5.3.1` (this, full-gate-green) + `.5.3.2` (status/doc/KM reconciliation, pending) since the remaining gate-flips span 3 trees + a doc/book/KM sync. **Fix:** removed `plugin` from both pathspec lists (rationale comment); core gate stays core-only — dropped, NOT retargeted to `noncore/`, per the `.5.1` precedent. **Verification:** `bash -n` OK; **`bash tools/run_ci_local.sh` → EXIT 0 end-to-end** (doctrine 2/2 PASS, tracked-input + machine-path audits pass, `perl -c` clean, RAM guard ok, `prove -v -Iperl t/phase0_regression.t` = `1..960` / `All tests successful` / `Result: PASS` ~198s, "[ci] local CI gate passed"). Book unaffected. Advances `NONCORE-QUARANTINE.V`'s "full local gate green". **phase0 + the full local gate are now green together for the first time. Next: `.5.3.2`** (flip the downstream blocked statuses + doc/KM sync across `NONCORE-QUARANTINE.V`, `LEGACY-VHDL-RETIRE.4/.5`, `SPEC-FORMAT-TERSE` impl-gate), then `.6` (book `:AND`).
- 2026-06-22: **PHASE0-BACKHALF-TRIAGE.5.4 — re-bless the 3 dark-tail failures (TEST-ONLY); `t/phase0_regression.t` is now fully GREEN end-to-end (960/960) for the first time**. Bootstrap-then-PNT: a thorough fresh-session resume (README→MEMORY_ARCHITECTURE→MEMORY→SESSION_BOOTSTRAP→COMMIT→TASK_TREE + delegated codebase/mdBook analysis) landed on the active frontier leaf and executed it. **No engine/spec/production code touched** — only `t/phase0_regression.t` (3 re-blesses) + task-tree/live docs. Ground-truth-first per `TOOLBOX.md` Protocol A — dumped every got-value via `LinkedSpec::Get`, not transcribed. **952/953** (`parse_mode_default_and_explicit_seek_preserve_progressive_matching` @43355 / `parse_mode_consume_requires_contiguous_match` @43383): both use `Top:: /a/ -> Top { return(1) }`; dumps → `CODE\n$VAR1 = 1;\n` (seek/consume accept) and `__AST_UNDEF__` (consume reject, unchanged). `return(1)` now resolves to scalar `1` (cluster-A/G class), so the retired tagged `?Top:` shape is gone — re-blessed `like(…, qr/\?Top:/)` → `qr/\$VAR1 = 1;/` (952's message clarified: the seek-forward proof is now the defined matched value vs consume's `__AST_UNDEF__`). **960** (`plugin_bridge_dispatch_calls_mechanically_gated_in_plg_corpus`): another stale `opendir '../plugin'` die (the 13 `.plg` moved to `noncore/plugin/`; **same class as `.5.1`**) — per the `.5.1` core-only precedent, dropped the 4 `noncore/`-dependent `.plg`-corpus asserts (the `opendir` census + the `get_plugin`/`run_plugin`/`dispatch_plugin_autoload_name` source scans), kept the core `PluginBridge.pm` `qr/Compatibility bridge/i` check (plan 5→1, rationale comment). **Verification:** `perl -c` OK; before-run 957 ok / 3 not-ok (failing = exactly {952,953,960}, reach `not ok 960` exit-255) → after-run **960 ok / 0 not-ok, EXIT 0, reach `ok 960`, `1..960` reached**; `comm` set-diff = **exactly the 3 cleared, new-failure set empty**. self-check + KM gate pass. **Book unaffected** (parse_mode behavior unchanged — only the non-idiomatic regression-test's expected AST shape; 960 is internal test infra). **Closes the green-phase0 goal of `.5`; unblocks the `SPEC-FORMAT-TERSE` / `LEGACY-VHDL-RETIRE.4-.5` / `NONCORE-QUARANTINE.V` chain. Next: `.5.3` (flip the downstream gates, now PNT-eligible — may hand off to `NONCORE-QUARANTINE.V`), then `.6` (book `:AND`).**
- 2026-06-22: **PHASE0-BACKHALF-TRIAGE.5.2 — fix the Lispish corpus_regression hang (root cause CORRECTED: not a regex — the parser never returns undef + the multi-parse loop lacked a progress guard); TEST-ONLY; corpus_regression GREEN, suite reaches subtest 960**. User chose "investigate + fix". **No engine/spec/production code touched** — only `t/phase0_regression.t` (one guard line) + the corrected KM card. **Root cause (measured, dogfooding TOOLBOX.md):** a single parse of the full 392B conf file = 0.03s (no backtracking); loop instrumentation showed the **Lispish parser never returns `undef`** — on a no-progress/EOF call it re-returns the prior form's AST with `pos()` unchanged (iter1 0→350 def, iter2.. 350→350 +0 def; general on single-form-EOF + `(R rise)\n\n`). `parse_with_lispish_multi`'s `while(1){…last unless defined}` therefore spun to its 100000 cap (~3 min/file × 76 files). **Fix:** a forward-progress guard (`last if pos_after<=pos_before`) — the missing streaming-loop invariant. **Measured: 76/76 conf+tablescript files ok, 0 hang; `ok 941 - corpus_regression`; full foreground run reaches subtest 960** (vs old death at 941). Corrected the KM card (was "catastrophic regex"). Deeper parser-contract (never-undef) + grammar gap (no top-level whitespace skip) = engine/spec follow-ons (cross-variant). **Running past corpus revealed 3 TEST-ONLY dark-tail failures → `.5.4`:** 960 (stale plugin-dir `opendir`, same as `.5.1`) + 952/953 (`parse_mode` assert `?Top:`; `return(1)`→scalar `1`, cluster-A/G class). NOTE: run phase0 FOREGROUND with `timeout:600000` (`run_in_background` is killed at ~120s). **Next: `.5.4` re-bless the 3 → green phase0, then `.5.3` gate flips.**
- 2026-06-22: **DOCTRINE-ENFORCEMENT-ADOPT.1+.2 — adopt the portable Doctrine-Enforcement architecture (driver+registry+gates) + a LinkedSpec TOOLBOX.md of its own debug tools**. User directive; landed `.1`+`.2` atomically (mutually referential). No engine/spec/production code touched — tooling + docs only. **`TOOLBOX.md`** catalogs LinkedSpec's **own** debug tools (per the user's "should contain LinkedSpec own debug tools"): facade probes (`Get`/`return_descriptor`/`call_spec_handler_subst`/`dump_parser_source`/`parse_only`/`generate_only`/`return_state`/`runtime_ctx_ref`), the `LINKEDSPEC_TRACE_LEVEL` trace framework, the `tools/*` scripts, the gates; generic techniques demoted to §6; every name verified against `perl/`. **`scripts/check_doctrines.sh`** = the registry driver (runs every `check_*.sh`, meta-checks each exists; registry = `MEMORY-ARCH` + `KNOWLEDGE-MAP`, **2/2 PASS**). **`.githooks/pre-commit`** + **`tools/run_ci_local.sh`** now call the driver (E3/E4). **`DOCTRINE_ENFORCEMENT.md`** (standard; §10 = LinkedSpec instance; honest hosted-CI-disabled note per ADR 0004). Discovery: README/AGENTS/CLAUDE point at both. **ADR `0009`** + INDEX. **Verification:** driver exit 0 (2/2); `bash -n` clean on hook + CI; KM in sync; the commit exercised the rewired hook green. `.3` (evidence/task-acceptance hard-gate) **deferred** (project-specific signature design). **Next: the directive is done (except deferred `.3`); the remaining open item is the user's `PHASE0-BACKHALF-TRIAGE.5.2` direction decision (quarantine vs fix vs guard the Lispish corpus hang).**
- 2026-06-22: **PHASE0-BACKHALF-TRIAGE.5.1 — remove stale corpus_regression plugin dataset (TEST-ONLY); determined subtest-941 = real stale ref (not a natural stop); EXPOSED .5.2 (Lispish corpus catastrophic backtracking)**. **No engine/spec/production code touched** — only `t/phase0_regression.t` (one dataset removed) + docs/KM. `.5` split → `.5.1` (done) + `.5.2` (blocked) + `.5.3` (blocked). **Determination:** subtest-941 `corpus_regression` "No tests run"/exit-255 is a **real stale reference, NOT a natural stop** — `NONCORE-QUARANTINE.3` rmdir'd `plugin/` but left the `plugin_plg_via_pplugin_spec` dataset, whose `opendir ../plugin or die` aborts the run at 941 (so 942-959 never ran). Removed that non-core `.plg` dataset (core gate stays core-only; `plan` 8→6, rationale comment). Baseline confirmed subtests **1-940 GREEN**. **Exposed `.5.2` (green-phase0 blocker):** re-running advanced into `corpus_regression` and **hung** — a full run = **374 CPU-min** on one 392-byte conf file; fork+SIGKILL census killed **~21/22 conf files (≈100%)**; the **Lispish** parse of conf/tablescript **catastrophically backtracks** (`alarm()` can't interrupt it); the ebnf dataset is healthy (7/7). ReDoS-style regex in the Lispish spec. KM card `lispish-corpus-catastrophic-backtracking.md`. Also found a stale `PERL5LIB=…/pgen/fx/perl` (bare `use LinkedSpec` loads the wrong checkout; use `-Iperl`). **Verification:** `perl -c -Iperl t/phase0_regression.t` OK; phase0 **NOT green** (blocked by `.5.2`); self-check + KM gate pass; book unaffected. **`.5.2` blocked on a user direction decision** (quarantine the Lispish corpus datasets vs fix the regex vs hard-timeout guard). **Next: surface the `.5.2` decision; new directive pending (adopt `pgen/DOCTRINE_ENFORCEMENT.md` + maintain `TOOLBOX.md`).**
- 2026-06-22: **PHASE0-BACKHALF-TRIAGE.2.4 — re-bless cluster F+G ×5 (TEST-ONLY); 5 phase0 failures cleared, zero regressions (cluster .2 complete; front 940 subtests green)**. **No engine/spec/production code touched** — only `t/phase0_regression.t`. Ground-truth-first probe of all 5 before editing. **G ×2:** `return(1)`→plain resolved `return 1`, so a single-top-rule parser returns scalar `1` — re-blessed `ok(ref($ast) eq 'ARRAY')` → `is($ast, 1, …)`. **F ×3** (migration-summary corpus aggregates): two used `return(1)` to stand in for unresolved-helper-blocked rules (now resolved/ready, cascading counts/ratios/lists/breakdown) → **restored** the corpus to genuinely-unresolved forms (`return(Leaf, $x)`; mixed = `return(Leaf, $x); my $tmp = 2`) so the original category coverage + assertions hold (2 spec + 1 payload edit total, 0 other assertion changes); the third (`compatibility_surface_metadata_includes_legacy_helper_wrappers`) had an **obsolete premise** (retired `return_m`/`return_a` are now RAW_PERL, not ready compat) → **adapted** to live compat helpers (`Top` → `return(a("?Top:"))` keeping `assign_call_my`+`capture_if`; `Leaf` → bare `return 1` = `return_bare`), re-blessing the contract-id lists/statement-count/descriptions. **Verification:** `perl -c` OK; load-independent focused Test::More harness 5/5; full `perl -Iperl t/phase0_regression.t` + `comm` set-diff = **exactly the 5 F/G cleared (phase0 6→1)**, new-failure set empty — only the `corpus_regression` natural-stop tail remains (owned by `.5`). self-check + KM gate pass. Book unaffected. **Next: `.5` (green-phase0 verification incl. the corpus tail + flip the downstream gates: SPEC-FORMAT-TERSE, LEGACY-VHDL-RETIRE.4/.5, NONCORE-QUARANTINE.V).**
- 2026-06-22: **PHASE0-BACKHALF-TRIAGE.2.3 — re-bless/rewrite cluster C `emit_context` ×20 (TEST-ONLY); 20 phase0 failures cleared, zero regressions**. **No engine/spec/production code touched** — only `t/phase0_regression.t`. All 20 traced to the retired `return_a`/`return_imatch`/`return_array` helpers + `return(1)` now lowering to a plain resolved `return 1` (node `RETURN`, contract `return_general`, language-agnostic-ready). Driven ground-truth-first: one comprehensive probe dumped every changed assertion's current value before editing. Changes: deps-builder `return ['?Top:', \@Top]`/`RETURN_A` → `return 1`/`RETURN`; facade `return_imatch`/`return_array` → passthrough; `a(IMATCH)` → `[IMATCH]`; two stale plan off-by-ones (89→88, 80→79); dropped the genuinely-removed `_lower_return_array_statement` probe (plan 8→6); `_find_unresolved_action_helpers` inputs `return(1)`→`return_a(1)` (counter still finds 2); `_parse_method_function_expr('return(1)')` args `'Top'`→`'1'`; descriptor-meta `RETURN_A`→`RETURN` + `return_a` contract → `return_general`/`return`, with **three subtests' spec return forms RESTORED** (`return(Top, $x + 1)`, `return(do { my $x = 1; $x })`, `return(Leaf, $x)`) so each keeps its original label/expression/nested-semicolon coverage rather than degrading it. Decision: kept the harmless dead `LinkedSpec::Deps::*` traps (Deps-unloaded covered by `emit_context_require_avoids_linkedspec_deps_load`); deferred a consistent dead-trap sweep of all 13 deps-builder siblings as optional hygiene. **Verification:** `perl -c` OK; after-run cleared the 11 cluster-C subtests ≤803 (0 regressions in 1–803) + a load-independent focused Test::More harness ran the 9 late meta/nested subtests (804–857) = 9/9 pass; authoritative low-load full `comm` set-diff = **exactly the 20 cleared (phase0 26→6)**, new-failure set empty. Two earlier full runs were SIGALRM-killed at the corpus tail by a transient external `rustc`/`nexsim_core` build (load ~29 → the documented truncated-TAP false-cleared hazard); a clean low-load re-run gave the diff. self-check + KM gate pass. Book unaffected. **Next: `.2.4` (cluster F ×3 + G STALE ×2: `return(1)` migration-summary + AST-shape re-bless).**
- 2026-06-21: **PHASE0-BACKHALF-TRIAGE.2.2.2.2 — re-bless cluster B1-accumulator (4 `return_a`/`return_m`, TEST-ONLY); 4 phase0 failures cleared, zero regressions (closes cluster B1)**. The recon's highest-risk leaf, driven ground-truth-first. **No engine/spec/production code touched** — only `t/phase0_regression.t`. A pre-flight probe replicated **every assertion of all 4 subtests** via `LinkedSpec::Get` → all PASS before any edit. Rewrote `.return_a().return_m()` → `.return(1).return(array("?Top:", entry_groups()))` (×3, replace_all — exactly 3, all targets); block `return_m(Top)` → `return(array("?Top:", entry_groups()))` (×2, **line-scoped** — @39745 is a passing non-target, excluded); blind-call `.return_a()` → `.return(1)` (@6342); subtest-1's two retired `RETURN_A`/`RETURN_M` node greps re-blessed to `grep RETURN` + `is(hits{RETURN}, 2)` (distinct-variant feature retired into a single `RETURN`). `perl -c` OK; full phase0 **30 → 26 failing** (complete TAP to corpus tail); `comm` name set-diff = **exactly the 4 cleared, new-failure set empty**. The gate was briefly blocked by **external** CPU contention (an unrelated `cargo`/`rustc` build at system-load 32 → SIGALRM-kill, which also produced a misleading truncated-TAP false set-diff); a fresh low-load run gave the clean diff. self-check + KM gate pass. Book unaffected. **Next: `.2.3` (cluster C `emit_context` ×20 — white-box, delete/rewrite removed-`Deps::*` monkeypatch seams).**
- 2026-06-21: **PHASE0-BACKHALF-TRIAGE.2.2.2.1 — re-bless cluster B1-array (33 `return_array`→`return(array("semantic_annotation",…))`, TEST-ONLY); 17 phase0 failures cleared, zero regressions**. Executed the recorded plan. **No engine/spec/production code touched** — only `t/phase0_regression.t`. A guarded **matching-paren-aware, line-scoped** transform rewrote 33 in-range `return_array(<Top,> semantic_annotation, X)` → `return(array("semantic_annotation", X))` (drops the `Top` label only on the L16601 subst-arg, quotes the bareword, +1 close paren), applied identically to fluent+block across 4 forms; it asserts `rewrites == in-range count` (**33**, not the recon's "34") + file-wide `return_array(` delta, dies-before-write on drift — **necessary because `return_array` is 74× file-wide and byte-identical across the 17 failing + ~20 passing switch-case subtests** (global replace would corrupt the passing ones); the full dry-run diff was inspected before apply. **Recon correction:** the 2 BOTH subtests (@17289, @20105) do **not** "pin no literal output" — each pins a literal `canonical_action_ir_hits` with stale `RETURN_A => 1`; re-blessed `RETURN 2→3` + dropped `RETURN_A`, **empirically dumped** (`{…RETURN=>3…}`, fallback=0, ready=1, I==LX) before writing. `perl -c` OK; full phase0 **47 → 30 failing**; `comm` name set-diff = **exactly the 17 cleared (incl. both BOTH), new-failure set empty**. self-check + KM gate pass. Book unaffected. **Next: `.2.2.2.2` (4 `return_a`/`return_m` accumulator, re-dump + re-bless, highest risk).**
- 2026-06-21: **PHASE0-BACKHALF-TRIAGE.2.2.2.1 (recon) — scope + verified rewrite rule for the B1-array leaf; read-only, no test change**. Pre-implementation recon recorded so the implementation runs mechanically. **Critical scope hazard:** `return_array` = 74× in the file (**34 in failing / 40 in PASSING** subtests, byte-identical spec-body strings) → the rewrite **must be line-scoped to the 17 B1-array subtests, never a global replace**; one "failing" site is a cluster-C `emit_context` (`.2.3`), excluded. Classified the 33 spec-body occurrences into 4 forms + 1 subst-arg. **Empirically verified** `return_array(semantic_annotation, X)` → `return(array("semantic_annotation", X))` → `fallback=0`/`ready`, fluent==block; the failing subtests pin no literal output, so the rewrite is shape-agnostic. Full plan in the `.2.2.2.1` node. `perl -c` OK; phase0 unchanged at 47; self-check + KM gate pass. **Recommending a fresh session for the multi-form paren-level surgery. Next: `.2.2.2.1` (execute the recorded plan).**
- 2026-06-21: **PHASE0-BACKHALF-TRIAGE.2.2.2 — split cluster B1 (21 subtests) into `.2.2.2.1` (return_array) + `.2.2.2.2` (return_a/return_m); decomposition slice, no test change**. Read-only recon mapped the 21 failing B1 subtests by retired helper (**17 `return_array`** incl. 2 BOTH @17289/@20105; **4 `return_a`/`return_m`** incl. the 3rd BOTH + `blind_call_fluent…`). An **archaeology** pass recovered all six retired helpers' original lowering from the COMPAT-ALIAS-RETIREMENT-V2.2 diff (`4e92503`) and **empirically verified** each canonical rewrite via `call_spec_handler_subst` probes — correcting the agent's simplified mapping (`return_array(L,e1,e2)` actually **drops the label `L`** and auto-quotes barewords → `return(array(e1,e2))`, a pure alias). The two families differ in blast radius: `return_array` = input-rewrite (expected usually already canonical); `return_a`/`return_m` add `"?L:"` + `array_copy`/`entry_groups` (re-dump + re-bless). New KM card `retired-return-helpers-canonical-rewrite.md`. No code change → phase0 stays 47; `perl -c` OK; self-check + KM gate pass. **Next: `.2.2.2.1` (17 `return_array` rewrites, mechanical-ish).**
- 2026-06-21: **PHASE0-BACKHALF-TRIAGE.2.2.1 — re-bless cluster B2 (55 `method_like` `RETURN_A`→`RETURN`, TEST-ONLY); 55 phase0 failures cleared, zero regressions**. Second `.2.2.x` re-bless leaf. **No engine/spec/production code touched** — only `t/phase0_regression.t`. The B2 subtests hard-coded the *retired* canonical action-IR node `RETURN_A`, which the engine renamed to `RETURN` (COMPAT-ALIAS-RETIREMENT-V2; KM `actionir-return-node-retired-to-return`). A **guarded one-pass transform** applied **52 Form-A membership-grep flips** (`grep {$_ eq 'RETURN_A'} …canonical_action_ir_nodes` → `'RETURN'`) + **19 Form-B hit-hash merges** (`RETURN += 1`, adjacent `RETURN_A => 1` deleted — the retired node renames *into* `RETURN`, so the two counts collapse into one key, never colliding) + **2 stale description fixes**; the script asserts each target's exact shape (Form-A count == 52; each Form-B `RETURN_A` adjacent to a `RETURN => N`) and aborts before writing on any drift. **Excluded (17 `RETURN_A` remain):** 14 cluster-C `emit_context` sites incl. the **passing** `helper_action_ir_events {kind}`/`helper_action_ir_nodes` sites (`.2.3`) + the 3 BOTH subtests (`.2.2.2`). **`perl -c` OK; full phase0 102 → 47 failing across two runs; `comm` set-diff = exactly the 55 cleared, new-failure set empty.** One after-only name on the first run (`parser_invalid_input_fails_at_runtime_parser_boundary`, a `Lispish` `open3` subprocess test at line 4163 — before every edit, engine byte-identical) was a CPU-contention flake, disproven by the clean re-run (`ok 137`). Remaining 47 = 20 `method_like` (B1+BOTH → `.2.2.2`) + 20 `emit_context` (`.2.3`) + 7 other (`.2.4`/`.5`). self-check + KM gate pass. **Book unaffected** (internal IR-node name, not a user surface). **Next: `.2.2.2` (B1 retired-helper spec rewrites, judgment-heavy).**
- 2026-06-21: **PHASE0-BACKHALF-TRIAGE.2.2 — split cluster B (76 subtests) into `.2.2.1` (B2 token re-bless) + `.2.2.2` (B1 helper rewrites); decomposition slice, no test change**. Cluster B was too broad + partly judgment-heavy for one signoff slice. **Read-only recon** classified all 76 (B1=18 retired-helper-in-body / B2=55 retired-`RETURN_A`-token / BOTH=3) with a per-subtest line map. **Empirical probe** pinned the engine facts: canonical return node is now `RETURN` (not `RETURN_A`/`RETURN_M`); retired `return_a/return_m/return_ma/return_imatch/return_im/return_array` → `RAW_PERL` passthrough. **Scope hazard:** `RETURN_A` appears 90× across cluster B + cluster C (`emit_context`) + apparently-passing helper-event tests → NOT a global replace; each edit scoped to a failing cluster-B subtest. `.2.2.1` = re-bless `RETURN_A`→`RETURN` in 55 pure-B2 subtests (scoped; merge RETURN+RETURN_A hit hashes); `.2.2.2` = rewrite 18+3 retired-helper spec bodies to canonical helpers + re-bless dependent assertions (judgment-heavy). New KM card `actionir-return-node-retired-to-return.md`; task tree carries the full work-list. No code change → phase0 stays 102; `perl -c` OK; self-check + KM gate pass. **Next: `.2.2.1` (B2 token re-bless).**
- 2026-06-21: **PHASE0-BACKHALF-TRIAGE.2.1 — re-bless cluster A (7 parser-collection-shape subtests, TEST-ONLY); 7 phase0 failures cleared, zero regressions**. First `.2.x` re-bless leaf. **No engine/spec/production code touched** — only 13 stale `is_deeply` expecteds in `t/phase0_regression.t`. These subtests asserted the *retired* auto-tag accumulator shape `['?Rule:',[]]` for blind-call `:AND`/`:OR`/`:+`/`AND+`/`AND{N,M}` rules whose children carry `… { return(1) }`; the current engine correctly surfaces each child's own `return(1)`, so a collection is `[1,1]`, a single dispatch is scalar `1`, a repeated AND group is `[[1,1],…]`. Re-blessed against **empirically-dumped** engine output (not the triage prose). Subtests 144/149/152/153/156/163/166. **Triage correction:** cluster A = 7, not the triaged 8 — the 8th (`blind_call_fluent_post_call_chain_matches_block_form`, 206) is a retired-`return_a` failure → re-bucketed to cluster B (`.2.2`); STALE total unchanged (108). **`perl -c` OK; full phase0 109 → 102 failing; `comm` full set-diff = exactly the 7 cleared, new-failure set empty.** Remaining 102 = 101 STALE (`.2.2`–`.2.4`) + 1 `corpus_regression` tail (`.5`). (Gate SIGALRM-killed at the corpus tail under external `bin/fsmgen` CPU contention — same stop point as the baseline; not a regression.) self-check + KM gate pass. **Next: `.2.2` re-bless cluster B `method_like` ×76 (retired `return_*`/`RETURN_A`).**
- 2026-06-21: **PHASE0-BACKHALF-TRIAGE.4 — engine fix: input-boundary-validation regression (#2); 2 phase0 failures cleared, zero regressions**. Authorized by ADR `0008`. **Fix (one file, `perl/LinkedSpec/Runtime.pm`):** the `MEDIUM-IMPACT.3.2` comment-skip wrapper ran `pos($$input_ref)=0` (unguarded deref) before the documented input-boundary guard (`Compiler.pm validate_input_ref`, `ref ne 'SCALAR'`), so non-SCALAR-ref input died with a raw `Not a SCALAR reference at … Runtime.pm line 126` and empty `last_error`. Now gates the `pos()`+comment/blank-skip block behind `if (ref($input_ref) eq 'SCALAR')` (mirrors the inner guard exactly) and always delegates to `$original_parser`, so invalid input yields the friendly `Top-level parser expects a SCALAR reference input; got ARRAY` + populated `last_error` (`type=runtime_parser`); valid scalar-ref input keeps the comment-skip path. **`perl -c` clean; full phase0 111→109 failing — set-diff vs post-`.3` = exactly the 2 Defect #2 subtests cleared, zero other changes.** Both reference-engine defects (#1, #2) now fixed. Remaining 109 = 108 STALE (`.2.x`) + 1 `corpus_regression` tail (`.5`). KM card `runtime-input-boundary-validation-regression.md` → `resolved`. self-check + KM gate pass. **Next: `.2.x` re-bless the 108 STALE (TEST-ONLY), then `.5` green-phase0 (+ corpus tail), then `.6` book `:AND` reconciliation.**
- 2026-06-21: **PHASE0-BACKHALF-TRIAGE.3 — engine fix: AND-rule action-codegen defect (#1); 62 phase0 failures cleared, zero regressions**. User **authorized both engine fixes** (sanctioned scoped exception to the engine-frozen doctrine — ADR `0008`); a fresh session first re-verified BOTH defects objectively read-only (incl. the book's OWN `Pair::AND` example breaking). **Fix (one file, `perl/LinkedSpec/HandlerVariantEmitter.pm`):** both AND-acode emitters (`_emit_and_acode_seq_handler` multi-regex + `_emit_and_single_acode_handler` single-regex) rewrote an edge `return(...)` via `s/\breturn\s*/\$" . $label . " = "/eg` — the bare `\$"` is a *reference to* the list-separator `$"` (stringifies `SCALAR(0x…)`) where the correct literal `"\$"` is used at lines 524/594/928, so the emitter produced invalid `SCALAR(0x…)<label> = …` (top→compile-fail→`undef`; child→dropped→`[]`); the single-acode handler also never `push`ed its transformed acode. **Now emits edge acodes verbatim** (already lowered to `return [...]`), so an AND edge `return(X)` surfaces the raw author payload directly (correct in both direct-AND and the `sub{}`-wrapped REP-AND iteration). Verified against all 21 cataloged AND-rule tests (`call(Child)` always wrapped as `return(call(Child))`). **`perl -c` clean; full phase0 173→111 failing (62 cleared — all 60 cluster-D capture/mark/cursor/entry/whole-input/current-match + named-G AND + `push_nonempty` C-t13 now pass).** Remaining 111 = 108 known-STALE (`.2.x`) + 2 Defect #2 (`.4`) + 1 newly-reached `corpus_regression` tail (`.5`). Only `:AND` emitters touched. KM card `and-return-edge-codegen-defect.md` → `resolved`. self-check + KM gate pass. **Next: `.4` (Runtime.pm input-boundary guard, Defect #2).**
- 2026-06-19: **PHASE0-BACKHALF-TRIAGE.1 — read-only triage COMPLETE: 173 failing phase0 subtests → 108 STALE (re-bless) / 65 REAL (engine-fix), 2 distinct engine defects**. No engine/spec/test code changed (triage report + `.2`–`.5` decomposition + 2 KM cards). Authoritative run = 173 fail/707 pass (reached 880/959 before the bg run was terminated, exit 144 mid-881). **STALE (108):** A parser-collection-shape (8, retired auto-tag `[1,1]` vs `['?Rule:',[]]`), B `method_like` (75, retired `return_*` helpers/`RETURN_A` nodes — branch-block lowering itself works/is documented), C `emit_context` (20, removed `Deps::*` seams + stale plan + retired-helper passthrough), F migration-summary (3, `return(1)` resolved not blocked), G singles (2, `return(1)` AST = scalar `1`). **REAL (65):** Defect #1 **AND-rule action-codegen** (63 — multi-edge AND + `return` edge emits `SCALAR(0x…)Rule` ⇒ compile-fail `near ")Top"` top / dropped `[]` child; bisected; likely `HandlerVariantEmitter`/`SpecEntry`); Defect #2 **input-boundary regression** (2 — `Runtime.pm:~126` wrapper derefs before the SCALAR-ref guard, commit `d7294d0`). KM cards `and-return-edge-codegen-defect.md` + `runtime-input-boundary-validation-regression.md`. self-check + KM gate pass; `perl -c` OK. **`.3`/`.4` engine fixes BLOCKED on user OK to touch the reference engine; `.2.x` re-bless is independent. Read-only triage vindicated — re-blessing cluster D would have masked a real codegen bug. Next: surface the engine-touch decision + fix order to the user.**
- 2026-06-19: **Triage WIP + trace directive owned (PHASE0-BACKHALF-TRIAGE.1 in progress; TRACE-OBSERVABILITY created)**. Ownership/read-only checkpoint (no engine/spec/test code changed). **Trace driver established:** `LINKEDSPEC_TRACE_LEVEL=debug perl -Iperl <driver>` (existing env control; ~22k lines ENTER/DECISION/dump to stdout). **Root-caused Cluster A (parser collection-shape, ~10+) = STALE tests** (engine returns `[1,1]` per child `return(1)`; tests expect retired `['?Rule:',[]]` tagged shape → re-bless). Clusters B–E (`method_like`×75, `emit_context`×21, capture/mark/entry) pending root-cause. **TRACE-OBSERVABILITY** owns the user's trace directives (discoverable CLI control + comprehensive "see everything" trace): framework already EXISTS in `Trace.pm` (enter/exit/decision/levels/sinks; env `LINKEDSPEC_TRACE_LEVEL` works) — gaps are discoverability (no `--trace`/bin/docs) + coverage (esp. generated runtime parser). self-check + KM gate pass. **Session very long → fresh session advisable; repo handoff-ready (relocation at `2baddbd`). Next: continue Cluster B–E root-cause with trace; and TRACE-OBSERVABILITY `.2` (CLI+docs, quick win).**
- 2026-06-19: **NONCORE-QUARANTINE.3+.4 — relocate ALL remaining non-core `.pm`/`.plg` to `noncore/` + excise their phase0 subtests; DISCOVERED ~173 pre-existing back-half core failures**. `git mv` the 23 remaining domain `.pm` + 13 `.plg` → `noncore/` (layout preserved); `perl/` is now **core-only** (LinkedSpec.pm + LinkedSpec/** + LinkedRE/PathSearch/PPlugin); emptied `perl/` subdirs + `plugin/` rmdir'd. Excised the 37-subtest legacy-migration block from `t/phase0_regression.t` (source lines 3312–5378, guarded anchor-splice; 996→959 subtests); `perl -c` core+test OK; `git grep`=0 island refs. **DISCOVERY (not from this work):** phase0 now runs the long-dark back half (subtests 111+) and reveals **~173 real, deterministic core-engine test failures** — structural/shape mismatches (0 timeouts, 0 missing-module), clustered `method_like`×75/`named_mark`×25/`emit_context`×21/capture-mark families. Engine bytes unchanged by this work → PRE-EXISTING, masked by the original hang (subtest 110). Likely **stale tests** (evolved ActionIR/HandlerIR behavior, never re-run) vs real regressions. **Green phase0 + `SPEC-FORMAT-TERSE` + `LEGACY-VHDL-RETIRE.4/.5` + `NONCORE-QUARANTINE.V` now blocked on triaging the 173 (separate tree).** Also: external `bin/fsmgen` 100%-CPU contention (another session, not killed) slows runs, not the cause. self-check + KM gate pass; phase0 NOT green (pre-existing failures). **Next: surface the 173 to the user; decide stale-vs-real + own a triage tree.**
- 2026-06-19: **NONCORE-QUARANTINE.1+.2 — dependency-tree inventory + relocate 12 zero-ref modules to `noncore/`** (new tree; repurposed from `DEADCODE-PRUNE` per the user's "move, don't delete" direction). Extracted `LinkedSpec.pm`'s full dependency tree (static + dynamic `get_parser`/`get_plugin`/AUTOLOAD/`.plg`→`.pm` edges) from roots = `LinkedSpec.pm` ∪ shipped specs ∪ conf/ebnf/tablescript. **41 KEEP / 36 non-core `.pm`; all 13 `.plg` non-core** (shipped specs reference 0 plugins/cross-specs → the legacy domain island is unreachable; zero core→domain edges; tools/bin clean). **Relocate (`git mv`) to `noncore/`, NOT delete** — preserve refactor/port/publish/delete options; `noncore/README.md` = parked fate ledger (hints: revive-candidate Lispish/LispML/LibReader; replaceable HUtils/Table*/HTML/HTTP/Text/Global; likely-rm vendor-timing/Timing/QC/Tk/MSOffice + 13 `.plg`). `.2`: created `noncore/` + ledger + `git mv` the 12 zero-ref modules (AmbiTiming/EasyTk/EncounTiming/HDisplay/LibReader/MagmaTiming/PTiming/Reportiming/rvp/TkGui/XLSreader/PluginUtils) — 100% safe (0 refs anywhere; no code/spec/test touched). perl/ top-level `.pm` 28→16; `perl -c perl/LinkedSpec.pm` OK. The phase0 back-half hangs live in the non-core island → removing its subtests (later batches) greens phase0. Plugin machinery stays in core for now (POSTPONE `.N`). self-check + KM gate pass. **Next: `.3` relocate the 24 domain `.pm` per cluster + remove their phase0 subtests → `.4` 13 `.plg` → `.V` verify green phase0.**
- 2026-06-18: **LEGACY-VHDL-RETIRE.2+.3 — retire the Perl-only legacy VHDL/RTL/FSM subsystem (RTLUtils hang cleared; a SECOND pre-existing back-half hang discovered)**. User confirmed "Full subsystem closure". `git rm` 3 modules (`RTLUtils.pm`/`FSMGen.pm`/`VHDL/ConstantEval.pm`) + 6 dependent `.plg` (≈6,495 lines); surgically cleaned `t/phase0_regression.t` (8 module-smoke subtests deleted + 7 mixed subtests cleaned, plan counts adjusted, ≈206 lines) + the two stale comments. `git grep`=0 refs; `perl -c` core+phase0 OK; edited subtests PASS live. **RTLUtils hang CLEARED — proven** via a pristine-HEAD worktree (original hangs at subtest 110 `add_header_n_context_clause`/`RTLUtils.pm:104`; post-retirement runs past to 130+; **corrects `.1`'s wrong line-746 claim**). **DISCOVERY:** removing it unmasked a SECOND pre-existing, unrelated hang — `HTML::PathLinks::link_path_tokens` (subtest 131) — + back-half failures (everything after subtest 110 had been dark). So **phase0 is still not green and the `SPEC-FORMAT-TERSE` gate stays blocked — now by the back-half, not RTLUtils.** Not caused by the retirement (proven). self-check + KM gate pass; full phase0 NOT green (not run to completion). **Next: surface the back-half fix-track decision to the user (new tree? scope?); `.4`/`.5` reblocked on it.**
- 2026-06-18: **LEGACY-VHDL-RETIRE.1 — own retirement tree + read-only inventory of the Perl-only legacy VHDL/RTL/FSM subsystem**. New tree `LEGACY-VHDL-RETIRE` (created this commit, ownership-first); completed its read-only feasibility/inventory leaf `.1` (the recorded `MEMORY.md` next action). Verified (`git grep` sweep + `wc -l`, no deletion): **zero functional dependency** on the subsystem from the active `.spec` core (only a comment at `perl/LinkedSpec.pm:246`); subsystem = `RTLUtils.pm`(877)+`FSMGen.pm`(3,549)+`VHDL/ConstantEval.pm`(90)=**4,516** lines; **6 dependent `.plg`** (fsmgen/lte_digital_rf/mbist/msword/regtest/rtl)=**1,979** lines; ≈**206** lines of phase0 migration-smoke; footprint ≈**6,701** lines. Catastrophic regex confirmed at **`RTLUtils.pm:746`** (corrected from the prior `add_header_n_context_clause` attribution). Caught stale doc drift: `generic_fake_memory_module.plg`/`wrapgen.plg` no longer exist yet `ROADMAP_V2:157`/`ARCHITECTURE_STATE:588` still cite them. KM card `rtlutils-regex-hang.md` written; `SPEC-FORMAT-TERSE` blocker updated to point at this tree. **Removal leaves `.2`–`.5` BLOCKED pending user removal-scope confirmation** (deletions). self-check + KM gate pass; no engine/spec/test code changed (phase0 still hangs until `.2`–`.4`). **Next: surface the removal-scope decision to the user; on confirmation, execute `.2`→`.5` to clear `RTLUTILS-REGEX-HANG` and unblock `SPEC-FORMAT-TERSE.1.1`.**
- 2026-06-18: **SPEC-FORMAT-TERSE.0 — activate + ratify the terse `.spec` format direction (ADR 0007)**. User activated the previously-`proposed` terse-format tree and reinforced the semantics (`assign`→`=`/`set`; no-sigil typed bare identifiers; type inference at init / by arg position; `copy()` unifies array+hash; arrays/hashes/numbers/strings have methods; everything-is-an-expression). Wrote ADR `0007` ratifying Rounds 1–3 + **gradual-alias migration** (canonical-new + deprecated-old-alias, then explicit retirement) + lockstep-all-variants (ADR 0006) + a user-sanctioned reference-touching exception + the regression-gate requirement; indexed it. `SPEC-FORMAT-TERSE` `proposed`→`active` (current focus); `SPEC-LANG-REFERENCE` scorch paused. **Two execution decisions surfaced to the user** (migration-policy confirmation; `RTLUTILS-REGEX-HANG`-first sequencing) before any implementation leaf. self-check + KM gate pass. No engine/book change.
- 2026-06-18: **SPEC-LANG-REFERENCE.10.5.4 — book: fix `worked-spec-walkthrough.md` → verified 2-rule idiom; re-derive whole-chapter outputs; drop declare/assign**. Rewrote the book's central walkthrough from the broken single-rule `Pair::AND /…/ -> Pair[0]` (returns `[]`, claimed a single hash) to a `Top::` entry rule (no regex; `-> Pair .push` + `LX{return(array_copy(a(Top)))}`) + a `Pair:` matcher (`I{return(hash("kind","pair","name",entry_group(0),"value",trim(entry_group(1))))}`). **Re-derived every claimed I/O** via a mode-aware `LinkedSpec::Get` driver: `answer = 42` (default/consume)→`[{"kind":"pair","name":"answer","value":"42"}]`; `junk answer = 42` consume→`[]`, seek→the pair; `a = 1, b = 2`→2-element list. Output reframed single-hash→one-element **list**; `match_group`→`entry_group` (+trap); `ctx{top_rule}` Pair→Top. **`declare()`/`assign()` removed** from the advanced sketch per the user's terse-format pivot (verified still live in the engine; removal owned by `SPEC-FORMAT-TERSE`). `mdbook build` exit 0; self-check exit 0. No Perl change. **Whole-book scorch PAUSED — user activated `SPEC-FORMAT-TERSE`; next: `SPEC-FORMAT-TERSE.0` (ratify + ADR).**
- 2026-06-17: **SPEC-LANG-REFERENCE.10.5.3 — book: fix `get-and-get-parser.md` minimal `Get` example → verified 2-rule idiom**. Replaced the inline `Get(...)` heredoc spec `Top::AND /foo/ -> Top[0] {…match_text()…}` (regex-on-top + `::AND -> Top[0]` → `[]`) with `top:: -> word .push` / `LX{return(array_copy(a(top)))}` + `word: /foo/ I{return(hash("kind","top","text",entry_text()))}` + an output comment + a structure-teaching sentence. **Verified by extracting the heredoc from the book file** + `LinkedSpec::Get`: `foo` → `[{"kind":"top","text":"foo"}]`. Caught `match_text()`→`null` vs `entry_text()`→`"foo"`. `mdbook build` exit 0; self-check exit 0. **Frontier → `SPEC-LANG-REFERENCE.10.5.4`** (`worked-spec-walkthrough.md`). PNT loop continues.
- 2026-06-17: **SPEC-LANG-REFERENCE.10.5.2 — book: fix `what-is-linkedspec.md` minimal kv example → verified 2-rule idiom**. First fix slice of the whole-book scorch. Replaced the overview chapter's single-rule `Top::AND+ /(\w+)=(\w+)/ -> Top[0] {…}` example (regex on top rule + `::AND -> Top[0]` self-edge → handler compile-fail → `null`, while prose claimed "returns a hash per match") with the verified 2-rule idiom (`top:: -> pair .push` / `LX{return(array_copy(a(top)))}` + `pair: /(\w+)=(\w+)/ I{return(hash("key",entry_group(0),"val",entry_group(1)))}`) + accurate structure-teaching prose + cross-links. **Verified by extracting the exact block from the book file** and running `LinkedSpec::Get`: `foo=bar baz=qux` → `[{"key":"foo","val":"bar"},{"key":"baz","val":"qux"}]`. Idiom note: bare `{return}` without `I` → `[0,0]`. `mdbook build` exit 0; self-check exit 0. **Frontier → `SPEC-LANG-REFERENCE.10.5.3`** (`public-api/get-and-get-parser.md`). PNT loop continues.
- 2026-06-17: **SPEC-LANG-REFERENCE.10.5.1 — whole-book `.spec`-snippet scorch AUDIT (findings + decomposition)**. Ran the fresh exhaustive hunt: **8 read-only `Explore` agents** over chapter groups, then **personally ground-truthed every load-bearing finding** through a private `LinkedSpec::Get` driver (an audit agent clobbered the shared scratch driver mid-run → all agent ACTUAL_OUTPUT treated as hypotheses, per the `.10.6` lesson). **Engine facts (probed):** `::`≡`:` on a non-first rule (`child::AND /re/` ≡ `child:AND /re/` = `[0]`); only the first rule is the entry; `Top:: /foo/ -> Top` → `null` — so `::`-no-regex is a STYLE doctrine, not an engine error. **Headline:** the `Rule::AND /regex/ -> Rule[N] {return}` idiom is **pervasive (~105 `::`-mode headers / ~20 files)** and is doctrine-divergent (regex on `::`) **and** the `[]`-shaped form. **User decision (AskUserQuestion): FULL BOOK-WIDE SCORCH** — rewrite every worked example (incl. isolated DSL fragments) to the 2-rule idiom + correct all outputs. Verified drifts: `tablegrep` `sens` = `=` not `=~`; `portmap` outputs nested (`["?bare:",["clk"]]`) not flat. **2 preliminary hypotheses overturned:** ebnf "richer example" compiles+parses (CLEAN); §5.5 forms run+return. Findings table + engine facts + scope Decision recorded in the tree; decomposed into per-file fix leaves `.10.5.2`–`.10.5.19` (`.10.4` superseded by `.10.5.16`). self-check exit 0. No book/Perl change (audit only). **Frontier → `SPEC-LANG-REFERENCE.10.5.2`** (`what-is-linkedspec.md` minimal example). PNT loop continues.
- 2026-06-17: **SPEC-LANG-REFERENCE.10.5 (scope) — broaden to a whole-book example scorch (user directive)**. Per the user directive ("scorch the book to hunt down book examples; the book shall not mislead, only truthful + valid code"), broadened `.10.5` into a **whole-book** exhaustive audit of every `.spec` snippet (doctrine-validity: no regex on a top `::` rule, ≥2 rules; + output-correctness via `LinkedSpec::Get`) → remediation. Audit-as-decomposition → fix sub-leaves `.10.5.1…`; subsumes `.10.4`. Frontier → `.10.5`. **Preliminary fan-out hunt** (4/5 read-only verifying agents reported before session exit; re-run fresh) confirms violations are WIDESPREAD (rule-modes, regex-in-spec, dsl helper refs; `worked-spec-walkthrough` §kind=pair claims a hash but returns `[]`; `get-and-get-parser` minimal example single-rule regex-on-top; §5.5 all three regex-on-top). `.10.3` catalog examples re-verified CLEAN. Read-only record/plan update — no book/Perl change. **Frontier → `SPEC-LANG-REFERENCE.10.5`.** Handoff-ready for a fresh session.
- 2026-06-17: **SPEC-LANG-REFERENCE.10.6 — record: retract the inaccurate "regex-on-top → []" premise; reframe the .10 rationale as the 2-rule authoring doctrine**. Ground-truth via `LinkedSpec::Get`: the OR self-ref / cross-rule action-edge regex-on-`::`-rule forms (old `.5.2`/`.9` examples + the §5.5 frozen oracle fixtures) **run and return their value**; only `::AND … -> Rule[N] { return }` returns `[]` (the `.10.1` finding). Rewrote the KM card `spec-top-rule-no-regex-two-rule-minimum.md` doctrine-first; retracted the false "`[]`" mechanism claim. **Doctrine + `.10.3` unchanged** — only the remediation rationale is corrected (the examples violated the 2-rule doctrine, not that they returned `[]`); there is no rationale for putting a regex on a top rule. KM gate regenerates `KNOWLEDGE_MAP.md`; self-check passes. No Perl, no book-example change. **Frontier → `SPEC-LANG-REFERENCE.10.4`.** PNT loop authorized (user, 2026-06-17). `RUST-PARITY` (frontier `.7.5.3`) resumes after this doc tree.
- 2026-06-17: **SPEC-LANG-REFERENCE.10.3 — book: redo Scalar+Numeric helper examples + preambles with the valid 2-rule idiom**. Remediation of the `.10`-flagged structurally-invalid examples. Rewrote the §2 (Scalar) + §5 (Numeric) "Worked examples" preambles and **all 33 helper examples** (17 Scalar + 16 Numeric) in `appendix/helper-contract-catalog.md` from the invalid `Demo:: /re/ -> Demo { return(<expr>) }` (regex on top rule → `[]`) to the **verified 2-rule idiom**: top `demo::` entry rule (no regex) `-> value .push` + `LX { return(array_copy(a(demo))) }`, normal `value : /<re>/  I.return(<expr>)` reading **`entry_group(N)`**. **Every example build-AND-run re-verified through `LinkedSpec::Get`** (scratch harness builds each spec from the exact book scaffold, JSON-encodes with `JSON::PP->canonical`, sanity-checked vs the frozen `["hello-world"]` idiom); all 33 produce the documented outputs, now the top rule's **one-element accumulator snapshot** (`["hello-world"]`, `[5]`, `[3.5]`, `[null]`, `[1]`/`[0]`). **Do-not-guess fix:** `is_defined` regex `/(\w*)(\S*)/`→`/(\w+)/` (empty-matchable → double dispatch-loop match → `["present","present"]`). Only remaining catalog `match_group` is the §8 Entry/Match *reference* (correct). `mdbook build` exit 0 (HTML verified: full blocks stay single code blocks); self-check + KM gate pass. No Perl change. **Frontier → `SPEC-LANG-REFERENCE.10.4`** (redo `.9` §5.5 Pair example). PNT loop authorized (user, 2026-06-17). `RUST-PARITY` (frontier `.7.5.3`) resumes after this doc tree.
- 2026-06-17: **SPEC-LANG-REFERENCE.10 (CORRECTION) — top rule has no regex; `.5.2`/`.9` examples are structurally invalid (NOT an engine bug); retract `.10.1`, plan remediation**. User established the `.spec` structural invariant: a **top (`::`) rule has NO regex** — it is the `_INITIAL` entry/`while(1)` dispatch loop matching the regexes of the **non-top (`:`) rules**; a valid spec needs **≥2 rules** (top + ≥1 normal rule carrying the regex). Verified vs `BootstrapSpec/Core.pm:414,417` + `RuleIR.pm:193-195` + an audit of all 20 specs (every top rule `regex_on_top=no`). **Consequences:** the `.10.1` "AND_SINGLE_ACODE engine regression" verdict was **WRONG** (the `[]` was invalid spec structure, not an engine bug — Perl reference untouched, authoritative); `.5.2`'s 35 examples + catalog preamble and `.9`'s §5.5 example used the invalid `Demo:: /re/ -> Demo {…}` form and **must be redone**. Deleted the bad KM card; wrote `spec-top-rule-no-regex-two-rule-minimum.md` with the **verified 2-rule idiom** (`demo_top:: -> word_pair .push; LX{return(array_copy(a(demo_top)))}` + `word_pair : /(\w+) (\w+)/ I.return(concat(entry_group(0),"-",entry_group(1)))` → `["hello-world"]`; child reads `entry_group`, not `match_group`). Superseded `.10.1` verdict + `.10.2` fork; added remediation leaves `.10.3` (redo `.5.2`+preamble), `.10.4` (redo `.9` §5.5), `.10.5` (audit other chapters). Records/correction only — no Perl, no example rewrites in this slice. self-check exit 0. **FRESH SESSION recommended; repo handoff-ready. Frontier → `SPEC-LANG-REFERENCE.10.3`.**
- 2026-06-17: **SPEC-LANG-REFERENCE.10.1 — investigation: single-slot AND edge-return drop is a Perl-reference regression (not intended)**. Read-only root-cause investigation (the user chose "investigate first, recommend before any change," and to HOLD the PNT loop). **VERDICT: accidental regression, NOT intended.** `_emit_and_single_acode_handler` (`perl/LinkedSpec/HandlerVariantEmitter.pm:564-630`) builds the transformed edge acode in the loop at 575-582 but **never `push`es it** → empty dispatch → `return \@collect` ([]). Provenance: MEDIUM-IMPACT.3.4.x rework (`148c746`/`7fec186`); sibling `_emit_and_acode_seq_handler` got the same edit WITH its push (oversight). Pre-documented gap in `specentry-perl-coupling-inventory.md:234`; no test pins `[]`. Triple-verified vs source/git/card; behavioral matrix via `LinkedSpec::Get` (single-slot AND `LX`/`E`/edge return all → `[]`; OR self-ref + multi-slot-closing-slot + REP all surface values). KM card `and-single-acode-edge-return-dropped.md` written. `.10` split: `.10.1` done, `.10.2` (fix) **BLOCKED on a user DIRECTION decision** (engine-fix vs doc-rewrite vs both; recommend engine-fix or both — engine-fix → dedicated engine tree). No code/book change. **PNT loop HELD by user** until `.10` decided; next selectable `.5.3`. `RUST-PARITY` (frontier `.7.5.3`) resumes after this doc tree.
- 2026-06-17: **SPEC-LANG-REFERENCE.9 — book: fix drifted §5.5 Pair example output (+ surface a systemic variant)**. Corrected the `runtime-semantics.md` §5.5 third example: `Pair::AND … -> Pair[0] { return(array("?pair:", …)) }` documented output `["?pair:","key","val"]` but actually returns `[]` (re-verified under default/`consume`/`seek` — parse mode is not the variable). Swapped to the **verified** OR self-ref form `Pair:: … -> Pair { return(array(…)) }` (→ `["?pair:","key","val"]`) + a §5.7 cross-ref note. §5.5/§5.6 swept (frozen Top→Done fixtures correct; §5.6 `I.return`-on-`:`-rule snippets are a different shipped-spec-grounded construct, untouched). **SYSTEMIC finding → new leaf `.10`, BLOCKED on a user decision:** the same single-slot `::AND -> Rule[0] { return }` form is used in several chapters that assert concrete outputs (notably the canonical `worked-spec-walkthrough.md`, claiming `{kind=>"pair",…}` for `answer = 42`; actually `[]`). Shipped specs use `-> Rule[N] { return }` self-edges only on **multi-slot** rules (closing-slot accumulator snapshot), so the construct is valid — the drift is single-slot `::AND` self-edge output claims. **Fork (surfaced to user):** engine-bug-fix (Perl reference + Rust + oracle) vs doc-rewrite (multi-chapter). `mdbook build` exit 0; self-check exit 0. **Frontier → `SPEC-LANG-REFERENCE.5.3`** (next unblocked); `.10` blocked. PNT loop authorized (user, 2026-06-17). `RUST-PARITY` (frontier `.7.5.3`) resumes after this doc tree.
- 2026-06-17: **SPEC-LANG-REFERENCE.5.2 — book: compile-verified worked examples for all Scalar + Numeric helpers**. Filled the example-density gap for `helper-contract-catalog.md` §2 (Scalar) + §5 (Numeric): a shared **Worked examples** preamble (runnable scaffold `Demo:: /<re>/ -> Demo { return(<expr>) }`; output = parser's top-level value; booleans → `1`/`0`, undef → `null`) plus an `Example` on **all 35 helpers** (17 Scalar + 18 Numeric), full `.spec` blocks for `concat`/`trim`/`num_add`/`num_sum`. **Every example build-AND-run verified through `LinkedSpec::Get`** with a scratch oracle-style driver sanity-checked against the frozen `proof_edge_{scalar,array}_literal` fixtures (reproduced exactly → outputs are reference behavior, not guesses); all 35 produce the documented outputs. **Two do-not-guess traps caught:** (1) `is_defined`/`is_undefined` lower only on the control-flow path (`ActionIR/FlowExpr.pm`) so `return(is_defined(x))` dies → documented condition-only via `if (...)`; the value-predicates `matches`/`starts_with`/`ends_with`/`contains_substr` ARE returnable (`1`/`0`); (2) `num_sum(split(...))` → `null` so array-form reducers use explicit `array(...)` (split deferred to Array `.5.3`). **Discovered defect (owned separately, not bundled): the §5.5 `runtime-semantics.md` Pair example outputs `[]`, not its documented `["?pair:","key","val"]`** (the AND-`[0]` self-edge form; the tagged array needs the OR self-ref `-> Pair` form) → new leaf `.9` (no-drift priority). `mdbook build` exit 0; self-check exit 0. **Frontier → `SPEC-LANG-REFERENCE.9`** (fix §5.5 drift) **then `.5.3`**. PNT loop authorized (user, 2026-06-17). `RUST-PARITY` (frontier `.7.5.3`) resumes after this doc tree.
- 2026-06-17: **SPEC-LANG-REFERENCE.5.1 — helper-catalog audit + variant-neutrality fixes + decomposition** (`.5` split, surface large). Delegated read-only audit of `Contracts.pm` ids vs `helper-contract-catalog.md`: **0 public-API completeness gaps** (158 ids = ~130 public + 17 internal IR variants + ~11 deprecated `compatibility_surface`); **2 Perl-sigil variant-neutrality leaks fixed** (`$name`→`name` line 13, `$rule_label`→"named after the rule label" line 159; whole-catalog re-sweep found no others); **0 `.spec` examples across all 10 families / ~140 helpers** → decomposed into per-family example sub-leaves `.5.2` (Scalar+Numeric), `.5.3` (Array), `.5.4` (Hash+Control Flow), `.5.5` (Decl/Capture-Mark/Entry-Match/Input/Call), each ≥1 compile-verified example. `mdbook build` exit 0; self-check exit 0. **Frontier → `SPEC-LANG-REFERENCE.5.2`**. PNT loop authorized (user, 2026-06-17). `RUST-PARITY` (frontier `.7.5.3`) resumes after this doc tree.
- 2026-06-17: **SPEC-LANG-REFERENCE.4 — book: worked examples for grouped targets + entry-vs-match divergence**. Closes audit gaps C (grouped `-> A | B { ... }` had no example) and D (entry-vs-match lacked a divergence example). (1) *Grouped action-edge targets* section in `dsl/action-and-lifecycle-placement.md` (one shared block bound to multiple targets), grounded in `ebnf.spec` + formal grammar §3.2; compiles. (2) *When `entry_*` and `match_*` diverge* section in `dsl/capture-marks-and-source-locations.md` — a dispatched-child example (`Call`→`Inner` over `greet(world)`: `entry_text()`=`greet(`, `match_text()`=`world`), cross-linked to the source-boundary example; compiles. **Verified, not guessed**: both examples compiled through `LinkedSpec::Get`; divergence semantics grounded in `.2`'s verified source wiring + the existing book example. **Honest scope note**: a clean top-level runtime I/O for the divergence was NOT fabricated — ~9 minimal accumulator/dispatch shapes all collapsed to `[]`/`undef`/`0` (documented hard accumulator axes), so it's documented at the verified reader-wiring level. `mdbook build` exit 0; self-check exit 0. **Frontier → `SPEC-LANG-REFERENCE.5`** (helper-catalog completeness + variant-neutrality sweep). PNT loop authorized (user, 2026-06-17). `RUST-PARITY` (frontier `.7.5.3`) resumes after this doc tree.
- 2026-06-17: **SPEC-LANG-REFERENCE.3 — book: the output/return-value shape contract (`runtime-semantics.md §5`)**. Closes CRITICAL gap B (output shape was reverse-engineered from `tests/corpus/`). Expanded §5 (renamed *Accumulator Convention* → *Accumulator and Output Shape*): §5.5 *What a Parser Returns* (top rule's value, returned directly, no envelope — 3 verified input→output pairs); §5.6 *The Output Shape Is the Author's Choice* (engine imposes **no output schema**; the `["?<rule>:", …]` tagged array is an **optional, older convention** with no engine meaning — authors may use any shape or none); §5.7 *`return(...)` versus the accumulator* (value channel vs implicit accumulator; child return consumed explicitly, not auto-appended); §5.8 *Backend Output Reconciliation* (the one-level wrap; reference value canonical, oracle compares a wrapping backend against `[reference]`). **Verified, not guessed**: literal examples are frozen oracle-corpus fixtures; the tagged `["?pair:","key","val"]` example was produced by **running the Perl reference** (re-confirming `.2`'s `match_group(0)`=first-capture); the convention confirmed by grepping shipped specs; wrap/return contract grounded in `docs/knowledge/rust-perl-output-oracle.md`. A hand-built accumulator example (`[undef,undef,undef]`) was **discarded** — only verified material documented. **User feedback mid-leaf**: tagged shape is non-mandatory → reframed §5.6/§5.7 (saved as durable feedback memory). `mdbook build` exit 0; self-check exit 0. **Frontier → `SPEC-LANG-REFERENCE.4`** (grouped-target + entry-vs-local-match worked examples). PNT loop authorized (user, 2026-06-17). `RUST-PARITY` (frontier `.7.5.3`) resumes after this doc tree.
- 2026-06-17: **SPEC-LANG-REFERENCE.2 — book: regex as a first-class concept + fix capture-indexing drift**. New chapter `docs/linkedspec-book/src/user-model/regex-in-spec.md` (registered in `SUMMARY.md`): `/pattern/` literal + `\/` escaping + inline `(?flags)`; regex slots/clusters → ordered-sequence (AND) vs alternatives (OR) + which-alternative branch tracking; `seek`/`consume` anchoring; numbered groups (**0-based, captures-only, compacted**) + the compaction gotcha + named-group remedy; entry-vs-match; and a verified **"regex feature set a backend must support"** section. Expanded `appendix/formal-grammar.md §3.1` with the capture-group contract + inline-flags clarification. **Every engine fact verified** read-only against `perl/LinkedRE.pm` (`oredRE`/`_build_match_info`), the ActionIR lowering (`Contracts.pm` `entry_group`→`$IMATCH_LIST[N]`, `match_group`→`$LMATCH_LIST[N]`), the `/pattern/` recognizer (`BootstrapSpec/Core.pm`), the Rust `rgx` runtime (`helpers.rs` `CompiledAlternation` + `matched_branch_number`), and cross-checked vs shipped specs (`lib_reader`/`tablegrep`/`spec.spec` → `entry_group(0)` = first capture) — never guessed. **Found + fixed a real capture-indexing contradiction**: `helper-contract-catalog.md` claimed "index 0 is the full match" (wrong) vs the walkthrough's correct "0 = first capture group"; corrected the catalog, two buggy examples (`overview/what-is-linkedspec.md`, the `formal-grammar.md` Child rule) using the wrong 1-based convention, and `source-boundary-helper-reference.md`. `mdbook build` exit 0; self-check exit 0. **Frontier → `SPEC-LANG-REFERENCE.3`** (output/return-shape contract). `RUST-PARITY` (frontier `.7.5.3`) remains active, resumes after this doc tree.
- 2026-06-17: **SPEC-LANG-REFERENCE.1 — audit + decomposition for complete variant-agnostic `.spec` book coverage** (new tree `SPEC-LANG-REFERENCE`, created this commit, ownership-first; audit-only). Owns the user request to fully + variant-agnostically document the ENTIRE `.spec` surface with abundant examples + KM cards (next backend needs no archaeology). Two read-only agents (authoritative surface inventory from `Core.pm`/`Validation.pm`/`Contracts.pm`(158)/`spec.spec`/shipped specs ∥ book coverage map over all `user-model`/`dsl`/`compiler`/`appendix` chapters) synthesized in the tree's "Audit Findings". **8/10 surface areas already WELL-COVERED**; binding gaps: (A→`.2`) regex-as-first-class (syntax-only in `formal-grammar.md:111-127`; no mental model/examples/required-feature-set); (B→`.3`) output/return-shape contract undocumented (backends reverse-engineer from corpus). Minor: grouped targets + entry-vs-local-match examples (`.4`), helper-catalog completeness+neutrality (`.5`), capture/mark cross-example (`.6`); KM cards (`.7`); finalize (`.8`). Rejected an unverified "E/IT deprecated" inventory claim (contradicts `LIFECYCLE-FAMILY-AUDIT`). self-check exit 0; KM green; no book change. **Frontier → `SPEC-LANG-REFERENCE.2`** (regex-first-class; verify engine feature set vs `LinkedRE.pm`/rgx before asserting). `RUST-PARITY` (frontier `.7.5.3`) remains active, resumes after this doc tree.
- 2026-06-17: **DOC-DRIFT-SYNC.2 — fix transposed :& / :| rule-mode cells in formal-grammar.md (TREE COMPLETE)** (book-only). The `:&`/`:|` description cells in `docs/linkedspec-book/src/appendix/formal-grammar.md:68-69` were transposed (AND/OR sense inverted vs `Core.pm:347-348` `&`→AND/`|`→OR + the dedicated `user-model/rule-modes-and-parse-modes.md`). Fixed: `:&` → "Ordered sequence (equivalent to `:AND`)."; `:|` → "Single choice — one successful alternative wins (`:OR{1}`)." Grep confirmed no other stale `:&`/`:|` ref in the file; §2.2 Semantics note already correct. `mdbook build` exit 0; self-check exit 0; KM green; no code change. **`DOC-DRIFT-SYNC` tree COMPLETE** (both leaves) → moved to Completed in `docs/TASK_TREE.md`. **Next: NEW user request (2026-06-17) — comprehensive variant-agnostic `.spec` syntax/semantics book coverage + KM cards (own tree).** `RUST-PARITY` (frontier `.7.5.3`) is again the sole active tree, resumes after the doc work.
- 2026-06-17: **DOC-DRIFT-SYNC.1 — sync ROADMAP.md to ROADMAP_V2.md (Phase 8/9 + Overall done)** (docs-only; new tree `DOC-DRIFT-SYNC`, created this commit, ownership-first). Zero-drift fix (doctrine `docs/decisions/0001` §4) for a bootstrap-session audit finding: `ROADMAP.md` lagged `ROADMAP_V2.md` — Overall `mostly done` vs `done`, **no Phase 8 / Phase 9 rows or long-form sections** (V2:56,66-67 marks both `done`). Added `## Phase 8` (multi-backend handoff) + `## Phase 9` (Rust variant; points at the active `RUST-PARITY` parity follow-on so it doesn't over-claim) long-form sections after Phase 7; inserted Phase 8/9 Status-table rows; flipped Overall `mostly done`→`done` (covers/remaining aligned to V2:56). `ROADMAP_V2.md` is canonical (per `docs/TASK_TREE.md`), unchanged. Dismissed non-drift (Non-Goal): "158 vs 146 helper contracts" — the book's 158 is reproducible. `scripts/check_memory_architecture.sh` exit 0; KM green; no code/book change. **DOC-DRIFT-SYNC frontier → `.2`** (formal-grammar.md `:&`/`:|` fix); `RUST-PARITY` stays active, resumes at `.7.5.3` after.
- 2026-06-17: **RUST-PARITY.7.5.1 — fix the header-line-regex → 0-regex parser bug in the Rust variant** (Rust parser code + tests). `rust/linkedspec-core/src/parser.rs:86` `(\S*)`→`([^\s/]*)`: a `/…/` regex on a rule's header line was swallowed by the mode-suffix group (`parse_mode_suffix("/;/")`→`Default`, regex dropped), so single-regex header rules registered 0 regexes (bracket pairs registered 1) and `-> child[N]` edges "never fired"; narrowing the class lets the regex fall through to `rest` where `parse_inline_body` registers it. **Bracket pairs repaired:** `command_subst : /open/ /close/` now registers `[open, close]` (entry idx 0 = open; self-recursive `-> command_subst[1]` → idx 1 = close). 4 new unit tests (3 `parser.rs` + 1 `compiler.rs`). `cargo test --manifest-path rust/Cargo.toml` = **242 passed / 0 failed** (238 baseline + 4; `linkedspec_core` 90→94; corpus_oracle 1 green proof). `cargo clippy -p linkedspec-core -p linkedspec-runtime --tests` warning multiset = baseline (core 10 / runtime 13 / validation.rs 4, zero-new; pre-existing `approx_constant` exit-101 in untouched `expr.rs:687`/`types_test.rs:143` recorded, not in scope). **PNT split — necessary but NOT sufficient for tclite:** with regexes registering, the oracle still showed tclite `[]` → `[]` because tclite accumulates via fluent continuations on ACTION edges (`-> command_subst .push`, `-> command_subst[1] .return(...)`) and the parser attaches `.method` chains only to BLIND edges (`=>`), so the compiler discards them after a `->` edge (`compiler.rs:171`). That independent gap → new leaf **`.7.5.3`** (action-edge fluent lowering, greens tclite); tclite oracle cases re-deferred there (corpus back to 2 green proofs). Lispish unaffected by `.7.5.3` (uses `{ code }` blocks) — needs `.7.5.2` (scalaref). Self-check exit 0. Knowledge card `docs/knowledge/rust-perl-output-oracle.md` corrected. **Active frontier → `RUST-PARITY.7.5.3`.**
- 2026-06-17: **RUST-PARITY.7.5 — SPLIT** (PNT rule 5; tree structuring, no code). A read-only investigation (+ a direct read of `parser.rs:86`) located the two **independent** root causes of the `.7.1` oracle's shipped-spec divergence and confirmed they are separable. Split into `.7.5.1` — fix the **header-line-regex → 0-regex parser bug** (`rust/linkedspec-core/src/parser.rs:86`: the header regex's `(\S*)` mode-suffix group eats a `/…/` regex on the header line, so `parse_mode_suffix("/;/")`→Default and the regex is discarded → `-> child[0]` edges never fire; fix `(\S*)`→`([^\s/]*)`; the shared root cause for tclite/Lispish/most specs; **foundational** — every rule header — so the open/close-pair semantics + full suite + oracle must be verified) — and `.7.5.2` — add `{…}` hash-literal/field-accessor to the action-code expression parser (`rust/linkedspec-core/src/expr.rs:299`) for Lispish's `scalaref(retv, {content})` (larger; depends on `.7.5.1`). Self-check exit 0; no code touched. **Recommend a FRESH SESSION to implement `.7.5.1`** — a foundational parser change deserves fresh focus after a long session; repo is handoff-ready. **Active frontier → `RUST-PARITY.7.5.1`.**
- 2026-06-17: **RUST-PARITY.7.1 — Perl↔Rust output-oracle mechanism + green first proof** (Rust + Perl tooling; first child of the `.7` split). Built the cross-variant output oracle (ADR 0006 §Phase 8.6): a timeout-guarded Perl generator `tools/gen_oracle_corpus.pl` (`alarm` per parse, `JSON::PP->canonical(1)`) emits `rust/linkedspec-runtime/tests/corpus/<case>/{input.spec,input.txt,expected.json}` (the book `backend-handoff.md` corpus format — zero added drift); a Rust runner `tests/corpus_oracle.rs` enumerates the corpus and asserts `engine.execute(input) == [reference]` (the documented one-level wrap: Perl returns the top value directly, Rust wraps the accumulator). **The oracle's first run DISPROVED the `.7`-split premise** that tclite/Lispish match "modulo wrap": tclite `[]` → Rust `[]` (Perl `["?tcl_script:",[["?command_subst:",[]]]]`), Lispish → `exit_now(1)`. Shared root cause — a single-regex rule written `name : /re/` (single colon) compiles in Rust as **0-regex**, so `-> child[0]` edges never fire (`::` single-regex rules are fine). Engine fix deferred to NEW leaf **`.7.5`** (now first in frontier, blocking `.7.2`/`.7.3`). Mechanism proven green on 2 controlled authored grammars (scalar `"scalar-ok"`→`["scalar-ok"]`; nested array `["?proof:","ok"]`→`[["?proof:","ok"]]`) that avoid every divergence source (no retv, no group-indexing, no single-colon rule, action-less child). `perl -c` OK; `cargo test` = **238 passed / 0 failed** (237 baseline + 1); `cargo clippy -p linkedspec-core -p linkedspec-runtime --tests` = core 10 / runtime 13 / validation.rs 4 = baseline (zero-new); self-check exit 0. No book change (format already matched; wrap-rule note → `.7.4`/`.9`). New knowledge card `docs/knowledge/rust-perl-output-oracle.md`. **Active frontier → `RUST-PARITY.7.5`** (Rust engine output-parity fix).
- 2026-06-16: **RUST-PARITY.7 — SPLIT** (PNT rule 5; tree structuring, no code). A two-agent read-only investigation (Rust test/corpus infra + Perl reference output path) confirmed the broad `.7` leaf must be split: there is **no oracle mechanism / canonical cross-variant output form yet**, an **output-shape reconciliation** is needed (the Perl reference returns the top rule's value directly — `tclite` `[]` → `["?tcl_script:",[["?command_subst:",[]]]]`, `Lispish` `(x y)` → `["x",["y"]]` — while the Rust engine wraps it one level in the accumulator, `[<value>]`), **~16/20 specs lack input fixtures** (authored inputs required), and the **`RTLUtils` hang needs a hard-timeout guard**. Split into `.7.1` (oracle mechanism + canonical form + first proof on tclite/Lispish), `.7.2` (corpus batch 1 — simple specs), `.7.3` (corpus batch 2 — remaining/harder, RTLUtils-guarded), `.7.4` (drift guard + finalize). **Architecture decision:** a timeout-guarded Perl fixture generator (`tools/`) emits canonical-JSON fixtures into `rust/linkedspec-runtime/tests/corpus/`; a Rust fixture-runner test compares `engine.execute(input)` against them (Perl-free `cargo test`; realizes ADR 0006 §Phase 8.6 language-neutral corpus). Self-check exit 0; no code touched. **Active frontier → `RUST-PARITY.7.1`.**
- 2026-06-16: **RUST-PARITY.6 — strict_syntax validation mode in the Rust variant** (Rust code; closes audit Gap 4). Added `validate_with_options(spec, strict_syntax: bool)` to `rust/linkedspec-core/src/validation.rs`; `validate(spec)` is now a non-strict wrapper (all ~70 call sites unchanged). Strict mode adds `check_unused_rules` (`unused = defined − used`), promoting the Perl reference's unused-rule **warning** to a hard error — parity with `Validation.pm validate_dsl_syntax(..., strict_syntax => 1)`. **Verified the reference semantics empirically** (timeout-guarded direct `validate_dsl_syntax` calls): `Top:: -> Child` strict → FAIL "Unused rule(s): Top" (top rule **not** exempt); `Top:: -> Ghost` strict → FAIL "Undefined rule reference(s): Ghost" (reported first). Undefined refs are already fatal here in every mode (`check_edge_targets`, runs first — preserving the reference's undefined-before-unused order), a pre-existing default-stricter-than-Perl divergence left as-is, so strict's observable addition is the unused-rule rejection. 4 new tests (`validate_strict_rejects_unreferenced_top_rule`, `validate_nonstrict_allows_unreferenced_rules`, `validate_strict_still_rejects_undefined_reference`, `validate_strict_accepts_fully_referenced_spec`). `cargo test` = **237 passed / 0 failed** (233 baseline + 4); `cargo clippy -p linkedspec-core --tests` validation.rs 4 = baseline 4 (zero new), `-p linkedspec-runtime --tests` 13 = baseline 13. No book change (strict contract already in `compiler/pipeline-overview.md`; book sync `.9`). Self-check exit 0. New knowledge card `docs/knowledge/rust-strict-syntax-validation.md`. **Active frontier → `RUST-PARITY.7`** (expand Rust runtime test corpus to the 20 shipped specs — Perl↔Rust output oracle).
- 2026-06-16: **RUST-PARITY.5.5.4 — anonymous capture-slice family in the Rust engine (+ catalog §7 entries)** (Rust engine code + book; fourth/final child of the `.5.5` split — **closes `.5.5` and `.5`**). Implemented the **anonymous** capture-slice family (counterpart of the `.5.5.3` named-mark family; reads the anonymous capture cursor `ctx.capture_start` = Perl `$IPOS`, set by `start_capture_slice()`). Authoritative contract: `perl/LinkedSpec/ActionIR/Contracts.pm` ~366–656. **Fixed** `capture_slice`/`capture_slice_len` to end at `ctx.match_start_byte` (match-start, Perl `$LSPOS - length $LMATCH`), was `ctx.pos` — the anonymous analog of the `.5.5.3` `capture_from` fix; this closes the book↔Rust gap `.5.5.3` handed off (catalog already stated match-start). **Added** 10 `call_helper` arms (reusing `span_text`/`span_char_len`): `capture_slice_until_cursor`(+`_len`)→cursor; `capture_take`(+`_len`)→match-start then advance `capture_start` to cursor; `capture_take_until_cursor`(+`_len`)→cursor then advance; `capture_rest`(+`_len`)→end-of-input; `capture_take_rest`(+`_len`)→end then advance. Text → raw slice, `_len` → char count (`.5.3`); reversed span → `undef`; `_take_*` mutate only on a valid span. **Scope:** folded in the inventory-missing-but-same-family `capture_rest`/`capture_rest_len`/`capture_take` so the anonymous family lands complete (the `.5.5.3`-discovered mark/match/entry-anchored helpers stay a deferred follow-up). **Book catalog §7:** added the 10 anonymous entries + refined the intro endpoint list and the destructive-`_take_` note (the take readers advance to the cursor, not the read endpoint); variant-agnostic, no-drift. Updated the two landed `helpers_5_2_capture_slice_*` tests (`"hello"`→`""`, `>0`→`0`). `cargo test` = **233 passed / 0 failed** (223 baseline + 10 new `helpers_5_5_4_*`); `cargo clippy -p linkedspec-runtime --tests` source warnings **13 = baseline 13** (zero new; vendored pgen/rgx-core ignored). `mdbook build` exit 0; self-check exit 0. New knowledge card `docs/knowledge/rust-anonymous-capture-slice-family.md`. **Active frontier → `RUST-PARITY.6`** (strict_syntax validation mode).
- 2026-06-16: **RUST-PARITY.5.5.3 — mark-based capture family in the Rust engine (+ catalog §7 fix)** (Rust engine code + book; third child of the `.5.5` split). Implemented the audit Gap-5 mark-based readers + setters and **fixed `capture_from` to Perl match-start parity** (Open Question RESOLVED as option (a), user-confirmed). Authoritative contract: `perl/LinkedSpec/ActionIR/Contracts.pm` ~690–1047. New `call_helper` arms (`rust/linkedspec-runtime/src/engine.rs`): `capture_from` (fixed: now ends at `ctx.match_start_byte`, was `ctx.pos`), `capture_len_from`, `capture_until_cursor_from`(+`_len`), `capture_take_until_cursor_from`(+`_len`), `capture_take_len_from`, `capture_rest_from`(+`_len`), `capture_take_rest_from`(+`_len`), `capture_between`, `capture_len_between`, `mark_input_start`(→0), `mark_input_end`(→byte len), `mark_copy(target, source)` (**2-arg** copy/delete). `_take_*` advance the mark to the read's endpoint (cursor, or end-of-input for `_rest_`); text → slice, `_len_*` → char count; missing mark / reversed span → `undef` (guarded `span_text`/`span_char_len`). **Book catalog §7 corrected** to the authoritative contract (user-requested): `capture_from` endpoint, 2-arg `mark_copy`, `_until_cursor_`/`_take_` + anonymous `capture_slice` wording, and the missing `_len_` companions. Updated the landed test `helpers_5_2_mark_and_capture_from` `"hello"`→`""`. `cargo test` = **223 passed / 0 failed** (207 baseline + 16 new `helpers_5_5_3_*`); `cargo clippy -p linkedspec-runtime --tests` source warnings **13 = baseline 13** (zero new; vendored pgen/rgx-core ignored). `mdbook build` exit 0; self-check exit 0. New knowledge card `docs/knowledge/rust-mark-based-capture-family.md`. **Discovered (recorded for `.5.5.4`/follow-up):** anonymous `capture_slice`/`_len` Rust arms still read to cursor; `mark_match_start/end`, `mark_entry_start/end`, `capture_take(mark)`, `capture_take_between(_len)` are absent from both Rust and the `.1` inventory. **Active frontier → `RUST-PARITY.5.5.4`** (anonymous capture-slice variants).
- 2026-06-16: **ALIAS-RETIREMENT-DOC-SYNC.1 — retire array-edge alias claims across book + roadmaps** (docs-only; new 1-leaf tree, completed). Zero-drift correction driven by RUST-PARITY.5.5.2's resolution + user direction that the variant-agnostic book/docs must be correct (not deferred as "Perl-side"). The array-edge aliases `tail`/`drop_last`/`flatten`/`array_values` are retired (Perl reference doesn't recognize them; 0 spec uses; 0 `t/` locks; "Retired" in the book catalog). Corrected 16 stale "remains/preserving … compatibility alias/syntax" claims → retirement (`COMPAT-ALIAS-RETIREMENT.1`), preserving historical "Landed …" records: book `appendix/formal-grammar.md:357`; `ROADMAP_V2.md` (182 ×3 + 256/257/260/262); `ROADMAP.md` (735/736/993/994/997/999/1189/1190/1191/1242). The book is now internally consistent with its own Helper Contract Catalog. Capture / named-map aliases caught by the same grep left out of scope (separate audit). `mdbook build` exit 0; gates pass; no code change. **Active Rust frontier unchanged → `RUST-PARITY.5.5.3`.**
- 2026-06-16: **RUST-PARITY.5.5.2 — input-boundary helpers + flat splice** (Rust engine code; second child of the `.5.5` helper-gap split). Added 3 `call_helper` arms in `rust/linkedspec-runtime/src/engine.rs`: `input_end_line()` (= `1 + whole-input newline count`, parity with Perl `Contracts.pm` `INPUT_END_LINE_READ`), `input_end_col()` (char distance past the last newline `+1`-when-none, parity with `_build_column_read_expr(length($$STRING))`, modeled on `cursor_col`, multibyte-correct), and generic `flat(container)` (Array→Array / Hash→Hash / scalar→single-element; Perl `MethodLowering.pm:199`). **Resolved the parked alias-retirement Open Question against the Perl reference:** `tail`/`drop_last`/`flatten`/`array_values` are NOT recognized by the reference (absent from all helper-recognition regexes, unused in 20 specs, 0 phase0 locks, retired in `COMPAT-ALIAS-RETIREMENT.1`, "Retired" in the book catalog) → deliberately NOT added to Rust (parity = match the reference's recognized surface; adding them would diverge). Only canonical `flat` was missing and is added. 3 new tests (`helpers_5_5_2_*`, end-to-end incl. multibyte + trailing-newline + flat-into-parent-hash). `cargo test` = **207 passed / 0 failed** (204 baseline + 3); `cargo clippy -p linkedspec-runtime --tests` `linkedspec-runtime` lib 13 = baseline 13 (zero new; integration_test `len_zero` :199 pre-existing; vendored pgen/rgx-core ignored). No book change (catalog §9 + §Compatibility-Aliases already conform; book sync `.9`). New knowledge card `docs/knowledge/rust-retired-array-aliases-not-added.md`. Flagged stale `ROADMAP_V2` 256–262 alias text for a separate Perl-side doc-sync slice. **Active frontier → `RUST-PARITY.5.5.3`** (mark-based capture family `capture_*_from`/`_between`, `mark_*`).
- 2026-06-16: **RUST-PARITY.5.5.1 — named-group reader helpers** (Rust engine code; first child of the `.5.5` helper-gap split). Added the 8 named-capture readers from the audit's Gap 5 to Helper Contract Catalog §8 parity, as new `call_helper` arms in `rust/linkedspec-runtime/src/engine.rs`: `entry_named(name)`→string/undef, `entry_has(name)`→bool, `entry_map()`/`entry_named_map()`→hash, plus the four `match_*` equivalents (`entry_named_map`/`match_named_map` are retired aliases implemented as combined arms). The entry readers read `ctx.entry_named`, the match readers `ctx.match_named` — both already populate from `MatchResult.named` (engine.rs:280/291) and save/restore in `SavedMatchState`, so this is a purely additive 8-arm change (no struct/population changes). New free helper `named_map_to_hash` sorts keys so `entry_map`/`match_map` are deterministic (matching `sorted_keys`/`sorted_values`). 6 new tests (`helpers_5_5_1_*`, end-to-end via `(?P<name>…)` regexes, covering present/absent and alias forms). `cargo test` = **204 passed / 0 failed** (198 baseline + 6); `cargo clippy -p linkedspec-runtime --tests` lint multiset byte-identical to stashed HEAD baseline (13 = 13; zero new). No book change (catalog §8 already documents these; Rust now conforms — book sync is `.9`). No knowledge card (localized additive change reading existing infra). **Active frontier → `RUST-PARITY.5.5.2`** (input-boundary helpers + real compat aliases; resolve the parked alias-retirement Open Question there).
- 2026-06-16: **RUST-PARITY.5.5 — SPLIT** (PNT rule 5; tree structuring, no code). PNT reached `RUST-PARITY.5.5` and an engine.rs audit confirmed it too broad (~28 missing helpers across ~7 families; only `drop_front`/`drop_back`/`array_copy`/`flat_array` of the family exist). Split into `.5.5.1` named-group readers (entry/match `_named`/`_has`/`_map`), `.5.5.2` input-boundary helpers + real compat aliases (`tail`/`drop_last`/`flatten`), `.5.5.3` mark-based capture family (`capture_*_from`/`_between`, `mark_*`), `.5.5.4` anonymous capture-slice variants. Parked an alias-policy Open Question (book catalog says `tail`/`drop_last`/`entry_named_map` are "retired aliases"; `ROADMAP_V2` says they "remain compatibility syntax" — resolve against the Perl reference in `.5.5.2`). Frontier → `.5.5.1`. **`.5.5` is detailed per-family helper work; recommending a FRESH SESSION to implement `.5.5.1`–`.5.5.4` at signoff quality after four engine leaves this session — repo is handoff-ready.**
- 2026-06-16: **RUST-PARITY.5.4 — dedup shadowed arms + REP zero-progress guard** (Rust engine code). Removed three shadowing duplicate `call_helper` arms (`print`, `hash`/`h`, `hash_copy`) so the better later arms win (Hash-arg merge for `hash`, `resolve_array_target` for `hash_copy`, consolidated `say|print|print_each`) — clearing 3 `unreachable_patterns` warnings. Fixed the REP loop's zero-progress guard: it now snapshots `pos_before` each iteration and breaks when `ctx.pos == pos_before` (Perl `loop_end_pos == loop_start_pos`) instead of a `matches > 100` iteration cap, so a zero-width REP match terminates after one no-progress iteration. 2 new tests. `cargo test` = **198 passed / 0 failed** (196 baseline + 2); `cargo clippy -p linkedspec-runtime --tests` touched-file warnings 15 → 12 (zero new). No knowledge card (localized fix). No book change (internal correctness; matches the documented Perl REP model — book sync is `.9`). **Active frontier → `RUST-PARITY.5.5`** (~30 missing capture/mark/entry/match/input helpers + real `tail`/`drop_last`/`flatten` aliases).
- 2026-06-16: **RUST-PARITY.5.3 — char-based offsets/slicing** (Rust engine code). Closed the audit's byte-indexing MAJOR: `substr`/`input_slice` byte-sliced DSL char-offset args (panicking on a multibyte boundary), cursor/capture lengths+columns were byte counts, and `entry_start_pos`/`match_start_pos` were hardcoded `0.0`. Internal positions stay byte-based (the regex engine is byte-based); the DSL boundary is now char-based for Perl parity via new `byte_to_char_offset`/`char_substr` helpers. `substr`/`input_slice`/`cursor_*`/`input_*`/`capture_slice_*`/`mark_pos`/`entry_*`/`match_*`/`length` all char-based; `RuntimeContext` gained `entry/match_*_byte` span fields (part of `SavedMatchState`, recorded from `m.start`/`m.end`) so `entry/match_start_pos` report real char offsets. 7 new multibyte tests (`chars_5_3_*`). `cargo test` = **196 passed / 0 failed** (189 baseline + 7); `cargo clippy -p linkedspec-runtime --tests` touched-file warning count identical to baseline (zero new). New knowledge card `docs/knowledge/rust-char-based-offsets.md`. No book change (positions/lengths/`substr` are char-based in the `.spec` contract; Rust now conforms — book sync is `.9`). **Active frontier → `RUST-PARITY.5.4`** (dedupe match arms + REP zero-progress guard).
- 2026-06-16: **RUST-PARITY.5.2 — entry_*/match_* separation** (Rust engine code). Closed the audit's match/entry-unification MAJOR: the single match-set site set the rule's own regex match into BOTH the entry registers (`entry_groups`/`entry_named`) and the local registers (`match_groups`/`match_named`), so `entry_*` and `match_*` were always identical and a child clobbered the parent's match. `execute_rule` now emulates Perl's per-handler `IMATCH`/`LMATCH` lexicals via a `SavedMatchState` save/restore: the entry match = the dispatcher's local match (Perl `$info = $minfo`, `MethodLowering.pm:332` + preamble `IMATCH=$$info{match}`); the rule's own match updates only the local registers; entry is seeded from the first own match only for the dispatcher-less top rule; both registers restore on exit (blind-call + normal returns) so a child's matching is transparent to the parent. 3 new integration tests (`match_5_2_*`: child entry/local divergence, parent match survives child dispatch, top-rule entry==local). `cargo test` = **189 passed / 0 failed** (186 baseline + 3); `cargo clippy -p linkedspec-runtime --tests` touched-file warning set identical to baseline (zero new). New knowledge card `docs/knowledge/rust-entry-match-separation.md`. No book change (the `.spec` `entry_*`/`match_*` contract is already documented; Rust now conforms — book sync is `.9`). **Active frontier → `RUST-PARITY.5.3`** (char-based indexing + cursor line/col).
- 2026-06-16: **RUST-PARITY.5.1 — retv-propagation BLOCKER fixed** (Rust engine code; done in a fresh session as the prior handoff recommended). After `->`/`=>`/REP child dispatch, the child's `return(expr)` value is now readable as `scalar(retv)` in the parent's attached code / `LE` / `E` (was undef → null/wrong output for nearly every grammar). `execute_rule` now returns the rule's own value via a per-invocation save/restore channel in `RuntimeContext`; both dispatch sites call `set_retv(child_retv)`; `return(...)` feeds the channel while still pushing the accumulator (baseline contract untouched); the dead `set_retv` is wired in. Latent `call(child)` rule-name-resolution bug also fixed (enables `assign(s(retv), call(child))`). 4 new integration tests (acode/OR, blind-call/AND, REP, `call`). `cargo test` = **186 passed / 0 failed** (182 baseline + 4); `cargo clippy` adds zero new `linkedspec-runtime` warnings. No book change (the `.spec` contract already specifies retv — Rust now conforms; Rust-parity book sync is `.9`). **Active frontier → `RUST-PARITY.5.2`** (separate `match_*` from `entry_*`).
- 2026-06-16: **RUST-PARITY.5 — SPLIT** (PNT rule 5; tree structuring, no code). PNT reached `RUST-PARITY.5`, found it too broad (six audit findings bundled), and split it into `.5.1` retv-propagation BLOCKER fix, `.5.2` match/entry split, `.5.3` char-based indexing, `.5.4` dedupe match arms + REP zero-progress guard, `.5.5` ~30 missing helpers. Sequenced retv-first. Confirmed Rust baseline green (`cargo test` = 182 tests, 0 failed) before splitting. Frontier → `.5.1`. **`.5.1` is correctness-critical engine surgery (engine.rs `execute_rule` + runtime.rs) — recommending a FRESH SESSION to implement it at signoff quality; repo is handoff-ready.**
- 2026-06-16: **SPEC-SPEC-SELFHOST.4 — TREE COMPLETE** — docs-sync finalization for the `specs/spec.spec` self-hosting rewrite (`.2`/`.3`, commit `4c667b7`). DEVELOPMENT_NOTES gained a status note superseding the MEDIUM-IMPACT.3.x "2/20" dual-path entries (rewrite = faithful 13-rule description of BootstrapSpec::Core; ratio 1.0000; cross-check harness now full 20/20 paragraph-count parity; self-hosts 13==13); mdBook `pipeline-overview` dual-path note now states the parity; extension-surface policy confirmed preserved verbatim in the new spec.spec header. Bootstrap stays oracle/primary; spec.spec = diagnostic side channel (Non-Goals). `mdbook build` exit 0; self-check exit 0. Tree moved to Completed. **Only `RUST-PARITY` (`.5`, retv BLOCKER) remains active.**
- 2026-06-16: **MDBOOK-VARIANT-AGNOSTIC.7 — TREE COMPLETE** — final whole-book cross-chapter consistency sweep over all 41 `src/**.md` pages: every page with Perl-API blocks carries a backend frame (`get-and-get-parser` uses one chapter-top frame per `.4` Option A); zero "Perl as the only backend" statements remain. One light touch: ebnf descriptor lead → "ask the reference (Perl) backend". `mdbook build` exit 0; self-check exit 0. The MDBOOK-VARIANT-AGNOSTIC tree (7 leaves) is complete and moved to Completed in `docs/TASK_TREE.md`; `ROADMAP_V2.md` Overall-roadmap row notes the milestone. The mdBook now documents the `.spec` file as the one universal contract with Perl as the reference backend across all sections. Active trees remaining: `SPEC-SPEC-SELFHOST.4`, `RUST-PARITY.5` (retv BLOCKER). **No documentation/book-sync tree active — PNT would next pick from `SPEC-SPEC-SELFHOST` or `RUST-PARITY`.**
- 2026-06-16: **MDBOOK-VARIANT-AGNOSTIC.6** — reframed the mdBook appendix (3 pages), the 6 corpus walkthroughs, and the development CI chapter as variant-agnostic (2 pages confirmed CLEAN). Appendix: `formal-grammar`/`runtime-semantics` cursor terminology (demoted `pos($input)`; relabeled `LinkedRE::or` + `generated_handler`), `backend-handoff` diagram `hashref AST`→`structured AST`. Corpus: one shared "`.spec` is the contract; the reference (Perl) backend runs it by spec name" driver frame; Perl-reference banners on the `plugin/` migration narrative and `pplugin`'s `.plg`/`PPlugin` subject. **Caught + fixed a drift:** the `ebnf` walkthrough showed a stale raw-Perl `semantic_annotation` action that no longer matched the migrated shipped helper-DSL rule (`specs/ebnf.spec:187`). `git diff --check` clean; `mdbook build` exit 0; self-check exit 0. Frontier → `.7` (final build + cross-chapter consistency + docs sync). Next: `MDBOOK-VARIANT-AGNOSTIC.7`.
- 2026-06-16: **MDBOOK-VARIANT-AGNOSTIC.5** — reframed the mdBook DSL + compiler/architecture chapters as variant-agnostic. Re-grepped all 14 in-scope pages (did NOT trust the `.1` CLEAN tags) and caught 3 leaks the audit mis-tagged CLEAN (`fluent-and-block-forms` `ControlFlow.pm`/`do { … }`, `source-boundary-helper-reference` BACKTRACK `pos($$STRING)=…`, `action-model-and-helper-surface` "byte offset"). Compiler 4 (`pipeline-overview`, `compiled-state-model`, `generated-handlers-and-dispatch`, `diagnostics`) + DSL 4 got backend-neutral frames demoting concrete Perl behind a "Perl reference backend" label; `architecture/owner-tree` got a "Perl reference implementation" banner; 5 pages confirmed CLEAN. Also reconciled the stale `docs/TASK_TREE.md` index row (`.2`→`.6`). `mdbook build` exit 0; self-check exit 0. Frontier → `.6` (appendix + 6 corpus walkthroughs). Next: `MDBOOK-VARIANT-AGNOSTIC.6`.
- 2026-06-16: **MDBOOK-VARIANT-AGNOSTIC.4** — reframed the 4 mdBook public-api chapters (`get-and-get-parser`, `descriptor-introspection`, `trace-api`, `plugin-registry`) with per-chapter backend frames (Option A — resolved the tree's Open Question): entry points/options, descriptor shape/fields, and the trace model are backend-neutral contracts while concrete signatures/encodings/constants/state vars are the Perl reference surface; `plugin-registry` got a deprecated/Perl-reference banner. `mdbook build` exit 0; self-check exit 0. Frontier → `.5` (DSL + compiler/architecture). Next: `MDBOOK-VARIANT-AGNOSTIC.5`.
- 2026-06-16: **MDBOOK-VARIANT-AGNOSTIC.3** — reframed the mdBook user-model chapters (`worked-spec-walkthrough`, `runtime-context-and-tracing`, `spec-files-and-rule-paragraphs`, `rule-modes-and-parse-modes`) to lead with the `.spec` contract and label runnable blocks as the Perl reference backend's surface; replaced the lone raw-host-language payload with helper DSL. Refined the `.1` audit: `rule-modes-and-parse-modes` was NOT fully CLEAN (real Perl-API "Public option shape" block) — remediated; `blind-calls-and-parser-orchestration` confirmed CLEAN. `mdbook build` exit 0; self-check exit 0. Frontier → `.4` (public-api chapters). Next: `MDBOOK-VARIANT-AGNOSTIC.4`.
- 2026-06-16: **MDBOOK-VARIANT-AGNOSTIC.2** — reframed all 5 mdBook overview pages (`index`, `what-is-linkedspec`, `design-rationale`, `documentation-layers`, `project-status`) so the `.spec` file is the **one universal contract** and Perl is the **reference backend** (Rust = second backend), aligned with `appendix/backend-handoff.md` + ADR 0006. Also fixed a phase drift in `project-status` (0–7 → 0–9; added Phase 8 multi-backend handoff + Phase 9 Rust variant). `mdbook build` exit 0; `scripts/check_memory_architecture.sh` exit 0. Frontier → `.3` (user-model chapters). Next: `MDBOOK-VARIANT-AGNOSTIC.3`.
- 2026-06-16: **MDBOOK-VARIANT-AGNOSTIC.1** — completed the variant-agnostic audit of the mdBook: deterministic Perl-leakage scan over all 41 `src/**.md` pages + targeted reads → full per-file catalog with a 3-way classification (CLEAN / REMEDIATE / LABEL) recorded in the task file. Found ~18 CLEAN, ~19 REMEDIATE, ~5 LABEL; the DSL `::`/`:AND` "hits" are `.spec` rule-labels, not Perl. Audit only — no book edits (remediation is `.2`–`.6`). Frontier → `.2` (overview chapters). Next: `MDBOOK-VARIANT-AGNOSTIC.2`.
- 2026-06-16: **TASK-TREE-INDEX-SYNC.1** — reconciled the stale `Active Task Trees` frontier column in `docs/TASK_TREE.md` against the authoritative per-tree `## Current Frontier` sections: `SPEC-SPEC-SELFHOST` `.2`→`.4`, `RUST-PARITY` `.1`→`.5` (`.4` superseded). One-leaf owning tree created+completed in the slice. Doc/tracker only — no code. Next: `MDBOOK-VARIANT-AGNOSTIC.1` (variant-agnostic audit).
- 2026-06-16: **SPEC-SPEC-SELFHOST.2+.3** — rewrote `specs/spec.spec` as a faithful self-hosting grammar. The old file returned `[[]]` (unusable); the new one mirrors the bootstrap `SPEC_ROOT` driver: `spec_file::` owns paragraph accumulators, dispatches to 12 per-token part rules, and starts a new paragraph at every `rule_header`. Compiles at ratio 1.0000 (blocked 0, compat 0). 19/19 shipped specs match the bootstrap oracle's exact rule count; `tools/cross_check_spec_parsers.pl` reports "ALL 20 specs match" (was 2/20); self-parses (13 paragraphs == 13 rules). New active tree `SPEC-SPEC-SELFHOST`; frontier: `.4` (docs sync). Stale Rust in-flight work left uncommitted (RUST-PARITY follow-on).
- 2026-06-16: **RUST-PARITY.3** — BACKTRACK/IBACKTRACK cursor save/restore in Rust runtime. `backtrack_stack` in RuntimeContext with push/pop. 4 new tests. 181/181 PASS. Active frontier: RUST-PARITY.4 (self-hosting).

- 2026-06-16: **RUST-PARITY.2** — Conditional flow in Rust runtime. if/elseif/else/endif, switch/case/default/endswitch with lazy evaluation. 12 new tests. 177/177 PASS.

- 2026-06-16: **RUST-PARITY.1** — Gap inventory complete. Rust vs Perl audit across `engine.rs` (1984 lines), `helpers.rs` (470 lines), compiler, parser, validation. 6 gap categories: (1) conditional flow, (2) BACKTRACK/IBACKTRACK, (3) self-hosting, (4) strict_syntax, (5) ~27 remaining helpers, (6) code-gen emitter. RUST-PARITY tree created (9 leaves). MDBOOK-VARIANT-AGNOSTIC tree created (7 leaves).
- 2026-06-15: **RUST-EDGE-SEMANTICS.4** — Tree COMPLETE (4 leaves). All 20 shipped specs compile. 166/166 PASS. RUST-EDGE-SEMANTICS tree closed and moved to Completed. **No active task trees — PNT idle.**
- 2026-06-15: **RUST-EDGE-SEMANTICS.3** — 7 new integration regression tests: edge-only dispatch end-to-end, mixed regex+edge, self-recursive compiler output, grouped targets, Child[N] entrypoint, lifecycle with edge-only, self-recursive edge-only. 166/166 PASS. Active PNT frontier: RUST-EDGE-SEMANTICS.4 (finalization).
- 2026-06-15: **RUST-EDGE-SEMANTICS.2** — Two-phase compiler rewrite. Phase 1: same-line regex→edge adjacency tracking via `element.line`. Phase 2: `build_dependency_regex_map` post-processing resolves edge-only entries from child rule regexes. `has_parent_regex` field on `AcodeEntry`. 8 new tests. Self-recursive rules resolved. Missing/OOB child regexes warn and skip. 159/159 PASS. clippy clean. Active PNT frontier: RUST-EDGE-SEMANTICS.3 (regression tests).
- 2026-06-15: **RUST-EDGE-SEMANTICS.1** — Full audit of Rust `->` edge dispatch vs Perl `dependency_regex_map` semantics. Documented: (a) compiler.rs lines 52-55 building regex_patterns from only explicit /regex/ entries, (b) compiler.rs lines 57-91 building AcodeEntry with `regex_idx = current_regex_idx - 1` (preceding parent regex), (c) engine.rs lines 77-81 building empty alternation for edge-only rules and lines 169-190 dispatching on parent-regex index, (d) 6-step Perl pipeline trace (BootstrapSpec→RuleIR→EmitContext→Compiler→HandlerVariantEmitter) + 5-row delta table. Root cause confirmed: Rust's "preceding regex" model vs Perl's child-regex alternation model. No code changes — audit/documentation only. Active PNT frontier: RUST-EDGE-SEMANTICS.2 (compiler rewrite).
- 2026-06-15: RGX-ADOPTION.1/.2 — rgx-core adopted as Rust regex engine. `regex` crate fully replaced. All 126 tests PASS with rgx backend. PCRE2-level regex features now available (look-around, backreferences, subroutine calls). Active PNT frontier: RGX-ADOPTION.3 (finalization).
- 2026-06-15: RGX-BUILD-REPRO.1 — rgx submodule pin bumped b771c7b→8763a0e. Upstream build fixes (BUILD-FLOW.1–.4) verified — cold-clone `make` succeeds. Tree COMPLETE and moved to Completed. No active task trees — PNT idle.
- 2026-06-15: RUST-FUNCTIONAL-PARITY.7–.10 — Tree COMPLETE (15 leaves). 80+ helpers. 126/126 PASS. Tree moved to Completed.
- 2026-06-15: Created RGX-BUILD-REPRO task tree — self-contained rgx build reproduction report for upstream. Active but blocked (`.1` pending upstream response). [RESOLVED — see above]
- 2026-06-15: RUST-FUNCTIONAL-PARITY.5.1 — Regex engine signoff-quality. Named capture extraction via Regex::capture_names(). 21 new tests. 117/117 PASS, zero warnings. Frontier → `.5.2` (lifecycle loop).
- 2026-06-15: RUST-FUNCTIONAL-PARITY.4.1 — Compiler signoff-quality. Added AcodeEntry/BcodeEntry structs (replaced opaque tuples). Fixed regex_idx tracking bug (was incorrectly incremented for action edges). Separated child_regex_idx from current-rule regex association. Fluent chains on blind edges stored as structured data. 6 new compiler tests. All 20 specs compile + serde roundtrip. 99/99 PASS, zero warnings. Frontier → `.5.1` (regex engine).
- 2026-06-15: RUST-FUNCTIONAL-PARITY.3.1 — Expression parser signoff-quality. Added Expr::FluentChain variant + FluentCall struct. Replaced broken fluent chain placeholder with recursive parse_fluent_chain(). Added boolean literal parsing (true/false with prefix-match guards). Added FluentChain interpreter support in engine.rs. Extended tests 9→51 (18 roundtrip, 5 error, 4 fluent chain, 5-level nesting). 93/93 PASS, zero warnings. Frontier → `.4.1` (compiler).
- 2026-06-15: RUST-FUNCTIONAL-PARITY.2.3 — rgx evaluation complete: API audit PASS, decision DEFER (rgx not on crates.io; cold-clone bootstrap needed). `.1.1`–`.2.3` all done. Frontier → `.3.1` (expression parser).
- 2026-06-14: PHASE9-RUST-VARIANT.10 — Finalization: tree COMPLETE (17 leaves). No active task trees — PNT idle.
- 2026-06-14: PHASE8-MULTI-BACKEND-HANDOFF.8 — Finalization: tree COMPLETE (8 leaves). Multi-backend specification surface complete.
- 2026-06-14: PLUGIN-ACTION-MIGRATION-STALE-REFERENCES.1 — Fixed 10 stale references. Tree COMPLETE (1 leaf).
- 2026-06-14: DOC-BOOK-SYNC.1 — Full mdBook + live docs audit complete. 19 gaps found (6 critical, 8 medium, 5 low) across 13 files.
- 2026-06-14: DOC-BOOK-SYNC.0 — Task tree creation for documentation/book sync. New active tree with 4 leaves.
- 2026-06-14: Completed LIFECYCLE-FAMILY-AUDIT.4 — Finalization: tree COMPLETE (4 leaves). All 7 lifecycle markers verified. No gaps found.
- 2026-06-14: Completed LIFECYCLE-FAMILY-AUDIT.1/.2 — inventory and gap analysis complete.
- 2026-06-14: Completed ROADMAP-V2-TRACKER-SYNC.5 — Finalization: tree COMPLETE (5 leaves). Roadmap, codebase, mdBook now synchronized. Tree moved to Completed. No active task trees remain — PNT idle.
- 2026-06-14: Completed ROADMAP-V2-TRACKER-SYNC.4 — audited and fixed mdBook drift. 7 stale claims fixed across 5 chapters. Active PNT frontier: ROADMAP-V2-TRACKER-SYNC.5.
- 2026-06-14: Completed ROADMAP-V2-TRACKER-SYNC.3 — updated all 4 live docs after tracker sync. Active PNT frontier: ROADMAP-V2-TRACKER-SYNC.4.
- 2026-06-14: Completed ROADMAP-V2-TRACKER-SYNC.2 — updated ROADMAP_V2.md and ROADMAP.md trackers. Method-like DSL migration track: mostly_done→done (COMPAT-ALIAS-RETIREMENT-V2, COMPAT-ALIAS-TEST-CLEANUP, FLUENT-BLOCK-EQUIVALENCE all completed). Overall roadmap: in_progress→mostly_done. Removed stale compat-alias and PLUGIN-ACTION-MIGRATION "remaining open" references. Active PNT frontier: ROADMAP-V2-TRACKER-SYNC.3.
- 2026-06-14: Completed ROADMAP-V2-TRACKER-SYNC.1 — audited current empirical state. All 20 specs compile at zero compatibility-surface rules. Identified 2 stale ROADMAP_V2.md tracker rows (Overall roadmap, Method-like DSL migration track). Active PNT frontier: ROADMAP-V2-TRACKER-SYNC.2.
- 2026-06-14: Completed COMPAT-ALIAS-RETIREMENT-V2.3 — tree COMPLETE (3 leaves). All 8 retirement-candidate aliases now removed from implementation. Short-term aliases already clean; medium-term legacy return helpers removed from all 7 files (~220 lines). No active task trees remain — PNT idle.
- 2026-06-14: Completed COMPAT-ALIAS-RETIREMENT-V2.1 — audit short-term aliases: implementation already clean across all 7 layers; USER_GUIDE.md updated (7 stale compatibility claims removed). Active PNT frontier: COMPAT-ALIAS-RETIREMENT-V2.2 (retire medium-term legacy return helpers).
- 2026-06-14: Completed FLUENT-BLOCK-EQUIVALENCE.2 — book documentation + regression verification. FLUENT-BLOCK-EQUIVALENCE tree COMPLETE (2 leaves). No active task trees remain — PNT idle.
- 2026-06-13: Completed MEDIUM-IMPACT.3.6 — MEDIUM-IMPACT tree closed out. Full regression verification.
- 2026-06-12: Completed MEDIUM-IMPACT.3.4.3 — cross-check re-run after AND ICODE routing fix. Cross-check: 1/20 match (was 10/20 before fix). AND fix correctly makes edges fire, but exposed MIXED_ACTIONS conflict: RuleIR routes AND I-block to acode_entries (acode_count=1) alongside bcode edge (bcode_count=1) → RuleIR returns MIXED_ACTIONS (invalid) → handler falls back to _default → empty @collect. New leaf .3.4.4 created to resolve MIXED_ACTIONS by keeping AND I-block separate from acode_entries and extending AND_BCODE handler. Frontier: MEDIUM-IMPACT.3.4.4.
- 2026-06-12: Completed MEDIUM-IMPACT.1.5 — JSON/AST diagnostic backend. `_emit_handler_json` serializes HandlerIR to valid JSON via JSON::PP. Backend threaded through SpecEntry.pm via `$BACKEND` package variable + `$deps->{backend}`. When `backend => 'json'`, `compile_spec_entry` stores JSON in `$info{handler_json}`; default `perl` path unchanged. 3/3 specs compile through default path. Active PNT frontier: `MEDIUM-IMPACT.3.4` (blocked), `MEDIUM-IMPACT.3.5` (pending). No remaining eligible leaves in `.1` container — `.1` container is done.
- 2026-06-12: Completed MEDIUM-IMPACT.1.4 — Backend emitter interface. `%BACKEND_EMITTERS` dispatch table with `perl` default backend. `_emit_handler($ir, %opts)` dispatches by backend name. All 10 SpecEntry.pm call sites use `_emit_handler`. 20/20 specs compile through backend dispatch pipeline. Active PNT frontier: `MEDIUM-IMPACT.1.5` (JSON/AST diagnostic backend), `MEDIUM-IMPACT.3.4` (blocked), `MEDIUM-IMPACT.3.5` (pending).
- 2026-06-12: Completed MEDIUM-IMPACT.1.3 — HandlerIR defined. 10 variant builders return IR hashrefs; `_emit_handler_perl()` dispatches 10 templates. SpecEntry.pm two-step flow. 452 lines dead code removed. 19/19 specs compile. Knowledge card `language-agnostic-backend-vision.md` captures future backend direction (Rust/Julia/Dart). Active PNT frontier: `MEDIUM-IMPACT.1.4` (backend emitter interface), `MEDIUM-IMPACT.3.4` (blocked), `MEDIUM-IMPACT.3.5` (pending).
- 2026-06-12: Completed MEDIUM-IMPACT.1.2 — HandlerVariantEmitter extraction (commit `d53578a`). All 10 variant builders extracted to `perl/LinkedSpec/HandlerVariantEmitter.pm` (554 lines). SpecEntry.pm delegates variant building. Zero behavior change. Old dead code remains in SpecEntry.pm (follow-up cleanup leaf). MEDIUM-IMPACT.2 container complete (4/4 fuzzing leaves, commits `764c2f3`–`7425c8f`). MEDIUM-IMPACT.3.3 cross-check complete (commit `e2ea174`). MEDIUM-IMPACT.3.4 blocked (commit `29b4d38`). Active PNT frontier: `MEDIUM-IMPACT.1.3` (define HandlerIR), `MEDIUM-IMPACT.3.4` (blocked), `MEDIUM-IMPACT.3.5` (pending).
- 2026-06-12 (hygiene): Backfilled commit hashes for 8 completed leaves, added 7 missing CHANGES.md entries, updated MEMORY.md latest_commit → d53578a, refreshed task-tree verification/commit log tables.
- 2026-06-12: Completed MEDIUM-IMPACT.3.3 — dual-path cross-check. Cross-check harness at `tools/cross_check_spec_parsers.pl`. 10/20 specs match (BNF, DT, Lispish, hlink_substitution, lib_reader, operators_try, pplugin, sdce, tkgui, verilog). 10/20 inflated candidate counts (ds_vhistory, ebnf, ifelse, portmap, regdef, simenv, spec.spec, tablegrep, tclite, vhdl). Root cause: AND handler lacks E-block, body_element:* over-matches. Zero hangs/crashes. Active PNT frontier: `MEDIUM-IMPACT.3.4` (fix cross-check gaps).
- 2026-06-12: Session bootstrap — task-tree restructure. MEDIUM-IMPACT.3 expanded 4→6 leaves: inserted dual-path cross-check (.3.3 compare, .3.4 fix gaps) before wiring primary (.3.5). Renumbered former .3.3/.3.4 → .3.5/.3.6. COMPAT-ALIAS-RETIREMENT tree completed and moved to Completed. MEMORY.md latest_commit fixed (d7294d0→4112374). Active PNT frontier: `MEDIUM-IMPACT.3.3` (dual-path cross-check: compare BootstrapSpec oracle vs spec.spec candidate across 20 specs).
- 2026-06-12: Completed MEDIUM-IMPACT.3.1 (post-commit bookkeeping). Task-tree administrative close-out: frontier updated (.3.2 now first eligible), commit log backfilled with `2526f2b` + hash-fix chain. Regression baseline: 1005 PASS. Active PNT frontier: `MEDIUM-IMPACT.3.2` (comment/blank-line skipping gap).
- 2026-06-12: Completed MEDIUM-IMPACT.3.1 — spec.spec accuracy audit. RuleIR.pm fix: per-regex ICODE→ACODE conversion for REP/OR rules ensures acode_count > 0. SpecEntry.pm fix: return→assignment transform for REP handlers so body_element loops correctly. spec.spec body_element made self-contained (9 inline alternatives, no bare helper calls). body_element now correctly returns array of matched body ASTs. Regression: 1005 PASS, spec.spec compile ratio 1.0000. Remaining gaps: body collection in rule_paragraph (AND handler lacks E-block support), comment/blank-line skipping (.3.2).
- 2026-06-11: Completed ACCUMULATOR-CONVENTION-AUDIT.3 and the ACCUMULATOR-CONVENTION-AUDIT tree (3/3 leaves) — synthesis + 6 recommendations. Key conclusion: the implicit-target `push(Child)` convention is healthy and serves a clear purpose. 95.5% of accumulator ops already use explicit targets; the 4 remaining convention-based uses are idiomatic. Recommendations: keep convention as-is, document in mdBook, teach `push_value` as preferred form. Tree moved to Completed. **No active task trees remain — PNT idle.**
- 2026-06-11: Completed ACCUMULATOR-CONVENTION-AUDIT.2 — per-spec accumulator usage categorization. 88 total accumulator ops across 19 specs: only 4 convention-based (4.5%) across 3 specs (regdef, tkgui, ebnf). 84 explicit-target (95.5%): 63 `push_value`, 19 fluent `.push()`, 2 `push_nonempty`. 10 specs use zero accumulators. Convention-based `push(Child)` is nearly extinct in practice. No code changes; phase0 1004 PASS baseline holds. Active PNT frontier: `ACCUMULATOR-CONVENTION-AUDIT.3` (synthesis + recommendations).
- 2026-06-11: Completed ACCUMULATOR-CONVENTION-AUDIT.1 — full ActionIR accumulator contract inventory. Audited all 9 accumulator-related contracts across `Contracts.pm` (call+dispatch + assignment+regex), `Scanner/PrimitiveBasicRules.pm` (push_child_call* scan rules), and `MethodLowering.pm` (push_value/push_nonempty lowering). Identified exactly 2 convention-based (implicit-target) helpers: `push(Child)` and `push(Child, idx)`. The other 7 require explicit target naming. Documented the `push(Child, arg)` integer-vs-word disambiguation edge case. Created `PLUGIN-ACTION-MIGRATION` task tree (proposed, parked per user request). No code changes; phase0 1004 PASS baseline holds. Active PNT frontier: `ACCUMULATOR-CONVENTION-AUDIT.2` (per-spec usage categorization).
- 2026-06-05: Completed KNOWLEDGE-MAP-DOC.4 and the KNOWLEDGE-MAP-DOC tree (4/4 leaves) — verified end-to-end with `bash tools/run_ci_local.sh` (exit 0): memory-arch self-check → Knowledge Map check (facts valid, ids unique, map in sync) → `perl -c` → phase0 **`Files=1, Tests=1004, Result: PASS`** → "local CI gate passed". The Knowledge Map retrieval layer is now adopted, seeded (6 fact cards), and gated. LinkedSpec's full memory+retrieval stack: layers A–D (`MEMORY_ARCHITECTURE.md`) + the question-keyed `KNOWLEDGE_MAP.md` over `docs/knowledge/` cards, enforced by the dual pre-commit gate + the local CI gate. `docs/TASK_TREE.md` Active table is now empty (tree moved to Completed). **No active task trees remain — PNT idle** (proposed `PLUGIN-ACTION-MIGRATION` stays `proposed`).
- 2026-06-05: Completed KNOWLEDGE-MAP-DOC.3 — wired the Knowledge Map gate. `.githooks/pre-commit` rewritten from `exec` (which would block any appended gate) into a dual gate: memory-arch self-check + KM regenerate/stage/`check_knowledge_map.sh`. `tools/run_ci_local.sh` now runs the KM check after the memory-arch check (+ `require_tracked_file` for the map + KM scripts). Reconciled the bootstrap pointers (AGENTS + CLAUDE/.cursorrules/copilot) to route to `KNOWLEDGE_MAP.md` and reverse the "not adopted" note; added `docs/decisions/0005` (adoption + archaeology boundary). Proved the gate bites (invalid card → exit 1; tampered map → exit 1; clean → 0). `perl -c` OK; phase0 1004 PASS baseline holds (no code changed). Active PNT frontier: `KNOWLEDGE-MAP-DOC.4` (full local-gate run + close).
- 2026-06-05: Completed KNOWLEDGE-MAP-DOC.2 — seeded 6 verified durable-fact cards under `docs/knowledge/` (ActionRewriter-removed, thin-façade, phase0 ActionIR-ready invariant, hosted-CI-disabled, spec.spec self-hosting, AND++LX hang gotcha). Each fact verified true against the repo before its `reverify` was written. Regenerated `KNOWLEDGE_MAP.md` → 6 facts / 29 question keys; `check_knowledge_map.sh` OK (fields valid, ids unique, map in sync). `perl -c perl/LinkedSpec.pm` OK; phase0 1004 PASS baseline holds (no code changed). Active PNT frontier: `KNOWLEDGE-MAP-DOC.3` (wire the KM gate into pre-commit + run_ci_local, reconcile bootstrap pointers, add ADR 0005).
- 2026-06-05: Completed KNOWLEDGE-MAP-DOC.1 — began adopting the Knowledge Map retrieval layer. Vendored the `knowledge-map/` bundle verbatim at the repo root (`diff -r` identical to source), ran `knowledge-map/install.sh` (created `docs/knowledge/`, generated the derived `KNOWLEDGE_MAP.md`; check reports in-sync). Wired README discovery (Knowledge Map bullet + path map) and reconciled the `MEMORY_ARCHITECTURE.md` §5 note from "not adopted" to "adopted". New active tree `KNOWLEDGE-MAP-DOC` (4 leaves). `perl -c perl/LinkedSpec.pm` OK; phase0 1004 PASS baseline holds (no code changed). Active PNT frontier: `KNOWLEDGE-MAP-DOC.2` (seed durable-fact cards).
- 2026-06-04: Completed MEMORY-ARCHITECTURE-DOC.5 and the MEMORY-ARCHITECTURE-DOC tree (5/5 leaves) — verified end-to-end with `bash tools/run_ci_local.sh` (exit 0): the memory-architecture self-check runs **first** (all invariants hold), then `perl -c`, then phase0 **`Files=1, Tests=1004, Result: PASS`**, then "local CI gate passed". The durable, harness-agnostic agent-memory architecture is now adopted and enforced: layer A (`MEMORY.md` bounded resume pointer) / B (`docs/tasks/` task-trees) / C (`docs/decisions/` records) / D (git), reachable from `AGENTS.md` + `README.md` + `MEMORY_ARCHITECTURE.md`, with E1–E4 gates (`scripts/check_memory_architecture.sh`, `.githooks/` via `core.hooksPath`, and the local CI gate). `docs/TASK_TREE.md` Active table is now empty (tree moved to Completed). **No active task trees remain — PNT idle** (proposed `PLUGIN-ACTION-MIGRATION` stays `proposed`).
- 2026-06-04: Completed MEMORY-ARCHITECTURE-DOC.4 — installed the `MEMORY_ARCHITECTURE.md` §9 enforcement: `scripts/check_memory_architecture.sh` (E2), `.githooks/pre-commit` + `.githooks/commit-msg` (E3, activated via `git config core.hooksPath .githooks`, with a linkedspec-adapted subject regex), the four bootstrap pointers `AGENTS.md`/`CLAUDE.md`/`.cursorrules`/`.github/copilot-instructions.md` (E1), and the self-check wired as the first gate in `tools/run_ci_local.sh` (E4). Proved all four gates bite (self-check fails over-cap; commit-msg rejects non-compliant subjects, accepts unit-id/Docs:/Merge/body-line-id) after fixing a POSIX-ERE `\b` bug. `bash -n` clean on all shell files; self-check exit 0; `perl -c` OK; phase0 1004 PASS baseline holds. Active PNT frontier: `MEMORY-ARCHITECTURE-DOC.5` (full local-gate run + close).
- 2026-06-04: Completed MEMORY-ARCHITECTURE-DOC.3 — demoted `MEMORY.md` from a 5204-line cumulative log to the 25-line bounded overwrite-only resume pointer (memory layer A, `MEMORY_ARCHITECTURE.md` §6 template); the prior history stays in git (`git show HEAD:MEMORY.md` confirms 5204 lines preserved). Reconciled `COMMIT.md` (the `### 4) MEMORY.md` section + workflow step 2 now define MEMORY.md as overwrite-only/capped, not cumulative) and the README ramp-up entry. `wc -l MEMORY.md` = 25 (≤ cap 60); `perl -c perl/LinkedSpec.pm` OK; phase0 1004 PASS baseline holds (no code changed). Active PNT frontier: `MEMORY-ARCHITECTURE-DOC.4` (install the enforcement kit: self-check + hooks + CI wiring + bootstrap pointers).
- 2026-06-04: Completed MEMORY-ARCHITECTURE-DOC.2 — created `docs/decisions/` (memory layer C) with `INDEX.md` and 4 dated ADR records: 0001 task-tree/commit/zero-drift doctrine (migrated out of harness-home-directory memory into the tracked repo so it survives a harness/model switch), 0002 all-target ActionIR-ready phase-0 invariant, 0003 raw-Perl-free `.spec` policy, 0004 hosted-CI-disabled / local-gate-is-source-of-truth. INDEX matches the 4 files. `perl -c perl/LinkedSpec.pm` OK; phase0 1004 PASS baseline holds (no code changed). Active PNT frontier: `MEMORY-ARCHITECTURE-DOC.3` (demote MEMORY.md to the bounded resume pointer + reconcile COMMIT.md).
- 2026-06-04: Completed MEMORY-ARCHITECTURE-DOC.1 — added the harness-agnostic durable-memory standard `MEMORY_ARCHITECTURE.md` at the repo root (verbatim from the cross-project source; the optional Knowledge Map layer is explicitly not adopted here) and wired discovery via `README.md` (Documentation Layers + ramp-up + path map) and `SESSION_BOOTSTRAP.md`. New active tree `MEMORY-ARCHITECTURE-DOC` (5 leaves) registered in `docs/TASK_TREE.md`. `perl -c perl/LinkedSpec.pm` OK; phase0 1004 PASS baseline holds (no code changed). Active PNT frontier: `MEMORY-ARCHITECTURE-DOC.2` (create `docs/decisions/` layer C + seed records).
- 2026-06-04: Completed DOC-CODEBASE-ALIGNMENT.5 and the DOC-CODEBASE-ALIGNMENT tree (5/5 leaves) — synced `ROADMAP.md`'s live-status tracker with `ROADMAP_V2.md`/reality. 13 stale rows flipped (Phases 1/1A/2/3/4/5/6/7 → `done`, Backbone refactor track + Item 3 → `done`, Method-like track → `mostly done`, Plugin track → `done`; Overall stays `in progress` with a refreshed focus note), each "Remaining focus" cell trimmed to a concise task-tree-referenced note. Annotated the Phase 1A planning section that `ActionRewriter.pm` was deleted in Phase 1. All 15 shared phase/track statuses now match `ROADMAP_V2.md`; every ROADMAP.md ActionRewriter mention is historical. `docs/TASK_TREE.md` Active table is now empty (tree moved to Completed). `perl -c perl/LinkedSpec.pm` OK; phase0 1004 PASS baseline holds (no code changed). **No active task trees remain — PNT idle** (proposed `PLUGIN-ACTION-MIGRATION` stays `proposed`, not PNT-eligible).
- 2026-06-04: Completed DOC-CODEBASE-ALIGNMENT.4 — reconciled `ROADMAP_V2.md`'s Phase 1A row so the deleted `ActionRewriter.pm` reads as historical (later deleted in Phase 1) rather than a live `LinkedSpec::OwnerDispatch` seam participant; the Phase 1 row's deletion record is untouched. While doing this, discovered `ROADMAP.md`'s status-tracker table is frozen at an early state (Phases 1, 1A, 2, 3, 4, 5, 6, 7, Backbone all stale vs `ROADMAP_V2.md`/reality) and split that broader reconciliation into new leaf `DOC-CODEBASE-ALIGNMENT.5`. `perl -c perl/LinkedSpec.pm` OK; phase0 1004 PASS baseline holds (no code changed). Active PNT frontier: `DOC-CODEBASE-ALIGNMENT.5` (sync ROADMAP.md tracker).
- 2026-06-04: Completed DOC-CODEBASE-ALIGNMENT.3 — scrubbed deleted-`ActionRewriter.pm` live claims from `USER_GUIDE.md` (7 references across two clusters). It had presented ActionRewriter as a retained compatibility-wrapper module; now framed as a forwarding shim deleted in `PHASE1-PARSER-CORE-ISOLATION.2`, with `RuleIR::EmitContext::rewrite_action_code_for_compat(...)` as the focused entrypoint. Dropped two misleading "ActionRewriter-facing" labels and corrected the `LinkedSpec::Deps`-removed note. `docs/linkedspec-book/` was already clean. `perl -c perl/LinkedSpec.pm` OK; phase0 1004 PASS baseline holds (no code changed). Active PNT frontier: `DOC-CODEBASE-ALIGNMENT.4` (reconcile ROADMAP.md / ROADMAP_V2.md).
- 2026-06-04: Completed DOC-CODEBASE-ALIGNMENT.2 — refreshed `ARCHITECTURE_STATE.md` so the deleted `perl/LinkedSpec/ActionRewriter.pm` is no longer presented as a live owner-dispatch participant (deleted in `PHASE1-PARSER-CORE-ISOLATION.2`; compat entrypoint now `RuleIR::EmitContext::rewrite_action_code_for_compat(...)`). Updated Last-refreshed date + refresh note, rewrote the "thinner now" bullet to "deleted entirely", dropped it from the seam-sharing list. `perl -c perl/LinkedSpec.pm` OK; phase0 1004 PASS baseline holds (no code changed). Active PNT frontier: `DOC-CODEBASE-ALIGNMENT.3` (USER_GUIDE.md + book scrub of the same stale claim).
- 2026-06-04: Completed DOC-CODEBASE-ALIGNMENT.1 — reconciled `docs/TASK_TREE.md` index with the real `docs/tasks/*.md` statuses found during session bootstrap. New active tree `DOC-CODEBASE-ALIGNMENT` registered (frontier `.1`); stale `PHASE7-SELF-HOSTED-SPEC` "active" row removed (file is `done`); Completed table gained `PHASE7-SELF-HOSTED-SPEC`, `PHASE1-PARSER-CORE-ISOLATION`, `METHOD-LIKE-DSL-MIGRATION`, `BOOK-DOCUMENTATION-SYNC`. Sub-drift fixed: `PHASE3/4/5` metadata `Status` `active`→`completed` to match their top nodes. All 13 trees now indexed under a status-matching table. Baseline (no code changed): phase0 Files=1, Tests=1004, PASS. Active PNT frontier: `DOC-CODEBASE-ALIGNMENT.2` (refresh `ARCHITECTURE_STATE.md` — remove deleted-`ActionRewriter.pm` live references).
- 2026-05-18: Updated ROADMAP_V2.md stale statuses — Phase 1 `mostly done` → `done` (PHASE1-PARSER-CORE-ISOLATION complete, 3/3 leaves). Backbone refactor track `mostly done` → `done` (all 3 items done). Removed stale Phase 1 reference from Method-like DSL migration track remaining-open list.
- 2026-05-18: Completed PHASE1-PARSER-CORE-ISOLATION.3 — evaluated rewrite_action_code_for_compat fallback in EmitContext.pm. Canonical pipeline handles s()/a()/h() correctly inside recognized contracts. The fallback only triggers for bare standalone s/a/h (malformed action code — no shipped .spec hits this path, no test exercises it). Fallback retained with inline documentation as a 20-line defensive compatibility measure. PHASE1-PARSER-CORE-ISOLATION tree COMPLETE (3 leaves). Full suite: 1004 PASS.
- 2026-05-18: Completed PHASE1-PARSER-CORE-ISOLATION.2 — removed ActionRewriter.pm forwarding shim. 118-line file deleted (59 generated forwarders + call_spec_handler_subst). 451 test references updated: 217 LinkedSpec::ActionRewriter:: → LinkedSpec::RuleIR::EmitContext::, 13 call_spec_handler_subst → rewrite_action_code_for_compat, 6 ActionRewriter-specific subtests removed. 10 broken require_avoids assertions fixed (EmitContext self-checks, plan mismatches, Deps check). Zero ActionRewriter references remain in codebase. Full suite: 1004 PASS. Active PNT frontier: PHASE1-PARSER-CORE-ISOLATION.3.
- 2026-05-17: Completed PHASE1-PARSER-CORE-ISOLATION.1 — full compile-path compatibility seam inventory. 4 seams identified: ActionRewriter.pm (118 lines, 59 forwarders, 0 non-test callers → REMOVABLE), rewrite_action_code_for_compat (s/h/a fallback → NEEDS EVALUATION), output format conversions (intentional adapters → KEEP), PluginBridge legacy functions (runtime, not compile path → OUT OF SCOPE). Active PNT frontier: PHASE1-PARSER-CORE-ISOLATION.2.
- 2026-05-17: Completed BOOK-DOCUMENTATION-SYNC (3 leaves) — synced book chapters with current codebase state. Updated plugin-registry.md stale deprecation status note ("may be narrowed or deprecated in a future phase" → DEPRECATED with PLUGIN-MODERNIZATION reference and retirement path). Updated owner-tree.md legacy plugin branch with individual DEPRECATED annotations on all 7 facade methods. Verified pplugin-spec-walkthrough.md ready_ratio note accurate, full 33-chapter book sweep found no additional stale references, USER_GUIDE files (10) clean. BOOK-DOCUMENTATION-SYNC tree COMPLETE (3 leaves).
- 2026-05-17: Completed PHASE7-SELF-HOSTED-SPEC.5 — defined extension-surface policy. spec.spec is the required change surface for .spec language evolution. Bootstrap grammar changes are exception-only with explicit justification. Policy documented in spec.spec header (extension-surface policy section, exception criteria, known bootstrapping gaps) and DEVELOPMENT_NOTES.md (formal policy section with rationale, exception path, and gap inventory). PHASE7-SELF-HOSTED-SPEC tree COMPLETE (5 leaves). Full suite: 1010 PASS.
- 2026-05-17: Completed PHASE7-SELF-HOSTED-SPEC.4 — fixed AND++LX parser hang and added regression coverage. The generated spec.spec parser hung on AND++LX: LX fires after AND+ loop completion but its execution triggers loop re-entry. Replaced `LX {return(...)}` with `E {return(...)}` in spec_file (E fires after rule completion without late-exit re-entry). Added 3 regression subtests (15 assertions): no-hang parse of 6 shipped .spec files, structural element recognition (minimal input + self-parse + lifecycle/blind-edge specs), and language_agnostic_ready_ratio lock at 1.0000. Known bootstrapping gap: no top-level comment/blank-line skip rule — workaround strips leading comments in tests. Full suite: 1010 PASS. Active PNT frontier: `PHASE7-SELF-HOSTED-SPEC.5`.
- 2026-05-17: Completed PHASE7-SELF-HOSTED-SPEC.3 — extended body_element:* from 5 to 9 regex-anchored alternatives covering all 12 body element recognition patterns from .1 inventory. Added: conditional markers (`-? word`), lifecycle markers (`(?:I|LS|LE|LX|E|EX|IT)\b`), fluent chains (`\.[ \t]*\w+`), word-based catch-all (`\w+[ \t]*[\(\{\.]`). 9 alternatives: regex, action edge, blind edge, split marker, conditional marker, lifecycle marker, fluent chain, word-based body code, plain code block. language_agnostic_ready_ratio 1.0000. Full suite: 1007 PASS. Active PNT frontier: `PHASE7-SELF-HOSTED-SPEC.4`.
- 2026-05-17: Completed PHASE7-SELF-HOSTED-SPEC.2 — authored spec.spec structural/syntactic rule paragraphs. 3 rules: spec_file::AND+ (top-level, edge-delegates to rule_paragraph), rule_paragraph:AND (own header regex /(\w+)[ \t]*(::|:)[ \t]*(\S*)[ \t]*(.*)/ + delegates to body_element), body_element:* (5 regex-anchored alternatives for regex tokens, action edges, blind edges, code blocks, split markers + 2 subdefs: body_edge_ast, body_blind_edge_ast). Compiles with language_agnostic_ready_ratio 1.0000. Full suite: 1007 PASS. Active PNT frontier: `PHASE7-SELF-HOSTED-SPEC.3`.
- 2026-05-17: Completed PHASE7-SELF-HOSTED-SPEC.1 — surveyed .spec language surface. 37 syntax categories across 9 sections: rule label forms (body/top), 11 rule mode variants (AND/OR/&/\|/+/*/? with bounded/unbounded/shorthand), 12 body element patterns, 7 lifecycle markers, 4 split/capture markers, ~40+ ActionIR helper functions, block structure, and authoring styles. Created leaves .2–.5. Active PNT frontier: `PHASE7-SELF-HOSTED-SPEC.2`.
- 2026-05-17: Completed PLUGIN-MODERNIZATION.5 — evaluated PPlugin/PluginBridge retirement feasibility. 36 .plg files with ~1,200+ actions remain — cannot retire yet. Documented 5-step retirement path: (1) migrate .plg actions to package owners, (2) retire PPlugin, (3) reduce/delete PluginBridge, (4) remove deprecated facade methods, (5) migrate FSMGen::AUTOLOAD. PluginRegistry can survive independently. PLUGIN-MODERNIZATION tree COMPLETE (5 leaves). Proposed follow-on: `PLUGIN-ACTION-MIGRATION`. No active trees — PNT idle.
- 2026-05-17: Completed PLUGIN-MODERNIZATION.4 — deprecated all 7 legacy plugin facade methods in LinkedSpec.pm (register_plugin, register_plugins, clear_registered_plugins, run_plugin, get_plugin, dispatch_plugin_autoload_name, AUTOLOAD). All marked DEPRECATED with retirement timeline tied to PLUGIN-MODERNIZATION.5. None removable yet: FSMGen::AUTOLOAD still depends on dispatch_plugin_autoload_name, test regression locks still exercise plugin infrastructure. Full suite: 1007 PASS. Active PNT frontier: `PLUGIN-MODERNIZATION.5`.
- 2026-05-17: Completed PLUGIN-MODERNIZATION.3 — de-scoped FSMGen.pm from LinkedSpec::get_plugin dependency. Replaced `\&LinkedSpec::get_plugin` default with `sub {}` no-op in getop_plugin_list (FSMGen.pm:68). Internal caller at line 3054 passes no explicit get_plugin but no .fsm files exist in repo to trigger +type=plugin syntax. Tests always pass explicit get_plugin. Updated 2 regression assertions. Full suite: 1007 PASS. Active PNT frontier: `PLUGIN-MODERNIZATION.4`.
- 2026-05-17: Completed PLUGIN-MODERNIZATION.2 — removed 2 dead .plg files: hutils.plg (thin HUtils:: passthroughs, zero references) and quick_sdf_hack.plg (dead qsdf_hack action, zero external callers). 36 .plg files remain. Full suite: 1007 PASS. Active PNT frontier: `PLUGIN-MODERNIZATION.3`.
- 2026-05-17: Completed PHASE6-DOCUMENTATION.5 — bridged book and USER_GUIDE cross-linking.
- 2026-05-17: Completed PHASE6-DOCUMENTATION.3 — documented Validation.pm (1,368-line DSL validation module). Expanded ARCHITECTURE_STATE.md section from 4 bullets to 30-line entry covering all 5 public entry points with error reporting path, context helpers, strict_syntax mode, and debugging guidance. Expanded book pipeline-overview.md Stage 2 from 4 lines to 16-line structured description of three validation layers. Active PNT frontier: `PHASE6-DOCUMENTATION.4`.
- 2026-05-17: Completed PHASE6-DOCUMENTATION.2 — documented LinkedRE.pm (56-line core regex utility). Added 11-line section to ARCHITECTURE_STATE.md covering or/oredRE API, position-tracking, seek vs consume, three consumers, and OwnerDispatch loading. Added 3-line explanatory note to book's generated-handlers-and-dispatch.md. Active PNT frontier: `PHASE6-DOCUMENTATION.3`.
- 2026-05-17: Completed PHASE6-DOCUMENTATION.1 — documentation surface inventory. Audited 30 mdBook chapters (all substantive, zero stubs), 10 USER_GUIDE files (14,611 lines of ActionIR lowering detail), 6 live docs, ARCHITECTURE_STATE.md, README.md. Found 7 doc gaps: LinkedRE.pm zero docs, Validation.pm thin (1 paragraph for 1,368 lines), public API incomplete (2/4 bands), book/USER_GUIDE silos, overview chapters thin, ActionIR lowering thin, per-spec walkthroughs incomplete. Created 7 follow-on leaves (.2–.8). Active PNT frontier: `PHASE6-DOCUMENTATION.2`.
- 2026-05-17: Completed PHASE3-EXECUTION-SEMANTICS.4 — verified BACKTRACK+parse_mode interaction already covered by .2 and cross-referenced in .3. PHASE3-EXECUTION-SEMANTICS tree COMPLETE (4 leaves). ROADMAP_V2.md Phase 3 → `done` (2026-05-17).
- 2026-05-17: Completed PHASE3-EXECUTION-SEMANTICS.3 — added "Forward-moving, non-backtracking model" subsection to rule-modes-and-parse-modes.md. States parser engine is forward-moving, no search tree, no partial-match unwind, no systemic backtracking. BACKTRACK/IBACKTRACK are sole rewind. 18-line prose addition.
- 2026-05-17: Completed PHASE3-EXECUTION-SEMANTICS.2 — added "BACKTRACK and IBACKTRACK: local cursor rewind" subsection (22 lines) to source-boundary-helper-reference.md. Covers concrete pos() rewinds, parent vs inner match distinction, local rewind vs systemic backtracking distinction, parse_mode interaction after rewind, and label-argument compatibility.
- 2026-05-17: Completed PHASE3-EXECUTION-SEMANTICS.1 — full parse-mode surface inventory. Audited 8 implementation components (LinkedRE.pm, Compiler.pm, SpecEntry.pm, CompilerState.pm, Runtime.pm, ActionIR/Contracts.pm, Scanner/LegacyRules.pm, CanonicalEvents/Core.pm), reviewed 5 book chapters, analyzed test coverage. Found 3 documentation gaps (BACKTRACK local-rewind contract, non-backtracking model statement, BACKTRACK+parse_mode interaction). Created follow-on leaves .2/.3/.4. Full suite: Files=1, Tests=1007, PASS.
- 2026-05-16: Completed PHASE2-DSL-FRONTEND.3 — added `strict_syntax` option to `validate_dsl_syntax` (Validation.pm lines 719-741). When set, undefined rule references and unused rules are promoted from warnings to hard errors. Default off (backwards compatible). Added 3 regression subtests (14 assertions). All 19 shipped specs fail strict mode as expected (every top rule is unreferenced by convention). PHASE2-DSL-FRONTEND tree now COMPLETE — all 6 leaves done. Full suite: Files=1, Tests=1007, PASS.
- 2026-05-16: Completed PHASE2-DSL-FRONTEND.5 — expanded extra-colon rule-label rejection regression coverage. The existing `_parse_rule_label_line` `invalid_mode` flag already rejected all extra-colon patterns; expanded regression test from 1 case to 14 edge cases (triple/quadruple colons, colon-space-colon variants, mode-suffix+colon, bounded-OR+colon, tab separators). Full suite: Files=1, Tests=1004, PASS.
- 2026-05-16: Completed PHASE2-DSL-FRONTEND.4 — closed the inside-block rule-start detection gap. Added explicit rejection in `validate_dsl_syntax` (Validation.pm lines 611-620): when `edge_scan_depth > 0`, a line matching the rule-label pattern triggers "Rule definition not allowed inside open block." Updated 2 existing tests, added 5 new regression subtests (bare rule label, top-rule label, mode-suffix labels, non-rule-label content acceptance, nested blocks). Verified zero shipped specs affected. Full suite: Files=1, Tests=1004, PASS.
- 2026-05-16: Completed PHASE2-DSL-FRONTEND.6 — verified and regression-locked full fluent-continuation surface recognition. Added 4 regression subtests (20 assertions) to `t/phase0_regression.t`: all 7 lifecycle markers with fluent chains (I/LS/LE/E/EX/IT/LX), deeply nested 5+ call chains with parens, quoted args with nested function calls, and empty-args fluent chain method calls. Full suite: Files=1, Tests=999, PASS.
- 2026-05-16: Completed PHASE2-DSL-FRONTEND.2 — closed the `validate_dsl_syntax` / `bootstrap_parse` construct-recognition drift gap. Compared `_looks_like_supported_rule_paragraph_member_line` acceptance patterns against all 14 bootstrap grammar start-token regexes. Added 6 regression subtests (20 assertions) to `t/phase0_regression.t`: zero-arg flow markers with blocks, method-empty blind-code-block fluent chains, lifecycle fluent-chains with attached if/elseif/else, three-target grouped action-edges, action-edges with regex-slot index plus fluent chain, and a full 19-shipped-specs validation regression lock. Full suite: Files=1, Tests=995, PASS.
- 2026-05-11: Broadened the shipped `.plg` source lock to reject direct `LinkedSpec::get_plugin(...)`, `LinkedSpec::run_plugin(...)`, and `LinkedSpec::dispatch_plugin_autoload_name(...)` plugin-bridge dispatch calls; renamed the plugin-corpus regression to name the package-owner destination.

## Recent Completed Slices
- Plugin/resource-resolution modernization: Broaden shipped `.plg` source lock against direct plugin-bridge dispatch helpers.
- Plugin/resource-resolution modernization: Lock shipped `.plg` files off direct `LinkedSpec::get_plugin(...)` lookups.
- Phase 1A / Backbone Item 3: Remove unused final descriptor projection helper from `Compiler.pm`.

## Doctrine
- 2026-05-17: Task-tree-ownership doctrine codified. All code changes must be task-tree tracked or task-tree owned before implementation. Recorded in book chapter `development/local-ci-and-regression.md`. Non-negotiable.

## Next Slice Direction
- Active PNT frontier: `SPEC-FORMAT-TERSE.1.3.2` — array function spelling disambiguation for terse mutation (`push(name,value)` vs existing child-call `push(...)`) before any engine code.
- ROADMAP_V2.md statuses synchronized with completed task trees. Phase 1, Backbone refactor track now `done`.
- PHASE1-PARSER-CORE-ISOLATION tree COMPLETE (3 leaves). ActionRewriter.pm removed, rewrite_action_code_for_compat evaluated and documented.
- PLUGIN-ACTION-MIGRATION tree **retired** — all 5 leaves done; 17 dead files deleted; 19 kept as legacy corpus. Plugin migration workstream closed.
- BOOK-DOCUMENTATION-SYNC tree COMPLETE (3 leaves).
- METHOD-LIKE-DSL-MIGRATION tree COMPLETE (5 leaves). All 19 shipped specs at zero compat. Cross-nesting parity deferred. Open items: compat alias retirement (policy defined). PLUGIN-ACTION-MIGRATION retired.
- 2026-05-17: Completed METHOD-LIKE-DSL-MIGRATION.5 — cross-nesting parity formally deferred, tree COMPLETE (5/5 leaves).
- 2026-05-17: Completed METHOD-LIKE-DSL-MIGRATION.4 — missing DSL features inventory. No concrete gaps in shipped corpus.
- 2026-05-17: Completed METHOD-LIKE-DSL-MIGRATION.3 — convention-based accumulator audit. 4 conventions audited, zero helpers needed.
- 2026-05-17: Completed METHOD-LIKE-DSL-MIGRATION.2 — legacy return-helper cleanup. 4 categories audited, zero migrations needed.
- 2026-05-17: Completed METHOD-LIKE-DSL-MIGRATION.1 — compatibility alias retirement policy audit. 11 aliases inventoried, policy in DEVELOPMENT_NOTES.md.
- PHASE7-SELF-HOSTED-SPEC tree COMPLETE (5 leaves).
- 2026-05-17: Completed PHASE7-SELF-HOSTED-SPEC.5 — defined extension-surface policy.
- 2026-05-17: Activated METHOD-LIKE-DSL-MIGRATION task tree — Method-like DSL migration track was `in progress` without task-tree ownership. Created tree with 5 leaves.
- 2026-05-16: Completed PHASE1A-CLOSE-OUT.1 — audited Phase 1A modularization. LinkedSpec.pm is a 286-line thin facade; 18 extracted modules use uniform OwnerDispatch; no monolith-era patterns remain.
- PHASE2-DSL-FRONTEND tree COMPLETE (all 6 leaves).
