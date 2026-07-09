# Project Status

LinkedSpec is an actively evolving system. The current direction is not “freeze everything exactly as it once was.” The direction is to preserve the strengths that make LinkedSpec useful while modernizing the runtime, compiler, diagnostics, and documentation.

LinkedSpec is also a multi-backend system. The `.spec` language is the one universal contract; each backend is an execution platform that runs the same `.spec` files with identical semantics. The Perl implementation is the **reference backend** (the canonical behavioral oracle), and a Rust backend is the second execution platform. ADR 0021 schedules future full-parity backend work as Dart first, Julia second, and Lua third. Status below is therefore stated at the `.spec`-contract level, with backend-specific notes called out where they apply.

## Completed phases

Phases 0–9 of the modernization roadmap are done:

- **Phase 0**: Regression safety net — `t/phase0_regression.t` covers all 21 shipped specs with a green `1028`-test baseline; every `.spec` compiles at `language_agnostic_ready_ratio == 1.0000` (zero compatibility-surface rules).
- **Phase 1**: Thin facade + owner dispatch — `LinkedSpec.pm` is a lazy public facade over owner modules that route through uniform `OwnerDispatch`; the former `ActionRewriter.pm` forwarding shim was deleted (118 lines).
- **Phase 1A**: Thin-façade modularization — `LinkedSpec.pm` delegated into focused owner modules (`Trace`, `Validation`, `Resolver`, `Runtime`, `Compiler`, `BootstrapSpec`, `SpecEntry`, `RuleIR`, `EmitContext`); the shared `OwnerDispatch` seam replaced per-owner lazy-loading wrappers.
- **Phase 2**: DSL frontend hardening — rule-label parsing, inside-block rejection, extra-colon rejection, fluent-continuation recognition, `strict_syntax` mode, construct-recognition alignment with bootstrap grammar.
- **Phase 3**: Execution semantics — seek/consume parse modes documented; explicit cursor controls are local cursor operations, not systemic backtracking; forward-moving non-backtracking model stated.
- **Phase 4**: Capture/mark API — 163 contracts across 6 families verified, compat aliases documented, mark-helper reference complete.
- **Phase 5**: Runtime diagnostics — structured last_error is the single diagnostics channel; handler compile warnings routed through trace instead of stderr; eval minimized to one handler compilation; trace bridging from compile scopes into runtime handler scopes.
- **Phase 6**: Documentation and adoption — the book you are reading. All identified documentation gaps closed (LinkedRE, Validation, public API, cross-linking, overviews, ActionIR lowering, per-spec walkthroughs).
- **Phase 7**: Self-hosted `spec.spec` grammar — LinkedSpec parses its own `.spec` language through the DSL itself. `spec.spec` compiles at `language_agnostic_ready_ratio == 1.0000` with regression coverage; it is the required change surface for `.spec` language evolution.
- **Phase 8**: Multi-backend specification and handoff — the `.spec` language, runtime semantics, helper contracts, and HandlerIR are specified backend-neutrally, so a backend can be built in any language without reading the reference source. The multi-backend vision — the same `.spec` files, the same semantics, and the same test corpus across all backends — is recorded in ADR 0006. This phase was specification-only (no behavioral code change).
- **Phase 9**: Rust variant — a second execution backend. The Rust workspace (`rust/`: `linkedspec-core` + `linkedspec-runtime`) carries its own `.spec` parser, compiler, runtime engine, and helper surface, and runs `.spec` files compiled from the same universal contract. It is operational in interpreted mode, and the current manifest-backed Rust oracle is green over 99 fixtures plus manifest drift guards. The generated-source path proves direct execution for the current structural families plus a curated manifest-backed corpus subset.

