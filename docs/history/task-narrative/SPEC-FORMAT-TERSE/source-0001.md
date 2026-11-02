# SPEC-FORMAT-TERSE: Evolve the .spec DSL toward a terser, fully-composable format

## Metadata

- Tree ID: `SPEC-FORMAT-TERSE`
- Status: `done` / `closed` (activated 2026-06-18 by user; ratified in ADR `0007`; closed by `.13.5`)
- Roadmap lane: `Overall roadmap — .spec language evolution (terse format)`
- Created: `2026-06-16`
- Last updated: `2026-07-08` (**`.13.5` DONE; parent task-tree status reconciled closed**).
  User directive 2026-07-08 activated the remaining `SPEC-FORMAT-TERSE` parked work after `.12` closed. `.13.5`
  closes the parent tree metadata after `.13.4` finished docs/KM/oracle/live-doc/task-tree drift alignment and
  left no current PNT-eligible `SPEC-FORMAT-TERSE` leaf. Prior `.13.3` landed Rust parser/runtime parity and the
  generated 97th oracle fixture for array-tree `walk_leaves`, `map_leaves`, and `reduce_leaves(initial)` receiver
  blocks while preserving hash-tree behavior. Prior `.13.2` landed the Perl reference implementation. Prior `.13.1`
  accepted array-tree receiver block traversal into the active roadmap and split it before implementation. Prior `.10.1`
  records the current direct hash-literal key contract: `{ key_expr : value_expr }` evaluates the key expression;
  bare keys are scalar reads, quoted keys are fixed fields, computed helper expressions may supply keys, and no
  parser/runtime behavior changed. Prior user directive 2026-07-08 reactivated the deferred `.12` hash-tree
  traversal backlog item. `.12.1` owns the
  spec-first split before any parser/runtime code, `.12.2` landed the Perl reference implementation for
  `walk_leaves`, `map_leaves`, and `reduce_leaves(initial)` receiver attached blocks, and `.12.3` landed Rust
  parser/runtime parity plus the generated oracle fixture. `.12.4` closed mdBook/Knowledge Map/live-doc/oracle
  no-drift alignment; `.12` has no remaining active leaf. Prior
  user directive 2026-07-07 reactivated the deferred
  `.14` trailing block-argument backlog item. `.14.1` defined
  the MVP contract before code, `.14.2` shipped the Perl reference helper-function form surface, and `.14.3` shipped Rust
  parser/runtime parity for `with(value) { ... }` / `with() { ... }` as immediate, non-closure trailing block
  arguments. `.14.4` shipped receiver-method form `.with() { ... }` on Perl and Rust: the receiver value is exposed as
  scoped `value`, the immediate block result can be terminal or feed later compatible receiver-family links, and
  explicit receiver `.with(value) { ... }` remains deferred/rejected. `.14.5` closed the final no-drift sweep for
  the trailing block-argument lane across mdBook, Knowledge Map, roadmap/live docs, task-tree state, and the
  generated 95-fixture oracle corpus. Prior
  **`.9.6` DONE; hash-literal colon association `.9` is closed**.
  Final no-drift scans across current specs, corpus sources, generated oracle inputs, tests, docs, mdBook, current
  Knowledge facts, and implementation support sites found no unclassified current hash-literal `=>` surface.
  Current specs, generated oracle inputs, active tests, mdBook examples, root docs, and current Knowledge facts now
  use `{ key : value }` for direct hash-literal association. Perl and Rust reject old `{ key => value }`
  as retired current ActionIR hash-literal syntax with diagnostics pointing to `{ key : value }`; blind-call edge
  `=>` syntax remains separate. Prior `.9.1` split
  the hash-literal `=>` migration surface before implementation: direct
  hash-literal associations are separate from blind-call edge `=>`, VHDL/source-language association syntax,
  historical docs/KM material, active tests/oracle fixtures, and parser/runtime support sites. Prior **`.8.6`
  DONE; helper-retirement no-drift closed.** Perl and Rust legacy helper support is hard-retired for declaration
  helpers/aliases, function-form `concat(...)`, `array_copy(...)`, `hash_copy(...)`, `push_value(...)`,
  `push_nonempty(...)`, and Rust wrapper aliases `a(...)` / `h(...)`; current `cat(...)`, `copy(...)`, `push(...)`,
  assignments, typed wrappers, `array(...)`, `hash(...)`, and receiver `.copy()` behavior keep parity.
  Source-method preservation keeps current `cat(...)` distinct from retired `concat(...)` after parser
  normalization, including attached control-flow reconstruction. Full phase0 passes 1022 tests. Prior `.8.2.4`
  closed the migration scans/gates before hard retirement: root authored
  specs/corpus are clean, generated corpus/test residues are tied to `.8.4` compatibility/retirement locks, oracle
  generation is stable over 93 fixtures, Rust `corpus_oracle` passes, and mdBook builds.
  `.8.2.3` previously migrated current-facing mdBook and Knowledge Map helper references to current terse
  spellings (`cat(...)`, `copy(...)`, assignment/operators, `push(...)`, and explicit `is_nonempty(...)` guards
  before `push(...)`). `.8.2.2.5` previously closed
  active-test/corpus helper residue scans and `.8.2.2` is done. Legacy helper-removal inventory is complete and `.8` is now
  split before behavior changes. Initial Perl probes showed `assign(...)` raw/unlowered, `scalar(...)` and
  `s(...)`/`a(...)`/`h(...)` unsupported, and still-successful Perl compatibility paths for
  `declare(...)`/`declare_s`/`declare_a`/`declare_h`, `concat(...)`, `array_copy(...)`, `hash_copy(...)`,
  `push_value(...)`, and `push_nonempty(...)`; `.8.3` retired those Perl paths. Initial Rust reads showed successful
  runtime arms for `declare`, `array_copy`, `hash_copy`, `concat`, `push_value`, `push_nonempty`, plus `array|a` and
  `hash|h` wrapper aliases; `.8.4` retired those Rust paths. `.8.2.1` migrated the current live EBNF
  `push_nonempty(...)` use by spelling the empty filter
  with `is_nonempty(...)`-guarded `push(...)` before hard retirement; generated EBNF oracle inputs and the EBNF
  walkthrough match the shipped spec with no expected-output drift. `.8.2.2.3` migrated generated oracle corpus
  fixture inputs with no expected-output drift; `.8.2.2.4` migrated/classified Perl phase0 helper strings; `.8.2.2.5`
  closed active-test/corpus residue scans and labelled Rust wrapper-alias residue. `.8.2.3` migrated current-facing
  mdBook/KM helper references and regenerated `KNOWLEDGE_MAP.md`; `.8.2.4` closed final `.8.2` no-drift scans and
  gates. `.8.3` hard-retired the Perl helper paths and `.8.4` hard-retired the Rust helper paths. Frontier ->
  `.8.5`/`.8.6` cleanup. Prior **`.15.5` DONE; colon scalar-slot removal closeout complete. Stale current-surface
  `:name` scans across shipped specs, generated corpus inputs, mdBook, tests, code, and Knowledge Map facts found
  no live authored `:name` support outside intentional retired-diagnostic tests/code and historical records. Two
  stale Knowledge fact-card references were corrected: the duck-typed assignment reverify command now uses bare
  `items` / `meta`, and the string-helper note now documents `substr(target, ...)` instead of the retired
  `substr(:target, ...)` target spelling. mdBook and the 93-fixture Rust oracle corpus remain in sync; frontier
  advances to `.8` for legacy helper-removal. Prior **`.15.4` DONE; Rust `Expr::ScalarSlot` hard-retired. Rust
  core no longer has the `Expr::ScalarSlot` AST/runtime path; a colon-prefixed value primary now emits
  `LINKEDSPEC_UNSUPPORTED_ACTIONIR_HELPER:colon_scalar_slot_use_bare_read` with a bare-read migration message.
  Runtime/source-emitter/integration fixtures were migrated to bare reads, generated and interpreted action-edge
  child-return paths keep scoped `retv` available when an attached block reads it, and shorthand aggregate wrappers
  `a(...)` / `h(...)` stay aligned with `array(...)` / `hash(...)`. The EBNF spec and generated oracle input
  fixtures now avoid the old same-name scalar/array `rule` collision by using `rule_header`, and the stale
  generated corpus case `terse_6_2_3_1_scalar_slot_shorthand` was renamed to
  `terse_15_4_bare_scalar_payload_readback`. Focused core/runtime/source-emitter/trace suites, oracle generation,
  Rust `corpus_oracle` over **93** fixtures, and full phase0 (`env PERL5LIB= perl -Iperl t/phase0_regression.t`,
  `1..1022`) PASS. Prior
  **`.15.3` DONE; Perl reference `:name` hard-retired. Perl ActionIR parsing/lowering, rewrite diagnostics, and
  EmitContext compatibility no longer accept colon scalar slots as successful reads or targets; a retired `:name`
  form now produces the unsupported helper sentinel
  `LINKEDSPEC_UNSUPPORTED_ACTIONIR_HELPER:colon_scalar_slot_use_bare_read`. The remaining current Perl fixture
  surface was migrated to bare reads, `scalar_slot_fallback` trace/declaration behavior is gone, and focused
  ActionIR/trace tests plus full phase0 (`env PERL5LIB= perl -Iperl t/phase0_regression.t`, `1..1022`) PASS.
  Follow-on fixes preserved current bare-read semantics for optional-scope `if`/`switch` forms, logical `or`/`and`
  conditions, `entry_text()` / `match_text()` direct value lowering outside user-function bodies, assignment-source
  passthrough, flow RHS lowering, and scalar-held hash `count_keys(...)`. Prior **`.15.2.4` DONE; current source/corpus/docs migration to bare value reads.
  Shipped specs, root corpus inputs, generated Rust oracle inputs, and mdBook examples now avoid live `:name`
  scalar-slot reads; regenerated 93-fixture oracle expected JSON and manifest are unchanged. Full phase0 PASS
  (`1..1022`), Rust corpus oracle PASS, mdBook PASS, diff check PASS, and the current-surface scalar-slot residue
  scan reports only expected rule-mode labels, regex syntax, and historical literal strings. Migration exposed and
  fixed signoff boundaries: parser-backed `set(...)` AST reconstruction, `split_tagged_records(...)` source-arg
  preservation, copy-return payload classification, initialized declare/type-memory tracking, Rust action-edge
  child-return publication order, descriptor scalar bare reads coexisting with same-name aggregate accumulators,
  and `array(retv)` vs `[retv]` constructor semantics. Prior **`.15.2.3` DONE; Rust parity and oracle alignment. Rust now treats bare
  switch subjects, numeric/comparison helper args, and `if(...)` conditions as value-position variable reads while
  keeping bare switch case labels literal tags (`switch(kind)` reads scalar `kind`; `case(foo)` matches `"foo"`,
  and `case(:foo)` still evaluates the scalar slot during the transition). Perl inline value `switch(...)` case
  labels were corrected to share the already-documented statement-switch literal-label rule. A regenerated
  93-fixture oracle also exposed stale self-hosted `specs/spec.spec` aggregate initialization after `.11`
  duck-typed assignment; `paragraphs` / `current` now initialize explicit aggregate targets so
  `push(rule_header, current)` mutates the intended working arrays. Focused Rust `.15.2.3` tests pass; Rust
  `corpus_oracle` passes over **93** fixtures; `perl -c` / `cargo fmt --check` pass; full phase0 reaches
  `ok 1022` with **1021 pass** and only the known baseline `not ok 796`. Frontier -> `.15.2.4` (source migration to bare,
  now output-preserving). Prior **`.15.2.2` DONE; Perl reference bare-read completion. ONE change to
  `ActionIR::FlowExpr::_lower_flow_composite_expr` (bare identifier at the `passthrough_no_call` site -> `$name`
  variable read, mirroring the `:name` branch) closed all three enumerated value-position gaps at once, because
  if/elseif/while + `num_*` + logical conditions delegate to it and the switch selector funnels through it too.
  A second change to `ActionIR::ControlFlow::_lower_switch_case_value_expr` keeps a bare switch-CASE LABEL a literal
  tag (hash-key-analogous exemption, ADR `0019`): `switch(kind)` reads variable `kind`, `case(foo)` matches literal
  `"foo"`. Discriminating probes: `switch(kind)`->`good`, `num_lt(n,5)`@n=10->`no`, `if(c)`@c=0->`F`, all == their
  `:name` forms (which still work; compat). FULL phase0 GREEN: reach `ok 1022`, 1021 pass, only pre-existing
  `not ok 796`; zero regressions. `:name` removal now unblocked once Rust parity (`.15.2.3`) lands and sources
  migrate (`.15.2.4`). ENV: run phase0 with `PERL5LIB=` cleared (stale `pgen/fx/perl` poisons subprocess tests).
  Prior **`.15.2.1` DONE; bare-vs-`:name` value-position inventory + engine seams locked
  before any engine code. Discriminating reference-engine probes confirm bare identifiers are NOT read as the
  bound variable in three value positions: the `switch(...)` selector, `num_*(...)` callee args, and
  `if(...)`/`while(...)`/logical conditions — `switch(:kind)`->`good` vs `switch(kind)`->`def`;
  `num_lt(:n,5)`@n=10->`no` vs `num_lt(n,5)`->`yes` (bare falls back to numeric 0); `if(:c)`@c=0->`F` vs
  `if(c)`->`T` (bare is a truthy bareword). Plain value positions (`return(name)`, assignment RHS, receiver) already
  read bare correctly. The load-bearing shipped-spec risk is rule-name collisions in `spec.spec`/`ebnf.spec`
  (ADR `0019`; `switch(kind)` and bare names matching rule/token names resolve as rule references). Central Perl
  seam: `ActionIR::FlowExpr::_lower_flow_composite_expr` (`perl/LinkedSpec/ActionIR/FlowExpr.pm:319`; the
  `:name`->`$name` branch at `:364` has NO bare-identifier counterpart) shared by if/elseif/while/logical and
  `num_*` args, plus the switch selector via `ActionIR::ControlFlow::_control_ast_value_source_expr`
  (`perl/LinkedSpec/ActionIR/ControlFlow.pm:332`). Rust seams: bare parses to `Expr::Variable`
  (`rust/linkedspec-core/src/expr.rs:1350`; selector test `:1788`), `:name` to `Expr::ScalarSlot` evaluated as
  `ctx.get_scalar` (`rust/linkedspec-runtime/src/engine.rs:3287`). Policy locked (value-position-is-variable,
  ADR `0019`): a bare identifier in a value-expression position is a variable/parameter read; rule references
  appear only in edge/dispatch positions (`-> Rule`, `call(Rule)`, `=> Rule`, all-bare `push(RuleA, AccumB)`).
  This composes with the `.11` type-at-assignment duck-typed model (already captured under `.11`): a bare read
  returns the runtime typed value whose type was fixed by the RHS shape at assignment. No engine behavior changed.
  Frontier -> `.15.2.2` (Perl bare-read completion). Prior **`.15.2` RE-SCOPED engine-first + recovery. A prior session's uncommitted,
  intermingled `.15.2/.15.3/.15.4/.8/.9` work (phase0 RED) is preserved on branch
  `recovery/terse-15-uncommitted-20260705`; `main` is clean at `104088e5`. Attempting the source-first `.15.2`
  migration proved it is NOT output-preserving: bare reads are not honored in every value position at `104088e5`
  (`switch(:kind)`->`'good'` vs `switch(kind)`->`'def'`; rule-name collisions in `spec.spec`/`ebnf.spec`), so per
  the user directive that `:name` shall NOT be supported, `.15` is re-sequenced ENGINE-FIRST: `.15.2.1` design,
  `.15.2.2` Perl bare-read completion, `.15.2.3` Rust parity, `.15.2.4` source migration, then `.15.3`/`.15.4`
  remove `:name` with no compat, then `.15.5` closeout. Frontier is `.15.2.1`. See ADR `0019` + KM card
  `terse-bare-read-value-position-gap`. Prior **`.15.1` DONE; colon scalar-slot removal audit split the work
  before code. Prior **`.11.5` DONE; duck-typed assignment alignment closed. Roadmap/live docs and
  current Knowledge Map facts now describe direct RHS shapes as typed value binding, not declaration or
  storage-class inference; historical target-kind inference cards are explicitly marked superseded. The Rust
  oracle corpus remains **92** fixtures and mdBook assignment/container guidance already matches `.11`. Frontier
  moves to `.15` for removing `:name` scalar-slot syntax from the future duck-typed surface. Prior **`.11.4` DONE; nested mixed value-path assignment landed. Perl and Rust now mutate
  scalar-held array/hash payload trees through direct lvalue paths such as `payload["items"][0]["name"] = value`
  in statement and expression-valued contexts. Intermediate containers must already exist with the required shape;
  final hash keys may be created; final array indexes may replace or append exactly at len; gaps/missing/wrong
  paths return `undef`/`null` and do not mutate. Oracle corpus is **92** fixtures and includes
  `terse_11_4_nested_mixed_value_path_assignment`. Frontier moves to `.11.5` for final duck-typed assignment
  closeout/alignment. Prior **`.11.3` DONE; Rust duck-typed assignment parity landed. Rust now scalar-binds
  evaluated RHS typed values for bare `name = value`, `set(name, value)`, and `=(name, value)`, including direct
  array/hash RHS shapes; explicit `array(...)` / `hash(...)` mutation targets remain aggregate storage, and
  scalar-held typed views/copy/receiver/helper reads use guarded snapshots. Oracle corpus is regenerated to **91**
  fixtures. Frontier moves to `.11.4` for nested mixed value paths. Prior **`.11.2` DONE; Perl reference
  duck-typed assignment landed. Bare Perl assignment targets now bind typed RHS values through one scalar value
  slot (`name = []` -> `$name = []`, `set(name, { key => value })` -> `$name = {$key => $value}`),
  expression-valued assignment returns the scalar-held value, generated-source collection records `my $name`
  rather than `my @name` / `my %name` solely from RHS shape, and scalar-bound `array(name)` / `hash(name)` views
  read guarded snapshots. Explicit `array(...)` / `hash(...)` mutation targets still use aggregate storage. Prior
  **`.11.1` DONE; duck-typed assignment work split after mandatory bootstrap,
  mdBook/code/Knowledge Map inventory, and focused toolbox probes. Current Perl/Rust still implement direct
  RHS-shape target-kind inference (`x = []` -> array storage, `x = {}` -> hash storage), which conflicts with the
  `.11` duck-typed value-binding contract. The frontier is `.11.2` for the Perl reference change, followed by
  `.11.3` Rust parity, `.11.4` nested mixed paths, and `.11.5` docs/KM/corpus closeout. Prior **`.7.4` DONE; type-method no-drift sweep closed. Current roadmap, task-tree index,
  mdBook helper/reference summaries, and Knowledge Map facts now agree that string/scalar, array/list, hash, and
  number receiver families are the supported type-method surface; array numeric reducers are terminal array/list
  receiver methods, not scalar number receiver links; mutation/lifecycle/control/child-dispatch/parser-state/
  declaration/compatibility helpers remain explicit unless a future leaf defines type-correct receiver semantics.
  No Perl/Rust behavior change was needed. The `.7` lane is closed. Prior **`.7.3` DONE; array/list numeric reducer receiver methods landed as terminal
  Perl/Rust links. `sum`, `avg`, `median`, `range`, `min`, and `max` now work from array receivers, including after
  array-returning links such as `sorted().take(...)` and Perl internal pure array-pipeline links such as `uniq()`.
  Invalid reducer continuations return `undef`/`null`; hash and number mutation/ambiguous boundaries remain
  explicit. Phase0 passes with **1021** tests, the Rust oracle corpus passes **74 fixtures**, mdBook examples and
  helper catalog entries are in sync, and frontier moves to `.7.4` for the final type-method no-drift sweep.
  Prior **`.7.2` DONE; string/scalar method backfill closed with no implementation
  change. Focused Perl probes confirm `"abcdef".substr(1, 3).uppercase()` and
  `uppercase(substr("abcdef", 1, 3))` both return `BCD` with `ready=1`, `fallback=0`, `raw=0`, and
  `unresolved=0`; focused Rust `terse_2_3_5_3` tests pass. mdBook already documents method/helper equivalence
  and the string receiver family (`trim`, `lowercase`, `uppercase`, `replace_substr`, `rm_prefix`, `rm_suffix`,
  `substr`, `concat`/`cat`, `coalesce_nonempty`, `split` bridge, and terminals), so no parser/runtime/book
  behavior change is required. Frontier moved to `.7.3` for array/list, hash, and number receiver backfill audit.
  Prior **`.7.1` DONE; supported type-method surface inventory recorded before
  implementation. The existing receiver families are string/scalar, array/list, hash, and number; boolean/flow
  results are terminal today; expression-valued blocks and user-function returns dispatch by yielded runtime type
  into those same families. Existing Perl/Rust method classifiers already include string `substr()`, so `.7.2`
  becomes a verification/backfill leaf for string/scalar methods rather than a blind implementation assumption.
  Mutation, lifecycle, parser-state/capture/input/mark, child-dispatch, declaration, and control-flow helpers stay
  function/statement/lifecycle surfaces unless a future leaf defines type-correct receiver semantics. mdBook,
  Knowledge Map, roadmap, and live docs record the boundary; frontier moves to `.7.2`. Prior **`.6.4` DONE; declaration-helper post-migration compatibility policy decided.
  `declare(...)` and declaration aliases were kept as legacy compatibility for existing specs at that historical
  leaf, but new shipped specs, public examples, and current corpus examples had to use terse auto-existing variables
  and assignment/mutation forms. `SPEC-FORMAT-TERSE.8` later superseded that retention policy and hard-retired the
  helpers. Declaration retirement `.6` is closed; frontier moves to `.7.1` for the supported-type method audit.
  Prior **`.6.3` DONE; public docs and checked-in corpus/example sweep closed. Current-facing
  mdBook examples and root corpus specs no longer teach `declare(...)` or old helper spellings; generated Rust
  oracle fixtures use canonical terse helpers where old names were incidental, while residual old spellings are
  isolated to compatibility/reference fixtures or legacy-reference pages. Added KM coverage for the
  `merge_hash(copy(hash(base)), overlay)` boundary. mdBook builds, focused doc/corpus scans pass, root corpus
  probes pass, oracle regeneration remains at **73 fixtures** with no expected-output drift, and Rust
  `corpus_oracle` passes. Frontier moves to `.6.4` for the post-migration compatibility-support policy. Prior
  **`.6.2.4` DONE; final shipped-spec terse-surface verification and no-drift
  inventory pass. All 21 shipped `specs/*.spec` descriptor-compile with `perl -Iperl`; shipped-spec scans are clean
  for `scalar(...)`, `assign(...)`, `declare(...)`, and the old helper spellings; mdBook has no `scalar(...)` /
  `assign(...)` hits and builds; phase0 is **1020 green**; regenerated Rust oracle corpus remains stable at
  **73 fixtures** and passes. Broader checked-in corpus/book `declare(...)` and old-helper reference hits are now
  explicitly carried by `.6.3`. Prior
  **`.6.2.3.2` DONE; authored/current `.spec` files no longer use or support `scalar(...)` scalar-slot reads or
  `assign(...)` assignment aliases. Scalar slots use `:name`, assignments use `LHS = RHS`/`set(...)`, initialized
  bare identifiers remember scalar/array/hash kind, active spec/corpus scans are clean, mdBook is clean, and
  phase0 is **1020 green**. Prior **`.6.2.3.1` DONE; the scalar-slot shorthand `:name` is accepted in
  scalar value positions and scalar mutation targets on Perl/Rust, with direct shape literals still inferring
  aggregate targets unless the scalar boundary is explicit through `:name`. Focused shorthand tests, phase0
  (**1019 green**), and the Rust corpus oracle (**73 fixtures**) pass. Prior **`.6.2.2` DONE; shipped
  specs no longer use active old helper spellings `assign(...)`, `push_value(...)`, `array_copy(...)`,
  `hash_copy(...)`, or `concat(...)`. The migration uses the landed terse aliases `set(...)`, `push(...)`,
  `copy(...)`, and `cat(...)`, with explicit `array(...)` push targets where needed to avoid all-bare child-call
  ambiguity. `portmap.spec` also drops redundant standalone separators after flow markers. The user's broader
  type-method-surface directive is tracked as future lane `.7`, starting with an inventory before any code.
  Prior **`.3.3.4` DONE; expression-valued assignment closure is locked across
  scalar, direct-shape aggregate, array append, hash-index mutation, user-function body, receiver-chain,
  and legacy `assign(...)` compatibility spellings. Public mdBook examples now prefer `set(...)` or operator
  assignment forms while retaining `assign(...)` only as a documented legacy alias. Oracle corpus reaches
  **62 fixtures** and phase0 reaches **1015 green**; no concrete PNT-eligible `SPEC-FORMAT-TERSE` leaf remained
  immediately after that closure, with future variant leaves deferred/blocked by explicit roadmap decisions.
  Prior **`.3.3.2` DONE; aggregate assignment expression values after target-kind
  inference now ship on Perl/Rust; frontier moves to `.3.3.3` array append/hash-index mutation expression
  values**.
  Prior **`.4.1` DONE; user-defined function MVP contract/inventory locked before code** —
  the accepted contract is now explicit: top-level `fn name(args) { ... }`, exact arity, eager argument
  evaluation, fresh function-local parameter/work-variable scope, pure value/block bodies, final-expression or
  `return(expr)` result, standalone call result discard, and no implicit caller-state capture, recursion,
  closures, lambdas, currying, host-code escape, or side-effect helpers in the MVP. Function names share the
  helper call surface, so definitions must not collide with built-in helpers, control/lifecycle keywords, rule
  labels, reserved runtime symbols, or another function definition. The inventory found a broad implementation
  surface across `specs/spec.spec`, function-definition extraction/registry, Perl ActionIR user-call lowering,
  Rust `SpecFile`/`CompiledSpec`/runtime function registry, oracle fixtures, phase0, mdBook, and Knowledge Map;
  `.4.2` and `.4.3` are split into smaller implementation leaves. Rust now resolves registered function calls
  before helper fallback, runs them in fresh function-local stores, feeds compatible receiver-dot chains from
  returned values, discards standalone call results, and passes a Perl/Rust oracle fixture. The finalized MVP
  ledger keeps only explicit-paren, braced `fn` definitions in scope and defers alternate spellings, optional
  zero-arg parentheses, brace-less bodies, caller-state-mutating functions, recursion support, closures/lambdas/
  currying, and function namespaces. Arithmetic symbol callees `+(...)`, `-(...)`, `*(...)`, `/(...)`, and
  `%(...)` now parse and dispatch to the existing `num_*` helpers on Perl and Rust, with slash-call lookahead
  preserving slash regex literals such as `/(\))/` and `/(?<!\\)}/`. The comparison migration is split behind
  an explicit `str_*` string bridge before numeric comparison word aliases and symbol callees. The bridge
  contract and implementation are now locked: `str_eq`, `str_ne`, `str_gt`, `str_ge`, `str_lt`, and `str_le`
  ship as explicit lexical string comparisons on Perl and Rust. Bare comparison words `eq`, `ne`, `gt`, `ge`,
  `lt`, and `le` now map to numeric `num_*` comparison helpers after `.3.2.3.3`; comparison symbol callees
  `==`, `!=`, `>`, `>=`, `<`, and `<=` now map to the same family after `.3.2.3.4`.
  Prior **`.3.2.1` DONE; numeric word aliases landed** — function-form `add(...)`,
  `sub(...)`, `mul(...)`, `div(...)`, `mod(...)`, `abs(...)`, `floor(...)`, `ceil(...)`, `round(...)`,
  `min(...)`, `max(...)`, `clamp(...)`, `sum(...)`, `avg(...)`, `median(...)`, and `range(...)` now map to the
  existing `num_*` helper family on Perl and Rust. Existing `num_*` spellings remain accepted. Bare comparison
  words such as `gt(...)` remain string comparisons; numeric comparison policy stays isolated behind
  `.3.2.3`. Prior **`.3.2`
  SPLIT/OWNED; arithmetic call surface split before code** — Round 3 keeps one `callee(args)` call grammar with
  no `(op a, b)` Lisp-prefix surface. Prior **`.3.1`
  DONE; edge-syntax contract confirmed/locked** — `->` action edges and `=>` blind-call edges stay as-is;
  grouped action-edge targets require a shared `{ ... }` block, and the block-less `-> A | B` form stays
  invalid. Existing phase0 locks already cover parse expansion, validation acceptance, rejection diagnostics,
  and three-target grouping; the mdBook now states the invalid boundary explicitly. Prior **`.5.0`
  DONE; future variant parity ownership/inventory complete** — current implemented backends are Perl
  reference + Rust; later ADR `0021` schedules future parity rollout as Dart, then Julia, then Lua under
  `FUTURE-PARITY-BACKLOG`. Prior **`.2.3.5.5` DONE; receiver-chain family
  complete** — expression-valued
  blocks now continue through compatible receiver-dot value chains by the runtime type they yield, with no
  block-only helper semantics. Locked examples cover array, early-return array, string-to-array, hash-to-array,
  and number chains:
  `{ [3, 1, 2] }.sorted().join_values(",")`,
  `{ return(["x", "y"]); ["bad"] }.join_values("|")`,
  `{ set(raw, " a-b "); raw }.trim().split("-").count()`,
  `{ { "b" => 2, "a" => 1 } }.sorted_keys().join_values(",")`, and
  `{ 3.5 }.floor().add(2)`. The Perl audit found string/hash/number block receivers already using existing
  family normalization, but array-yielding blocks needed narrow exit-shape recognition before array helpers
  such as `sorted(...)` could lower. Rust needed parser follow-through after block/hash/array primaries; its
  runtime already evaluates non-variable fluent receivers through `eval_expr`. Phase0 is **1001 green** and
  the oracle corpus is **52 fixtures**. Prior **`.2.3.5.6` DONE** — typed wrapper quoted-name
  boundaries are locked on Perl/Rust and in the variant-neutral mdBook. `array(foo)` / `a(foo)` and
  `hash(bar)` / `h(bar)` remain explicit typed working-variable reads, but quoted arguments are not aliases:
  `array("foo")` / `array('foo')` are literal array-constructor payloads, and
  `hash("bar", value)` / `hash('bar', value)` are fixed-key hash-constructor payloads. The terse constructor
  forms are direct shapes (`[...]` and `{...}`), which the book now prefers for new examples. Runtime
  scalar-indirect lookup and postfix forms such as `foo.array()` are explicitly not pursued. The oracle corpus
  is **51 fixtures** and phase0 is **1000 green**. Prior **`.2.3.5.4` DONE** — number receiver-dot value chains
  now run on Perl and Rust. Terse receiver methods (`abs`, `floor`, `ceil`, `round`, `add`, `sub`, `mul`,
  `div`, `mod`, `min`, `max`, `clamp`, and comparison terminals `eq`/`ne`/`gt`/`ge`/`lt`/`le`) map to the
  existing `num_*` helper family with the receiver as the first argument. Numeric literal receivers parse on
  Rust, Perl skips decimal dots while splitting receiver chains, value-form numeric comparisons now lower on
  Perl, and Rust `num_add`/`num_mul` consume all supplied operands. Prior **`.2.3.5.3` DONE** — string/scalar receiver-dot value
  chains now run on Perl and Rust. String-returning helpers compose from scalar or string-literal receivers,
  `split(delim)` explicitly bridges into the array receiver-chain family, scalar terminals end the chain, and
  value-form `split(...)` / `substr(...)` are portable helper payloads. Rust now parses fluent chains after
  string literals. Prior **`.2.3.5.2` DONE** —
  hash receiver-dot value chains now run on Perl and Rust. Pure hash helpers can be chained from hash
  receivers, `sorted_keys`/`sorted_values` bridge into array receiver chains, and named `set_key(meta, ...)` /
  `meta[key] = value` remain the mutating forms; receiver-dot `scalaref(key)` was later retired and replaced by
  named working-hash reads such as `scalar(hash(meta), key)`. `.3.3.3` later added hash-index expression values.
  Rust `merge_hash` now matches the documented
  later-argument override contract. Prior
  **`.2.3.5.1` DONE** — array receiver-dot value chains
  now run on Perl and Rust. Pure array helpers can be chained from array receivers, terminal helpers return
  their documented scalar/number/string/boolean values, and `.1.6` receiver-dot end mutations remain
  statement-only. Prior **`.2.3.5`
  DONE/SPLIT** — return-type method chaining is specified before code. Statement-only receiver-dot array
  mutations from `.1.6` remain stable, while value-returning receiver-dot chains are split into array, hash,
  string, and number implementation leaves with explicit backend parity/oracle requirements. Prior
  **`.2.3.4.2` DONE** — Perl inline-composite
  value-control lowering landed. Inline `if(...)` and `switch(...)` now return the selected branch value in `return(...)`,
  assignment RHS, and fluent `.return(...)` value slots, including nested helper predicates/branches and
  expression-valued block branches. The new
  `terse_2_3_4_2_inline_if_value_control` and
  `terse_2_3_4_2_inline_switch_value_control` oracle fixtures bring the Rust corpus to **46 fixtures**. The
  contract asserts payload values, not incidental legacy/action-edge tag strings. Prior **`.2.3.4.1` DONE** —
  Rust helper-context bare aggregate argument parity landed. Bare working-variable names now become hash or
  array snapshots only in helper argument slots whose callee contract already implies that aggregate kind, such
  as `merge_hash(hash_copy(base), overlay)` and `count(drop_front(sorted(items)))`, while ordinary bare
  variables still read scalar state. The `.2.3.4.1` oracle fixtures brought the Rust corpus to **44 fixtures**.
  Prior **`.2.3.4` DONE/SPLIT** — the full-composability audit added a green deep pure-helper
  oracle fixture and split `.2.3.4.1` plus `.2.3.4.2` before code. `.2.3.4.2` owns Perl reference
  inline-composite value control lowering for `return(if(...))` / `return(switch(...))`; receiver-dot
  value-returning/chained methods remain `.2.3.5`. Prior **`.2.3.3.3.3.1` DONE** — Rust now
  matches the Perl-reference `tclite` minimal oracle cases. Bare default rules compile as zero-min
  repeated-choice loops, child-rule `I.return(...)` exits before local entry-regex re-matching, and
  `tools/gen_oracle_corpus.pl` restored `tclite_command_subst` (`[]`) plus `tclite_double_quote` (`""`) into
  the committed green corpus. Rust `corpus_oracle` passes with 41 fixtures. Prior **`.2.3.3.3.3` DONE/SPLIT** — retrying
  `tclite` after Rust fluent parity proved the remaining divergence was not a fluent-continuation blocker.
  Prior **`.2.3.3.3.2` DONE** — Rust
  action-edge explicit/flow fluent chains now execute beyond the no-arg subset. Multiline dotted continuations
  after `-> child` stay attached to the preceding action edge, `.push(target)` and `.push(child,target)`
  dispatch the child and append its return value to the explicit target accumulator, statement-control markers
  gate later fluent calls, `.say(...)` and other helper calls run through normal expression evaluation, and
  `.return_undef()` keeps the action-edge return path. Prior **`.2.3.3.3.1` DONE** — Rust compact
  lifecycle/body receiver chains such as
  `I.return(...)` and `I.declare(...).return(...)` now normalize to executable lifecycle `CodeBlock` statements
  on multiline body and regex-first header-line inline paths. Focused parser, compiler, and runtime locks prove
  return-channel behavior, ordered declaration/mutation chains, and no surviving standalone `FluentChain` on
  accepted lifecycle-marker surfaces. Prior **`.2.3.3.3` SPLIT/DONE** — audit showed remaining Rust fluent
  parity is not one signoff slice. Compact lifecycle/body receiver chains were the first child; action-edge
  explicit/flow chains were separate; `tclite` default-mode repetition re-enable stays a follow-up audit after
  those fluent surfaces land. Prior **`.2.3.3.2` DONE** — Rust now
  parses attached fluent
  `.when(cond) { ... }` block payloads on action-edge and lifecycle-marker surfaces by normalizing them to the
  existing attached `when/otherwise` statement-block model. Dotted `.otherwise { ... }` and no-dot
  `otherwise { ... }` fallback tails execute on both surfaces, including multiline `}.otherwise {` placement.
  Prior **`.2.3.3.1` DONE** — Rust now preserves and executes action-edge fluent no-arg `.push`,
  `.return(expr)`, and `.return_undef` continuations. The `tclite` oracle remains deferred because the
  implementation exposed separate blockers: compact lifecycle/body fluent forms (now closed by `.2.3.3.3.1`)
  and shipped recursive default rules still depend on default-mode repetition parity. Prior **`.2.3.3`
  SPLIT/OWNED** — Rust fluent parity is
  not one implementation seam. Action-edge no-arg `.push` / `.return(expr)` continuations were split first and
  coordinated with `RUST-PARITY.7.5.3` / the `tclite` oracle. Rust attached fluent block payloads and any
  remaining body/standalone fluent continuations stay separate follow-on children. Prior **`.2.3.2` DONE** —
  lifecycle blocks are now source/runtime/book locked as statement blocks, not expression-valued blocks.
  Phase0 locks all seven lifecycle markers plus Perl runtime behavior for final statement value discard,
  top-level lifecycle `return(expr)` writing the surrounding channel, and expression-valued block-local return
  staying separate. Rust runtime locks the same value/drop distinction and its current return-event shape.
  Phase0 is **994 green**. Prior **`.2.3.1` DONE; frontier `.2.3.2`** — Perl reference fluent
  `.when(cond) { ... }.otherwise { ... }` block chains are now source/descriptor/runtime locked for
  action-edge and lifecycle surfaces, including the no-dot `otherwise { ... }` continuation after a false
  `when` branch. Bootstrap now parses optional-dot attached fluent tails, recognizes `when` as the fluent
  attached-if head, and normalizes `otherwise` as an attached fallback tail. Phase0 is **993 green**. Prior
  **`.2.3` SPLIT/OWNED; frontier `.2.3.1`** — fluent
  control-flow, lifecycle block semantics, full composability, Rust fluent-block/action-edge parity, and
  return-type method chaining are now separate leaves after KM/TOOLBOX/code-read ground truth. Perl already
  accepts exact action/lifecycle `.when(cond) { ... }.otherwise { ... }` block chains; Rust and the portable
  book contract do not yet. Lifecycle block syntax exists, but value-drop versus rule-return-channel behavior
  still needs a focused semantic lock. Prior **`.2.2.6.2` DONE; frontier `.2.3`** — Rust attached
  `while(cond) { ... }` parser/runtime parity landed with deterministic iteration safety and oracle corpus
  **39 fixtures**; attached while is now portable on Perl and Rust. Prior **`.2.2.6.1` DONE** — Perl attached
  `while(cond) { ... }` now lowers through ActionIR with a deterministic iteration guard. Prior
  **`.2.2.6` SPLIT/OWNED before code; frontier `.2.2.6.1`** — attached
  `while(cond) { ... }` is split into a Perl reference loop/safety contract followed by Rust parity. Prior
  **`.2.2.5.2` DONE; frontier `.2.2.6`** — Rust attached `switch/case/default` parser/runtime parity landed
  over the Perl-oracle contract; oracle corpus is **38 fixtures**; `while(cond) { ... }` is next. Prior
  **`.2.2.5.1` DONE** — Perl
  attached `switch/case/default` separator/source lock landed; compact adjacent branches lower with no host
  residue, then Rust attached-switch parity followed in `.2.2.5.2`. Prior **`.2.2.5` SPLIT/OWNED before code; frontier `.2.2.5.1`** —
  attached `switch/case/default` is split into a Perl separator/source lock followed by Rust parity. Prior
  **`.2.2.4` DONE; frontier `.2.2.5`** — `when/otherwise` now lowers as
  portable attached `if/else` alias flow on Perl and Rust; oracle corpus is **37 fixtures**. Prior
  **`.2.2.4` OWNED before code** — `when/otherwise` is scoped as a normalization alias over the landed
  attached `if/else` contract, not host Perl `when`. Prior **`.2.2.3` DONE; frontier `.2.2.4`** — Rust attached-block
  `if/elseif/else` parity landed by parsing attached branch bodies into the existing statement-control model,
  with oracle parity locked. Prior **`.2.2.3` OWNED before code** — Rust attached-block `if/elseif/else`
  parity narrowed to `CodeBlock::parse` attached statement parsing plus existing runtime branch gating. Prior
  **`.2.2.2` DONE; frontier `.2.2.3`** — Perl attached-block `if/elseif/else` compact same-line branch
  continuations now split, lower through ActionIR, and run without raw fallback. Prior **`.2.2.2` OWNED before
  code** — same-line
  `} elseif/else {` was narrowed to the statement-splitting seam. Prior **`.2.2.1` DONE;
  frontier `.2.2.2`** — Round 2 control-flow keyword surface split after KM/TOOLBOX/code-read ground truth.
  At split time, marker/composite `if` plus inline-composite `switch` were believed to be the portable support,
  while attached-block `if`, `when`/`otherwise`, statement `switch`, and `while` needed separate leaves; later
  `.2.3.4` corrected inline value-control portability and split the Perl value-lowering gap. Prior
  **`.2.1.4` DONE; frontier
  `.2.2`** — block-local early
  `return(expr)` now works in expression-valued blocks on Perl and Rust without leaking into the surrounding
  rule return channel. Prior **`.2.1.3` DONE; frontier `.2.1.4`** — Rust parser/runtime parity for
  expression-valued blocks landed with oracle fixture; true block-local early-return follow-through is next if
  needed. Prior
  **`.1.6` DONE; Round 1 closed** — Array end-mutation methods landed on Perl
  and Rust: `items.push_back(value)`, `items.push_front(value)`, `items.pop_back()`, and `items.pop_front()`
  are statement-level mutations over named working arrays, with bare / `array(...)` / `a(...)` receivers.
  Phase0 is **990 green** and the oracle corpus is **33 fixtures**. Frontier -> **`.2.1`** (Round 2
  expression-valued blocks). Prior **`.1.2.3.5.4` DONE** — Rust RHS shape target-kind inference parity landed,
  closing the `.1.2.3.5` RHS-shape split across both variants. Rust now mirrors the accepted Perl
  `.1.2.3.5.2` rule: direct shape RHS on a bare or matching typed aggregate target initializes/replaces the
  array/hash working variable, while explicit `scalar(...)` keeps scalar-held payload assignment. Oracle corpus
  is **32 fixtures**; focused Rust `.1.2.3.5.4` locks and corpus oracle are green. Prior **`.1.2.3.5.3` DONE** —
  Rust shape-literal values parse/evaluate through recursive expression AST nodes and runtime
  `RuntimeValue::Array` / `RuntimeValue::Hash` construction, with oracle and integration locks. Prior
  **`.1.2.3.5.2` DONE** — Perl RHS target-kind inference landed. Direct RHS
  shapes now infer aggregate assignment targets when the target is bare: `name = [value]` / `set(name, [])`
  assign array working variable `@name`, and `name = { key => value }` / `set(name, {})` assign hash working
  variable `%name`. Non-shape RHS values remain scalar assignment, and explicit `scalar(name)` keeps scalar
  payload assignment (`$name = [$value]`). Typed array/hash declaration initializers now unwrap lowered shape
  literals too, so `declare(array, items=[value])` and `declare(hash, meta={ key => value })` compose with
  scalar bare reads and helper values. Phase0 is **989 green** and full local CI PASS. Frontier -> **`.1.2.3.5.3`** (Rust
  shape-literal value parity). Prior
  **`.1.2.3.5.1` DONE** — Perl shape-literal value expressions now lower `[]`,
  `[value]`, and `{ key => value }` through DSL value-expression rules, so shape members compose with scalar
  bare reads and auto-`my`; fixed hash field names must be quoted. Phase0 is **988 green**,
  mdBook/KM/live docs are updated. Prior **`.1.2.3.5` DONE/SPLIT** —
  RHS-shape/type-inference was split before code:
  Perl shape-literal value expressions, Perl RHS target-kind inference, then Rust parity for each accepted
  contract. Ground truth shows current Perl accepts raw empty `[]`/`{}` only as scalar value expressions and
  current Rust cannot parse bracket/brace value expressions at all; non-empty shapes need expression-aware
  lowering instead of raw Perl bareword passthrough. No engine/book behavior changed in this split. Frontier
  -> **`.1.2.3.5.1`**. Prior **`.1.2.3.4` DONE** — Rust scalar bare-read parity now matches the accepted
  `.1.2.3.3` Perl contract. Rust accepts source-slot scalar reads, mutation key/RHS scalar reads, and
  direct-access bare path atoms by relying on the existing `Expr::Variable` scalar read path and removing
  obsolete parser reservations. Oracle corpus is **28 fixtures**. Split **`.1.2.3.5`** now owns the remaining
  Channel 2 RHS-shape/type-inference work through concrete children. Prior **`.1.2.3.3.3` DONE** — Perl
  direct-access bare path atoms work: `foo["a"][z]` lowers like
  `foo["a"][scalar(z)]` (`$foo->{"a"}->[$z]`) and auto-supplies one per-invocation `my $z`; quoted path
  segments stay hash keys, numeric/helper segments stay array indexes, reserved literals and engine locals are
  not claimed, `scalaref(...)` compatibility was unchanged at that historical leaf and was later retired under
  `SCALAREF-RETIREMENT`. RHS-shape inference stays later. Phase0 is
  **987 green** and mdBook is updated. Prior **`.1.2.3.3.2` DONE** — Perl scalar mutation-slot bare reads work:
  `items += VALUE`, `set_key(meta, KEY, VALUE)`, and `meta[KEY] = VALUE` read scalar working variables in
  accepted key/RHS slots, auto-supply one per-invocation `my $NAME`, preserve target inference (`@items` /
  `%meta`), primitive literals, reserved-name boundaries, and all-bare `push(A,B)` child-call routing. Prior
  **`.1.2.3.3.1` DONE** — Perl scalar source-slot bare reads work:
  `return(NAME)`, `set(out, NAME)` / `assign(out, NAME)`, and `out = NAME` read scalar working variable `NAME`
  with one per-invocation `my $NAME`; primitive literals stay exact. Prior **`.1.2.3.3` SPLIT** — Perl scalar bare value reads
  divide by lowering seam: return/assignment-like scalar source slots first, mutation key/RHS slots next,
  direct-access bare path atoms after the key-vs-index rule is explicit. Prior **`.1.2.3.2` DONE** — Rust aggregate bare value reads now match the Perl
  reference: `array_copy(NAME)` and array-first `copy(NAME)` read array working variable `NAME`, while
  `hash_copy(NAME)` reads hash working variable `NAME`; `copy(hash(NAME))` stays the explicit hash-copy path.
  Oracle corpus is **25 fixtures** and full Rust runtime suite is green. Prior **`.1.2.3.1` DONE** — Perl aggregate bare value reads now
  auto-exist safely with exactly one `my @NAME` / `my %NAME` per rule; phase0 **984 green**. Prior
  **`.1.2.3` SPLIT** — Channel 2 ground truth shows aggregate bare value reads are separable from scalar bare
  reads/direct `[z]`, which remain later sub-surfaces. Prior
  **`.1.5.5.2` SUPERSEDED/MERGED** — reverify showed bare
  direct-access segments are the same global Channel 2 value-position-read problem as `return(z)`, so this
  leaf was merged into **`.1.2.3` Channel 2 design/split** instead of implementing `[z]` locally. Prior
  **`.1.5.5.1` DONE** — direct nested access with explicit path segments
  landed on Perl and Rust. `foo["a"][9]["b"][scalar(z)]` now reads mixed hash/array payload paths; quoted
  string segments are hash keys, numeric/helper segments are array indexes, and bare `[z]` remains deferred to
  Channel 2. Prior
  **`.1.5.5` SPLIT** — direct nested access was divided before code into `.1.5.5.1` explicit-segment direct
  access and `.1.5.5.2` bare-segment/Channel-2 coordination. Prior **`.1.5.4` DONE** — statement
  separators are newline-or-semicolon across Perl and Rust: newlines split top-level canonical DSL statements,
  multiple same-line statements require `;`, nested semicolons remain protected, and fluent attached-control
  tails normalize to explicit newline boundaries. Prior **`.1.5.3` DONE** — helper calls keep mandatory `callee(args)` parentheses while
  optional whitespace before `(` is locked at supported statement/value sites; no-parenthesis helper spellings
  remain out of scope. Prior **`.1.5.2` DONE** —
  primitive literals are now typed values on Perl and Rust: quoted strings, numbers, `undef`, `true`, and
  `false` work in return/mutation/flow positions; `true`/`false` are JSON booleans, exact matching keeps
  `trueword`/`undefine` out of the literal path, and Rust now gates statement-form `if(false)` blocks. Prior **`.1.5` SPLIT** — literals, nested access, call + semicolon rules are
  decomposed into signoff-sized leaves after KM/TOOLBOX/code-read ground truth. **`.1.5.1` DONE** (split
  audit). Prior **`.1.3.4.3` DONE** — hash-index assignment operator
  `name[key] = value` landed on Perl and Rust for explicit key/value expressions. It lowers/runs identically to
  settled `set_key(name, key, value)`, auto-exists the bare hash target, and leaves bare key/RHS identifiers
  deferred to Channel 2. **`.1.3.4` operator family DONE** (scalar `name = value`, array `items += value`,
  hash `name[key] = value`). **`.1.3` mutation surface DONE.** Prior **`.1.3.4.2` DONE** — array append operator `items += value`
  landed on Perl and Rust for explicit RHS expressions. Prior **`.1.3.4.1` DONE** — scalar assignment
  operator `name = value` landed. Prior **`.1.3.3` DONE** — hash mutation spelling landed. Top-level
  `set_key(name, key, value)` is now a statement-level named-hash mutation on Perl and Rust; nested/value-form
  `set_key(hash_expr, key, value)` remains a pure copy helper and is locked not to mutate its source hash.
  Book + KM + oracle corpus updated. Prior
  **`.1.3.2` DONE** — array function spelling landed with a conservative disambiguation:
  `push(target, value)` is accepted as the terse explicit-value append only when the value expression is
  unambiguous/non-all-bare; all-bare two-identifier `push(A, B)` keeps the existing child-call meaning
  (`A` rule into `B` accumulator). Perl now recognizes the alias at the contract/scanner/lowering sites plus
  the auto-array collector; Rust already had the `"push_value" | "push"` runtime alias and is now locked with
  oracle + integration coverage. Prior **`.1.3` SPLIT** — mutation surface split by mechanism after
  TOOLBOX-first probes. Scalar function form `set(name,val)` is already satisfied by `.1.4.1`/`.1.4.2`;
  operator forms are new syntax. Prior **`.1.4.2` DONE** — Rust lockstep parity for helper renames: `set` as
  `assign`, `cat` as `concat`, and unified `copy` for array/hash values or wrapped targets; 2 Perl-oracle
  fixtures + 3 Rust integration locks; cargo/clippy/phase0/full gate green; no book change. **`.1.4` container
  done.** Prior **`.1.4.1` DONE** — Perl
  reference: terse renames `set`/`cat`/`copy` now lower byte-identically to
  `assign`/`concat`/`array_copy`+`hash_copy` in every position; aliases recognized at every canonical-name site;
  all 20 specs byte-identical; +4 phase0 locks → 975 green; gate EXIT 0; book taught (3 pages); KM updated.
  Prior **`.1.2.2` DONE** — Rust lockstep parity for `.1.2.1`: REQUIRED a Rust engine
  change (unlike `.1.1.2`) — `resolve_scalar_target`/`resolve_array_target` now map a bare `Expr::Variable`
  target to the working var (`allow_bare` gate; push targets only), per-parse HashMap auto-vivifies; 2 oracle
  fixtures + 4 integration tests; cargo 248→252; clippy zero-new; phase0 971 (Perl untouched); gate EXIT 0;
  no book change. **Channel 1 complete on BOTH variants;** `.1.2` stays `active` (Channel 2 `.1.2.3`+ pending).
  Frontier → `.1.4`. Prior **`.1.2.1` DONE** — Perl arg-position bare working-variable auto-existence
  (Channel 1) landed: extended the `.1.1.1` collector `_collect_auto_working_var_decls` with a bare
  arg-position pass (`assign`→`$`, `push_value`/`push_nonempty`→`@`; `\s*,` guard keeps wrapped targets on
  the wrapped path; shared `$record` dedup); all 20 shipped specs byte-identical; +3 phase0 subtests → 971
  green; `tools/run_ci_local.sh` EXIT 0; ratio 1.0000; book taught in 3 pages; child-append/`.push` target +
  bare hash deferred to Channel 2; KM [[terse-bare-working-vars-engine-gaps]] updated. Frontier → `.1.2.2`
  (Rust parity). Prior **`.1.2` SPLIT** by inference channel after a `dump_parser_source`
  ground-truth pass — too broad for one signoff slice: a multi-channel Perl-reference engine change
  (arg-position auto-existence + value-position bare-word reads + RHS-shape inference), each with a
  lockstep Rust-parity obligation (ADR 0006). `.1.2` → container; added `.1.2.1` (Perl, Channel 1:
  arg-position bare working-var auto-existence — closes the leaky-global gap a bare arg-position var has
  today) + `.1.2.2` (Rust parity). Channel 2 (value-position bare-word reads + RHS-shape) `.1.2.3`+ added
  once `.1.2.1` lands and `.1.5` literal syntax is designed (not pre-published — no vague placeholders).
  Frontier → `.1.2.1`. Ground truth in KM [[terse-bare-working-vars-engine-gaps]]; DOCS/TREE/KM only — no
  engine/book change in the split slice. Prior **`.1.1.2` DONE** — Rust lockstep parity for auto-existing
  variables: assessed DOABLE with **no engine change** (the Rust interpreter stores working vars in
  per-parse `RuntimeContext` HashMaps that auto-vivify, so auto-existence is inherent — there is no
  Perl-style leaky-global hazard to fix); locked with 5 oracle corpus fixtures (`autoexist_*`,
  Rust==Perl reference) + 4 integration tests (value anchors, declare/no-declare convergence,
  per-parse no-leak) → **cargo 244→248 green**, all 7 oracle fixtures PASS, clippy zero-new, phase0
  **968 green** (Perl untouched), gate EXIT 0. The recursive/REP auto-exist idiom the Perl phase0
  locks use does NOT reproduce on Rust — the separately-owned `RUST-PARITY` recursive-grammar gap,
  NOT auto-existence. **`.1.1` container DONE** (both children done). Frontier → `.1.2`. KM card
  [[rust-working-vars-auto-vivify]]. Prior **`.1.1.1` DONE** — Perl auto-existing working variables landed:
  collector in `RuleIR/EmitContext.pm`, injection in `SpecEntry.pm`; 19/20 specs byte-identical,
  +3 phase0 locks → 968 green, gate EXIT 0, book taught. Frontier → `.1.1.2` (Rust lockstep parity).
  Prior `2026-06-23`: **`.1.1` SPLIT** into `.1.1.1` (Perl reference) + `.1.1.2` (Rust lockstep
  parity) after a `dump_parser_source` ground-truth pass — too broad for one signoff slice; verified design
  recorded in Decisions + KM [[working-vars-no-strict-need-my-lexical]]; frontier → `.1.1.1`. Prior
  `2026-06-22`: **implementation gate CLEARED** — `t/phase0_regression.t` 960/960 green +
  `tools/run_ci_local.sh` EXIT 0 via `PHASE0-BACKHALF-TRIAGE`; `.1.x`+ are now PNT-eligible (policy already
  resolved = gradual-alias, ADR `0007`). Status flip recorded cross-tree in
  `PHASE0-BACKHALF-TRIAGE.5.3.2.1`. ACTIVATED 2026-06-18; `.0` done via ADR `0007`.)
- Owner: repo-local workflow

## Goal

Formalize and own — as an executable, pivotable plan — the `.spec` format-evolution
direction brainstormed on 2026-06-15 (Rounds 1–3), so the decisions are not lost and any one
of them can be cleanly picked up. The direction makes `.spec` authoring terser and fully
Lisp-style composable: remove ceremony wrappers (`declare`, `scalar()/array()/hash()`), infer
types, rename helpers (`assign`→`set`, `concat`→`cat`, `array_copy`/`hash_copy`→`copy`), add
operator spellings alongside function forms, make blocks expression-valued, and treat arithmetic
and comparisons as composable functions with word+symbol spellings.

**Guiding principle (design goal):** terse and dynamic-feeling, **yet still readable** — brevity
must never cost clarity. Every change is judged on all three: does it reduce ceremony, does it feel
fluid/composable, and does a reader still understand the rule at a glance? If a terse form hurts
readability, it is not adopted.

**Scope: ALL LinkedSpec variants (Perl, Rust, Julia, Dart).** Per
`docs/decisions/0006-multi-backend-vision.md` and the cross-variant-output-parity doctrine, `.spec`
is the **universal contract** — there are no per-variant `.spec` dialects. The terse format is
defined and proven on the **Perl reference first**, then rolled out to **every backend in lockstep**
so a `.spec` that compiles/runs on one variant compiles/runs identically on all. **All variants must
stay at full feature parity** — no variant gets ahead of the contract. The mdBook is the
**variant-neutral / agnostic** behavioral spec every backend implements: it describes the `.spec`
DSL and concepts, **not** any one backend's implementation (see the `MDBOOK-VARIANT-AGNOSTIC` tree
and the `mdbook-variant-agnostic` / `cross-variant-output-parity` doctrine). It is updated per change.
Each adopted change therefore carries a follow-on parity obligation in every variant (e.g. `RUST-PARITY`),
and the book change must read the same regardless of which backend a reader uses.

Source of record for the raw brainstorm: KM card
[[spec-format-brainstorm-rounds-1-3]] (`docs/knowledge/spec-format-brainstorm-rounds-1-3.md`,
2026-06-15, status `brainstorming`). This tree transcribes those decisions in full so they
survive even if the card is lost, and turns each into a pickable leaf.

## Sequencing

- **ACTIVATED 2026-06-18 (user).** `.0` (ratify + ADR `0007`) is **done**. The tree is now the
  active work unit.
- **Implementation leaves (`.1.x`+) are now UNGATED (2026-06-22).** Per the user (2026-06-16) and ADR
  `0007`, per-leaf acceptance needs the full `t/phase0_regression.t` gate, which was hung by
  `RTLUTILS-REGEX-HANG`. That gate is now **restored + green**: `LEGACY-VHDL-RETIRE` retired the hanging
  subsystem, `NONCORE-QUARANTINE` relocated the rest of the domain island (excising the second back-half
  hang's smoke), and `PHASE0-BACKHALF-TRIAGE` resolved the 173 back-half failures + the corpus/dark-tail
  tail — so `t/phase0_regression.t` is **960/960 green** and `tools/run_ci_local.sh` exits **0**. `.1.x`+ are
  PNT-eligible; the execution-order question is closed (no scoped-check workaround needed — the real gate is
  back).
- Migration policy ratified in ADR `0007`: **canonical-new-form + deprecated-old-alias (gradual)**,
  then explicit retirement (open to a user override toward one-shot hard rename).

## Non-Goals

- Implementing any of this now (the current raw-Perl-free helper DSL remains the supported,
  shipped surface until a leaf is ratified and landed).
- Changing shipped `.spec` files or the current helper contracts before a leaf is activated.
- Re-litigating already-shipped semantics (rule modes/edges that stay as-is are noted, not changed).

## Acceptance Criteria (per leaf, when activated)

Each change leaf follows the extension-surface order (`PHASE7-SELF-HOSTED-SPEC.5` policy):
1. Author/extend the construct in `specs/spec.spec` first (self-hosted grammar).
2. Implement the bootstrap-grammar + ActionIR lowering changes (`BootstrapSpec/Core.pm`,
   `ActionIR/*`), keeping the all-target ActionIR-ready invariant (ratio 1.0000, zero
   compatibility-surface) — or introduce the new form as canonical with the old form aliased
   during migration. For user-defined `fn` syntax specifically, bootstrap-parser support is
   not the permanent destination; any bridge there must be explicitly temporary and removed
   once `specs/spec.spec` plus the text-to-AST path can own the surface.
3. Update the mdBook (the behavioral spec) and add regression coverage in `t/phase0_regression.t`.
4. Run the full gate; commit per `COMMIT.md`.

## Task Tree

- ID: `SPEC-FORMAT-TERSE`
  Status: `done` / `closed` (closed 2026-07-08 by `.13.5`)
  Goal: Evolve the `.spec` DSL toward a terser, fully-composable format (brainstorm Rounds 1–3 + resume 4+)
  Children: `.0` through `.15` completed, deferred, or explicitly blocked as recorded below; `.13.5` closes the
    parent metadata status after the final active implementation/docs lane was exhausted.

- ID: `SPEC-FORMAT-TERSE.0`
  Status: `done`
  Goal: Ratify the adopted direction and record it as an ADR (the brainstorm is tentative)
  Acceptance: A `docs/decisions/000N-spec-format-terse-direction.md` ADR captures which rounds/changes
    are adopted, the migration policy (canonical-new + aliased-old vs hard rename), and the
    backward-compatibility stance for the 20 shipped specs. First leaf on activation.
  Verification: Done — 2026-06-18. Wrote ADR
    [`0007-spec-format-terse-direction.md`](../decisions/0007-spec-format-terse-direction.md)
    (indexed in `docs/decisions/INDEX.md`) ratifying the terse direction Rounds 1–3 as transcribed
    here + in [[spec-format-brainstorm-rounds-1-3]]; cross-checked against the user's 2026-06-18
    clarifications (`assign`→`=`/`set`; no-sigil typed bare identifiers; type inference at init / by
    arg position; `copy()` unifies array+hash; arrays/hashes/numbers/strings have methods,
    chain-by-return-type; everything-is-an-expression / typed-value blocks) — all consistent. ADR
    decisions: (1) adopt Rounds 1–3, Round 4+ deferred; (2) **migration policy = canonical-new +
    deprecated-old-alias (gradual), then explicit retirement** — keeps the 20 shipped specs + book
    compiling and the ActionIR-ready invariant (ADR 0002) at every step; (3) `.spec` stays the single
    universal contract, all variants in lockstep (ADR 0006), book updated only after the engine
    implements a form; (4) a **user-sanctioned exception** to [[feedback_do-not-fix-reference-engine]]
    (intentional evolution, not a docs-vs-reference fix); (5) implementation leaves gated by a usable
    `t/phase0_regression.t` (hung by `RTLUTILS-REGEX-HANG`). Design-only leaf — no engine/book change,
    so the regression gate does not apply to `.0`. self-check + KM gate pass.
  Commit: `SPEC-FORMAT-TERSE.0 — activate + ratify the terse .spec format direction (ADR 0007)`; prior node reference: `SPEC-FORMAT-TERSE.0` (see Commit Log); retained completion note: Tree `proposed`→`active`; ADR `0007` + INDEX row; migration policy = gradual alias; reference-touching exception; implementation gated by `RTLUTILS-REGEX-HANG`. No engine/book change.

- ID: `SPEC-FORMAT-TERSE.1`
  Status: `done` (2026-06-29 — Round 1 closed by `.1.6`; variables/types, mutation, helper renames,
    literals/calls/access, and array end-mutation methods now have accepted Perl/Rust locks for the published
    Round 1 leaves.)
  Goal: Round 1 — variables, types, mutation, functions
  Children: `.1.1`, `.1.2`, `.1.3`, `.1.4`, `.1.5`, `.1.6`

- ID: `SPEC-FORMAT-TERSE.1.1`
  Status: `done` (2026-06-24 — both children done: `.1.1.1` Perl reference + `.1.1.2` Rust lockstep
    parity. Split 2026-06-23 — too broad for one signoff slice: Perl reference engine change +
    lockstep Rust parity are separable.)
  Goal: Auto-existing variables — remove the need for `declare(...)`; a working variable exists on
    first use within a rule scope (declare stays as a deprecated, still-working alias)
  Children: `.1.1.1` (Perl reference), `.1.1.2` (Rust lockstep parity)
  Commit: `SPEC-FORMAT-TERSE.1.1 — split into .1.1.1 (Perl) + .1.1.2 (Rust parity); record auto-existing-variable design + KM card`; table label: `SPEC-FORMAT-TERSE.1.1` (split); retained completion note: `.1.1` → container; first frontier child `.1.1.1`. Design grounded by `dump_parser_source` probes; KM [[working-vars-no-strict-need-my-lexical]]. Docs/tree/KM-only — no engine/book change.

- ID: `SPEC-FORMAT-TERSE.1.1.1`
  Status: `done` (2026-06-24)
  Goal: Perl reference — auto-existing working variables: the engine auto-supplies the per-invocation
    `my` lexical so a `.spec` working variable referenced via the typed wrappers
    `scalar(NAME)`/`array(NAME)`/`hash(NAME)` (and `s()/a()/h()` aliases) need not be `declare(...)`d
    first. `declare(...)` keeps working unchanged (deprecated alias, gradual migration per ADR 0007).
  Acceptance: (1) a `.spec` rule that references a working variable through a typed wrapper WITHOUT a
    prior `declare(...)` compiles and runs correctly — the engine emits a single `my $NAME`/`@NAME`/`%NAME`
    in the handler preamble (run once, NOT inline per edge), so the variable is a per-invocation lexical,
    not a leaky package global (see KM [[working-vars-no-strict-need-my-lexical]]); (2) specs that DO
    use `declare(...)` produce byte-identical generated source + identical output (no double `my`; the
    auto-collector dedupes against explicit declares and the `@<label>` accumulator); (3) the all-target
    ActionIR-ready invariant holds (ratio 1.0000, zero compatibility-surface — ADR 0002); (4)
    `t/phase0_regression.t` stays green (currently 965) with new locks proving the no-declare path works
    and the declare path is unchanged; (5) `bash tools/run_ci_local.sh` EXIT 0; (6) book updated to teach
    that working variables auto-exist and `declare(...)` is optional (note both forms; full example
    re-authoring is a later gradual-migration leaf). Type is taken from the wrapper (`scalar`→`$`,
    `array`→`@`, `hash`→`%`) — full RHS/arg-position inference is `.1.2`, NOT this leaf.
  Verification: **DONE 2026-06-24.** Implemented a rule-level collector
    `RuleIR::EmitContext::_collect_auto_working_var_decls` (+ `_mask_action_code_literals`) that scans the
    RAW pre-lowering blocks (`code_blocks` + `acode/bcode/and_icode` entries — NOT the regex `re` slots) for
    single-bare-identifier typed-wrapper refs, takes the sigil from the wrapper, dedups against the
    `@<label>` accumulator + any same-sigil `my` already in the LOWERED code (declare/raw-my), excludes DSL
    literals (`undef`/`true`/`false`) + engine-reserved handler locals, and returns one `my` per surviving
    var; `build_rule_ir_emit_context` returns it as `auto_var_decls`; `SpecEntry::compile_spec_entry`
    prepends it to the preamble icode (empty string ⇒ unchanged ⇒ byte-identical for declared specs).
    **TOOLBOX-first ground truth** (`dump_parser_source` probes): WITHOUT declare the handler had a bare
    leaky-global `$count`/`@items`; WITH the change it now emits `my $count;`/`my @items;` once.
    **Byte-identical proof:** generated source for **all 20 shipped specs**, mine-vs-stashed, diffed —
    **19/20 byte-identical**; only `tkgui` differs (one legit `my $subgui_name;` for its genuinely
    undeclared working scalar) and its parse output is **identical before/after, even on a 2nd same-process
    parse** (no leak; per-invocation `my`). A Lispish false positive (`a(undef)`→`my @undef`) was caught by
    the diff and fixed via the reserved-literal exclusion. **+3 phase0 locks** (no-declare scalar+array work
    + no cross-parse leak; declare path single-`my`; reserved-literal not auto-declared): **phase0 965→968
    green**; `bash tools/run_ci_local.sh` **EXIT 0** ("Result: PASS", 968); ratio 1.0000 preserved (phase0
    all-target guard green); `mdbook build` EXIT 0. **Book (6):** taught auto-existence (declare optional)
    in `dsl/declaration-helper-reference.md`, `appendix/helper-contract-catalog.md` §1 (+ corrected the
    `assign` "must exist"/undeclared-error contract), and `dsl/value-container-flow-helper-reference.md`;
    examples NOT re-authored (a later gradual leaf).
  Commit: `SPEC-FORMAT-TERSE.1.1.1 — Perl auto-existing working variables (engine + book + 3 phase0 locks)`; prior node reference: `SPEC-FORMAT-TERSE.1.1.1` (see Commit Log); retained completion note: Collector `_collect_auto_working_var_decls` in `RuleIR/EmitContext.pm` (+ `_mask_action_code_literals`) → `auto_var_decls`; preamble injection in `SpecEntry::compile_spec_entry`. 19/20 specs byte-identical (tkgui +1 legit `my`, behavior-preserved); +3 phase0 locks → 968; gate EXIT 0; book taught (declare optional).

- ID: `SPEC-FORMAT-TERSE.1.1.2`
  Status: `done` (2026-06-24)
  Goal: Rust lockstep parity — the Rust runtime auto-supplies the same per-invocation working-variable
    binding so a `.spec` using auto-existing variables compiles/runs identically on the Rust backend
    (cross-variant-output-parity; ADR 0006 lockstep obligation for the `.1.1.1` reference change).
  Acceptance: the Rust variant reproduces `.1.1.1`'s behavior on the same minimal specs (auto-exist works;
    declare-form unchanged); Rust test suite green; cross-check/oracle parity holds for any non-recursive
    auto-exist spec. (If the Rust runtime's working-variable model blocks this independently of the known
    recursive-grammar `RUST-PARITY` gap, record the blocker; otherwise implement.) Assess blocked-vs-doable
    when reached — the `.1.1.1` change is "landed against the universal contract" only once this closes.
  Verification: **DONE 2026-06-24 — assessed DOABLE; NO engine change needed.** TOOLBOX-first
    ground truth (throwaway Rust + Perl `LinkedSpec::Get` probes, dump-don't-guess): the Rust runtime is
    an interpreter (not codegen+`eval`), so working variables live in per-parse `RuntimeContext` HashMaps
    (`scalars`/`arrays`/`hashes` in `rust/linkedspec-runtime/src/runtime.rs`) that **auto-vivify** on write
    (`set_scalar`/`push_value` insert / `or_default`) and read as `Undef`/empty when absent — i.e. working
    variables **already auto-exist with no `declare`**, and `Engine::execute` builds a **fresh
    `RuntimeContext` per call** so a value can never leak across parses (the Rust analogue of Perl's
    per-invocation `my`). Perl's `.1.1.1` change was needed only because non-strict generated handlers
    would otherwise make an undeclared var a leaky package global — a codegen hazard Rust does not have, so
    there is nothing to fix. `declare(...)` stays meaningful for its `=init` seed form (unchanged).
    **Proof (cross-variant, divergence-free edge-action form = the `.7.1` oracle proof class):** ran the
    same minimal grammars on BOTH backends — scalar no-declare → Perl `"ok"` / Rust `["ok"]`; array
    no-declare → Perl `["a","b"]` / Rust `[["a","b"]]`; declare twins identical; `array(undef)` → Perl
    `[null]` / Rust `[[null]]` — i.e. Rust == Perl reference wrapped one level (the documented Perl↔Rust
    output-shape rule). **Locked:** 5 oracle corpus fixtures `autoexist_{scalar,array}_{no_declare,declare}`
    + `autoexist_undef_literal` via `tools/gen_oracle_corpus.pl` (all 7 oracle fixtures PASS) + 4
    integration locks in `rust/linkedspec-runtime/tests/integration_test.rs`
    (`terse_1_1_2_*`: scalar/array value anchors, declare/no-declare convergence, per-parse no-leak via
    same-engine re-run). **cargo test 244→248 green**; `cargo clippy` zero-new source/test warnings
    (engine.rs 11 = baseline, my test files add 0); `perl -c tools/gen_oracle_corpus.pl` OK; `mdbook build`
    EXIT 0; `bash tools/run_ci_local.sh` **EXIT 0** (phase0 968 green, Perl untouched). **Deferred (NOT a
    blocker for this leaf):** the recursive/REP auto-exist idiom the Perl phase0 locks use (`top:: ... ->
    top[0]`, `Top::*`) does NOT reproduce on Rust — that is the separately-owned `RUST-PARITY`
    recursive-grammar / REP-lifecycle gap, independent of auto-existence (proven: those exact specs return
    `[null]`/`[[]]` on Rust while the non-recursive equivalents are at full parity). No book change
    (variant-agnostic; `.1.1.1` already taught the contract; Rust now conforms). KM card
    [[rust-working-vars-auto-vivify]].
  Commit: `SPEC-FORMAT-TERSE.1.1.2` (see Commit Log)

- ID: `SPEC-FORMAT-TERSE.1.2`
  Status: `done` (2026-06-29 — Channel 1 and Channel 2 are closed on Perl and Rust; RHS-shape/type
    inference completed through `.1.2.3.5.4`. Split 2026-06-24 — too broad for one signoff slice. Ground
    truth via
    `dump_parser_source` (KM [[terse-bare-working-vars-engine-gaps]]): a bare working var splits into
    two inference channels — (1) ARG-POSITION (already lowers to the right sigil'd variable but gets no
    auto-`my` → leaky global) and (2) VALUE-POSITION (`return(count)`→ bareword `count`, not `$count`) +
    RHS-shape — each a Perl-reference change with a Rust-parity obligation (ADR 0006). Split Perl-first
    by channel, mirroring how `.1.1` split into `.1.1.1`/`.1.1.2`. **`.1.2.1` DONE 2026-06-24** — Perl
    Channel 1 arg-position auto-existence landed (collector extended: bare `assign`→`$`,
    `push_value`/`push_nonempty`→`@`; wrapped target untouched; all 20 specs byte-identical; +3 phase0
    locks → 971; book taught). **`.1.2.2` DONE 2026-06-24** — Rust lockstep parity landed; unlike `.1.1.2`
    it REQUIRED a Rust engine change (the bare-target resolvers `resolve_scalar_target`/`resolve_array_target`
    now map a bare `Expr::Variable` target to the working var; per-parse HashMap auto-vivifies it); 2 oracle
    fixtures + 4 integration tests, cargo 248→252. **Channel 1 complete on BOTH variants.** Channel 2 is
    owned by `.1.2.3` after `.1.5` settled primitive literals, separators, and
    explicit direct nested access; `.1.5.5.2` was superseded into `.1.2.3`. **`.1.2.3` SPLIT 2026-06-29**
    into aggregate bare value reads first (`.1.2.3.1` Perl + `.1.2.3.2` Rust), then scalar bare value reads
    (`.1.2.3.3` Perl + `.1.2.3.4` Rust), with RHS-shape/type inference split under `.1.2.3.5`; all
    `.1.2.3.x` children are now done.)
  Goal: Remove container wrappers as a *requirement* + add type inference (bare words are
    variables/functions, never string literals; type from RHS shape `[]`→array/`{}`→hash/scalar and
    from helper arg position). Wrappers stay accepted aliases during migration (gradual, ADR 0007).
  Children: `.1.2.1` (Perl, Channel 1), `.1.2.2` (Rust parity for `.1.2.1`), `.1.2.3` (Channel 2
    value-position bare-word reads + RHS-shape/type-inference container).
  Commit: `SPEC-FORMAT-TERSE.1.2 — split into .1.2.1 (Perl, Channel 1) + .1.2.2 (Rust parity); record bare-working-var ground truth + KM card`; table label: `SPEC-FORMAT-TERSE.1.2` (split); retained completion note: `.1.2` → container after a `dump_parser_source` ground-truth pass: a bare working var has two inference channels — arg-position (lowers right but leaks; no auto-`my`) and value-position bare-word reads + RHS-shape (`return(count)`→bareword). `.1.2.1` (Perl arg-position auto-existence) is the first frontier child; `.1.2.2` is its Rust parity; Channel 2 leaves added later. KM [[terse-bare-working-vars-engine-gaps]]. DOCS/TREE/KM only — no engine/book change.

- ID: `SPEC-FORMAT-TERSE.1.2.1`
  Status: `done` (2026-06-24)
  Goal: Perl reference — Channel 1: arg-position bare working-variable auto-existence. A bare working
    variable used in a type-implying helper arg position (scalar LHS of `assign`/`set`; array target of
    `push`/`push_value`; hash target of the key-set forms) auto-exists as a per-invocation `my` with the
    sigil implied by that position — closing the leaky-package-global gap the ground truth exposed: such a
    bare var already LOWERS to the correct sigil'd variable (`assign(count, v)`→`$count = v`;
    `push_value(items,..)`→`push @items, ..`) but currently gets NO auto-`my`, because the `.1.1.1`
    collector matches only WRAPPED `scalar/array/hash(NAME)`. Wrappers remain optional/equivalent here.
  Acceptance: (1) a `.spec` using a bare working var in a type-implying arg position WITHOUT a wrapper or
    `declare(...)` compiles and runs correctly, with exactly one preamble `my $NAME`/`@NAME`/`%NAME` (run
    once in the preamble, NOT inline per edge — per-invocation lexical, no cross-parse leak; see KM
    [[working-vars-no-strict-need-my-lexical]]); (2) specs that DO use wrappers/`declare(...)` stay
    byte-identical (dedup vs the `@<label>` accumulator + any same-sigil `my` already in the lowered
    code, mirroring `.1.1.1`); (3) all-target ActionIR-ready ratio 1.0000 (ADR 0002); (4)
    `t/phase0_regression.t` green (currently 968) with new locks: bare arg-position scalar + array
    auto-exist + cross-parse no-leak, with the wrapped/declare paths unchanged; (5)
    `bash tools/run_ci_local.sh` EXIT 0; (6) book updated to teach that a working var in a typed arg
    position auto-exists (wrapper optional there too). Full RHS-shape / value-position bare-word reads are
    Channel 2 (`.1.2.3`+), NOT this leaf.
  Verification: **DONE 2026-06-24.** Extended the `.1.1.1` rule-level collector
    `RuleIR::EmitContext::_collect_auto_working_var_decls` with a second collection pass (refactored the
    per-ref add into a shared `$record` closure): alongside the WRAPPED typed-wrapper refs it now also
    scans the literal-masked RAW blocks for a **bare** working var in a type-implying *first-arg* helper
    position and records it with the **position-implied** sigil — `assign(NAME, …)` → `$NAME` (scalar;
    `_lower_assign_statement` extracts scalar first), `push_value(NAME, …)` / `push_nonempty(NAME, …)` →
    `@NAME` (array). The `\s*,` after the bare name means a WRAPPED target (`scalar(x)`/`array(x)`, whose
    name is followed by `(`) is NOT matched by the bare pattern — it stays on the wrapped path; both dedup
    (by sigil+name) to one `my`. Same reserved-literal / `@<label>` / already-`my` dedup as `.1.1.1`.
    **TOOLBOX-first ground truth** (`dump_parser_source`, scratchpad `probe_terse_1_2_1.pl`,
    dump-don't-guess): isolated bare forms (no wrapper anywhere) — `assign(count,…)`→`$count = …` now with
    `my $count;`; `push_value(items,…)`→`push @items` now with `my @items;`; `push_nonempty` likewise; and
    `assign(pair, set_key(hash(pair),…))` now declares BOTH `my %pair` (wrapped) AND `my $pair` (the bare
    assign target — a separate scalar that held the hashref, previously leaky). **Byte-identical proof:**
    generated source for **all 20 shipped specs**, mine-vs-stashed, diffed — **0 diff** (cleaner than
    `.1.1.1`; the corpus has no un-wrapped arg-position targets). **+3 phase0 subtests / 17 assertions**
    (`spec_format_terse_1_2_1_*`: bare scalar+array+push_nonempty auto-exist with the `my` in the preamble
    before `while(1)`; deferred `.push(target)` boundary; dedup vs wrapped/declare = single `my`;
    integrated per-invocation no-leak run-twice): **phase0 968→971 green**; `bash tools/run_ci_local.sh`
    **EXIT 0** ("[ci] local CI gate passed", 971); ratio 1.0000 (phase0 all-target guard green);
    `mdbook build` EXIT 0. **Book (3):** taught bare arg-position auto-existence (wrapper optional there) in
    `dsl/declaration-helper-reference.md` (+ corrected the now-outdated "argument position is a later step"
    note), `appendix/helper-contract-catalog.md` §1 (+ the `assign`/`push_value`/`push_nonempty` entries),
    and `dsl/value-container-flow-helper-reference.md`. **Scope (signoff): Channel 1 covers the unambiguous
    first-arg value-helper positions only.** The child-append `push(Rule[, target])` / fluent
    `.push(target)` target is DEFERRED (its first arg is a rule name — ambiguous), and a bare HASH target
    has no clean arg-position trigger (`assign`'s target lowers scalar-first; `set_key(name,…)` is a
    value-position read) — both belong to Channel 2 (value-position + RHS-shape), not this leaf. KM
    [[terse-bare-working-vars-engine-gaps]] updated (Channel 1 closed).
  Commit: `SPEC-FORMAT-TERSE.1.2.1 — Perl arg-position bare working-variable auto-existence (Channel 1; engine + book + 3 phase0 locks)`; prior node reference: `SPEC-FORMAT-TERSE.1.2.1` (see Commit Log); retained completion note: Extended `_collect_auto_working_var_decls` (`RuleIR/EmitContext.pm`) with a bare arg-position pass: `assign(NAME,…)`→`my $NAME`, `push_value`/`push_nonempty(NAME,…)`→`my @NAME`; wrapped targets stay on the `.1.1.1` wrapped path (the `\s*,` guard); shared `$record` dedup → all 20 specs byte-identical; +3 phase0 subtests → 971 green; gate EXIT 0; ratio 1.0000; book (3 pages) taught wrapper-optional-in-arg-position. Child-append `push(Rule[,target])`/`.push` target + bare hash deferred to Channel 2. KM [[terse-bare-working-vars-engine-gaps]] (Channel 1 closed).

- ID: `SPEC-FORMAT-TERSE.1.2.2`
  Status: `done` (2026-06-24)
  Goal: Rust lockstep parity for `.1.2.1` (ADR 0006). The Rust runtime reproduces arg-position bare
    working-variable auto-existence identically. (The `.1.1.1`→`.1.1.2` precedent suggests this likely
    holds by architecture — the interpreter's per-parse `RuntimeContext` HashMaps auto-vivify on write
    regardless of wrapper/`declare`/bare; assess blocked-vs-doable when reached.)
  Acceptance: the Rust variant reproduces `.1.2.1` on the same minimal specs; cargo suite green; oracle
    cross-check parity holds for any non-recursive arg-position auto-exist spec (the recursive/REP idiom
    stays deferred to `RUST-PARITY`). The `.1.2.1` change is "landed against the universal contract" only
    once this closes. Lock with oracle fixtures + integration tests (mirror `.1.1.2`).
  Verification: **DONE 2026-06-24 — DOABLE, but (unlike `.1.1.2`) it REQUIRED a Rust engine change.**
    TOOLBOX-first ground truth (throwaway Rust integration probe, dump-don't-guess): the auto-vivify is
    inherent (per the `.1.1.2` card), but a **bare** arg-position target was not being mapped to the working
    variable — `resolve_scalar_target`/`resolve_array_target` (`rust/linkedspec-runtime/src/engine.rs`) only
    extracted the name from a WRAPPED `scalar(VAR)`/`array(VAR)` Call; a bare `Expr::Variable` fell through
    to `val.to_str()` (the evaluated value → `""`). Probe BEFORE: bare `assign(v,"ok")`→`[null]`, bare
    `push_value(items,..)`→`[[]]` (vs wrapped `["ok"]`/`[["a","b"]]`) — a genuine divergence from the Perl
    `.1.2.1` reference. **Fix:** both resolvers now also accept a bare `Expr::Variable` target and return its
    name (mirroring the Perl `^(\w+)$` fallback in `ValueExpr::_extract_*_symbol_name`); the per-parse
    HashMap then auto-vivifies it (no `declare`, fresh ctx per `execute` ⇒ no leak). Scoped to the Channel-1
    target positions via an `allow_bare` flag: `true` for `push_value`/`push_nonempty`, `false` for the
    value-position reads `array_copy`/`hash_copy` (bare value-position reads are Channel 2, not this leaf).
    Probe AFTER: bare == wrapped (`["ok"]`, `[["a","b"]]`). **Locked:** 2 oracle corpus fixtures
    `autoexist_{scalar,array}_bare_arg` via `tools/gen_oracle_corpus.pl` (regenerated — the existing 7
    fixtures byte-identical; `corpus_oracle` checks Rust == the Perl reference value) + 4 `terse_1_2_2_*`
    integration tests (scalar/array/push_nonempty value anchors, bare==wrapped==declare convergence,
    per-parse no-leak via same-engine re-run). **cargo test 248→252 green**; all 9 oracle fixtures PASS;
    `cargo clippy` zero-new (engine.rs 11 = baseline — my added `if allow_bare` nest was flattened to a
    tuple `if let`; my test file adds 0); `perl -c tools/gen_oracle_corpus.pl` OK; **phase0 971 green**
    (Perl untouched), `bash tools/run_ci_local.sh` **EXIT 0**. No book change (variant-agnostic — `.1.2.1`
    already taught the contract; Rust now conforms). The recursive/REP idiom stays deferred to `RUST-PARITY`.
    KM card [[terse-bare-working-vars-engine-gaps]] updated (Rust parity + the engine-change contrast with
    `.1.1.2`). **`.1.2.1` is now landed against the universal contract on both variants.**
  Commit: `SPEC-FORMAT-TERSE.1.2.2 — Rust lockstep parity for arg-position bare working-variable auto-existence (engine + oracle + 4 integration locks)`; prior node reference: `SPEC-FORMAT-TERSE.1.2.2` (see Commit Log); retained completion note: Bare `Expr::Variable` target now mapped to the working var in `resolve_scalar_target` + `resolve_array_target` (`allow_bare` gate: push targets true, value-reads false), mirroring Perl's `^\w+$` fallback; per-parse HashMap auto-vivifies. **Required an engine change** (unlike `.1.1.2`). 2 oracle fixtures + 4 `terse_1_2_2_*` tests; cargo 248→252; clippy zero-new; phase0 971 (Perl untouched); gate EXIT 0; no book change. Channel 1 complete on both variants; `.1.2.1` now landed against the universal contract.

- ID: `SPEC-FORMAT-TERSE.1.2.3`
  Status: `done` (2026-06-29 — value-read children `.1.2.3.1` through `.1.2.3.4` are done, and
    RHS-shape/type-inference closed through `.1.2.3.5.1` through `.1.2.3.5.4` on Perl and Rust.
    Split 2026-06-29. Split-time ground truth:
    aggregate bare value reads already lower on Perl (`array_copy(items)` -> `[@items]`,
    `hash_copy(meta)` -> `{%meta}`, `copy(items)` -> `[@items]`) but do not get a preamble
    `my @items`/`my %meta`; Rust deliberately keeps bare value reads out of aggregate-copy target
    resolvers. Scalar bare value reads (`return(count)`, scalar RHS/key/direct `[z]`) were a separate surface
    and now have Perl/Rust parity.)
  Goal: Channel 2 — value-position bare-word reads and RHS-shape/type inference.
  Children: `.1.2.3.1` (Perl aggregate bare value reads), `.1.2.3.2` (Rust parity for `.1.2.3.1`),
    `.1.2.3.3` (Perl scalar bare value reads, split by lowering seam), `.1.2.3.4` (Rust parity for the
    accepted `.1.2.3.3` scalar-read contract), `.1.2.3.5` (RHS-shape/type-inference split container).
  Verification: **SPLIT 2026-06-29.** KM retrieval and TOOLBOX probes show three distinct sub-surfaces.
    (1) Perl aggregate bare value reads already lower to sigiled variables (`return(array_copy(items))` ->
    `return [@items]`, `return(hash_copy(meta))` -> `return {%meta}`, `return(copy(items))` -> `return
    [@items]`) but generated source has no `my @items` / `my %meta`, so this is the same non-strict
    package-global hazard as earlier auto-existence leaves. (2) Rust `Expr::Variable` evaluates as a scalar
    read, but aggregate-copy resolvers use `allow_bare=false` in value-read positions, so bare aggregate reads
    are not lockstep with the Perl reference. (3) Scalar-like value reads remain unresolved on Perl:
    `return(count)` -> `return count`, `set(out,count)` -> `$out = count`, while `items += value`,
    `meta[key] = value`, and `foo["a"][z]` remain raw/reserved. Therefore `.1.2.3` becomes a container before
    code.
  Commit: `SPEC-FORMAT-TERSE.1.2.3 — split Channel 2 value reads by aggregate/scalar surfaces` (see Commit Log); retained completion note: No engine/book behavior change. Channel 2 is now an active container with aggregate bare value reads first (`.1.2.3.1` Perl, `.1.2.3.2` Rust), followed by scalar bare reads (`.1.2.3.3` Perl, `.1.2.3.4` Rust). Frontier becomes `.1.2.3.1`.

- ID: `SPEC-FORMAT-TERSE.1.2.3.1`
  Status: `done` (2026-06-29)
  Goal: Perl reference — aggregate bare value reads auto-exist safely.
  Acceptance: Bare aggregate reads that already lower to `@NAME`/`%NAME` in Perl value positions
    (`array_copy(NAME)`, `hash_copy(NAME)`, and `copy(NAME)` under the existing array-first `copy` rule)
    emit exactly one preamble `my @NAME`/`my %NAME` per rule when not otherwise declared/wrapped, without
    changing wrapped or explicitly declared specs. Focused phase0 locks prove generated-source preamble
    placement, no duplicate declarations, no cross-parse package-global leak, and unchanged behavior for
    `array_copy(array(NAME))`, `hash_copy(hash(NAME))`, and declared variants.
  Verification: **PASS 2026-06-29.** Extended `_collect_auto_working_var_decls` to collect aggregate bare
    value-read forms from literal-masked raw action blocks: `array_copy(NAME)` / `copy(NAME)` -> `my @NAME`;
    `hash_copy(NAME)` -> `my %NAME`. Focused source/runtime/no-leak probe PASS, including same-parser reruns for
    array and hash reads; Perl syntax checks PASS; phase0 PASS (`t/phase0_regression.t`, **984 tests**).
    Book/live docs and KM updated. Rust parity remains owned by `.1.2.3.2`.
  Commit: `SPEC-FORMAT-TERSE.1.2.3.1 — auto-exist aggregate bare value reads` (see Commit Log); retained completion note: Perl aggregate bare value reads now auto-declare per-invocation lexicals: `array_copy(NAME)` / `copy(NAME)` -> `my @NAME`; `hash_copy(NAME)` -> `my %NAME`. Wrapped/declared paths dedup unchanged; scalar bare reads and bare key/RHS/direct path atoms remain deferred. Frontier becomes `.1.2.3.2`.

- ID: `SPEC-FORMAT-TERSE.1.2.3.2`
  Status: `done` 2026-06-29
  Goal: Rust lockstep parity for `.1.2.3.1` aggregate bare value reads.
  Acceptance: Rust accepts and evaluates bare aggregate read forms to the same values as the Perl reference
    for `array_copy(NAME)`, `hash_copy(NAME)`, and `copy(NAME)`/`copy(hash(NAME))` under the documented
    array-first `copy` rule, with oracle fixtures and focused integration locks. The change must not make
    scalar bare reads or bare direct-access segments advance ahead of `.1.2.3.3`.
  Verification: **PASS 2026-06-29.** `array_copy`, `hash_copy`, and `copy` now allow bare aggregate targets
    only through their aggregate target resolvers. `copy(NAME)` remains array-first; `copy(hash(NAME))` remains
    the explicit wrapped hash-copy form. Added 4 integration locks and 4 Perl-oracle fixtures; focused Rust
    `.1.2.3.2` tests PASS; direct-access bare-segment rejection PASS; oracle corpus PASS over 25 fixtures; full
    runtime suite PASS (116 unit tests, 25 oracle fixtures, 54 integration tests); clippy EXIT 0 with existing
    warning baseline. Phase0/mdBook/KM/local CI PASS.
  Commit: `SPEC-FORMAT-TERSE.1.2.3.2 — add Rust aggregate bare-read parity` (see Commit Log); retained completion note: Rust aggregate bare reads now match the Perl reference at the aggregate-copy helper call sites. `array_copy(NAME)` and array-first `copy(NAME)` read arrays, `hash_copy(NAME)` reads hashes, and `copy(hash(NAME))` keeps the explicit hash form. 4 oracle fixtures + 4 integration locks; full runtime suite green; scalar Channel 2 remains next.

- ID: `SPEC-FORMAT-TERSE.1.2.3.3`
  Status: `done` (2026-06-29 — all three Perl scalar bare-read children done: `.1.2.3.3.1` source slots,
    `.1.2.3.3.2` mutation key/RHS slots, and `.1.2.3.3.3` direct-access bare path atoms. Split 2026-06-29 —
    too broad for one signoff code slice. TOOLBOX probes showed return and
    assignment source payloads fall through to raw barewords; statement-level `set_key(meta,key,"v")` already
    lowers a bare key through `_lower_scalar_access_key_expr`, but bare values stay raw; `items += value` and
    `meta[key] = value` are rejected by scanner/lowerer guards before key/RHS lowering; direct access
    deliberately rejects bare path atoms. All-bare child-call `push(A,B)` remains protected.)
  Goal: Perl reference — scalar bare value reads in scalar-like positions.
  Children: `.1.2.3.3.1` (return/assignment scalar source slots), `.1.2.3.3.2` (mutation key/RHS scalar slots),
    `.1.2.3.3.3` (direct-access bare path atoms).
  Acceptance: The Perl scalar bare-read contract is defined and implemented by child leaves without broadening
    all-bare child-call forms such as `push(A,B)`. Each child must add generated-source/runtime locks and
    collector coverage for any newly sigiled scalar reads so generated handlers keep per-invocation lexicals.
  Verification: **DONE 2026-06-29.** KM retrieval plus TOOLBOX `call_spec_handler_subst` probes established
    the seams: `return(count)` -> `return count`, `set(out,count)` -> `$out = count`, and `name = value` ->
    `$name = value` share scalar source-slot raw fallback; `set_key(meta,key,"v")` already emits
    `$meta{$key} = "v"` while `set_key(meta,"stage",value)` leaves `value` raw; `items += value`,
    `meta[key] = "v"`, `meta["stage"] = value`, and `meta[key] = value` are still raw/reserved because the
    scanner/lowerer guards reject bare RHS/key tokens; direct `foo["a"][z]` remains raw while
    `foo["a"][scalar(z)]` lowers to `$foo->{"a"}->[$z]`. `push(A,B)` still lowers as the child-call form.
    No engine/book behavior changed in the split slice. Children `.1.2.3.3.1`, `.1.2.3.3.2`, and
    `.1.2.3.3.3` then landed each accepted scalar-read seam with phase0 locks; `.1.2.3.4` later closed Rust
    scalar parity. The remaining Channel 2 work is now `.1.2.3.5` RHS-shape/type inference.
  Commit: `SPEC-FORMAT-TERSE.1.2.3.3 — split scalar bare reads by lowering seam` (see Commit Log); retained completion note: No engine/book behavior change. Perl scalar bare reads are split into return/assignment source slots (`.1.2.3.3.1`), mutation key/RHS slots (`.1.2.3.3.2`), and direct-access bare path atoms (`.1.2.3.3.3`). Frontier becomes `.1.2.3.3.1`.

- ID: `SPEC-FORMAT-TERSE.1.2.3.3.1`
  Status: `done` (2026-06-29)
  Goal: Perl reference — scalar bare reads in return and assignment-like source slots.
  Acceptance: `return(NAME)`, `set(out, NAME)` / `assign(out, NAME)`, and scalar assignment operator
    `out = NAME` lower as scalar working-variable reads (`$NAME`) and auto-supply exactly one preamble
    `my $NAME` when not already declared/wrapped. Wrapped forms (`scalar(NAME)` / `s(NAME)`) and declared specs
    remain unchanged, primitive literals remain literals, reserved names are not auto-declared, and all-bare
    child-call forms such as `push(A,B)` keep the existing child-call lowering. This leaf does not claim array
    append RHS, hash mutation key/RHS, direct-access bare path atoms, generic helper argument bare reads, or
    RHS-shape `[]`/`{}` inference.
  Verification: **PASS 2026-06-29.** Added scoped bare scalar-read lowering only at the source-slot seams:
    `_lower_return_payload_expr` for `return(NAME)` and `_lower_assignment_source_expr` for `set(out, NAME)` /
    `assign(out, NAME)` / `out = NAME`. `_collect_auto_working_var_decls` now records matching scalar source
    reads from raw action blocks, deduping with wrapped/declared forms and skipping reserved literals/engine
    locals. Focused lowering/source probes PASS: source slots now emit `$NAME`; `true`/`undef` stay literals;
    `trueword`/`undefine` become scalar reads; `items += value`, `meta["stage"] = value`, direct `[z]`, and
    `push(A,B)` keep their prior boundaries. Added a 24-assertion phase0 lock and updated the primitive-literal
    prefix lock; phase0 PASS (**985 tests**, 213s); mdBook build PASS.
  Commit: `SPEC-FORMAT-TERSE.1.2.3.3.1 — implement scalar source-slot bare reads` (see Commit Log); retained completion note: Perl source-slot bare reads now work for return and scalar assignment-like sources with matching scalar auto-existence. mdBook/KM/live docs updated; phase0 985 green. Frontier becomes `.1.2.3.3.2`.

- ID: `SPEC-FORMAT-TERSE.1.2.3.3.2`
  Status: `done` (2026-06-29)
  Goal: Perl reference — scalar bare reads in mutation key/RHS slots.
  Acceptance: Accepted mutation forms that currently require explicit scalar wrappers for scalar RHS/key reads
    gain scoped bare scalar reads without changing target inference: array append RHS (`items += value`),
    statement-level named hash mutation value (`set_key(meta, key, value)` / `set_key(meta, "stage", value)`),
    and hash-index operator key/RHS (`meta[key] = value`, `meta["stage"] = value`) lower through `$value` /
    `$key` where the accepted key slot is scalar-valued. Existing explicit forms and primitive literals remain
    unchanged, target auto-existence stays `@items` / `%meta`, and all-bare child-call `push(A,B)` remains a
    child call rather than an append.
  Verification: **DONE 2026-06-29.** Perl now lowers accepted mutation-slot bare scalar reads:
    `items += value` -> `push @items, $value`, `set_key(meta,key,value)` -> `$meta{$key} = $value`, and
    `meta[key] = value` -> `$meta{$key} = $value`. The scanner contracts now recognize these forms, while
    reserved engine locals such as `CAPTURE` remain unclaimed, primitive literals stay typed values, direct
    `foo["a"][z]` remains deferred, and all-bare `push(A,B)` / `push(items,value)` keep child-call precedence.
    `_collect_auto_working_var_decls` records the matching scalar key/RHS reads plus the existing array/hash
    targets, deduping with declarations/wrappers and skipping reserved literals. Perl syntax checks PASS;
    TOOLBOX lowering probes PASS; `prove -q -Iperl t/phase0_regression.t` PASS (**986 tests**, including the
    new 29-assertion lock); mdBook updated.
  Commit: `SPEC-FORMAT-TERSE.1.2.3.3.2 — implement scalar mutation-slot bare reads` (see Commit Log); retained completion note: Perl mutation-slot bare reads now work for array append RHS, statement-level `set_key` key/RHS, and hash-index operator key/RHS, with matching scalar auto-existence. mdBook/KM/live docs updated; phase0 986 green. Frontier becomes `.1.2.3.3.3`.

- ID: `SPEC-FORMAT-TERSE.1.2.3.3.3`
  Status: `done` (2026-06-29)
  Goal: Perl reference — direct-access bare path atoms.
  Acceptance: Define and implement the direct-access bare path rule after `.1.2.3.3.1`/`.1.2.3.3.2` settle the
    scalar read model. If the accepted rule is scalar-index, direct `foo["a"][z]` lowers like
    `foo["a"][scalar(z)]` (`$foo->{"a"}->[$z]`) and auto-supplies `my $z`; quoted path segments remain hash
    keys, numeric/helper segments remain array indexes, and `scalaref(...)` compatibility is documented or
    explicitly left unchanged. This leaf does not introduce RHS-shape `[]`/`{}` inference.
  Verification: **PASS 2026-06-29.** Perl now lowers non-reserved bare atoms inside direct-access paths as
    scalar array indexes: `return(foo["a"][z])` -> `return $foo->{"a"}->[$z]`, identical to the explicit
    `[scalar(z)]` form. The same direct-access value lowering now composes through assignment sources, array
    append RHS, and hash mutation RHS. `_collect_auto_working_var_decls` records accepted bare path atoms
    (`z`, `idx`, `pos`) through the direct lowerer as an acceptance oracle and emits exactly one `my $NAME`
    per atom, deduping with explicit `declare(scalar, NAME)`. Reserved atoms such as `true` and `CAPTURE` are
    not claimed. `scalaref(foo,{"a"}[z])` keeps its historical `[z]` path atom; use `[scalar(z)]` there for a
    scalar variable index. `push(A,B)` remains child-call syntax. Perl syntax checks PASS; TOOLBOX lowering
    probes PASS; `prove -q -Iperl t/phase0_regression.t` PASS (**987 tests**, including the new 18-assertion
    lock); mdBook updated.
  Commit: `SPEC-FORMAT-TERSE.1.2.3.3.3 — implement direct-access bare path atoms` (see Commit Log); retained completion note: Perl direct-access bare path atoms now work as scalar array indexes with matching scalar auto-existence. mdBook/KM/live docs updated; phase0 987 green. `.1.2.3.3` closes; frontier becomes `.1.2.3.4`.

- ID: `SPEC-FORMAT-TERSE.1.2.3.4`
  Status: `done` (2026-06-29)
  Goal: Rust lockstep parity for the accepted `.1.2.3.3` scalar bare value-read contract.
  Acceptance: Rust parser/runtime behavior matches the accepted Perl scalar bare-read contract after the
    `.1.2.3.3.x` children land, without getting ahead on later RHS-shape or block-expression surfaces. Split by
    the same seams if one parity slice is too broad.
  Verification: **PASS 2026-06-29.** Rust already evaluated `Expr::Variable` as a scalar working-variable
    read through `ctx.get_scalar(name)`, so the parity gap was the parser reservations left over from Channel 2
    staging. The parser now accepts bare scalar variables in source slots (`return(value)`, `set(out, value)`,
    `name = value`), mutation key/RHS slots (`items += value`, `meta[key] = value`), and multi-segment direct
    access path indexes (`foo["a"][idx]`). One-level `name[index]` remains the legacy indexed-variable form.
    Focused Rust core tests `parse_scalar_bare_reads_in_mutation_slots` and
    `parse_direct_nested_access_accepts_bare_segments` PASS; focused Rust runtime `.1.2.3.4` tests PASS;
    `tools/gen_oracle_corpus.pl` regenerated **28 fixtures** including three `.1.2.3.4` oracle cases; Rust
    corpus oracle PASS; mdBook build PASS; KM/memory/doctrine/diff checks PASS; full local CI PASS.
  Commit: `SPEC-FORMAT-TERSE.1.2.3.4 — add Rust scalar bare-read parity` (see Commit Log); retained completion note: Rust now accepts the Perl scalar bare-read contract in source slots, mutation key/RHS slots, and direct-access bare path atoms through the existing `Expr::Variable` scalar read path. 3 oracle fixtures added; frontier becomes `.1.2.3.5` RHS-shape/type-inference split.

- ID: `SPEC-FORMAT-TERSE.1.2.3.5`
  Status: `done` (SPLIT 2026-06-29 — no engine/book behavior change)
  Goal: Channel 2 RHS-shape/type-inference split before code.
  Children: `.1.2.3.5.1` (Perl shape-literal value expressions), `.1.2.3.5.2` (Perl RHS-shape target
    inference), `.1.2.3.5.3` (Rust parity for `.1.2.3.5.1`), `.1.2.3.5.4` (Rust parity for `.1.2.3.5.2`).
  Acceptance: Ground truth first, then split or implement the remaining `.1.2` shape-inference contract
    without disturbing the now-settled value-read semantics. This owns `[]`/`{}` RHS-shape and any scalar/hash/
    array inference rules still needed after `.1.2.3.4`; it must explicitly protect direct-access brackets,
    control-flow/block braces, helper-call parsing, and all-bare `push(A,B)` child-call routing. If the shape
    surface is too broad, create child leaves before code.
  Verification: **SPLIT 2026-06-29.** KM retrieval plus TOOLBOX/source/runtime/code-read probes show this is
    not one signoff implementation seam. Perl lowering accepts empty `[]` and `{}` as raw Perl arrayref/hashref
    value expressions in scalar/value slots: `return([])` -> `return []`, `name = []` -> `$name = []`, and
    `items += []` -> `push @items, []`. But `name = []` and `name = {}` assign scalar `$name`; they do not
    initialize or alias the aggregate working variables `@name` / `%name`, which remain distinct slots.
    Runtime/source dumps prove `items = []; items += "a"; return(items)` keeps `$items` separate from
    `@items`, and `meta = {}; meta[key] = "v"; return(meta)` keeps `$meta` separate from `%meta`. Non-empty
    shapes such as `[value]` and `{ key => value }` were raw Perl passthrough at split time, so bare identifiers
    became Perl barewords/strings rather than the settled scalar reads; they therefore needed an expression-aware DSL
    literal lowerer before any target-kind inference can be signoff. Rust `parse_expr` has no bracket/brace
    primary expression at all, so Rust parity is also a separate obligation. The split is: `.1.2.3.5.1` Perl
    shape-literal value expressions; `.1.2.3.5.2` Perl RHS-shape target inference; `.1.2.3.5.3` Rust parity for
    accepted shape-literal values; `.1.2.3.5.4` Rust parity for accepted target inference.
  Commit: `SPEC-FORMAT-TERSE.1.2.3.5 — split RHS-shape inference by mechanism` (see Commit Log); retained completion note: No engine/book behavior change. RHS-shape/type inference is split into Perl shape-literal value expressions (`.1.2.3.5.1`), Perl RHS target-kind inference (`.1.2.3.5.2`), and Rust parity for each (`.1.2.3.5.3`/`.1.2.3.5.4`). Frontier becomes `.1.2.3.5.1`.

- ID: `SPEC-FORMAT-TERSE.1.2.3.5.1`
  Status: `done` (2026-06-29)
  Goal: Perl reference — define and lower `[]` / `{}` as DSL shape-literal value expressions.
  Acceptance: Empty and non-empty array/hash literals accepted in value positions lower through expression-aware
    element/key/value handling, so settled scalar reads compose inside shapes (`[value]`, `{ key => value }`)
    without raw Perl bareword/string passthrough. Direct-access bracket paths, hash-index assignment brackets,
    future control-flow/block braces, helper-call parsing, primitive literals, and all-bare child-call routing
    remain protected. Add focused Perl runtime/source locks and update the mdBook only if user-visible behavior
    changes.
  Verification: **PASS 2026-06-29.** Perl now lowers accepted shape-literal value expressions through scoped
    DSL value-expression rules: `return([value])` -> `return [$value]`, `return({ key => value })` ->
    `return {$key => $value}`, `items += [value]` -> `push @items, [$value]`, and
    `meta[key] = { key => value }` -> `$meta{$key} = {$key => $value}`. Nested shape literals, primitive
    literals, direct access, and recognized helper calls compose in direct shape members. `_collect_auto_working_var_decls`
    records scalar bare reads only for shapes accepted by the lowerer, so generated handlers auto-supply one
    per-invocation `my $value` / `my $key` where needed. Runtime/source locks prove
    `return(array([value, cat("a","b"), true, []], { key => value, "fixed" => [value] }))` returns the expected
    typed nested structure with no canonical fallback. This leaf deferred target-kind inference, which later
    landed in `.1.2.3.5.2`. Perl syntax checks PASS; phase0 PASS (`t/phase0_regression.t`, **988 tests**);
    mdBook/KM/live docs updated.
  Commit: `SPEC-FORMAT-TERSE.1.2.3.5.1 — implement Perl shape-literal values` (see Commit Log); retained completion note: Perl now lowers accepted `[]` / `{}` shape literals as DSL value expressions, with scalar bare reads inside direct elements, keys, and values plus auto-`my` declarations. Fixed hash fields require quoted keys. Target-kind inference stays deferred to `.1.2.3.5.2`; Rust parity stays `.1.2.3.5.3`.

- ID: `SPEC-FORMAT-TERSE.1.2.3.5.2`
  Status: `done` (2026-06-29)
  Goal: Perl reference — decide and implement RHS-shape target-kind inference.
  Acceptance: After `.1.2.3.5.1` defines shape literals as values, decide whether scalar assignment forms such
    as `name = []` / `name = {}` initialize aggregate working variables (`@name` / `%name`) or intentionally
    remain scalar arrayref/hashref assignment. The accepted rule must be explicit, backwards-compatible or
    consciously migrated, covered by source/runtime locks, and documented in the mdBook if it changes the
    user-facing contract.
  Verification: **DONE 2026-06-29.** Accepted rule: direct shape literals infer aggregate working-variable
    targets only for bare assignment targets. `name = []` / `name = [value]` lower to `@name = ...`;
    `name = {}` / `name = { key => value }` lower to `%name = ...`; `set(...)` / `assign(...)` follow the
    same source-driven rule. Non-shape RHS values remain scalar assignment (`name = value` -> `$name =
    $value`). Explicit wrappers keep explicit kind, so `set(scalar(name), [value])` stores the array payload in
    `$name`. Auto-working-var collection now records the inferred target sigil, so generated handlers emit
    exactly one matching `my @name` / `my %name` / `my $name` and do not retain stale scalar declarations for
    aggregate shape assignments. Typed direct shape initializers in `declare(array, ...)` and `declare(hash,
    ...)` unwrap lowered shape values instead of raw payload text, so direct initializer members compose with
    scalar bare reads and helper value calls. Focused lowering/runtime/source probes PASS; phase0 PASS
    (`t/phase0_regression.t`, 989 tests); mdBook/KM/memory/doctrine/diff checks PASS; full local CI PASS.
  Commit: `SPEC-FORMAT-TERSE.1.2.3.5.2 — infer Perl RHS shape target kind` (see Commit Log); retained completion note: Perl now uses direct RHS shape literals to infer aggregate bare assignment targets: arrays for `[]` / `[value]`, hashes for `{}` / `{ key => value }`; explicit `scalar(...)` keeps scalar-held payload assignment. Declaration initializer direct shapes unwrap lowered members. Frontier becomes `.1.2.3.5.3`.

- ID: `SPEC-FORMAT-TERSE.1.2.3.5.3`
  Status: `done` (2026-06-29)
  Goal: Rust lockstep parity for `.1.2.3.5.1` shape-literal value expressions.
  Acceptance: Rust parses and evaluates the accepted Perl shape-literal value-expression contract with oracle
    fixtures and focused integration locks, without advancing RHS target-kind inference ahead of `.1.2.3.5.2`.
  Verification: Rust parser locks cover direct array/hash value literals, mutation RHS shape literals, roundtrip
    display, and the `.1.2.3.5.4` boundary that scalar assignment keeps the shape payload. Runtime integration
    locks prove typed nested return payloads, mutation RHS payloads, and scalar-held RHS shape assignment.
    Oracle corpus regenerated with 30 fixtures and Rust corpus oracle PASS. Focused Rust core/runtime tests PASS;
    mdBook/KM/live docs updated; memory/doctrine/diff/full local gates recorded in the Verification Log.
  Commit: `SPEC-FORMAT-TERSE.1.2.3.5.3 — implement Rust shape-literal values` (see Commit Log); retained completion note: Rust parses/evaluates direct shape literals as value expressions with parser/runtime/oracle locks, while leaving Rust RHS target-kind inference to `.1.2.3.5.4`.

- ID: `SPEC-FORMAT-TERSE.1.2.3.5.4`
  Status: `done` (2026-06-29)
  Goal: Rust lockstep parity for `.1.2.3.5.2` RHS-shape target-kind inference.
  Acceptance: Rust matches the accepted Perl target-kind inference contract with oracle fixtures and focused
    integration locks. If `.1.2.3.5.2` intentionally preserves scalar arrayref/hashref assignment, Rust must
    lock that behavior rather than inventing aggregate initialization.
  Verification: **PASS 2026-06-29.** Rust now classifies only direct RHS `Expr::ArrayLiteral` /
    `Expr::HashLiteral` values as target-kind inference sources. Bare targets and matching explicit
    `array(...)` / `hash(...)` targets receive whole-aggregate assignment through `RuntimeContext::set_array`
    and `set_hash`: `items = [value]`, `set(items, [value])`, and `set(array(items), [value])` replace the
    array working variable, while `meta = { key => value }`, `assign(meta, { key => value })`, and
    `set(hash(meta), { key => value })` replace the hash working variable. Explicit `scalar(payload)` falls
    through to the existing scalar target resolver and stores the shape payload in scalar `payload`; the array
    working variable `payload` remains separate/empty. Focused Rust runtime `.1.2.3.5.4` tests PASS; oracle
    corpus regenerated with 32 fixtures and Rust corpus oracle PASS; mdBook/KM/live docs updated.
  Commit: `SPEC-FORMAT-TERSE.1.2.3.5.4 — implement Rust RHS shape target kind` (see Commit Log); retained completion note: Rust now uses direct RHS shape literals to infer aggregate bare or matching typed aggregate assignment targets, while explicit `scalar(...)` keeps scalar-held payload assignment. Added integration/oracle locks; frontier becomes `.1.6`.

- ID: `SPEC-FORMAT-TERSE.1.3`
  Status: `done` (2026-06-29 — mutation surface closed by mechanism. `.1.3.1` audit done;
    `.1.3.2` array function spelling done; `.1.3.3` hash mutation done; `.1.3.4` operator family done
    by `.1.3.4.1` scalar assignment, `.1.3.4.2` array append, and `.1.3.4.3` hash-index assignment.
    TOOLBOX-first
    `call_spec_handler_subst` + runtime probes show four different states/mechanisms: scalar
    `set(name, val)` already lowers and runs via `.1.4` (`set`→`assign`, bare target auto-exists); explicit
    array append now has a conservative `push(target, value)` spelling for unambiguous value expressions, while
    all-bare `push(A, B)` keeps the live child-call convention; `set_key(name, k, v)` is currently a pure
    hash value expression in Perl return/source paths but did not become a standalone mutation statement until
    `.1.3.3`, and Rust likewise needed a statement handler; operator forms `name = val`,
    `items += val`, `name["k"] = val` originally passed through as raw/invalid Perl and required new statement
    syntax in the Rust expression AST; all three landed in the `.1.3.4.x` children. KM card
    [[terse-mutation-surface-ground-truth]].)
  Goal: Mutation surface — function + operator spellings
  Acceptance: Scalar assign `name = val` (op) or `set(name, val)` (function); array push `name += val`
    (op) or `push(name, val)` (function); hash set `name[k] = v` (op) or `set_key(name, k, v)`
    (function). Both spellings lower identically.
  Children: `.1.3.1` (scalar function-form audit, already satisfied), `.1.3.2` (array function spelling
    disambiguation), `.1.3.3` (hash function mutation semantics), `.1.3.4` (operator syntax family)
  Verification: **SPLIT 2026-06-29.** Ground truth:
    `set(name,"ok")` == `assign(name,"ok")` lowers to `$name = "ok"` and runs to `"ok"` with the per-invocation
    bare-target `my` already supplied by `.1.2.1`/`.1.4.1`; Rust `.1.4.2` has the matching `set` alias and
    integration lock. `push_value(items,"a")` lowers/runs (`push @items, "a"`), but `push(items,"a")` passes
    through Perl lowering as raw `push(items, "a")` and fails handler compilation; Rust currently interprets
    `"push"` as a `push_value` alias, but the Perl reference cannot adopt `push(name,value)` without resolving
    the conflict with existing child-call `push(Rule, target)` semantics. `return(set_key(name,"k","v"))`
    runs on Perl as a hash-valued expression, but `set_key(name,...)` alone does not lower as a statement; Rust
    `set_key` returns the original arg unless arg0 is already a hash value. Operators `name = "ok"`,
    `items += "a"`, and `name["k"] = "v"` pass through `call_spec_handler_subst` unchanged and compile as
    invalid/raw Perl; Rust's `CodeBlock` grammar has no assignment/`+=` statement node. No engine/book change
    in this split slice.
  Commit: `SPEC-FORMAT-TERSE.1.3 — split mutation surface by mechanism; record push/operator ground truth`; prior node reference: `SPEC-FORMAT-TERSE.1.3` (see Commit Log); table label: `SPEC-FORMAT-TERSE.1.3` (split); retained completion note: `.1.3` → container after TOOLBOX-first probes: scalar `set(name,val)` already done; array explicit-value append spelling must resolve `push(name,value)` vs existing child-call `push(rule,target)`; hash `set_key(name,k,v)` needs a mutation statement contract distinct from pure `set_key(hash_expr,...)`; operators require new statement syntax on Perl + Rust. `.1.3.1` audit done; `.1.3.2` is next. KM [[terse-mutation-surface-ground-truth]]. DOCS/TREE/KM only — no engine/book change.

- ID: `SPEC-FORMAT-TERSE.1.3.1`
  Status: `done` (2026-06-29, audit-only)
  Goal: Scalar function form — `set(name, value)` is the terse scalar mutation spelling and must match
    `assign(name, value)` on both variants.
  Acceptance: Perl `call_spec_handler_subst` lowers `set(name, val)` and `assign(name, val)` byte-identically;
    a runtime spec with bare `set(name, val)` returns the assigned value and does not leak between parses; Rust
    has an equivalent `set` alias and lock. No new code if already satisfied.
  Verification: **DONE by prior leaves, audited 2026-06-29.** `.1.4.1` added `set` to every Perl `assign`
    recognition site, including the bare-target auto-`my` collector; `.1.4.2` added Rust `"assign" | "set"`.
    Fresh probe: `set(name,"ok")` and `assign(name,"ok")` both lower to `$name = "ok"`; a minimal parser returns
    `"ok"`. The `.1.4.1` phase0 locks and `.1.4.2` integration lock already cover per-parse bare `set` target
    semantics.
  Commit: `SPEC-FORMAT-TERSE.1.3` (audit recorded in the split commit)

- ID: `SPEC-FORMAT-TERSE.1.3.2`
  Status: `done` (2026-06-29)
  Goal: Array function spelling — decide and implement the explicit-value append spelling requested as
    `push(name, value)` without regressing the existing child-call `push(rule[, target[, index]])` convention.
  Acceptance: Existing child-call forms (`push(Child)`, `push(Child, target)`, indexed variants, and fluent
    `.push(...)`) remain byte-identical and documented; the selected explicit-value spelling lowers/runs
    identically to `push_value(name, value)` on Perl and Rust; ambiguity between two bare identifiers is
    resolved by a documented rule before any engine change; focused phase0/Rust locks prove both the new
    spelling and the legacy child-call convention.
  Verification: **DONE 2026-06-29.** Decision: `push(target, value)` is the terse explicit-value append only
    when the value expression makes the value role unambiguous (literal, typed wrapper such as
    `scalar(value)`, wrapped target such as `array(items)`, helper value such as `cat(...)`, or `call(Child)`).
    All-bare child-call forms keep precedence: `push(Child)`, `push(Child, target)`, `push(Child, index)`,
    `push(Child, target, index)`, and the scope-injected method-chain child-call forms remain child-call
    contracts. In particular `push(items, value)` is still child-call-shaped (`items` rule into `@value`);
    appending a working variable value stays `push(items, scalar(value))` or `push_value(items, scalar(value))`
    until Channel 2 bare value-position reads land. Implementation: Perl `push_value` statement recognition now
    also accepts `push` in `ActionIR/Contracts.pm`, `Scanner/PrimitivePipelineRules.pm`, and
    `ActionIR/MethodLowering.pm`, while `RuleIR/EmitContext.pm` collects the target auto-`my @target` using a
    parser-backed balanced `push(...)` scan so nested/comma value expressions do not break declarations. Rust
    already accepted `"push_value" | "push"`; this leaf locks that existing behavior against the Perl reference
    with one oracle fixture and one integration test. Focused proof before final gate: `call_spec_handler_subst`
    lowers `push(items,"a")`, `push(items, scalar(retv))`, `push(array(items), scalar(retv))`, and
    `push(items, call(Leaf))` like `push_value`, while `push(items, value)`, `push(Leaf, items)`,
    `push(Leaf, 1)`, and `push(Leaf, items, 1)` remain child-call lowerings; descriptor/runtime probe has zero
    fallback/unresolved nodes and returns `["a","b"]`; source-dump lock for `push(items, cat("a", "b"))` emits
    exactly one `my @items` and the concat do-block. `prove -q -Iperl t/phase0_regression.t` PASS (975);
    focused Rust `terse_1_3_2_push_alias_matches_push_value` PASS; corpus oracle PASS over 12 fixtures;
    `mdbook build docs/linkedspec-book` EXIT 0; Knowledge Map gate OK; `scripts/check_memory_architecture.sh`
    OK; `bash tools/run_ci_local.sh` EXIT 0 (`phase0` 975, local CI gate passed).
  Commit: `SPEC-FORMAT-TERSE.1.3.2 — recognize push(target,value) explicit append while preserving child-call push`; prior node reference: `SPEC-FORMAT-TERSE.1.3.2` (see Commit Log); retained completion note: Perl `ActionIR` now treats `push(target,value)` as a `push_value` alias only for unambiguous/non-all-bare value expressions; all-bare `push(A,B)` remains child-call. Added Perl phase0 locks, Rust oracle fixture + integration lock, and book/KM/live-doc updates.

- ID: `SPEC-FORMAT-TERSE.1.3.3`
  Status: `done` (2026-06-29)
  Goal: Hash function mutation spelling — define and implement `set_key(name, key, value)` as the mutation
    counterpart to `name[key] = value`, while preserving today's pure hash-valued `set_key(hash_expr, key,
    value)` helper.
  Acceptance: The mutation form has an explicit statement-level lowering on Perl and an equivalent Rust
    runtime behavior; pure value `set_key(hash(...), key, value)` remains unchanged; bare hash auto-existence
    and Channel 2 value-position semantics are either implemented here with locks or explicitly split further
    with a dependency on `.1.2.3`/`.1.5`.
  Verification: **DONE 2026-06-29.** TOOLBOX `call_spec_handler_subst` proves top-level `set_key(meta,...)`
    lowers to `$meta{...} = ...` while `return(set_key(hash(meta),...))` still uses the pure copy helper.
    Descriptor probe reports `ASSIGN,RETURN` with zero fallback; source dump for bare `set_key(meta,...)`
    emits exactly one preamble `my %meta`; same-parser runtime probe returns stable hash output across reruns;
    pure nested helper lock proves the source hash is not mutated. `perl -c` edited Perl modules +
    generator/test OK; `prove -q -Iperl t/phase0_regression.t` PASS (976);
    `perl -Iperl tools/gen_oracle_corpus.pl` regenerated 13 fixtures; focused Rust `terse_1_3_3` tests PASS;
    corpus oracle PASS over 13 fixtures; `mdbook build docs/linkedspec-book` EXIT 0; Knowledge Map,
    memory-architecture, doctrine checks, and full local gate OK.
  Commit: `SPEC-FORMAT-TERSE.1.3.3 — implement set_key(name,key,value) hash mutation statement`; prior node reference: `SPEC-FORMAT-TERSE.1.3.3` (see Commit Log); retained completion note: Perl `ActionIR` now treats top-level `set_key(name,key,value)` as an ASSIGN mutation statement and auto-declares bare hash targets. Rust executes top-level `set_key(...)` statements by mutating the named hash while keeping nested value-form `set_key(hash_expr,...)` pure. Added phase0 locks, Rust integration locks, oracle fixture, and book/KM/live-doc updates.

- ID: `SPEC-FORMAT-TERSE.1.3.4`
  Status: `done` (2026-06-29 — operator family closed. `.1.3.4.1` scalar assignment, `.1.3.4.2` array append,
    and `.1.3.4.3` hash-index assignment all landed on Perl and Rust with statement-only semantics and
    explicit Channel 2 boundaries.)
  Goal: Operator syntax family — `name = value`, `name += value`, and `name[key] = value` lower identically to
    the settled function forms.
  Children: `.1.3.4.1` (scalar assignment operator), `.1.3.4.2` (array append operator), `.1.3.4.3`
    (hash-index assignment operator)
  Acceptance: Perl gains explicit statement recognition/lowering for the three operator shapes; Rust gains
    corresponding AST statement forms and runtime execution; each operator is locked against its canonical
    function form; no raw/invalid Perl passthrough remains. Split by operator before code if this remains too
    broad when reached.
  Verification: **SPLIT 2026-06-29.** KM retrieval first (`terse-mutation-surface-ground-truth`,
    `terse-bare-working-vars-engine-gaps`) confirmed the function forms are settled and operator forms remain
    new syntax. TOOLBOX `call_spec_handler_subst` shows `name = "ok"`, `items += "a"`, and
    `name["k"] = "v"` are unchanged while `set(name,"ok")`, `push(items,"a")`, and
    `set_key(name,"k","v")` lower to the settled forms. `return_descriptor` on a spec containing all three
    operators reports three `RAW_PERL` canonical fallback events and lists all three statements as
    language-agnostic blockers. Rust code-read: `rust/linkedspec-core/src/expr.rs` models `Stmt { expr }`
    only, `expr` has `Call`/`Variable`/`IndexedVar`/literals/fluent chain, and
    `rust/linkedspec-runtime/src/engine.rs::execute_block()` evaluates each expression statement (with only the
    special top-level `set_key(...)` mutation hook). Therefore `.1.3.4` becomes a container. No engine/book
    behavior change in this split slice.
  Commit: `SPEC-FORMAT-TERSE.1.3.4 — split operator syntax family into scalar, array, and hash leaves`; prior node reference: `SPEC-FORMAT-TERSE.1.3.4` (see Commit Log); retained completion note: Docs/tree/KM/live-doc split slice only. Operator forms are currently RAW_PERL blockers on Perl and unsupported by Rust's expression-statement-only lifecycle AST. Frontier becomes `.1.3.4.1` scalar assignment operator.

- ID: `SPEC-FORMAT-TERSE.1.3.4.1`
  Status: `done` (2026-06-29)
  Goal: Scalar assignment operator — `name = value` lowers/runs identically to `set(name, value)` /
    `assign(name, value)`.
  Acceptance: Perl recognizes top-level scalar assignment statements without leaving RAW_PERL fallback and
    emits the same scalar assignment as the settled `set(...)` form; Rust parses and executes the same scalar
    assignment statement without broadening value-position bare-word reads; both variants have focused locks
    proving equivalence to `set(name,value)` plus no regression to keyword args (`helper(name=value)`) or
    equality-like future operator syntax.
  Verification: **DONE 2026-06-29.** Perl now recognizes statement-level `NAME = RHS` through an explicit
    `scalar_assignment_operator` ASSIGN contract, scanner event, and lowering path that emits the same scalar
    assignment as `set(NAME,RHS)` / `assign(NAME,RHS)`. The auto-working-var collector records the bare scalar
    target so generated handlers get exactly one `my $NAME` preamble. Rust now has a statement-only
    `Expr::AssignScalar` AST variant, parses the operator only at block-statement boundaries, executes it via
    `RuntimeContext::set_scalar`, and rejects nested assignment expressions during value evaluation. The parser
    boundary is intentionally narrow: `name == value`, `items += value`, `name[key] = value`, helper keyword
    args such as `declare(scalar, name=entry_group(1))`, and value-position bare-word reads remain outside this
    leaf. **Verification:** TOOLBOX lowerings prove `name = "ok"` emits `$name = "ok"` and `name = cat(...)`
    is byte-identical to `set(name, cat(...))`, while equality/append/hash-index shapes pass through
    unchanged; descriptor/source/runtime probes show `ASSIGN,RETURN`, fallback count 0, exactly one scalar
    declaration, no array/hash declaration, and stable same-parser output. `perl -c` clean on edited Perl
    modules/test/generator; `prove -q -Iperl t/phase0_regression.t` PASS (`1..977`); oracle corpus regenerated
    with 14 fixtures; focused Rust core `scalar_assignment` tests PASS; focused Rust runtime `terse_1_3_4_1`
    tests PASS; full Rust runtime suite PASS (116 unit + corpus-oracle harness + 41 integration tests);
    mdBook, doctrine, memory-architecture, and local CI gates recorded in the close-out.
  Commit: `SPEC-FORMAT-TERSE.1.3.4.1 — implement scalar assignment operator name = value`; prior node reference: `SPEC-FORMAT-TERSE.1.3.4.1` (see Commit Log); retained completion note: Perl and Rust now support statement-level scalar `name = value` as equivalent to `set(name,value)` / `assign(name,value)`, with focused locks proving the narrow boundary and no Channel 2 broadening. Frontier becomes `.1.3.4.2` array append operator.

- ID: `SPEC-FORMAT-TERSE.1.3.4.2`
  Status: `done` (2026-06-29)
  Goal: Array append operator — `items += value` lowers/runs identically to the settled explicit append form.
  Acceptance: Perl and Rust append one value to the named working array; the value expression follows the
    conservative `.1.3.2` disambiguation contract (bare working-variable values remain deferred to Channel 2
    unless explicitly wrapped); existing child-call `push(...)` semantics stay unchanged.
  Verification: **DONE 2026-06-29.** Perl now recognizes statement-level `NAME += RHS` through an explicit
    `array_append_operator` PUSH contract, scanner event, and lowering path that emits the same direct push as
    `push(NAME,RHS)` / `push_value(NAME,RHS)` for explicit RHS expressions. The auto-working-var collector
    records the bare array target so generated handlers get exactly one `my @NAME` preamble. Rust now has a
    statement-only `Expr::AssignArrayAppend` AST variant, parses the operator only at block-statement
    boundaries, executes it by evaluating RHS then calling `RuntimeContext::push_value`, and rejects nested
    append expressions during value evaluation. The boundary is intentionally narrow: `items += scalar(value)`
    works, while `items += value` stayed deferred to Channel 2 at this leaf; increment-like `items ++`, child-call
    `push(A,B)`, scalar assignment, and hash-index assignment remain separate. **Verification:** TOOLBOX
    lowerings prove `items += "a"` emits `push @items, "a"` and `items += cat(...)` / `items += scalar(...)`
    lower identically to explicit append forms, while bare RHS and out-of-scope operators remain unchanged;
    descriptor/source/runtime probes show `PUSH,RETURN`, fallback count 0, exactly one array declaration, no
    scalar/hash declaration, and stable same-parser output. `perl -c` clean on edited Perl modules/test/
    generator; `prove -q -Iperl t/phase0_regression.t` PASS (`1..978`); oracle corpus regenerated with 15
    fixtures; focused Rust core `array_append` tests PASS; focused Rust core `scalar_assignment` regression
    tests PASS; focused Rust runtime `terse_1_3_4_2` tests PASS; Rust corpus oracle PASS over 15 fixtures;
    full Rust runtime suite PASS (116 unit + corpus-oracle harness + 43 integration tests); mdBook, doctrine,
    memory-architecture, and local CI gates recorded in the close-out. Later `.1.2.3.3.2` / `.1.2.3.4`
    closed the accepted scalar bare RHS read on Perl/Rust.
  Commit: `SPEC-FORMAT-TERSE.1.3.4.2 — implement array append operator items += value`; prior node reference: `SPEC-FORMAT-TERSE.1.3.4.2` (see Commit Log); retained completion note: Perl and Rust now support statement-level array `items += value` as equivalent to explicit append forms for explicit RHS expressions, with locks proving bare RHS remains deferred to Channel 2. Frontier becomes `.1.3.4.3` hash-index assignment operator.

- ID: `SPEC-FORMAT-TERSE.1.3.4.3`
  Status: `done` (2026-06-29)
  Goal: Hash-index assignment operator — `name[key] = value` lowers/runs identically to
    `set_key(name, key, value)`.
  Acceptance: Perl and Rust mutate the named working hash at the supplied key expression; nested/indexed value
    reads remain scoped to the already-supported key-expression helpers and do not claim the broader Channel 2
    bare value-position read model.
  Verification: **DONE 2026-06-29.** Perl now recognizes statement-level `NAME[KEY] = RHS` through an
    explicit `hash_index_assignment_operator` ASSIGN contract, scanner event, and lowering path that emits the
    same direct hash mutation as `set_key(NAME, KEY, RHS)`. The scanner/lowerer parse brackets and assignment
    boundaries with quote/nesting awareness, so keys such as `cat("s","tage")` work without comma-splitting
    mistakes. The auto-working-var collector records the bare hash target only when the same parser accepts the
    statement, giving generated handlers exactly one `my %NAME` preamble. Rust now has a statement-only
    `Expr::AssignHashIndex` AST variant, parses it before scalar assignment/array append fallback, evaluates the
    key to a string, mutates the per-parse hash map with `RuntimeContext::set_hash_entry`, and rejects nested
    hash-index assignment expressions during value evaluation. The boundary is intentionally narrow:
    `meta["stage"] = "v"`, `meta[cat("s","tage")] = cat("v","!")`, and
    `meta[scalar(key)] = scalar(value)` lower/run like `set_key(...)`; bare key/RHS forms such as
    `meta[key] = "v"` and `meta["stage"] = value` stayed deferred to Channel 2 at this leaf, and the later
    `.1.2.3.3.2` / `.1.2.3.4` leaves closed the accepted scalar bare key/RHS reads. **Verification:** TOOLBOX
    lowerings prove the accepted operator shapes lower like `set_key(...)` while bare key/RHS boundaries remain
    unchanged; `perl -c` clean on edited Perl modules/test/generator; `prove -q -Iperl t/phase0_regression.t`
    PASS (`1..979`); oracle corpus regenerated with 16 fixtures; focused Rust core `hash_index` tests PASS;
    Rust scalar/array operator regression tests PASS; focused Rust runtime `terse_1_3_4_3` tests PASS; Rust
    corpus oracle PASS over 16 fixtures; mdBook, doctrine, memory-architecture, and local CI gates recorded in
    the close-out.
  Commit: `SPEC-FORMAT-TERSE.1.3.4.3 — implement hash-index assignment operator name[key] = value`; prior node reference: `SPEC-FORMAT-TERSE.1.3.4.3` (see Commit Log); retained completion note: Perl and Rust now support statement-level hash-index `name[key] = value` as equivalent to `set_key(name,key,value)` for explicit key/value expressions, with locks proving bare key/RHS remain deferred to Channel 2. `.1.3.4` and `.1.3` close; frontier becomes `.1.5`.

- ID: `SPEC-FORMAT-TERSE.1.4`
  Status: `done` (2026-06-29 — SPLIT 2026-06-24 by variant, then closed by `.1.4.1` + `.1.4.2`. TOOLBOX-first
    `call_spec_handler_subst` ground truth established three distinct helper-rename shapes: `cat` pure alias,
    `set` statement-level alias, `copy` unified array/hash dispatch. **`.1.4.1` DONE 2026-06-24** (Perl
    reference — aliases recognized at every canonical-name site; all 20 specs byte-identical; +4 phase0 locks
    → 975; gate EXIT 0; book taught). **`.1.4.2` DONE 2026-06-29** (Rust lockstep parity — `Engine::call_helper()`
    recognizes `set`/`cat` and unified `copy`; 2 oracle fixtures + 3 integration locks; cargo/clippy/phase0/full
    gate green; no book change). KM card [[terse-helper-rename-lowering-sites]] updated. `.1.4.1` is now landed
    against the universal contract on both variants.)
  Goal: Helper renames — `assign`→`set`, `concat`→`cat`, `array_copy`/`hash_copy`→`copy` (new terse names
    become canonical; old names kept as deprecated aliases that lower identically — gradual, ADR 0007)
  Children: `.1.4.1` (Perl reference), `.1.4.2` (Rust lockstep parity)
  Commit: `SPEC-FORMAT-TERSE.1.4 — split into .1.4.1 (Perl reference) + .1.4.2 (Rust parity); record helper-rename lowering-site ground truth + KM card`; table label: `SPEC-FORMAT-TERSE.1.4` (split); retained completion note: `.1.4` → container after a TOOLBOX-first `call_spec_handler_subst` ground-truth pass: the three terse spellings `set`/`cat`/`copy` are currently unrecognized, and the change spans separable Perl + Rust ownership areas (ADR 0006 lockstep). `.1.4.1` (Perl: `cat`=normalize, `set`=statement-level, `copy`=unified array/hash dispatch) is the first frontier child; `.1.4.2` is its Rust parity. KM [[terse-helper-rename-lowering-sites]]. DOCS/TREE/KM only — no engine/book change.

- ID: `SPEC-FORMAT-TERSE.1.4.1`
  Status: `done` (2026-06-24)
  Goal: Perl reference — recognize the terse rename spellings `set`/`cat`/`copy` so each lowers
    **identically** to its canonical helper: `set(target, val)` ≡ `assign(target, val)` (scalar
    `$target = val`); `cat(...)` ≡ `concat(...)` (the concat do-block); and one unified `copy(name)` ≡
    `array_copy(name)` for arrays (`[@name]`) and ≡ `hash_copy(name)` for hashes (`{%name}`), resolving
    array-vs-hash by the wrapped symbol kind at lowering time. The old names keep lowering unchanged
    (deprecated aliases during migration — gradual, ADR 0007; retirement is a later explicit leaf).
  Acceptance: (1) `call_spec_handler_subst` proves byte-equal lowering: `set(scalar(x),1)` == `assign(...)`
    (`$x = 1`), `cat("a","b")` == `concat("a","b")`, `copy(a(x))` == `array_copy(a(x))` (`[@x]`),
    `copy(h(x))` == `hash_copy(h(x))` (`{%x}`); (2) the canonical/old-name lowering is byte-UNCHANGED, so
    all 20 shipped specs (which use the old names) generate byte-identical source — proven by a
    mine-vs-stashed all-spec diff (mirrors `.1.1.1`/`.1.2.1`); (3) the all-target ActionIR-ready ratio is
    1.0000 (ADR 0002); (4) `t/phase0_regression.t` green (currently 971) with new locks proving the three
    new spellings lower identically to their canonical AND the old names are unchanged; (5)
    `bash tools/run_ci_local.sh` EXIT 0; (6) book updated to teach the terse spellings as canonical with the
    old names as deprecated aliases (the affected pages are `dsl/value-container-flow-helper-reference.md`,
    `appendix/helper-contract-catalog.md`, `dsl/declaration-helper-reference.md`). **Ground-truth design
    (confirmed, dump-don't-guess):** `cat`→`concat` is a pure rename → extend `_normalize_method_name`
    (`ActionIR/MethodExpr.pm:19-26`); `set`→`assign` is STATEMENT-level (`ActionIR/Contracts.pm:1749/1753`
    `\bassign\s*\(` recognition + `ActionIR/DeclareMethod._lower_assign_method_statement` +
    `ActionIR/MethodLowering._lower_assign_statement`) and is NOT reached by `_normalize_method_name` alone
    (probe: `set(...)` fully passes through) — so `set` must be added to the statement-level recognition
    (resolve the exact seam with `dump_parser_source` in this leaf); `copy` is NOT a pure rename — add a
    dedicated `copy` dispatch in `MethodLowering._lower_method_value_expr` (beside `array_copy`@1553 /
    `hash_copy`@1533) that tries `extract_array_symbol_name` then `extract_hash_symbol_name`.
  Verification: **DONE 2026-06-24.** TOOLBOX-first `call_spec_handler_subst` (dump-don't-guess; `perl -Iperl`
    confirmed `perl/LinkedSpec.pm`). Implemented the three shapes the ground-truth pass prescribed AND every
    other site each canonical name is recognized, so the aliases lower **byte-identically in every position**:
    (i) `cat`→`concat` + `set`→`assign` added to `_normalize_method_name` (`ActionIR/MethodExpr.pm`); (ii) `set`
    statement-level recognition extended (`\bassign\s*\(`→`\b(?:assign|set)\s*\(`) at the `assign_value`
    contract (`ActionIR/Contracts.pm`), its IR-event scanner `_scan_contract_assign_value`
    (`ActionIR/Scanner/PrimitivePipelineRules.pm`), and the bare-arg auto-`my` collector
    (`RuleIR/EmitContext.pm` — `.1.2.1` parity, so bare `set(name,…)` auto-exists like `assign`); (iii) a
    dedicated `copy` dispatch in `MethodLowering._lower_method_value_expr` (array symbol first then hash,
    `*_symbol_expr_re`-guarded), plus `copy` added to the array/hash declare-initializer recognizers
    (`DeclareMethod` 136/163), the return-payload guard+rewriter helper lists (`MethodLowering` 1650/1658), the
    FlowExpr value-expr prefix list (`FlowExpr.pm` :270, assignment-source path), the bootstrap general-payload
    gate (`BootstrapSpec/Core.pm`, `cat`), and — to keep `copy` first-class in array-vs-hash type inference for
    reducers/`coalesce` — the four `looks_like_{array,hash}_value_expr` recognizers (`MethodLowering` +
    `FlowExpr`), each resolving `copy(X)`'s kind array-first. **Acceptance proven:** `call_spec_handler_subst`
    byte-equal for the 4 headline forms AND 11 composed forms (scalar/array/hash assignment source, push value,
    nested return payload, `num_sum`/`num_avg`/`coalesce` over `copy`); `set` produces the same `ASSIGN`
    canonical ActionIR node as `assign` (`return_descriptor`); a real terse spec (`set`+`cat`+`copy`) runs
    end-to-end **byte-identical** to its canonical twin (`["a!","b!","c!"]`), stable across a re-run.
    **Byte-identical proof:** generated source for all 20 shipped specs, baseline-vs-mine, **0 diff** (old names
    byte-unchanged — every alias add is guarded by the new spelling, which no shipped spec uses). **+4 phase0
    subtests / 31 assertions** (`spec_format_terse_1_4_1_*`): **phase0 971→975 green**; `bash
    tools/run_ci_local.sh` **EXIT 0** ("Result: PASS", 975); ratio 1.0000 (all-target guard green); `perl -c`
    clean on all 8 edited modules; `mdbook build` EXIT 0. **Book (3 pages):** taught the terse renames as
    canonical with the old names as deprecated (not-yet-retired) aliases —
    `appendix/helper-contract-catalog.md` (per-helper Terse-spelling lines + a new "Terse Helper Renames"
    subsection), `dsl/value-container-flow-helper-reference.md`, `dsl/declaration-helper-reference.md`.
    **Scope (signoff):** no open boundary remained — `copy` is resolved by symbol kind at every recognized
    site (including the type-inference recognizers), so there is no `copy`-as-reducer-subject gap. KM card
    [[terse-helper-rename-lowering-sites]] updated (`.1.4.1` landed; full site list; reverify now proves parity).
  Commit: `SPEC-FORMAT-TERSE.1.4.1 — Perl recognize terse renames set/cat/copy lowering identically to assign/concat/array_copy+hash_copy (engine + book + 4 phase0 locks)`; prior node reference: `SPEC-FORMAT-TERSE.1.4.1` (see Commit Log); retained completion note: Recognized the aliases at every site each canonical name is (normalize seam for `cat`/`set`; 3 raw-text `set` scanners; dedicated array-then-hash `copy` dispatch; declare-init / return-payload / FlowExpr-source / type-inference recognizers). 4 headline + 11 composed forms byte-equal to canonical; `set`==`assign` ASSIGN node; terse spec runs == canonical twin end-to-end; **all 20 specs byte-identical**; +4 phase0 locks → **975 green**; gate EXIT 0; ratio 1.0000; book taught (3 pages, renames canonical + old names deprecated-not-retired). `.1.4.1` landed on the Perl reference; `.1.4.2` (Rust parity) is next.

- ID: `SPEC-FORMAT-TERSE.1.4.2`
  Status: `done` (2026-06-29)
  Goal: Rust lockstep parity for `.1.4.1` (ADR 0006) — `Engine::call_helper()`
    (`rust/linkedspec-runtime/src/engine.rs`) recognizes `set`/`cat`/`copy` identically: pipe the rename
    onto the canonical arm where it is a pure alias (`"assign" | "set"` @711, `"concat" | "cat"` @820), and
    add a dedicated value-type-dispatching `"copy"` arm (Array→clone array, Hash→clone hash, else resolve
    the named target) since `"copy"` cannot appear in both the `array_copy`@735 and `hash_copy`@1833 arms.
  Acceptance: cargo suite green; oracle cross-check parity holds for `set`/`cat`/`copy` (Rust == the Perl
    reference value) on non-recursive specs; lock with oracle fixtures + integration tests mirroring
    `.1.2.2`; `t/phase0_regression.t` 975 untouched (Perl); `bash tools/run_ci_local.sh` EXIT 0; clippy
    zero-new; no book change (variant-agnostic — `.1.4.1` teaches the contract; Rust conforms). The
    `.1.4.1` change is "landed against the universal contract" only once this closes.
  Verification: **DONE 2026-06-29.** Rust `Engine::call_helper()` now dispatches `"assign" | "set"` and
    `"concat" | "cat"` through the existing canonical arms, and adds a dedicated `"copy"` arm. `copy` clones
    already-materialized `RuntimeValue::Array`/`RuntimeValue::Hash` values, resolves wrapped array targets via
    `resolve_array_target(..., allow_bare=false)`, and resolves wrapped hash targets via the new
    `resolve_hash_target(..., allow_bare=false)`; the `hash`/`h` helper now also treats one bare variable
    argument as a named hash reference so `copy(h(m))` and `hash_copy(h(m))` converge. This keeps the array-then-
    hash resolution scoped to wrapped targets; Channel 2 bare value-position reads remain deferred. **Locked:**
    2 oracle corpus fixtures generated from the Perl reference (`terse_1_4_2_set_cat_copy_array`,
    `terse_1_4_2_copy_hash_symbol_empty`) + 3 integration tests (`set`+`cat`+`copy(array)` parity, hash target
    and hash value copy parity, and per-parse bare `set` target semantics). **Verification:** `perl -c
    tools/gen_oracle_corpus.pl` OK; `perl -Iperl tools/gen_oracle_corpus.pl` regenerated 11 fixtures; focused
    `cargo test --manifest-path rust/linkedspec-runtime/Cargo.toml terse_1_4_2 -- --nocapture` PASS (3 tests);
    `cargo test --manifest-path rust/linkedspec-runtime/Cargo.toml --test corpus_oracle -- --nocapture` PASS
    (11 fixtures); full `cargo test --manifest-path rust/linkedspec-runtime/Cargo.toml` PASS (116 unit + 1
    corpus-oracle harness over 11 fixtures + 36 integration tests); `cargo clippy
    --manifest-path rust/linkedspec-runtime/Cargo.toml` EXIT 0 with the existing baseline warnings only
    (11 engine + 2 helpers, zero-new from this slice); `perl -Iperl t/phase0_regression.t` PASS (`1..975`,
    Perl untouched); `bash tools/run_ci_local.sh` EXIT 0. No mdBook change: `.1.4.1` already documented the
    variant-neutral helper contract and this slice makes Rust conform.
  Commit: `SPEC-FORMAT-TERSE.1.4.2` (see Commit Log)

- ID: `SPEC-FORMAT-TERSE.1.5`
  Status: `done` / `closed` (2026-06-29 — split by literal/call/separator/access surface; children complete)
  Goal: Literals, nested access, call + semicolon rules
  Children: `.1.5.1`, `.1.5.2`, `.1.5.3`, `.1.5.4`, `.1.5.5`

- ID: `SPEC-FORMAT-TERSE.1.5.1`
  Status: `done` (2026-06-29 — ground truth + split)
  Goal: Establish exact current behavior for literals, nested access, call spacing, and semicolon/newline
    separators, then split `.1.5` before implementation.
  Acceptance: KM retrieval, TOOLBOX probes, and Perl/Rust code-read identify which parts are already true,
    which parts need parity locks, and which parts require new semantics; `.1.5` becomes an active container
    with executable child leaves; no implementation code changes in this audit slice.
  Verification: TOOLBOX `call_spec_handler_subst` probes over literal returns, call whitespace, direct
    nested access, and existing `scalaref(...)` lowering; `LinkedSpec::Get` runtime probes for primitive
    literal outputs and separator behavior; `StatementSplit` probes for top-level statement detection;
    Rust code-read of `expr.rs` + `engine.rs`; `cargo test --quiet --manifest-path
    rust/linkedspec-core/Cargo.toml parse_` PASS (41 core parser tests + 1 filtered types test, existing
    rgx/pgen warnings); `cargo test --manifest-path rust/linkedspec-core/Cargo.toml hash_index -- --nocapture`
    PASS. Result: Perl strings/numbers/`undef` already run; Perl `true`/`false` currently return strings,
    not typed booleans; optional whitespace before `(` works at real helper/value sites; newline-separated
    adjacent lowered statements still fail without `;` on Perl; Rust accepts newline-separated parser tests
    but currently has broader whitespace-separated parsing; direct `foo["a"][9]['b'][z]` is not lowered on
    Perl and Rust only has single array-index `IndexedVar`, so direct any-depth mixed access remains open.
  Commit: `SPEC-FORMAT-TERSE.1.5 — split literals/access/call/separator surface`

- ID: `SPEC-FORMAT-TERSE.1.5.2`
  Status: `done` (2026-06-29)
  Goal: Primitive literal parity and locks.
  Acceptance: `"..."`, `'...'`, integer, float, `true`, `false`, and `undef` are accepted as typed value
    literals in return payloads and representative mutation/value-expression RHS positions on Perl and Rust;
    Perl/Rust agree on observable JSON values; `true`/`false` are booleans, not Perl bareword strings; prefix
    identifiers such as `trueword`/`undefine` remain out of the literal path.
  Verification: **DONE 2026-06-29.** Perl gained a shared
    `ActionIR::ValueExpr::_lower_primitive_literal_expr` path for exact string, numeric, `undef`, `true`, and
    `false` literals. `true`/`false` lower to `JSON::PP::true` / `JSON::PP::false`, so the public JSON value
    shape is typed boolean rather than `"true"`/`"false"`. The helper is wired through return/value lowering,
    flow expressions, scalar/hash access key lowering, mutation RHS guards, scanner contracts, and legacy
    `push(...)` disambiguation: `push(items,false)` is an explicit append, while `push(items,trueword)` keeps
    the all-bare child-call interpretation. Rust already had typed literal expressions; this leaf added
    statement-form `if(cond); elseif(cond); else(); endif()` gating in `Engine::execute_block()` for one-arg
    marker controls, while leaving multi-arg `if(cond, then, else)` as the existing lazy value helper. **Locks:**
    +1 Perl phase0 subtest (`spec_format_terse_1_5_2_primitive_literal_parity`, 18 assertions), +2 Rust
    integration tests, +2 oracle corpus fixtures (`terse_1_5_2_primitive_literals`,
    `terse_1_5_2_boolean_mutation_flow`). **Verification:** syntax checks on edited Perl modules/test/generator;
    `env PERL5LIB= prove -q -Iperl t/phase0_regression.t` PASS (`1..980`); `perl -Iperl
    tools/gen_oracle_corpus.pl` regenerated 18 fixtures; focused `cargo test --quiet --manifest-path
    rust/linkedspec-runtime/Cargo.toml terse_1_5_2 -- --nocapture` PASS (2 tests); `cargo test --quiet
    --manifest-path rust/linkedspec-runtime/Cargo.toml --test corpus_oracle -- --nocapture` PASS over 18
    fixtures; full runtime/mdBook/KM/memory/doctrine/local gates recorded in the Verification Log.
  Commit: `SPEC-FORMAT-TERSE.1.5.2 — implement primitive literal parity` (see Commit Log); retained completion note: Primitive literals are typed values on Perl/Rust; Perl booleans now lower through `JSON::PP`, exact matching preserves identifier prefixes, `push(items,false)` is a value append, and Rust statement-form `if(false)` gates inactive branches. Frontier becomes `.1.5.3`.

- ID: `SPEC-FORMAT-TERSE.1.5.3`
  Status: `done` (2026-06-29)
  Goal: Function-call spacing and mandatory-call-parentheses locks.
  Acceptance: Calls still require `()`; optional whitespace before `(` is accepted at every already-supported
    statement and value-expression site (`return (val)`, `set (name,val)`, `cat ("a","b")`,
    `scalar (name)`, operator RHS/key expressions), without accepting bare no-paren helper keywords.
  Verification: **DONE 2026-06-29.** No production semantic broadening was needed; this leaf locks the existing
    helper-call grammar. Perl phase0 now proves optional whitespace before `(` lowers byte-identically to tight
    calls for `return`, `set`, nested `cat`/`scalar`/`array`, array-append RHS calls, and hash-index key/RHS
    calls, while `return(cat "a","b")`, `set name,"v"`, and `return scalar name` remain outside helper-call
    recognition. A runtime spec with spaced `set`, `cat`, `scalar`, `array`, `array_copy`, `hash`, and
    `hash_copy` calls returns `["ab",["cd"],{"stage":"ab"}]` and reports canonical `ASSIGN,PUSH,RETURN` nodes
    with fallback count 0. Rust core parser locks prove whitespace-before-`(` call parsing and no-paren
    keyword non-recognition; Rust runtime integration plus the Perl oracle fixture prove the same typed output.
    **Verification:** `perl -Iperl -c t/phase0_regression.t` PASS; `perl -Iperl -c tools/gen_oracle_corpus.pl`
    PASS; focused Rust parser/runtime `.1.5.3` tests PASS; `perl -Iperl tools/gen_oracle_corpus.pl`
    regenerated 19 fixtures; `cargo test --quiet --manifest-path rust/linkedspec-runtime/Cargo.toml --test
    corpus_oracle -- --nocapture` PASS over 19 fixtures; `env PERL5LIB= prove -q -Iperl t/phase0_regression.t`
    PASS (`1..981`). Full runtime/mdBook/KM/memory/doctrine/local gates are recorded in the Verification Log.
  Commit: `SPEC-FORMAT-TERSE.1.5.3 — lock call spacing and mandatory parentheses` (see Commit Log); retained completion note: Optional whitespace before `(` is locked at supported helper/value sites on Perl and Rust, while no-parenthesis helper spellings remain outside call recognition. Frontier becomes `.1.5.4`.

- ID: `SPEC-FORMAT-TERSE.1.5.4`
  Status: `done` (2026-06-29)
  Goal: Statement separator contract.
  Acceptance: Newlines separate top-level canonical DSL statements; semicolons remain accepted and are
    required only when multiple statements share one physical line. Perl lowering emits valid generated Perl
    for newline-separated statements; same-line adjacent statements without `;` are rejected or left as
    explicit blockers consistently with Rust; semicolons inside nested expressions/literals stay protected.
  Verification: **DONE 2026-06-29.** Perl `StatementSplit` now requires a line break before implicit
    statement-boundary splitting and keeps same-line adjacent helpers as raw blockers. Perl `RewritePipeline`
    inserts a generated `;` when adjacent lowered canonical statements were newline-separated in source and
    leaves author semicolons unchanged. Bootstrap normalizes captured fluent attached-control tails with
    internal newline separators, preserving `Top.if(...) { ... } elseif(...) { ... } else { ... }` and
    lifecycle equivalents without re-opening arbitrary same-line helper adjacency. Rust `linkedspec-core`
    now distinguishes inline whitespace from statement-separator whitespace: newline or `;` separates
    statements, while same-line whitespace does not. New locks cover splitter behavior, lowering output,
    runtime execution, nested-semicolon payload protection, generated corpus parity, and mdBook wording.
    **Verification:** `perl -Iperl -c` for changed Perl modules PASS; `perl -Iperl -c
    t/phase0_regression.t` PASS; `env PERL5LIB= prove -q -Iperl t/phase0_regression.t` PASS (`1..982`);
    `perl -Iperl tools/gen_oracle_corpus.pl` regenerated 20 fixtures; focused Rust core parser tests PASS;
    focused Rust runtime `.1.5.4` integration test PASS; Rust corpus oracle PASS over 20 fixtures; full Rust
    runtime suite PASS; `mdbook build docs/linkedspec-book` PASS; Knowledge Map regenerate/check PASS;
    memory/doctrine checks PASS; `git diff --check` PASS; `bash tools/run_ci_local.sh` PASS.
  Commit: `SPEC-FORMAT-TERSE.1.5.4 — lock statement separators` (see Commit Log); retained completion note: Newline-or-semicolon statement separation is locked on Perl and Rust. Same-line multiple statements require `;`; nested semicolons stay protected; fluent attached-control tails keep working through Bootstrap newline normalization. Frontier becomes `.1.5.5`.

- ID: `SPEC-FORMAT-TERSE.1.5.5`
  Status: `done` (2026-06-29 — split before code)
  Goal: Direct nested access surface.
  Children: `.1.5.5.1` (explicit segment expressions), `.1.5.5.2` (bare path-segment / Channel 2
    coordination)
  Acceptance: Any-depth mixed access `foo["a"][9]['b'][z]` is designed and implemented on both variants, or
    split before code if the Channel 2 dependency is still too broad. The result must define base/value/index
    semantics explicitly, coordinate with `.1.2.3` value-position bare-word reads, and preserve the then-existing
    `scalaref(base, path)` behavior until the direct syntax fully supersedes it. That legacy helper was later
    retired under `SCALAREF-RETIREMENT`.
  Verification: **SPLIT 2026-06-29.** KM retrieval first (`terse-literals-calls-separators-access-ground-truth`,
    `terse-bare-working-vars-engine-gaps`), then TOOLBOX probes and code-read. Direct
    `return(foo["a"][9]["b"][scalar(z)])` currently rewrites to invalid Perl-shaped
    `return foo["a"][9]["b"][$z]`, and a generated-source/runtime probe fails handler compilation near `][`.
    The existing explicit helper `return(scalaref(foo,{"a"}[9]{"b"}[scalar(z)]))` lowers correctly to
    `$foo->{"a"}->[9]->{"b"}->[$z]`. Bare segment `z` remains a bare atom in both direct and `scalaref`
    probes, matching the open Channel 2 value-position-read gap. Rust code-read shows only single-level
    `IndexedVar { name, index }` parsing/evaluation today. Therefore `.1.5.5` becomes a container before any
    implementation code. No engine/book behavior change in this split slice.
  Commit: `SPEC-FORMAT-TERSE.1.5.5 — split direct access by Channel 2 boundary` (see Commit Log); retained completion note: `.1.5.5` is now a container. `.1.5.5.1` owns direct nested access with explicit path segments; `.1.5.5.2` owns the bare path-segment / Channel 2 value-position-read coordination. Frontier becomes `.1.5.5.1`.

- ID: `SPEC-FORMAT-TERSE.1.5.5.1`
  Status: `done` (2026-06-29)
  Goal: Direct nested access with explicit path segments.
  Acceptance: Perl and Rust accept any-depth mixed direct bracket access with explicit segment expressions,
    e.g. `foo["a"][9]["b"][scalar(z)]`, while preserving the then-existing `scalaref(base,path)` explicit helper.
    That legacy helper was later retired under `SCALAREF-RETIREMENT`.
    Segment kind semantics are documented and locked conservatively: quoted string segments are hash keys,
    numeric segments are array indexes, and helper/value expressions in brackets are explicit index
    expressions unless later Channel 2 work deliberately broadens them. Bare path segments such as `[z]` remain
    out of scope for this leaf.
  Verification: **DONE 2026-06-29.** Perl now lowers direct nested access in value positions through
    `ActionIR::ValueExpr::_lower_direct_nested_access_value_expr`, reusing the then-existing `scalaref(...)`
    segment splitter/lowerer so explicit paths produced the same dereference chain:
    `foo["a"][9]["b"][scalar(z)]` -> `$foo->{"a"}->[9]->{"b"}->[$z]`. Single-quoted key segments are hash
    keys too. Bare path atoms such as `[z]` deliberately remain outside the canonical lowering. Rust core now
    models `AccessSegment::{Key,Index}` and `Expr::NestedAccess`; one-level non-key `name[index]` stays the
    legacy `IndexedVar`, while mixed/multi-segment explicit access becomes `NestedAccess` and bare nested
    segments are rejected as Channel 2-reserved. Rust runtime evaluates the path by walking hash keys and array
    indexes from the scalar-held base value. **Locks:** Perl phase0 subtest
    `spec_format_terse_1_5_5_1_direct_nested_access_explicit_segments`; Rust parser tests
    `parse_direct_nested_access_*`; Rust runtime test
    `terse_1_5_5_1_direct_nested_access_explicit_segments_run`; oracle fixture
    `terse_1_5_5_1_direct_nested_access`; mdBook/KM/live-doc updates. Focused syntax/Rust/oracle checks are
    green; full gates are recorded in the Verification Log.
  Commit: `SPEC-FORMAT-TERSE.1.5.5.1 — implement direct nested access explicit segments` (see Commit Log); retained completion note: Perl and Rust now accept explicit mixed direct access such as `foo["a"][9]["b"][scalar(z)]`; `scalaref(...)` remains accepted; bare path atoms stay deferred to `.1.5.5.2` / Channel 2. Frontier becomes `.1.5.5.2`.

- ID: `SPEC-FORMAT-TERSE.1.5.5.2`
  Status: `superseded` (2026-06-29 — merged into `SPEC-FORMAT-TERSE.1.2.3`)
  Goal: Bare path-segment / Channel 2 coordination for direct access.
  Acceptance: The full brainstorm spelling `foo["a"][9]["b"][z]` is implemented only after the project has a
    coherent value-position bare-word read model, or this leaf is merged into the future `.1.2.3` Channel 2
    work with explicit task-tree evidence. This leaf must define how bare path atoms choose scalar/array/hash
    reads and key-vs-index semantics without breaking existing child-call and helper-call boundaries.
  Verification: **SUPERSEDED 2026-06-29.** KM retrieval plus a focused TOOLBOX reverify confirmed the boundary
    still holds after `.1.5.5.1`: `return(foo["a"][9]["b"][scalar(z)])` lowers to
    `$foo->{"a"}->[9]->{"b"}->[$z]`, while `return(foo["a"][9]["b"][z])` remains raw
    `return foo["a"][9]["b"][z]` and `return(z)` remains `return z`. Rust keeps a parser lock rejecting bare
    direct-access segments as Channel 2-reserved. Therefore implementing `[z]` inside direct access would
    pre-empt the global value-position bare-word-read model. This leaf is merged into new `.1.2.3`, which owns
    `return(name)`, bare direct-access path atoms, bare RHS/key expressions, RHS-shape inference, and the
    Perl/Rust lockstep split.
  Commit: `SPEC-FORMAT-TERSE.1.5.5.2 — merge bare direct access into Channel 2` (see Commit Log); retained completion note: No engine/book behavior change. `.1.5.5.2` is superseded into new `.1.2.3` because bare direct-access path atoms share the global value-position bare-word-read model. Frontier becomes `.1.2.3`.

- ID: `SPEC-FORMAT-TERSE.1.6`
  Status: `done` (2026-06-29)
  Goal: Array mutation methods — `.push_front(v)`, `.push_back(v)`, `.pop_front()`, `.pop_back()`
  Acceptance: The four array end-mutation methods are recognized and lower to ActionIR.
  Verification: **PASS 2026-06-29.** Perl recognizes statement-level receiver-dot array end mutations on bare
    and explicit array receivers: `items.push_back(value)` -> `push @items, $value`,
    `items.push_front(value)` -> `unshift @items, $value`, `items.pop_back()` -> `pop @items`, and
    `items.pop_front()` -> `shift @items`; `array(items)` and `a(items)` are accepted receiver aliases. Push
    values use the settled mutation-slot value rules, so bare push values read scalar working variables and
    auto-supply matching `my $value`; accepted receivers auto-supply one `my @items`. The contract/scanner
    reports canonical `ARRAY_MUTATE` ActionIR with zero fallback. Rust executes the same single-call
    `Expr::FluentChain` statement forms before generic fluent evaluation, mutating the runtime working array
    and discarding pop return values. Value-returning forms such as `return(items.pop_back())` remain outside
    this statement-only slice. Perl syntax checks PASS; TOOLBOX lowering/runtime/source probes PASS; focused
    Rust parser/runtime `.1.6` tests PASS; oracle corpus regenerated to **33 fixtures** and corpus oracle PASS;
    phase0 PASS (`t/phase0_regression.t`, **990 tests**); mdBook updated.
  Commit: `SPEC-FORMAT-TERSE.1.6 — implement array end-mutation methods` (see Commit Log); retained completion note: Perl and Rust now support statement-level `items.push_back(value)`, `items.push_front(value)`, `items.pop_back()`, and `items.pop_front()` over named working arrays. Added phase0/Rust/oracle/book/KM locks; Round 1 closes and frontier becomes `.2.1`.

- ID: `SPEC-FORMAT-TERSE.2`
  Status: `done` / `closed` (Round 2 expression-valued block, control-flow, and composability leaves complete)
  Goal: Round 2 — control flow (everything is an expression)
  Children: `.2.1`, `.2.2`, `.2.3`

- ID: `SPEC-FORMAT-TERSE.2.1`
  Status: `done` (2026-06-30 — all split children `.2.1.1` through `.2.1.4` landed)
  Goal: Expression-valued blocks — `{ ... }` returns its value (last statement or explicit `return()`)
  Acceptance: A block evaluates to its last statement's value or an explicit `return(...)`; blocks
    compose as expressions.
  Children: `.2.1.1`, `.2.1.2`, `.2.1.3`, `.2.1.4`
  Verification: `.2.1.1` split; `.2.1.2` Perl core; `.2.1.3` Rust parity; `.2.1.4` block-local early
    return. Phase0 and Rust corpus oracle green after `.2.1.4`.
  Commit: `.2.1` container closed by `SPEC-FORMAT-TERSE.2.1.4`

- ID: `SPEC-FORMAT-TERSE.2.1.1`
  Status: `done` (2026-06-29)
  Goal: Expression-valued block ground truth and split before code
  Acceptance: KM retrieval, TOOLBOX lowering/runtime probes, and code-read identify the current Perl/Rust
    behavior, ambiguity with `{}` / `{ key => value }` shape literals, and safe implementation split.
  Verification: KM card `terse-expression-valued-blocks-ground-truth`; TOOLBOX probes showed
    `return({})` and `return({ key => value })` are shape literals, while `return({ set(x,"a"); x })`
    lowers as invalid Perl hash/block syntax and Rust has no block-expression AST variant.
  Commit: `SPEC-FORMAT-TERSE.2.1.1 — split expression-valued blocks`; prior node reference (incorrect; corrected by containment .6): `SPEC-FORMAT-TERSE.3.2.3.2 - implement string comparison helpers`; retained completion note: No engine/book behavior change. `.2.1` is split into Perl-reference core block values (`.2.1.2`), Rust parity (`.2.1.3`), and explicit block-local early-return follow-through (`.2.1.4`). Frontier becomes `.2.1.2`.

- ID: `SPEC-FORMAT-TERSE.2.1.2`
  Status: `done` (2026-06-29)
  Goal: Perl reference — core expression-valued block values
  Acceptance: Non-empty `{ ... }` value payloads without top-level `=>` lower as block expressions in
    value-consuming slots, preserving `{}` and `{ key => value }` as hash literals. The first Perl slice
    supports last-expression value and final `return(expr)` block value forms; full block-local early return
    remains a follow-up if needed.
  Verification: Perl syntax checks; TOOLBOX lowering/runtime probes; `prove -q -Iperl t/phase0_regression.t`
    PASS (**991 tests**); mdBook build PASS; Knowledge Map regenerate/check PASS;
    memory/doctrine/diff checks PASS; full local CI PASS.
  Commit: `SPEC-FORMAT-TERSE.2.1.2 — implement Perl expression-valued blocks`; retained completion note: Perl reference now accepts the core block-value subset in value-consuming sites, preserving hash-literal precedence. Rust parity remains `.2.1.3`; full block-local early return remains `.2.1.4`.

- ID: `SPEC-FORMAT-TERSE.2.1.3`
  Status: `done` (2026-06-29)
  Goal: Rust parity — core expression-valued block values
  Acceptance: Rust parser/runtime add the same block-expression AST/runtime behavior and preserve hash-literal
    disambiguation; oracle fixtures match the Perl reference. Implementation seam is `Expr`/brace parsing in
    `rust/linkedspec-core/src/expr.rs` plus value-returning block evaluation in
    `rust/linkedspec-runtime/src/engine.rs`. Preserve `{}` and keyed top-level `=>` hash literals; only
    non-empty non-fat-arrow brace payloads become block values. Match the Perl core for final expression and
    final `return(expr)` payloads; true mid-block early return remains `.2.1.4`.
  Verification: KM card `terse-rust-expression-valued-block-seams`; Rust code-read; focused core parser locks
    PASS; focused runtime `.2.1.3` locks PASS; oracle corpus regenerated to **34 fixtures** and corpus oracle
    PASS; full Rust core/runtime package suites PASS; mdBook/KM/memory/doctrine/diff checks PASS; full local
    CI PASS (`tools/run_ci_local.sh`, phase0 **991** tests).
  Commit: `SPEC-FORMAT-TERSE.2.1.3 — own Rust expression-valued blocks`; implementation commit pending.; retained completion note: No engine/book behavior change. Rust parser/runtime seams are recorded before code; frontier remains `.2.1.3` implementation.; table reference: `SPEC-FORMAT-TERSE.2.1.3 — implement Rust expression-valued blocks`; retained completion note: Rust parser/runtime parity for the core block-value subset landed with oracle fixture; frontier becomes `.2.1.4`.

- ID: `SPEC-FORMAT-TERSE.2.1.4`
  Status: `done` (2026-06-30)
  Goal: Block-local explicit return semantics and composition follow-through
  Acceptance: True block-local early-return semantics are implemented without leaking into the surrounding
    rule return channel; nested composition is locked and the book is updated.
  Verification: Perl syntax checks; TOOLBOX lowering/runtime probes; focused Rust `.2.1.4` runtime locks;
    oracle corpus regenerated to **35 fixtures** and corpus oracle PASS; phase0 PASS (**991 tests**);
    mdBook/KM/memory/doctrine/diff checks PASS; full local CI PASS.
  Commit: `SPEC-FORMAT-TERSE.2.1.4 — implement block-local return`; retained completion note: Expression-valued blocks now support block-local early `return(expr)` on Perl and Rust without leaking into the surrounding rule return channel. Added Perl/Rust/oracle/book/KM locks; `.2.1` closes and frontier becomes `.2.2`.

- ID: `SPEC-FORMAT-TERSE.2.2`
  Status: `done` / `closed` (split 2026-06-30 by `.2.2.1`; children complete)
  Goal: Control-flow keywords — `if/elseif/else`, `when`, `otherwise`, `default`, `while`, `switch`
  Acceptance: `if (cond) { ... } elseif (cond) { ... } else { ... }` — parens for conditions, blocks
    for bodies, blocks NEVER inside parens; `when (cond) { ... }` inline conditional; `otherwise { ... }`
    and `default { ... }` take no parens/args; `while (cond) { ... }`; `switch (expr) { case(v) { ... }
    default { ... } }`.
  Children: `.2.2.1`, `.2.2.2`, `.2.2.3`, `.2.2.4`, `.2.2.5`, `.2.2.5.1`,
    `.2.2.5.2`, `.2.2.6`, `.2.2.6.1`, `.2.2.6.2`
  Verification: `.2.2.1` split/ground truth done; `.2.2.2` Perl attached-block if done; `.2.2.3` Rust parity
    done by normalizing attached branch statements to the existing marker-control runtime; `.2.2.4` landed
    `when/otherwise` aliases over that attached-if model on Perl and Rust; `.2.2.5` split attached
    `switch/case/default` by Perl separator/source lock and Rust parity; `.2.2.5.1` landed the Perl
    separator/source lock with compact adjacent branches lowering without host residue; `.2.2.5.2` landed Rust
    parser/runtime parity with 38 oracle fixtures. `.2.2.6` split `while` before code; `.2.2.6.1` landed the
    Perl reference loop/safety contract; `.2.2.6.2` landed Rust parser/runtime/oracle parity with 39 fixtures.
  Commit: `SPEC-FORMAT-TERSE.2.2.1 - split control-flow keyword surface`;
    `SPEC-FORMAT-TERSE.2.2.2 - implement Perl attached if blocks`;
    `SPEC-FORMAT-TERSE.2.2.3 - implement Rust attached if blocks`;
    `SPEC-FORMAT-TERSE.2.2.4 - own when otherwise aliases`;
    `SPEC-FORMAT-TERSE.2.2.4 - implement when otherwise aliases`;
    `SPEC-FORMAT-TERSE.2.2.5 - split attached switch surface`;
    `SPEC-FORMAT-TERSE.2.2.5.1 - implement Perl attached switch separator lock`;
    `SPEC-FORMAT-TERSE.2.2.5.2 - implement Rust attached switch blocks`;
    `SPEC-FORMAT-TERSE.2.2.6 - split while loop surface`;
    `SPEC-FORMAT-TERSE.2.2.6.1 - implement Perl attached while safety`;
    `SPEC-FORMAT-TERSE.2.2.6.2 - implement Rust attached while safety`

- ID: `SPEC-FORMAT-TERSE.2.2.1`
  Status: `done` (2026-06-30)
  Goal: Control-flow keyword ground truth and split before code
  Acceptance: KM retrieval, TOOLBOX lowering/runtime/metadata probes, and Perl/Rust code-read identify the
    current portable control-flow contract and split the broad `.2.2` surface into signoff-sized leaves.
  Verification: TOOLBOX `call_spec_handler_subst` + `LinkedSpec::Get(..., return_descriptor => 1)` probes
    showed attached `if(...) { ... } else { ... }` is still a RAW_PERL dependency on the Perl reference
    (`language_agnostic_action_ir_ready=0`), `when(...) { ... } otherwise { ... }` is host-Perl behavior with
    an experimental-warning compile path and not ActionIR-ready, and `while(...) { ... }` is raw. Attached
    `switch(...) { case(...) { ... } default { ... } }` is Perl ActionIR-ready in metadata but has separator
    and Rust-parity risks that warrant a dedicated leaf. Rust code-read shows portable runtime support for
    statement-marker `if(cond); ... elseif(cond); else(); ... endif()` and lazy inline-composite `if`/`switch`,
    but no attached-block statement parser/runtime for `if`, `switch`, `when`, `otherwise`, or `while`.
    mdBook/KM/live docs updated; no engine behavior changed.
  Commit: `SPEC-FORMAT-TERSE.2.2.1 - split control-flow keyword surface`; table reference: `SPEC-FORMAT-TERSE.2.2.1 — split control-flow keyword surface`; retained completion note: No engine behavior change. `.2.2` is split by current support seams: Perl attached-if first, Rust attached-if parity next, then `when`/`otherwise`, attached switch/default, and while. Frontier becomes `.2.2.2`.

- ID: `SPEC-FORMAT-TERSE.2.2.2`
  Status: `done` (2026-06-30)
  Goal: Perl reference — attached-block `if/elseif/else` without explicit `endif`
  Acceptance: `if(cond) { ... } elseif(cond2) { ... } else { ... }` lowers through ActionIR without raw Perl
    fallback, executes only the selected branch, and preserves the existing statement-marker
    `if(cond); ... else(); ... endif()` and inline-composite `if(...)` contracts.
  Verification: `StatementSplit::Core` now splits complete attached `if`/`elseif` branch bodies before same-line
    attached `elseif(...) { ... }` / `else { ... }` continuations. TOOLBOX lowering/metadata probes show compact
    attached-block `if/elseif/else` lowers with zero raw fallback/unresolved helpers and runtime selects only the
    active branch. Perl syntax checks PASS; phase0 PASS (**991 tests**); mdBook build PASS; Knowledge
    Map/memory/doctrine/diff checks PASS. Marker-form and inline-composite `if` contracts preserved.
  Commit: `SPEC-FORMAT-TERSE.2.2.2 - implement Perl attached if blocks`; table reference: `SPEC-FORMAT-TERSE.2.2.2 — own Perl attached if blocks`; exact Git subject: `SPEC-FORMAT-TERSE.2.2.2 - own Perl attached if blocks`; retained completion note: No engine behavior change. Perl attached-block if ownership narrowed the implementation to the same-line branch-continuation splitter: newline-separated `if { ... }` / `elseif { ... }` / `else { ... }` clauses are already ActionIR-ready, while compact `} elseif/else {` chains remain raw. Frontier remains `.2.2.2` implementation.; table reference: `SPEC-FORMAT-TERSE.2.2.2 — implement Perl attached if blocks`; retained completion note: Perl compact attached-block `if/elseif/else` now splits, lowers, and runs without raw fallback. Marker-form and inline-composite `if` behavior is unchanged. Frontier becomes `.2.2.3` for Rust parity.

- ID: `SPEC-FORMAT-TERSE.2.2.3`
  Status: `done` (2026-06-30)
  Goal: Rust parity — attached-block `if/elseif/else`
  Acceptance: Rust parses and executes the accepted `.2.2.2` attached-block if contract with the same branch
    gating and oracle parity, while keeping inline-composite and marker-form `if` behavior unchanged.
  Verification: `CodeBlock::parse` now recognizes attached `if(...) { ... } elseif(...) { ... } else { ... }`
    statement chains and emits the existing `if` / branch-body / `elseif` / branch-body / `else` / branch-body /
    `endif` marker sequence. Runtime branch gating reused `Engine::handle_statement_if_control`; no second Rust
    branch runtime was added. Focused Rust core `attached_if` tests PASS; focused Rust runtime `terse_2_2_3`
    tests PASS; oracle corpus regenerated to **36 fixtures** with `terse_2_2_3_attached_if_blocks`; corpus oracle
    PASS. mdBook/KM/live docs updated; marker-form and inline-composite `if` preserved.
  Commit: `SPEC-FORMAT-TERSE.2.2.3 - own Rust attached if blocks`;; table reference: `SPEC-FORMAT-TERSE.2.2.3 — own Rust attached if blocks`; retained completion note: No engine behavior change. Rust parity is owned before code: parse attached `if`/`elseif`/`else` branch bodies into the existing statement-control model, reusing `handle_statement_if_control` rather than adding a second branch runtime. Frontier remains `.2.2.3` implementation.; table reference: `SPEC-FORMAT-TERSE.2.2.3 — implement Rust attached if blocks`; exact Git subject: `SPEC-FORMAT-TERSE.2.2.3 - implement Rust attached if blocks`; retained completion note: Rust `CodeBlock::parse` now normalizes attached `if/elseif/else` branch bodies to the existing marker-control sequence; runtime branch gating is reused unchanged. Added parser/runtime/oracle locks; attached `if` is now portable on Perl and Rust. Frontier becomes `.2.2.4`.
    `SPEC-FORMAT-TERSE.2.2.3 - implement Rust attached if blocks`

- ID: `SPEC-FORMAT-TERSE.2.2.4`
  Status: `done` (2026-06-30)
  Goal: `when/otherwise` conditional aliases
  Acceptance: `when(cond) { ... } otherwise { ... }` is implemented as the readable one-condition alias family
    for attached-block if/else on Perl and Rust, without relying on Perl's host-language `when` feature.
  Verification: Perl now recognizes `when` at the existing attached-if statement-split/scanner/contract/control-flow
    seams and normalizes bare attached `otherwise` to `else()`. TOOLBOX probes show the compact alias chain lowers
    to canonical `if/else`, descriptor metadata reports `raw=0 unresolved=0`, generated source has no host
    `when`/`otherwise`, and runtime selects the true branch. Rust `CodeBlock::parse` now accepts attached `when`
    starts plus `otherwise` fallback branches and emits the existing `if`/`else`/`endif` statement sequence; no
    runtime branch engine was added. Focused Perl probe PASS; focused Rust core/runtime tests PASS; Rust oracle
    corpus PASS; oracle corpus regenerated to **37 fixtures** with `terse_2_2_4_when_otherwise_aliases`;
    phase0 PASS (`Files=1, Tests=991`); mdBook/KM/memory/doctrine/diff checks PASS; full local CI PASS.
  Commit: `SPEC-FORMAT-TERSE.2.2.4 - own when otherwise aliases`;; table reference: `SPEC-FORMAT-TERSE.2.2.4 — own when otherwise aliases`; retained completion note: No engine behavior change. `when/otherwise` is owned as an alias-normalization leaf over attached `if/else`, not host Perl `when`; implementation should reuse existing control-flow lowerers and Rust marker runtime. Frontier remains `.2.2.4` implementation.; table reference: `SPEC-FORMAT-TERSE.2.2.4 — implement when otherwise aliases`; exact Git subject: `SPEC-FORMAT-TERSE.2.2.4 - implement when otherwise aliases`; retained completion note: Perl and Rust now normalize attached `when(cond) { ... } otherwise { ... }` to the existing attached `if/else` control-flow contract. Oracle corpus 37 fixtures. Frontier becomes `.2.2.5`.
    `SPEC-FORMAT-TERSE.2.2.4 - implement when otherwise aliases`

- ID: `SPEC-FORMAT-TERSE.2.2.5`
  Status: `done` (2026-06-30)
  Goal: Attached-block `switch/case/default` parity and separator lock
  Acceptance: `switch(expr) { case(v) { ... } default { ... } }` has portable Perl/Rust behavior, clear
    statement-separator rules between branch blocks, first-match/default semantics, and no raw fallback.
  Children: `.2.2.5.1`, `.2.2.5.2`
  Verification: KM retrieval (`terse-control-flow-keyword-surface-ground-truth`,
    `terse-statement-separator-contract`, `spec-format-brainstorm-rounds-1-3`), TOOLBOX descriptor/lowering/runtime
    probes, and Perl/Rust code-read show this is not one safe implementation leaf. Perl already has attached-switch
    lowering machinery and a simple one-case/default probe can run, but generated lowering can leave host-like
    `default { ... }` / adjacent `case(...) { ... }` residue; adjacent branch blocks without an explicit separator
    are not language-agnostic ready (`unresolved_helper_count=1` for the second `case`) and can compile invalid
    Perl. Rust had lazy value-form `switch(expr, case(...), default(...))` runtime tests, but
    `CodeBlock::parse` only had attached statement parsing for `if`/`when`, not attached `switch/case/default`.
    Therefore `.2.2.5.1` owned the Perl reference separator/source lock, and `.2.2.5.2` owned Rust parity. Both
    children are now done, so attached `switch/case/default` is portable on Perl and Rust.
  Commit: `SPEC-FORMAT-TERSE.2.2.5 - split attached switch surface`;; table reference: `SPEC-FORMAT-TERSE.2.2.5 — split attached switch surface`; retained completion note: No engine behavior change. Attached `switch/case/default` is split before code into `.2.2.5.1` Perl separator/source lock and `.2.2.5.2` Rust parity. Frontier becomes `.2.2.5.1`.
    `SPEC-FORMAT-TERSE.2.2.5.1 - implement Perl attached switch separator lock`;
    `SPEC-FORMAT-TERSE.2.2.5.2 - implement Rust attached switch blocks`

- ID: `SPEC-FORMAT-TERSE.2.2.5.1`
  Status: `done` (2026-06-30)
  Goal: Perl reference — attached-block `switch/case/default` separator/source lock
  Acceptance: Perl lowers adjacent attached switch branch blocks such as
    `switch(expr) { case(v) { ... } case(w) { ... } default { ... } }` without raw host-label residue,
    unresolved helpers, or invalid generated Perl; explicit semicolons and optional `endcase()` / `endswitch()`
    remain accepted; a same-line statement after the final attached switch block still requires an explicit
    semicolon per `.1.5.4`.
  Verification: `StatementSplit::Core` now recognizes complete attached `case(...) { ... }` and
    `default { ... }` branch statements and splits before same-line `case(...) {` / `default {` branch
    continuations. TOOLBOX probes show compact adjacent branches report `ready=1 raw=0 unresolved=0`, generated
    lowering has no host-shaped `case(...)` or `default { ... }` residue, and runtime probes cover first-match,
    later-case, and default selection. A same-line ordinary statement after the final attached switch still
    requires an explicit `;`. Perl syntax checks PASS; phase0 PASS (`Files=1, Tests=991`);
    mdBook/KM/memory/doctrine/diff checks PASS; full local CI PASS.
  Commit: `SPEC-FORMAT-TERSE.2.2.5.1 - implement Perl attached switch separator lock`; table reference: `SPEC-FORMAT-TERSE.2.2.5.1 — implement Perl attached switch separator lock`; retained completion note: Perl compact attached `switch/case/default` now splits adjacent branch bodies, lowers without host branch residue, and preserves the semicolon requirement before any following same-line ordinary statement. Frontier becomes `.2.2.5.2` Rust parity.

- ID: `SPEC-FORMAT-TERSE.2.2.5.2`
  Status: `done` (2026-06-30)
  Goal: Rust parity — attached-block `switch/case/default`
  Acceptance: Rust parses and executes the accepted `.2.2.5.1` attached-switch contract with the same
    first-match/default semantics and oracle parity, while preserving the existing lazy value-form
    `switch(expr, case(...), default(...))`.
  Verification: `CodeBlock::parse` now recognizes one-argument attached `switch(...) { ... }` blocks with
    attached `case(value) { ... }` / `default { ... }` branch bodies and normalizes them to
    `switch` / `case` / `default` / `endswitch` statement controls. `Engine` now gates statement switch
    controls with a `StatementSwitchFrame` stack beside the existing if stack in lifecycle blocks and
    expression-valued block evaluation. Focused Rust parser `attached_switch` PASS; focused Rust runtime
    `terse_2_2_5_2` PASS; lazy value-form `cond_switch` PASS; Perl oracle corpus regenerated to **38 fixtures**
    with `terse_2_2_5_2_attached_switch_blocks`; Rust corpus oracle PASS.
  Commit: `SPEC-FORMAT-TERSE.2.2.5.2 - implement Rust attached switch blocks`; table reference: `SPEC-FORMAT-TERSE.2.2.5.2 — implement Rust attached switch blocks`; retained completion note: Rust attached `switch/case/default` now parses and executes with first-match/default statement gating and oracle parity. Lazy value-form switch remains unchanged. Frontier becomes `.2.2.6` (`while`).

- ID: `SPEC-FORMAT-TERSE.2.2.6`
  Status: `done` (split/owned before code 2026-06-30; `.2.2.6.1` + `.2.2.6.2` done)
  Goal: `while(cond) { ... }` statement loop container
  Acceptance: `while(cond) { ... }` executes a statement block while the condition is true, has an explicit
    forward-progress/iteration safety rule, composes with block-local `return(expr)` where appropriate, and
    is implemented on Perl and Rust without raw host-language fallback.
  Children: `.2.2.6.1`, `.2.2.6.2`
  Verification: KM retrieval (`terse-control-flow-keyword-surface-ground-truth`,
    `spec-format-brainstorm-rounds-1-3`, `top-rule-recursion-forward-progress-guard`), TOOLBOX probes, and
    code-read split this into a Perl reference contract and a Rust parity contract. `.2.2.6.1` landed the Perl
    ActionIR loop/safety contract; `.2.2.6.2` landed Rust parser/runtime/oracle parity with 39 fixtures.
  Commit: `SPEC-FORMAT-TERSE.2.2.6 - split while loop surface`; table reference: `SPEC-FORMAT-TERSE.2.2.6 — split while loop surface`; retained completion note: No engine behavior change. Attached `while(cond) { ... }` is split before code into `.2.2.6.1` Perl reference loop/safety and `.2.2.6.2` Rust parity. Frontier becomes `.2.2.6.1`.

- ID: `SPEC-FORMAT-TERSE.2.2.6.1`
  Status: `done` (2026-06-30)
  Goal: Perl reference — attached-block `while(cond) { ... }` with iteration safety
  Acceptance: Perl lowers attached `while(cond) { ... }` through ActionIR without raw fallback or unresolved
    helper residue; the condition is evaluated before each iteration; body statements execute while true;
    `return(expr)` inside a rule/action loop still returns from the surrounding rule; and a deterministic
    iteration safety guard prevents non-terminating loops from hanging generated parsers.
  Verification: Perl syntax checks; TOOLBOX lowering/descriptor/runtime/generated-source probes; phase0
    (`prove -q -Iperl t/phase0_regression.t`) PASS (`Files=1, Tests=992`). Lowering emits a guarded host
    `for (; cond; )` loop with unique `__ls_while_guard_N` state, descriptor metadata reports `ready=1 raw=0
    fallback=0 unresolved=0` with `WHILE` nodes, counted-loop runtime returns `3`, non-terminating loops hit the
    deterministic safety guard and return control to the parser, and same-line statement separator behavior is
    locked.
  Commit: `SPEC-FORMAT-TERSE.2.2.6.1 - implement Perl attached while safety`; table reference: `SPEC-FORMAT-TERSE.2.2.6.1 — implement Perl attached while safety`; retained completion note: Perl attached `while(cond) { ... }` now lowers through ActionIR with condition re-evaluation and deterministic iteration safety. Frontier becomes `.2.2.6.2` Rust parity.

- ID: `SPEC-FORMAT-TERSE.2.2.6.2`
  Status: `done` (2026-06-30)
  Goal: Rust parity — attached-block `while(cond) { ... }` with the accepted Perl safety contract
  Acceptance: Rust parses and executes the `.2.2.6.1` attached-while contract, including nested composition
    with existing statement `if`/`switch` controls, expression-valued block evaluation where applicable, the
    same deterministic iteration safety behavior, and oracle parity.
  Verification: focused Rust parser `attached_while` PASS; focused Rust runtime `terse_2_2_6_2` PASS; full
    Rust core/runtime package tests PASS; oracle generator syntax/regeneration PASS; oracle corpus regenerated
    to **39 fixtures** with `terse_2_2_6_2_attached_while_blocks`; Rust corpus oracle PASS. Runtime locks cover
    counted-loop condition re-evaluation, nested attached `if`/`switch` in a loop body, surrounding-rule
    `return(expr)` exit from a loop, expression-valued block side effects/local return, and deterministic
    safety-limit diagnostics.
    mdBook/KM/memory/doctrine/diff checks PASS; full local CI PASS (`Files=1, Tests=992`).
  Commit: `SPEC-FORMAT-TERSE.2.2.6.2 - implement Rust attached while safety`; table reference: `SPEC-FORMAT-TERSE.2.2.6.2 — implement Rust attached while safety`; retained completion note: Rust attached `while(cond) { ... }` now parses and executes with the accepted Perl loop/safety contract, expression-block composition, numeric comparison helper parity, and a 39-fixture oracle corpus. Frontier becomes `.2.3`.

- ID: `SPEC-FORMAT-TERSE.2.3`
  Status: `done` / `closed` (2026-06-30 split container; children complete)
  Goal: Fluent control-flow, lifecycle blocks, and full composability
  Children: `.2.3.1`, `.2.3.2`, `.2.3.3` (container), `.2.3.4` (container), `.2.3.5`
  Acceptance: Fluent chains `.when (cond) { ... }.otherwise { ... }` (parens for condition, block after);
    lifecycle blocks `I { ... }`, `LS { ... }`, etc. take a block after the keyword and drop the value;
    Lisp-style composability everywhere (any function in any argument position at any depth); method
    chaining by return type (array→array, hash→hash, string→string, number→number).
  Verification: **SPLIT 2026-06-30.** KM retrieval, TOOLBOX probes, and code-read show this is not one safe
    implementation leaf. Perl reference descriptor/runtime probes already accept exact action and lifecycle
    fluent block chains such as `Done.when(true) { return("yes") }.otherwise { return("no") }` and
    `I.when(true) { set(value,"yes") }.otherwise { set(value,"no") }` with
    `ready=1 raw=0 fallback=0 unresolved=0` and `"yes"` runtime results. Lifecycle block syntax
    `I { ... }` exists across the family, but its final value is not returned; explicit `return(expr)` still
    writes the surrounding rule/action return channel and needs a focused contract lock before the book can
    phrase "drop the value" without ambiguity. Rust currently parses attached statement blocks, but expression
    fluent chains have only `.method(args)` calls, no attached-block payloads; the compiler preserves blind-edge
    fluent chains but drops standalone/body fluent chains, and action-edge fluent continuation parity is already
    tracked by `RUST-PARITY.7.5.3`. Representative nested helper composition works, while value-returning and
    chained receiver-dot array methods such as `set(out, items.push_back("a"))` and
    `items.push_back("a").push_back("b")` are not supported; Round 1 array end-mutation methods are
    statement-only.
  Commit: `SPEC-FORMAT-TERSE.2.3 - split fluent lifecycle composability surface`; retained completion note: No engine behavior change. `.2.3` is split into Perl fluent block-chain locking, lifecycle value/drop semantics, Rust fluent-block/action-edge parity, full composability audit, and return-type method chaining design. Frontier becomes `.2.3.1`.

- ID: `SPEC-FORMAT-TERSE.2.3.1`
  Status: `done` (2026-06-30)
  Goal: Perl reference fluent block-chain contract lock
  Acceptance: Exact action-edge and lifecycle fluent block chains are source/descriptor/runtime locked on the
    Perl reference: `.when(cond) { ... }.otherwise { ... }` and the no-dot `otherwise` continuation variant
    both lower through owned ActionIR/bootstrap machinery with no raw fallback or unresolved helper residue.
    The book states this as the Perl reference surface unless and until Rust parity lands.
  Verification: Perl syntax checks PASS (`perl/LinkedSpec/BootstrapSpec/Core.pm`, `t/phase0_regression.t`);
    phase0 PASS (`Files=1, Tests=993`). The new `.2.3.1` regression lock covers four Perl reference cases:
    action-edge dotted `.otherwise`, action-edge no-dot `otherwise`, lifecycle dotted `.otherwise`, and
    lifecycle no-dot `otherwise`, all with a false `when` condition proving the fallback branch actually runs.
    Descriptor metadata is `ready=1`, `fallback=0`, `raw=0`, `unresolved=0`; generated source contains no
    host-shaped `when`/`otherwise` residue for source-locked cases. Implementation is a narrow bootstrap parse
    fix: optional leading dot accepted for attached fluent tails, `when` recognized as an attached fluent-if
    head, and `otherwise` recognized as an attached fallback tail.
  Commit: `SPEC-FORMAT-TERSE.2.3.1 - lock Perl fluent when otherwise blocks`; retained completion note: Perl reference fluent `.when(cond) { ... }.otherwise { ... }` and no-dot `otherwise { ... }` fallback continuations now execute correctly on action-edge and lifecycle surfaces, with phase0 locks. Frontier becomes `.2.3.2`.

- ID: `SPEC-FORMAT-TERSE.2.3.2`
  Status: `done` (2026-06-30)
  Goal: Lifecycle block value-drop and return-channel semantics lock
  Acceptance: `I { ... }`, `LS { ... }`, `LE { ... }`, `E { ... }`, `EX { ... }`, `IT { ... }`, and
    `LX { ... }` block syntax is verified across parser/runtime/book surfaces; final-expression block values
    are discarded, and explicit `return(expr)` behavior is documented and regression-locked separately from
    expression-valued block-local returns.
  Verification: Perl syntax check PASS (`t/phase0_regression.t`); phase0 PASS (`Files=1, Tests=994`). The new
    `.2.3.2` phase0 lock source-verifies all seven structured lifecycle markers, runtime-verifies that final
    ordinary lifecycle statements mutate but do not become implicit returns, proves top-level Perl lifecycle
    `return(expr)` writes the surrounding rule channel, and contrasts that with expression-valued block-local
    `return(expr)`. Focused Rust runtime PASS (`cargo test --quiet --manifest-path
    rust/linkedspec-runtime/Cargo.toml terse_2_3_2`): lifecycle statement values are discarded, top-level
    lifecycle `return(expr)` records the surrounding return event, and expression-valued block return remains
    local. mdBook pages now state lifecycle blocks are statement blocks rather than expression-valued blocks.
    Full local CI PASS.
  Commit: `SPEC-FORMAT-TERSE.2.3.2 - lock lifecycle value drop return channel`; retained completion note: Lifecycle blocks are locked as statement blocks: final ordinary statement values are discarded, top-level `return(expr)` writes the surrounding rule/action channel, and expression-valued block-local return stays separate. Phase0 994 green; frontier becomes `.2.3.3`.

- ID: `SPEC-FORMAT-TERSE.2.3.3`
  Status: `done` / `closed` (2026-06-30 split container; children complete)
  Goal: Rust fluent block-chain and action-edge parity split/implementation
  Children: `.2.3.3.1`, `.2.3.3.2`, `.2.3.3.3`
  Acceptance: Rust supports the accepted fluent control-flow block-chain contract, including attached block
    payloads on fluent calls where required, and no longer drops action-edge/body fluent continuations. This
    leaf must coordinate with `RUST-PARITY.7.5.3` rather than hiding that existing parity gap.
  Verification: Split 2026-06-30 after KM retrieval, TOOLBOX Perl reference probes, and Rust parser/compiler
    code-read. The immediate tclite blocker is action-edge no-arg `.push` / `.return(expr)` continuations:
    Perl `.push` dispatches the child and appends the child return to the current rule's same-named accumulator,
    while Perl `.return(expr)` returns the expression for the triggering action edge without recursively
    dispatching the close-edge child. Rust currently preserves fluent chains only on `=>` blind edges and drops
    standalone body `FluentChain` elements; `ActionEdge` has no structured fluent-chain field. Attached
    `.when(cond) { ... }.otherwise { ... }` block payloads are a separate parser/runtime seam, so they stay out
    of the first implementation slice. `.2.3.3.1` later closed action-edge no-arg fluent continuation parity
    but did not re-enable `tclite`: compact lifecycle/body fluent forms (`I.return(...)`) and default-mode
    repetition remain separate blockers. `.2.3.3.2` later closed the Rust attached fluent block-payload subset
    by normalizing action-edge/lifecycle `.when(cond) { ... }` chains to existing attached statement blocks;
    compact lifecycle/body fluent continuations remain `.2.3.3.3`.
  Commit: `pending` (container split; first implementation child is `.2.3.3.1`)

- ID: `SPEC-FORMAT-TERSE.2.3.3.1`
  Status: `done` (2026-06-30)
  Goal: Rust action-edge fluent continuation parity (`.push` / `.return(expr)`) and `tclite` oracle triage
  Acceptance: Rust parses fluent continuations after `->` action edges into structured `ActionEdge` metadata,
    compiles them onto `AcodeEntry`, and executes the accepted Perl-reference no-arg `.push`, `.return(expr)`,
    and `.return_undef` semantics. `.push` dispatches the child and appends the child return to the current
    rule's accumulator without leaking the child return event into the shared engine accumulator. `.return(expr)`
    returns through the current rule/action channel without forcing a recursive close-edge child dispatch. If
    the `tclite` oracle cannot be re-enabled after this surface lands, record the newly exposed blockers instead
    of folding unrelated parser/runtime work into this leaf.
  Verification: Parser/compiler/runtime parity landed on Rust. `ActionEdge` now owns `fluent_chain`, `AcodeEntry`
    serializes it with a default, `parse_fluent_chain_with_remainder` preserves nested helper-call arguments, and
    the runtime executes no-arg `.push`, `.return(expr)`, and `.return_undef` in the action-edge dispatch loop.
    Focused Rust checks passed: `cargo test --quiet --manifest-path rust/linkedspec-core/Cargo.toml fluent_chain`
    and `cargo test --quiet --manifest-path rust/linkedspec-runtime/Cargo.toml terse_2_3_3_1 -- --nocapture`.
    The focused runtime locks assert dispatch-match propagation via `entry_text()`, accumulator-event suppression
    for `.push`, close-edge `.return(expr)` without child redispatch, and `.return_undef` with no accumulator
    event. `tclite_command_subst` / `tclite_double_quote` stay out of the corpus for now because compact
    lifecycle/body fluent continuations and default-mode repetition are separate remaining blockers.
  Commit: `SPEC-FORMAT-TERSE.2.3.3.1 - implement Rust action-edge fluent continuations` (see Commit Log); retained completion note: Rust action-edge fluent no-arg `.push`, `.return(expr)`, and `.return_undef` now execute through structured action-edge metadata; `tclite` remains deferred behind compact lifecycle/body fluent and default-mode repetition gaps. Frontier becomes `.2.3.3.2`.

- ID: `SPEC-FORMAT-TERSE.2.3.3.2`
  Status: `done` (2026-06-30)
  Goal: Rust attached fluent block payloads for accepted `.when(cond) { ... }.otherwise { ... }` chains
  Acceptance: Rust parses and executes attached fluent block payloads on action-edge and lifecycle surfaces
    for the accepted Perl-reference `.when`/`otherwise` contract, including dotted and no-dot fallback tails.
  Verification: Rust parser/runtime parity landed by recognizing receiver-fluent `.when(cond) { ... }` tails
    after `-> Target` action edges and lifecycle markers such as `I`, then attaching normalized
    `when(cond) { ... } otherwise { ... }` code to the existing action-edge/lifecycle code-block fields. The
    parser accepts both `.otherwise { ... }` and no-dot `otherwise { ... }`, and tracks the physical source
    line that owns a remainder so multiline `}.otherwise {` chains do not skip the fallback payload. Focused
    Rust checks passed: `cargo test --quiet --manifest-path rust/linkedspec-core/Cargo.toml attached_fluent
    -- --nocapture` and `cargo test --quiet --manifest-path rust/linkedspec-runtime/Cargo.toml
    terse_2_3_3_2 -- --nocapture`. Runtime locks cover action-edge dotted fallback, action-edge no-dot
    fallback, lifecycle dotted fallback, and lifecycle no-dot fallback. Full Rust core/runtime package tests,
    mdBook build, Knowledge Map regenerate/check, memory/doctrine/diff checks, and full local CI PASS
    (`Files=1, Tests=994`).
  Commit: `SPEC-FORMAT-TERSE.2.3.3.2 - implement Rust attached fluent block payloads` (see Commit Log); retained completion note: Rust action-edge/lifecycle `.when(cond) { ... }` fluent block chains now execute through normalized attached statement blocks with dotted or no-dot fallback tails. Frontier becomes `.2.3.3.3`.

- ID: `SPEC-FORMAT-TERSE.2.3.3.3`
  Status: `done` (SPLIT 2026-06-30 — no engine/book behavior change)
  Goal: Rust remaining body/standalone fluent continuation audit and implementation split
  Children: `.2.3.3.3.1` (compact lifecycle/body receiver chains), `.2.3.3.3.2` (action-edge explicit/flow
    chains), `.2.3.3.3.3` (`tclite`/default-mode repetition re-enable audit after fluent parity)
  Acceptance: Any remaining `BodyElementKind::FluentChain` paths that are currently dropped by the compiler are
    audited against Perl reference behavior, implemented if they are part of the portable contract, or split
    into concrete follow-up leaves with evidence. This audit must include compact lifecycle/body fluent forms
    such as `I.return(...)` and explicit-argument action/body `.push(...)` forms. If `tclite` still cannot be
    re-enabled after those fluent surfaces land, split the remaining default-mode repetition gap before code.
  Verification: Split after KM retrieval, Perl reference probes, shipped-spec/code search, and Rust
    parser/compiler/runtime code-read. Rust `parser.rs` parses `I.return(...)` / `I.declare(...).return(...)`
    as a bare lifecycle marker followed by `BodyElementKind::FluentChain`, and `compiler.rs` currently resets
    adjacency and drops standalone/body `FluentChain` elements. That lifecycle/body receiver-chain surface is
    separate from action-edge fluent metadata: action edges now carry `AcodeEntry.fluent_chain`, but
    `engine.rs::execute_action_edge_fluent_chain` only implements no-arg `.push`, `.return(expr)`, and
    `.return_undef`; explicit/flow forms such as `.if(...).push(child,target).else().return_undef().endif()`
    and `-> include_dir.push(includes)` need their own action-edge semantics. `tclite` remains out of the
    oracle until the fluent children land, then gets a focused re-enable/default-mode repetition audit rather
    than being folded into either fluent implementation.
  Commit: `SPEC-FORMAT-TERSE.2.3.3.3 - split remaining Rust fluent continuations` (see Commit Log); retained completion note: Remaining Rust fluent parity split into compact lifecycle/body receiver chains, action-edge explicit/flow chains, and `tclite`/default-mode repetition re-enable audit. Frontier becomes `.2.3.3.3.1`.

- ID: `SPEC-FORMAT-TERSE.2.3.3.3.1`
  Status: `done` (2026-06-30)
  Goal: Rust compact lifecycle/body receiver chains
  Acceptance: Rust parses compact lifecycle/body receiver chains such as `I.return(expr)`,
    `I.declare(...).return(...)`, and chained helper statements after lifecycle markers into executable
    lifecycle `CodeBlock` statements instead of dropping them as standalone `FluentChain` elements. Add parser,
    compiler, and runtime locks for return-channel behavior, chained declaration/mutation helpers, and no
    surviving standalone `FluentChain` on accepted lifecycle-marker surfaces.
  Verification: Rust parser/compiler/runtime parity landed by normalizing lifecycle-marker receiver chains into
    lifecycle `CodeBlock` statement strings before compilation. Focused core PASS
    (`cargo test --quiet --manifest-path rust/linkedspec-core/Cargo.toml lifecycle_compact -- --nocapture`):
    parser locks prove multiline body and regex-first header-line inline normalization with no surviving
    standalone `FluentChain`, and compiler locks prove compact `I`/`E` chains populate lifecycle code slots.
    Focused runtime PASS (`cargo test --quiet --manifest-path rust/linkedspec-runtime/Cargo.toml
    terse_2_3_3_3_1 -- --nocapture`): compact lifecycle `return(expr)` writes the surrounding rule return
    channel, ordered `declare`/`set` helper chains execute, and regex-first header-line inline compact chains
    execute. Full Rust core/runtime package tests PASS; mdBook build PASS; oracle generator syntax PASS;
    Knowledge Map regenerate/check PASS; memory/doctrine/diff checks PASS; full local CI PASS. mdBook/KM/live
    docs updated.
  Commit: `SPEC-FORMAT-TERSE.2.3.3.3.1 - implement Rust compact lifecycle fluent chains` (see Commit Log); retained completion note: Rust compact lifecycle/body receiver chains now execute as lifecycle `CodeBlock` statements; frontier becomes `.2.3.3.3.2`.

- ID: `SPEC-FORMAT-TERSE.2.3.3.3.2`
  Status: `done` (2026-06-30)
  Goal: Rust action-edge explicit/flow fluent chains
  Acceptance: Rust action-edge fluent continuations beyond the no-arg `.2.3.3.1` subset are audited and
    implemented or further split: explicit `.push(child,target)` / `.push(target)` spellings, fluent
    statement-control chains (`.if(...).push(...).else().return_undef().endif()`), and shipped `ebnf.spec`
    action-edge forms must either execute with Perl-reference semantics or be split with concrete blockers.
  Verification: Rust parser/compiler/runtime parity landed for action-edge explicit/flow fluent continuations.
    The body parser now attaches multiline dotted continuation lines to the preceding `ActionEdge` instead of
    leaving them as later body elements, and the compiler preserves those calls in `AcodeEntry.fluent_chain`.
    Runtime action-edge fluent execution reuses the existing statement-control stacks for `.if/.else/.endif`
    gating, dispatches `.push(target)` and `.push(child,target)` through the child return channel, truncates
    child accumulator leakage before appending the child return to the explicit target, keeps
    `.return(expr)`/`.return_undef()` on the action-edge return path, and routes helper calls such as `.say(...)`
    through normal expression evaluation. Focused Rust core and runtime locks pass; full validation is recorded
    in the Verification Log.
  Commit: `SPEC-FORMAT-TERSE.2.3.3.3.2 - implement Rust action-edge fluent flow chains` (see Commit Log); retained completion note: Rust action-edge explicit/flow fluent chains now execute with explicit-target child return appends and statement-control gating; frontier becomes `.2.3.3.3.3`.

- ID: `SPEC-FORMAT-TERSE.2.3.3.3.3`
  Status: `done` (split/audit-only, 2026-06-30)
  Goal: Rust `tclite` oracle re-enable / default-mode repetition audit after fluent parity
  Acceptance: After `.2.3.3.3.1` and `.2.3.3.3.2`, retry the deferred `tclite` oracle fixtures. If they still
    diverge, isolate the remaining default-mode repetition gap into a concrete implementation leaf before code.
  Verification: Perl reference probes confirm `tclite` returns
    `["?tcl_script:",[["?command_subst:",[]]]]` for `[]` and
    `["?tcl_script:",[["?double_quote:",[]]]]` for `""`. The two cases were temporarily re-enabled in
    `tools/gen_oracle_corpus.pl`; the Rust corpus oracle then reported exactly two failures while the other
    39 fixtures passed. Both failures had the expected wrapped Perl values but actual Rust output `[]`,
    proving the remaining gap is default-mode recursive repetition/top-level default-rule dispatch parity, not
    a fluent continuation issue. The failing fixtures were removed from the committed green corpus and the
    implementation work is split to `.2.3.3.3.3.1`.
  Commit: `SPEC-FORMAT-TERSE.2.3.3.3.3 - split Rust tclite repetition parity` (see Commit Log); retained completion note: `tclite` oracle retry after fluent parity still returned Rust `[]` for `[]` and `""` at that split point; default-mode recursive repetition parity split to `.2.3.3.3.3.1`, which later landed the fixtures.

- ID: `SPEC-FORMAT-TERSE.2.3.3.3.3.1`
  Status: `done` (2026-06-30)
  Goal: Rust default-mode recursive repetition parity for `tclite`
  Acceptance: Rust reproduces the Perl reference for the shipped `tclite` `[]` and `""` oracle cases after
    default-mode recursive repetition/top-level default-rule dispatch is implemented. The `tclite_command_subst`
    and `tclite_double_quote` cases are restored to `tools/gen_oracle_corpus.pl`, regenerated into
    `rust/linkedspec-runtime/tests/corpus/`, and `cargo test --quiet --manifest-path
    rust/linkedspec-runtime/Cargo.toml --test corpus_oracle -- --nocapture` passes with those cases included.
    Any broader recursive-rule value parity discovered during implementation must be split rather than hidden
    in this leaf.
  Verification: Rust default-mode recursive repetition parity landed for the shipped `tclite` minimal
    fixtures. KM/toolbox probes and generated Perl source showed that parent dependency-regex dispatch passes
    an already-matched entry context into the child handler, and a child `I.return(...)` exits immediately
    before local entry-regex matching. Rust now compiles `RuleMode::Default` as zero-min repeated choice
    (`rep_min = Some(0)`) and exits a rule invocation immediately after preamble execution if the preamble set
    a return value, restoring caller return/match state before returning the child value. The stale lifecycle
    tests that expected `I.return(...)` to continue into matching and `E` were corrected to Perl-reference
    output, and capture-helper/lifecycle-order tests that intentionally need one seek match now spell
    `OR{1,1}` explicitly. `tools/gen_oracle_corpus.pl` restored `tclite_command_subst` and `tclite_double_quote`; the
    regenerated corpus has 41 fixtures, and focused Rust locks plus `corpus_oracle` pass.
  Commit: `SPEC-FORMAT-TERSE.2.3.3.3.3.1 - implement Rust tclite default repetition` (see Commit Log); retained completion note: Rust default-mode recursive repetition parity landed; `tclite_command_subst` and `tclite_double_quote` are active oracle fixtures, corpus 41 passes, and frontier becomes `.2.3.4`.

- ID: `SPEC-FORMAT-TERSE.2.3.4`
  Status: `done` (SPLIT/AUDIT 2026-06-30 — no runtime behavior change beyond a passing oracle fixture)
  Goal: Full composability audit and gap split
  Children: `.2.3.4.1` (Rust bare aggregate helper-argument parity), `.2.3.4.2` (Perl inline
    value-control lowering)
  Acceptance: Representative and adversarial nested helper calls are audited across Perl lowering, Rust AST,
    runtime evaluation, oracle fixtures, and mdBook examples. Any unsupported "function in any argument
    position at any depth" sites are split into concrete leaves instead of accepted by assertion.
  Verification: **SPLIT/AUDIT 2026-06-30.** TOOLBOX probes and source dumps separated the portable subset from
    unsupported sites. Pure value-helper composition is portable when helper argument slots are explicit about
    aggregate kind where Rust still needs it: the new oracle fixture
    `terse_2_3_4_deep_pure_helper_composition` composes `count(drop_front(sorted_keys(merge_hash(hash_copy(base),
    hash(overlay)))))` after hash working variables are initialized by statement mutations; Perl lowers it
    with `ready=1 raw=0 unresolved=0`, and the Rust corpus oracle passes with **42 fixtures**. Direct nested
    access, shape literals, and value-form `set_key(hash_expr, key, value)` are already covered by existing
    oracle and Rust locks. Two unsupported "function anywhere" sites were split before implementation: first,
    Perl `merge_hash(hash_copy(base), overlay)` returns `2` while Rust returns `1` because Rust evaluates bare
    `overlay` as a scalar before `merge_hash` sees only evaluated `RuntimeValue::Hash` arguments; `.2.3.4.1`
    owns that Rust helper-context aggregate bare-read parity. Second, Perl inline-composite value controls such
    as `return(if(1, "yes", else("no")))` lower to generated `do { if (...) { ... } }` shapes that do not
    return the selected branch value, and nested predicate/branch helper forms can fail handler compilation;
    `.2.3.4.2` owns the Perl reference lowering fix plus parity locks. Receiver-dot array mutations remain
    statement-only, and value-returning/chained receiver methods stay in `.2.3.5`.
  Commit: `SPEC-FORMAT-TERSE.2.3.4 - split composability boundaries`; prior node reference: `pending` (split/audit slice); retained completion note: Full composability audit split Rust helper-context aggregate bare reads to `.2.3.4.1` and Perl inline value-control lowering to `.2.3.4.2`; added a green deep pure-helper oracle fixture and frontier becomes `.2.3.4.1`.

- ID: `SPEC-FORMAT-TERSE.2.3.4.1`
  Status: `done` (2026-06-30)
  Goal: Rust helper-context aggregate bare reads for nested pure composition
  Acceptance: Rust matches the Perl reference for helper argument positions where the callee implies a hash or
    array value from a bare working variable, starting with the audited book-shaped case
    `merge_hash(hash_copy(base), overlay)`. Add focused Rust runtime locks and re-enable the bare-argument
    oracle form only after it passes. Existing `array_copy(NAME)` / `hash_copy(NAME)` / `copy(NAME)` behavior
    from `.1.2.3.2` must remain unchanged.
  Verification: **PASS 2026-06-30.** Rust now keeps global `Expr::Variable` evaluation scalar-only while
    promoting a bare working-variable name to `ctx.hash_copy(name)` in hash-consuming helper argument slots and
    `ctx.array_copy(name)` in array-consuming helper argument slots. Focused runtime locks cover
    `merge_hash(hash_copy(base), overlay)` against the explicit `hash(overlay)` wrapper, a broader hash helper
    family spanning `set_key`, `rename_key`, `drop_keys`, `pick_keys`, `sorted_keys`, `has_key`, `scalaref`,
    and `flat_hash`, and an array helper family spanning `sorted`, `reversed`, `first`, `last`, `take`,
    `drop_front`, `contains`, `index_of`, `num_sum`, and `flat_array`. `tools/gen_oracle_corpus.pl` added
    `terse_2_3_4_1_bare_hash_helper_arg_composition` and
    `terse_2_3_4_1_bare_array_helper_arg_composition`; final Rust `corpus_oracle` passes with **44 fixtures**.
  Commit: `SPEC-FORMAT-TERSE.2.3.4.1 - implement Rust bare aggregate helper args`; retained completion note: Rust helper-context bare aggregate arguments landed for hash- and array-consuming helper slots; corpus 44 passes and frontier becomes `.2.3.4.2`.

- ID: `SPEC-FORMAT-TERSE.2.3.4.2`
  Status: `done` (2026-06-30)
  Goal: Perl inline-composite value control lowering
  Acceptance: Perl reference inline-composite `if(...)` and `switch(...)` value forms return the selected
    branch value in all supported value positions (`return(...)`, assignment RHS, and fluent `.return(...)`),
    with nested helper predicates/branches and expression-valued block branches covered. Rust already has
    runtime support for lazy value `if`/`switch`; after Perl lands, add oracle fixtures and focused parity
    checks instead of relying on descriptor readiness alone.
  Verification: **PASS 2026-06-30.** Perl value lowering now recognizes inline-composite `if(...)` and
    `switch(...)` as value expressions before generic method-helper lowering. `if(...)` lowers to a
    value-producing `do { my $__ls_if_value; ...; $__ls_if_value }` form with lazy selected-branch assignment,
    accepting `elseif(...)`, `else(...)`, and the Rust-compatible plain third-argument fallback. `switch(...)`
    evaluates its source once, compares `case(...)` values in order, assigns the first matching branch value,
    and falls back to `default(...)` when no case matches. Flow conditions lower host booleans as `1`/`0` while
    ordinary return/assignment payload booleans remain JSON booleans. Inline branch payloads participate in
    auto-working-variable discovery, including scalar reads inside expression-valued block branches. Focused
    phase0 locks cover direct return, assignment RHS, nested predicate/helper payloads, expression-valued block
    payloads, fluent `.return(if(...))`, fluent `.return(switch(...))`, and descriptor metadata with no raw or
    unresolved fallback. The fluent runtime checks assert the selected payload value and deliberately do not
    require any specific legacy/action-edge tag string. `tools/gen_oracle_corpus.pl` added
    `terse_2_3_4_2_inline_if_value_control` and
    `terse_2_3_4_2_inline_switch_value_control`; Rust `corpus_oracle` passes with **46 fixtures**.
  Commit: `SPEC-FORMAT-TERSE.2.3.4.2 - implement Perl inline value controls`; retained completion note: Perl inline value-control lowering landed for `if`/`switch` in supported value positions; corpus 46 passes and frontier becomes `.2.3.5`.

- ID: `SPEC-FORMAT-TERSE.2.3.5`
  Status: `done` (2026-07-01)
  Goal: Method chaining by return type design and first implementation split
  Acceptance: The return-type chaining model is specified before code. Statement-only receiver-dot mutations
    from `.1.6` remain stable, while value-returning method calls and chains are split by type family
    (array/hash/string/number) with explicit return contracts and backend parity requirements.
  Verification: **PASS 2026-07-01.** KM retrieval, source read, and TOOLBOX probes established the live
    boundary before code: Perl lowers `items.push_back("a")` and `items.pop_back()` only as standalone
    statement mutations, leaves `return(items.pop_back())`, `set(out, items.push_back("a"))`, and
    `items.push_back("a").push_back("b")` raw/unimplemented, and already lowers pure function-style forms such
    as `return(sorted(items))`. Rust parses receiver-dot lifecycle expressions as `Expr::FluentChain`, executes
    single-call array end mutations as statement-only side effects, and otherwise evaluates fluent chains to
    `undef` rather than a chained value. The accepted model for future code is receiver-as-first-argument
    value chaining by return family, not silent mutation overloading: pure array/hash/string/number methods may
    become value-returning receiver chains when their child leaf defines the exact return type and parity locks;
    `.1.6` `push_back`/`push_front`/`pop_back`/`pop_front` statement behavior remains unchanged until an array
    child explicitly designs any value-returning destructive variant. Added child leaves `.2.3.5.1` through
    `.2.3.5.4`, with `.2.3.5.5` now owning the block-valued receiver-chain audit after the type-family
    leaves, corrected stale mdBook inline value-control wording, and added KM fact
    `terse-return-type-method-chaining-split`. Commit-workflow checks PASS: `check_memory_architecture`,
    `check_doctrines`, `check_knowledge_map`, `git diff --check`, and `mdbook build docs/linkedspec-book`.
  Commit: `SPEC-FORMAT-TERSE.2.3.5 - split return-type method chaining`; retained completion note: Return-type method chaining specified before code and split into array/hash/string/number receiver-family leaves. No runtime behavior changed; first implementation frontier is `.2.3.5.1` array receiver-dot value chains.

- ID: `SPEC-FORMAT-TERSE.2.3.5.1`
  Status: `done` (2026-07-01)
  Goal: Array receiver-dot value chains
  Acceptance: Define and implement the array-family receiver-dot value contract on Perl and Rust. Pure array
    snapshot methods such as sorted/reversed/take/take_last/drop_front/drop_back/slice/filter/uniq-style forms
    must return arrays and be chainable with later array methods. Array terminal methods such as
    first/last/count/contains/index_of/join_values/is_empty/is_nonempty must return their documented scalar,
    number, string, or boolean values and may only continue through a compatible next-family chain after the
    contract says so. The existing `.1.6` mutating statements `push_back`, `push_front`, `pop_back`, and
    `pop_front` must remain statement-only unless this leaf explicitly splits destructive value-returning
    variants before code. Add Perl phase0 locks, Rust parser/runtime locks, oracle fixtures, and mdBook examples.
  Verification: **PASS 2026-07-01.** Perl normalizes receiver-dot array value chains to pure helper value
    composition without changing legacy public function-style array-pipeline lowering. `items.sorted().drop_front(2).first()`,
    `items.uniq().join_values(",")`, `items.filter_match(/^a$/).count()`, and
    `phrases.split_each("-").filter_match(/^aa$/).count()` are locked in phase0. Rust evaluates compatible
    `Expr::FluentChain` array receivers by feeding the current value through existing helper contracts; `split_each`
    now returns the documented flat array with the supplied delimiter. Statement-only `.1.6` mutations still
    return `undef` in value slots and do not mutate there. Added Rust parser/runtime locks, oracle fixture
    `terse_2_3_5_1_array_receiver_value_chains` (corpus **47 fixtures**), mdBook examples, and KM fact
    `terse-array-receiver-value-chains`.
  Commit: `SPEC-FORMAT-TERSE.2.3.5.1 - implement array receiver value chains`; retained completion note: Array receiver-dot value chains landed on Perl/Rust with phase0, focused Rust tests, oracle corpus, mdBook, and KM locks. Frontier becomes `.2.3.5.2`.

- ID: `SPEC-FORMAT-TERSE.2.3.5.2`
  Status: `done` (2026-07-01)
  Goal: Hash receiver-dot value chains
  Acceptance: Define and implement the hash-family receiver-dot value contract on Perl and Rust. Hash-producing
    methods such as merge/set_key/rename_key/drop_keys/pick_keys/hash_copy-style snapshots must return hashes
    and chain with later hash methods; key/value terminal methods such as sorted_keys/sorted_values/count_keys,
    has_key, scalaref, and flat_hash must return the documented array, number, boolean, scalar, or hash value.
    Statement-level hash mutations such as `set_key(name, key, value)` and `meta[key] = value` keep their
    existing statement semantics. Add parity locks, oracle fixtures, and mdBook examples.
  Verification: **PASS 2026-07-01.** Perl normalizes receiver-dot hash value chains to pure helper
    composition. Bare hash receivers are wrapped as `hash(name)` before helper composition so optional-scope
    parsing cannot drop the receiver in forms such as `meta.merge_hash(...)`. Receiver-dot `scalaref(key)` maps
    to Perl's established `scalar(hash_expr, key)` field reader, while Rust evaluates it through the existing
    hash-consuming helper arm. `meta.set_key("c", 3).sorted_keys().join_values(",")`,
    `meta.merge_hash(hash(extra)).scalaref("a")`, and
    `hash(meta).rename_key("a", "aa").drop_keys("b").set_key("z", 4).count_keys()` are locked. Rust
    `merge_hash` now honors the documented later-argument override contract. Added Rust parser/runtime locks,
    oracle fixture `terse_2_3_5_2_hash_receiver_value_chains` (corpus **48 fixtures**), mdBook examples, and
    KM fact `terse-hash-receiver-value-chains`.
  Commit: `SPEC-FORMAT-TERSE.2.3.5.2 - implement hash receiver value chains`; retained completion note: Hash receiver-dot value chains landed on Perl/Rust with focused tests, oracle corpus, mdBook, and KM locks. Frontier becomes `.2.3.5.3`.

- ID: `SPEC-FORMAT-TERSE.2.3.5.3`
  Status: `done` (2026-07-01)
  Goal: String receiver-dot value chains
  Acceptance: Define and implement the string/scalar-family receiver-dot value contract on Perl and Rust.
    String-transforming methods such as trim/lowercase/uppercase/replace_substr/rm_prefix/rm_suffix/substr/cat
    must return strings and compose with later string methods. Predicate/array-producing terminals such as
    starts_with/ends_with/contains_substr/matches/split/split_each-style forms must return their documented
    boolean or array value and only continue through compatible next-family chains after that contract is
    explicit. Add parity locks, oracle fixtures, and mdBook examples.
  Verification: **PASS 2026-07-01.** Perl normalizes string/scalar receiver-dot value chains to pure helper
    composition. Bare scalar receivers are wrapped as `scalar(name)` before helper composition, string literals
    may be receivers, and `split(delim)` is the explicit bridge into array receiver chains. String-returning
    links include `trim`, `lowercase`, `uppercase`, `replace_substr`, `rm_prefix`, `rm_suffix`, `substr`,
    `concat`/`cat`, and `coalesce_nonempty`; terminal `length`, `starts_with`, `ends_with`,
    `contains_substr`, and `matches` end the chain. Perl also lowers value-form `split(...)` and `substr(...)`
    as portable helper payloads. Rust parses fluent chains after string literals and evaluates the same
    string/array bridge family. Locked examples include
    `raw.trim().lowercase().replace_substr("-", "_").rm_prefix("node_").rm_suffix("_end").cat("!")`,
    `raw.trim().split("-").trim_each().lowercase_each().join_values("|")`,
    `" a-b ".trim().split("-").count()`, and `"abcdef".substr(1, 3).uppercase()`. Invalid post-terminal
    continuations return `undef`/`null`. Added Perl phase0 locks, Rust parser/runtime locks, oracle fixture
    `terse_2_3_5_3_string_receiver_value_chains` (corpus **49 fixtures**), mdBook examples, and KM fact
    `terse-string-receiver-value-chains`.
  Commit: `SPEC-FORMAT-TERSE.2.3.5.3 - implement string receiver value chains`; retained completion note: String receiver-dot value chains landed on Perl/Rust with phase0, focused Rust tests, oracle corpus, mdBook, and KM locks. Frontier becomes `.2.3.5.4`.

- ID: `SPEC-FORMAT-TERSE.2.3.5.4`
  Status: `done` (2026-07-01)
  Goal: Number receiver-dot value chains
  Acceptance: Define and implement the number-family receiver-dot value contract on Perl and Rust. Numeric
    methods must map receiver-dot form to the existing function-style numeric helper family without inventing
    operator precedence: unary methods (abs/floor/ceil/round) return numbers, binary/multi-argument methods
    (add/sub/mul/div/mod/min/max/clamp) consume the receiver as the first argument, comparison methods return
    booleans, and array reducers remain array-consuming unless an explicit receiver-family bridge is specified.
    Add parity locks, oracle fixtures, and mdBook examples.
  Verification: **PASS 2026-07-01.** Perl normalizes number receiver-dot value chains to the existing `num_*`
    helper family. Bare numeric receivers read scalar working variables, integer and decimal literal receivers
    are accepted, decimal dots are ignored by the receiver splitter, and value-form numeric comparisons now
    lower as terminal values. Rust parses fluent chains after numeric literals without swallowing method dots
    as decimal points, evaluates the same number receiver family, and consumes all supplied operands for
    `num_add`/`num_mul` so receiver `add(...)`/`mul(...)` remains multi-argument. Locked examples include
    `score.abs().ceil().add(2, 3).mul(2).sub(1).div(2).clamp(0, 20).max(5).min(12)`,
    `5.mod(2)`, `3.5.floor().add(1)`, `3.5.round()`, and comparison terminals
    `score.abs().gt(3)` / `score.abs().le(4)`. Invalid post-comparison continuations return `undef`/`null`.
    Array reducers (`num_sum`, `num_avg`, `num_median`, `num_range`, and array-form `num_min`/`num_max`) remained
    explicit array-consuming helpers with no scalar-to-array receiver bridge at that time; later `.7.3` added
    terminal array/list receiver reducer methods without making reducers scalar number receiver links. Added Perl phase0 locks, Rust
    parser/runtime locks, oracle fixture `terse_2_3_5_4_number_receiver_value_chains` (corpus **50 fixtures**),
    mdBook examples, and KM fact `terse-number-receiver-value-chains`.
  Commit: `SPEC-FORMAT-TERSE.2.3.5.4 - implement number receiver value chains`; retained completion note: Number receiver-dot value chains landed on Perl/Rust with phase0, focused Rust tests, oracle corpus, mdBook, and KM locks. `declare(...)` and other statement/lifecycle methods stay outside receiver methods. Frontier becomes `.2.3.5.5`.

- ID: `SPEC-FORMAT-TERSE.2.3.5.5`
  Status: `done` (2026-07-01)
  Goal: Block-valued receiver-dot chaining audit/parity
  Acceptance: Verify and, only if needed, implement receiver-dot chaining from expression-valued blocks by the
    runtime type yielded by the block. A block that yields a string, number, array, or hash must be able to
    continue through the compatible receiver-family chain already owned by `.2.3.5.1` through `.2.3.5.4`, with
    no special block-only helper semantics. The slice must add Perl phase0 locks, Rust parser/runtime locks,
    oracle fixtures where JSON-stable, and mdBook examples. If the existing expression-valued block + receiver
    family machinery already satisfies the contract, this leaf closes as a verification/documentation slice
    with explicit evidence.
  Verification: **PASS 2026-07-01.** Audit found the contract mostly present but not fully locked. Perl
    string-, hash-, and number-yielding block receivers already fed the existing receiver-family lowering, but
    array-yielding blocks were rejected by the array-value recognizer before array helpers such as `sorted(...)`
    and `join_values(...)` could normalize. Perl now treats an expression-valued block as array-like only when
    its visible exits are array-yielding expressions, including block-local `return(expr)`, so scalar/hash
    blocks are not misclassified. Rust runtime evaluation already handled non-variable fluent receivers through
    `eval_expr`; the parser now allows block/hash/array primaries to continue into `.method(...)` chains.
    Added Perl phase0 locks, Rust parser/runtime locks, oracle fixture
    `terse_2_3_5_5_block_valued_receiver_chains`, mdBook examples, and KM fact
    `terse-block-valued-receiver-chains`. Locked examples cover
    `{ [3, 1, 2] }.sorted().join_values(",")`,
    `{ return(["x", "y"]); ["bad"] }.join_values("|")`,
    `{ set(raw, " a-b "); raw }.trim().split("-").count()`,
    `{ { "b" => 2, "a" => 1 } }.sorted_keys().join_values(",")`, and
    `{ 3.5 }.floor().add(2)`. Validation PASS: Perl syntax checks, focused Perl probes, focused Rust
    `.2.3.5.5` parser/runtime tests, oracle generator, Rust corpus oracle (**52 fixtures**), full phase0
    (**1001 tests**), and mdBook/KM/memory/doctrine/diff checks.
  Commit: `SPEC-FORMAT-TERSE.2.3.5.5 - implement block-valued receiver chains`; retained completion note: Expression-valued blocks now feed yielded array/string/hash/number values into compatible receiver-dot value chains. Perl array-yielding blocks use narrow visible-exit recognition; Rust parses fluent chains after block/hash/array primaries. Phase0 1001 green; oracle corpus 52 fixtures; receiver-chain family is complete.

- ID: `SPEC-FORMAT-TERSE.2.3.5.6`
  Status: `done` (2026-07-01)
  Goal: Typed wrapper quoted-name boundary and terse shape-constructor lock
  Acceptance: Preserve `array(foo)` / `a(foo)` and `hash(bar)` / `h(bar)` as explicit typed working-variable
    reads for expression positions that need an array/list or hash/associative-array value. Do not equate
    quoted wrapper arguments with those bare-name reads: `array("foo")` and `array('foo')` remain literal
    array-constructor payloads, while `hash("bar")` and `hash('bar')` remain hash-constructor payloads under
    the existing constructor arity rules. Prefer the terse direct-shape constructor forms (`["foo"]`,
    `{ "bar" => value }`, `[]`, `{}`) in mdBook examples and make clear that shape literals are the terse
    spellings for array/hash construction. Do not add runtime scalar-indirect lookup and do not implement or
    document postfix typed-view adapters such as `foo.array()`.
  Verification: **PASS 2026-07-01.** Perl generic value-expression lowering now treats exactly one bare
    aggregate wrapper argument as a typed working-variable read (`array(foo)` / `a(foo)` -> `[@foo]`,
    `hash(bar)` / `h(bar)` -> `{%bar}`) while quoted arguments keep constructor semantics. Perl direct shape
    literals now lower as array/hash value expressions in generic helper composition, so examples such as
    `concat_arrays(array(parts), sorted_keys(hash(meta)), ["tail"])` and
    `sorted(concat_arrays(array(parts), ["delta"], ["alpha"]))` compose without raw fallback. Aggregate symbol
    extraction skips primitive literals and inappropriate engine locals while preserving legitimate aggregate
    locals such as `IMATCH_LIST` and `IMATCH_HASH`. Rust already had the corrected quoted-boundary runtime
    behavior; this leaf adds Rust locks and oracle coverage. Added phase0 subtest
    `spec_format_terse_2_3_5_6_typed_wrapper_quoted_name_boundaries`, Rust integration locks, oracle fixture
    `terse_2_3_5_6_typed_wrapper_quoted_names`, mdBook wording, and KM fact
    `typed-wrapper-quoted-name-boundaries`. Validation PASS: Perl syntax checks, focused lowering/runtime/source
    probes, full phase0 (**1000 tests**), focused Rust `.2.3.5.6` tests, oracle generator, Rust corpus oracle
    (**51 fixtures**), and `mdbook build docs/linkedspec-book`.
  Commit: `SPEC-FORMAT-TERSE.2.3.5.6 - lock aggregate wrapper quoting boundaries`; retained completion note: Bare aggregate wrapper arguments remain typed working-variable reads; quoted wrapper arguments remain constructor payloads; direct `[...]` / `{...}` shapes are the preferred terse constructors. Phase0 1000 green; oracle corpus 51 fixtures; frontier returns to `.2.3.5.5`.

- ID: `SPEC-FORMAT-TERSE.3`
  Status: `done` / `closed`
  Goal: Round 3 — edge syntax plus uniform operator/function expression syntax
  Children: `.3.1`, `.3.2`, `.3.3`

- ID: `SPEC-FORMAT-TERSE.3.1`
  Status: `done` (2026-07-01)
  Goal: Edge syntax — confirm and lock current behavior
  Acceptance: `->` action edges, `=>` blind-call edges kept as-is. Grouped targets `-> A | B { code }`
    factor a shared code block across child rules (each target dispatches independently; the pipe is
    purely syntactic factoring). The block-less form `-> A | B` (no `{...}`) stays INVALID. (No code
    change expected — documents the decided contract; pair with regression locks if not already present.)
  Verification: Existing locks confirmed in `t/phase0_regression.t`:
    `bootstrap_grouped_action_edge_targets_share_one_code_block`,
    `validation_accepts_grouped_action_edge_targets_with_shared_code_block`,
    `validation_rejects_grouped_action_edge_targets_without_shared_code_block`, and
    `validation_accepts_grouped_action_edge_with_three_targets`. Focused `perl -Iperl` validation/bootstrap
    probes confirmed grouped shared-block acceptance, two-target `ACODE` expansion, and block-less grouped
    rejection with the current diagnostic. Full phase0 passed (`prove -q -Iperl t/phase0_regression.t`:
    1001 tests), and `bash tools/run_ci_local.sh` passed. The mdBook action/lifecycle chapter and formal
    grammar appendix now state the invalid boundary explicitly. No parser/compiler/runtime code changed.
  Commit: `SPEC-FORMAT-TERSE.3.1 - lock edge syntax contract`; retained completion note: Edge syntax confirmed without behavior change: `->` action edges and `=>` blind-call edges stay as-is; grouped action targets require a shared block; block-less grouping stays invalid. Frontier becomes `.3.2`.

- ID: `SPEC-FORMAT-TERSE.3.2`
  Status: `done` / `closed` (split 2026-07-01; children complete)
  Goal: Arithmetic + comparisons as composable functions (word + symbol spellings, no precedence)
  Children: `.3.2.1`, `.3.2.2`, `.3.2.3`
  Acceptance: Split before code because the requested surface crosses three separate mechanisms. Function-form
    numeric word aliases can map to the existing `num_*` family without a grammar change; symbol callees need
    parser/lowering/runtime work on both implemented variants; comparison word aliases conflict with the
    current documented string-comparison helpers (`eq`/`ne`/`gt`/`ge`/`lt`/`le`). Round 3 keeps one uniform
    `callee(args)` grammar with word and symbol callee spellings and does not add the `(op a, b)` Lisp-prefix
    call form. No operator precedence is introduced; every accepted arithmetic/comparison form must compose as
    an ordinary nested call.
  Verification: **SPLIT/OWNED 2026-07-01.** KM retrieval plus TOOLBOX/source probes established that
    `num_*` helpers lower/run today, while bare `add(...)`, `sum(...)`, and symbol `+(...)` do not map to the
    numeric helper family. `+(2,3)` is especially unsafe to leave as host fallback because raw Perl can treat
    it as unary-plus/comma behavior instead of addition. Rust call parsing currently accepts word names only,
    not symbol callees. Flow predicates already lower bare `eq`/`gt`/etc. as string comparisons, and the
    mdBook explicitly warns not to use `gt(...)` or `lt(...)` for numeric counters. No parser/compiler/runtime
    code changed in this split.
  Commit: `SPEC-FORMAT-TERSE.3.2 - split arithmetic call surface`; retained completion note: Arithmetic/comparison calls split before code: `.3.2.1` owns non-conflicting numeric word aliases, `.3.2.2` owns arithmetic symbol callees, and `.3.2.3` owns the comparison spelling policy before implementation. Frontier becomes `.3.2.1`.

- ID: `SPEC-FORMAT-TERSE.3.2.1`
  Status: `done` 2026-07-01
  Goal: Numeric word aliases for non-conflicting arithmetic, single-value helpers, multi-value helpers, and
    numeric array reducers
  Acceptance: Function-style calls `add(a,b)`, `sub(a,b)`, `mul(a,b)`, `div(a,b)`, `mod(a,b)`, `abs(v)`,
    `floor(v)`, `ceil(v)`, `round(v)`, `min(...)`, `max(...)`, `clamp(v,lo,hi)`, `sum(array_expr)`,
    `avg(array_expr)`, `median(array_expr)`, and `range(array_expr)` map to the existing `num_*` helper
    family on Perl and Rust. The old `num_*` spellings remain accepted aliases. This leaf does not add symbol
    callees and does not change bare comparison helper semantics. Calls are ordinary nested helper calls; no
    operator precedence is introduced.
  Verification: **DONE 2026-07-01.** Perl maps aliases in value lowering, after receiver-dot normalization, so
    function-form aliases do not disturb number receiver chains such as `3.5.floor().add(1)`. Rust maps the
    same alias names in helper dispatch. Focused probes confirmed `add(1,2)` lowers through `num_add`,
    `gt(10,2)` remains string comparison, and receiver-dot number chains still lower through `num_*`. Full
    phase0 passed (`prove -q -Iperl t/phase0_regression.t`, 1002 tests); oracle generation produced 53
    fixtures; Rust `corpus_oracle` passed over 53 fixtures; focused Rust integration test
    `terse_3_2_1_numeric_word_aliases_run` passed; mdBook build passed.
  Commit: `SPEC-FORMAT-TERSE.3.2.1 - implement numeric word aliases`; retained completion note: Function-form numeric word aliases dispatch to the existing `num_*` family on Perl/Rust; bare comparison words stayed string helpers only until `.3.2.3.3`. Phase0 1002 green; oracle corpus 53 fixtures; frontier becomes `.3.2.2`.

- ID: `SPEC-FORMAT-TERSE.3.2.2`
  Status: `done` 2026-07-02
  Goal: Arithmetic symbol callees for the numeric helper family
  Acceptance: Symbol function calls `+(a,b)`, `-(a,b)`, `*(a,b)`, `/(a,b)`, and `%(a,b)` parse and map to
    `num_add`, `num_sub`, `num_mul`, `num_div`, and `num_mod` on Perl and Rust. The implementation must reject
    or lower these before any raw host-language fallback can reinterpret them; in particular, `+(2,3)` must be
    numeric addition, not Perl unary-plus/comma behavior. No `(op a, b)` Lisp-prefix form is accepted and no
    operator precedence is introduced.
  Verification: **DONE 2026-07-02.** Perl method-expression parsing, ActionIR AST scanning, validation,
    bootstrap balanced parsing, and flow-composite lowering now recognize `+`, `-`, `*`, `/`, and `%` as
    ordinary callee names when they form a balanced symbol call. The slash disambiguator requires `/` followed
    by optional whitespace and a balanced parenthesized argument list with a call boundary, skips quoted strings
    and backslash-escaped characters, and deliberately does not treat `}` as a call boundary so regex literals
    such as `/(\))/` and `/(?<!\\)}/` remain regexes. Rust mirrors the same parser distinction and helper
    dispatch maps the symbols to `num_add`, `num_sub`, `num_mul`, `num_div`, and `num_mod`.
    Focused Perl lowering/runtime/source probes passed; `perl -Iperl -c` passed for the edited Perl modules;
    full phase0 passed (`prove -q -Iperl t/phase0_regression.t`, 1008 tests); oracle generation produced
    55 fixtures including `terse_3_2_2_arithmetic_symbol_callees`; Rust corpus oracle passed; Rust core tests
    passed; the focused Rust runtime `.3.2.2` integration test passed; mdBook, memory/Knowledge Map/doctrine/diff
    checks, and full local CI passed. A broader full runtime integration run also confirmed the new `.3.2.2` test
    passes, while exposing unrelated stale `s(...)`/`a(...)`/`h(...)` short-wrapper tests already inconsistent
    with the earlier alias-retirement leaf.
  Commit: `SPEC-FORMAT-TERSE.3.2.2 - implement arithmetic symbol callees`; retained completion note: Arithmetic symbol callees `+(...)`, `-(...)`, `*(...)`, `/(...)`, and `%(...)` now dispatch to `num_add`/`num_sub`/`num_mul`/`num_div`/`num_mod` on Perl/Rust; slash regex literals remain regexes. Frontier becomes `.3.2.3`.

- ID: `SPEC-FORMAT-TERSE.3.2.3`
  Status: `done` / `closed` (split 2026-07-02; children complete)
  Goal: Comparison spelling contract and implementation split before code
  Children: `.3.2.3.1`, `.3.2.3.2`, `.3.2.3.3`, `.3.2.3.4`
  Acceptance: Record and split the accepted comparison operator-call surface before code. The canonical future
    DSL surface treats numeric comparison operators as ordinary value-producing calls with both word and symbol
    spellings: `eq(a,b)` / `==(a,b)`, `ne(a,b)` / `!=(a,b)`, `gt(a,b)` / `>(a,b)`, `ge(a,b)` / `>=(a,b)`,
    `lt(a,b)` / `<(a,b)`, and `le(a,b)` / `<=(a,b)`. Existing `num_eq`/`num_ne`/`num_gt`/`num_ge`/
    `num_lt`/`num_le` helpers and number receiver terminals such as `score.gt(3)` remain accepted.
    Implementation is split because current Perl/Rust behavior has a compatibility conflict: bare
    function-form `eq`/`ne`/`gt`/`ge`/`lt`/`le` are string comparisons in documented flow/helper contexts
    today. The migration must introduce an explicit string-comparison bridge before flipping the bare
    comparison words to numeric operator-call aliases. The accepted bridge names are `str_eq`, `str_ne`,
    `str_gt`, `str_ge`, `str_lt`, and `str_le`; the old bare comparison words remain compatibility aliases
    only until their owning child leaf changes them. Symbol equality is `==(...)`; raw `=(...)` remains
    reserved for assignment under `.3.3`, and `=>` remains the blind-call edge operator.
  Verification: **SPLIT/OWNED 2026-07-02.** KM retrieval plus TOOLBOX/source probes established the live
    boundary before code: `return(num_gt(10,2))` and `return(10.gt(2))` lower through numeric comparisons,
    `FLOW num_gt(10,2)` lowers as numeric `>`, while `FLOW gt(10,2)` lowers as Perl string `gt`;
    `return(>(10,2))`, `return(>=(10,2))`, `return(==(10,10))`, and `return(!=(10,2))` stay unimplemented
    raw/unrecognized comparison symbol calls. Runtime probes return `1` for `num_gt` and receiver `.gt`, and
    `null` for bare `gt` and symbol `>` in the tested value-call shape. Source reads show distinct owners:
    Perl comparison word behavior lives in `ActionIR/FlowExpr.pm` plus value/helper lowering, arithmetic symbol
    parsing is currently limited in `ActionIR/MethodExpr.pm` and `ActionIR/AST/Parser.pm`, Rust symbol parsing
    is limited in `rust/linkedspec-core/src/expr.rs`, and Rust helper dispatch maps only existing `num_*`,
    receiver numeric comparisons, and non-comparison arithmetic aliases. No parser/compiler/runtime code
    changed in this split.
  Commit: `SPEC-FORMAT-TERSE.3.2.3 - split comparison call surface`; retained completion note: Comparison call migration split before code: explicit `str_*` string bridge first, numeric comparison word aliases second, numeric comparison symbol callees third. Current shipped comparison behavior is unchanged; frontier becomes `.3.2.3.1`.

- ID: `SPEC-FORMAT-TERSE.3.2.3.1`
  Status: `done` 2026-07-02
  Goal: Explicit string-comparison bridge contract
  Acceptance: Lock the string-comparison compatibility bridge before code. The accepted explicit string
    helper names are `str_eq(lhs,rhs)`, `str_ne(lhs,rhs)`, `str_gt(lhs,rhs)`, `str_ge(lhs,rhs)`,
    `str_lt(lhs,rhs)`, and `str_le(lhs,rhs)`, each preserving today's string comparison semantics. This leaf
    must define the warning/book wording and the migration boundary: old bare `eq`/`ne`/`gt`/`ge`/`lt`/`le`
    cannot be flipped to numeric aliases until the explicit string names exist and repo-owned string examples
    have been migrated or compatibility-covered. The bridge names are two-argument lexical string predicates,
    not numeric helpers, not receiver-dot links, and not comparison symbols. Until `.3.2.3.2` implements them,
    the shipped string comparison surface remains the old bare words, and user-facing docs must not present
    `str_*` as runnable current syntax. No symbol-call or numeric-word behavior changes belong here.
  Verification: **DONE 2026-07-02.** KM retrieval and the `.3.2.3` source boundary were reused, then mdBook
    wording was locked around the current `eq`/`ne`/`gt`/`ge`/`lt`/`le` string helpers. The public book now
    states that `str_eq`/`str_ne`/`str_gt`/`str_ge`/`str_lt`/`str_le` are the accepted explicit bridge names,
    but are not shipped until `.3.2.3.2`. Current runtime behavior remains unchanged; no parser/compiler/runtime
    code changed.
  Commit: `SPEC-FORMAT-TERSE.3.2.3.1 - lock string comparison bridge`; retained completion note: Explicit `str_*` string-bridge names locked before implementation; no runtime behavior changed; frontier becomes `.3.2.3.2`.

- ID: `SPEC-FORMAT-TERSE.3.2.3.2`
  Status: `done` 2026-07-02
  Goal: Implement explicit string-comparison helpers
  Acceptance: Implement `str_eq`/`str_ne`/`str_gt`/`str_ge`/`str_lt`/`str_le` on Perl and Rust as the portable
    explicit string-comparison family, update docs/examples/tests to prefer them for lexical string ordering,
    and keep old bare comparison words as compatibility aliases until `.3.2.3.3` owns the numeric-word flip.
    Add focused Perl/Rust locks and mdBook/KM updates.
  Verification: **DONE 2026-07-02.** Perl ActionIR value/flow lowering now accepts `str_*` as two-argument
    lexical string predicates and emits explicit string comparison operator lowering. Rust validation reserves
    the names and runtime helper dispatch evaluates them through string coercion. Phase0 locks prove `str_*`
    lowering, runtime results, generated-source cleanup, zero fallback, and old bare `gt(...)` string
    compatibility. The Rust focused runtime test and oracle fixture prove Perl/Rust parity over lexical
    ordering cases such as `str_gt("2","10")` versus numeric `num_gt("10","2")`. The book now prefers
    `str_*` for lexical comparisons, while bare comparison words remain compatibility aliases until `.3.2.3.3`.
  Commit: `SPEC-FORMAT-TERSE.3.2.3.2 - implement string comparison helpers`; retained completion note: Explicit `str_*` lexical string comparisons landed on Perl/Rust; corpus 56 passes and frontier becomes `.3.2.3.3`.

- ID: `SPEC-FORMAT-TERSE.3.2.3.3`
  Status: `done` 2026-07-02
  Goal: Numeric comparison word aliases
  Acceptance: After the string bridge lands, map ordinary value-call comparison words `eq`, `ne`, `gt`, `ge`,
    `lt`, and `le` to `num_eq`, `num_ne`, `num_gt`, `num_ge`, `num_lt`, and `num_le` on Perl and Rust. Preserve
    explicit `num_*` helper names and number receiver terminals. This leaf must close raw fallback for the
    word-call shapes it owns, update legacy-string compatibility notes, and add focused parity/oracle locks.
  Verification: **DONE 2026-07-02.** Perl flow/value lowering now treats bare `eq`, `ne`, `gt`, `ge`, `lt`, and
    `le` as numeric comparison aliases over the existing `num_*` family, including flow predicates and dropped
    value statements. Rust validation and runtime helper dispatch accept the same aliases and route them through
    numeric comparison semantics. Explicit `num_*` helper names and number receiver terminals remain stable.
    Lexical string comparisons now use `str_eq`, `str_ne`, `str_gt`, `str_ge`, `str_lt`, and `str_le`; repo-owned
    shipped specs and tests with string-intent bare comparison words were migrated to `str_*`. Phase0 locks prove
    numeric lowering, runtime results, generated-source cleanup, zero fallback/unresolved metadata, and
    `str_gt("2","10")` remaining lexical while bare `gt("2","10")` is numeric false. The Rust focused runtime
    test and oracle fixture prove Perl/Rust parity. Oracle corpus reaches **57 fixtures** and phase0 reaches
    **1010 tests**.
  Commit: `SPEC-FORMAT-TERSE.3.2.3.3 - flip comparison word aliases`; retained completion note: Bare comparison word calls now map to numeric `num_*` aliases on Perl/Rust; lexical string comparisons use `str_*`; corpus 57 passes and frontier becomes `.3.2.3.4`.

- ID: `SPEC-FORMAT-TERSE.3.2.3.4`
  Status: `done` (2026-07-02)
  Goal: Numeric comparison symbol callees
  Acceptance: Parse and dispatch `==(a,b)`, `!=(a,b)`, `>(a,b)`, `>=(a,b)`, `<(a,b)`, and `<=(a,b)` as
    ordinary numeric comparison calls on Perl and Rust, mapping to the same `num_*` comparison helpers as the
    word aliases. Preserve regex/slash handling from `.3.2.2`; do not claim `=(target,value)` assignment
    operator-call behavior, which remains `.3.3`; do not disturb `=>` blind-call edges. Add parser/lowering/
    runtime parity locks, oracle fixture(s), mdBook examples, and Knowledge Map updates.
  Outcome: Perl method-expression parsing accepts comparison symbol callees while still rejecting single
    `=(target,value)` as a method call. Perl value/flow lowering maps `==`/`!=`/`>`/`>=`/`<`/`<=` through the
    numeric comparison helper family, with slash division and slash regex boundaries preserved. Rust expression
    parsing recognizes multi-character comparison symbols as ordinary call names, fixes empty-name keyword-arg
    misclassification for `==(...)`, and runtime dispatch maps the symbols to `num_eq`/`num_ne`/`num_gt`/
    `num_ge`/`num_lt`/`num_le`. Added phase0, Rust parser/runtime, and 58-fixture oracle locks.
  Verification: Perl syntax checks for changed ActionIR modules; focused Perl lowering/runtime/source probes;
    Rust parser tests for arithmetic/comparison symbol callees and single-equals deferral; focused Rust runtime
    `.3.2.3.4` test; oracle regeneration; Rust corpus oracle; phase0 (`1011` tests); mdBook build; Knowledge
    Map regenerate/check; memory architecture; doctrine registry; `git diff --check`; full local CI.
  Commit: `SPEC-FORMAT-TERSE.3.2.3.4 - implement comparison symbol callees`; retained completion note: Comparison symbol callees now map to numeric `num_*` aliases on Perl/Rust; corpus 58 passes and frontier becomes `.3.3`.

- ID: `SPEC-FORMAT-TERSE.3.3`
  Status: `done` (SPLIT/OWNED 2026-07-02; no parser/compiler/runtime code change)
  Goal: Expression-valued assignment and assignment operator-call equivalence
  Children: `.3.3.1` (scalar assignment expression values and `=(target,value)` scalar equivalence), `.3.3.2`
    (aggregate assignment expression values after target-kind inference), `.3.3.3` (array append/hash-index
    mutation expression values), `.3.3.4` (legacy function spelling cleanup, docs, and oracle closure)
  Acceptance: Capture the clarified assignment contract before code. The canonical scalar assignment spelling
    is `target = value`; legacy `assign(target, value)` is migration debt and must not be promoted in new
    examples. The operator-call spelling `=(target, value)` is accepted as equivalent to `target = value`,
    following the same "operators are ordinary calls" rule as arithmetic/comparison symbol callees. Assignment
    is an expression, so it has a value; the initial contract should define that value as the value stored in
    the target after assignment and target-kind inference. `target = value`, `=(target, value)`, and any
    retained compatibility function spelling must compose in ordinary value positions, including helper
    arguments, `return(...)`, expression-valued blocks, user-defined function bodies, and compatible
    receiver-dot chains. Existing `.1.3.4.1` statement-only scalar assignment remains the current shipped
    behavior until this leaf or its children implement expression-valued semantics. Split before code if
    scalar assignment, aggregate shape assignment, hash-index assignment, array append, or backend parity need
    separate leaves.
  Outcome: Behavior at split time was audited before code: statement-form `name = "ok"; return(name)` ran, but
    `return(name = "ok")`, `return(=(name,"ok"))`, `return(set(name,"ok"))`, and `set(out, name = "ok")`
    still failed/null on the Perl reference; Rust still explicitly treated scalar assignment, array append,
    and hash-index assignment as statement-only in expression evaluation. The book now reflects that current
    boundary instead of claiming assignment aliases compose in every value position. Implementation is split
    by target/mutation mechanism before code.
  Verification: KM retrieval (`terse-expression-valued-assignment-and-operator-calls`,
    `terse-mutation-surface-ground-truth`); TOOLBOX `call_spec_handler_subst` and `LinkedSpec::Get` probes for
    statement assignment vs value-position assignment; Rust source/test audit for statement-only expression
    diagnostics; mdBook drift correction; Knowledge Map regenerate/check; memory/doctrine/diff checks; full
    local CI.
  Commit: `SPEC-FORMAT-TERSE.3.3 - split expression-valued assignment`; retained completion note: Assignment expression values are split before code into scalar, aggregate, append/hash-index, and compatibility/docs closure leaves; current shipped assignment remains statement-only and frontier becomes `.3.3.1`.

- ID: `SPEC-FORMAT-TERSE.3.3.1`
  Status: `done` (2026-07-02)
  Goal: Scalar assignment expression values and `=(target,value)` scalar equivalence
  Acceptance: Implement the scalar subset first on Perl and Rust. `target = value`, `=(target, value)`, and
    retained scalar compatibility spellings (`set(target, value)` and legacy `assign(target, value)`) must be
    ordinary value expressions when the target is scalar or a bare target inferred as scalar from a non-shape
    RHS. The expression value is the scalar value stored in the target after assignment. The forms must compose
    in `return(...)`, helper arguments, expression-valued blocks, user-defined function bodies, and compatible
    scalar receiver-dot chains. This leaf must preserve statement behavior and explicitly exclude direct RHS
    shape target-kind inference, array append, and hash-index assignment.
  Outcome: Scalar non-shape assignment is now a value expression on Perl and Rust. `return(name = "ok")`,
    `return(=(other, name = "ok"))`, and `return(set(out, name = "ok"))` store and return the scalar value.
    Assignment expressions compose inside helper arguments, expression-valued blocks, exact-arity user-function
    bodies, and compatible scalar receiver-dot chains such as `=(raw, " hi ").trim()`. Direct RHS shape
    assignment remains deferred in value positions; statement behavior for scalar, array, and hash assignments
    is preserved.
  Verification: Perl syntax checks for `ActionIR::MethodExpr` and `ActionIR::MethodLowering`; focused
    `t/actionir_ast_parser.t`; focused Perl runtime/source probe for nested scalar assignment expressions;
    phase0 scalar assignment subtest; focused Rust parser tests for scalar assignment values, keyword-arg
    boundaries, and `=(...)`; focused Rust runtime `.3.3.1` test; oracle fixture
    `terse_3_3_1_scalar_assignment_expressions` (corpus **59 fixtures**); mdBook/livedoc/KM updates; full
    gates before commit. Phase0 reaches **1012 tests**.
  Commit: `SPEC-FORMAT-TERSE.3.3.1 - implement scalar assignment values`

- ID: `SPEC-FORMAT-TERSE.3.3.2`
  Status: `done` (2026-07-02)
  Goal: Aggregate assignment expression values after target-kind inference
  Acceptance: Extend expression-valued assignment to array/hash targets and direct RHS shape target-kind
    inference after `.3.3.1` lands. `target = [value]`, `target = { key => value }`, `set(target, [value])`,
    `set(target, { key => value })`, matching typed aggregate targets, and the operator-call spelling must
    return the aggregate value stored in the target after assignment. Explicit `scalar(target)` remains the
    scalar payload boundary. Backend parity and oracle fixtures must cover both array and hash results.
  Outcome: Direct RHS shape assignment forms are now value expressions on Perl and Rust. Bare targets infer the
    aggregate kind from the direct shape RHS and yield the stored aggregate snapshot: `return(items = [value])`,
    `return(set(items, [value]))`, `return(=(items, [value]))`, and matching `array(items)` targets return an
    array value; `return(set(meta, { key => value }))` and matching `hash(meta)` targets return a hash value.
    Explicit `scalar(payload)` remains a scalar-held payload boundary, so `set(scalar(payload), [value])` stores
    and yields the array payload in the scalar. Assignment-expression targets now auto-declare `@`/`%` variables
    in generated Perl source without reintroducing stale scalar declarations. Array append and hash-index
    mutation expression values later landed in `.3.3.3`.
  Verification: Perl syntax checks for `ActionIR::MethodLowering` and `RuleIR::EmitContext`; focused
    `t/actionir_ast_parser.t`; focused generated-source probes for aggregate assignment expression lowering and
    declaration inference; focused Rust core scalar-assignment parser tests; focused Rust runtime `.3.3.2`
    integration test; oracle generator and Rust corpus oracle over **60 fixtures**; full phase0 PASS with
    **1013 tests**; mdBook/live-doc/KM updates and full gates before commit.
  Commit: `SPEC-FORMAT-TERSE.3.3.2 - implement aggregate assignment values`; retained completion note: Direct RHS shape assignment expressions now return the assigned array/hash value after target-kind inference on Perl/Rust; corpus 60 fixtures, phase0 1013 green, and frontier becomes `.3.3.3`.

- ID: `SPEC-FORMAT-TERSE.3.3.3`
  Status: `done` (2026-07-02)
  Goal: Mutation expression values for array append and hash-index assignment
  Acceptance: Define and implement value contracts for mutation operators that are currently statement-only:
    `items += value` and `meta[key] = value`. Before code, lock whether each expression returns the updated
    target aggregate snapshot or the stored element value; after that decision, implement Perl/Rust parity,
    preserve statement-side behavior, and add oracle coverage for helper arguments, `return(...)`, block
    values, and compatible receiver chains.
  Outcome: Array append and hash-index mutation operators are now value expressions on Perl and Rust. Both mutate
    the named working target and yield the updated aggregate snapshot: `items += value` returns `[@items]` /
    array snapshot after the push, and `meta[key] = value` returns `+{%meta}` / hash snapshot after the field
    update. These values compose in `return(...)`, helper arguments, expression-valued blocks, and compatible
    receiver chains such as `(items += value).count()` and `(meta[key] = value).count_keys()`. Statement-side
    behavior remains unchanged.
  Verification: Perl syntax checks for `ActionIR::MethodLowering`, `RuleIR::EmitContext`, and
    `t/phase0_regression.t`; focused `t/actionir_ast_parser.t`; focused Rust parser tests for assignment
    expression parsing and parenthesized mutation receiver chains; focused Rust runtime `.3.3.3`; oracle
    generator and Rust corpus oracle over **61 fixtures**; full phase0 PASS with **1014 tests**; mdBook/live-doc/KM
    updates and full gates before commit.
  Commit: `SPEC-FORMAT-TERSE.3.3.3 - implement mutation assignment values`; retained completion note: Array append and hash-index mutation expressions now return updated aggregate snapshots on Perl/Rust; corpus 61 fixtures, phase0 1014 green, and frontier becomes `.3.3.4`.

- ID: `SPEC-FORMAT-TERSE.3.3.4`
  Status: `done` (2026-07-02)
  Goal: Legacy function spelling cleanup and full assignment-expression closure
  Acceptance: After scalar, aggregate, append, and hash-index expression semantics land, reconcile the retained
    `assign(...)` compatibility surface with canonical `set(...)` and operator spellings. Public examples must
    prefer `target = value` or `set(...)` as appropriate and must not promote `assign(...)` as new syntax.
    Close mdBook/KM/status drift, add any missing oracle/corpus fixtures, and confirm the parent `.3.3`
    contract across Perl and Rust.
  Outcome: The parent `.3.3` assignment-expression contract is now closed. A single portable fixture composes
    scalar assignment values, operator-call `=(...)`, canonical `set(...)`, legacy `assign(...)`, user-function
    body assignment, direct RHS array/hash shape assignment, array append mutation values, hash-index mutation
    values, aggregate snapshot reads, and receiver-chain terminals. Public mdBook examples now prefer `set(...)`
    or operator assignment while the helper catalog keeps `assign(...)` as a legacy alias with current value
    semantics. Function-track parent/container status drift was also reconciled after the already-landed `.4.2`,
    `.4.3`, and `.4.4` children.
  Verification: Perl phase0 closure lock (`1015` tests), focused Rust runtime closure lock, oracle generator,
    Rust corpus oracle over **62 fixtures**, mdBook build, Knowledge Map regenerate/check, memory architecture,
    doctrine registry, `git diff --check`, and full local CI.
  Commit: `SPEC-FORMAT-TERSE.3.3.4 - close assignment expression docs`; retained completion note: Parent assignment-expression closure fixture locks scalar, aggregate, mutation, user-function, receiver-chain, operator, canonical `set`, and legacy `assign` compatibility forms; public book examples now prefer `set`/operators; corpus 62 fixtures, phase0 1015 green, and no concrete `SPEC-FORMAT-TERSE` PNT leaf remains.

- ID: `SPEC-FORMAT-TERSE.4`
  Status: `done` (2026-07-02; split/owned 2026-07-01 by explicit user direction)
  Goal: Round 4 — user-defined pure functions in `.spec`
  Children: `.4.1` (done), `.4.2` (Perl reference container: `.4.2.1`–`.4.2.3`), `.4.3`
    (Rust parity container: `.4.3.1`–`.4.3.2`), `.4.4`
  Acceptance: User-defined functions are introduced as a disciplined value-expression surface, not a
    general-purpose sublanguage. The first accepted syntax is top-level `fn name(args) { ... }`, with explicit
    parentheses required for zero and nonzero arities (`fn name() { ... }`). Function bodies are pure
    expression/block values over the existing ActionIR helper DSL; parameters are explicit positional values;
    no implicit capture of caller working variables, recursion, closures, lambdas, currying, or host-code escape
    is accepted in the first implementation. A call to a user function is an expression with a value, so it can
    be nested in helper arguments, assigned, returned, appended, or used as the receiver of a compatible
    receiver-dot value chain. When the call appears as a standalone statement, its result is silently discarded.
    The syntax/semantics must be represented in `specs/spec.spec`, the Perl ActionIR AST path, the Rust
    parser/runtime, oracle corpus, phase0, mdBook, live docs, and Knowledge Map before the surface is complete.
    The bootstrap parser must not be the final owner of `fn <name>(...) { ... }`; bootstrap support, if any, is
    a temporary migration bridge to remove after the text-to-AST path can carry the surface through
    `specs/spec.spec`.
  Verification: **DONE 2026-07-02.** The split/inventory leaf `.4.1`, Perl implementation leaves
    `.4.2.1`–`.4.2.3`, Rust parity leaves `.4.3.1`–`.4.3.2`, and docs/retrieval finalization leaf `.4.4`
    are complete. The accepted MVP surface is top-level `fn name(args) { ... }` with explicit parentheses,
    fresh function-local stores, value-call composition, receiver-chain continuation, standalone result discard,
    and explicit deferrals for alternate spellings, optional zero-arg parentheses, brace-less bodies,
    caller-state/persistent side effects, recursion, closures/lambdas/currying, and namespaces.
  Commit: `SPEC-FORMAT-TERSE.4 - own user-defined function surface`; retained completion note: User-defined pure functions are now owned under Round 4. Calls are value expressions, may feed receiver-dot chains, and standalone results are silently discarded. Frontier becomes `.4.1`, then `.3.2.2`.

- ID: `SPEC-FORMAT-TERSE.4.1`
  Status: `done` (2026-07-01 — contract/inventory locked before code)
  Goal: Function syntax/semantics contract and implementation inventory
  Acceptance: Record the exact MVP grammar, name-resolution rules, purity limits, parameter binding model,
    return-value model, receiver-chain behavior, unused-result behavior, collision/error boundaries, and split
    implementation seams before code. The inventory must inspect `specs/spec.spec`, the Perl bootstrap parser
    only to identify/remove any temporary `fn` support boundary, Perl ActionIR AST lowering/value-expression
    seams, the Rust parser/runtime expression model, oracle generation, and mdBook chapters. If the
    implementation surface is broader than one signoff slice, split `.4.2+` further before code.
  Verification: **DONE 2026-07-01.** KM retrieval plus source/book inventory covered `specs/spec.spec`,
    `BootstrapSpec.pm`/`BootstrapSpec/Core.pm`, Perl `ActionIR::AST::Parser`, `MethodLowering`,
    `RewritePipeline`, Rust `expr.rs`/`ast.rs`/`types.rs`/`compiler.rs`/`engine.rs`, oracle generation, and
    mdBook compiler/backend status. TOOLBOX probes proved current Perl behavior: `return(user_fn("x"))`,
    assignment/mutation value slots, and user-call receiver chains now diagnose through
    `LINKEDSPEC_UNSUPPORTED_ACTIONIR_HELPER:user_fn`, while standalone `user_fn("x")` remains raw until the
    registry owns discard semantics. Rust source read showed `Expr::Call` and `Expr::FluentChain` already parse
    the call shapes, but `Engine::call_helper` sends unknown names to warning+`undef`; user functions therefore
    need a registry path before helper fallback. mdBook, Knowledge Map, memory/doctrine checks,
    `git diff --check`, and full local CI PASS (`bash tools/run_ci_local.sh`, phase0 1004 tests). No
    parser/compiler/runtime code changed.
  Commit: `SPEC-FORMAT-TERSE.4.1 - lock user function contract`; retained completion note: User-function MVP contract/inventory locked before code; implementation split into `.4.2.1`–`.4.2.3` and `.4.3.1`–`.4.3.2`. Frontier becomes `.4.2.1`.

- ID: `SPEC-FORMAT-TERSE.4.2`
  Status: `done` (2026-07-01; split by `.4.1` inventory)
  Goal: Perl reference user-function implementation
  Children: `.4.2.1`, `.4.2.2`, `.4.2.3`
  Acceptance: The Perl reference accepts the `.4.1` function contract through a sequence of signoff-sized
    leaves: first the self-hosted grammar/top-level function registry, then value-call execution/lowering, then
    standalone discard plus receiver-chain/error hardening. The final grammar owner is `specs/spec.spec`; do not
    leave permanent `fn` syntax support in the bootstrap parser. Add focused phase0 locks and update
    `specs/spec.spec`, mdBook, live docs, and Knowledge Map as warranted.
  Verification: **DONE 2026-07-01.** Perl registry/descriptor ingestion landed in `.4.2.1`, exact-arity
    value-call execution landed in `.4.2.2`, and standalone discard plus purity/recursion hardening landed in
    `.4.2.3`. Registered Perl user functions now execute as pure values, use fresh function-local working
    stores, compose in supported value positions/receiver chains, and keep unsupported constructs on explicit
    diagnostics with zero raw fallback.
  Commit: closed by child commits `.4.2.1`, `.4.2.2`, and `.4.2.3`

- ID: `SPEC-FORMAT-TERSE.4.2.1`
  Status: `done` (2026-07-01 — Perl registry/descriptor seam landed)
  Goal: Perl reference function-definition grammar and registry seam
  Acceptance: Add the permanent `function_definition` surface to `specs/spec.spec` and a temporary,
    explicitly-documented Perl reference ingestion bridge if the primary bootstrap path still cannot consume the
    self-hosted function part directly. The compiled descriptor must carry a function registry with name,
    ordered parameter list, source span/body AST, and arity metadata, while ordinary rule parsing remains
    compatible with all shipped specs. Reject duplicate functions and collisions with rule labels, built-in
    helper/control/lifecycle names, reserved runtime symbols, and invalid/duplicate parameters before runtime.
    This leaf must not execute user-function calls yet.
  Verification: **DONE 2026-07-01.** Added `function_definition` to `specs/spec.spec` and a documented
    temporary Perl pre-bootstrap registry bridge in `LinkedSpec::UserFunctionRegistry`. The bridge extracts
    top-level `fn name(args) { body }` definitions, strips them from the source passed to ordinary
    validation/bootstrap while preserving newlines, parses function bodies through the ActionIR AST block parser,
    and attaches the registry to compiled state. Public descriptors now expose `functions`, `meta.function_order`,
    and `meta.function_count`; each definition records params, arity, source/body spans, body source, and
    `body_ast`. Negative locks cover duplicate functions, built-in helper/control-name collisions, rule-label
    collisions, duplicate parameters, reserved parameters, and malformed body-less definitions. Registered calls
    remain unresolved-helper diagnostics with zero raw fallback until `.4.2.2`. Syntax checks PASS for
    `UserFunctionRegistry.pm`, `Compiler.pm`, `CompilerState.pm`, and `t/phase0_regression.t`; focused descriptor
    probes PASS; `specs/spec.spec` descriptor compile stays at ratio 1.0000; focused AST suite, mdBook build,
    memory/doctrine/Knowledge Map checks, diff check, and full local CI PASS. The local CI gate includes phase0
    PASS with **1005 tests**.
  Commit: `SPEC-FORMAT-TERSE.4.2.1 - add Perl user function registry`; retained completion note: Perl registry/descriptor seam landed: `specs/spec.spec` owns active `function_definition`, descriptors expose `functions`, and registered calls intentionally remain unresolved until `.4.2.2`. Frontier becomes `.4.2.2`.

- ID: `SPEC-FORMAT-TERSE.4.2.2`
  Status: `done` (2026-07-01)
  Goal: Perl reference user-function value-call execution
  Acceptance: Resolve calls whose callee is in the function registry after built-in helper names have been
    excluded, evaluate arguments eagerly in the caller context, bind exact-arity positional parameters into a
    fresh function-local value scope, evaluate the pure function body, and return the final expression or
    `return(expr)` payload as a typed value. Calls must compose in `return(...)`, assignment RHS, array append
    RHS, hash mutation value, helper arguments, expression-valued blocks, and compatible receiver-dot chains.
    Unknown calls that are not in the registry must keep unresolved-helper diagnostics rather than host-code
    fallback.
  Verification: **DONE 2026-07-01.** Threaded the compiled function registry into per-rule ActionIR lowering,
    resolved registered exact-arity calls before unknown-helper fallback, evaluated arguments eagerly in the
    caller context, bound positional params into a fresh function-local scope, and lowered function body AST
    statements to a value-producing `do { ... }` expression. Function-local scalar/array/hash working variables
    are lexically declared inside the generated function expression, so local assignments do not capture or
    mutate caller variables. Phase0 now locks composition through `return(...)`, assignment RHS, array append
    RHS, hash mutation value, helper arguments, final-expression bodies, non-final `return(expr)`, compatible
    receiver-dot chains from returned string/hash values, and a caller/local shadowing smoke. Wrong-arity
    registered calls stay on the unresolved-helper diagnostic path with zero raw fallback. Standalone
    user-function call discard, recursion/purity diagnostics, and hard rejection of unsupported body effects
    remain `.4.2.3`.
  Commit: `SPEC-FORMAT-TERSE.4.2.2 - execute Perl user function value calls`

- ID: `SPEC-FORMAT-TERSE.4.2.3`
  Status: `done` (2026-07-01)
  Goal: Perl reference standalone discard, purity diagnostics, and phase0 hardening
  Acceptance: Standalone user-function call statements compute and silently discard the returned value without
    raw fallback. The MVP rejects recursion, unsupported side-effect/parser-state helpers, host-code escape,
    closure/lambda/currying syntax, implicit caller working-variable capture, and attempts to mutate caller
    scope with clear diagnostics. Add source, descriptor, runtime, receiver-chain, collision, and negative
    phase0 locks while preserving the all-target ActionIR-ready invariant at ratio 1.0000.
  Verification: **DONE 2026-07-01.** Registered standalone user-function calls and receiver chains are now
    classified as canonical `VALUE_DROP` events through a registry-aware ActionIR canonical-event seam, so their
    value is computed through the normal user-function lowering path and then discarded without raw Perl fallback.
    Unknown unregistered standalone calls remain explicit raw compatibility debt rather than being broadened into
    the user-function path. Phase0 now locks source, descriptor, and runtime behavior for standalone discard;
    nested user-function calls passing parameter values; direct and mutual recursion diagnostics; parser-state
    helper use inside function bodies; host-code-shaped function bodies; and nested function syntax inside a
    function body. These hardening diagnostics stay on unresolved-helper metadata with zero raw fallback. Focused
    AST suite, phase0 (**1007 tests**), mdBook build, memory/doctrine/Knowledge Map checks, diff check, and full
    local CI PASS after this leaf.
  Commit: `SPEC-FORMAT-TERSE.4.2.3 - harden Perl user function discard`; retained completion note: Registered standalone calls now lower as `VALUE_DROP`, nested user-function parameter passing is fixed, and recursion/unsupported body diagnostics are phase0-locked. Frontier becomes `.4.3.1`.

- ID: `SPEC-FORMAT-TERSE.4.3`
  Status: `done` (2026-07-02; split 2026-07-01 by `.4.1` inventory)
  Goal: Rust parity for user-defined pure functions
  Children: `.4.3.1`, `.4.3.2`
  Acceptance: The Rust parser/runtime matches the Perl reference for the `.4.1`/`.4.2` contract, including
    function-call value semantics, receiver-dot chaining, and silent standalone-result discard. Add Rust parser,
    runtime, and oracle corpus locks.
  Verification: **DONE 2026-07-02.** Rust registry/compiler parity landed in `.4.3.1` and runtime/oracle
    parity landed in `.4.3.2`. Rust registered user functions parse, validate, compile, execute before helper
    fallback, bind eager caller-context arguments into fresh function-local stores, return body values into
    compatible receiver chains, discard standalone results, and diagnose arity/recursion hazards.
  Commit: closed by child commits `.4.3.1` and `.4.3.2`

- ID: `SPEC-FORMAT-TERSE.4.3.1`
  Status: `done` (2026-07-02)
  Goal: Rust function-definition AST/compiler registry parity
  Acceptance: Extend Rust parsed `.spec` AST and compiled spec structures with the same function registry shape
    accepted by the Perl reference: name, ordered parameters, body `CodeBlock`, source metadata, and exact arity.
    Enforce duplicate/collision/parameter diagnostics before execution and preserve existing rule compilation.
  Verification: **DONE 2026-07-02.** Rust `SpecFile` now carries a top-level `functions` registry of
    `FunctionDefinition` records with ordered params, arity, original source, body source, and source/body spans.
    The Rust parser recognizes top-level `fn name(args) { ... }` definitions before or between rule paragraphs,
    preserves ordinary rule parsing, and keeps function bodies out of raw rule text. Rust validation now rejects
    duplicate user-function names, rule-label collisions, built-in helper/control-name collisions including
    `.3.2.1` numeric word aliases, lifecycle/runtime/function-keyword collisions, invalid params, duplicate
    params, and reserved params before runtime. Rust `CompiledSpec` now carries `CompiledUserFunction` records whose bodies are parsed into
    `CodeBlock` values, with compile-stage diagnostics for invalid function body code. This was registry parity
    only: Rust runtime call resolution, standalone discard, receiver-chain execution, and oracle fixtures were
    deferred to `.4.3.2` and are now closed there.
  Commit: `SPEC-FORMAT-TERSE.4.3.1 - add Rust user function registry`; retained completion note: Rust parsed/compiled registry parity landed: `SpecFile.functions`, `FunctionDefinition`, `CompiledSpec.functions`, `CompiledUserFunction`, and pre-runtime diagnostics. Frontier becomes `.4.3.2`.

- ID: `SPEC-FORMAT-TERSE.4.3.2`
  Status: `done` (2026-07-02)
  Goal: Rust user-function runtime parity and oracle fixtures
  Acceptance: Rust `Engine` resolves user-function calls before unknown-helper fallback, evaluates arguments
    eagerly, executes the function body in a fresh local scope, returns final-expression or `return(expr)` values,
    supports receiver-dot continuation from returned values, silently discards standalone call results, and
    matches the Perl reference in focused integration tests plus oracle fixtures.
  Verification: **DONE 2026-07-02.** Rust `Engine` now resolves registered user-function calls before ordinary
    helper fallback, reports exact-arity diagnostics, evaluates arguments in the caller context, binds parameters
    into fresh function-local scalar/array/hash stores, evaluates compiled `CodeBlock` bodies for final-expression
    or `return(expr)` results, restores caller variable stores after return, rejects direct/mutual recursion with a
    deterministic diagnostic, and lets returned arrays/hashes/scalars continue through compatible receiver-dot
    chains. Standalone registered function calls execute through the same value path and discard their results.
    Focused Rust runtime locks cover value calls, local scope, receiver chains, standalone discard, wrong arity,
    and recursion diagnostics. The Perl/Rust oracle corpus now includes
    `terse_4_3_2_user_function_runtime`, raising the corpus to **54 fixtures**.
  Commit: `SPEC-FORMAT-TERSE.4.3.2 - execute Rust user functions`; retained completion note: Rust runtime parity landed for registered value calls, receiver chains, standalone discard, local function scope, exact-arity diagnostics, recursion diagnostics, and the 54-fixture oracle corpus. Frontier becomes `.4.4`.

- ID: `SPEC-FORMAT-TERSE.4.4`
  Status: `done` (2026-07-02)
  Goal: Function surface finalization and deferred extension ledger
  Acceptance: Close the user-facing docs and retrieval state after Perl/Rust parity. Record explicit deferrals
    for alternate spellings (`function ... endfunction`, optional zero-arg parentheses, brace-less bodies),
    statementful functions, recursion, closures, lambdas, currying, and any future function namespace features.
  Verification: **DONE 2026-07-02.** The public book now states the exact accepted MVP surface: top-level
    `fn name(args) { ... }`, explicit parentheses for every arity including `fn name() { ... }`, braced
    value-oriented bodies, exact arity, fresh function-local variable stores, final-expression/`return(expr)`
    results, value-call composition, receiver-chain continuation, and standalone result discard on Perl/Rust.
    The same public/retrieval state explicitly defers alternate spellings (`function ... endfunction` and
    `fn ... endfn`), omitted zero-arg parentheses, brace-less bodies, caller-state/parser-state/persistent
    side-effect functions, recursive user functions, closures, lambdas, currying/partial application, and future
    namespace/module features. No parser/compiler/runtime code changed.
  Commit: `SPEC-FORMAT-TERSE.4.4 - finalize function surface ledger`; retained completion note: Function MVP docs/retrieval closure landed; frontier becomes `.3.2.2`.

- ID: `SPEC-FORMAT-TERSE.5`
  Status: `done` / `closed` (split 2026-07-01; future backend leaves now superseded by `FUTURE-PARITY-BACKLOG`)
  Goal: Future backend variant parity ownership before any non-Rust variant code
  Children: `.5.0` (done), `.5.1` (deferred), `.5.2` (deferred), `.5.3` (superseded by `FUTURE-PARITY-BACKLOG.1.3`)
  Acceptance: The implemented-variant inventory is explicit, the accepted future backend targets are tied
    back to ADR `0006`, and no future backend implementation can begin without a concrete owning leaf/tree
    plus a corpus-parity acceptance contract. This ownership slice must not add backend code.
  Verification: **SPLIT/OWNED 2026-07-01.** `.5.0` records the current backend inventory and future-backend
    boundaries. Julia and Dart remained accepted future targets from ADR `0006`; Lua had not yet been adopted
    by any then-current ADR, task tree, mdBook handoff chapter, or tracked source path. ADR `0021` later adopted
    Lua as a future backend target and scheduled backend rollout as Dart -> Julia -> Lua under
    `FUTURE-PARITY-BACKLOG`. The executable terse-language frontier returned to `.3.1` after this ownership slice.
  Commit: `SPEC-FORMAT-TERSE.5.0 - own future variant parity inventory`

- ID: `SPEC-FORMAT-TERSE.5.0`
  Status: `done` (2026-07-01)
  Goal: Inventory implemented/future backend variants and split future parity ownership
  Acceptance: Re-read the active roadmap/task tree, ADR `0006`, Phase 8/9 task trees, mdBook backend handoff,
    Knowledge Map backend facts, and tracked source layout. Record that the implemented backends are the Perl
    reference and the Rust interpreter, that future backend work needs explicit ownership before code, and
    that later adoption decisions belong in ADR/task-tree records. Update live docs and retrieval docs; do not
    change parser/compiler/runtime code.
  Verification: **PASS 2026-07-01.** Bootstrap/roadmap/mdBook/codebase read completed before edits. Source
    inventory found no tracked Julia, Dart, or Lua implementation paths outside the unrelated nested `rgx`
    checkout. ADR `0006`, Phase 8, and the mdBook backend handoff name Rust/Julia/Dart, while Phase 9 is
    explicitly Rust-only. The stale Knowledge Map statement that LinkedSpec was "currently Perl 5 only" was
    corrected to the post-Phase-9 inventory. Backend handoff wording now points at the current 52-fixture
    Rust corpus state after `.2.3.5.5`. Validation PASS: memory architecture, doctrine driver, Knowledge Map,
    `git diff --check`, and `mdbook build docs/linkedspec-book`; no engine code changed.
  Commit: `SPEC-FORMAT-TERSE.5.0 - own future variant parity inventory`; retained completion note: Future backend parity ownership is explicit: Perl reference and Rust are implemented; ADR `0021` later adopts Lua and moves future backend rollout to `FUTURE-PARITY-BACKLOG`. Frontier returns to `.3.1`.

- ID: `SPEC-FORMAT-TERSE.5.1`
  Status: `superseded` (2026-07-09 by `FUTURE-PARITY-BACKLOG.1.2` and `JULIA-BACKEND-PARITY`)
  Goal: Julia backend parity task-tree adoption
  Acceptance: When the roadmap selects Julia backend implementation, create or activate a dedicated backend
    task tree with concrete parser/compiler/runtime/helper/corpus leaves. The acceptance contract must require
    identical `.spec` input files, mdBook-neutral behavior, and language-neutral corpus parity before any
    feature is called complete.
  Verification: Superseded — `FUTURE-PARITY-BACKLOG.1.2` creates `docs/tasks/JULIA-BACKEND-PARITY.md` as the
    dedicated Julia backend parity plan after the Dart scoped milestone closes. Executable Julia work starts at
    `JULIA-BACKEND-PARITY.1.1`; no Julia backend code exists in this closed terse-format tree.
  Commit: `FUTURE-PARITY-BACKLOG.1.2 - scope Julia backend parity plan`

- ID: `SPEC-FORMAT-TERSE.5.2`
  Status: `superseded` (2026-07-09 by `FUTURE-PARITY-BACKLOG.1.1` and `DART-BACKEND-PARITY`)
  Goal: Dart backend parity task-tree adoption
  Acceptance: When the roadmap selects Dart backend implementation, create or activate a dedicated backend
    task tree with concrete parser/compiler/runtime/helper/corpus leaves. The acceptance contract must require
    identical `.spec` input files, mdBook-neutral behavior, and language-neutral corpus parity before any
    feature is called complete.
  Verification: Superseded — `FUTURE-PARITY-BACKLOG.1.1` created `docs/tasks/DART-BACKEND-PARITY.md`, and
    `DART-BACKEND-PARITY.7.5` later closed the scoped interpreter-first Dart milestone. No Dart code belongs to
    this closed terse-format tree.
  Commit: `DART-BACKEND-PARITY.7.5 - close Dart parity milestone`

- ID: `SPEC-FORMAT-TERSE.5.3`
  Status: `superseded` (2026-07-09 by ADR `0021` and `FUTURE-PARITY-BACKLOG.1.3`)
  Goal: Lua backend scope decision before any Lua parity leaf
  Acceptance: Lua may enter the backend set only after an explicit decision record or roadmap update adopts it
    and defines the same universal `.spec` / corpus-parity obligations as the accepted future backends.
  Verification: Superseded — ADR `0021` adopts Lua as a future backend target and schedules it after Dart
    and Julia. Implementation remains future work under `FUTURE-PARITY-BACKLOG.1.3`; no Lua backend code
    exists in this closed terse-format tree.
  Commit: `FUTURE-PARITY-BACKLOG.0 - create future parity backlog`

- ID: `SPEC-FORMAT-TERSE.6`
  Status: `done` (2026-07-04)
  Goal: Finish the terse-format declaration migration by removing `declare(...)` from live `.spec` files.
  Children: `.6.1`, `.6.2`, `.6.3`, `.6.4`

- ID: `SPEC-FORMAT-TERSE.6.1`
  Status: `done`
  Goal: Own the 2026-07-03 user directive that `declare(...)` shall not be used in spec files, and split the
    retirement work under this existing terse-format tree before any `.spec` edit.
  Acceptance: The task tree records the directive as the implementation of the existing `.1.1`/ADR `0007`
    gradual-migration promise; `docs/TASK_TREE.md`, roadmap/live docs, mdBook guidance, and Knowledge Map point at
    the new frontier; no `.spec` file is modified in this ownership leaf.
  Verification: Done — 2026-07-03. Active shipped-spec inventory found 70 `declare(...)` occurrences across 13
    files under `specs/`: `BNF`, `ds_vhistory`, `ebnf`, `hlink_substitution`, `lib_reader`, `Lispish`, `portmap`,
    `pplugin`, `sdce`, `simenv`, `spec`, `tablegrep`, and `vhdl`. The directive is owned here rather than in
    `RUST-PARITY`: do not expand runtime `declare` support to solve terse migration debt. The next executable leaf
    is `.6.2`.
  Commit: `SPEC-FORMAT-TERSE.6.1 - own declare retirement migration`; retained completion note: User directive owned under `SPEC-FORMAT-TERSE`; shipped-spec inventory recorded; no `.spec` file changed; frontier becomes `.6.2`.

- ID: `SPEC-FORMAT-TERSE.6.2`
  Status: `done` (2026-07-04)
  Goal: Migrate shipped specs to the canonical terse surface already landed by this tree.
  Children: `.6.2.1`, `.6.2.2`, `.6.2.3`, `.6.2.4`

- ID: `SPEC-FORMAT-TERSE.6.2.1`
  Status: `done` (2026-07-03)
  Goal: Remove `declare(...)` from shipped specs using auto-existing variables and explicit reset assignments.
  Acceptance: `rg -n '(^|[.{;[:space:]])declare\(' specs` returns no active hits; migrated specs compile on the
    Perl reference; representative behavior stays stable or exact blockers are split; no runtime `declare`
    expansion is introduced to compensate for old verbose syntax.
  Verification: PASS — 2026-07-03. Active `declare(...)` / `.declare(...)` use is removed from the 13 shipped
    specs found by `.6.1`: `BNF`, `ds_vhistory`, `ebnf`, `hlink_substitution`, `lib_reader`, `Lispish`,
    `portmap`, `pplugin`, `sdce`, `simenv`, `spec`, `tablegrep`, and `vhdl`. Replacements use terse
    initialization/reset forms (`name = value`, `name = undef`, `items = []`) plus structured lifecycle blocks
    where a fluent declaration chain needed to keep later statements ordered. The shipped-spec scan
    `rg -n 'declare\(|\.declare\(' specs` returns no hits. Focused `LinkedSpec::Get(..., return_descriptor => 1)`
    compilation passes for all edited shipped specs; `prove -q -Iperl t/phase0_regression.t` passes with **1018**
    tests; Rust `corpus_oracle` passes over **66 fixtures**. Stale phase0 expectations that required `DECLARE`
    action nodes were updated to the replacement `ASSIGN`/capture/source-read nodes. Commit-workflow gates also
    pass: Knowledge Map, memory architecture, doctrine registry, `git diff --check`, `mdbook build
    docs/linkedspec-book`, and `bash tools/run_ci_local.sh`.
  Commit: `SPEC-FORMAT-TERSE.6.2.1 - remove declare from shipped specs`; retained completion note: Removed the 70 active shipped-spec `declare(...)` / `.declare(...)` uses with terse assignments/resets and structured lifecycle blocks; phase0 and Rust corpus oracle pass; frontier becomes `.6.2.2`.

- ID: `SPEC-FORMAT-TERSE.6.2.2`
  Status: `done` (2026-07-03)
  Goal: Migrate old shipped-spec helper spellings to canonical terse helper spellings.
  Acceptance: Active shipped specs no longer use `assign(...)`, `push_value(...)`, `array_copy(...)`,
    `hash_copy(...)`, or `concat(...)` when a shipped terse equivalent already exists (`set`, `push`, `copy`,
    `cat`, assignment operators); `portmap.spec` also drops standalone statement separators after flow markers
    such as `if(...)`, `elseif(...)`, and `else()` where no following same-line construct makes the separator
    necessary; migrated specs compile and focused behavior checks stay stable.
  Verification: PASS — 2026-07-03. Active shipped-spec old-helper spelling scan
    `rg -n '\b(assign|push_value|array_copy|hash_copy|concat)\s*\(' specs` returns no hits. The `portmap.spec`
    flow-marker separator scan `rg -n '^\s*(?:if|elseif)\(.*\);\s*$|^\s*else\(\);\s*$' specs/portmap.spec`
    returns no hits. Registered descriptor compilation passes for all 21 shipped specs; stale phase0
    source-inspection expectations were updated to assert `set`, `push`, `copy`, and `cat`; `prove -q -Iperl
    t/phase0_regression.t` passes with **1018** tests; Rust `corpus_oracle` passes over **66 fixtures**.
  Commit: `SPEC-FORMAT-TERSE.6.2.2 - migrate shipped-spec helper spellings`; retained completion note: Migrated active shipped-spec old helper spellings to `set`, `push`, `copy`, and `cat`; cleaned redundant standalone `portmap.spec` flow-marker separators; phase0 and Rust corpus oracle pass; frontier becomes `.6.2.3`.

- ID: `SPEC-FORMAT-TERSE.6.2.3`
  Status: `done` (2026-07-04; both children done)
  Goal: Migrate shipped-spec typed wrappers/constructors toward terse scalar-slot reads, bare reads, and direct
    shape literals where the accepted inference rules make the replacement unambiguous.
  Children: `.6.2.3.1`, `.6.2.3.2`
  Acceptance: Wrapper cleanup proceeds only through concrete child leaves. Parser/runtime syntax extensions are
    owned before any shipped-spec migration uses them; any remaining `scalar(...)`, `array(...)`, or `hash(...)`
    use is explicitly classified as still-needed compatibility syntax or split into a narrower owner.
  Verification: DONE — `.6.2.3.1` first added and locked the `:name` scalar-slot shorthand on Perl/Rust; `.6.2.3.2`
    then retired active authored-spec `scalar(...)` and `assign(...)`, migrated shipped specs/corpora/fixtures to
    `:name`, direct assignment, bare aggregate reads, direct shape literals, and remembered bare identifier kinds,
    and kept mdBook current-facing examples clean.
  Commit: `.6.2.3.1`, `.6.2.3.2` (see Commit Log)

- ID: `SPEC-FORMAT-TERSE.6.2.3.1`
  Status: `done` (2026-07-03)
  Goal: Add `:name` as a terse scalar-slot expression for the value of scalar working variable `name`, with
    `set(:name, value)` preserving the explicit scalar target boundary that `set(scalar(name), value)` has today.
  Acceptance: Perl reference lowering and Rust parsing/runtime treat `:name` as equivalent to one-argument
    `scalar(name)` in value positions and as an explicit scalar target in assignment-like target positions;
    direct-shape aggregate inference for bare `name = [...]` / `set(name, [...])` remains unchanged; the mdBook
    documents `:name` as the preferred terse scalar spelling while `scalar(name)` remains accepted compatibility
    syntax; focused Perl/Rust tests and one oracle fixture lock the behavior.
  Verification: **DONE 2026-07-03.** Perl now recognizes `:name` in scalar source slots, direct shape literals,
    legacy `array(...)` / `hash(...)` constructor payloads, scalar assignment-like targets, and auto-working-var
    declaration collection. Rust adds `Expr::ScalarSlot { name }`, parses leading `:name` as a fluent-capable
    value primary, evaluates it through `ctx.get_scalar(name)`, and resolves it as an explicit scalar target.
    Direct-shape aggregate inference remains unchanged: bare `set(payload, [value])` assigns the array working
    variable, while `set(:payload, [value])` stores the whole array payload in scalar `payload`. **Verification:**
    `perl -c -Iperl` on `ActionIR/ValueExpr.pm`, `ActionIR/MethodLowering.pm`, `RuleIR/EmitContext.pm`, and
    `tools/gen_oracle_corpus.pl`; focused `call_spec_handler_subst` probes for `return(:name)`,
    `set(:payload, [value])`, `[:value]`, `array(:value)`, and hash shape members; `prove -q -Iperl
    t/phase0_regression.t` PASS (**1019 tests**); `cargo fmt --manifest-path rust/Cargo.toml --all`;
    `cargo test --manifest-path rust/Cargo.toml -p linkedspec-core parse_scalar_slot_shorthand_expr` PASS;
    `cargo test --manifest-path rust/Cargo.toml -p linkedspec-runtime terse_6_2_3_1_scalar_slot_shorthand_runs
    -- --nocapture` PASS; `perl -Iperl tools/gen_oracle_corpus.pl` generated **73 fixtures** including
    `terse_6_2_3_1_scalar_slot_shorthand`; `cargo test --manifest-path rust/Cargo.toml -p linkedspec-runtime
    --test corpus_oracle -- --nocapture` PASS over all 73 fixtures. mdBook + KM updated.
  Commit: `SPEC-FORMAT-TERSE.6.2.3.1 - add scalar slot shorthand`; retained completion note: Added `:name` as the scalar-slot shorthand on Perl/Rust; `set(:payload, [value])` keeps scalar payload assignment while bare direct-shape targets still infer aggregates; phase0 1019 and oracle 73 fixtures pass; frontier becomes `.6.2.3.2`.

- ID: `SPEC-FORMAT-TERSE.6.2.3.2`
  Status: `done` (2026-07-04)
  Goal: Retire `scalar(...)` and `assign(...)` from the supported/current-facing `.spec` surface now that `:name`,
    `set(...)`, assignment operators, bare reads, and direct shape literals cover their active use cases.
  Acceptance: Perl and Rust no longer lower or execute `scalar(...)` as a scalar-slot wrapper or `assign(...)` as
    an assignment alias; after a bare identifier is initialized as a scalar, array, or hash target, later bare
    references remember and reuse that known type so active specs do not need a wrapper to disambiguate the
    identifier; active shipped specs, oracle fixtures, phase0 fixtures, and user-facing mdBook examples no longer
    depend on either retired spelling; `assign(LHS, RHS)` is replaced by the terse operator form `LHS = RHS`,
    whose RHS shape infers and remembers the bare LHS kind; other replacement examples use `:name`, direct
    assignment, bare aggregate reads, direct shape literals, and bracket access as appropriate; any unavoidable
    historical mentions are clearly marked as retired historical evidence, not active syntax. Focused negative
    locks prove both old spellings fail or are absent from the supported helper surface, while migrated positives
    prove equivalent behavior through the terse forms and the initialized bare-identifier type memory.
  Verification: **DONE 2026-07-04.** Perl removed active raw `scalar(...)` scalar-slot lowering and raw authored
    `assign(...)` lowering while preserving parser-normalized internal assignment handling for `set(...)` and
    operator forms. `:name` lowers directly to scalar slot reads/targets, raw `assign(...)` is unsupported, and
    bare-kind memory is collected from direct assignments, parser-normalized `set(...)`, explicit scalar slots, and
    aggregate mutation/copy positions. Rust added `RuntimeVarKind` to remember scalar/array/hash stores and evaluates
    `Expr::Variable` / nested access bases through the remembered kind, with `Expr::ScalarSlot` staying the explicit
    scalar target/read. Active authored spec/corpus scan `rg -n '\bscalar\s*\(|\bassign\s*\(' specs tests/corpus
    rust/linkedspec-runtime/tests/corpus --glob '*.spec' --glob '*.md'` returns no hits; mdBook scan returns no hits.
    Verification run: `perl -c -Iperl` on edited ActionIR modules; `prove -q -Iperl t/actionir_ast_parser.t` PASS;
    `prove -q -Iperl t/phase0_regression.t` PASS (**1020 tests**); `cargo fmt --manifest-path rust/Cargo.toml
    --all --check` PASS; focused Rust tests `parse_scalar_slot_shorthand_expr`,
    `terse_6_2_3_1_scalar_slot_shorthand_runs`, and
    `terse_6_2_3_2_bare_identifier_remembers_type_after_initialization` PASS.
  Commit: `SPEC-FORMAT-TERSE.6.2.3.2 - retire scalar and assign spec helpers`; retained completion note: Authored/current specs moved to `:name`, `LHS = RHS` / `set(...)`, direct shapes, and remembered bare kind; raw authored `scalar(...)` and `assign(...)` are retired from the DSL surface; phase0 1020 and focused Rust checks pass.

- ID: `SPEC-FORMAT-TERSE.6.2.4`
  Status: `done` (2026-07-04)
  Goal: Final shipped-spec terse-surface verification and no-drift inventory.
  Acceptance: Shipped specs compile, phase0 and oracle gates pass or exact blockers are task-owned, and the
    shipped-spec old-surface inventory is either clean or fully annotated in this task tree before moving to docs
    and corpus sweeps.
  Verification: **DONE 2026-07-04.** `perl -Iperl -MLinkedSpec ...` descriptor-compiled all 21 shipped
    `specs/*.spec` files and confirmed `$INC{'LinkedSpec.pm'} = perl/LinkedSpec.pm`. Shipped-spec scans returned
    no hits for `scalar(...)` / `assign(...)`, no hits for `declare(...)` / `.declare(...)`, and no hits for
    `push_value(...)` / `array_copy(...)` / `hash_copy(...)` / `concat(...)`. `prove -q -Iperl
    t/phase0_regression.t` passed (**1020 tests**). `perl -Iperl tools/gen_oracle_corpus.pl` regenerated
    **73 fixtures** with no tracked corpus diff, and `cargo test --manifest-path rust/Cargo.toml -p
    linkedspec-runtime --test corpus_oracle -- --nocapture` passed all 73 fixtures. `mdbook build
    docs/linkedspec-book` passed, and the mdBook source scan has no `scalar(...)` / `assign(...)` hits. Broader
    checked-in corpus scans still find legacy `declare(...)` in `tests/corpus/{simple_grammar,tablegrep,lispish}`
    plus `rust/linkedspec-runtime/tests/corpus/autoexist_{array,scalar}_declare`, and old helper spellings in
    pre-terse corpus/compatibility fixtures; mdBook scans still find `declare(...)` and older helper references in
    the DSL/reference and walkthrough chapters. Those are not shipped-spec blockers and are the explicit input to
    `.6.3`. Full local CI (`bash tools/run_ci_local.sh`) passed after the documentation updates.
  Commit: `SPEC-FORMAT-TERSE.6.2.4 - verify shipped-spec terse surface`; retained completion note: Final shipped-spec no-drift verification passes: all 21 shipped specs compile, retired-surface/old-helper shipped scans are clean, phase0 1020 and Rust oracle 73 fixtures pass, mdBook builds, and broader docs/corpus legacy references are owned by `.6.3`.

- ID: `SPEC-FORMAT-TERSE.6.3`
  Status: `done` (2026-07-04)
  Goal: Sweep public docs, checked-in corpus/test specs, and current-facing examples so they no longer teach or
    depend on `declare(...)` as active spec-file authoring.
  Acceptance: mdBook and current guides document terse replacements first; examples use auto-existing variables,
    assignment operators, `set(...)`, `items = []`, `meta = { ... }`, `items += value`, and `meta[key] = value`
    instead of `declare(...)`; historical/task records remain only when clearly historical; book build and focused
    doc/corpus scans pass.
  Verification: **DONE 2026-07-04.** Current-facing mdBook chapters and root checked-in corpus specs now use terse
    initialization/mutation and canonical helper spelling: `name = value`, `items = []`, `meta = { ... }`,
    `items += value`, `meta[key] = value`, `push(...)`, `copy(...)`, and `cat(...)`. The root
    `tests/corpus/simple_grammar`, `tests/corpus/tablegrep`, and `tests/corpus/lispish` specs scan clean for
    active `declare(...)` / `.declare(...)` and old helper calls. The generated Rust oracle corpus now uses
    canonical terse helpers where the old spelling was incidental; residual `declare(...)`, `push_value(...)`,
    `array_copy(...)`, and `hash_copy(...)` hits are compatibility locks (`autoexist_*_declare`,
    `autoexist_array_bare_arg`, `terse_1_2_3_2_*_bare_read`, and the hash receiver-method fixture) or explicit
    legacy/reference documentation. Added Knowledge Map fact card
    `docs/knowledge/terse-merge-hash-bare-overlay-boundary.md` after probes confirmed
    `merge_hash(base, overlay)` is not equivalent to `merge_hash(copy(hash(base)), overlay)`.
    Focused scans over current-facing docs and root corpus pass; root corpus probes match existing expectations
    (`simple_grammar`, `tablegrep`, `lispish`); `perl -Iperl tools/gen_oracle_corpus.pl` regenerates **73
    fixtures** with no `expected.json` drift; Rust `corpus_oracle` passes all 73 fixtures; `mdbook build
    docs/linkedspec-book` passes; `prove -q -Iperl t/phase0_regression.t` passes (**1020 tests**); full local CI
    (`bash tools/run_ci_local.sh`) passes after the final live-doc updates.
  Commit: `SPEC-FORMAT-TERSE.6.3 - sweep docs and corpus declare examples`; retained completion note: Current-facing mdBook and checked-in corpus examples now use terse initialization/mutation and canonical helper spellings; root corpus scans/probes pass; generated oracle expected outputs are unchanged; residual old spellings are compatibility/reference-only; frontier becomes `.6.4`.

- ID: `SPEC-FORMAT-TERSE.6.4`
  Status: `done` (2026-07-04)
  Goal: Decide and implement the post-migration compatibility-support policy for declaration helpers.
  Acceptance: After `.6.2`/`.6.3` leave no live spec-file dependency, either keep implementation support explicitly
    documented as legacy compatibility or remove/diagnose it under a focused implementation leaf; Perl and Rust
    agree on the selected policy; final no-drift scans and local gates pass.
  Verification: **DONE 2026-07-04.** ADR `0018` records the selected policy: keep `declare(...)` and declaration
    aliases as accepted legacy compatibility for existing specs, do not use them in new shipped specs/current
    examples/root corpus examples, do not expand declaration support with new features, and require a future
    focused leaf for any removal or diagnostic hardening. The mdBook declaration reference and helper catalog now
    state that policy, `docs/knowledge/terse-declaration-helper-compatibility-policy.md` records the retrieval
    fact, and the Rust oracle corpus keeps declare/no-declare convergence fixtures as compatibility locks. No
    Perl/Rust implementation change is needed for this policy slice.
  Commit: `SPEC-FORMAT-TERSE.6.4 - lock declare compatibility policy`; retained completion note: ADR `0018` keeps declaration helpers as accepted legacy compatibility, excludes them from new authoring, and requires a future focused leaf for any removal/diagnostics; declaration-retirement `.6` closes and frontier becomes `.7.1`.

- ID: `SPEC-FORMAT-TERSE.7`
  Status: `done` (2026-07-04; no current `SPEC-FORMAT-TERSE` frontier)
  Goal: Audit and backfill the type method surface so useful helper functions are also available as receiver
    methods on the supported value types when that is readable and type-correct.
  Children: `.7.1`, `.7.2`, `.7.3`, `.7.4`

- ID: `SPEC-FORMAT-TERSE.7.1`
  Status: `done` (2026-07-04)
  Goal: Inventory supported runtime value types and helper families before implementation.
  Acceptance: The task tree lists every supported receiver/value family (string/scalar, array/list, hash, number,
    boolean/flow-result where applicable, block-yielded values, and user-function returns), maps existing helpers
    to plausible method candidates, identifies helpers that should remain function-only, and states backend/test/doc
    impact before any code changes.
  Inventory:
    - **String/scalar receivers:** scalar working variables, explicit scalar-slot reads, string literals,
      string-yielding blocks, string-yielding assignments, and string-returning user functions dispatch to the
      string receiver family. Existing receiver methods already include `trim`, `lowercase`, `uppercase`,
      `replace_substr`, `rm_prefix`, `rm_suffix`, `substr`, `concat`/`cat`, and `coalesce_nonempty`. `split(delim)`
      bridges to the array family. `length`, `starts_with`, `ends_with`, `contains_substr`, and `matches` are
      terminal value methods.
    - **Array/list receivers:** named arrays, `array(...)` snapshots, direct array shapes, array-yielding blocks,
      array-yielding assignments, and array-returning user functions dispatch to the array receiver family.
      Existing receiver methods already include `array_copy`/`copy`, `sorted`, `reversed`, `take`, `take_last`,
      `drop_front`, `drop_back`, `slice`, `concat_arrays`, `split_each`, `trim_each`, `filter_nonempty`,
      `lowercase_each`, `uppercase_each`, `uniq`, `filter_match`, `count`, `first`, `last`, `contains`,
      `index_of`, `is_empty`, `is_nonempty`, and `join_values`.
    - **Hash receivers:** named hashes, `hash(...)` snapshots, direct hash shapes, hash-yielding blocks,
      hash-yielding assignments, and hash-returning user functions dispatch to the hash receiver family. Existing
      receiver methods already include `hash_copy`, `merge_hash`, pure `set_key`, `rename_key`, `drop_keys`,
      `pick_keys`, and `flat_hash`; `sorted_keys` and `sorted_values` bridge to array receiver chains; `count_keys`
      and `has_key` are terminal value methods.
    - **Number receivers:** numeric literals, numeric scalar values, number-yielding blocks, numeric assignment
      values, and number-returning user functions dispatch to the number receiver family. Existing receiver methods
      map terse names to the `num_*` family: `abs`, `floor`, `ceil`, `round`, `add`, `sub`, `mul`, `div`, `mod`,
      `clamp`, `min`, and `max`; comparison terminals are `eq`, `ne`, `gt`, `ge`, `lt`, and `le`.
    - **Boolean/flow-result values:** booleans and predicate results are terminal flow values today. They feed
      control/helper conditions, but there is no boolean receiver family to expand in this lane unless a future
      task explicitly designs one.
    - **Block-yielded values and user-function returns:** expression-valued blocks and registered pure
      user-function calls do not own separate method tables. The yielded runtime value selects the compatible
      string, array, hash, or number receiver family.
    - **Function-only / statement-only boundaries:** mutation forms (`name = value`, `items += value`,
      `meta[key] = value`, statement `set_key(name, ...)`, statement regex `substr(:target, pattern, replacement,
      flags)` / `regex_subst(...)`, statement `split(array(target), source, delim)`, and array end mutations)
      remain explicit mutation surfaces. Lifecycle/control/dispatch helpers (`I`/`LS`/`LE`/`E`/`EX`/`IT`/`LX`,
      action-edge `.push`/`.return`, `call(child)`, `return(...)`, `if`/`switch`/`while`, `exit_now`, `next`),
      declaration helpers, capture/entry/match/input/mark readers, and compatibility aliases remain
      function/statement/lifecycle surfaces unless a later leaf gives them type-correct receiver semantics.
    - **Plausible follow-up candidates:** `.7.2` should verify the existing `substr()` receiver method and
      string-method parity/docs, then only implement genuinely missing string/scalar links. `.7.3` may audit
      whether array receiver aliases for numeric reducers (`sum`, `avg`, `median`, `range`, array `min`/`max`) are
      readable enough to add; scalar number receiver methods are already distinct from those array-consuming
      reducers.
  Backend/test/doc impact:
    - Any added method must update Perl `ActionIR::MethodLowering` receiver classifiers/lowering, Rust
      `engine.rs` receiver dispatch/runtime helper handling, focused parser/runtime tests, oracle fixtures when
      user-visible parity changes, mdBook helper docs, and Knowledge Map facts in one slice.
    - Because `substr()` is already present in the string/scalar receiver family, `.7.2` starts with verification
      and no-drift docs/test evidence before deciding whether any code change is needed.
  Verification: **DONE 2026-07-04.** KM retrieval and source inventory confirmed the current receiver families in
    Perl `ActionIR::MethodLowering` and Rust `engine.rs`. The mdBook helper catalog now states the audited
    receiver-family and non-method boundary, and `docs/knowledge/terse-type-method-surface-inventory.md` records
    the durable retrieval fact. Focused classifier scans, Knowledge Map regeneration/check, mdBook build, memory
    architecture, doctrine, Rust corpus oracle, and full local CI pass.
  Commit: `SPEC-FORMAT-TERSE.7.1 - inventory type method surface`; retained completion note: Receiver/value families, existing method tables, function/statement-only boundaries, and backend/test/doc impact are recorded before code; string `substr()` is already a receiver method, and frontier becomes `.7.2` verification/backfill.

- ID: `SPEC-FORMAT-TERSE.7.2`
  Status: `done` (2026-07-04)
  Goal: Backfill string/scalar receiver methods, explicitly including the user's `substr()` method directive.
  Acceptance: `substr(...)` is verified or implemented as a string/scalar receiver method on Perl and Rust, all
    other useful string helper candidates from `.7.1` are either implemented or explicitly deferred with reasons,
    and docs/tests demonstrate helper-form and method-form equivalence.
  Verification: **DONE 2026-07-04.** No parser/runtime code change was needed. Perl and Rust already accept the
    full useful string/scalar receiver set identified in `.7.1`: `trim`, `lowercase`, `uppercase`,
    `replace_substr`, `rm_prefix`, `rm_suffix`, `substr`, `concat`/`cat`, `coalesce_nonempty`, the array bridge
    `split`, and terminals `length`, `starts_with`, `ends_with`, `contains_substr`, and `matches`. The focused
    Perl probe:
    `return(array("abcdef".substr(1, 3).uppercase(), uppercase(substr("abcdef", 1, 3)), " a-b ".trim().split("-").count()))`
    returns `["BCD", "BCD", 2]`, and the descriptor metadata is `ready=1`, `fallback=0`, `raw=0`,
    `unresolved=0`. Focused Rust `cargo test --manifest-path rust/Cargo.toml -p linkedspec-runtime
    terse_2_3_5_3 --quiet` passes. Existing public docs demonstrate method/helper equivalence in
    `docs/linkedspec-book/src/dsl/value-container-flow-helper-reference.md` and
    `docs/linkedspec-book/src/appendix/helper-contract-catalog.md`; existing corpus fixture
    `terse_2_3_5_3_string_receiver_value_chains` locks Perl/Rust behavior. No additional string/scalar helper is
    deferred from `.7.2`; regex-substitution `substr(:target, pattern, replacement, flags)` remains an explicit
    statement mutation boundary, not a pure receiver method.
  Commit: `SPEC-FORMAT-TERSE.7.2 - verify string method surface`; retained completion note: String/scalar receiver methods, including `substr()`, are already implemented and documented on Perl/Rust; focused probes/tests verify helper-method equivalence; no parser/runtime/book behavior change was needed, and frontier becomes `.7.3`.

- ID: `SPEC-FORMAT-TERSE.7.3`
  Status: `done` (2026-07-04)
  Goal: Backfill useful array/list, hash, and number receiver methods from the `.7.1` inventory.
  Acceptance: Reasonable pure helper candidates are method-callable on matching receiver types, mutating or
    ambiguous helpers retain explicit statement/function forms unless the leaf defines safe receiver semantics, and
    Perl/Rust parity plus mdBook examples are locked.
  Verification: **PASS 2026-07-04.** Added terminal array/list receiver methods for numeric aggregate reducers:
    `sum`, `avg`, `median`, `range`, `min`, and `max`. Perl receiver chains lower those methods through the
    existing aggregate helper family, including array-returning links such as `sorted().take(...)` and pure
    internal array-pipeline links such as `uniq()`. Invalid reducer continuations such as
    `scores.sum().drop_front(1)` and `scores.min().sorted()` return `undef`/`null`. Rust accepts the same
    receiver methods, tightens array receiver terminal continuation handling, and supports the documented
    single-array `num_min(array_expr)` / `num_max(array_expr)` plus `min(array_expr)` / `max(array_expr)` forms.
    Hash receiver methods from `.7.1` already cover the useful pure hash surface; mutating/ambiguous helpers remain
    explicit statement/function forms. Locked by Perl phase0 (**1021 tests**), focused Rust `terse_7_3` integration
    tests, regenerated oracle fixture `terse_7_3_array_numeric_reducer_receiver_methods` (corpus **74 fixtures**),
    mdBook examples, and KM fact `terse-array-numeric-reducer-receiver-methods`.
  Commit: `SPEC-FORMAT-TERSE.7.3 - backfill array numeric reducer receiver methods`; retained completion note: Array/list numeric reducers `sum`, `avg`, `median`, `range`, `min`, and `max` are terminal receiver methods on Perl/Rust; invalid continuations return `undef`/`null`; phase0 1021 and oracle 74 fixtures pass.

- ID: `SPEC-FORMAT-TERSE.7.4`
  Status: `done` (2026-07-04)
  Goal: Final type-method no-drift sweep.
  Acceptance: The codebase, mdBook, helper catalog, examples, tests, and Knowledge Map agree on which helpers are
    methods, which remain function-only, and why; broad gates pass.
  Verification: **PASS 2026-07-04.** Reconciled the current receiver-family summaries after `.7.3`: `ROADMAP_V2.md`
    and `docs/TASK_TREE.md` no longer point at stale `.7.1`/`.7.3` frontiers; the mdBook helper-contract family
    summary now includes terminal array/list reducer methods; older number-receiver notes and the
    `terse-number-receiver-value-chains` Knowledge Map card now state the later `.7.3` boundary explicitly
    (array reducers are array/list receiver methods, not scalar number receiver links). Focused drift scans cover
    stale frontier text, 73/74 fixture wording, receiver-family summaries, numeric reducer statements, tests,
    corpus, and Knowledge Map facts. No source behavior change was needed.
  Commit: `SPEC-FORMAT-TERSE.7.4 - close type-method no-drift sweep`; retained completion note: Roadmap/task-tree/mdBook/KM receiver-family summaries are reconciled after `.7.3`; type-method lane closes with no Perl/Rust behavior change; at that time no concrete `SPEC-FORMAT-TERSE` leaf was pending.

- ID: `SPEC-FORMAT-TERSE.8`
  Status: `done` / `closed` (reactivated by user directive 2026-07-04; closed by `.8.6` on 2026-07-07)
  Goal: Remove all legacy compatibility helper-function support so the accepted `.spec` authoring surface is the
    terse surface only.
  Acceptance: Perl and Rust reject or stop lowering legacy helper spellings that remained accepted only for
    compatibility after `.6.4`, including declaration helpers (`declare(...)` and declaration aliases), old
    assignment/copy/concat/append spellings (`assign(...)`, `array_copy(...)`, `hash_copy(...)`, `concat(...)`,
    `push_value(...)` where a terse replacement exists), retired wrapper aliases (`s(...)`, `a(...)`, `h(...)`),
    and any lingering `scalar(...)` scalar-slot compatibility path. Current shipped specs, root corpus examples,
    generated oracle fixtures, mdBook examples, helper catalog, Knowledge Map facts, and roadmap/live docs must
    describe and exercise only the terse forms: auto-existing variables, bare value reads, `array(...)`, `hash(...)`,
    direct shape literals, `set(...)`, assignment operators, `push(...)`/`items += value`, `cat(...)`, and
    `copy(...)`. Historical changelog/task records may mention removed spellings only as past facts, not as
    current supported behavior.
  Children: `.8.1` (done — inventory/split), `.8.2` (done — current-source/test/corpus/doc migration and
    `push_nonempty(...)` replacement decision), `.8.3` (done — Perl hard retirement), `.8.4` (done — Rust
    hard retirement), `.8.5` (done — public docs/KM/reference cleanup), `.8.6` (done — no-drift closeout).
  Verification: **PASS 2026-07-07.** Children `.8.1` through `.8.6` closed the legacy-helper-retirement lane.
  Commit: `SPEC-FORMAT-TERSE.8.6 - close helper retirement drift`

- ID: `SPEC-FORMAT-TERSE.8.1`
  Status: `done` (2026-07-06)
  Goal: Inventory and split legacy helper-removal before any behavior change.
  Acceptance: LinkedSpec-tool probes and code reads classify which legacy helper spellings still succeed on Perl
    and Rust, which are already retired/diagnostic, which examples/docs/corpus surfaces still exercise them, and
    which child leaf owns each removal/migration boundary.
  Verification: **PASS 2026-07-06.** `LinkedSpec::call_spec_handler_subst` shows Perl currently leaves
    `assign(x, 1)` raw/unlowered, emits unsupported-helper diagnostics for `scalar(...)` and `s(...)`/`a(...)`/
    `h(...)`, and still successfully lowers `declare(...)`/`declare_s`/`declare_a`/`declare_h`, `concat(...)`,
    `array_copy(...)`, `hash_copy(...)`, `push_value(...)`, and `push_nonempty(...)`. Rust code reads show
    successful runtime arms for `declare`, `array_copy`, `hash_copy`, `concat`, `push_value`, `push_nonempty`, and
    wrapper aliases `array|a` and `hash|h`. Broad scans identify current shipped/corpus/doc/test hits, including
    `specs/ebnf.spec` and oracle fixtures still using `push_nonempty(...)`; because `push_nonempty(...)` filters
    undef/empty values and has no plain `push(...)` equivalent, `.8.2` owns either a behavior-preserving migration
    to existing terse expressions or a replacement split before hard retirement. Knowledge fact card
    `legacy-helper-retirement-split-inventory` records the reusable inventory.
  Commit: `SPEC-FORMAT-TERSE.8.1 - split legacy helper retirement`; retained completion note: Legacy helper-removal inventory/split: current successful compatibility paths and `push_nonempty(...)` replacement risk are classified; `.8.2` becomes the active migration owner before Perl/Rust hard retirement.

- ID: `SPEC-FORMAT-TERSE.8.2`
  Status: `done` (split 2026-07-06; closed 2026-07-06)
  Goal: Migrate current authored sources, checked-in corpus/oracle examples, active tests, mdBook examples, and
    current Knowledge facts away from still-successful legacy helper spellings before engine removal.
  Acceptance: Current `.spec`/corpus/book examples use `set(...)`, assignment operators, `push(...)`/`+=`,
    `cat(...)`, `copy(...)`, direct shapes, bare reads, and `array(...)`/`hash(...)` wrappers. Any
    `push_nonempty(...)` use is either rewritten with identical behavior using existing terse constructs or split
    into a separately owned replacement before removal. Historical tests/docs may keep old spellings only when they
    assert retired diagnostics or document past behavior. Oracle generation and mdBook build stay in sync.
  Children: `.8.2.1` (done — live EBNF `push_nonempty(...)` migration and generated EBNF oracle refresh),
    `.8.2.2` (done — incidental active test/corpus old-helper migration; leave only explicit legacy/diagnostic
    locks), `.8.2.3` (done — current-facing mdBook/KM helper-reference cleanup), `.8.2.4` (done — no-drift
    closeout before hard retirement), `.8.3` (done — Perl hard retirement), `.8.4` (done — Rust hard
    retirement).
  Verification: **PASS 2026-07-06.** Child leaves `.8.2.1` through `.8.2.4` migrated the live EBNF
    `push_nonempty(...)` flow, active tests/corpus fixtures, generated oracle inputs, current-facing mdBook/KM
    references, and final no-drift scans before hard retirement. Root `specs/` and `tests/corpus/` are clean for
    retired helper spellings; generated corpus/test residues are classified as `.8.3`/`.8.4`
    compatibility/retirement locks or current receiver-method surface; oracle regeneration is stable over **93**
    fixtures; Rust `corpus_oracle`, mdBook, full phase0 **1022**, whitespace, and doctrine gates pass.
  Commit: `SPEC-FORMAT-TERSE.8.2.4 - close helper migration no-drift gates`

- ID: `SPEC-FORMAT-TERSE.8.2.1`
  Status: `done` (2026-07-06)
  Goal: Migrate the current live EBNF optional-capture append path away from `push_nonempty(...)` before helper
    removal.
  Acceptance: `specs/ebnf.spec`, generated EBNF oracle corpus inputs, and the EBNF mdBook walkthrough no longer
    use `push_nonempty(...)`. The replacement evaluates the trimmed capture slice once, appends it only when
    `is_nonempty(...)` is true, preserves the existing `logging_annotation` JSON output, and keeps oracle generation
    and mdBook in sync. The decision for helper retirement is explicit: do not introduce a new one-off replacement
    helper for this pattern; use ordinary assignment, `is_nonempty(...)`, and `push(...)`.
  Verification: **PASS 2026-07-06.** `specs/ebnf.spec` now assigns the trimmed capture slice to
    `logging_annotation_part`, gates on `is_nonempty(logging_annotation_part)`, and calls
    `push(array(logging_annotation), logging_annotation_part)` in both the comma and closing-edge branches.
    `perl -Iperl tools/gen_oracle_corpus.pl` regenerated **93** fixtures; only generated EBNF `input.spec` files
    changed and `expected.json` stayed byte-stable. `LinkedSpec::get_parser("ebnf")` returns the same
    `logging_annotation` JSON payload for `@log_rule("expr", "term")`. Focused scoped scan finds no
    `push_nonempty(...)` in `specs/ebnf.spec`, the EBNF mdBook walkthrough, or the generated EBNF oracle inputs.
    `mdbook build docs/linkedspec-book` passed; Rust `corpus_oracle` passed all **93** fixtures. Full phase0 first
    exposed one stale source-inspection assertion expecting the old helper; after updating that lock to the explicit
    filter flow, `prove -q -Iperl t/phase0_regression.t` passed **1022** tests.
  Commit: `SPEC-FORMAT-TERSE.8.2.1 - migrate EBNF nonempty append flow`; retained completion note: Live EBNF `push_nonempty(...)` use migrated to explicit assignment + `is_nonempty(...)` + `push(...)`; generated EBNF oracle inputs and mdBook walkthrough now match the shipped spec, with oracle expected output unchanged.

- ID: `SPEC-FORMAT-TERSE.8.2.2`
  Status: `done`
  Goal: Migrate incidental legacy helper spellings in active Rust/Perl tests and generated corpus fixtures while
    preserving only explicit legacy/diagnostic assertions for the retirement leaves.
  Acceptance: Active tests that are not asserting legacy compatibility use `push(...)`/`+=`, `copy(...)`, `cat(...)`,
    assignments, direct shapes, and current wrappers. Remaining old-helper test strings are annotated as
    compatibility or retired-diagnostic locks owned by `.8.3`/`.8.4`.
  Verification: **PASS 2026-07-06.** Child leaves `.8.2.2.1` through `.8.2.2.5` migrated or classified active
    Rust source-emitter fixtures, Rust integration fixtures, generated oracle inputs, and Perl phase0 terse
    fixtures. Final closeout scans show root `specs/` and `tests/corpus/` clean for the retired helper spellings;
    source-emitter clean; Rust integration and generated corpus residue limited to recursive declaration scope,
    explicit legacy-helper compatibility, aggregate-copy compatibility, current hash receiver-method surface, and
    wrapper-alias retirement locks; and phase0 residue limited to `.8.2.2.4` compatibility/equivalence categories.
  Commit: `SPEC-FORMAT-TERSE.8.2.2.5 - close active test corpus helper residue`

- ID: `SPEC-FORMAT-TERSE.8.2.2.1`
  Status: `done`
  Goal: Migrate incidental legacy helper spellings in `rust/linkedspec-runtime/tests/source_emitter.rs`.
  Acceptance: Source-emitter proof specs use current-surface helper spellings for aggregate initialization,
    appends, aggregate copies, and string concatenation. The source-emitter test suite still compiles generated
    Rust parsers and preserves the asserted JSON payloads.
  Verification: **PASS 2026-07-06.** Embedded source-emitter `.spec` fixtures now use explicit
    `set(array(...), [])` aggregate initialization/reset, `push(...)`, `copy(...)`, and `cat(...)` instead of
    incidental legacy helper spellings. The first direct `name = []` migration attempt failed the repeated
    pair/group snapshot cases, proving that direct duck-typed assignment binds a scalar-held array value rather
    than clearing the named aggregate later mutated by `push(array(name), ...)`; the final migration keeps aggregate
    storage explicit through `set(array(name), [])`. Focused residue scan over
    `rust/linkedspec-runtime/tests/source_emitter.rs` finds no `declare(...)`, `push_value(...)`,
    `array_copy(...)`, `hash_copy(...)`, `concat(...)`, or `push_nonempty(...)`. `cargo test --manifest-path
    rust/Cargo.toml -p linkedspec-runtime --test source_emitter` passed all **3** tests, including generated Rust
    parser compile/run proofs.
  Commit: `SPEC-FORMAT-TERSE.8.2.2.1 - migrate source-emitter helper fixtures`; retained completion note: Rust source-emitter smoke specs use current helper spellings and explicit aggregate resets; focused residue scan is clean and generated-source compile/run tests pass.

- ID: `SPEC-FORMAT-TERSE.8.2.2.2`
  Status: `done`
  Goal: Migrate or classify legacy helper spellings in active Rust integration-test strings.
  Acceptance: Incidental setup grammars use current-surface spellings. Intentional compatibility and retired
    diagnostic locks remain explicit and are annotated with their owning retirement leaves.
  Verification: **PASS 2026-07-06.** The Rust integration-test helper-string lane is closed. Smoke fixtures,
    recursive TOP-RULE-AS-NORMAL fixtures, explicit compatibility/equivalence tests, later current-feature
    fixtures, hash receiver-chain residue, and typed wrapper-alias residue are each migrated or classified by
    child leaves `.8.2.2.2.1` through `.8.2.2.2.5`. Remaining old-helper spellings in `integration_test.rs` are
    explicitly tied to recursive scoped-declaration compatibility, `.8.4` legacy-helper retirement locks, current
    hash receiver-method surface, or wrapper-alias retirement.
  Commit: `SPEC-FORMAT-TERSE.8.2.2.2.5 - classify integration helper residue`

- ID: `SPEC-FORMAT-TERSE.8.2.2.2.1`
  Status: `done`
  Goal: Migrate non-compatibility Rust integration smoke fixtures before the explicit legacy-alias blocks.
  Acceptance: The top-level smoke spec, user-function smoke helpers, corpus/lifecycle/edge smoke tests, `retv_5_1`
    tests, and `match_5_2` tests use current helper spellings without changing asserted outputs. Explicit
    compatibility blocks and recursive declare-scope edge cases remain untouched for later children.
  Verification: **PASS 2026-07-06.** `SIMPLE_GRAMMAR`, staged user-function smoke helpers, corpus/lifecycle/edge
    smoke grammars, `retv_5_1`, and `match_5_2` now use current `set(array(...), [])`, `push(...)`, `copy(...)`,
    `cat(...)`, and direct scalar assignment spellings. The scoped helper-hit scan now starts at the later
    TOP-RULE-AS-NORMAL recursive block, outside this child. Focused `full_pipeline` and
    `function_body_staged_prototype_end_to_end_shape_and_runtime` filters passed, and full
    `cargo test --manifest-path rust/Cargo.toml -p linkedspec-runtime --test integration_test` passed all **172**
    tests.
  Commit: `SPEC-FORMAT-TERSE.8.2.2.2.1 - migrate integration smoke helper fixtures`; retained completion note: Rust integration smoke fixtures before the recursive/compatibility blocks use current helper spellings; full integration test passes **172** tests.

- ID: `SPEC-FORMAT-TERSE.8.2.2.2.2`
  Status: `done`
  Goal: Migrate or classify the TOP-RULE-AS-NORMAL recursive integration-test helper spellings.
  Acceptance: Recursive `sexpr` tests preserve the scoped declaration/aggregate semantics captured in existing
    Knowledge Map facts. Any retained old-helper spelling is explicitly tied to a compatibility or diagnostic owner.
  Verification: **PASS 2026-07-06.** TOP-RULE-AS-NORMAL recursive `sexpr` integration-test fixtures now use
    current `push(...)`, `copy(...)`, and `array(...)` spellings around the recursive accumulator. The
    `declare(array, items)` initializer is intentionally retained as a Rust scoped-declaration compatibility lock:
    a candidate replacement with `set(array(items), [])` failed the two Rust value-parity tests by leaking/overwriting
    recursive frame state, while a matching Perl probe stayed output-equivalent. The mdBook helper catalog and
    Knowledge facts now record this Rust hard-retirement boundary. Focused TOP-RULE and full Rust integration tests
    pass, along with mdBook, Knowledge Map, memory, doctrine, and whitespace checks.
  Commit: `SPEC-FORMAT-TERSE.8.2.2.2.2 - classify recursive helper fixtures`; retained completion note: TOP-RULE-AS-NORMAL recursive fixtures use current append/snapshot helpers; `declare(...)` remains an intentional Rust scoped-declaration compatibility lock for `.8.4` to resolve before hard retirement.

- ID: `SPEC-FORMAT-TERSE.8.2.2.2.3`
  Status: `done`
  Goal: Migrate or annotate explicit legacy-helper compatibility/equivalence tests in Rust integration tests.
  Acceptance: Tests that prove old spellings equal current spellings are either converted to current-surface tests
    with equivalent coverage or annotated as intentional compatibility locks for `.8.3`/`.8.4` retirement.
  Verification: **PASS 2026-07-06.** The early Rust integration compatibility/equivalence block now uses current
    `push(...)`, `copy(...)`, and `hash(...)` spellings on current-side assertions. Retained old helper spellings in
    that block are annotated as explicit Rust `.8.4` hard-retirement locks: declaration helper sides, semantic
    `push_nonempty(...)`, aggregate-copy helper compatibility assertions, string concat helper compatibility,
    `push_value(...)`, and the legacy `h(...)` wrapper side. Later current-feature fixture strings remain owned by
    `.8.2.2.2.4`. Focused filters for `terse_1_1_2`, `terse_1_2`, `terse_1_4_2`, and `terse_1_3_2` passed; full
    `integration_test` passed **172** tests; Rust formatting, memory architecture, doctrine, and whitespace checks
    passed.
  Commit: `SPEC-FORMAT-TERSE.8.2.2.2.3 - annotate legacy helper tests`; retained completion note: Explicit Rust legacy-helper compatibility/equivalence tests now use current-side helper spellings and label retained old-helper sides as `.8.4` hard-retirement locks.

- ID: `SPEC-FORMAT-TERSE.8.2.2.2.4`
  Status: `done`
  Goal: Migrate later current-feature Rust integration fixtures that still carry incidental old-helper spellings.
  Acceptance: Current terse feature tests outside explicit compatibility blocks use `push(...)`/`+=`, `copy(...)`,
    `cat(...)`, and explicit aggregate setters where needed, with focused Rust test filters passing.
  Verification: **PASS 2026-07-06.** Later current-feature Rust integration fixture strings outside explicit
    compatibility blocks now use current `push(...)`, `copy(...)`, and explicit aggregate-setter spellings where
    the current surface supports them. The array append-operator equivalence test now compares against current
    `push(...)`. A candidate rewrite of hash receiver chains from `.hash_copy()` to `.copy()` failed the focused
    hash receiver-chain test by returning `Null`, so documented `.hash_copy()` receiver spellings and wrapper alias
    `h(...)` strings remain for `.8.2.2.2.5` residue classification. Focused Rust filters for `terse_1_`,
    `terse_2_3`, `rust_parity_7_3_4`, `rust_parity_7_5_2`, `terse_11_3`, and `terse_3_3` passed; full
    `integration_test` passed **172** tests; Rust formatting and whitespace checks passed.
  Commit: `SPEC-FORMAT-TERSE.8.2.2.2.4 - migrate later integration fixtures`; retained completion note: Later current-feature Rust integration fixtures use current helper spellings where supported; hash receiver and wrapper-alias residue remains for `.8.2.2.2.5` classification.

- ID: `SPEC-FORMAT-TERSE.8.2.2.2.5`
  Status: `done`
  Goal: Close Rust integration-test helper-string cleanup with a residue classification scan.
  Acceptance: Remaining old-helper strings in `integration_test.rs` are each either gone or classified as explicit
    compatibility/retirement locks before generated-corpus fixture migration starts.
  Verification: **PASS 2026-07-06.** Focused residue scan over `integration_test.rs` shows every remaining
    old-helper spelling under an explicit owner. TOP-RULE-AS-NORMAL recursive `declare(array, items)` is owned by
    `.8.2.2.2.2`; early compatibility/equivalence helper strings are owned by `.8.2.2.2.3` and `.8.4`; the hash
    receiver-chain `.hash_copy()` calls are documented as current receiver-method surface; and the quoted wrapper
    boundary test keeps `h(...)` only as a legacy wrapper-alias retirement lock. Rust formatting passed.
  Commit: `SPEC-FORMAT-TERSE.8.2.2.2.5 - classify integration helper residue`; retained completion note: Remaining Rust integration-test helper-string hits are each classified under recursive scope, explicit legacy compatibility, current receiver-method surface, or wrapper-alias retirement ownership.

- ID: `SPEC-FORMAT-TERSE.8.2.2.3`
  Status: `done`
  Goal: Migrate or classify legacy helper spellings in generated oracle corpus fixture inputs.
  Acceptance: Generated fixture inputs avoid incidental old-helper spellings where behavior is current-surface;
    remaining old-helper fixtures are tied to compatibility or retirement diagnostics with no oracle drift.
  Verification: **PASS 2026-07-06.** `tools/gen_oracle_corpus.pl` now emits current helper spellings where
    generated fixture behavior is current-surface: `autoexist_array_bare_arg` and TOP-RULE recursion inputs use
    `push(...)`/`copy(...)`, and incidental setup in the aggregate-copy compatibility fixture uses `push(...)`.
    Retained generated-corpus residues are explicitly classified as declaration compatibility, aggregate-copy
    compatibility, or current hash receiver-method surface. `perl -c -Iperl tools/gen_oracle_corpus.pl` passed;
    regeneration emitted **93** fixtures with only expected `input.spec` changes; Rust `corpus_oracle` passed all
    **3** tests including the full Perl reference comparison; residue scan, formatting, whitespace, memory, and
    doctrine checks passed.
  Commit: `SPEC-FORMAT-TERSE.8.2.2.3 - migrate generated corpus helper fixtures`; retained completion note: Generated oracle corpus helper fixture inputs use current helper spellings where behavior is current-surface; retained residues are classified with no oracle expected-output drift.

- ID: `SPEC-FORMAT-TERSE.8.2.2.4`
  Status: `done`
  Goal: Migrate or classify legacy helper spellings in Perl phase0 test strings.
  Acceptance: Perl regression strings that are not directly testing legacy compatibility use current-surface
    spellings, while remaining old-helper assertions are explicitly owned by the hard-retirement leaves.
  Verification: **PASS 2026-07-06.** Current-surface Perl phase0 embedded specs now use `cat(...)`, `push(...)`,
    and `copy(...)` where they are not compatibility locks. TOP-RULE recursion append/snapshot paths,
    user-function helpers, auto-existence append proofs, current-feature snapshot returns, array method fixtures,
    and mutation-expression snapshots were migrated. Retained old-helper hits are classified as scoped-declaration
    compatibility, `push_nonempty(...)` semantic-filter compatibility, aggregate-copy compatibility,
    helper-renaming equivalence, canonical old-side equivalence, or current `.hash_copy()` receiver-method surface.
    A candidate all-bare `push(words, label)` rewrite failed the full phase0 comparison because that spelling
    remains child-call-shaped; the accepted current form is `push(array(words), label)` when the RHS is a bare
    scalar read. `perl -c -Iperl t/phase0_regression.t` passed; full phase0 with `PERL5LIB=` cleared passed
    **1022** tests; focused phase0 residue scan found every remaining old-helper spelling under an explicit owner;
    Rust formatting, whitespace, memory architecture, and doctrine checks passed.
  Commit: `SPEC-FORMAT-TERSE.8.2.2.4 - migrate Perl phase0 helper strings`; retained completion note: Perl phase0 fixture strings use current helper spellings where behavior is current-surface; retained old-helper strings are classified and full phase0 passes 1022 tests.

- ID: `SPEC-FORMAT-TERSE.8.2.2.5`
  Status: `done`
  Goal: Close the active-test and corpus helper-string cleanup with focused residue scans.
  Acceptance: Rust/Perl active tests and generated corpus inputs are clean or each residual old-helper spelling is
    classified as an intentional compatibility or retired-diagnostic lock before `.8.2.3`.
  Verification: **PASS 2026-07-06.** Focused scans covered active Rust tests, generated oracle inputs, generator
    source, shipped specs, checked-in corpus specs, and the Perl phase0 terse block. Root `specs/` and
    `tests/corpus/` are clean for primary retired helper spellings and wrapper aliases. Generated oracle inputs
    retain only owned declaration, aggregate-copy, and current hash receiver-method categories. Perl phase0 residue
    remains within the `.8.2.2.4` classified terse block. Rust integration scan false positives were limited to
    input strings such as `(a(b)c)`, and real `a(...)` / `h(...)` wrapper-alias fixture strings are now labelled as
    `.8.4` retirement locks. Rust formatting, whitespace, memory architecture, and doctrine checks passed.
  Commit: `SPEC-FORMAT-TERSE.8.2.2.5 - close active test corpus helper residue`; retained completion note: Active-test/corpus helper residue scans are clean or classified; Rust integration wrapper-alias residue is labelled and `.8.2.2` closes.

- ID: `SPEC-FORMAT-TERSE.8.2.3`
  Status: `done`
  Goal: Migrate current-facing mdBook and Knowledge Map helper references away from the old helper spellings before
    implementation removal.
  Acceptance: Current-facing docs teach `cat(...)`, `copy(...)`, assignments, `push(...)`, and explicit
    `if(is_nonempty(value)) { push(...) }` filtering first. Legacy names appear only in historical compatibility or
    retired-diagnostic sections, and Knowledge fact-card `reverify` commands avoid removed spellings unless they
    explicitly prove retirement.
  Verification: **PASS 2026-07-06.** Current-facing mdBook helper examples and compatibility tables now use or
    recommend current spellings: `cat(...)`, `copy(...)`, assignments, `push(...)`, and explicit
    `if(is_nonempty(value)) { push(...) }` filters. The declaration helper reference, value/container flow guide,
    source-boundary migration table, helper catalog, and formal grammar appendix no longer present old helper calls
    as current authoring examples. Knowledge fact-card `reverify` commands were migrated away from legacy helper
    spellings unless the card explicitly proves retirement or compatibility, and `KNOWLEDGE_MAP.md` was regenerated.
    `mdbook build docs/linkedspec-book`, Knowledge Map check, whitespace check, memory-architecture check, and
    doctrine check passed.
  Commit: `SPEC-FORMAT-TERSE.8.2.3 - migrate book and knowledge helper references`

- ID: `SPEC-FORMAT-TERSE.8.2.4`
  Status: `done`
  Goal: Close the migration parent with focused scans and regenerated artifacts before hard retirement.
  Acceptance: Current-source/test/corpus/doc/KM scans are clean or each residual old-helper spelling is tied to a
    pending hard-retirement diagnostic. Oracle generation, corpus oracle, mdBook, doctrine checks, and focused
    phase0/Rust checks pass.
  Verification: **PASS 2026-07-06.** Focused scans show root `specs/` and `tests/corpus/` clean for primary
    retired helper spellings and wrapper aliases. Generated corpus input residues are limited to declaration
    compatibility, aggregate-copy compatibility, and current `.hash_copy()` receiver-method fixtures; active Rust
    integration and Perl phase0 residues remain tied to `.8.2.2.*`, `.8.3`, or `.8.4` compatibility/retirement
    locks. `perl -c -Iperl tools/gen_oracle_corpus.pl` passes, `perl -Iperl tools/gen_oracle_corpus.pl` regenerates
    **93** fixtures with no git drift, Rust `corpus_oracle` passes all **3** tests, `env PERL5LIB= prove -q -Iperl
    t/phase0_regression.t` passes **1022** tests, `mdbook build docs/linkedspec-book` passes, and whitespace and
    doctrine checks pass.
  Commit: `SPEC-FORMAT-TERSE.8.2.4 - close helper migration no-drift gates`

- ID: `SPEC-FORMAT-TERSE.8.3`
  Status: `done` (2026-07-06)
  Goal: Hard-retire Perl reference support for still-successful legacy helper spellings after `.8.2` migration.
  Acceptance: Perl lowering no longer successfully recognizes `declare(...)`/declaration aliases, `concat(...)`,
    `array_copy(...)`, `hash_copy(...)`, `push_value(...)`, or `push_nonempty(...)` as current helper spellings;
    retired uses produce explicit diagnostics or remain raw only in negative tests. Current terse replacements keep
    behavior.
  Verification: **PASS 2026-07-06.** Perl lowering now emits
    `LINKEDSPEC_UNSUPPORTED_ACTIONIR_HELPER:<name>` diagnostics for declaration helpers and aliases,
    function-form `concat(...)`, `array_copy(...)`, `hash_copy(...)`, `push_value(...)`, and
    `push_nonempty(...)`, while current `cat(...)`, `copy(...)`, `push(...)`, assignments, typed wrappers, and
    receiver `.cat(...)` / `.hash_copy()` behavior continue to lower. AST call nodes preserve source spelling so
    parser-normalized current `cat(...)` does not get mistaken for retired `concat(...)`, and receiver/source
    reconstruction keeps current helper spellings in synthesized nested expressions. Focused direct probes,
    `perl -c -Iperl` syntax checks for touched Perl/test modules, focused Perl AST/trace/validation suites, full
    phase0 **1022**, mdBook, Knowledge Map, memory, whitespace, and doctrine gates pass.
  Commit: `SPEC-FORMAT-TERSE.8.3 - hard-retire Perl legacy helpers`; retained completion note: Perl legacy helper spellings now diagnose instead of lowering successfully; current terse replacements keep behavior; frontier becomes `.8.4`.

- ID: `SPEC-FORMAT-TERSE.8.4`
  Status: `done` (2026-07-07)
  Goal: Hard-retire Rust parser/runtime support for legacy helper spellings after `.8.2` migration.
  Acceptance: Rust no longer executes `declare`, `array_copy`, `hash_copy`, `concat`, `push_value`,
    `push_nonempty`, or wrapper aliases `a(...)`/`h(...)` as successful current helper spellings; current terse
    replacements keep corpus parity. The recursive TOP-RULE-AS-NORMAL accumulator boundary found in
    `.8.2.2.2.2` must be resolved here before `declare(...)` removal: either Rust gains current-surface
    rule-invocation scoping for undeclared recursive accumulators or retired declaration use produces an explicit
    diagnostic with replacement guidance.
  Verification: **PASS 2026-07-07.** Rust runtime now routes retired helper spellings to explicit
    `LINKEDSPEC_UNSUPPORTED_ACTIONIR_HELPER:<name>` diagnostics instead of successful execution. Removed successful
    helper dispatch for `declare`, `array_copy`, `hash_copy`, `concat`, `push_value`, `push_nonempty`, and wrapper
    aliases `a(...)` / `h(...)`; Rust validation keeps those names known only so diagnostics reach runtime. Current
    fixture/corpus sources use `set(array(...), [])`, `set(hash(...), hash())` / direct shapes, `push(...)`,
    `copy(...)`, `cat(...)`, `array(...)`, `hash(...)`, and hash receiver `.copy()`. Recursive TOP-RULE-AS-NORMAL
    replacement now works because explicit aggregate resets record rule-local bindings before mutation, giving
    `set(array(items), [])` the scoped snapshot/restore behavior that old `declare(array, items)` supplied in Rust.
    Perl oracle regeneration also exposed a source-reconstruction bug: attached control-flow lowering must preserve
    AST `source_method` so current `cat(...)` inside blocks is not reconstructed as retired `concat(...)`; this is
    fixed and locked in phase0. Verification run: `perl -c -Iperl` on touched Perl modules, `perl -c -Iperl
    tools/gen_oracle_corpus.pl`, `ORACLE_TIMEOUT=45 perl -Iperl tools/gen_oracle_corpus.pl` (93 fixtures), focused
    Rust retirement/TOP-RULE/hash-receiver/corpus tests, full `cargo test --quiet --manifest-path rust/Cargo.toml -p
    linkedspec-core`, full `cargo test --quiet --manifest-path rust/Cargo.toml -p linkedspec-runtime`, and full
    `prove -q -Iperl t/phase0_regression.t` **1022** pass.
  Commit: `SPEC-FORMAT-TERSE.8.4 - hard-retire Rust legacy helpers`

- ID: `SPEC-FORMAT-TERSE.8.5`
  Status: `done`
  Goal: Reconcile user-facing docs, helper catalog, Knowledge facts, roadmap/live docs, and diagnostics after Perl
    and Rust legacy helper retirement.
  Acceptance: Current-facing docs and fact-card `reverify` commands describe only supported terse helper spellings;
    legacy names appear only in historical records or retired-diagnostic guidance.
  Verification: 2026-07-07: root guides, mdBook current surfaces, Rust README, and Knowledge facts reconciled;
    `KNOWLEDGE_MAP.md` regenerated; `knowledge-map/scripts/check_knowledge_map.sh`, `mdbook build
    docs/linkedspec-book`, and `git diff --check` pass; memory/doctrine gates run in commit closeout.
  Commit: `SPEC-FORMAT-TERSE.8.5 - reconcile helper retirement docs`

- ID: `SPEC-FORMAT-TERSE.8.6`
  Status: `done`
  Goal: Final no-drift closeout for legacy helper retirement.
  Acceptance: Stale legacy-helper scans across current specs/corpora/docs/tests/KM/code pass, oracle corpus and
    mdBook stay in sync, and the next frontier advances to `.9`.
  Verification: **PASS 2026-07-07.** Current executable specs/corpora scan clean for retired helper calls:
    no `declare(...)`, `assign(...)`, `array_copy(...)`, `hash_copy(...)`, `concat(...)`, `push_value(...)`,
    `push_nonempty(...)`, or scalar-slot `scalar(...)` calls remain in `specs/`, root corpus specs, or Rust oracle
    corpus specs. Short-wrapper alias scans only hit literal input text `(a(b)c)` in recursion fixtures, not helper
    calls. Colon-prefixed scalar-slot scans only hit comments, Perl namespace examples, regex syntax, and string
    literals. Code/test/doc/KM residue is classified as unsupported-helper diagnostics, retirement regression
    locks, historical/migration notes, Knowledge facts, or explicit retired-helper reference text. Root
    `USER_GUIDE.md` had one stale current-facing `concat(...)` paragraph; it now teaches `cat(...)` and states
    source-spelled `concat(...)` is retired. Added Knowledge fact
    `terse-helper-retirement-no-drift-closeout`. `perl -c -Iperl tools/gen_oracle_corpus.pl` passes; `perl -Iperl
    tools/gen_oracle_corpus.pl` regenerates **93** fixtures with no corpus drift; Rust `corpus_oracle` passes **3**
    tests. mdBook/Knowledge Map/memory/doctrine gates pass in commit closeout. Frontier advances to `.9` after this
    clean commit.
  Commit: `SPEC-FORMAT-TERSE.8.6 - close helper retirement no-drift`

- ID: `SPEC-FORMAT-TERSE.9`
  Status: `done` / `closed` (activated 2026-07-07; split by `.9.1` before implementation; closed by `.9.6`)
  Goal: Replace Perlish hash-literal association syntax with terse colon association syntax.
  Acceptance: The current `.spec` hash literal syntax uses `{ key : value }` for key/value association in direct
    hash shape literals and examples. The old `{ key => value }` spelling is removed from the accepted current
    authoring surface, generated oracle fixtures, active tests, mdBook examples, and Knowledge Map current facts
    except where historical task/changelog records explicitly discuss past syntax. Perl and Rust parse/evaluate
    colon hash literals consistently, including nested shape literals, direct RHS target-kind inference
    (`meta = { key : value }`), mutation RHS values (`meta[key] = { key : value }`), block-vs-hash precedence,
    and expression-valued assignment forms. The book documents `:` as the hash-literal key/value separator and
    no longer teaches `=>` as current `.spec` syntax.
  Verification: **PASS 2026-07-07.** `.9.1` split the migration surface, `.9.2` added Perl colon support,
    `.9.3` added Rust parity, `.9.4` migrated current source/docs/KM/corpus/tests to `{ key : value }`, `.9.5`
    hard-retired old `{ key => value }` source syntax on Perl/Rust, and `.9.6` closed no-drift scans/gates.
    Remaining `=>` owners are blind-call edge syntax, VHDL/source-language associations, generated Perl host
    output, metadata/test data, value-rendering examples, explicit retired-diagnostic tests, or historical records.
  Commit: `SPEC-FORMAT-TERSE.9.6 - close hash literal colon drift`

- ID: `SPEC-FORMAT-TERSE.9.1`
  Status: `done` (2026-07-07)
  Goal: Audit/split the hash-literal `=>` to `:` migration surface before parser/runtime changes.
  Acceptance: Current `=>` occurrences are classified by owner (blind-call edge syntax, direct hash-literal syntax,
    shipped non-ActionIR grammars such as VHDL associations, docs/KM historical material, tests/oracle fixtures,
    parser/runtime support sites). The implementation sequence is split so blind-call `=>` remains valid while
    hash-literal association migrates to colon syntax, and `.9.2`+ descendants have clear acceptance boundaries.
  Verification: **PASS 2026-07-07.** Classification scans show direct hash-literal `=>` candidates in current
    docs/root guides, mdBook DSL/helper/formal-grammar pages, Knowledge facts, Perl parser tests, oracle generator
    fixture strings, generated Rust oracle corpus inputs, and selected shipped-spec surfaces such as
    `specs/user_function_definition.spec` and legacy/raw Perl-ish `tablegrep` / `tkgui` forms. Blind-call edge
    `=>` is distinct syntax in `specs/spec.spec`, Rust corpus copies, and formal grammar docs and must remain
    valid. VHDL/source-language `=>` in `specs/vhdl.spec` and related corpus fixtures is not ActionIR
    hash-literal syntax and must remain. Parser/runtime ownership is split across Perl
    `ActionIR/AST/Parser.pm` (`_parse_hash_literal_expr`, `_find_top_level_fat_arrow`) and Rust
    `linkedspec-core/src/expr.rs::parse_hash_literal` plus `HashLiteral` evaluation in
    `linkedspec-runtime/src/engine.rs`. Added Knowledge fact `hash-literal-colon-migration-split`. Frontier
    advances to `.9.2` for Perl reference colon-hash support.
  Commit: `SPEC-FORMAT-TERSE.9.1 - split hash literal colon migration`

- ID: `SPEC-FORMAT-TERSE.9.2`
  Status: `done` (2026-07-07)
  Goal: Add Perl reference support for colon hash-literal association while keeping old `=>` available only for the
    migration window.
  Acceptance: Perl ActionIR AST parsing/lowering accepts `{ key : value }`, quoted keys, nested colon hash
    literals, direct RHS assignment, mutation RHS values, expression-valued assignment forms, and block-vs-hash
    precedence without disturbing blind-call edges.
  Verification: **PASS 2026-07-07.** `ActionIR/AST/Parser.pm` now uses a top-level hash-pair scanner that accepts
    `:` and old `=>` during the migration window while skipping `::`. Focused parser coverage locks colon hash
    literals with bare/quoted keys, nested array/hash values, mixed old/new separators, hash-index assignment RHS
    values, and `{ JSON::PP }` block classification. Phase0 subtest
    `spec_format_terse_9_2_perl_colon_hash_literal_support` locks lowering/runtime behavior for return payloads,
    direct assignment, hash-index mutation, expression-valued `set(...)` / `=(...)`, array composition, generated
    Perl host `=>` output, zero fallback/unresolved helpers, and ActionIR readiness. Full
    `env PERL5LIB= perl -Iperl t/phase0_regression.t` passes with plan `1..1023`. Frontier advances to `.9.3`.
  Commit: `SPEC-FORMAT-TERSE.9.2 - add Perl colon hash literals`; retained completion note: Perl reference accepts `{ key : value }` hash-literal association during the migration window, preserves old `=>` until hard retirement, keeps generated Perl host fat arrows internal, and advances the frontier to `.9.3` Rust parity.

- ID: `SPEC-FORMAT-TERSE.9.3`
  Status: `done` (2026-07-07)
  Goal: Add Rust parser/runtime parity for colon hash-literal association.
  Acceptance: Rust parses/evaluates the same colon hash-literal forms as Perl, including nested shapes, direct RHS
    assignment, mutation RHS values, expression-valued assignment forms, receiver chains, and block-vs-hash
    precedence, while blind-call `=>` remains edge syntax.
  Verification: **PASS 2026-07-07.** `rust/linkedspec-core/src/expr.rs` now parses direct hash-literal pairs with
    either old `=>` or new `:` during the migration window, and the brace disambiguation scanner detects top-level
    hash-pair separators while skipping `::`, nested braces, parentheses, brackets, strings, and regex literals.
    Focused parser tests lock colon-only nested hashes, mixed old/new separators, assignment/mutation RHS and
    expression-valued assignment slots, and scanner edge cases. Rust runtime integration test
    `terse_9_3_colon_hash_literals_parse_and_run` locks direct assignment, hash-index mutation RHS, value-form
    `set(...)` / `=(...)`, array composition, direct hash receiver chaining, and expression-valued block
    precedence. Frontier advances to `.9.4`.
  Commit: `SPEC-FORMAT-TERSE.9.3 - add Rust colon hash literals`; retained completion note: Rust parser/runtime accepts `{ key : value }` hash-literal association during the migration window, preserves old `=>` until hard retirement, keeps blind-call edge `=>` separate, and advances the frontier to `.9.4` current-source/docs/corpus migration.

- ID: `SPEC-FORMAT-TERSE.9.4`
  Status: `done` (2026-07-07)
  Goal: Migrate current specs, generated oracle fixtures, active tests, mdBook examples, root docs, and current
    Knowledge facts from hash-literal `=>` to `:`.
  Acceptance: Current-facing `.spec` authoring examples and generated oracle inputs use `{ key : value }` where
    they mean direct hash-literal association. Remaining `=>` occurrences are blind-call edge syntax, non-ActionIR
    grammar payloads, or explicitly historical/retirement material.
  Verification: **PASS 2026-07-07.** Current source/docs/corpus/KM examples now prefer colon hash-literal
    association: `specs/user_function_definition.spec`, `specs/tablegrep.spec`, `specs/tkgui.spec`, root corpus
    copies, generated Rust oracle inputs, Rust integration tests, Perl phase0 strings, mdBook helper/runtime/formal
    grammar pages, root `USER_GUIDE.md`, and current Knowledge facts were migrated. Remaining `=>` occurrences are
    classified as blind-call edge syntax, VHDL/source-language associations, generated Perl host-output hashrefs,
    Perl metadata hashes, historical/changelog material, or the explicit mixed old/new migration-window parser lock.
    Migration exposed and fixed a Perl `MethodLowering.pm` source fallback that still detected only `=>` in
    expression-valued block receiver chains; it now recognizes top-level `:` while skipping `::`.
    `tools/gen_oracle_corpus.pl` regenerates **93** fixtures. `perl -Iperl -c tools/gen_oracle_corpus.pl`,
    `perl -Iperl -c perl/LinkedSpec/ActionIR/MethodLowering.pm`, `prove -q -Iperl t/actionir_ast_parser.t`, full
    `prove -q -Iperl t/phase0_regression.t` (`1..1023`), focused Rust parser/runtime filters, Rust corpus oracle,
    mdBook, Knowledge Map, memory, whitespace, doctrine gates, and `bash tools/run_ci_local.sh` pass. Frontier
    advances to `.9.5`.
  Commit: `SPEC-FORMAT-TERSE.9.4 - migrate hash literals to colon`; retained completion note: Current specs/corpus/docs/KM/tests now prefer `{ key : value }`; classified `=>` owners remain for blind-call edges, source-language associations, generated Perl host output, metadata, history, and explicit compatibility locks; frontier advances to `.9.5` hard retirement.

- ID: `SPEC-FORMAT-TERSE.9.5`
  Status: `done` (2026-07-07)
  Goal: Hard-retire old hash-literal `=>` association from current Perl/Rust ActionIR value syntax.
  Acceptance: `{ key => value }` no longer parses/evaluates as a current hash-literal association in Perl or Rust
    ActionIR value positions; diagnostics point to `{ key : value }`. Blind-call `=> Rule` edge syntax and
    non-ActionIR grammar payloads remain valid.
  Verification: **PASS 2026-07-07.** Perl `ActionIR/AST/Parser.pm` now marks direct top-level `=>` hash-literal
    payloads as retired instead of building a current `hash_literal` AST, and `MethodLowering.pm` lowers both AST
    and source-fallback retired forms to the explicit
    `LINKEDSPEC_UNSUPPORTED_ACTIONIR_HELPER:hash_literal_use_colon` diagnostic instead of interpreting them as a
    raw/fallback path. Valid colon hash literals still lower, and AST source reconstruction now serializes current
    hash literals with `:` while generated Perl host hashrefs may still use Perl `=>`. Rust
    `linkedspec-core/src/expr.rs` now rejects `=>` in direct hash-literal parsing with the same colon-migration
    diagnostic, and the Rust compiler treats unsupported-ActionIR-helper parse diagnostics as fatal compile
    errors so action code cannot be silently accepted as `code: None`. Focused Perl/Rust parser, compiler, and
    runtime tests pass. Full phase0 exposed and then locked a Perl AST aggregate-call fix: multi-argument
    `array(...)` now emits `[...]` directly from already-lowered args so generated Perl host hashrefs are not
    reparsed as retired source fat arrows. Full `prove -q -Iperl t/phase0_regression.t` passes with plan
    `1..1024`; mdBook, Knowledge Map, memory/doctrine/diff/Rust-format checks, and local CI pass.
  Commit: `SPEC-FORMAT-TERSE.9.5 - retire hash literal fat arrows`; retained completion note: Perl/Rust now reject old `{ key => value }` as current ActionIR hash-literal syntax, point diagnostics to `{ key : value }`, keep blind-call edge `=>` separate, and advance the frontier to `.9.6` final no-drift closeout.

- ID: `SPEC-FORMAT-TERSE.9.6`
  Status: `done` (2026-07-07)
  Goal: Final no-drift closeout for hash-literal colon association.
  Acceptance: Scans across current specs/corpora/docs/tests/KM/code show no unclassified current hash-literal `=>`
    usage, generated oracle fixtures and Rust corpus oracle stay in sync, mdBook documents `:` as the current
    hash-literal separator, and the frontier advances past `.9`.
  Verification: **PASS 2026-07-07.** Current `.spec` source scans under `specs/`, `tests/corpus/`, and
    `rust/linkedspec-runtime/tests/corpus/` found no direct hash-literal `=>` surface. Remaining `=>` hits are
    classified as blind-call grammar/edge syntax, source-language association regexes, generated Perl host output,
    Perl metadata/test data, value-rendering examples, explicit retired-syntax diagnostics/tests, or historical
    records. mdBook proof scans show the current direct hash-literal separator documented as `:` and the old
    `{ key => value }` spelling documented only as retired. `tools/gen_oracle_corpus.pl` regenerates **93**
    fixtures, `prove -q -Iperl t/actionir_ast_parser.t` passes, focused Rust core/runtime `.9` tests pass, Rust
    `corpus_oracle` passes over the manifest-backed **93** fixtures, and full `prove -q -Iperl
    t/phase0_regression.t` passes with plan `1..1024`.
  Commit: `SPEC-FORMAT-TERSE.9.6 - close hash literal colon drift`; retained completion note: Final no-drift scans classify all remaining `=>` owners, mdBook documents `:` as current and old hash-literal fat arrows only as retired, oracle generation/Rust corpus oracle/full phase0 pass, and `.9` closes with no PNT-eligible child remaining.

- ID: `SPEC-FORMAT-TERSE.10`
  Status: `done` (2026-07-08; closed by `.10.1`)
  Goal: Decide whether direct hash literals have any dynamic/computed key surface beyond the fixed-key syntax
    accepted by the spec, and implement it only if the spec explicitly defines that surface first.
  Children: `.10.1` (done)
  Acceptance: No parser/runtime implementation may broaden hash-literal key semantics by accident. Before any
    code change, the leaf must either (a) be closed as `dropped` with the explicit decision that direct hash
    literals accept only the fixed key forms defined by `.9`, or (b) be split into a specification-first
    implementation plan that defines exact dynamic/computed-key syntax, bare-key stringification rules, quoted-key
    behavior, expression-key delimiters if any, block-vs-hash precedence, nested literal behavior, Perl/Rust parity,
    diagnostics for ambiguous key forms, mdBook examples, active tests, generated oracle fixtures, and Knowledge
    Map updates. This leaf is not PNT-eligible while `.8` and `.9` are pending.
  Verification: `2026-07-08: closed as a spec-ratification/no-engine-change leaf. KM retrieval plus TOOLBOX
    lowering/runtime probes show the current `.9`/`.15` surface already has a dynamic key-expression contract:
    direct hash literals use `{ key_expr : value_expr }`; bare key names read scalar values; quoted keys are fixed
    strings; computed helper expressions such as `cat(prefix,suffix)` are valid key expressions; old `=>` remains
    retired; and block-vs-hash precedence stays unchanged. mdBook wording and a Knowledge fact now make the
    current contract explicit.`
  Commit: `SPEC-FORMAT-TERSE.10.1 - ratify dynamic hash-literal keys`

- ID: `SPEC-FORMAT-TERSE.10.1`
  Status: `done` (2026-07-08)
  Goal: Reactivate `.10`, audit the current direct hash-literal key behavior, and close it as an explicit
    spec contract without parser/runtime changes if the existing behavior is already intentional and documented.
  Acceptance: The task tree records whether dynamic/computed keys are accepted or dropped; mdBook explains the
    accepted key-expression contract and fixed-key quoting rule; a Knowledge fact gives future sessions the
    answer and reverify command; live docs point to the next `SPEC-FORMAT-TERSE` frontier; no parser/runtime
    behavior changes are made in this spec-ratification slice.
  Verification: `2026-07-08: LinkedSpec::call_spec_handler_subst lowers return({ key : value }) as
    $key => $value, lowers return({ cat(prefix,suffix) : value, "fixed" : key }) with the computed helper
    expression as the hash key, and preserves quoted fixed keys. A direct `LinkedSpec::Get` runtime probe returns
    `[{"stage":"ok"},{"fixed":"stage","stage":"ok"},{"key":"ok"}]` for bare, computed, and quoted key examples.
    Rust code read confirms `parse_hash_literal` parses the key with `parse_expr()` before the top-level `:`, and
    runtime evaluation stringifies the evaluated key with `to_str()`.`
  Commit: `SPEC-FORMAT-TERSE.10.1 - ratify dynamic hash-literal keys`; retained completion note: Direct hash literals are explicitly expression-keyed: bare keys are scalar reads, quoted keys are fixed strings, and computed helper expressions may supply keys. No parser/runtime behavior changed; `.10` is closed.

- ID: `SPEC-FORMAT-TERSE.11`
  Status: `done` (2026-07-05; `.11.1` through `.11.5` done)
  Goal: Adopt duck-typed `.spec` variable assignment semantics so variables bind typed values at runtime instead of
    exposing Perl-style scalar/array/hash storage classes through assignment inference.
  Children: `.11.1` (done), `.11.2` (done), `.11.3` (done), `.11.4` (done), `.11.5` (done).
  Acceptance: The spec, parser, Perl lowering, Rust runtime, generated oracle corpus, active tests, mdBook, and
    Knowledge Map agree that `name = value` binds `name` to the typed value produced by the RHS. Scalar, number,
    string, array, and hash values are all legal RHS values; `name = [...]` binds an array value, `name = {...}`
    binds a hash value, and later `name = ...` may rebind the same name to a different typed shape. Direct
    `[...]` / `{...}` literals are value literals, not declarations or Perl-sigil target-kind inference triggers.
    The `.11` MVP keeps aggregate RHS syntax explicit: `name = [a, b]` and `name = { k : v }` are accepted
    value-literal assignments, while delimiterless aggregate sugar such as `name = a, b` or `name = k : v` is
    out of scope unless a later task-tree leaf specifies its precedence, diagnostics, and parser recovery rules.
    Deeply nested references and assignments through array/hash value trees must be supported in arbitrary
    combinations. Reads and writes such as hash-then-array, array-then-hash, and longer mixed paths are part of the
    `.11` contract, including both statement-form assignment and expression-valued assignment where the language
    already supports assignment expressions. The implementation must specify and test intermediate-container
    behavior for nested writes instead of inheriting Perl autovivification semantics by accident.
    `array(name)` and `hash(name)` remain explicit typed reads/snapshots/guards at use sites, not declaration
    mechanisms. The implementation must remove or rewrite current assignment tests and lowering paths that infer
    `@name` / `%name` storage solely from RHS shape. Perl may keep private implementation details internally, but
    no user-facing spec, diagnostic, mdBook example, or Knowledge Map fact may describe assignment in terms of
    Perl storage classes. Hash-literal syntax must coordinate with `.9`: examples use whichever key/value
    separator is current when the child implementation lands, and no `.11` code may reintroduce `{ key => value }`
    as a current surface after `.9`.
  Verification: **DONE 2026-07-05.** `.11.1` split the work after bootstrap/probes; `.11.2` landed Perl
    duck-typed value binding; `.11.3` landed Rust parity; `.11.4` landed nested mixed value-path assignment; and
    `.11.5` closed current-facing docs, roadmap, mdBook/KM alignment, and corpus/oracle wording. Assignment is now
    documented as typed value binding across active surfaces. Historical RHS target-kind inference remains only as
    explicitly superseded history.
  Commit: closed by child commits through `SPEC-FORMAT-TERSE.11.5 - close duck-typed assignment alignment`

- ID: `SPEC-FORMAT-TERSE.11.1`
  Status: `done` (2026-07-05)
  Goal: Split duck-typed assignment implementation after full bootstrap/code/book inventory and toolbox probes.
  Acceptance: Before code, identify the exact current drift from the `.11` contract, split the implementation into
    signoff-sized children, and record the dirty-work boundary so later commits do not mix unrelated helper-removal
    work with assignment semantics.
  Verification: **PASS 2026-07-05.** Completed the mandatory bootstrap read (`README.md`,
    `MEMORY_ARCHITECTURE.md`, `MEMORY.md`, `SESSION_BOOTSTRAP.md`, `COMMIT.md`, `TOOLBOX.md`, task tree,
    relevant ADRs, and Knowledge Map facts), read the mdBook source set for assignment/container drift, inspected
    the LinkedSpec facade/import tree plus the ActionIR/Rust seams for assignments and variable stores, and used
    toolbox probes with `perl -Iperl` to confirm current behavior. Current Perl still lowers bare direct-shape
    assignments as target-kind inference (`x = []` -> `@x = ()`, `set(x, {})` -> `%x = ()`) and the collector still
    records matching `my @x` / `my %x` declarations. Rust still has direct-shape assignment branches that retag
    bare targets into array/hash stores. The worktree also contains pre-existing `.8` helper-removal / `.15`
    tracking edits, so implementation is split to keep staging and commit ownership precise. No parser/runtime/book
    behavior changed in this leaf.
  Commit: `SPEC-FORMAT-TERSE.11.1 - split duck-typed assignment work`; retained completion note: Split duck-typed assignment after bootstrap, code/book/KM inventory, and toolbox probes; frontier became `.11.2`.

- ID: `SPEC-FORMAT-TERSE.11.2`
  Status: `done` (2026-07-05)
  Goal: Perl reference — replace RHS-shape target-kind inference with duck-typed value binding for bare assignment
    targets.
  Acceptance: Perl lowering for `name = value`, `set(name, value)`, expression-valued `=(name, value)`, and the
    corresponding generated-source declaration collector treats bare `name` as one runtime value binding. Direct
    shape RHS values lower as values (`[]`/`{}` payloads held by the variable), not as `@name` / `%name` storage
    assignment solely because of RHS shape. Explicit typed view/mutation surfaces must be handled deliberately and
    documented in the child verification; no stale collector path may emit `my @name` or `my %name` solely from
    `name = [...]` / `name = {...}`. Focused Perl source/runtime tests must replace the old
    `shape_rhs_infers_bare_targets` locks.
  Verification: **PASS 2026-07-05.** Perl bare assignment and `set` lowering now use scalar value binding for
    direct shape RHS values: `name = []` -> `$name = []`, `name = { key => value }` ->
    `$name = {$key => $value}`, `set(name, [value])` -> `$name = [$value]`, and expression-valued
    `return(set(items, [value]))` / `return(=(items, [value]))` return `$items`. Explicit
    `set(array(items), [value])` and `set(hash(meta), {...})` remain aggregate-storage mutation targets. The
    auto-working-var collector records scalar declarations for bare shape assignment targets and no longer emits
    `my @items` / `my %meta` solely from RHS shape. Scalar-bound `array(name)` / `hash(name)` value views now read
    guarded snapshots from `$name`, including reducer/read helpers such as `count(array(items))`,
    `count_keys(hash(meta))`, `first(array(items))`, and `sorted_values(hash(meta))`. Focused probes covered
    lowering, generated declarations, runtime readback, and the assignment-expression closure. Syntax gates passed
    for `perl/LinkedSpec/ActionIR/MethodLowering.pm`, `perl/LinkedSpec/RuleIR/EmitContext.pm`, and
    `t/phase0_regression.t`; `git diff --check` passed for the touched Perl/test files. A clean detached-worktree
    `prove -q -Iperl t/phase0_regression.t` rerun completed with the `.11.2` assignment locks green and one
    helper-readiness failure outside this slice: `emit_context_lowers_split_tagged_records_helper` reports
    `unresolved_helper_count == 1` and therefore is not language-agnostic ready.
  Commit: `SPEC-FORMAT-TERSE.11.2 - implement Perl duck-typed assignment binding`; retained completion note: Perl reference bare assignment now binds typed RHS values through scalar storage; explicit aggregate targets remain aggregate storage; frontier became `.11.3`.

- ID: `SPEC-FORMAT-TERSE.11.3`
  Status: `done` (2026-07-05)
  Goal: Rust runtime parity for duck-typed assignment and bare variable value reads.
  Acceptance: Rust `Expr::AssignScalar` and `set`/`=` helper execution bind the evaluated `RuntimeValue` to the
    named variable without retagging bare targets from direct RHS shape. Later assignments may replace a scalar
    with an array/hash value and vice versa. Rust integration and oracle fixtures must replace the old
    `.1.2.3.5.4` target-kind inference expectations.
  Verification: **PASS 2026-07-05.** Rust `Engine` removed the direct RHS-shape target-retagging path for bare
    assignment and helper assignment. `Expr::AssignScalar`, statement-form `name = value`, and helper-form
    `set(name, value)` / `=(name, value)` now evaluate the RHS and store the resulting `RuntimeValue` in the
    scalar value slot, so direct array/hash RHS values are scalar-held typed values. Explicit raw `array(name)` and
    `hash(name)` targets still route to aggregate storage. Guarded scalar-held snapshots now feed
    `array(name)`, `hash(name)`, `copy(...)`, aggregate-consuming helper slots, and array/hash receiver chains when
    `bare_kind(name)` is scalar. The final oracle pass also closed the narrow Perl reference fallback where
    scalar-held `copy(name)` and bare array receiver chains still preferred aggregate storage unless explicitly
    wrapped; the Perl declaration collector also now records the scalar slot for remembered-scalar `copy(name)`
    instead of reintroducing aggregate preamble declarations. Focused Rust locks cover scalar-held direct-shape
    assignment, replacement across scalar/array/hash shapes, bare `set(...)` value binding, explicit aggregate
    targets, scalar-slot shorthand readback, and the `.3.3.2`/`.3.3.4` assignment-expression cases. Perl
    syntax/probe checks cover scalar-held copy/receiver readback and declaration collection.
    `tools/gen_oracle_corpus.pl` regenerated the oracle corpus to **91** manifest-listed fixtures with
    `.11.3` cases replacing the old `.1.2.3.5.4` expectations, and the Rust corpus oracle passes. Broad
    `prove -q -Iperl t/phase0_regression.t` completes with the `.11` locks clean and one known unrelated failure:
    `emit_context_lowers_split_tagged_records_helper` still reports `unresolved_helper_count == 1`.
  Commit: `SPEC-FORMAT-TERSE.11.3 - implement Rust duck-typed assignment parity`; retained completion note: Rust now scalar-binds bare assignment RHS values, including direct array/hash shapes, and keeps explicit `array(...)` / `hash(...)` targets as aggregate storage. Oracle corpus is 91 fixtures; frontier becomes `.11.4`.

- ID: `SPEC-FORMAT-TERSE.11.4`
  Status: `done` (2026-07-05)
  Goal: Specify and implement nested mixed array/hash value-path reads and writes.
  Acceptance: Nested paths through duck-typed values support arbitrary hash-then-array, array-then-hash, and longer
    mixed read/write combinations in statement and expression-valued assignment contexts. Missing intermediate
    containers, wrong-shape transitions, array index extension, and hash key creation are specified in LinkedSpec
    terms and covered on Perl/Rust without accidentally inheriting Perl autovivification semantics.
  Verification: **PASS 2026-07-05.** Perl AST assignment parsing now distinguishes multi-segment direct-access
    lvalues as `assign_nested_access`; `ActionIR::MethodLowering` lowers nested statement and value assignments to
    explicit guarded mutation blocks; generated code checks every intermediate container instead of relying on Perl
    autovivification, creates/replaces final hash keys, replaces/appends final array elements only at existing
    indexes or len, and returns `undef` for missing/wrong/gap paths. Single-segment scalar-held array/hash roots
    now mutate their scalar-held value before falling back to named hash storage. Rust `Expr::AssignNestedAccess`
    plus runtime `assign_nested_runtime_value(...)` implements the same semantics, and statement-form
    `AssignHashIndex` now reuses the expression assignment path so `payload[1] = value` mutates scalar-held arrays
    consistently. Focused Perl syntax/probe checks covered nested lowering, scalar-held array roots, generated
    declarations, and descriptor readiness. Focused Rust `.11.4` tests pass. `tools/gen_oracle_corpus.pl`
    regenerated the corpus to **92** manifest-listed fixtures, preserving known `spec_spec_*` expected AST fixtures
    after generator drift, and the Rust corpus oracle passes with the new
    `terse_11_4_nested_mixed_value_path_assignment` case. mdBook and Knowledge Map now document the explicit
    no-autovivification write contract. Broad phase0 was rerun after the `.11.4` assertion fix and still has the
    pre-existing unrelated `emit_context_lowers_split_tagged_records_helper` failure only (`1/1022` failed).
  Commit: `SPEC-FORMAT-TERSE.11.4 - implement nested value-path assignment`; retained completion note: Nested mixed direct-access writes now mutate scalar-held array/hash value trees on Perl/Rust with explicit no-autovivification path guards; oracle corpus is 92 fixtures; frontier becomes `.11.5`.

- ID: `SPEC-FORMAT-TERSE.11.5`
  Status: `done` (2026-07-05)
  Goal: Close duck-typed assignment documentation, Knowledge Map, corpus/oracle, and mdBook alignment.
  Acceptance: Active tests, generated oracle fixtures, mdBook chapters, helper catalog, live docs, and current
    Knowledge Map facts describe assignment as typed value binding, not Perl storage-class inference. Historical
    task/changelog references may remain historical; current-facing guidance must not teach direct RHS shape as
    declaration or target-kind inference. Coordinate examples with `.9` if hash-literal colon syntax has landed.
  Verification: **PASS 2026-07-05.** Scanned current-facing roadmap, mdBook, live docs, and Knowledge Map facts for
    stale RHS-shape target-kind inference language. `ROADMAP_V2.md` now says the old inference branch is historical
    and superseded by `.11` duck-typed value binding, and the corpus count is **92** with
    `terse_11_4_nested_mixed_value_path_assignment`. Fact cards that still referenced the old inference as a
    dependency now point readers to the `.11` supersession, while the explicit historical inference cards remain
    marked `superseded`. `KNOWLEDGE_MAP.md` was regenerated. The mdBook assignment/container sections already
    describe typed binding, explicit aggregate targets, and nested no-autovivification writes, so no book behavior
    change was needed in this closeout leaf.
  Commit: `SPEC-FORMAT-TERSE.11.5 - close duck-typed assignment alignment`; retained completion note: Roadmap/current docs and Knowledge Map retrieval now present typed value binding as current behavior and target-kind inference as superseded history; `.11` closes and frontier becomes `.15`.

- ID: `SPEC-FORMAT-TERSE.12`
  Status: `done` / `closed` (reactivated by user directive 2026-07-08; exhausted by `.12.4`)
  Goal: Specify hash-tree traversal receiver methods with attached code blocks for operating on leaves.
  Children: `.12.1` (done), `.12.2` (done), `.12.3` (done), `.12.4` (done).
  Acceptance: Hash-tree traversal is receiver-only in this lane and uses immediate attached blocks, not delayed
    closures. A hash-tree is a value tree with a hash at the root, hashes at interior nodes, and scalar or array
    values at leaves. The accepted MVP methods are:
    `hash_value.walk_leaves() { ... }`, `hash_value.map_leaves() { ... }`, and
    `hash_value.reduce_leaves(initial) { ... }`. Traversal is depth-first over sorted stringified hash keys, so
    Perl and Rust do not inherit host hash iteration order. During each block call the runtime binds scoped scalar
    `value` to the leaf value, `key` to the leaf key, `path` to an array value of keys from the root to the leaf,
    and `depth` to `count(path)`. `reduce_leaves` also binds scoped scalar `acc` to the current accumulator and
    replaces it with the block result after each leaf. Array values are leaves and are not recursively traversed.
    Empty hash nodes are valid and produce no callback calls. Non-hash receivers and wrong-shape interior values
    return `undef` / `null` without running callbacks.
    `walk_leaves` returns the original tree value after running callbacks for side effects.
    `map_leaves` returns a new hash tree with the same hash structure and each leaf replaced by the block result.
    `reduce_leaves(initial)` returns the final accumulator; for an empty valid tree it returns `initial`.
    The implementation must preserve caller-state side effects except for scoped restoration of `value`, `key`,
    `path`, `depth`, and `acc`; must compose with duck-typed assignment and nested value paths from `.11`; must
    land on Perl and Rust with active tests, generated oracle fixtures, mdBook examples, and Knowledge Map facts;
    and must describe the surface in LinkedSpec terms, not Ruby or Perl mechanics.
  Verification: `pending`
  Commit: `pending`

- ID: `SPEC-FORMAT-TERSE.12.1`
  Status: `done` (2026-07-08)
  Goal: Reactivate and split hash-tree attached-block traversal before implementation.
  Acceptance: Record the user reactivation, define the exact MVP method surface and semantics, split the
    implementation into signoff-sized Perl/Rust/docs leaves, update the live roadmap/index/resume docs, and commit
    this before parser/runtime code changes.
  Verification: **PASS 2026-07-08.** `.12` is reactivated and split before code. The MVP surface is
    receiver-only `walk_leaves`, `map_leaves`, and `reduce_leaves(initial)` with immediate attached blocks, sorted
    depth-first traversal, scoped `value`/`key`/`path`/`depth` bindings plus `acc` for reduction, array leaves, and
    explicit invalid-shape behavior. Live roadmap/index/resume docs now point at `.12.2` for the Perl reference
    implementation.
  Commit: `SPEC-FORMAT-TERSE.12.1 - activate hash-tree traversal split`; retained completion note: Reactivated `.12` by user directive and split hash-tree attached-block traversal into Perl, Rust/oracle, and docs/KM/no-drift leaves before parser/runtime code.

- ID: `SPEC-FORMAT-TERSE.12.2`
  Status: `done` (2026-07-08)
  Goal: Perl reference implementation for hash-tree attached-block receiver methods.
  Acceptance: Perl ActionIR AST/lowering accepts receiver-form `.walk_leaves() { ... }`, `.map_leaves() { ... }`,
    and `.reduce_leaves(initial) { ... }` on hash-valued receivers; rejects malformed arity or missing blocks with
    explicit unsupported-helper diagnostics; binds/restores scoped `value`, `key`, `path`, `depth`, and `acc`
    according to the `.12` contract; uses sorted depth-first traversal; covers valid, empty, array-leaf,
    non-hash/wrong-shape, continuation, and side-effect cases in focused Perl tests.
  Verification: **PASS 2026-07-08.** Perl AST parsing now accepts receiver trailing-block segments for
    `walk_leaves`, `map_leaves`, and `reduce_leaves`. `ActionIR::MethodLowering` lowers them through immediate
    sorted depth-first traversal closures over hash-root/hash-interior value trees, treats arrays as leaves,
    returns `undef` without callbacks for non-hash receivers, and binds scoped `value`, `key`, `path`, `depth`,
    plus reduction-only `acc` for callback execution. Malformed missing-block or wrong-arity calls emit explicit
    `LINKEDSPEC_UNSUPPORTED_ACTIONIR_HELPER:<method>` diagnostics. Focused tests cover AST parsing, lowering,
    valid/empty/non-hash runtime behavior, array leaves, side effects, continuation through `count_keys`, scoped
    callback restoration, descriptor readiness, and generated-source residue checks. Verification commands:
    `perl -Iperl -c perl/LinkedSpec/ActionIR/AST/Parser.pm`;
    `perl -Iperl -c perl/LinkedSpec/ActionIR/MethodLowering.pm`;
    `prove -q -Iperl t/actionir_ast_parser.t`;
    `PERL5LIB= prove -q -Iperl t/phase0_regression.t` (PASS, 1027 tests);
    `git diff --check`.
  Commit: `SPEC-FORMAT-TERSE.12.2 - implement Perl hash-tree traversal`; retained completion note: Perl reference receiver attached-block traversal landed for `walk_leaves`, `map_leaves`, and `reduce_leaves(initial)` with sorted hash-tree leaf traversal, scoped callback bindings, malformed-call diagnostics, and phase0 `1..1027`; frontier becomes `.12.3` Rust parity.

- ID: `SPEC-FORMAT-TERSE.12.3`
  Status: `done` (2026-07-08)
  Goal: Rust parser/runtime parity and generated oracle fixture for hash-tree traversal methods.
  Acceptance: Rust parses and executes the same receiver attached-block method surface as Perl; runtime results
    match Perl over generated oracle fixtures; focused Rust integration tests cover traversal order, scoped
    bindings/restoration, map/reduce/walk returns, array leaves, empty trees, non-hash/wrong-shape handling, and
    compatible receiver continuations.
  Verification: **PASS 2026-07-08.** Rust expression parsing now accepts receiver trailing blocks for
    `walk_leaves`, `map_leaves`, and `reduce_leaves(initial)`, preserving the explicit initial accumulator plus
    final block argument for reductions. The runtime routes hash-tree receiver calls through the receiver
    trailing-block chain path, diagnoses missing/malformed blocks with
    `LINKEDSPEC_UNSUPPORTED_ACTIONIR_HELPER:<method>`, walks hash-root/hash-interior value trees in sorted
    depth-first order, treats arrays as leaves, binds/restores scoped `value`, `key`, `path`, `depth`, and
    reduction-only `acc`, returns `undef` for non-hash receivers without callbacks, and composes
    `walk_leaves` / `map_leaves` results with later hash-family receiver methods such as `count_keys`. Focused
    Rust tests cover parser shape, traversal order, scoped restoration, map/reduce/walk returns, array leaves,
    empty trees, non-hash handling, continuations, and malformed-call diagnostics. The generated oracle corpus now
    includes `terse_12_3_hash_tree_traversal_receiver_blocks`, manifest `case_count` is 96, the Rust oracle
    passes over all 96 fixtures, and mdBook/helper-contract plus Knowledge Map status was updated in-slice so the
    committed tree has no public-doc drift. Verification commands: `cargo fmt --manifest-path rust/linkedspec-core/Cargo.toml`;
    `cargo fmt --manifest-path rust/linkedspec-runtime/Cargo.toml`;
    `cargo test --manifest-path rust/linkedspec-core/Cargo.toml hash_tree_receiver -- --nocapture`;
    `cargo test --manifest-path rust/linkedspec-runtime/Cargo.toml terse_12_3 -- --nocapture`;
    `perl -Iperl -c tools/gen_oracle_corpus.pl`; direct Perl oracle probe for the new fixture;
    `perl -Iperl tools/gen_oracle_corpus.pl`; and
    `cargo test --manifest-path rust/Cargo.toml -p linkedspec-runtime oracle_corpus_matches_perl_reference -- --nocapture`.
    Final pre-commit gates also pass: `mdbook build docs/linkedspec-book`;
    `bash scripts/check_memory_architecture.sh`; `bash knowledge-map/scripts/check_knowledge_map.sh`;
    `bash scripts/check_doctrines.sh`; `git diff --check`.
  Commit: `SPEC-FORMAT-TERSE.12.3 - implement Rust hash-tree traversal`; retained completion note: Rust parser/runtime parity landed for `walk_leaves`, `map_leaves`, and `reduce_leaves(initial)` receiver attached blocks; generated oracle corpus is 96 fixtures with `terse_12_3_hash_tree_traversal_receiver_blocks`; frontier becomes `.12.4` docs/KM/no-drift closeout.

- ID: `SPEC-FORMAT-TERSE.12.4`
  Status: `done` (2026-07-08)
  Goal: Close hash-tree traversal docs, Knowledge Map, oracle, and no-drift alignment.
  Acceptance: mdBook helper/reference/formal/backend-handoff pages document the shipped `.12` surface with
    examples; generated oracle corpus count and Knowledge Map facts are current; live docs and task-tree frontier
    mark `.12` exhausted; final scans find no current-facing drift in method names, callback bindings, or
    traversal semantics.
  Verification: **PASS 2026-07-08.** mdBook helper/reference/formal/backend-handoff pages document
    `walk_leaves() { ... }`, `map_leaves() { ... }`, and `reduce_leaves(initial) { ... }` with examples and
    terminal/continuation boundaries. Knowledge Map retrieval points at the Perl and Rust hash-tree traversal
    fact cards plus the 96-fixture oracle fact. The manifest records `case_count` 96 and
    `terse_12_3_hash_tree_traversal_receiver_blocks`. Live docs, roadmap, architecture state, and task-tree rows
    mark `.12` exhausted while leaving `.10` and `.13` deferred. No-drift scans covered hash-tree method names,
    callback bindings, traversal semantics, trailing-block boundary wording, historical 95-fixture references, and
    current 96-fixture oracle state; current-facing count drift was not found. Final gates pass: `mdbook build
    docs/linkedspec-book`; `bash scripts/check_memory_architecture.sh`;
    `bash knowledge-map/scripts/check_knowledge_map.sh`; `bash scripts/check_doctrines.sh`; `git diff --check`.
  Commit: `SPEC-FORMAT-TERSE.12.4 - close hash-tree traversal drift`; retained completion note: Final no-drift closeout verified mdBook, Knowledge Map, live docs, task-tree rows, roadmap/architecture state, and the 96-fixture oracle manifest; `.12` is exhausted. `.10` was later closed by `.10.1`; `.13` remains the next parked item under the exhaustion directive.

- ID: `SPEC-FORMAT-TERSE.13`
  Status: `done` / `closed` (reactivated by user directive 2026-07-08; exhausted by `.13.4`; parent metadata
    reconciled by `.13.5`)
  Goal: Track analogous array-tree traversal receiver methods as a lower-priority future feature.
  Children: `.13.1` (done), `.13.2` (done), `.13.3` (done), `.13.4` (done), `.13.5` (done; metadata-only
    parent tree status reconciliation)
  Acceptance: Array-tree traversal is receiver-only in this lane and uses the same immediate attached-block method
    names as hash-tree traversal, but on array-valued receivers: `array_value.walk_leaves() { ... }`,
    `array_value.map_leaves() { ... }`, and `array_value.reduce_leaves(initial) { ... }`. An array-tree is a
    value tree with an array at the root, arrays at interior nodes, and scalar or hash values at leaves. Hash
    values are leaves and are not recursively traversed. Traversal is depth-first in zero-based array index order.
    During each block call the runtime binds scoped scalar `value` to the leaf value, `index` to the zero-based
    leaf index in its parent array, `path` to an array value of zero-based indexes from the root to the leaf, and
    `depth` to `count(path)`. `reduce_leaves` also binds scoped scalar `acc` to the current accumulator and replaces
    it with the block result after each leaf. Empty arrays are valid and produce no callback calls. Non-array
    receivers return `undef` / `null` without running callbacks. `walk_leaves` returns the original array value
    after running callbacks for side effects. `map_leaves` returns a new array tree with the same array structure
    and each leaf replaced by the block result. `reduce_leaves(initial)` returns the final accumulator; for an
    empty valid tree it returns `initial`. `walk_leaves` and `map_leaves` may feed later array-family receiver
    links such as `.count()`, while `reduce_leaves(...)` is terminal. The implementation must preserve caller-state
    side effects except for scoped restoration of `value`, `index`, `path`, `depth`, and `acc`; must land on Perl
    and Rust with active tests, generated oracle fixtures, mdBook examples, and Knowledge Map facts.
  Verification: **PASS 2026-07-08.** `.13.1` split the contract before code, `.13.2` landed the Perl reference,
    `.13.3` landed Rust parser/runtime parity plus the 97th oracle fixture, `.13.4` closed mdBook, Knowledge
    Map, live-doc, task-tree, roadmap, and oracle-count drift, and `.13.5` reconciled the parent task-tree status.
    Array-tree traversal is now a shipped Perl/Rust receiver-block surface with no remaining behavioral `.13`
    leaf.
  Commit: `SPEC-FORMAT-TERSE.13.4 - close array-tree traversal drift`

- ID: `SPEC-FORMAT-TERSE.13.1`
  Status: `done` (2026-07-08)
  Goal: Reactivate and split array-tree attached-block traversal before implementation.
  Acceptance: Record the user reactivation, define the exact MVP method surface and semantics, split the
    implementation into signoff-sized Perl/Rust/docs leaves, update live roadmap/index/resume docs, add a durable
    Knowledge fact for the accepted-but-not-yet-shipped contract, and commit this before parser/runtime code
    changes.
  Verification: **PASS 2026-07-08.** `.13` is reactivated and split before code. The MVP surface is receiver-only
    `walk_leaves`, `map_leaves`, and `reduce_leaves(initial)` on array-valued receivers with immediate attached
    blocks, depth-first index-order traversal, scoped `value`/`index`/`path`/`depth` bindings plus `acc` for
    reduction, hash leaves, and explicit non-array receiver behavior. No parser/runtime behavior changed.
  Commit: `SPEC-FORMAT-TERSE.13.1 - split array-tree traversal`; retained completion note: Reactivated `.13` and split array-tree receiver block traversal into Perl, Rust/oracle, and docs/KM/no-drift leaves before parser/runtime code.

- ID: `SPEC-FORMAT-TERSE.13.2`
  Status: `done` (2026-07-08)
  Goal: Perl reference implementation for array-tree attached-block receiver methods.
  Acceptance: Perl ActionIR AST/lowering accepts receiver-form `.walk_leaves() { ... }`, `.map_leaves() { ... }`,
    and `.reduce_leaves(initial) { ... }` on array-valued receivers; preserves existing hash-tree behavior on
    hash-valued receivers; rejects malformed arity or missing blocks with explicit unsupported-helper diagnostics;
    binds/restores scoped `value`, `index`, `path`, `depth`, and `acc` according to the `.13` contract; uses
    deterministic index-order traversal; covers valid, empty, hash-leaf, non-array, continuation, and side-effect
    cases in focused Perl tests.
  Verification: **PASS 2026-07-08.** Perl lowering now dispatches the shared receiver traversal methods at runtime
    across hash and array receivers. Hash receivers keep `.12` sorted-key traversal with scoped
    `value`/`key`/`path`/`depth` and reduce-only `acc`; array receivers traverse nested arrays depth-first by
    zero-based index, treat hashes as leaves, bind scoped `value`/`index`/`path`/`depth` plus reduce-only `acc`,
    return `undef` without callbacks for non-array/non-hash scalar receivers, preserve ordinary side effects, and
    feed compatible array continuations after `walk_leaves` / `map_leaves`. Focused AST and phase0 locks cover
    parsing, lowering diagnostics, valid/empty/non-array runtime behavior, hash leaves, continuation through
    `count`, scoped restoration, descriptor readiness, and generated-source residue. Full Perl phase0 passes:
    `prove -q -Iperl t/phase0_regression.t` => `Files=1, Tests=1028`, `Result: PASS`.
  Commit: `SPEC-FORMAT-TERSE.13.2 - implement Perl array-tree traversal`; retained completion note: Perl reference lowering/runtime support landed for array-valued `walk_leaves`, `map_leaves`, and `reduce_leaves(initial)` receiver blocks while preserving hash-tree traversal behavior; the then-frontier moved to `.13.3`.

- ID: `SPEC-FORMAT-TERSE.13.3`
  Status: `done` (2026-07-08)
  Goal: Rust parser/runtime parity and generated oracle fixture for array-tree traversal methods.
  Acceptance: Rust executes the same array-tree receiver attached-block method surface as Perl while preserving
    `.12` hash-tree behavior; runtime results match Perl over generated oracle fixtures; focused Rust tests cover
    traversal order, scoped binding restoration, map/reduce/walk returns, hash leaves, empty arrays, non-array
    handling, compatible array-family continuations, and malformed-call diagnostics.
  Verification: **PASS 2026-07-08.** Rust parser support treats `walk_leaves`, `map_leaves`, and
    `reduce_leaves(initial)` receiver trailing blocks as tree traversal fluent calls. Runtime execution now
    dispatches receiver traversal over hash or array values: hash receivers keep the `.12` sorted-key behavior,
    while array receivers recurse through nested arrays by zero-based index, treat hashes as leaves, bind scoped
    `value`/`index`/`path`/`depth` plus reduce-only `acc`, return `undef` without callbacks for scalar receivers,
    and allow `walk_leaves` / `map_leaves` results to feed array-family continuations. Focused checks pass:
    `cargo test --manifest-path rust/linkedspec-core/Cargo.toml tree_traversal_receiver`,
    `cargo test --manifest-path rust/linkedspec-runtime/Cargo.toml terse_13_3`,
    `cargo test --manifest-path rust/linkedspec-runtime/Cargo.toml terse_12_3_hash_tree`,
    `perl -Iperl tools/gen_oracle_corpus.pl` => `Generated 97 oracle fixture(s) plus manifest`, and
    `cargo test --manifest-path rust/Cargo.toml -p linkedspec-runtime oracle_corpus_matches_perl_reference`
    => `1 passed` over the 97-fixture manifest. The new fixture is
    `terse_13_3_array_tree_traversal_receiver_blocks`.
  Commit: `SPEC-FORMAT-TERSE.13.3 - implement Rust array-tree traversal`; retained completion note: Rust parser/runtime parity landed for array-valued `walk_leaves`, `map_leaves`, and `reduce_leaves(initial)` receiver blocks while preserving hash-tree behavior; generated oracle corpus is 97 fixtures and the then-frontier moved to `.13.4` closeout.

- ID: `SPEC-FORMAT-TERSE.13.4`
  Status: `done` (2026-07-08)
  Goal: Close array-tree traversal docs, Knowledge Map, oracle, and no-drift alignment.
  Acceptance: mdBook helper/reference/formal/backend-handoff pages document the shipped `.13` surface with
    examples; generated oracle corpus count and Knowledge Map facts are current; live docs and task-tree frontier
    mark `.13` exhausted; final scans find no current-facing drift in method names, callback bindings, traversal
    semantics, or corpus counts.
  Verification: **PASS 2026-07-08.** Final no-drift scans found no current-facing Rust-pending array-tree wording
    after `.13.3`, no stale 96-fixture current corpus count, and no callback-binding drift. The only current
    wording cleanup was to keep the DSL-facing scalar-receiver result as `undef` while JSON output may encode it
    as null. mdBook helper/reference/formal/backend-handoff/status pages already document the shipped Perl/Rust
    array-tree traversal surface. Knowledge Map facts point at the `.13.2` Perl implementation, `.13.3` Rust
    implementation, and 97-fixture oracle evidence. Final gates pass: `mdbook build docs/linkedspec-book`;
    `bash knowledge-map/scripts/check_knowledge_map.sh`; `bash scripts/check_memory_architecture.sh`;
    `bash scripts/check_doctrines.sh`; `bash scripts/check_task_tree_metadata.sh`; `git diff --check`.
  Commit: `SPEC-FORMAT-TERSE.13.4 - close array-tree traversal drift`; retained completion note: Final no-drift closeout verified mdBook, Knowledge Map, live docs, task-tree rows, roadmap state, and the 97-fixture oracle manifest; `.13` is exhausted.

- ID: `SPEC-FORMAT-TERSE.13.5`
  Status: `done` (2026-07-08)
  Goal: Reconcile the parent `SPEC-FORMAT-TERSE` task-tree status to closed after `.13.4` left no current
    PNT-eligible leaf.
  Acceptance: The central task-tree index, this task file's top metadata, current-frontier table, live docs,
    roadmap state, and Knowledge Map facts agree that `SPEC-FORMAT-TERSE` is closed; stale split-container
    `active` rows inside this task file are converted to historical closed/done wording; no parser/runtime,
    corpus, or mdBook behavioral semantics change.
  Verification: **PASS 2026-07-08.** Metadata-only closeout reconciled the parent `SPEC-FORMAT-TERSE` status and
    stale internal split-container rows to closed/done while preserving future backend deferrals as non-current
    roadmap decisions. Gates pass: `mdbook build docs/linkedspec-book`;
    `bash knowledge-map/scripts/check_knowledge_map.sh`; `bash scripts/check_memory_architecture.sh`;
    `bash scripts/check_doctrines.sh`; `bash scripts/check_task_tree_metadata.sh`; `git diff --check`.
  Commit: `SPEC-FORMAT-TERSE.13.5 - close parent terse task tree`; retained completion note: Metadata-only closeout reconciled the parent task tree and central index from active-with-empty-frontier to done/closed; no behavior changed.

- ID: `SPEC-FORMAT-TERSE.14`
  Status: `done` (closed by `.14.5` on 2026-07-07)
  Goal: Specify and implement code blocks as a trailing block-argument type for helper and receiver-method calls,
    without introducing closures as assignable/returnable values.
  Children: `.14.1`, `.14.2`, `.14.3`, `.14.4`, `.14.5`
  Acceptance: The accepted surface treats a trailing block as a final-only argument to an explicitly block-taking
    helper or receiver method. Blocks are immediate callbacks, not closures: they are not assignable values, not
    returnable values, and not callable later. Inline `fn(args, { ... })`, non-final block arguments, assignable
    block values, returning block values, closures, lambdas, and implicit captured caller-state callbacks remain
    out of scope. The implementation must preserve hash-literal `{ key : value }` parsing from `.9`, keep
    `fn { ... }` deferred unless a later leaf proves it grammar-safe, document the shipped user-facing surface in
    the mdBook, and keep Perl/Rust parity plus oracle coverage.
  Verification: **PASS 2026-07-07.** `.14.1` split the contract before code, `.14.2` shipped Perl helper-function
    form `with(value) { ... }` / `with() { ... }`, `.14.3` shipped Rust helper-function form parity and the 94th
    oracle fixture, `.14.4` shipped receiver-method form `.with() { ... }` and the 95th oracle fixture, and `.14.5`
    closed roadmap/mdBook/Knowledge/live-doc/task-tree/oracle drift without parser/runtime behavior change.
  Commit: `SPEC-FORMAT-TERSE.14.5 - close trailing block drift`
  Supersession note: Director clarification on 2026-07-10 establishes codeblock as the fourth object/value kind
    beside scalar, array, and harray, with `call(args) { block }` equivalent to `call(args, { block })` whenever a
    helper, user function, or receiver method accepts a final codeblock. The `.14` implementation remains accurate
    current-behavior history but its `with`-first, non-parenthesized abstraction is too narrow. Corrective design,
    every-backend parity, and the decision to retain or remove `with` are owned by
    `FUTURE-PARITY-BACKLOG.11.1`; no behavior changed in capture leaf `.11.0`.

