# SPEC-FORMAT-TERSE: Evolve the .spec DSL toward a terser, fully-composable format

## Metadata

- Tree ID: `SPEC-FORMAT-TERSE`
- Status: `done` / `closed` (activated 2026-06-18 by user; ratified in ADR `0007`; closed by `.13.5`)
- Roadmap lane: `Overall roadmap — .spec language evolution (terse format)`
- Created: `2026-06-16`
- Last updated: `2026-11-01`
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
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-FORMAT-TERSE --id SPEC-FORMAT-TERSE`.

- ID: `SPEC-FORMAT-TERSE.0`
  Status: `done`
  Goal: Ratify the adopted direction and record it as an ADR (the brainstorm is tentative)
  Acceptance: A `docs/decisions/000N-spec-format-terse-direction.md` ADR captures which rounds/changes
    are adopted, the migration policy (canonical-new + aliased-old vs hard rename), and the
    backward-compatibility stance for the 20 shipped specs. First leaf on activation.
  Commit: `SPEC-FORMAT-TERSE.0 — activate + ratify the terse .spec format direction (ADR 0007)`; prior node reference: `SPEC-FORMAT-TERSE.0` (see Commit Log); retained completion note: Tree `proposed`→`active`; ADR `0007` + INDEX row; migration policy = gradual alias; reference-touching exception; implementation gated by `RTLUTILS-REGEX-HANG`. No engine/book change.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-FORMAT-TERSE --id SPEC-FORMAT-TERSE.0`.

- ID: `SPEC-FORMAT-TERSE.1`
  Status: `done` (2026-06-29 — Round 1 closed by `.1.6`; variables/types, mutation, helper renames,
    literals/calls/access, and array end-mutation methods now have accepted Perl/Rust locks for the published
    Round 1 leaves.)
  Goal: Round 1 — variables, types, mutation, functions
  Children: `.1.1`, `.1.2`, `.1.3`, `.1.4`, `.1.5`, `.1.6`
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-FORMAT-TERSE --id SPEC-FORMAT-TERSE.1`.

- ID: `SPEC-FORMAT-TERSE.1.1`
  Status: `done` (2026-06-24 — both children done: `.1.1.1` Perl reference + `.1.1.2` Rust lockstep
    parity. Split 2026-06-23 — too broad for one signoff slice: Perl reference engine change +
    lockstep Rust parity are separable.)
  Goal: Auto-existing variables — remove the need for `declare(...)`; a working variable exists on
    first use within a rule scope (declare stays as a deprecated, still-working alias)
  Children: `.1.1.1` (Perl reference), `.1.1.2` (Rust lockstep parity)
  Commit: `SPEC-FORMAT-TERSE.1.1 — split into .1.1.1 (Perl) + .1.1.2 (Rust parity); record auto-existing-variable design + KM card`; table label: `SPEC-FORMAT-TERSE.1.1` (split); retained completion note: `.1.1` → container; first frontier child `.1.1.1`. Design grounded by `dump_parser_source` probes; KM [[working-vars-no-strict-need-my-lexical]]. Docs/tree/KM-only — no engine/book change.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-FORMAT-TERSE --id SPEC-FORMAT-TERSE.1.1`.

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
  Commit: `SPEC-FORMAT-TERSE.1.1.1 — Perl auto-existing working variables (engine + book + 3 phase0 locks)`; prior node reference: `SPEC-FORMAT-TERSE.1.1.1` (see Commit Log); retained completion note: Collector `_collect_auto_working_var_decls` in `RuleIR/EmitContext.pm` (+ `_mask_action_code_literals`) → `auto_var_decls`; preamble injection in `SpecEntry::compile_spec_entry`. 19/20 specs byte-identical (tkgui +1 legit `my`, behavior-preserved); +3 phase0 locks → 968; gate EXIT 0; book taught (declare optional).
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-FORMAT-TERSE --id SPEC-FORMAT-TERSE.1.1.1`.

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
  Commit: `SPEC-FORMAT-TERSE.1.1.2` (see Commit Log)
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-FORMAT-TERSE --id SPEC-FORMAT-TERSE.1.1.2`.

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
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-FORMAT-TERSE --id SPEC-FORMAT-TERSE.1.2`.

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
  Commit: `SPEC-FORMAT-TERSE.1.2.1 — Perl arg-position bare working-variable auto-existence (Channel 1; engine + book + 3 phase0 locks)`; prior node reference: `SPEC-FORMAT-TERSE.1.2.1` (see Commit Log); retained completion note: Extended `_collect_auto_working_var_decls` (`RuleIR/EmitContext.pm`) with a bare arg-position pass: `assign(NAME,…)`→`my $NAME`, `push_value`/`push_nonempty(NAME,…)`→`my @NAME`; wrapped targets stay on the `.1.1.1` wrapped path (the `\s*,` guard); shared `$record` dedup → all 20 specs byte-identical; +3 phase0 subtests → 971 green; gate EXIT 0; ratio 1.0000; book (3 pages) taught wrapper-optional-in-arg-position. Child-append `push(Rule[,target])`/`.push` target + bare hash deferred to Channel 2. KM [[terse-bare-working-vars-engine-gaps]] (Channel 1 closed).
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-FORMAT-TERSE --id SPEC-FORMAT-TERSE.1.2.1`.

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
  Commit: `SPEC-FORMAT-TERSE.1.2.2 — Rust lockstep parity for arg-position bare working-variable auto-existence (engine + oracle + 4 integration locks)`; prior node reference: `SPEC-FORMAT-TERSE.1.2.2` (see Commit Log); retained completion note: Bare `Expr::Variable` target now mapped to the working var in `resolve_scalar_target` + `resolve_array_target` (`allow_bare` gate: push targets true, value-reads false), mirroring Perl's `^\w+$` fallback; per-parse HashMap auto-vivifies. **Required an engine change** (unlike `.1.1.2`). 2 oracle fixtures + 4 `terse_1_2_2_*` tests; cargo 248→252; clippy zero-new; phase0 971 (Perl untouched); gate EXIT 0; no book change. Channel 1 complete on both variants; `.1.2.1` now landed against the universal contract.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-FORMAT-TERSE --id SPEC-FORMAT-TERSE.1.2.2`.

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
  Commit: `SPEC-FORMAT-TERSE.1.2.3 — split Channel 2 value reads by aggregate/scalar surfaces` (see Commit Log); retained completion note: No engine/book behavior change. Channel 2 is now an active container with aggregate bare value reads first (`.1.2.3.1` Perl, `.1.2.3.2` Rust), followed by scalar bare reads (`.1.2.3.3` Perl, `.1.2.3.4` Rust). Frontier becomes `.1.2.3.1`.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-FORMAT-TERSE --id SPEC-FORMAT-TERSE.1.2.3`.

- ID: `SPEC-FORMAT-TERSE.1.2.3.1`
  Status: `done` (2026-06-29)
  Goal: Perl reference — aggregate bare value reads auto-exist safely.
  Acceptance: Bare aggregate reads that already lower to `@NAME`/`%NAME` in Perl value positions
    (`array_copy(NAME)`, `hash_copy(NAME)`, and `copy(NAME)` under the existing array-first `copy` rule)
    emit exactly one preamble `my @NAME`/`my %NAME` per rule when not otherwise declared/wrapped, without
    changing wrapped or explicitly declared specs. Focused phase0 locks prove generated-source preamble
    placement, no duplicate declarations, no cross-parse package-global leak, and unchanged behavior for
    `array_copy(array(NAME))`, `hash_copy(hash(NAME))`, and declared variants.
  Commit: `SPEC-FORMAT-TERSE.1.2.3.1 — auto-exist aggregate bare value reads` (see Commit Log); retained completion note: Perl aggregate bare value reads now auto-declare per-invocation lexicals: `array_copy(NAME)` / `copy(NAME)` -> `my @NAME`; `hash_copy(NAME)` -> `my %NAME`. Wrapped/declared paths dedup unchanged; scalar bare reads and bare key/RHS/direct path atoms remain deferred. Frontier becomes `.1.2.3.2`.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-FORMAT-TERSE --id SPEC-FORMAT-TERSE.1.2.3.1`.

- ID: `SPEC-FORMAT-TERSE.1.2.3.2`
  Status: `done` 2026-06-29
  Goal: Rust lockstep parity for `.1.2.3.1` aggregate bare value reads.
  Acceptance: Rust accepts and evaluates bare aggregate read forms to the same values as the Perl reference
    for `array_copy(NAME)`, `hash_copy(NAME)`, and `copy(NAME)`/`copy(hash(NAME))` under the documented
    array-first `copy` rule, with oracle fixtures and focused integration locks. The change must not make
    scalar bare reads or bare direct-access segments advance ahead of `.1.2.3.3`.
  Commit: `SPEC-FORMAT-TERSE.1.2.3.2 — add Rust aggregate bare-read parity` (see Commit Log); retained completion note: Rust aggregate bare reads now match the Perl reference at the aggregate-copy helper call sites. `array_copy(NAME)` and array-first `copy(NAME)` read arrays, `hash_copy(NAME)` reads hashes, and `copy(hash(NAME))` keeps the explicit hash form. 4 oracle fixtures + 4 integration locks; full runtime suite green; scalar Channel 2 remains next.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-FORMAT-TERSE --id SPEC-FORMAT-TERSE.1.2.3.2`.

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
  Commit: `SPEC-FORMAT-TERSE.1.2.3.3 — split scalar bare reads by lowering seam` (see Commit Log); retained completion note: No engine/book behavior change. Perl scalar bare reads are split into return/assignment source slots (`.1.2.3.3.1`), mutation key/RHS slots (`.1.2.3.3.2`), and direct-access bare path atoms (`.1.2.3.3.3`). Frontier becomes `.1.2.3.3.1`.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-FORMAT-TERSE --id SPEC-FORMAT-TERSE.1.2.3.3`.

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
  Commit: `SPEC-FORMAT-TERSE.1.2.3.3.1 — implement scalar source-slot bare reads` (see Commit Log); retained completion note: Perl source-slot bare reads now work for return and scalar assignment-like sources with matching scalar auto-existence. mdBook/KM/live docs updated; phase0 985 green. Frontier becomes `.1.2.3.3.2`.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-FORMAT-TERSE --id SPEC-FORMAT-TERSE.1.2.3.3.1`.

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
  Commit: `SPEC-FORMAT-TERSE.1.2.3.3.2 — implement scalar mutation-slot bare reads` (see Commit Log); retained completion note: Perl mutation-slot bare reads now work for array append RHS, statement-level `set_key` key/RHS, and hash-index operator key/RHS, with matching scalar auto-existence. mdBook/KM/live docs updated; phase0 986 green. Frontier becomes `.1.2.3.3.3`.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-FORMAT-TERSE --id SPEC-FORMAT-TERSE.1.2.3.3.2`.

- ID: `SPEC-FORMAT-TERSE.1.2.3.3.3`
  Status: `done` (2026-06-29)
  Goal: Perl reference — direct-access bare path atoms.
  Acceptance: Define and implement the direct-access bare path rule after `.1.2.3.3.1`/`.1.2.3.3.2` settle the
    scalar read model. If the accepted rule is scalar-index, direct `foo["a"][z]` lowers like
    `foo["a"][scalar(z)]` (`$foo->{"a"}->[$z]`) and auto-supplies `my $z`; quoted path segments remain hash
    keys, numeric/helper segments remain array indexes, and `scalaref(...)` compatibility is documented or
    explicitly left unchanged. This leaf does not introduce RHS-shape `[]`/`{}` inference.
  Commit: `SPEC-FORMAT-TERSE.1.2.3.3.3 — implement direct-access bare path atoms` (see Commit Log); retained completion note: Perl direct-access bare path atoms now work as scalar array indexes with matching scalar auto-existence. mdBook/KM/live docs updated; phase0 987 green. `.1.2.3.3` closes; frontier becomes `.1.2.3.4`.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-FORMAT-TERSE --id SPEC-FORMAT-TERSE.1.2.3.3.3`.

- ID: `SPEC-FORMAT-TERSE.1.2.3.4`
  Status: `done` (2026-06-29)
  Goal: Rust lockstep parity for the accepted `.1.2.3.3` scalar bare value-read contract.
  Acceptance: Rust parser/runtime behavior matches the accepted Perl scalar bare-read contract after the
    `.1.2.3.3.x` children land, without getting ahead on later RHS-shape or block-expression surfaces. Split by
    the same seams if one parity slice is too broad.
  Commit: `SPEC-FORMAT-TERSE.1.2.3.4 — add Rust scalar bare-read parity` (see Commit Log); retained completion note: Rust now accepts the Perl scalar bare-read contract in source slots, mutation key/RHS slots, and direct-access bare path atoms through the existing `Expr::Variable` scalar read path. 3 oracle fixtures added; frontier becomes `.1.2.3.5` RHS-shape/type-inference split.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-FORMAT-TERSE --id SPEC-FORMAT-TERSE.1.2.3.4`.

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
  Commit: `SPEC-FORMAT-TERSE.1.2.3.5 — split RHS-shape inference by mechanism` (see Commit Log); retained completion note: No engine/book behavior change. RHS-shape/type inference is split into Perl shape-literal value expressions (`.1.2.3.5.1`), Perl RHS target-kind inference (`.1.2.3.5.2`), and Rust parity for each (`.1.2.3.5.3`/`.1.2.3.5.4`). Frontier becomes `.1.2.3.5.1`.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-FORMAT-TERSE --id SPEC-FORMAT-TERSE.1.2.3.5`.

- ID: `SPEC-FORMAT-TERSE.1.2.3.5.1`
  Status: `done` (2026-06-29)
  Goal: Perl reference — define and lower `[]` / `{}` as DSL shape-literal value expressions.
  Acceptance: Empty and non-empty array/hash literals accepted in value positions lower through expression-aware
    element/key/value handling, so settled scalar reads compose inside shapes (`[value]`, `{ key => value }`)
    without raw Perl bareword/string passthrough. Direct-access bracket paths, hash-index assignment brackets,
    future control-flow/block braces, helper-call parsing, primitive literals, and all-bare child-call routing
    remain protected. Add focused Perl runtime/source locks and update the mdBook only if user-visible behavior
    changes.
  Commit: `SPEC-FORMAT-TERSE.1.2.3.5.1 — implement Perl shape-literal values` (see Commit Log); retained completion note: Perl now lowers accepted `[]` / `{}` shape literals as DSL value expressions, with scalar bare reads inside direct elements, keys, and values plus auto-`my` declarations. Fixed hash fields require quoted keys. Target-kind inference stays deferred to `.1.2.3.5.2`; Rust parity stays `.1.2.3.5.3`.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-FORMAT-TERSE --id SPEC-FORMAT-TERSE.1.2.3.5.1`.

- ID: `SPEC-FORMAT-TERSE.1.2.3.5.2`
  Status: `done` (2026-06-29)
  Goal: Perl reference — decide and implement RHS-shape target-kind inference.
  Acceptance: After `.1.2.3.5.1` defines shape literals as values, decide whether scalar assignment forms such
    as `name = []` / `name = {}` initialize aggregate working variables (`@name` / `%name`) or intentionally
    remain scalar arrayref/hashref assignment. The accepted rule must be explicit, backwards-compatible or
    consciously migrated, covered by source/runtime locks, and documented in the mdBook if it changes the
    user-facing contract.
  Commit: `SPEC-FORMAT-TERSE.1.2.3.5.2 — infer Perl RHS shape target kind` (see Commit Log); retained completion note: Perl now uses direct RHS shape literals to infer aggregate bare assignment targets: arrays for `[]` / `[value]`, hashes for `{}` / `{ key => value }`; explicit `scalar(...)` keeps scalar-held payload assignment. Declaration initializer direct shapes unwrap lowered members. Frontier becomes `.1.2.3.5.3`.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-FORMAT-TERSE --id SPEC-FORMAT-TERSE.1.2.3.5.2`.

- ID: `SPEC-FORMAT-TERSE.1.2.3.5.3`
  Status: `done` (2026-06-29)
  Goal: Rust lockstep parity for `.1.2.3.5.1` shape-literal value expressions.
  Acceptance: Rust parses and evaluates the accepted Perl shape-literal value-expression contract with oracle
    fixtures and focused integration locks, without advancing RHS target-kind inference ahead of `.1.2.3.5.2`.
  Commit: `SPEC-FORMAT-TERSE.1.2.3.5.3 — implement Rust shape-literal values` (see Commit Log); retained completion note: Rust parses/evaluates direct shape literals as value expressions with parser/runtime/oracle locks, while leaving Rust RHS target-kind inference to `.1.2.3.5.4`.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-FORMAT-TERSE --id SPEC-FORMAT-TERSE.1.2.3.5.3`.

- ID: `SPEC-FORMAT-TERSE.1.2.3.5.4`
  Status: `done` (2026-06-29)
  Goal: Rust lockstep parity for `.1.2.3.5.2` RHS-shape target-kind inference.
  Acceptance: Rust matches the accepted Perl target-kind inference contract with oracle fixtures and focused
    integration locks. If `.1.2.3.5.2` intentionally preserves scalar arrayref/hashref assignment, Rust must
    lock that behavior rather than inventing aggregate initialization.
  Commit: `SPEC-FORMAT-TERSE.1.2.3.5.4 — implement Rust RHS shape target kind` (see Commit Log); retained completion note: Rust now uses direct RHS shape literals to infer aggregate bare or matching typed aggregate assignment targets, while explicit `scalar(...)` keeps scalar-held payload assignment. Added integration/oracle locks; frontier becomes `.1.6`.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-FORMAT-TERSE --id SPEC-FORMAT-TERSE.1.2.3.5.4`.

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
  Commit: `SPEC-FORMAT-TERSE.1.3 — split mutation surface by mechanism; record push/operator ground truth`; prior node reference: `SPEC-FORMAT-TERSE.1.3` (see Commit Log); table label: `SPEC-FORMAT-TERSE.1.3` (split); retained completion note: `.1.3` → container after TOOLBOX-first probes: scalar `set(name,val)` already done; array explicit-value append spelling must resolve `push(name,value)` vs existing child-call `push(rule,target)`; hash `set_key(name,k,v)` needs a mutation statement contract distinct from pure `set_key(hash_expr,...)`; operators require new statement syntax on Perl + Rust. `.1.3.1` audit done; `.1.3.2` is next. KM [[terse-mutation-surface-ground-truth]]. DOCS/TREE/KM only — no engine/book change.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-FORMAT-TERSE --id SPEC-FORMAT-TERSE.1.3`.