The active Dart backend follows the same interpreter-first path. It now has source parsing, validation,
compiled-spec state, runtime interpretation, staged user-function body parsing, exact-arity user-function runtime
execution, and a controlled executable corpus harness whose first 40 shipped manifest fixtures plus the non-`fn`
middle helper/control/receiver fixtures pass through bounded execute mode. The final shipped-spec/parser-smoke
window is measured and split for regex-dialect, helper/action, recursion/output, and residual parity work. Basic
Dart regex-dialect bridging is now in place for POSIX character classes, inline/scoped flags, possessive
quantifier markers, lower-bound `{,n}` quantifiers, and Python-style named captures. Scoped flag groups are accepted
by lifting their options to Dart `RegExp`. The missing helper/action bridge is also in place for direct
capture-slice helpers, diagnostic output helpers, logical helpers, `exit_now`, and quoted helper-call delimiter
parsing. Dart now also resolves tclite-style action-edge regex dispatch and scopes explicit aggregate resets per
rule invocation, so the tclite and recursive top-rule parser-smoke fixtures pass. Deeper PCRE structural
constructs remain split follow-up work. Full shipped 99-fixture corpus parity is still in progress.

The Method-like DSL migration track is also complete: all 21 shipped specs are at zero compatibility-surface rules, 100+ helpers across 10 families are regression-locked, current helper names are the only documented helper surface, and fluent/block equivalence is verified. Current setup and read forms use direct assignments, `set(...)`, bare scalar reads, `array(...)`, `hash(...)`, `push(...)`, `copy(...)`, and `return(...)`. Unknown typed calls in return/value positions diagnose through the generic unknown-helper path instead of emitting generated host-language calls, while unregistered standalone function-shaped statements remain explicit raw compatibility debt. Top-level `fn name(args) { ... }` definition shells are parsed by `specs/user_function_definition.spec` and projected through the active user-function registry, with params, arity, source/body spans, body source, neutral `body_payload`, neutral `body_parse_job`, and body AST recorded. The parse-job sidecar now dispatches through the minimal staged registry provider for `actionir-body.spec` / `action_block`, and the returned `action_block` AST is stitched into `body_ast`; general public `parse_job(...)` authoring remains future work. On Perl, Rust, and Dart, registered exact-arity user-function calls now execute in value positions, compatible receiver chains, and standalone discard statements: arguments evaluate eagerly in the caller, params bind in a fresh function-local scope, and the result is the final expression or `return(expr)` payload. Recursive and unsupported function-body forms are fenced as diagnostics with zero raw fallback on the Perl reference; Rust and Dart directly diagnose recursive calls in their runtime resolvers. The accepted MVP surface is closed at explicit-paren, braced `fn` definitions; alternate spellings, omitted zero-arg parentheses, brace-less bodies, caller-state-mutating functions, recursion support, closures/lambdas/currying, and function namespaces remain deferred extension topics.

## Backbone items

Three backbone items tracked major structural modernization — all done:

1. Declarative bootstrap grammar registry replacing positional bootstrap coupling (done)
2. Staged `spec_entry()` compiler pipeline around RuleIR and explicit planning/validation phases (done)
3. Structured ActionIR/rewrite/lowering pipeline replacing ad hoc helper regex-chain rewriting (done)

## Ongoing

- **Documentation and book sync** — the book is kept aligned with the codebase as features land and surfaces evolve.
- **Variant-agnostic documentation** — this book is being aligned so it describes the `.spec` contract, DSL, and helper semantics backend-neutrally, with the Perl implementation shown as the reference backend rather than as "the" implementation.
- **Future backend parity backlog** - `FUTURE-PARITY-BACKLOG` owns deferred parity work. `FUTURE-PARITY-BACKLOG.1.1` scoped Dart into `DART-BACKEND-PARITY`; Julia and Lua remain gated until the Dart scoped milestone is reached. Each backend variant is expected to own a distinct LinkedSpec CLI entrypoint. The backlog also parks a future spec-derived closed-loop validation arc: both a parser and a stimuli generator should be derived from the same `.spec` source of truth, with design work required before any implementation.
- **Dart backend parity** - `DART-BACKEND-PARITY` is the active first future-backend lane. Its strategy is
  interpreter-first over typed `.spec` and helper/action AST plus compiled-spec state, with generated Dart source
  deferred to a later proof lane after corpus parity. The repo now has a `dart/` CLI/library scaffold,
  manifest/corpus IO validation, source-level AST/data types with JSON round-trip coverage, a core `.spec` rule
  parser with shipped-spec plus rule-only corpus parser coverage, frontend validation/strict-syntax checks,
  spec-returned function-definition projection, typed ActionIR helper/action parsing, ActionIR contract
  resolution, a user-function registry seam, a compiled-spec state model, runtime matching primitives, and the
  first runtime rule interpreter. Dart ActionIR parsing covers calls, literals, access, shape literals,
  assignments, block values, attached controls, receiver chains, trailing blocks, and standalone value-drop
  statements; the resolver records current canonical helper/control contracts and generic diagnostics over those
  typed nodes. With a `UserFunctionRegistry`, exact-arity user calls classify before helper fallback while
  wrong-arity registered calls report user-function arity diagnostics. `compileSpec(...)` builds ordered
  `CompiledSpec` / `CompiledRule` state, structured dependency-regex data, mode metadata, lifecycle/action
  `ActionBlock` payloads, function projection, and descriptor-shaped `spec` / `functions` /
  `dependency_regex_map` / `meta` JSON. Runtime matching supports seek/consume modes, stable alternative identity,
  capture and named-capture records, char-offset projections, entry/local match registers, cursor state, and
  zero-progress detection. `LinkedSpecRuntimeEngine` now executes default/AND/OR/repetition rule families with
  action-edge and blind-call child dispatch, lifecycle blocks, explicit returns, `retv`, accumulators, bounded
  repetition, zero-progress cutoffs, and recursion cutoffs. Its evaluator now also preserves
  scalar/array/hash/null/boolean/number shapes through assignment and wrapper snapshots, supports `hash(...)`,
  `set(hash(...), ...)`, hash-index mutation, nested reads, non-numeric map keys, aggregate `copy(...)`,
  named/map/position capture helpers, string/scalar helpers, explicit `str_*` lexical comparisons, numeric helpers,
  numeric aliases/symbol callees, compatible string/number receiver chains, array helper family breadth, regex
  split/filter bridges, delimiter-first `join_values`, array numeric reducers, statement-only array end mutations,
  hash helper family breadth, hash receiver chains, statement/value mutation boundaries, nested value-path
  assignment with no-autovivification failure behavior, explicit flat-style hash splicing, expression-valued
  blocks with block-local return, attached and inline structured controls,
  helper/receiver `with` trailing blocks, hash/array tree traversal receiver callbacks, `save_cursor()` /
  `restore_cursor()` stack semantics, `rewind_match_start()` / `rewind_entry_start()` anchor rewinds, and
  char-based cursor/input helpers, `capture_until_boundary(rule[, ...])` non-consuming structural boundary
  capture. Runtime failures now expose structured Dart `RuntimeDiagnostic` payloads through
  `RuntimeInterpreterException.diagnostic` with stable owner/stage/rule/source attribution. Dart also has ordered
  trace levels, `LinkedSpecTraceConfig`, event/scope primitives, stdout/routed-file/mirror sinks with
  reset/truncate behavior, and traced runtime entrypoints that preserve parse output while emitting a parse-scope
  event. Dart runtime tracing now also emits rule scopes, regex match/no-match decisions, action/blind child
  dispatch decisions, lifecycle block marks, cursor-control marks, recursion-cutoff decisions, and
  `capture_until_boundary(...)` source-boundary marks. The diagnostics/trace no-drift sweep is closed. Dart now
  also has the minimal staged parser registry for function-body parse jobs: `actionir-body.spec` resolves to the
  built-in `action_block` provider, dispatch records carry the staged cache key and compiled parser shape, queued
  jobs execute in stable order, and the returned `action_block` JSON is stitched into `body_ast`. Dart registered
  exact-arity user-function calls now execute before helper fallback with eager caller-side arguments, fresh
  function-local scalar/array/hash stores, final-expression or local-return results, receiver-chain continuation,
  standalone discard, and direct/mutual recursion diagnostics. Dart now also preserves neutral staged function
  descriptor shapes through parsed functions, compiled registry jobs, descriptor `body_payload`,
  `body_parse_job`, stitched `body_ast`, function-order metadata, and runtime output. Dart now also treats empty
  array/hash returns as successful non-null rule matches, uses child-rule match bits for blind dispatch, and
  executes marker-form `if(...)` / `elseif(...)` / `else()` / `endif()` statement chains as grouped branches. It
  also preserves assignment expressions inside helper arguments, supports plain fallback values in inline
  `if(...)`, evaluates numeric aggregate reducers over bare arrays, and follows scalar-held list/map readback for
  `array(name)`, `hash(name)`, and `copy(name)`. The first 40 shipped manifest fixtures and the non-`fn` middle
  fixtures pass through bounded corpus execute mode. Top-level `fn` corpus fixtures are routed to a later
  spec-defined function-shell corpus leaf. The final shipped-spec/parser-smoke window is split after a 2/31
  diagnostic run and is now 7/31 green. The basic regex-dialect bridge, helper/action bridge, and
  recursive/default-mode bridge are done, while deeper PCRE structural constructs remain routed to a follow-up; the
  next Dart frontier is residual parser-smoke output/helper parity, followed by closeout and cross-backend gates.