- ID: `SPEC-FORMAT-TERSE.1.3.1`
  Status: `done` (2026-06-29, audit-only)
  Goal: Scalar function form — `set(name, value)` is the terse scalar mutation spelling and must match
    `assign(name, value)` on both variants.
  Acceptance: Perl `call_spec_handler_subst` lowers `set(name, val)` and `assign(name, val)` byte-identically;
    a runtime spec with bare `set(name, val)` returns the assigned value and does not leak between parses; Rust
    has an equivalent `set` alias and lock. No new code if already satisfied.
  Commit: `SPEC-FORMAT-TERSE.1.3` (audit recorded in the split commit)
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-FORMAT-TERSE --id SPEC-FORMAT-TERSE.1.3.1`.

- ID: `SPEC-FORMAT-TERSE.1.3.2`
  Status: `done` (2026-06-29)
  Goal: Array function spelling — decide and implement the explicit-value append spelling requested as
    `push(name, value)` without regressing the existing child-call `push(rule[, target[, index]])` convention.
  Acceptance: Existing child-call forms (`push(Child)`, `push(Child, target)`, indexed variants, and fluent
    `.push(...)`) remain byte-identical and documented; the selected explicit-value spelling lowers/runs
    identically to `push_value(name, value)` on Perl and Rust; ambiguity between two bare identifiers is
    resolved by a documented rule before any engine change; focused phase0/Rust locks prove both the new
    spelling and the legacy child-call convention.
  Commit: `SPEC-FORMAT-TERSE.1.3.2 — recognize push(target,value) explicit append while preserving child-call push`; prior node reference: `SPEC-FORMAT-TERSE.1.3.2` (see Commit Log); retained completion note: Perl `ActionIR` now treats `push(target,value)` as a `push_value` alias only for unambiguous/non-all-bare value expressions; all-bare `push(A,B)` remains child-call. Added Perl phase0 locks, Rust oracle fixture + integration lock, and book/KM/live-doc updates.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-FORMAT-TERSE --id SPEC-FORMAT-TERSE.1.3.2`.

- ID: `SPEC-FORMAT-TERSE.1.3.3`
  Status: `done` (2026-06-29)
  Goal: Hash function mutation spelling — define and implement `set_key(name, key, value)` as the mutation
    counterpart to `name[key] = value`, while preserving today's pure hash-valued `set_key(hash_expr, key,
    value)` helper.
  Acceptance: The mutation form has an explicit statement-level lowering on Perl and an equivalent Rust
    runtime behavior; pure value `set_key(hash(...), key, value)` remains unchanged; bare hash auto-existence
    and Channel 2 value-position semantics are either implemented here with locks or explicitly split further
    with a dependency on `.1.2.3`/`.1.5`.
  Commit: `SPEC-FORMAT-TERSE.1.3.3 — implement set_key(name,key,value) hash mutation statement`; prior node reference: `SPEC-FORMAT-TERSE.1.3.3` (see Commit Log); retained completion note: Perl `ActionIR` now treats top-level `set_key(name,key,value)` as an ASSIGN mutation statement and auto-declares bare hash targets. Rust executes top-level `set_key(...)` statements by mutating the named hash while keeping nested value-form `set_key(hash_expr,...)` pure. Added phase0 locks, Rust integration locks, oracle fixture, and book/KM/live-doc updates.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-FORMAT-TERSE --id SPEC-FORMAT-TERSE.1.3.3`.

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
  Commit: `SPEC-FORMAT-TERSE.1.3.4 — split operator syntax family into scalar, array, and hash leaves`; prior node reference: `SPEC-FORMAT-TERSE.1.3.4` (see Commit Log); retained completion note: Docs/tree/KM/live-doc split slice only. Operator forms are currently RAW_PERL blockers on Perl and unsupported by Rust's expression-statement-only lifecycle AST. Frontier becomes `.1.3.4.1` scalar assignment operator.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-FORMAT-TERSE --id SPEC-FORMAT-TERSE.1.3.4`.

- ID: `SPEC-FORMAT-TERSE.1.3.4.1`
  Status: `done` (2026-06-29)
  Goal: Scalar assignment operator — `name = value` lowers/runs identically to `set(name, value)` /
    `assign(name, value)`.
  Acceptance: Perl recognizes top-level scalar assignment statements without leaving RAW_PERL fallback and
    emits the same scalar assignment as the settled `set(...)` form; Rust parses and executes the same scalar
    assignment statement without broadening value-position bare-word reads; both variants have focused locks
    proving equivalence to `set(name,value)` plus no regression to keyword args (`helper(name=value)`) or
    equality-like future operator syntax.
  Commit: `SPEC-FORMAT-TERSE.1.3.4.1 — implement scalar assignment operator name = value`; prior node reference: `SPEC-FORMAT-TERSE.1.3.4.1` (see Commit Log); retained completion note: Perl and Rust now support statement-level scalar `name = value` as equivalent to `set(name,value)` / `assign(name,value)`, with focused locks proving the narrow boundary and no Channel 2 broadening. Frontier becomes `.1.3.4.2` array append operator.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-FORMAT-TERSE --id SPEC-FORMAT-TERSE.1.3.4.1`.

- ID: `SPEC-FORMAT-TERSE.1.3.4.2`
  Status: `done` (2026-06-29)
  Goal: Array append operator — `items += value` lowers/runs identically to the settled explicit append form.
  Acceptance: Perl and Rust append one value to the named working array; the value expression follows the
    conservative `.1.3.2` disambiguation contract (bare working-variable values remain deferred to Channel 2
    unless explicitly wrapped); existing child-call `push(...)` semantics stay unchanged.
  Commit: `SPEC-FORMAT-TERSE.1.3.4.2 — implement array append operator items += value`; prior node reference: `SPEC-FORMAT-TERSE.1.3.4.2` (see Commit Log); retained completion note: Perl and Rust now support statement-level array `items += value` as equivalent to explicit append forms for explicit RHS expressions, with locks proving bare RHS remains deferred to Channel 2. Frontier becomes `.1.3.4.3` hash-index assignment operator.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-FORMAT-TERSE --id SPEC-FORMAT-TERSE.1.3.4.2`.

- ID: `SPEC-FORMAT-TERSE.1.3.4.3`
  Status: `done` (2026-06-29)
  Goal: Hash-index assignment operator — `name[key] = value` lowers/runs identically to
    `set_key(name, key, value)`.
  Acceptance: Perl and Rust mutate the named working hash at the supplied key expression; nested/indexed value
    reads remain scoped to the already-supported key-expression helpers and do not claim the broader Channel 2
    bare value-position read model.
  Commit: `SPEC-FORMAT-TERSE.1.3.4.3 — implement hash-index assignment operator name[key] = value`; prior node reference: `SPEC-FORMAT-TERSE.1.3.4.3` (see Commit Log); retained completion note: Perl and Rust now support statement-level hash-index `name[key] = value` as equivalent to `set_key(name,key,value)` for explicit key/value expressions, with locks proving bare key/RHS remain deferred to Channel 2. `.1.3.4` and `.1.3` close; frontier becomes `.1.5`.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-FORMAT-TERSE --id SPEC-FORMAT-TERSE.1.3.4.3`.

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
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-FORMAT-TERSE --id SPEC-FORMAT-TERSE.1.4`.

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
  Commit: `SPEC-FORMAT-TERSE.1.4.1 — Perl recognize terse renames set/cat/copy lowering identically to assign/concat/array_copy+hash_copy (engine + book + 4 phase0 locks)`; prior node reference: `SPEC-FORMAT-TERSE.1.4.1` (see Commit Log); retained completion note: Recognized the aliases at every site each canonical name is (normalize seam for `cat`/`set`; 3 raw-text `set` scanners; dedicated array-then-hash `copy` dispatch; declare-init / return-payload / FlowExpr-source / type-inference recognizers). 4 headline + 11 composed forms byte-equal to canonical; `set`==`assign` ASSIGN node; terse spec runs == canonical twin end-to-end; **all 20 specs byte-identical**; +4 phase0 locks → **975 green**; gate EXIT 0; ratio 1.0000; book taught (3 pages, renames canonical + old names deprecated-not-retired). `.1.4.1` landed on the Perl reference; `.1.4.2` (Rust parity) is next.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-FORMAT-TERSE --id SPEC-FORMAT-TERSE.1.4.1`.

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
  Commit: `SPEC-FORMAT-TERSE.1.4.2` (see Commit Log)
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-FORMAT-TERSE --id SPEC-FORMAT-TERSE.1.4.2`.

- ID: `SPEC-FORMAT-TERSE.1.5`
  Status: `done` / `closed` (2026-06-29 — split by literal/call/separator/access surface; children complete)
  Goal: Literals, nested access, call + semicolon rules
  Children: `.1.5.1`, `.1.5.2`, `.1.5.3`, `.1.5.4`, `.1.5.5`
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-FORMAT-TERSE --id SPEC-FORMAT-TERSE.1.5`.

- ID: `SPEC-FORMAT-TERSE.1.5.1`
  Status: `done` (2026-06-29 — ground truth + split)
  Goal: Establish exact current behavior for literals, nested access, call spacing, and semicolon/newline
    separators, then split `.1.5` before implementation.
  Acceptance: KM retrieval, TOOLBOX probes, and Perl/Rust code-read identify which parts are already true,
    which parts need parity locks, and which parts require new semantics; `.1.5` becomes an active container
    with executable child leaves; no implementation code changes in this audit slice.
  Commit: `SPEC-FORMAT-TERSE.1.5 — split literals/access/call/separator surface`
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-FORMAT-TERSE --id SPEC-FORMAT-TERSE.1.5.1`.