- **Non-current helper code purge** - `NONCURRENT-HELPER-CODE-PURGE` is closed. Perl source cleanup, Rust source cleanup, active test/tool/generated fixture and checked-in `.spec` migration, and final no-drift scans are complete. Retired helper-looking calls use generic unknown-helper fallback behavior, active generic-unknown-helper tests use invented helper names, and active helper-call/label/tag scans are clean.
- **Rust generated-source breadth** — the Rust interpreter oracle is the current cross-variant parity gate. Generated Rust source already covers the current structural families and a curated corpus subset; broadening generated-source proof to the full manifest remains a separately owned future follow-on.
- **Lifecycle-family audit** — verified complete (2026-06-14). All 7 lifecycle markers (`I`, `LS`, `LE`, `E`, `EX`, `IT`, `LX`) have full semicolon-light structured authoring coverage. The current separator contract is newline-or-semicolon: newlines separate top-level helper statements, and multiple same-line statements require semicolons. No lifecycle-specific semantic gaps found.
- **Terse `.spec` format evolution** — the active language-evolution track now supports auto-existing working variables, canonical helper renames (`set`, `cat`, `copy`), scalar/array/hash mutation operators, typed primitive literals, newline-or-semicolon statement separators, direct nested access such as `payload["children"][0]["name"]`, nested value-path assignment such as `payload["children"][0]["name"] = value`, attached-block `if`/`when`/`switch`/`while` control flow, inline value `if`/`switch` in `return(...)`, assignment RHS, and fluent `.return(...)`, deep pure-helper composition, array receiver-dot value chains such as `items.sorted().drop_front(2).first()` and `items.uniq().join_values(",")`, hash receiver-dot value chains such as `meta.set_key("stage", "normalized").sorted_keys().join_values(",")`, string receiver-dot value chains such as `raw.trim().lowercase().replace_substr("-", "_")` and `raw.trim().split("-").trim_each().join_values("|")`, number receiver-dot value chains such as `score.abs().ceil().add(2).clamp(0, 10)` and `count(array(parts)).gt(0)`, function-style numeric aliases such as `add(2, mul(3, 4))` and `gt(count(array(parts)), 0)`, arithmetic symbol callees such as `+(2, *(3,4))`, comparison symbol callees such as `>(count(array(parts)), 0)` and `==("2", "2")`, explicit string comparison helpers such as `str_eq(trim(kind), "word")` and `str_gt("2", "10")`, scalar assignment value expressions such as `return(name = "ok")`, `return(=(other, "ok"))`, and `=(raw, " text ").trim()`, aggregate assignment value expressions such as `return(items = [value])`, `return(set(meta, { key : value }))`, and `=(items, [value]).count()`, mutation assignment value expressions such as `return(items += value)`, `return(meta[key] = value)`, `(items += value).count()`, and `(meta[key] = value).count_keys()`, expression-valued block receivers such as `{ [3, 1, 2] }.sorted().join_values(",")`, `{ " a-b " }.trim().split("-").count()`, `{ { "b" : 2, "a" : 1 } }.sorted_keys().join_values(",")`, and `{ 3.5 }.floor().add(2)`, helper-function form and receiver-method form trailing block arguments on Perl and Rust such as `with(value) { return(cat(value, "!")) }` and `" a-b ".trim().with() { return(value.split("-")) }.count()`, hash-tree receiver block traversal methods such as `tree.map_leaves() { return(cat(join_values("/", array(path)), "=", value)) }`, `tree.walk_leaves() { paths += join_values("/", array(path)) }`, and `tree.reduce_leaves(0) { return(acc.add(1)) }`, array-tree receiver block traversal methods such as `items.map_leaves() { return(cat(join_values("/", array(path)), "=", value)) }`, `items.walk_leaves() { paths += join_values("/", array(path)) }`, and `items.reduce_leaves(0) { return(acc.add(1)) }`, bare aggregate working-variable snapshots in supported hash- and array-consuming helper slots such as `merge_hash(copy(hash(base)), overlay)` and `count(drop_front(sorted(items)))`, and bare scalar reads in return/assignment source slots, mutation key/RHS slots, direct path atoms, direct shape-literal values such as `[value]` and `{ "kind" : value }`, `if`/`while` conditions, numeric/comparison helper args, and switch subjects. Switch case labels remain literal tag positions: `switch(kind)` reads scalar `kind`, while `case(word)` matches the literal `"word"`. It also supports exact-arity user functions such as `fn normalize(value) { return(trim(value)) }` and `fn no_args() { return("ok") }`, with calls usable as values, receiver-chain receivers, or standalone discarded statements on both Perl and Rust. Direct RHS shape literals bind typed values on bare assignment targets (`items = [value]`, `meta = { key : value }`); explicit `array(...)` and `hash(...)` targets preserve aggregate storage. Examples include `return(i)`, `set(out, if(is_nonempty(flag), "yes", else("no")))`, `out = switch(kind, case("word", "word"), default("other"))`, `return(name = "ok")`, `items += value`, `return(items += value)`, `items.sorted().first()`, `meta.set_key("stage", "normalized").count_keys()`, `raw.trim().split("-").lowercase_each().join_values("_")`, `score.abs().round().gt(3)`, `gt(count(array(parts)), 0)`, `+(2, *(3,4))`, `str_eq(lowercase(trim(kind)), "word")`, `meta[key] = value`, `return(meta[key] = value)`, `payload["children"][i]`, `return([value, { "key" : value }])`, `return(with("x") { return(cat(value, "!")) })`, `return(" x ".with() { return(cat(value, "!")) }.trim())`, `return({ "a" : "A", "b" : { "y" : "B" } }.map_leaves() { return(cat(join_values("/", array(path)), "=", value)) })`, `return(["a", ["b"]].map_leaves() { return(cat(join_values("/", array(path)), "=", value)) })`, `return(normalize(" x "))`, `words(" go ").join_values("|")`, `switch(kind) { case("word") { return("word") } default { return("other") } }`, `items = [value]`, and `meta = { key : value }`. Function syntax remains the explicit-paren, braced `fn` MVP; alternate spellings, optional zero-arg parentheses, brace-less bodies, caller-state-mutating functions, recursion support, closures/lambdas/currying, and namespaces are deferred. The comparison migration is complete through symbol callees: `str_*` is shipped and preferred for lexical string comparisons, while bare comparison words and comparison symbol callees are numeric aliases over `num_*`. Scalar, aggregate, array append, and hash-index mutation expression-valued assignment are shipped under `SPEC-FORMAT-TERSE.3.3.1` through `.3.3.3`, with legacy assignment spelling cleanup closed by `.3.3.4`; current cross-backend trailing block arguments are intentionally limited to immediate helper-function `with(...)`, receiver-method `.with()`, and tree traversal receiver methods `walk_leaves`, `map_leaves`, and `reduce_leaves`, not closures or delayed callbacks.
- **Shipped-spec terse-source migration** — complete. Current shipped specs, broader public examples, and checked-in corpus/test-spec examples prefer auto-existing working variables, operator assignment/reset forms, `set(...)`, `push(...)`, `copy(...)`, and `cat(...)`. Deleted helper spellings are no longer part of the current contract surface.

## What this means for readers

- Some older historical names appear in repo history and older notes. The active code path uses the current vocabulary.
- The current public and architectural explanations in this book prefer the active surfaces, not the oldest historical vocabulary.
- For the most current implementation status, the repo's `ROADMAP_V2.md` and `ARCHITECTURE_STATE.md` remain the fastest-changing references. This book absorbs that understanding over time in a more stable, explanatory form.

The project is healthy, actively maintained, and moving in a clear direction. Each phase leaves the codebase in a more explainable, more trustworthy state than it found it.