- ID: `SPEC-FORMAT-TERSE.1.5.2`
  Status: `done` (2026-06-29)
  Goal: Primitive literal parity and locks.
  Acceptance: `"..."`, `'...'`, integer, float, `true`, `false`, and `undef` are accepted as typed value
    literals in return payloads and representative mutation/value-expression RHS positions on Perl and Rust;
    Perl/Rust agree on observable JSON values; `true`/`false` are booleans, not Perl bareword strings; prefix
    identifiers such as `trueword`/`undefine` remain out of the literal path.
  Commit: `SPEC-FORMAT-TERSE.1.5.2 — implement primitive literal parity` (see Commit Log); retained completion note: Primitive literals are typed values on Perl/Rust; Perl booleans now lower through `JSON::PP`, exact matching preserves identifier prefixes, `push(items,false)` is a value append, and Rust statement-form `if(false)` gates inactive branches. Frontier becomes `.1.5.3`.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-FORMAT-TERSE --id SPEC-FORMAT-TERSE.1.5.2`.

- ID: `SPEC-FORMAT-TERSE.1.5.3`
  Status: `done` (2026-06-29)
  Goal: Function-call spacing and mandatory-call-parentheses locks.
  Acceptance: Calls still require `()`; optional whitespace before `(` is accepted at every already-supported
    statement and value-expression site (`return (val)`, `set (name,val)`, `cat ("a","b")`,
    `scalar (name)`, operator RHS/key expressions), without accepting bare no-paren helper keywords.
  Commit: `SPEC-FORMAT-TERSE.1.5.3 — lock call spacing and mandatory parentheses` (see Commit Log); retained completion note: Optional whitespace before `(` is locked at supported helper/value sites on Perl and Rust, while no-parenthesis helper spellings remain outside call recognition. Frontier becomes `.1.5.4`.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-FORMAT-TERSE --id SPEC-FORMAT-TERSE.1.5.3`.

- ID: `SPEC-FORMAT-TERSE.1.5.4`
  Status: `done` (2026-06-29)
  Goal: Statement separator contract.
  Acceptance: Newlines separate top-level canonical DSL statements; semicolons remain accepted and are
    required only when multiple statements share one physical line. Perl lowering emits valid generated Perl
    for newline-separated statements; same-line adjacent statements without `;` are rejected or left as
    explicit blockers consistently with Rust; semicolons inside nested expressions/literals stay protected.
  Commit: `SPEC-FORMAT-TERSE.1.5.4 — lock statement separators` (see Commit Log); retained completion note: Newline-or-semicolon statement separation is locked on Perl and Rust. Same-line multiple statements require `;`; nested semicolons stay protected; fluent attached-control tails keep working through Bootstrap newline normalization. Frontier becomes `.1.5.5`.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-FORMAT-TERSE --id SPEC-FORMAT-TERSE.1.5.4`.

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
  Commit: `SPEC-FORMAT-TERSE.1.5.5 — split direct access by Channel 2 boundary` (see Commit Log); retained completion note: `.1.5.5` is now a container. `.1.5.5.1` owns direct nested access with explicit path segments; `.1.5.5.2` owns the bare path-segment / Channel 2 value-position-read coordination. Frontier becomes `.1.5.5.1`.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-FORMAT-TERSE --id SPEC-FORMAT-TERSE.1.5.5`.

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
  Commit: `SPEC-FORMAT-TERSE.1.5.5.1 — implement direct nested access explicit segments` (see Commit Log); retained completion note: Perl and Rust now accept explicit mixed direct access such as `foo["a"][9]["b"][scalar(z)]`; `scalaref(...)` remains accepted; bare path atoms stay deferred to `.1.5.5.2` / Channel 2. Frontier becomes `.1.5.5.2`.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-FORMAT-TERSE --id SPEC-FORMAT-TERSE.1.5.5.1`.

- ID: `SPEC-FORMAT-TERSE.1.5.5.2`
  Status: `superseded` (2026-06-29 — merged into `SPEC-FORMAT-TERSE.1.2.3`)
  Goal: Bare path-segment / Channel 2 coordination for direct access.
  Acceptance: The full brainstorm spelling `foo["a"][9]["b"][z]` is implemented only after the project has a
    coherent value-position bare-word read model, or this leaf is merged into the future `.1.2.3` Channel 2
    work with explicit task-tree evidence. This leaf must define how bare path atoms choose scalar/array/hash
    reads and key-vs-index semantics without breaking existing child-call and helper-call boundaries.
  Commit: `SPEC-FORMAT-TERSE.1.5.5.2 — merge bare direct access into Channel 2` (see Commit Log); retained completion note: No engine/book behavior change. `.1.5.5.2` is superseded into new `.1.2.3` because bare direct-access path atoms share the global value-position bare-word-read model. Frontier becomes `.1.2.3`.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-FORMAT-TERSE --id SPEC-FORMAT-TERSE.1.5.5.2`.

- ID: `SPEC-FORMAT-TERSE.1.6`
  Status: `done` (2026-06-29)
  Goal: Array mutation methods — `.push_front(v)`, `.push_back(v)`, `.pop_front()`, `.pop_back()`
  Acceptance: The four array end-mutation methods are recognized and lower to ActionIR.
  Commit: `SPEC-FORMAT-TERSE.1.6 — implement array end-mutation methods` (see Commit Log); retained completion note: Perl and Rust now support statement-level `items.push_back(value)`, `items.push_front(value)`, `items.pop_back()`, and `items.pop_front()` over named working arrays. Added phase0/Rust/oracle/book/KM locks; Round 1 closes and frontier becomes `.2.1`.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-FORMAT-TERSE --id SPEC-FORMAT-TERSE.1.6`.

- ID: `SPEC-FORMAT-TERSE.2`
  Status: `done` / `closed` (Round 2 expression-valued block, control-flow, and composability leaves complete)
  Goal: Round 2 — control flow (everything is an expression)
  Children: `.2.1`, `.2.2`, `.2.3`
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-FORMAT-TERSE --id SPEC-FORMAT-TERSE.2`.

- ID: `SPEC-FORMAT-TERSE.2.1`
  Status: `done` (2026-06-30 — all split children `.2.1.1` through `.2.1.4` landed)
  Goal: Expression-valued blocks — `{ ... }` returns its value (last statement or explicit `return()`)
  Acceptance: A block evaluates to its last statement's value or an explicit `return(...)`; blocks
    compose as expressions.
  Children: `.2.1.1`, `.2.1.2`, `.2.1.3`, `.2.1.4`
  Commit: `.2.1` container closed by `SPEC-FORMAT-TERSE.2.1.4`
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-FORMAT-TERSE --id SPEC-FORMAT-TERSE.2.1`.

- ID: `SPEC-FORMAT-TERSE.2.1.1`
  Status: `done` (2026-06-29)
  Goal: Expression-valued block ground truth and split before code
  Acceptance: KM retrieval, TOOLBOX lowering/runtime probes, and code-read identify the current Perl/Rust
    behavior, ambiguity with `{}` / `{ key => value }` shape literals, and safe implementation split.
  Commit: `SPEC-FORMAT-TERSE.2.1.1 — split expression-valued blocks`; prior node reference (incorrect; corrected by containment .6): `SPEC-FORMAT-TERSE.3.2.3.2 - implement string comparison helpers`; retained completion note: No engine/book behavior change. `.2.1` is split into Perl-reference core block values (`.2.1.2`), Rust parity (`.2.1.3`), and explicit block-local early-return follow-through (`.2.1.4`). Frontier becomes `.2.1.2`.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-FORMAT-TERSE --id SPEC-FORMAT-TERSE.2.1.1`.

- ID: `SPEC-FORMAT-TERSE.2.1.2`
  Status: `done` (2026-06-29)
  Goal: Perl reference — core expression-valued block values
  Acceptance: Non-empty `{ ... }` value payloads without top-level `=>` lower as block expressions in
    value-consuming slots, preserving `{}` and `{ key => value }` as hash literals. The first Perl slice
    supports last-expression value and final `return(expr)` block value forms; full block-local early return
    remains a follow-up if needed.
  Commit: `SPEC-FORMAT-TERSE.2.1.2 — implement Perl expression-valued blocks`; retained completion note: Perl reference now accepts the core block-value subset in value-consuming sites, preserving hash-literal precedence. Rust parity remains `.2.1.3`; full block-local early return remains `.2.1.4`.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-FORMAT-TERSE --id SPEC-FORMAT-TERSE.2.1.2`.

- ID: `SPEC-FORMAT-TERSE.2.1.3`
  Status: `done` (2026-06-29)
  Goal: Rust parity — core expression-valued block values
  Acceptance: Rust parser/runtime add the same block-expression AST/runtime behavior and preserve hash-literal
    disambiguation; oracle fixtures match the Perl reference. Implementation seam is `Expr`/brace parsing in
    `rust/linkedspec-core/src/expr.rs` plus value-returning block evaluation in
    `rust/linkedspec-runtime/src/engine.rs`. Preserve `{}` and keyed top-level `=>` hash literals; only
    non-empty non-fat-arrow brace payloads become block values. Match the Perl core for final expression and
    final `return(expr)` payloads; true mid-block early return remains `.2.1.4`.
  Commit: `SPEC-FORMAT-TERSE.2.1.3 — own Rust expression-valued blocks`; implementation commit pending.; retained completion note: No engine/book behavior change. Rust parser/runtime seams are recorded before code; frontier remains `.2.1.3` implementation.; table reference: `SPEC-FORMAT-TERSE.2.1.3 — implement Rust expression-valued blocks`; retained completion note: Rust parser/runtime parity for the core block-value subset landed with oracle fixture; frontier becomes `.2.1.4`.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-FORMAT-TERSE --id SPEC-FORMAT-TERSE.2.1.3`.

- ID: `SPEC-FORMAT-TERSE.2.1.4`
  Status: `done` (2026-06-30)
  Goal: Block-local explicit return semantics and composition follow-through
  Acceptance: True block-local early-return semantics are implemented without leaking into the surrounding
    rule return channel; nested composition is locked and the book is updated.
  Commit: `SPEC-FORMAT-TERSE.2.1.4 — implement block-local return`; retained completion note: Expression-valued blocks now support block-local early `return(expr)` on Perl and Rust without leaking into the surrounding rule return channel. Added Perl/Rust/oracle/book/KM locks; `.2.1` closes and frontier becomes `.2.2`.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-FORMAT-TERSE --id SPEC-FORMAT-TERSE.2.1.4`.

- ID: `SPEC-FORMAT-TERSE.2.2`
  Status: `done` / `closed` (split 2026-06-30 by `.2.2.1`; children complete)
  Goal: Control-flow keywords — `if/elseif/else`, `when`, `otherwise`, `default`, `while`, `switch`
  Acceptance: `if (cond) { ... } elseif (cond) { ... } else { ... }` — parens for conditions, blocks
    for bodies, blocks NEVER inside parens; `when (cond) { ... }` inline conditional; `otherwise { ... }`
    and `default { ... }` take no parens/args; `while (cond) { ... }`; `switch (expr) { case(v) { ... }
    default { ... } }`.
  Children: `.2.2.1`, `.2.2.2`, `.2.2.3`, `.2.2.4`, `.2.2.5`, `.2.2.5.1`,
    `.2.2.5.2`, `.2.2.6`, `.2.2.6.1`, `.2.2.6.2`
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
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-FORMAT-TERSE --id SPEC-FORMAT-TERSE.2.2`.

- ID: `SPEC-FORMAT-TERSE.2.2.1`
  Status: `done` (2026-06-30)
  Goal: Control-flow keyword ground truth and split before code
  Acceptance: KM retrieval, TOOLBOX lowering/runtime/metadata probes, and Perl/Rust code-read identify the
    current portable control-flow contract and split the broad `.2.2` surface into signoff-sized leaves.
  Commit: `SPEC-FORMAT-TERSE.2.2.1 - split control-flow keyword surface`; table reference: `SPEC-FORMAT-TERSE.2.2.1 — split control-flow keyword surface`; retained completion note: No engine behavior change. `.2.2` is split by current support seams: Perl attached-if first, Rust attached-if parity next, then `when`/`otherwise`, attached switch/default, and while. Frontier becomes `.2.2.2`.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-FORMAT-TERSE --id SPEC-FORMAT-TERSE.2.2.1`.

- ID: `SPEC-FORMAT-TERSE.2.2.2`
  Status: `done` (2026-06-30)
  Goal: Perl reference — attached-block `if/elseif/else` without explicit `endif`
  Acceptance: `if(cond) { ... } elseif(cond2) { ... } else { ... }` lowers through ActionIR without raw Perl
    fallback, executes only the selected branch, and preserves the existing statement-marker
    `if(cond); ... else(); ... endif()` and inline-composite `if(...)` contracts.
  Commit: `SPEC-FORMAT-TERSE.2.2.2 - implement Perl attached if blocks`; table reference: `SPEC-FORMAT-TERSE.2.2.2 — own Perl attached if blocks`; exact Git subject: `SPEC-FORMAT-TERSE.2.2.2 - own Perl attached if blocks`; retained completion note: No engine behavior change. Perl attached-block if ownership narrowed the implementation to the same-line branch-continuation splitter: newline-separated `if { ... }` / `elseif { ... }` / `else { ... }` clauses are already ActionIR-ready, while compact `} elseif/else {` chains remain raw. Frontier remains `.2.2.2` implementation.; table reference: `SPEC-FORMAT-TERSE.2.2.2 — implement Perl attached if blocks`; retained completion note: Perl compact attached-block `if/elseif/else` now splits, lowers, and runs without raw fallback. Marker-form and inline-composite `if` behavior is unchanged. Frontier becomes `.2.2.3` for Rust parity.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-FORMAT-TERSE --id SPEC-FORMAT-TERSE.2.2.2`.

- ID: `SPEC-FORMAT-TERSE.2.2.3`
  Status: `done` (2026-06-30)
  Goal: Rust parity — attached-block `if/elseif/else`
  Acceptance: Rust parses and executes the accepted `.2.2.2` attached-block if contract with the same branch
    gating and oracle parity, while keeping inline-composite and marker-form `if` behavior unchanged.
  Commit: `SPEC-FORMAT-TERSE.2.2.3 - own Rust attached if blocks`;; table reference: `SPEC-FORMAT-TERSE.2.2.3 — own Rust attached if blocks`; retained completion note: No engine behavior change. Rust parity is owned before code: parse attached `if`/`elseif`/`else` branch bodies into the existing statement-control model, reusing `handle_statement_if_control` rather than adding a second branch runtime. Frontier remains `.2.2.3` implementation.; table reference: `SPEC-FORMAT-TERSE.2.2.3 — implement Rust attached if blocks`; exact Git subject: `SPEC-FORMAT-TERSE.2.2.3 - implement Rust attached if blocks`; retained completion note: Rust `CodeBlock::parse` now normalizes attached `if/elseif/else` branch bodies to the existing marker-control sequence; runtime branch gating is reused unchanged. Added parser/runtime/oracle locks; attached `if` is now portable on Perl and Rust. Frontier becomes `.2.2.4`.
    `SPEC-FORMAT-TERSE.2.2.3 - implement Rust attached if blocks`
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-FORMAT-TERSE --id SPEC-FORMAT-TERSE.2.2.3`.

- ID: `SPEC-FORMAT-TERSE.2.2.4`
  Status: `done` (2026-06-30)
  Goal: `when/otherwise` conditional aliases
  Acceptance: `when(cond) { ... } otherwise { ... }` is implemented as the readable one-condition alias family
    for attached-block if/else on Perl and Rust, without relying on Perl's host-language `when` feature.
  Commit: `SPEC-FORMAT-TERSE.2.2.4 - own when otherwise aliases`;; table reference: `SPEC-FORMAT-TERSE.2.2.4 — own when otherwise aliases`; retained completion note: No engine behavior change. `when/otherwise` is owned as an alias-normalization leaf over attached `if/else`, not host Perl `when`; implementation should reuse existing control-flow lowerers and Rust marker runtime. Frontier remains `.2.2.4` implementation.; table reference: `SPEC-FORMAT-TERSE.2.2.4 — implement when otherwise aliases`; exact Git subject: `SPEC-FORMAT-TERSE.2.2.4 - implement when otherwise aliases`; retained completion note: Perl and Rust now normalize attached `when(cond) { ... } otherwise { ... }` to the existing attached `if/else` control-flow contract. Oracle corpus 37 fixtures. Frontier becomes `.2.2.5`.
    `SPEC-FORMAT-TERSE.2.2.4 - implement when otherwise aliases`
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-FORMAT-TERSE --id SPEC-FORMAT-TERSE.2.2.4`.

- ID: `SPEC-FORMAT-TERSE.2.2.5`
  Status: `done` (2026-06-30)
  Goal: Attached-block `switch/case/default` parity and separator lock
  Acceptance: `switch(expr) { case(v) { ... } default { ... } }` has portable Perl/Rust behavior, clear
    statement-separator rules between branch blocks, first-match/default semantics, and no raw fallback.
  Children: `.2.2.5.1`, `.2.2.5.2`
  Commit: `SPEC-FORMAT-TERSE.2.2.5 - split attached switch surface`;; table reference: `SPEC-FORMAT-TERSE.2.2.5 — split attached switch surface`; retained completion note: No engine behavior change. Attached `switch/case/default` is split before code into `.2.2.5.1` Perl separator/source lock and `.2.2.5.2` Rust parity. Frontier becomes `.2.2.5.1`.
    `SPEC-FORMAT-TERSE.2.2.5.1 - implement Perl attached switch separator lock`;
    `SPEC-FORMAT-TERSE.2.2.5.2 - implement Rust attached switch blocks`
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-FORMAT-TERSE --id SPEC-FORMAT-TERSE.2.2.5`.

- ID: `SPEC-FORMAT-TERSE.2.2.5.1`
  Status: `done` (2026-06-30)
  Goal: Perl reference — attached-block `switch/case/default` separator/source lock
  Acceptance: Perl lowers adjacent attached switch branch blocks such as
    `switch(expr) { case(v) { ... } case(w) { ... } default { ... } }` without raw host-label residue,
    unresolved helpers, or invalid generated Perl; explicit semicolons and optional `endcase()` / `endswitch()`
    remain accepted; a same-line statement after the final attached switch block still requires an explicit
    semicolon per `.1.5.4`.
  Commit: `SPEC-FORMAT-TERSE.2.2.5.1 - implement Perl attached switch separator lock`; table reference: `SPEC-FORMAT-TERSE.2.2.5.1 — implement Perl attached switch separator lock`; retained completion note: Perl compact attached `switch/case/default` now splits adjacent branch bodies, lowers without host branch residue, and preserves the semicolon requirement before any following same-line ordinary statement. Frontier becomes `.2.2.5.2` Rust parity.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-FORMAT-TERSE --id SPEC-FORMAT-TERSE.2.2.5.1`.

- ID: `SPEC-FORMAT-TERSE.2.2.5.2`
  Status: `done` (2026-06-30)
  Goal: Rust parity — attached-block `switch/case/default`
  Acceptance: Rust parses and executes the accepted `.2.2.5.1` attached-switch contract with the same
    first-match/default semantics and oracle parity, while preserving the existing lazy value-form
    `switch(expr, case(...), default(...))`.
  Commit: `SPEC-FORMAT-TERSE.2.2.5.2 - implement Rust attached switch blocks`; table reference: `SPEC-FORMAT-TERSE.2.2.5.2 — implement Rust attached switch blocks`; retained completion note: Rust attached `switch/case/default` now parses and executes with first-match/default statement gating and oracle parity. Lazy value-form switch remains unchanged. Frontier becomes `.2.2.6` (`while`).
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-FORMAT-TERSE --id SPEC-FORMAT-TERSE.2.2.5.2`.

- ID: `SPEC-FORMAT-TERSE.2.2.6`
  Status: `done` (split/owned before code 2026-06-30; `.2.2.6.1` + `.2.2.6.2` done)
  Goal: `while(cond) { ... }` statement loop container
  Acceptance: `while(cond) { ... }` executes a statement block while the condition is true, has an explicit
    forward-progress/iteration safety rule, composes with block-local `return(expr)` where appropriate, and
    is implemented on Perl and Rust without raw host-language fallback.
  Children: `.2.2.6.1`, `.2.2.6.2`
  Commit: `SPEC-FORMAT-TERSE.2.2.6 - split while loop surface`; table reference: `SPEC-FORMAT-TERSE.2.2.6 — split while loop surface`; retained completion note: No engine behavior change. Attached `while(cond) { ... }` is split before code into `.2.2.6.1` Perl reference loop/safety and `.2.2.6.2` Rust parity. Frontier becomes `.2.2.6.1`.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-FORMAT-TERSE --id SPEC-FORMAT-TERSE.2.2.6`.

- ID: `SPEC-FORMAT-TERSE.2.2.6.1`
  Status: `done` (2026-06-30)
  Goal: Perl reference — attached-block `while(cond) { ... }` with iteration safety
  Acceptance: Perl lowers attached `while(cond) { ... }` through ActionIR without raw fallback or unresolved
    helper residue; the condition is evaluated before each iteration; body statements execute while true;
    `return(expr)` inside a rule/action loop still returns from the surrounding rule; and a deterministic
    iteration safety guard prevents non-terminating loops from hanging generated parsers.
  Commit: `SPEC-FORMAT-TERSE.2.2.6.1 - implement Perl attached while safety`; table reference: `SPEC-FORMAT-TERSE.2.2.6.1 — implement Perl attached while safety`; retained completion note: Perl attached `while(cond) { ... }` now lowers through ActionIR with condition re-evaluation and deterministic iteration safety. Frontier becomes `.2.2.6.2` Rust parity.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-FORMAT-TERSE --id SPEC-FORMAT-TERSE.2.2.6.1`.

- ID: `SPEC-FORMAT-TERSE.2.2.6.2`
  Status: `done` (2026-06-30)
  Goal: Rust parity — attached-block `while(cond) { ... }` with the accepted Perl safety contract
  Acceptance: Rust parses and executes the `.2.2.6.1` attached-while contract, including nested composition
    with existing statement `if`/`switch` controls, expression-valued block evaluation where applicable, the
    same deterministic iteration safety behavior, and oracle parity.
  Commit: `SPEC-FORMAT-TERSE.2.2.6.2 - implement Rust attached while safety`; table reference: `SPEC-FORMAT-TERSE.2.2.6.2 — implement Rust attached while safety`; retained completion note: Rust attached `while(cond) { ... }` now parses and executes with the accepted Perl loop/safety contract, expression-block composition, numeric comparison helper parity, and a 39-fixture oracle corpus. Frontier becomes `.2.3`.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-FORMAT-TERSE --id SPEC-FORMAT-TERSE.2.2.6.2`.

- ID: `SPEC-FORMAT-TERSE.2.3`
  Status: `done` / `closed` (2026-06-30 split container; children complete)
  Goal: Fluent control-flow, lifecycle blocks, and full composability
  Children: `.2.3.1`, `.2.3.2`, `.2.3.3` (container), `.2.3.4` (container), `.2.3.5`
  Acceptance: Fluent chains `.when (cond) { ... }.otherwise { ... }` (parens for condition, block after);
    lifecycle blocks `I { ... }`, `LS { ... }`, etc. take a block after the keyword and drop the value;
    Lisp-style composability everywhere (any function in any argument position at any depth); method
    chaining by return type (array→array, hash→hash, string→string, number→number).
  Commit: `SPEC-FORMAT-TERSE.2.3 - split fluent lifecycle composability surface`; retained completion note: No engine behavior change. `.2.3` is split into Perl fluent block-chain locking, lifecycle value/drop semantics, Rust fluent-block/action-edge parity, full composability audit, and return-type method chaining design. Frontier becomes `.2.3.1`.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-FORMAT-TERSE --id SPEC-FORMAT-TERSE.2.3`.

- ID: `SPEC-FORMAT-TERSE.2.3.1`
  Status: `done` (2026-06-30)
  Goal: Perl reference fluent block-chain contract lock
  Acceptance: Exact action-edge and lifecycle fluent block chains are source/descriptor/runtime locked on the
    Perl reference: `.when(cond) { ... }.otherwise { ... }` and the no-dot `otherwise` continuation variant
    both lower through owned ActionIR/bootstrap machinery with no raw fallback or unresolved helper residue.
    The book states this as the Perl reference surface unless and until Rust parity lands.
  Commit: `SPEC-FORMAT-TERSE.2.3.1 - lock Perl fluent when otherwise blocks`; retained completion note: Perl reference fluent `.when(cond) { ... }.otherwise { ... }` and no-dot `otherwise { ... }` fallback continuations now execute correctly on action-edge and lifecycle surfaces, with phase0 locks. Frontier becomes `.2.3.2`.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-FORMAT-TERSE --id SPEC-FORMAT-TERSE.2.3.1`.

- ID: `SPEC-FORMAT-TERSE.2.3.2`
  Status: `done` (2026-06-30)
  Goal: Lifecycle block value-drop and return-channel semantics lock
  Acceptance: `I { ... }`, `LS { ... }`, `LE { ... }`, `E { ... }`, `EX { ... }`, `IT { ... }`, and
    `LX { ... }` block syntax is verified across parser/runtime/book surfaces; final-expression block values
    are discarded, and explicit `return(expr)` behavior is documented and regression-locked separately from
    expression-valued block-local returns.
  Commit: `SPEC-FORMAT-TERSE.2.3.2 - lock lifecycle value drop return channel`; retained completion note: Lifecycle blocks are locked as statement blocks: final ordinary statement values are discarded, top-level `return(expr)` writes the surrounding rule/action channel, and expression-valued block-local return stays separate. Phase0 994 green; frontier becomes `.2.3.3`.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-FORMAT-TERSE --id SPEC-FORMAT-TERSE.2.3.2`.

- ID: `SPEC-FORMAT-TERSE.2.3.3`
  Status: `done` / `closed` (2026-06-30 split container; children complete)
  Goal: Rust fluent block-chain and action-edge parity split/implementation
  Children: `.2.3.3.1`, `.2.3.3.2`, `.2.3.3.3`
  Acceptance: Rust supports the accepted fluent control-flow block-chain contract, including attached block
    payloads on fluent calls where required, and no longer drops action-edge/body fluent continuations. This
    leaf must coordinate with `RUST-PARITY.7.5.3` rather than hiding that existing parity gap.
  Commit: `pending` (container split; first implementation child is `.2.3.3.1`)
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-FORMAT-TERSE --id SPEC-FORMAT-TERSE.2.3.3`.

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
  Commit: `SPEC-FORMAT-TERSE.2.3.3.1 - implement Rust action-edge fluent continuations` (see Commit Log); retained completion note: Rust action-edge fluent no-arg `.push`, `.return(expr)`, and `.return_undef` now execute through structured action-edge metadata; `tclite` remains deferred behind compact lifecycle/body fluent and default-mode repetition gaps. Frontier becomes `.2.3.3.2`.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-FORMAT-TERSE --id SPEC-FORMAT-TERSE.2.3.3.1`.

- ID: `SPEC-FORMAT-TERSE.2.3.3.2`
  Status: `done` (2026-06-30)
  Goal: Rust attached fluent block payloads for accepted `.when(cond) { ... }.otherwise { ... }` chains
  Acceptance: Rust parses and executes attached fluent block payloads on action-edge and lifecycle surfaces
    for the accepted Perl-reference `.when`/`otherwise` contract, including dotted and no-dot fallback tails.
  Commit: `SPEC-FORMAT-TERSE.2.3.3.2 - implement Rust attached fluent block payloads` (see Commit Log); retained completion note: Rust action-edge/lifecycle `.when(cond) { ... }` fluent block chains now execute through normalized attached statement blocks with dotted or no-dot fallback tails. Frontier becomes `.2.3.3.3`.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-FORMAT-TERSE --id SPEC-FORMAT-TERSE.2.3.3.2`.

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
  Commit: `SPEC-FORMAT-TERSE.2.3.3.3 - split remaining Rust fluent continuations` (see Commit Log); retained completion note: Remaining Rust fluent parity split into compact lifecycle/body receiver chains, action-edge explicit/flow chains, and `tclite`/default-mode repetition re-enable audit. Frontier becomes `.2.3.3.3.1`.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-FORMAT-TERSE --id SPEC-FORMAT-TERSE.2.3.3.3`.

- ID: `SPEC-FORMAT-TERSE.2.3.3.3.1`
  Status: `done` (2026-06-30)
  Goal: Rust compact lifecycle/body receiver chains
  Acceptance: Rust parses compact lifecycle/body receiver chains such as `I.return(expr)`,
    `I.declare(...).return(...)`, and chained helper statements after lifecycle markers into executable
    lifecycle `CodeBlock` statements instead of dropping them as standalone `FluentChain` elements. Add parser,
    compiler, and runtime locks for return-channel behavior, chained declaration/mutation helpers, and no
    surviving standalone `FluentChain` on accepted lifecycle-marker surfaces.
  Commit: `SPEC-FORMAT-TERSE.2.3.3.3.1 - implement Rust compact lifecycle fluent chains` (see Commit Log); retained completion note: Rust compact lifecycle/body receiver chains now execute as lifecycle `CodeBlock` statements; frontier becomes `.2.3.3.3.2`.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-FORMAT-TERSE --id SPEC-FORMAT-TERSE.2.3.3.3.1`.

- ID: `SPEC-FORMAT-TERSE.2.3.3.3.2`
  Status: `done` (2026-06-30)
  Goal: Rust action-edge explicit/flow fluent chains
  Acceptance: Rust action-edge fluent continuations beyond the no-arg `.2.3.3.1` subset are audited and
    implemented or further split: explicit `.push(child,target)` / `.push(target)` spellings, fluent
    statement-control chains (`.if(...).push(...).else().return_undef().endif()`), and shipped `ebnf.spec`
    action-edge forms must either execute with Perl-reference semantics or be split with concrete blockers.
  Commit: `SPEC-FORMAT-TERSE.2.3.3.3.2 - implement Rust action-edge fluent flow chains` (see Commit Log); retained completion note: Rust action-edge explicit/flow fluent chains now execute with explicit-target child return appends and statement-control gating; frontier becomes `.2.3.3.3.3`.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-FORMAT-TERSE --id SPEC-FORMAT-TERSE.2.3.3.3.2`.

- ID: `SPEC-FORMAT-TERSE.2.3.3.3.3`
  Status: `done` (split/audit-only, 2026-06-30)
  Goal: Rust `tclite` oracle re-enable / default-mode repetition audit after fluent parity
  Acceptance: After `.2.3.3.3.1` and `.2.3.3.3.2`, retry the deferred `tclite` oracle fixtures. If they still
    diverge, isolate the remaining default-mode repetition gap into a concrete implementation leaf before code.
  Commit: `SPEC-FORMAT-TERSE.2.3.3.3.3 - split Rust tclite repetition parity` (see Commit Log); retained completion note: `tclite` oracle retry after fluent parity still returned Rust `[]` for `[]` and `""` at that split point; default-mode recursive repetition parity split to `.2.3.3.3.3.1`, which later landed the fixtures.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-FORMAT-TERSE --id SPEC-FORMAT-TERSE.2.3.3.3.3`.

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
  Commit: `SPEC-FORMAT-TERSE.2.3.3.3.3.1 - implement Rust tclite default repetition` (see Commit Log); retained completion note: Rust default-mode recursive repetition parity landed; `tclite_command_subst` and `tclite_double_quote` are active oracle fixtures, corpus 41 passes, and frontier becomes `.2.3.4`.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-FORMAT-TERSE --id SPEC-FORMAT-TERSE.2.3.3.3.3.1`.

- ID: `SPEC-FORMAT-TERSE.2.3.4`
  Status: `done` (SPLIT/AUDIT 2026-06-30 — no runtime behavior change beyond a passing oracle fixture)
  Goal: Full composability audit and gap split
  Children: `.2.3.4.1` (Rust bare aggregate helper-argument parity), `.2.3.4.2` (Perl inline
    value-control lowering)
  Acceptance: Representative and adversarial nested helper calls are audited across Perl lowering, Rust AST,
    runtime evaluation, oracle fixtures, and mdBook examples. Any unsupported "function in any argument
    position at any depth" sites are split into concrete leaves instead of accepted by assertion.
  Commit: `SPEC-FORMAT-TERSE.2.3.4 - split composability boundaries`; prior node reference: `pending` (split/audit slice); retained completion note: Full composability audit split Rust helper-context aggregate bare reads to `.2.3.4.1` and Perl inline value-control lowering to `.2.3.4.2`; added a green deep pure-helper oracle fixture and frontier becomes `.2.3.4.1`.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-FORMAT-TERSE --id SPEC-FORMAT-TERSE.2.3.4`.

- ID: `SPEC-FORMAT-TERSE.2.3.4.1`
  Status: `done` (2026-06-30)
  Goal: Rust helper-context aggregate bare reads for nested pure composition
  Acceptance: Rust matches the Perl reference for helper argument positions where the callee implies a hash or
    array value from a bare working variable, starting with the audited book-shaped case
    `merge_hash(hash_copy(base), overlay)`. Add focused Rust runtime locks and re-enable the bare-argument
    oracle form only after it passes. Existing `array_copy(NAME)` / `hash_copy(NAME)` / `copy(NAME)` behavior
    from `.1.2.3.2` must remain unchanged.
  Commit: `SPEC-FORMAT-TERSE.2.3.4.1 - implement Rust bare aggregate helper args`; retained completion note: Rust helper-context bare aggregate arguments landed for hash- and array-consuming helper slots; corpus 44 passes and frontier becomes `.2.3.4.2`.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-FORMAT-TERSE --id SPEC-FORMAT-TERSE.2.3.4.1`.

- ID: `SPEC-FORMAT-TERSE.2.3.4.2`
  Status: `done` (2026-06-30)
  Goal: Perl inline-composite value control lowering
  Acceptance: Perl reference inline-composite `if(...)` and `switch(...)` value forms return the selected
    branch value in all supported value positions (`return(...)`, assignment RHS, and fluent `.return(...)`),
    with nested helper predicates/branches and expression-valued block branches covered. Rust already has
    runtime support for lazy value `if`/`switch`; after Perl lands, add oracle fixtures and focused parity
    checks instead of relying on descriptor readiness alone.
  Commit: `SPEC-FORMAT-TERSE.2.3.4.2 - implement Perl inline value controls`; retained completion note: Perl inline value-control lowering landed for `if`/`switch` in supported value positions; corpus 46 passes and frontier becomes `.2.3.5`.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-FORMAT-TERSE --id SPEC-FORMAT-TERSE.2.3.4.2`.

- ID: `SPEC-FORMAT-TERSE.2.3.5`
  Status: `done` (2026-07-01)
  Goal: Method chaining by return type design and first implementation split
  Acceptance: The return-type chaining model is specified before code. Statement-only receiver-dot mutations
    from `.1.6` remain stable, while value-returning method calls and chains are split by type family
    (array/hash/string/number) with explicit return contracts and backend parity requirements.
  Commit: `SPEC-FORMAT-TERSE.2.3.5 - split return-type method chaining`; retained completion note: Return-type method chaining specified before code and split into array/hash/string/number receiver-family leaves. No runtime behavior changed; first implementation frontier is `.2.3.5.1` array receiver-dot value chains.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-FORMAT-TERSE --id SPEC-FORMAT-TERSE.2.3.5`.

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
  Commit: `SPEC-FORMAT-TERSE.2.3.5.1 - implement array receiver value chains`; retained completion note: Array receiver-dot value chains landed on Perl/Rust with phase0, focused Rust tests, oracle corpus, mdBook, and KM locks. Frontier becomes `.2.3.5.2`.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-FORMAT-TERSE --id SPEC-FORMAT-TERSE.2.3.5.1`.

- ID: `SPEC-FORMAT-TERSE.2.3.5.2`
  Status: `done` (2026-07-01)
  Goal: Hash receiver-dot value chains
  Acceptance: Define and implement the hash-family receiver-dot value contract on Perl and Rust. Hash-producing
    methods such as merge/set_key/rename_key/drop_keys/pick_keys/hash_copy-style snapshots must return hashes
    and chain with later hash methods; key/value terminal methods such as sorted_keys/sorted_values/count_keys,
    has_key, scalaref, and flat_hash must return the documented array, number, boolean, scalar, or hash value.
    Statement-level hash mutations such as `set_key(name, key, value)` and `meta[key] = value` keep their
    existing statement semantics. Add parity locks, oracle fixtures, and mdBook examples.
  Commit: `SPEC-FORMAT-TERSE.2.3.5.2 - implement hash receiver value chains`; retained completion note: Hash receiver-dot value chains landed on Perl/Rust with focused tests, oracle corpus, mdBook, and KM locks. Frontier becomes `.2.3.5.3`.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-FORMAT-TERSE --id SPEC-FORMAT-TERSE.2.3.5.2`.

- ID: `SPEC-FORMAT-TERSE.2.3.5.3`
  Status: `done` (2026-07-01)
  Goal: String receiver-dot value chains
  Acceptance: Define and implement the string/scalar-family receiver-dot value contract on Perl and Rust.
    String-transforming methods such as trim/lowercase/uppercase/replace_substr/rm_prefix/rm_suffix/substr/cat
    must return strings and compose with later string methods. Predicate/array-producing terminals such as
    starts_with/ends_with/contains_substr/matches/split/split_each-style forms must return their documented
    boolean or array value and only continue through compatible next-family chains after that contract is
    explicit. Add parity locks, oracle fixtures, and mdBook examples.
  Commit: `SPEC-FORMAT-TERSE.2.3.5.3 - implement string receiver value chains`; retained completion note: String receiver-dot value chains landed on Perl/Rust with phase0, focused Rust tests, oracle corpus, mdBook, and KM locks. Frontier becomes `.2.3.5.4`.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-FORMAT-TERSE --id SPEC-FORMAT-TERSE.2.3.5.3`.

- ID: `SPEC-FORMAT-TERSE.2.3.5.4`
  Status: `done` (2026-07-01)
  Goal: Number receiver-dot value chains
  Acceptance: Define and implement the number-family receiver-dot value contract on Perl and Rust. Numeric
    methods must map receiver-dot form to the existing function-style numeric helper family without inventing
    operator precedence: unary methods (abs/floor/ceil/round) return numbers, binary/multi-argument methods
    (add/sub/mul/div/mod/min/max/clamp) consume the receiver as the first argument, comparison methods return
    booleans, and array reducers remain array-consuming unless an explicit receiver-family bridge is specified.
    Add parity locks, oracle fixtures, and mdBook examples.
  Commit: `SPEC-FORMAT-TERSE.2.3.5.4 - implement number receiver value chains`; retained completion note: Number receiver-dot value chains landed on Perl/Rust with phase0, focused Rust tests, oracle corpus, mdBook, and KM locks. `declare(...)` and other statement/lifecycle methods stay outside receiver methods. Frontier becomes `.2.3.5.5`.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-FORMAT-TERSE --id SPEC-FORMAT-TERSE.2.3.5.4`.

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
  Commit: `SPEC-FORMAT-TERSE.2.3.5.5 - implement block-valued receiver chains`; retained completion note: Expression-valued blocks now feed yielded array/string/hash/number values into compatible receiver-dot value chains. Perl array-yielding blocks use narrow visible-exit recognition; Rust parses fluent chains after block/hash/array primaries. Phase0 1001 green; oracle corpus 52 fixtures; receiver-chain family is complete.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-FORMAT-TERSE --id SPEC-FORMAT-TERSE.2.3.5.5`.

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
  Commit: `SPEC-FORMAT-TERSE.2.3.5.6 - lock aggregate wrapper quoting boundaries`; retained completion note: Bare aggregate wrapper arguments remain typed working-variable reads; quoted wrapper arguments remain constructor payloads; direct `[...]` / `{...}` shapes are the preferred terse constructors. Phase0 1000 green; oracle corpus 51 fixtures; frontier returns to `.2.3.5.5`.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-FORMAT-TERSE --id SPEC-FORMAT-TERSE.2.3.5.6`.

- ID: `SPEC-FORMAT-TERSE.3`
  Status: `done` / `closed`
  Goal: Round 3 — edge syntax plus uniform operator/function expression syntax
  Children: `.3.1`, `.3.2`, `.3.3`
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-FORMAT-TERSE --id SPEC-FORMAT-TERSE.3`.

- ID: `SPEC-FORMAT-TERSE.3.1`
  Status: `done` (2026-07-01)
  Goal: Edge syntax — confirm and lock current behavior
  Acceptance: `->` action edges, `=>` blind-call edges kept as-is. Grouped targets `-> A | B { code }`
    factor a shared code block across child rules (each target dispatches independently; the pipe is
    purely syntactic factoring). The block-less form `-> A | B` (no `{...}`) stays INVALID. (No code
    change expected — documents the decided contract; pair with regression locks if not already present.)
  Commit: `SPEC-FORMAT-TERSE.3.1 - lock edge syntax contract`; retained completion note: Edge syntax confirmed without behavior change: `->` action edges and `=>` blind-call edges stay as-is; grouped action targets require a shared block; block-less grouping stays invalid. Frontier becomes `.3.2`.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-FORMAT-TERSE --id SPEC-FORMAT-TERSE.3.1`.

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
  Commit: `SPEC-FORMAT-TERSE.3.2 - split arithmetic call surface`; retained completion note: Arithmetic/comparison calls split before code: `.3.2.1` owns non-conflicting numeric word aliases, `.3.2.2` owns arithmetic symbol callees, and `.3.2.3` owns the comparison spelling policy before implementation. Frontier becomes `.3.2.1`.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-FORMAT-TERSE --id SPEC-FORMAT-TERSE.3.2`.

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
  Commit: `SPEC-FORMAT-TERSE.3.2.1 - implement numeric word aliases`; retained completion note: Function-form numeric word aliases dispatch to the existing `num_*` family on Perl/Rust; bare comparison words stayed string helpers only until `.3.2.3.3`. Phase0 1002 green; oracle corpus 53 fixtures; frontier becomes `.3.2.2`.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-FORMAT-TERSE --id SPEC-FORMAT-TERSE.3.2.1`.

- ID: `SPEC-FORMAT-TERSE.3.2.2`
  Status: `done` 2026-07-02
  Goal: Arithmetic symbol callees for the numeric helper family
  Acceptance: Symbol function calls `+(a,b)`, `-(a,b)`, `*(a,b)`, `/(a,b)`, and `%(a,b)` parse and map to
    `num_add`, `num_sub`, `num_mul`, `num_div`, and `num_mod` on Perl and Rust. The implementation must reject
    or lower these before any raw host-language fallback can reinterpret them; in particular, `+(2,3)` must be
    numeric addition, not Perl unary-plus/comma behavior. No `(op a, b)` Lisp-prefix form is accepted and no
    operator precedence is introduced.
  Commit: `SPEC-FORMAT-TERSE.3.2.2 - implement arithmetic symbol callees`; retained completion note: Arithmetic symbol callees `+(...)`, `-(...)`, `*(...)`, `/(...)`, and `%(...)` now dispatch to `num_add`/`num_sub`/`num_mul`/`num_div`/`num_mod` on Perl/Rust; slash regex literals remain regexes. Frontier becomes `.3.2.3`.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-FORMAT-TERSE --id SPEC-FORMAT-TERSE.3.2.2`.

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
  Commit: `SPEC-FORMAT-TERSE.3.2.3 - split comparison call surface`; retained completion note: Comparison call migration split before code: explicit `str_*` string bridge first, numeric comparison word aliases second, numeric comparison symbol callees third. Current shipped comparison behavior is unchanged; frontier becomes `.3.2.3.1`.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-FORMAT-TERSE --id SPEC-FORMAT-TERSE.3.2.3`.

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
  Commit: `SPEC-FORMAT-TERSE.3.2.3.1 - lock string comparison bridge`; retained completion note: Explicit `str_*` string-bridge names locked before implementation; no runtime behavior changed; frontier becomes `.3.2.3.2`.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-FORMAT-TERSE --id SPEC-FORMAT-TERSE.3.2.3.1`.

- ID: `SPEC-FORMAT-TERSE.3.2.3.2`
  Status: `done` 2026-07-02
  Goal: Implement explicit string-comparison helpers
  Acceptance: Implement `str_eq`/`str_ne`/`str_gt`/`str_ge`/`str_lt`/`str_le` on Perl and Rust as the portable
    explicit string-comparison family, update docs/examples/tests to prefer them for lexical string ordering,
    and keep old bare comparison words as compatibility aliases until `.3.2.3.3` owns the numeric-word flip.
    Add focused Perl/Rust locks and mdBook/KM updates.
  Commit: `SPEC-FORMAT-TERSE.3.2.3.2 - implement string comparison helpers`; retained completion note: Explicit `str_*` lexical string comparisons landed on Perl/Rust; corpus 56 passes and frontier becomes `.3.2.3.3`.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-FORMAT-TERSE --id SPEC-FORMAT-TERSE.3.2.3.2`.

- ID: `SPEC-FORMAT-TERSE.3.2.3.3`
  Status: `done` 2026-07-02
  Goal: Numeric comparison word aliases
  Acceptance: After the string bridge lands, map ordinary value-call comparison words `eq`, `ne`, `gt`, `ge`,
    `lt`, and `le` to `num_eq`, `num_ne`, `num_gt`, `num_ge`, `num_lt`, and `num_le` on Perl and Rust. Preserve
    explicit `num_*` helper names and number receiver terminals. This leaf must close raw fallback for the
    word-call shapes it owns, update legacy-string compatibility notes, and add focused parity/oracle locks.
  Commit: `SPEC-FORMAT-TERSE.3.2.3.3 - flip comparison word aliases`; retained completion note: Bare comparison word calls now map to numeric `num_*` aliases on Perl/Rust; lexical string comparisons use `str_*`; corpus 57 passes and frontier becomes `.3.2.3.4`.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-FORMAT-TERSE --id SPEC-FORMAT-TERSE.3.2.3.3`.

- ID: `SPEC-FORMAT-TERSE.3.2.3.4`
  Status: `done` (2026-07-02)
  Goal: Numeric comparison symbol callees
  Acceptance: Parse and dispatch `==(a,b)`, `!=(a,b)`, `>(a,b)`, `>=(a,b)`, `<(a,b)`, and `<=(a,b)` as
    ordinary numeric comparison calls on Perl and Rust, mapping to the same `num_*` comparison helpers as the
    word aliases. Preserve regex/slash handling from `.3.2.2`; do not claim `=(target,value)` assignment
    operator-call behavior, which remains `.3.3`; do not disturb `=>` blind-call edges. Add parser/lowering/
    runtime parity locks, oracle fixture(s), mdBook examples, and Knowledge Map updates.
  Commit: `SPEC-FORMAT-TERSE.3.2.3.4 - implement comparison symbol callees`; retained completion note: Comparison symbol callees now map to numeric `num_*` aliases on Perl/Rust; corpus 58 passes and frontier becomes `.3.3`.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-FORMAT-TERSE --id SPEC-FORMAT-TERSE.3.2.3.4`.

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
  Commit: `SPEC-FORMAT-TERSE.3.3 - split expression-valued assignment`; retained completion note: Assignment expression values are split before code into scalar, aggregate, append/hash-index, and compatibility/docs closure leaves; current shipped assignment remains statement-only and frontier becomes `.3.3.1`.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-FORMAT-TERSE --id SPEC-FORMAT-TERSE.3.3`.

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
  Commit: `SPEC-FORMAT-TERSE.3.3.1 - implement scalar assignment values`
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-FORMAT-TERSE --id SPEC-FORMAT-TERSE.3.3.1`.

- ID: `SPEC-FORMAT-TERSE.3.3.2`
  Status: `done` (2026-07-02)
  Goal: Aggregate assignment expression values after target-kind inference
  Acceptance: Extend expression-valued assignment to array/hash targets and direct RHS shape target-kind
    inference after `.3.3.1` lands. `target = [value]`, `target = { key => value }`, `set(target, [value])`,
    `set(target, { key => value })`, matching typed aggregate targets, and the operator-call spelling must
    return the aggregate value stored in the target after assignment. Explicit `scalar(target)` remains the
    scalar payload boundary. Backend parity and oracle fixtures must cover both array and hash results.
  Commit: `SPEC-FORMAT-TERSE.3.3.2 - implement aggregate assignment values`; retained completion note: Direct RHS shape assignment expressions now return the assigned array/hash value after target-kind inference on Perl/Rust; corpus 60 fixtures, phase0 1013 green, and frontier becomes `.3.3.3`.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-FORMAT-TERSE --id SPEC-FORMAT-TERSE.3.3.2`.

- ID: `SPEC-FORMAT-TERSE.3.3.3`
  Status: `done` (2026-07-02)
  Goal: Mutation expression values for array append and hash-index assignment
  Acceptance: Define and implement value contracts for mutation operators that are currently statement-only:
    `items += value` and `meta[key] = value`. Before code, lock whether each expression returns the updated
    target aggregate snapshot or the stored element value; after that decision, implement Perl/Rust parity,
    preserve statement-side behavior, and add oracle coverage for helper arguments, `return(...)`, block
    values, and compatible receiver chains.
  Commit: `SPEC-FORMAT-TERSE.3.3.3 - implement mutation assignment values`; retained completion note: Array append and hash-index mutation expressions now return updated aggregate snapshots on Perl/Rust; corpus 61 fixtures, phase0 1014 green, and frontier becomes `.3.3.4`.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-FORMAT-TERSE --id SPEC-FORMAT-TERSE.3.3.3`.

- ID: `SPEC-FORMAT-TERSE.3.3.4`
  Status: `done` (2026-07-02)
  Goal: Legacy function spelling cleanup and full assignment-expression closure
  Acceptance: After scalar, aggregate, append, and hash-index expression semantics land, reconcile the retained
    `assign(...)` compatibility surface with canonical `set(...)` and operator spellings. Public examples must
    prefer `target = value` or `set(...)` as appropriate and must not promote `assign(...)` as new syntax.
    Close mdBook/KM/status drift, add any missing oracle/corpus fixtures, and confirm the parent `.3.3`
    contract across Perl and Rust.
  Commit: `SPEC-FORMAT-TERSE.3.3.4 - close assignment expression docs`; retained completion note: Parent assignment-expression closure fixture locks scalar, aggregate, mutation, user-function, receiver-chain, operator, canonical `set`, and legacy `assign` compatibility forms; public book examples now prefer `set`/operators; corpus 62 fixtures, phase0 1015 green, and no concrete `SPEC-FORMAT-TERSE` PNT leaf remains.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-FORMAT-TERSE --id SPEC-FORMAT-TERSE.3.3.4`.

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
  Commit: `SPEC-FORMAT-TERSE.4 - own user-defined function surface`; retained completion note: User-defined pure functions are now owned under Round 4. Calls are value expressions, may feed receiver-dot chains, and standalone results are silently discarded. Frontier becomes `.4.1`, then `.3.2.2`.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-FORMAT-TERSE --id SPEC-FORMAT-TERSE.4`.

- ID: `SPEC-FORMAT-TERSE.4.1`
  Status: `done` (2026-07-01 — contract/inventory locked before code)
  Goal: Function syntax/semantics contract and implementation inventory
  Acceptance: Record the exact MVP grammar, name-resolution rules, purity limits, parameter binding model,
    return-value model, receiver-chain behavior, unused-result behavior, collision/error boundaries, and split
    implementation seams before code. The inventory must inspect `specs/spec.spec`, the Perl bootstrap parser
    only to identify/remove any temporary `fn` support boundary, Perl ActionIR AST lowering/value-expression
    seams, the Rust parser/runtime expression model, oracle generation, and mdBook chapters. If the
    implementation surface is broader than one signoff slice, split `.4.2+` further before code.
  Commit: `SPEC-FORMAT-TERSE.4.1 - lock user function contract`; retained completion note: User-function MVP contract/inventory locked before code; implementation split into `.4.2.1`–`.4.2.3` and `.4.3.1`–`.4.3.2`. Frontier becomes `.4.2.1`.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-FORMAT-TERSE --id SPEC-FORMAT-TERSE.4.1`.

- ID: `SPEC-FORMAT-TERSE.4.2`
  Status: `done` (2026-07-01; split by `.4.1` inventory)
  Goal: Perl reference user-function implementation
  Children: `.4.2.1`, `.4.2.2`, `.4.2.3`
  Acceptance: The Perl reference accepts the `.4.1` function contract through a sequence of signoff-sized
    leaves: first the self-hosted grammar/top-level function registry, then value-call execution/lowering, then
    standalone discard plus receiver-chain/error hardening. The final grammar owner is `specs/spec.spec`; do not
    leave permanent `fn` syntax support in the bootstrap parser. Add focused phase0 locks and update
    `specs/spec.spec`, mdBook, live docs, and Knowledge Map as warranted.
  Commit: closed by child commits `.4.2.1`, `.4.2.2`, and `.4.2.3`
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-FORMAT-TERSE --id SPEC-FORMAT-TERSE.4.2`.

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
  Commit: `SPEC-FORMAT-TERSE.4.2.1 - add Perl user function registry`; retained completion note: Perl registry/descriptor seam landed: `specs/spec.spec` owns active `function_definition`, descriptors expose `functions`, and registered calls intentionally remain unresolved until `.4.2.2`. Frontier becomes `.4.2.2`.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-FORMAT-TERSE --id SPEC-FORMAT-TERSE.4.2.1`.

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
  Commit: `SPEC-FORMAT-TERSE.4.2.2 - execute Perl user function value calls`
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-FORMAT-TERSE --id SPEC-FORMAT-TERSE.4.2.2`.

- ID: `SPEC-FORMAT-TERSE.4.2.3`
  Status: `done` (2026-07-01)
  Goal: Perl reference standalone discard, purity diagnostics, and phase0 hardening
  Acceptance: Standalone user-function call statements compute and silently discard the returned value without
    raw fallback. The MVP rejects recursion, unsupported side-effect/parser-state helpers, host-code escape,
    closure/lambda/currying syntax, implicit caller working-variable capture, and attempts to mutate caller
    scope with clear diagnostics. Add source, descriptor, runtime, receiver-chain, collision, and negative
    phase0 locks while preserving the all-target ActionIR-ready invariant at ratio 1.0000.
  Commit: `SPEC-FORMAT-TERSE.4.2.3 - harden Perl user function discard`; retained completion note: Registered standalone calls now lower as `VALUE_DROP`, nested user-function parameter passing is fixed, and recursion/unsupported body diagnostics are phase0-locked. Frontier becomes `.4.3.1`.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-FORMAT-TERSE --id SPEC-FORMAT-TERSE.4.2.3`.

- ID: `SPEC-FORMAT-TERSE.4.3`
  Status: `done` (2026-07-02; split 2026-07-01 by `.4.1` inventory)
  Goal: Rust parity for user-defined pure functions
  Children: `.4.3.1`, `.4.3.2`
  Acceptance: The Rust parser/runtime matches the Perl reference for the `.4.1`/`.4.2` contract, including
    function-call value semantics, receiver-dot chaining, and silent standalone-result discard. Add Rust parser,
    runtime, and oracle corpus locks.
  Commit: closed by child commits `.4.3.1` and `.4.3.2`
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-FORMAT-TERSE --id SPEC-FORMAT-TERSE.4.3`.

- ID: `SPEC-FORMAT-TERSE.4.3.1`
  Status: `done` (2026-07-02)
  Goal: Rust function-definition AST/compiler registry parity
  Acceptance: Extend Rust parsed `.spec` AST and compiled spec structures with the same function registry shape
    accepted by the Perl reference: name, ordered parameters, body `CodeBlock`, source metadata, and exact arity.
    Enforce duplicate/collision/parameter diagnostics before execution and preserve existing rule compilation.
  Commit: `SPEC-FORMAT-TERSE.4.3.1 - add Rust user function registry`; retained completion note: Rust parsed/compiled registry parity landed: `SpecFile.functions`, `FunctionDefinition`, `CompiledSpec.functions`, `CompiledUserFunction`, and pre-runtime diagnostics. Frontier becomes `.4.3.2`.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-FORMAT-TERSE --id SPEC-FORMAT-TERSE.4.3.1`.

- ID: `SPEC-FORMAT-TERSE.4.3.2`
  Status: `done` (2026-07-02)
  Goal: Rust user-function runtime parity and oracle fixtures
  Acceptance: Rust `Engine` resolves user-function calls before unknown-helper fallback, evaluates arguments
    eagerly, executes the function body in a fresh local scope, returns final-expression or `return(expr)` values,
    supports receiver-dot continuation from returned values, silently discards standalone call results, and
    matches the Perl reference in focused integration tests plus oracle fixtures.
  Commit: `SPEC-FORMAT-TERSE.4.3.2 - execute Rust user functions`; retained completion note: Rust runtime parity landed for registered value calls, receiver chains, standalone discard, local function scope, exact-arity diagnostics, recursion diagnostics, and the 54-fixture oracle corpus. Frontier becomes `.4.4`.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-FORMAT-TERSE --id SPEC-FORMAT-TERSE.4.3.2`.

- ID: `SPEC-FORMAT-TERSE.4.4`
  Status: `done` (2026-07-02)
  Goal: Function surface finalization and deferred extension ledger
  Acceptance: Close the user-facing docs and retrieval state after Perl/Rust parity. Record explicit deferrals
    for alternate spellings (`function ... endfunction`, optional zero-arg parentheses, brace-less bodies),
    statementful functions, recursion, closures, lambdas, currying, and any future function namespace features.
  Commit: `SPEC-FORMAT-TERSE.4.4 - finalize function surface ledger`; retained completion note: Function MVP docs/retrieval closure landed; frontier becomes `.3.2.2`.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-FORMAT-TERSE --id SPEC-FORMAT-TERSE.4.4`.

- ID: `SPEC-FORMAT-TERSE.5`
  Status: `done` / `closed` (split 2026-07-01; future backend leaves now superseded by `FUTURE-PARITY-BACKLOG`)
  Goal: Future backend variant parity ownership before any non-Rust variant code
  Children: `.5.0` (done), `.5.1` (deferred), `.5.2` (deferred), `.5.3` (superseded by `FUTURE-PARITY-BACKLOG.1.3`)
  Acceptance: The implemented-variant inventory is explicit, the accepted future backend targets are tied
    back to ADR `0006`, and no future backend implementation can begin without a concrete owning leaf/tree
    plus a corpus-parity acceptance contract. This ownership slice must not add backend code.
  Commit: `SPEC-FORMAT-TERSE.5.0 - own future variant parity inventory`
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-FORMAT-TERSE --id SPEC-FORMAT-TERSE.5`.

- ID: `SPEC-FORMAT-TERSE.5.0`
  Status: `done` (2026-07-01)
  Goal: Inventory implemented/future backend variants and split future parity ownership
  Acceptance: Re-read the active roadmap/task tree, ADR `0006`, Phase 8/9 task trees, mdBook backend handoff,
    Knowledge Map backend facts, and tracked source layout. Record that the implemented backends are the Perl
    reference and the Rust interpreter, that future backend work needs explicit ownership before code, and
    that later adoption decisions belong in ADR/task-tree records. Update live docs and retrieval docs; do not
    change parser/compiler/runtime code.
  Commit: `SPEC-FORMAT-TERSE.5.0 - own future variant parity inventory`; retained completion note: Future backend parity ownership is explicit: Perl reference and Rust are implemented; ADR `0021` later adopts Lua and moves future backend rollout to `FUTURE-PARITY-BACKLOG`. Frontier returns to `.3.1`.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-FORMAT-TERSE --id SPEC-FORMAT-TERSE.5.0`.

- ID: `SPEC-FORMAT-TERSE.5.1`
  Status: `superseded` (2026-07-09 by `FUTURE-PARITY-BACKLOG.1.2` and `JULIA-BACKEND-PARITY`)
  Goal: Julia backend parity task-tree adoption
  Acceptance: When the roadmap selects Julia backend implementation, create or activate a dedicated backend
    task tree with concrete parser/compiler/runtime/helper/corpus leaves. The acceptance contract must require
    identical `.spec` input files, mdBook-neutral behavior, and language-neutral corpus parity before any
    feature is called complete.
  Commit: `FUTURE-PARITY-BACKLOG.1.2 - scope Julia backend parity plan`
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-FORMAT-TERSE --id SPEC-FORMAT-TERSE.5.1`.

- ID: `SPEC-FORMAT-TERSE.5.2`
  Status: `superseded` (2026-07-09 by `FUTURE-PARITY-BACKLOG.1.1` and `DART-BACKEND-PARITY`)
  Goal: Dart backend parity task-tree adoption
  Acceptance: When the roadmap selects Dart backend implementation, create or activate a dedicated backend
    task tree with concrete parser/compiler/runtime/helper/corpus leaves. The acceptance contract must require
    identical `.spec` input files, mdBook-neutral behavior, and language-neutral corpus parity before any
    feature is called complete.
  Commit: `DART-BACKEND-PARITY.7.5 - close Dart parity milestone`
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-FORMAT-TERSE --id SPEC-FORMAT-TERSE.5.2`.

- ID: `SPEC-FORMAT-TERSE.5.3`
  Status: `superseded` (2026-07-09 by ADR `0021` and `FUTURE-PARITY-BACKLOG.1.3`)
  Goal: Lua backend scope decision before any Lua parity leaf
  Acceptance: Lua may enter the backend set only after an explicit decision record or roadmap update adopts it
    and defines the same universal `.spec` / corpus-parity obligations as the accepted future backends.
  Commit: `FUTURE-PARITY-BACKLOG.0 - create future parity backlog`
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-FORMAT-TERSE --id SPEC-FORMAT-TERSE.5.3`.

- ID: `SPEC-FORMAT-TERSE.6`
  Status: `done` (2026-07-04)
  Goal: Finish the terse-format declaration migration by removing `declare(...)` from live `.spec` files.
  Children: `.6.1`, `.6.2`, `.6.3`, `.6.4`
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-FORMAT-TERSE --id SPEC-FORMAT-TERSE.6`.

- ID: `SPEC-FORMAT-TERSE.6.1`
  Status: `done`
  Goal: Own the 2026-07-03 user directive that `declare(...)` shall not be used in spec files, and split the
    retirement work under this existing terse-format tree before any `.spec` edit.
  Acceptance: The task tree records the directive as the implementation of the existing `.1.1`/ADR `0007`
    gradual-migration promise; `docs/TASK_TREE.md`, roadmap/live docs, mdBook guidance, and Knowledge Map point at
    the new frontier; no `.spec` file is modified in this ownership leaf.
  Commit: `SPEC-FORMAT-TERSE.6.1 - own declare retirement migration`; retained completion note: User directive owned under `SPEC-FORMAT-TERSE`; shipped-spec inventory recorded; no `.spec` file changed; frontier becomes `.6.2`.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-FORMAT-TERSE --id SPEC-FORMAT-TERSE.6.1`.

- ID: `SPEC-FORMAT-TERSE.6.2`
  Status: `done` (2026-07-04)
  Goal: Migrate shipped specs to the canonical terse surface already landed by this tree.
  Children: `.6.2.1`, `.6.2.2`, `.6.2.3`, `.6.2.4`
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-FORMAT-TERSE --id SPEC-FORMAT-TERSE.6.2`.

- ID: `SPEC-FORMAT-TERSE.6.2.1`
  Status: `done` (2026-07-03)
  Goal: Remove `declare(...)` from shipped specs using auto-existing variables and explicit reset assignments.
  Acceptance: `rg -n '(^|[.{;[:space:]])declare\(' specs` returns no active hits; migrated specs compile on the
    Perl reference; representative behavior stays stable or exact blockers are split; no runtime `declare`
    expansion is introduced to compensate for old verbose syntax.
  Commit: `SPEC-FORMAT-TERSE.6.2.1 - remove declare from shipped specs`; retained completion note: Removed the 70 active shipped-spec `declare(...)` / `.declare(...)` uses with terse assignments/resets and structured lifecycle blocks; phase0 and Rust corpus oracle pass; frontier becomes `.6.2.2`.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-FORMAT-TERSE --id SPEC-FORMAT-TERSE.6.2.1`.

- ID: `SPEC-FORMAT-TERSE.6.2.2`
  Status: `done` (2026-07-03)
  Goal: Migrate old shipped-spec helper spellings to canonical terse helper spellings.
  Acceptance: Active shipped specs no longer use `assign(...)`, `push_value(...)`, `array_copy(...)`,
    `hash_copy(...)`, or `concat(...)` when a shipped terse equivalent already exists (`set`, `push`, `copy`,
    `cat`, assignment operators); `portmap.spec` also drops standalone statement separators after flow markers
    such as `if(...)`, `elseif(...)`, and `else()` where no following same-line construct makes the separator
    necessary; migrated specs compile and focused behavior checks stay stable.
  Commit: `SPEC-FORMAT-TERSE.6.2.2 - migrate shipped-spec helper spellings`; retained completion note: Migrated active shipped-spec old helper spellings to `set`, `push`, `copy`, and `cat`; cleaned redundant standalone `portmap.spec` flow-marker separators; phase0 and Rust corpus oracle pass; frontier becomes `.6.2.3`.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-FORMAT-TERSE --id SPEC-FORMAT-TERSE.6.2.2`.

- ID: `SPEC-FORMAT-TERSE.6.2.3`
  Status: `done` (2026-07-04; both children done)
  Goal: Migrate shipped-spec typed wrappers/constructors toward terse scalar-slot reads, bare reads, and direct
    shape literals where the accepted inference rules make the replacement unambiguous.
  Children: `.6.2.3.1`, `.6.2.3.2`
  Acceptance: Wrapper cleanup proceeds only through concrete child leaves. Parser/runtime syntax extensions are
    owned before any shipped-spec migration uses them; any remaining `scalar(...)`, `array(...)`, or `hash(...)`
    use is explicitly classified as still-needed compatibility syntax or split into a narrower owner.
  Commit: `.6.2.3.1`, `.6.2.3.2` (see Commit Log)
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-FORMAT-TERSE --id SPEC-FORMAT-TERSE.6.2.3`.

- ID: `SPEC-FORMAT-TERSE.6.2.3.1`
  Status: `done` (2026-07-03)
  Goal: Add `:name` as a terse scalar-slot expression for the value of scalar working variable `name`, with
    `set(:name, value)` preserving the explicit scalar target boundary that `set(scalar(name), value)` has today.
  Acceptance: Perl reference lowering and Rust parsing/runtime treat `:name` as equivalent to one-argument
    `scalar(name)` in value positions and as an explicit scalar target in assignment-like target positions;
    direct-shape aggregate inference for bare `name = [...]` / `set(name, [...])` remains unchanged; the mdBook
    documents `:name` as the preferred terse scalar spelling while `scalar(name)` remains accepted compatibility
    syntax; focused Perl/Rust tests and one oracle fixture lock the behavior.
  Commit: `SPEC-FORMAT-TERSE.6.2.3.1 - add scalar slot shorthand`; retained completion note: Added `:name` as the scalar-slot shorthand on Perl/Rust; `set(:payload, [value])` keeps scalar payload assignment while bare direct-shape targets still infer aggregates; phase0 1019 and oracle 73 fixtures pass; frontier becomes `.6.2.3.2`.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-FORMAT-TERSE --id SPEC-FORMAT-TERSE.6.2.3.1`.

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
  Commit: `SPEC-FORMAT-TERSE.6.2.3.2 - retire scalar and assign spec helpers`; retained completion note: Authored/current specs moved to `:name`, `LHS = RHS` / `set(...)`, direct shapes, and remembered bare kind; raw authored `scalar(...)` and `assign(...)` are retired from the DSL surface; phase0 1020 and focused Rust checks pass.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-FORMAT-TERSE --id SPEC-FORMAT-TERSE.6.2.3.2`.

- ID: `SPEC-FORMAT-TERSE.6.2.4`
  Status: `done` (2026-07-04)
  Goal: Final shipped-spec terse-surface verification and no-drift inventory.
  Acceptance: Shipped specs compile, phase0 and oracle gates pass or exact blockers are task-owned, and the
    shipped-spec old-surface inventory is either clean or fully annotated in this task tree before moving to docs
    and corpus sweeps.
  Commit: `SPEC-FORMAT-TERSE.6.2.4 - verify shipped-spec terse surface`; retained completion note: Final shipped-spec no-drift verification passes: all 21 shipped specs compile, retired-surface/old-helper shipped scans are clean, phase0 1020 and Rust oracle 73 fixtures pass, mdBook builds, and broader docs/corpus legacy references are owned by `.6.3`.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-FORMAT-TERSE --id SPEC-FORMAT-TERSE.6.2.4`.

- ID: `SPEC-FORMAT-TERSE.6.3`
  Status: `done` (2026-07-04)
  Goal: Sweep public docs, checked-in corpus/test specs, and current-facing examples so they no longer teach or
    depend on `declare(...)` as active spec-file authoring.
  Acceptance: mdBook and current guides document terse replacements first; examples use auto-existing variables,
    assignment operators, `set(...)`, `items = []`, `meta = { ... }`, `items += value`, and `meta[key] = value`
    instead of `declare(...)`; historical/task records remain only when clearly historical; book build and focused
    doc/corpus scans pass.
  Commit: `SPEC-FORMAT-TERSE.6.3 - sweep docs and corpus declare examples`; retained completion note: Current-facing mdBook and checked-in corpus examples now use terse initialization/mutation and canonical helper spellings; root corpus scans/probes pass; generated oracle expected outputs are unchanged; residual old spellings are compatibility/reference-only; frontier becomes `.6.4`.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-FORMAT-TERSE --id SPEC-FORMAT-TERSE.6.3`.

- ID: `SPEC-FORMAT-TERSE.6.4`
  Status: `done` (2026-07-04)
  Goal: Decide and implement the post-migration compatibility-support policy for declaration helpers.
  Acceptance: After `.6.2`/`.6.3` leave no live spec-file dependency, either keep implementation support explicitly
    documented as legacy compatibility or remove/diagnose it under a focused implementation leaf; Perl and Rust
    agree on the selected policy; final no-drift scans and local gates pass.
  Commit: `SPEC-FORMAT-TERSE.6.4 - lock declare compatibility policy`; retained completion note: ADR `0018` keeps declaration helpers as accepted legacy compatibility, excludes them from new authoring, and requires a future focused leaf for any removal/diagnostics; declaration-retirement `.6` closes and frontier becomes `.7.1`.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-FORMAT-TERSE --id SPEC-FORMAT-TERSE.6.4`.

- ID: `SPEC-FORMAT-TERSE.7`
  Status: `done` (2026-07-04; no current `SPEC-FORMAT-TERSE` frontier)
  Goal: Audit and backfill the type method surface so useful helper functions are also available as receiver
    methods on the supported value types when that is readable and type-correct.
  Children: `.7.1`, `.7.2`, `.7.3`, `.7.4`
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-FORMAT-TERSE --id SPEC-FORMAT-TERSE.7`.

- ID: `SPEC-FORMAT-TERSE.7.1`
  Status: `done` (2026-07-04)
  Goal: Inventory supported runtime value types and helper families before implementation.
  Acceptance: The task tree lists every supported receiver/value family (string/scalar, array/list, hash, number,
    boolean/flow-result where applicable, block-yielded values, and user-function returns), maps existing helpers
    to plausible method candidates, identifies helpers that should remain function-only, and states backend/test/doc
    impact before any code changes.
  Commit: `SPEC-FORMAT-TERSE.7.1 - inventory type method surface`; retained completion note: Receiver/value families, existing method tables, function/statement-only boundaries, and backend/test/doc impact are recorded before code; string `substr()` is already a receiver method, and frontier becomes `.7.2` verification/backfill.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-FORMAT-TERSE --id SPEC-FORMAT-TERSE.7.1`.

- ID: `SPEC-FORMAT-TERSE.7.2`
  Status: `done` (2026-07-04)
  Goal: Backfill string/scalar receiver methods, explicitly including the user's `substr()` method directive.
  Acceptance: `substr(...)` is verified or implemented as a string/scalar receiver method on Perl and Rust, all
    other useful string helper candidates from `.7.1` are either implemented or explicitly deferred with reasons,
    and docs/tests demonstrate helper-form and method-form equivalence.
  Commit: `SPEC-FORMAT-TERSE.7.2 - verify string method surface`; retained completion note: String/scalar receiver methods, including `substr()`, are already implemented and documented on Perl/Rust; focused probes/tests verify helper-method equivalence; no parser/runtime/book behavior change was needed, and frontier becomes `.7.3`.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-FORMAT-TERSE --id SPEC-FORMAT-TERSE.7.2`.

- ID: `SPEC-FORMAT-TERSE.7.3`
  Status: `done` (2026-07-04)
  Goal: Backfill useful array/list, hash, and number receiver methods from the `.7.1` inventory.
  Acceptance: Reasonable pure helper candidates are method-callable on matching receiver types, mutating or
    ambiguous helpers retain explicit statement/function forms unless the leaf defines safe receiver semantics, and
    Perl/Rust parity plus mdBook examples are locked.
  Commit: `SPEC-FORMAT-TERSE.7.3 - backfill array numeric reducer receiver methods`; retained completion note: Array/list numeric reducers `sum`, `avg`, `median`, `range`, `min`, and `max` are terminal receiver methods on Perl/Rust; invalid continuations return `undef`/`null`; phase0 1021 and oracle 74 fixtures pass.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-FORMAT-TERSE --id SPEC-FORMAT-TERSE.7.3`.

- ID: `SPEC-FORMAT-TERSE.7.4`
  Status: `done` (2026-07-04)
  Goal: Final type-method no-drift sweep.
  Acceptance: The codebase, mdBook, helper catalog, examples, tests, and Knowledge Map agree on which helpers are
    methods, which remain function-only, and why; broad gates pass.
  Commit: `SPEC-FORMAT-TERSE.7.4 - close type-method no-drift sweep`; retained completion note: Roadmap/task-tree/mdBook/KM receiver-family summaries are reconciled after `.7.3`; type-method lane closes with no Perl/Rust behavior change; at that time no concrete `SPEC-FORMAT-TERSE` leaf was pending.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-FORMAT-TERSE --id SPEC-FORMAT-TERSE.7.4`.

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
  Commit: `SPEC-FORMAT-TERSE.8.6 - close helper retirement drift`
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-FORMAT-TERSE --id SPEC-FORMAT-TERSE.8`.

- ID: `SPEC-FORMAT-TERSE.8.1`
  Status: `done` (2026-07-06)
  Goal: Inventory and split legacy helper-removal before any behavior change.
  Acceptance: LinkedSpec-tool probes and code reads classify which legacy helper spellings still succeed on Perl
    and Rust, which are already retired/diagnostic, which examples/docs/corpus surfaces still exercise them, and
    which child leaf owns each removal/migration boundary.
  Commit: `SPEC-FORMAT-TERSE.8.1 - split legacy helper retirement`; retained completion note: Legacy helper-removal inventory/split: current successful compatibility paths and `push_nonempty(...)` replacement risk are classified; `.8.2` becomes the active migration owner before Perl/Rust hard retirement.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-FORMAT-TERSE --id SPEC-FORMAT-TERSE.8.1`.

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
  Commit: `SPEC-FORMAT-TERSE.8.2.4 - close helper migration no-drift gates`
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-FORMAT-TERSE --id SPEC-FORMAT-TERSE.8.2`.

- ID: `SPEC-FORMAT-TERSE.8.2.1`
  Status: `done` (2026-07-06)
  Goal: Migrate the current live EBNF optional-capture append path away from `push_nonempty(...)` before helper
    removal.
  Acceptance: `specs/ebnf.spec`, generated EBNF oracle corpus inputs, and the EBNF mdBook walkthrough no longer
    use `push_nonempty(...)`. The replacement evaluates the trimmed capture slice once, appends it only when
    `is_nonempty(...)` is true, preserves the existing `logging_annotation` JSON output, and keeps oracle generation
    and mdBook in sync. The decision for helper retirement is explicit: do not introduce a new one-off replacement
    helper for this pattern; use ordinary assignment, `is_nonempty(...)`, and `push(...)`.
  Commit: `SPEC-FORMAT-TERSE.8.2.1 - migrate EBNF nonempty append flow`; retained completion note: Live EBNF `push_nonempty(...)` use migrated to explicit assignment + `is_nonempty(...)` + `push(...)`; generated EBNF oracle inputs and mdBook walkthrough now match the shipped spec, with oracle expected output unchanged.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-FORMAT-TERSE --id SPEC-FORMAT-TERSE.8.2.1`.

- ID: `SPEC-FORMAT-TERSE.8.2.2`
  Status: `done`
  Goal: Migrate incidental legacy helper spellings in active Rust/Perl tests and generated corpus fixtures while
    preserving only explicit legacy/diagnostic assertions for the retirement leaves.
  Acceptance: Active tests that are not asserting legacy compatibility use `push(...)`/`+=`, `copy(...)`, `cat(...)`,
    assignments, direct shapes, and current wrappers. Remaining old-helper test strings are annotated as
    compatibility or retired-diagnostic locks owned by `.8.3`/`.8.4`.
  Commit: `SPEC-FORMAT-TERSE.8.2.2.5 - close active test corpus helper residue`
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-FORMAT-TERSE --id SPEC-FORMAT-TERSE.8.2.2`.

- ID: `SPEC-FORMAT-TERSE.8.2.2.1`
  Status: `done`
  Goal: Migrate incidental legacy helper spellings in `rust/linkedspec-runtime/tests/source_emitter.rs`.
  Acceptance: Source-emitter proof specs use current-surface helper spellings for aggregate initialization,
    appends, aggregate copies, and string concatenation. The source-emitter test suite still compiles generated
    Rust parsers and preserves the asserted JSON payloads.
  Commit: `SPEC-FORMAT-TERSE.8.2.2.1 - migrate source-emitter helper fixtures`; retained completion note: Rust source-emitter smoke specs use current helper spellings and explicit aggregate resets; focused residue scan is clean and generated-source compile/run tests pass.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-FORMAT-TERSE --id SPEC-FORMAT-TERSE.8.2.2.1`.

- ID: `SPEC-FORMAT-TERSE.8.2.2.2`
  Status: `done`
  Goal: Migrate or classify legacy helper spellings in active Rust integration-test strings.
  Acceptance: Incidental setup grammars use current-surface spellings. Intentional compatibility and retired
    diagnostic locks remain explicit and are annotated with their owning retirement leaves.
  Commit: `SPEC-FORMAT-TERSE.8.2.2.2.5 - classify integration helper residue`
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-FORMAT-TERSE --id SPEC-FORMAT-TERSE.8.2.2.2`.

- ID: `SPEC-FORMAT-TERSE.8.2.2.2.1`
  Status: `done`
  Goal: Migrate non-compatibility Rust integration smoke fixtures before the explicit legacy-alias blocks.
  Acceptance: The top-level smoke spec, user-function smoke helpers, corpus/lifecycle/edge smoke tests, `retv_5_1`
    tests, and `match_5_2` tests use current helper spellings without changing asserted outputs. Explicit
    compatibility blocks and recursive declare-scope edge cases remain untouched for later children.
  Commit: `SPEC-FORMAT-TERSE.8.2.2.2.1 - migrate integration smoke helper fixtures`; retained completion note: Rust integration smoke fixtures before the recursive/compatibility blocks use current helper spellings; full integration test passes **172** tests.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-FORMAT-TERSE --id SPEC-FORMAT-TERSE.8.2.2.2.1`.

- ID: `SPEC-FORMAT-TERSE.8.2.2.2.2`
  Status: `done`
  Goal: Migrate or classify the TOP-RULE-AS-NORMAL recursive integration-test helper spellings.
  Acceptance: Recursive `sexpr` tests preserve the scoped declaration/aggregate semantics captured in existing
    Knowledge Map facts. Any retained old-helper spelling is explicitly tied to a compatibility or diagnostic owner.
  Commit: `SPEC-FORMAT-TERSE.8.2.2.2.2 - classify recursive helper fixtures`; retained completion note: TOP-RULE-AS-NORMAL recursive fixtures use current append/snapshot helpers; `declare(...)` remains an intentional Rust scoped-declaration compatibility lock for `.8.4` to resolve before hard retirement.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-FORMAT-TERSE --id SPEC-FORMAT-TERSE.8.2.2.2.2`.

- ID: `SPEC-FORMAT-TERSE.8.2.2.2.3`
  Status: `done`
  Goal: Migrate or annotate explicit legacy-helper compatibility/equivalence tests in Rust integration tests.
  Acceptance: Tests that prove old spellings equal current spellings are either converted to current-surface tests
    with equivalent coverage or annotated as intentional compatibility locks for `.8.3`/`.8.4` retirement.
  Commit: `SPEC-FORMAT-TERSE.8.2.2.2.3 - annotate legacy helper tests`; retained completion note: Explicit Rust legacy-helper compatibility/equivalence tests now use current-side helper spellings and label retained old-helper sides as `.8.4` hard-retirement locks.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-FORMAT-TERSE --id SPEC-FORMAT-TERSE.8.2.2.2.3`.

- ID: `SPEC-FORMAT-TERSE.8.2.2.2.4`
  Status: `done`
  Goal: Migrate later current-feature Rust integration fixtures that still carry incidental old-helper spellings.
  Acceptance: Current terse feature tests outside explicit compatibility blocks use `push(...)`/`+=`, `copy(...)`,
    `cat(...)`, and explicit aggregate setters where needed, with focused Rust test filters passing.
  Commit: `SPEC-FORMAT-TERSE.8.2.2.2.4 - migrate later integration fixtures`; retained completion note: Later current-feature Rust integration fixtures use current helper spellings where supported; hash receiver and wrapper-alias residue remains for `.8.2.2.2.5` classification.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-FORMAT-TERSE --id SPEC-FORMAT-TERSE.8.2.2.2.4`.

- ID: `SPEC-FORMAT-TERSE.8.2.2.2.5`
  Status: `done`
  Goal: Close Rust integration-test helper-string cleanup with a residue classification scan.
  Acceptance: Remaining old-helper strings in `integration_test.rs` are each either gone or classified as explicit
    compatibility/retirement locks before generated-corpus fixture migration starts.
  Commit: `SPEC-FORMAT-TERSE.8.2.2.2.5 - classify integration helper residue`; retained completion note: Remaining Rust integration-test helper-string hits are each classified under recursive scope, explicit legacy compatibility, current receiver-method surface, or wrapper-alias retirement ownership.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-FORMAT-TERSE --id SPEC-FORMAT-TERSE.8.2.2.2.5`.

- ID: `SPEC-FORMAT-TERSE.8.2.2.3`
  Status: `done`
  Goal: Migrate or classify legacy helper spellings in generated oracle corpus fixture inputs.
  Acceptance: Generated fixture inputs avoid incidental old-helper spellings where behavior is current-surface;
    remaining old-helper fixtures are tied to compatibility or retirement diagnostics with no oracle drift.
  Commit: `SPEC-FORMAT-TERSE.8.2.2.3 - migrate generated corpus helper fixtures`; retained completion note: Generated oracle corpus helper fixture inputs use current helper spellings where behavior is current-surface; retained residues are classified with no oracle expected-output drift.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-FORMAT-TERSE --id SPEC-FORMAT-TERSE.8.2.2.3`.

- ID: `SPEC-FORMAT-TERSE.8.2.2.4`
  Status: `done`
  Goal: Migrate or classify legacy helper spellings in Perl phase0 test strings.
  Acceptance: Perl regression strings that are not directly testing legacy compatibility use current-surface
    spellings, while remaining old-helper assertions are explicitly owned by the hard-retirement leaves.
  Commit: `SPEC-FORMAT-TERSE.8.2.2.4 - migrate Perl phase0 helper strings`; retained completion note: Perl phase0 fixture strings use current helper spellings where behavior is current-surface; retained old-helper strings are classified and full phase0 passes 1022 tests.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-FORMAT-TERSE --id SPEC-FORMAT-TERSE.8.2.2.4`.

- ID: `SPEC-FORMAT-TERSE.8.2.2.5`
  Status: `done`
  Goal: Close the active-test and corpus helper-string cleanup with focused residue scans.
  Acceptance: Rust/Perl active tests and generated corpus inputs are clean or each residual old-helper spelling is
    classified as an intentional compatibility or retired-diagnostic lock before `.8.2.3`.
  Commit: `SPEC-FORMAT-TERSE.8.2.2.5 - close active test corpus helper residue`; retained completion note: Active-test/corpus helper residue scans are clean or classified; Rust integration wrapper-alias residue is labelled and `.8.2.2` closes.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-FORMAT-TERSE --id SPEC-FORMAT-TERSE.8.2.2.5`.

- ID: `SPEC-FORMAT-TERSE.8.2.3`
  Status: `done`
  Goal: Migrate current-facing mdBook and Knowledge Map helper references away from the old helper spellings before
    implementation removal.
  Acceptance: Current-facing docs teach `cat(...)`, `copy(...)`, assignments, `push(...)`, and explicit
    `if(is_nonempty(value)) { push(...) }` filtering first. Legacy names appear only in historical compatibility or
    retired-diagnostic sections, and Knowledge fact-card `reverify` commands avoid removed spellings unless they
    explicitly prove retirement.
  Commit: `SPEC-FORMAT-TERSE.8.2.3 - migrate book and knowledge helper references`
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-FORMAT-TERSE --id SPEC-FORMAT-TERSE.8.2.3`.

- ID: `SPEC-FORMAT-TERSE.8.2.4`
  Status: `done`
  Goal: Close the migration parent with focused scans and regenerated artifacts before hard retirement.
  Acceptance: Current-source/test/corpus/doc/KM scans are clean or each residual old-helper spelling is tied to a
    pending hard-retirement diagnostic. Oracle generation, corpus oracle, mdBook, doctrine checks, and focused
    phase0/Rust checks pass.
  Commit: `SPEC-FORMAT-TERSE.8.2.4 - close helper migration no-drift gates`
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-FORMAT-TERSE --id SPEC-FORMAT-TERSE.8.2.4`.

- ID: `SPEC-FORMAT-TERSE.8.3`
  Status: `done` (2026-07-06)
  Goal: Hard-retire Perl reference support for still-successful legacy helper spellings after `.8.2` migration.
  Acceptance: Perl lowering no longer successfully recognizes `declare(...)`/declaration aliases, `concat(...)`,
    `array_copy(...)`, `hash_copy(...)`, `push_value(...)`, or `push_nonempty(...)` as current helper spellings;
    retired uses produce explicit diagnostics or remain raw only in negative tests. Current terse replacements keep
    behavior.
  Commit: `SPEC-FORMAT-TERSE.8.3 - hard-retire Perl legacy helpers`; retained completion note: Perl legacy helper spellings now diagnose instead of lowering successfully; current terse replacements keep behavior; frontier becomes `.8.4`.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-FORMAT-TERSE --id SPEC-FORMAT-TERSE.8.3`.

- ID: `SPEC-FORMAT-TERSE.8.4`
  Status: `done` (2026-07-07)
  Goal: Hard-retire Rust parser/runtime support for legacy helper spellings after `.8.2` migration.
  Acceptance: Rust no longer executes `declare`, `array_copy`, `hash_copy`, `concat`, `push_value`,
    `push_nonempty`, or wrapper aliases `a(...)`/`h(...)` as successful current helper spellings; current terse
    replacements keep corpus parity. The recursive TOP-RULE-AS-NORMAL accumulator boundary found in
    `.8.2.2.2.2` must be resolved here before `declare(...)` removal: either Rust gains current-surface
    rule-invocation scoping for undeclared recursive accumulators or retired declaration use produces an explicit
    diagnostic with replacement guidance.
  Commit: `SPEC-FORMAT-TERSE.8.4 - hard-retire Rust legacy helpers`
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-FORMAT-TERSE --id SPEC-FORMAT-TERSE.8.4`.

- ID: `SPEC-FORMAT-TERSE.8.5`
  Status: `done`
  Goal: Reconcile user-facing docs, helper catalog, Knowledge facts, roadmap/live docs, and diagnostics after Perl
    and Rust legacy helper retirement.
  Acceptance: Current-facing docs and fact-card `reverify` commands describe only supported terse helper spellings;
    legacy names appear only in historical records or retired-diagnostic guidance.
  Commit: `SPEC-FORMAT-TERSE.8.5 - reconcile helper retirement docs`
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-FORMAT-TERSE --id SPEC-FORMAT-TERSE.8.5`.

- ID: `SPEC-FORMAT-TERSE.8.6`
  Status: `done`
  Goal: Final no-drift closeout for legacy helper retirement.
  Acceptance: Stale legacy-helper scans across current specs/corpora/docs/tests/KM/code pass, oracle corpus and
    mdBook stay in sync, and the next frontier advances to `.9`.
  Commit: `SPEC-FORMAT-TERSE.8.6 - close helper retirement no-drift`
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-FORMAT-TERSE --id SPEC-FORMAT-TERSE.8.6`.

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
  Commit: `SPEC-FORMAT-TERSE.9.6 - close hash literal colon drift`
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-FORMAT-TERSE --id SPEC-FORMAT-TERSE.9`.

- ID: `SPEC-FORMAT-TERSE.9.1`
  Status: `done` (2026-07-07)
  Goal: Audit/split the hash-literal `=>` to `:` migration surface before parser/runtime changes.
  Acceptance: Current `=>` occurrences are classified by owner (blind-call edge syntax, direct hash-literal syntax,
    shipped non-ActionIR grammars such as VHDL associations, docs/KM historical material, tests/oracle fixtures,
    parser/runtime support sites). The implementation sequence is split so blind-call `=>` remains valid while
    hash-literal association migrates to colon syntax, and `.9.2`+ descendants have clear acceptance boundaries.
  Commit: `SPEC-FORMAT-TERSE.9.1 - split hash literal colon migration`
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-FORMAT-TERSE --id SPEC-FORMAT-TERSE.9.1`.

- ID: `SPEC-FORMAT-TERSE.9.2`
  Status: `done` (2026-07-07)
  Goal: Add Perl reference support for colon hash-literal association while keeping old `=>` available only for the
    migration window.
  Acceptance: Perl ActionIR AST parsing/lowering accepts `{ key : value }`, quoted keys, nested colon hash
    literals, direct RHS assignment, mutation RHS values, expression-valued assignment forms, and block-vs-hash
    precedence without disturbing blind-call edges.
  Commit: `SPEC-FORMAT-TERSE.9.2 - add Perl colon hash literals`; retained completion note: Perl reference accepts `{ key : value }` hash-literal association during the migration window, preserves old `=>` until hard retirement, keeps generated Perl host fat arrows internal, and advances the frontier to `.9.3` Rust parity.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-FORMAT-TERSE --id SPEC-FORMAT-TERSE.9.2`.

- ID: `SPEC-FORMAT-TERSE.9.3`
  Status: `done` (2026-07-07)
  Goal: Add Rust parser/runtime parity for colon hash-literal association.
  Acceptance: Rust parses/evaluates the same colon hash-literal forms as Perl, including nested shapes, direct RHS
    assignment, mutation RHS values, expression-valued assignment forms, receiver chains, and block-vs-hash
    precedence, while blind-call `=>` remains edge syntax.
  Commit: `SPEC-FORMAT-TERSE.9.3 - add Rust colon hash literals`; retained completion note: Rust parser/runtime accepts `{ key : value }` hash-literal association during the migration window, preserves old `=>` until hard retirement, keeps blind-call edge `=>` separate, and advances the frontier to `.9.4` current-source/docs/corpus migration.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-FORMAT-TERSE --id SPEC-FORMAT-TERSE.9.3`.

- ID: `SPEC-FORMAT-TERSE.9.4`
  Status: `done` (2026-07-07)
  Goal: Migrate current specs, generated oracle fixtures, active tests, mdBook examples, root docs, and current
    Knowledge facts from hash-literal `=>` to `:`.
  Acceptance: Current-facing `.spec` authoring examples and generated oracle inputs use `{ key : value }` where
    they mean direct hash-literal association. Remaining `=>` occurrences are blind-call edge syntax, non-ActionIR
    grammar payloads, or explicitly historical/retirement material.
  Commit: `SPEC-FORMAT-TERSE.9.4 - migrate hash literals to colon`; retained completion note: Current specs/corpus/docs/KM/tests now prefer `{ key : value }`; classified `=>` owners remain for blind-call edges, source-language associations, generated Perl host output, metadata, history, and explicit compatibility locks; frontier advances to `.9.5` hard retirement.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-FORMAT-TERSE --id SPEC-FORMAT-TERSE.9.4`.

- ID: `SPEC-FORMAT-TERSE.9.5`
  Status: `done` (2026-07-07)
  Goal: Hard-retire old hash-literal `=>` association from current Perl/Rust ActionIR value syntax.
  Acceptance: `{ key => value }` no longer parses/evaluates as a current hash-literal association in Perl or Rust
    ActionIR value positions; diagnostics point to `{ key : value }`. Blind-call `=> Rule` edge syntax and
    non-ActionIR grammar payloads remain valid.
  Commit: `SPEC-FORMAT-TERSE.9.5 - retire hash literal fat arrows`; retained completion note: Perl/Rust now reject old `{ key => value }` as current ActionIR hash-literal syntax, point diagnostics to `{ key : value }`, keep blind-call edge `=>` separate, and advance the frontier to `.9.6` final no-drift closeout.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-FORMAT-TERSE --id SPEC-FORMAT-TERSE.9.5`.

- ID: `SPEC-FORMAT-TERSE.9.6`
  Status: `done` (2026-07-07)
  Goal: Final no-drift closeout for hash-literal colon association.
  Acceptance: Scans across current specs/corpora/docs/tests/KM/code show no unclassified current hash-literal `=>`
    usage, generated oracle fixtures and Rust corpus oracle stay in sync, mdBook documents `:` as the current
    hash-literal separator, and the frontier advances past `.9`.
  Commit: `SPEC-FORMAT-TERSE.9.6 - close hash literal colon drift`; retained completion note: Final no-drift scans classify all remaining `=>` owners, mdBook documents `:` as current and old hash-literal fat arrows only as retired, oracle generation/Rust corpus oracle/full phase0 pass, and `.9` closes with no PNT-eligible child remaining.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-FORMAT-TERSE --id SPEC-FORMAT-TERSE.9.6`.

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
  Commit: `SPEC-FORMAT-TERSE.10.1 - ratify dynamic hash-literal keys`
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-FORMAT-TERSE --id SPEC-FORMAT-TERSE.10`.

- ID: `SPEC-FORMAT-TERSE.10.1`
  Status: `done` (2026-07-08)
  Goal: Reactivate `.10`, audit the current direct hash-literal key behavior, and close it as an explicit
    spec contract without parser/runtime changes if the existing behavior is already intentional and documented.
  Acceptance: The task tree records whether dynamic/computed keys are accepted or dropped; mdBook explains the
    accepted key-expression contract and fixed-key quoting rule; a Knowledge fact gives future sessions the
    answer and reverify command; live docs point to the next `SPEC-FORMAT-TERSE` frontier; no parser/runtime
    behavior changes are made in this spec-ratification slice.
  Commit: `SPEC-FORMAT-TERSE.10.1 - ratify dynamic hash-literal keys`; retained completion note: Direct hash literals are explicitly expression-keyed: bare keys are scalar reads, quoted keys are fixed strings, and computed helper expressions may supply keys. No parser/runtime behavior changed; `.10` is closed.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-FORMAT-TERSE --id SPEC-FORMAT-TERSE.10.1`.

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
  Commit: closed by child commits through `SPEC-FORMAT-TERSE.11.5 - close duck-typed assignment alignment`
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-FORMAT-TERSE --id SPEC-FORMAT-TERSE.11`.

- ID: `SPEC-FORMAT-TERSE.11.1`
  Status: `done` (2026-07-05)
  Goal: Split duck-typed assignment implementation after full bootstrap/code/book inventory and toolbox probes.
  Acceptance: Before code, identify the exact current drift from the `.11` contract, split the implementation into
    signoff-sized children, and record the dirty-work boundary so later commits do not mix unrelated helper-removal
    work with assignment semantics.
  Commit: `SPEC-FORMAT-TERSE.11.1 - split duck-typed assignment work`; retained completion note: Split duck-typed assignment after bootstrap, code/book/KM inventory, and toolbox probes; frontier became `.11.2`.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-FORMAT-TERSE --id SPEC-FORMAT-TERSE.11.1`.

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
  Commit: `SPEC-FORMAT-TERSE.11.2 - implement Perl duck-typed assignment binding`; retained completion note: Perl reference bare assignment now binds typed RHS values through scalar storage; explicit aggregate targets remain aggregate storage; frontier became `.11.3`.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-FORMAT-TERSE --id SPEC-FORMAT-TERSE.11.2`.

- ID: `SPEC-FORMAT-TERSE.11.3`
  Status: `done` (2026-07-05)
  Goal: Rust runtime parity for duck-typed assignment and bare variable value reads.
  Acceptance: Rust `Expr::AssignScalar` and `set`/`=` helper execution bind the evaluated `RuntimeValue` to the
    named variable without retagging bare targets from direct RHS shape. Later assignments may replace a scalar
    with an array/hash value and vice versa. Rust integration and oracle fixtures must replace the old
    `.1.2.3.5.4` target-kind inference expectations.
  Commit: `SPEC-FORMAT-TERSE.11.3 - implement Rust duck-typed assignment parity`; retained completion note: Rust now scalar-binds bare assignment RHS values, including direct array/hash shapes, and keeps explicit `array(...)` / `hash(...)` targets as aggregate storage. Oracle corpus is 91 fixtures; frontier becomes `.11.4`.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-FORMAT-TERSE --id SPEC-FORMAT-TERSE.11.3`.

- ID: `SPEC-FORMAT-TERSE.11.4`
  Status: `done` (2026-07-05)
  Goal: Specify and implement nested mixed array/hash value-path reads and writes.
  Acceptance: Nested paths through duck-typed values support arbitrary hash-then-array, array-then-hash, and longer
    mixed read/write combinations in statement and expression-valued assignment contexts. Missing intermediate
    containers, wrong-shape transitions, array index extension, and hash key creation are specified in LinkedSpec
    terms and covered on Perl/Rust without accidentally inheriting Perl autovivification semantics.
  Commit: `SPEC-FORMAT-TERSE.11.4 - implement nested value-path assignment`; retained completion note: Nested mixed direct-access writes now mutate scalar-held array/hash value trees on Perl/Rust with explicit no-autovivification path guards; oracle corpus is 92 fixtures; frontier becomes `.11.5`.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-FORMAT-TERSE --id SPEC-FORMAT-TERSE.11.4`.

- ID: `SPEC-FORMAT-TERSE.11.5`
  Status: `done` (2026-07-05)
  Goal: Close duck-typed assignment documentation, Knowledge Map, corpus/oracle, and mdBook alignment.
  Acceptance: Active tests, generated oracle fixtures, mdBook chapters, helper catalog, live docs, and current
    Knowledge Map facts describe assignment as typed value binding, not Perl storage-class inference. Historical
    task/changelog references may remain historical; current-facing guidance must not teach direct RHS shape as
    declaration or target-kind inference. Coordinate examples with `.9` if hash-literal colon syntax has landed.
  Commit: `SPEC-FORMAT-TERSE.11.5 - close duck-typed assignment alignment`; retained completion note: Roadmap/current docs and Knowledge Map retrieval now present typed value binding as current behavior and target-kind inference as superseded history; `.11` closes and frontier becomes `.15`.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-FORMAT-TERSE --id SPEC-FORMAT-TERSE.11.5`.

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
  Commit: `pending`
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-FORMAT-TERSE --id SPEC-FORMAT-TERSE.12`.

- ID: `SPEC-FORMAT-TERSE.12.1`
  Status: `done` (2026-07-08)
  Goal: Reactivate and split hash-tree attached-block traversal before implementation.
  Acceptance: Record the user reactivation, define the exact MVP method surface and semantics, split the
    implementation into signoff-sized Perl/Rust/docs leaves, update the live roadmap/index/resume docs, and commit
    this before parser/runtime code changes.
  Commit: `SPEC-FORMAT-TERSE.12.1 - activate hash-tree traversal split`; retained completion note: Reactivated `.12` by user directive and split hash-tree attached-block traversal into Perl, Rust/oracle, and docs/KM/no-drift leaves before parser/runtime code.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-FORMAT-TERSE --id SPEC-FORMAT-TERSE.12.1`.

- ID: `SPEC-FORMAT-TERSE.12.2`
  Status: `done` (2026-07-08)
  Goal: Perl reference implementation for hash-tree attached-block receiver methods.
  Acceptance: Perl ActionIR AST/lowering accepts receiver-form `.walk_leaves() { ... }`, `.map_leaves() { ... }`,
    and `.reduce_leaves(initial) { ... }` on hash-valued receivers; rejects malformed arity or missing blocks with
    explicit unsupported-helper diagnostics; binds/restores scoped `value`, `key`, `path`, `depth`, and `acc`
    according to the `.12` contract; uses sorted depth-first traversal; covers valid, empty, array-leaf,
    non-hash/wrong-shape, continuation, and side-effect cases in focused Perl tests.
  Commit: `SPEC-FORMAT-TERSE.12.2 - implement Perl hash-tree traversal`; retained completion note: Perl reference receiver attached-block traversal landed for `walk_leaves`, `map_leaves`, and `reduce_leaves(initial)` with sorted hash-tree leaf traversal, scoped callback bindings, malformed-call diagnostics, and phase0 `1..1027`; frontier becomes `.12.3` Rust parity.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-FORMAT-TERSE --id SPEC-FORMAT-TERSE.12.2`.

- ID: `SPEC-FORMAT-TERSE.12.3`
  Status: `done` (2026-07-08)
  Goal: Rust parser/runtime parity and generated oracle fixture for hash-tree traversal methods.
  Acceptance: Rust parses and executes the same receiver attached-block method surface as Perl; runtime results
    match Perl over generated oracle fixtures; focused Rust integration tests cover traversal order, scoped
    bindings/restoration, map/reduce/walk returns, array leaves, empty trees, non-hash/wrong-shape handling, and
    compatible receiver continuations.
  Commit: `SPEC-FORMAT-TERSE.12.3 - implement Rust hash-tree traversal`; retained completion note: Rust parser/runtime parity landed for `walk_leaves`, `map_leaves`, and `reduce_leaves(initial)` receiver attached blocks; generated oracle corpus is 96 fixtures with `terse_12_3_hash_tree_traversal_receiver_blocks`; frontier becomes `.12.4` docs/KM/no-drift closeout.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-FORMAT-TERSE --id SPEC-FORMAT-TERSE.12.3`.

- ID: `SPEC-FORMAT-TERSE.12.4`
  Status: `done` (2026-07-08)
  Goal: Close hash-tree traversal docs, Knowledge Map, oracle, and no-drift alignment.
  Acceptance: mdBook helper/reference/formal/backend-handoff pages document the shipped `.12` surface with
    examples; generated oracle corpus count and Knowledge Map facts are current; live docs and task-tree frontier
    mark `.12` exhausted; final scans find no current-facing drift in method names, callback bindings, or
    traversal semantics.
  Commit: `SPEC-FORMAT-TERSE.12.4 - close hash-tree traversal drift`; retained completion note: Final no-drift closeout verified mdBook, Knowledge Map, live docs, task-tree rows, roadmap/architecture state, and the 96-fixture oracle manifest; `.12` is exhausted. `.10` was later closed by `.10.1`; `.13` remains the next parked item under the exhaustion directive.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-FORMAT-TERSE --id SPEC-FORMAT-TERSE.12.4`.

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
  Commit: `SPEC-FORMAT-TERSE.13.4 - close array-tree traversal drift`
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-FORMAT-TERSE --id SPEC-FORMAT-TERSE.13`.

- ID: `SPEC-FORMAT-TERSE.13.1`
  Status: `done` (2026-07-08)
  Goal: Reactivate and split array-tree attached-block traversal before implementation.
  Acceptance: Record the user reactivation, define the exact MVP method surface and semantics, split the
    implementation into signoff-sized Perl/Rust/docs leaves, update live roadmap/index/resume docs, add a durable
    Knowledge fact for the accepted-but-not-yet-shipped contract, and commit this before parser/runtime code
    changes.
  Commit: `SPEC-FORMAT-TERSE.13.1 - split array-tree traversal`; retained completion note: Reactivated `.13` and split array-tree receiver block traversal into Perl, Rust/oracle, and docs/KM/no-drift leaves before parser/runtime code.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-FORMAT-TERSE --id SPEC-FORMAT-TERSE.13.1`.

- ID: `SPEC-FORMAT-TERSE.13.2`
  Status: `done` (2026-07-08)
  Goal: Perl reference implementation for array-tree attached-block receiver methods.
  Acceptance: Perl ActionIR AST/lowering accepts receiver-form `.walk_leaves() { ... }`, `.map_leaves() { ... }`,
    and `.reduce_leaves(initial) { ... }` on array-valued receivers; preserves existing hash-tree behavior on
    hash-valued receivers; rejects malformed arity or missing blocks with explicit unsupported-helper diagnostics;
    binds/restores scoped `value`, `index`, `path`, `depth`, and `acc` according to the `.13` contract; uses
    deterministic index-order traversal; covers valid, empty, hash-leaf, non-array, continuation, and side-effect
    cases in focused Perl tests.
  Commit: `SPEC-FORMAT-TERSE.13.2 - implement Perl array-tree traversal`; retained completion note: Perl reference lowering/runtime support landed for array-valued `walk_leaves`, `map_leaves`, and `reduce_leaves(initial)` receiver blocks while preserving hash-tree traversal behavior; the then-frontier moved to `.13.3`.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-FORMAT-TERSE --id SPEC-FORMAT-TERSE.13.2`.

- ID: `SPEC-FORMAT-TERSE.13.3`
  Status: `done` (2026-07-08)
  Goal: Rust parser/runtime parity and generated oracle fixture for array-tree traversal methods.
  Acceptance: Rust executes the same array-tree receiver attached-block method surface as Perl while preserving
    `.12` hash-tree behavior; runtime results match Perl over generated oracle fixtures; focused Rust tests cover
    traversal order, scoped binding restoration, map/reduce/walk returns, hash leaves, empty arrays, non-array
    handling, compatible array-family continuations, and malformed-call diagnostics.
  Commit: `SPEC-FORMAT-TERSE.13.3 - implement Rust array-tree traversal`; retained completion note: Rust parser/runtime parity landed for array-valued `walk_leaves`, `map_leaves`, and `reduce_leaves(initial)` receiver blocks while preserving hash-tree behavior; generated oracle corpus is 97 fixtures and the then-frontier moved to `.13.4` closeout.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-FORMAT-TERSE --id SPEC-FORMAT-TERSE.13.3`.

- ID: `SPEC-FORMAT-TERSE.13.4`
  Status: `done` (2026-07-08)
  Goal: Close array-tree traversal docs, Knowledge Map, oracle, and no-drift alignment.
  Acceptance: mdBook helper/reference/formal/backend-handoff pages document the shipped `.13` surface with
    examples; generated oracle corpus count and Knowledge Map facts are current; live docs and task-tree frontier
    mark `.13` exhausted; final scans find no current-facing drift in method names, callback bindings, traversal
    semantics, or corpus counts.
  Commit: `SPEC-FORMAT-TERSE.13.4 - close array-tree traversal drift`; retained completion note: Final no-drift closeout verified mdBook, Knowledge Map, live docs, task-tree rows, roadmap state, and the 97-fixture oracle manifest; `.13` is exhausted.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-FORMAT-TERSE --id SPEC-FORMAT-TERSE.13.4`.

- ID: `SPEC-FORMAT-TERSE.13.5`
  Status: `done` (2026-07-08)
  Goal: Reconcile the parent `SPEC-FORMAT-TERSE` task-tree status to closed after `.13.4` left no current
    PNT-eligible leaf.
  Acceptance: The central task-tree index, this task file's top metadata, current-frontier table, live docs,
    roadmap state, and Knowledge Map facts agree that `SPEC-FORMAT-TERSE` is closed; stale split-container
    `active` rows inside this task file are converted to historical closed/done wording; no parser/runtime,
    corpus, or mdBook behavioral semantics change.
  Commit: `SPEC-FORMAT-TERSE.13.5 - close parent terse task tree`; retained completion note: Metadata-only closeout reconciled the parent task tree and central index from active-with-empty-frontier to done/closed; no behavior changed.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-FORMAT-TERSE --id SPEC-FORMAT-TERSE.13.5`.

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
  Commit: `SPEC-FORMAT-TERSE.14.5 - close trailing block drift`
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-FORMAT-TERSE --id SPEC-FORMAT-TERSE.14`.

- ID: `SPEC-FORMAT-TERSE.14.1`
  Status: `done` (2026-07-07)
  Goal: Activate and split the trailing block-argument backlog item before implementation.
  Acceptance: The task tree defines the MVP block-argument contract, first callable surface, sequencing, diagnostics,
    and verification expectations before parser/runtime code changes.
  Commit: `SPEC-FORMAT-TERSE.14.1 - activate trailing block-argument plan`
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-FORMAT-TERSE --id SPEC-FORMAT-TERSE.14.1`.

- ID: `SPEC-FORMAT-TERSE.14.2`
  Status: `done` (2026-07-07)
  Goal: Implement Perl reference helper-function form trailing block arguments for `with(value) { ... }`.
  Acceptance: Perl ActionIR parsing/lowering recognizes `with(value) { ... }` and `with() { ... }` as a helper call
    with a final block argument, lowers it without raw fallback, binds/restores the scoped `value` context variable,
    keeps block-local return semantics, and preserves hash-literal parsing. Focused parser/lowering/runtime tests
    prove `with("x") { return(cat(value, "!")) }` returns `"x!"`, `with() { return(is_undefined(value)) }` returns
    true, and `{ key : value }` remains a hash literal.
  Commit: `SPEC-FORMAT-TERSE.14.2 - add Perl helper trailing blocks`
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-FORMAT-TERSE --id SPEC-FORMAT-TERSE.14.2`.

- ID: `SPEC-FORMAT-TERSE.14.3`
  Status: `done` (completed 2026-07-07)
  Goal: Implement Rust helper-function form parity for `with(value) { ... }`.
  Acceptance: Rust parser/runtime recognizes the same helper-function form trailing block syntax and semantics as the Perl
    reference, including scoped `value` binding/restoration, block-local return behavior, zero-arg `with()`, and
    hash-literal boundary preservation. Add a generated oracle fixture and focused Rust parser/runtime tests.
  Commit: `SPEC-FORMAT-TERSE.14.3 - add Rust helper trailing blocks`
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-FORMAT-TERSE --id SPEC-FORMAT-TERSE.14.3`.

- ID: `SPEC-FORMAT-TERSE.14.4`
  Status: `done` (completed 2026-07-07)
  Goal: Implement receiver-form trailing block arguments for `.with() { ... }` on compatible value receivers.
  Acceptance: Perl and Rust receiver chains accept a terminal or continuing `.with() { ... }` segment where the
    receiver value is exposed as scoped `value` inside the block. The returned block value feeds later compatible
    receiver-family links or acts as the terminal expression result. Non-final block arguments inside an ordinary
    argument list remain rejected/deferred.
  Commit: `SPEC-FORMAT-TERSE.14.4 - add receiver trailing blocks`
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-FORMAT-TERSE --id SPEC-FORMAT-TERSE.14.4`.

- ID: `SPEC-FORMAT-TERSE.14.5`
  Status: `done` (completed 2026-07-07)
  Goal: Close trailing block-argument docs, mdBook, Knowledge Map, oracle, and no-drift alignment.
  Acceptance: mdBook documents the shipped helper-function and receiver-method `with` block-argument surface with worked examples,
    explicitly states what remains deferred, active tests and generated oracle fixtures are current, Knowledge Map
    retrieval records the durable syntax/semantics fact, and roadmap/task-tree/live docs agree on `.14` status.
  Commit: `SPEC-FORMAT-TERSE.14.5 - close trailing block drift`; retained completion note: Final no-drift closeout for helper-function and receiver-method `with` trailing blocks; roadmap/mdBook/KM/live docs/task-tree/oracle agree and `.14` closes.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-FORMAT-TERSE --id SPEC-FORMAT-TERSE.14.5`.

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
  Commit: `SPEC-FORMAT-TERSE.15.5 - close colon scalar-slot drift`
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-FORMAT-TERSE --id SPEC-FORMAT-TERSE.15`.

- ID: `SPEC-FORMAT-TERSE.15.1`
  Status: `done` (2026-07-05)
  Goal: Audit colon-prefixed scalar-slot usage and split safe implementation leaves before code.
  Acceptance: Inventory current `:name` use in shipped specs, root corpus examples, Rust oracle fixtures, active
    Perl/Rust tests, parser/lowering/runtime support, mdBook, and Knowledge Map facts. Split follow-on work if
    blast radius is larger than one safe slice.
  Commit: `SPEC-FORMAT-TERSE.15.1 - split colon scalar-slot removal`; retained completion note: Audit/split only: `:name` removal spans specs, corpus, oracle fixtures, mdBook, Knowledge Map facts, tests, generator sources, and Perl/Rust parser/runtime support. Frontier becomes `.15.2` for current-facing migration.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-FORMAT-TERSE --id SPEC-FORMAT-TERSE.15.1`.

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
  Children: `.15.2.1` (design/inventory, DONE 2026-07-05), `.15.2.2` (Perl engine impl, DONE 2026-07-05),
    `.15.2.3` (Rust parity, DONE 2026-07-06), `.15.2.4` (source migration to bare, DONE 2026-07-06).
  Acceptance: bare reads produce byte-identical reference output to today's `:name` in every value position on
    Perl and Rust and the value-position-vs-edge policy is documented; then all current shipped specs, root
    corpus, generated oracle sources, mdBook examples, and non-historical Knowledge Map facts use bare reads with
    a byte-identical regenerated oracle corpus and green phase0.
  Commit: `SPEC-FORMAT-TERSE.15.2 - reorder .15 to engine-first (bare-read gap)`; prior node reference: `SPEC-FORMAT-TERSE.15.2.4 - migrate current sources to bare reads`; table label: `SPEC-FORMAT-TERSE.15.2 re-scope`; retained completion note: Recovery + finding: prior uncommitted mess preserved on `recovery/terse-15-uncommitted-20260705`; proved bare reads are not honored in all value positions at `104088e5`, so `.15.2` is re-sequenced engine-first (`.15.2.1`-`.15.2.4`) and `.15.3`/`.15.4` remove `:name` with no compat. No engine/source behavior changed. Frontier becomes `.15.2.1`.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-FORMAT-TERSE --id SPEC-FORMAT-TERSE.15.2`.

- ID: `SPEC-FORMAT-TERSE.15.2.1`
  Status: `done` (2026-07-05)
  Goal: Inventory every value position where a bare identifier is NOT read as the bound variable today while
    `:name` is (Perl + Rust), and lock the value-position-is-variable-read policy and the edge/child-call
    rule-reference boundary before any engine code.
  Acceptance: A complete list of failing positions with reference-engine evidence (e.g. `switch(:kind)`->`good`
    vs `switch(kind)`->`def`), the collision cases in `spec.spec`/`ebnf.spec`, the Perl lowering seams
    (`ActionIR::MethodLowering`/`ValueExpr`/`FlowExpr`/`ControlFlow`) and Rust parser/runtime seams that must
    change, and the documented policy. No engine behavior changes in this leaf.
  Commit: `pending`
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-FORMAT-TERSE --id SPEC-FORMAT-TERSE.15.2.1`.

- ID: `SPEC-FORMAT-TERSE.15.2.2`
  Status: `done` (2026-07-05)
  Goal: Perl reference — make bare identifiers read the bound typed value in every value position enumerated by
    `.15.2.1`, with rule references confined to edge/dispatch positions. `:name` keeps working (compat) during
    this transition.
  Acceptance: focused reference-engine probes show bare == `:name` output for every enumerated position; phase0
    stays green (1021 pass plus the one pre-existing unrelated `emit_context_lowers_split_tagged_records_helper`
    failure).
  Commit: `pending`
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-FORMAT-TERSE --id SPEC-FORMAT-TERSE.15.2.2`.

- ID: `SPEC-FORMAT-TERSE.15.2.3`
  Status: `done` (2026-07-06)
  Goal: Rust parity for `.15.2.2` — bare reads in all value positions, same value-position-is-variable policy,
    `:name` still parses during the transition.
  Acceptance: Rust oracle fixtures for the enumerated positions pass with bare reads; `cargo` corpus oracle green.
    If the regenerated corpus exposes pre-existing source drift that blocks the oracle from testing Rust parity,
    the same leaf owns the minimal source correction plus a durable finding, because `.15.2.3` cannot close with
    a red oracle.
  Commit: `SPEC-FORMAT-TERSE.15.2.3 - align Rust bare-read switch parity`; prior node reference: `pending`; retained completion note: Rust bare value reads now match Perl in switch/num/if positions while bare case labels remain literal; inline Perl switch case labels were aligned; `specs/spec.spec` aggregate initialization corrected; corpus oracle is 93 fixtures; frontier becomes `.15.2.4`.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-FORMAT-TERSE --id SPEC-FORMAT-TERSE.15.2.3`.

- ID: `SPEC-FORMAT-TERSE.15.2.4`
  Status: `done` (2026-07-06)
  Goal: Migrate current shipped specs, root corpus, generated oracle sources, mdBook examples, and
    non-historical Knowledge Map facts from `:name` to bare reads, now output-preserving because the engine reads
    bare everywhere.
  Acceptance: zero `:name` in current sources (historical records excepted); regenerated oracle corpus is
    byte-identical (`expected.json` unchanged); phase0 green; `cargo` corpus oracle green; mdBook builds.
  Commit: `SPEC-FORMAT-TERSE.15.2.4 - migrate current sources to bare reads`; retained completion note: Current specs/corpus/oracle/mdBook/KM surfaces use bare reads instead of live `:name`; oracle expected JSON stayed unchanged over 93 fixtures; frontier becomes `.15.3`.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-FORMAT-TERSE --id SPEC-FORMAT-TERSE.15.2.4`.

- ID: `SPEC-FORMAT-TERSE.15.3`
  Status: `done` (2026-07-06)
  Goal: Remove Perl reference `:name` scalar-slot parsing/lowering ENTIRELY (user directive 2026-07-05: `:name`
    shall NOT be supported). No compatibility retention.
  Acceptance: `:name` in a value position becomes a parse/lowering error carrying a bare-read migration
    diagnostic; no current test depends on `:name`; bare names remain valid value reads in all value positions
    (guaranteed by `.15.2.2`), and hash-literal key token behavior is unchanged.
  Commit: `SPEC-FORMAT-TERSE.15.3 - retire Perl colon scalar slots`; retained completion note: Perl `:name` now emits a retired colon-slot diagnostic sentinel instead of a successful scalar read/target; `scalar_slot_fallback` is gone; active Perl tests/fixtures use bare reads; full phase0 passes; frontier becomes `.15.4`.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-FORMAT-TERSE --id SPEC-FORMAT-TERSE.15.3`.

- ID: `SPEC-FORMAT-TERSE.15.4`
  Status: `done` (2026-07-06)
  Goal: Remove Rust `Expr::ScalarSlot` parsing/runtime support ENTIRELY (user directive 2026-07-05: `:name` shall
    NOT be supported). No compatibility retention.
  Acceptance: the Rust `:name` value primary is deleted and produces a bare-read migration diagnostic; parser/
    runtime/source-emitter tests no longer depend on `:name`; current oracle fixtures pass with bare reads (via
    `.15.2.3`); bare names and hash-literal key boundaries remain correct.
  Commit: `SPEC-FORMAT-TERSE.15.4 - retire Rust colon scalar slots`; retained completion note: Rust `Expr::ScalarSlot` parser/runtime/source-emitter support is gone; retired colon scalar slots emit the bare-read migration diagnostic; active Rust fixtures and oracle corpus use bare reads; frontier becomes `.15.5`.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-FORMAT-TERSE --id SPEC-FORMAT-TERSE.15.4`.

- ID: `SPEC-FORMAT-TERSE.15.5`
  Status: `done` (2026-07-06)
  Goal: Final no-drift closeout for colon scalar-slot removal.
  Acceptance: Stale `:name` scans across current specs/corpora/docs/tests/KM pass, mdBook and oracle corpus are in
    sync, task-tree/live docs record the new surface, and the next frontier advances to `.8` / `.9` as appropriate.
  Commit: `SPEC-FORMAT-TERSE.15.5 - close colon scalar-slot drift`; retained completion note: Final no-drift closeout: stale current-surface scans pass; two stale Knowledge fact-card colon examples corrected; oracle corpus, mdBook, Knowledge Map, memory/doctrine checks, and phase0 pass; `.15` closes and frontier becomes `.8`.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-FORMAT-TERSE --id SPEC-FORMAT-TERSE.15.5`.

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

## Historical narrative

Exact predecessor: `python3 tools/read_task_narrative.py --tree SPEC-FORMAT-TERSE --all`.
