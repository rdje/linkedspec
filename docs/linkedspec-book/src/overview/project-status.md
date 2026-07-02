# Project Status

LinkedSpec is an actively evolving system. The current direction is not “freeze everything exactly as it once was.” The direction is to preserve the strengths that make LinkedSpec useful while modernizing the runtime, compiler, diagnostics, and documentation.

LinkedSpec is also a multi-backend system. The `.spec` language is the one universal contract; each backend is an execution platform that runs the same `.spec` files with identical semantics. The Perl implementation is the **reference backend** (the canonical behavioral oracle), and a Rust backend is the second execution platform; the language is specified so further backends can be built in other languages. Status below is therefore stated at the `.spec`-contract level, with backend-specific notes called out where they apply.

## Completed phases

Phases 0–9 of the modernization roadmap are done:

- **Phase 0**: Regression safety net — `t/phase0_regression.t` covers all 20 shipped specs with a green baseline; every `.spec` compiles at `language_agnostic_ready_ratio == 1.0000` (zero compatibility-surface rules).
- **Phase 1**: Thin facade + owner dispatch — `LinkedSpec.pm` is a 258-line lazy facade; 27 modules use uniform `OwnerDispatch`; the former `ActionRewriter.pm` forwarding shim was deleted (118 lines).
- **Phase 1A**: Thin-façade modularization — `LinkedSpec.pm` delegated into focused owner modules (`Trace`, `Validation`, `Resolver`, `Runtime`, `Compiler`, `BootstrapSpec`, `SpecEntry`, `RuleIR`, `EmitContext`); the shared `OwnerDispatch` seam replaced per-owner lazy-loading wrappers.
- **Phase 2**: DSL frontend hardening — rule-label parsing, inside-block rejection, extra-colon rejection, fluent-continuation recognition, `strict_syntax` mode, construct-recognition alignment with bootstrap grammar.
- **Phase 3**: Execution semantics — seek/consume parse modes documented; BACKTRACK/IBACKTRACK defined as local cursor-rewind, not systemic backtracking; forward-moving non-backtracking model stated.
- **Phase 4**: Capture/mark API — 163 contracts across 6 families verified, compat aliases documented, mark-helper reference complete.
- **Phase 5**: Runtime diagnostics — structured last_error is the single diagnostics channel; handler compile warnings routed through trace instead of stderr; eval minimized to one handler compilation; trace bridging from compile scopes into runtime handler scopes.
- **Phase 6**: Documentation and adoption — the book you are reading. All identified documentation gaps closed (LinkedRE, Validation, public API, cross-linking, overviews, ActionIR lowering, per-spec walkthroughs).
- **Phase 7**: Self-hosted `spec.spec` grammar — LinkedSpec parses its own `.spec` language through the DSL itself. `spec.spec` compiles at `language_agnostic_ready_ratio == 1.0000` with regression coverage; it is the required change surface for `.spec` language evolution.
- **Phase 8**: Multi-backend specification and handoff — the `.spec` language, runtime semantics, helper contracts, and HandlerIR are specified backend-neutrally, so a backend can be built in any language without reading the reference source. The multi-backend vision — the same `.spec` files, the same semantics, and the same test corpus across all backends — is recorded in ADR 0006. This phase was specification-only (no behavioral code change).
- **Phase 9**: Rust variant — a second execution backend. The Rust workspace (`rust/`: `linkedspec-core` + `linkedspec-runtime`) carries its own `.spec` parser, compiler, runtime engine, and helper surface, and runs `.spec` files compiled from the same universal contract. It is operational (interpreted mode, v0.1); full cross-variant output parity with the Perl reference is an ongoing follow-on.

The Method-like DSL migration track is also complete: all 20 shipped specs at zero compatibility-surface rules, 100+ helpers across 10 families regression-locked, retired compatibility aliases fenced or removed, and fluent/block equivalence verified. The later ActionIR AST migration has also retired the short wrapper spellings `s(...)`, `a(...)`, and `h(...)`; use `scalar(...)`, `array(...)`, and `hash(...)`. It now diagnoses unknown typed calls in return/value positions instead of emitting generated host-language calls, while unregistered standalone function-shaped statements remain explicit raw compatibility debt. Top-level `fn name(args) { ... }` definitions are now active in `spec.spec` and projected through the Perl reference descriptor `functions` registry, with params, arity, source/body spans, body source, and body AST recorded. On the Perl reference, registered exact-arity user-function calls now execute in value positions, compatible receiver chains, and standalone discard statements: arguments evaluate eagerly in the caller, params bind in a fresh function-local scope, and the result is the final expression or `return(expr)` payload. Recursive and unsupported function-body forms are fenced as unresolved-helper diagnostics with zero raw fallback. Rust parity remains follow-on work.

## Backbone items

Three backbone items tracked major structural modernization — all done:

1. Declarative bootstrap grammar registry replacing positional bootstrap coupling (done)
2. Staged `spec_entry()` compiler pipeline around RuleIR and explicit planning/validation phases (done)
3. Structured ActionIR/rewrite/lowering pipeline replacing ad hoc helper regex-chain rewriting (done)

## Ongoing

- **Documentation and book sync** — the book is kept aligned with the codebase as features land and surfaces evolve.
- **Variant-agnostic documentation** — this book is being aligned so it describes the `.spec` contract, DSL, and helper semantics backend-neutrally, with the Perl implementation shown as the reference backend rather than as "the" implementation.
- **Rust backend parity** — bringing the Rust backend to full cross-variant output parity with the Perl reference: identical match/no-match results and identical JSON output for any given `.spec` file.
- **Lifecycle-family audit** — verified complete (2026-06-14). All 7 lifecycle markers (`I`, `LS`, `LE`, `E`, `EX`, `IT`, `LX`) have full semicolon-light structured authoring coverage. The current separator contract is newline-or-semicolon: newlines separate top-level helper statements, and multiple same-line statements require semicolons. No lifecycle-specific semantic gaps found.
- **Terse `.spec` format evolution** — the active language-evolution track now supports auto-existing working variables, canonical helper renames (`set`, `cat`, `copy`), scalar/array/hash mutation operators, typed primitive literals, newline-or-semicolon statement separators, direct nested access such as `payload["children"][0]["name"]`, attached-block `if`/`when`/`switch`/`while` control flow, inline value `if`/`switch` in `return(...)`, assignment RHS, and fluent `.return(...)`, deep pure-helper composition, array receiver-dot value chains such as `items.sorted().drop_front(2).first()` and `items.uniq().join_values(",")`, hash receiver-dot value chains such as `meta.set_key("stage", "normalized").sorted_keys().join_values(",")`, string receiver-dot value chains such as `raw.trim().lowercase().replace_substr("-", "_")` and `raw.trim().split("-").trim_each().join_values("|")`, number receiver-dot value chains such as `score.abs().ceil().add(2).clamp(0, 10)` and `count(array(parts)).gt(0)`, expression-valued block receivers such as `{ [3, 1, 2] }.sorted().join_values(",")`, `{ " a-b " }.trim().split("-").count()`, `{ { "b" => 2, "a" => 1 } }.sorted_keys().join_values(",")`, and `{ 3.5 }.floor().add(2)`, bare aggregate working-variable snapshots in hash- and array-consuming helper slots such as `merge_hash(hash_copy(base), overlay)` and `count(drop_front(sorted(items)))`, and bare scalar reads in return/assignment source slots, mutation key/RHS slots, direct path atoms, and direct shape-literal values such as `[value]` and `{ "kind" => value }`. Direct RHS shape literals infer aggregate assignment targets (`items = [value]`, `meta = { key => value }`), with `scalar(name)` preserving scalar-held payload assignment. Examples include `return(i)`, `set(out, if(is_nonempty(flag), "yes", else("no")))`, `out = switch(kind, case("word", "word"), default("other"))`, `items += value`, `items.sorted().first()`, `meta.set_key("stage", "normalized").count_keys()`, `raw.trim().split("-").lowercase_each().join_values("_")`, `score.abs().round().gt(3)`, `meta[key] = value`, `payload["children"][i]`, `return([value, { "key" => value }])`, `switch(scalar(kind)) { case("word") { return("word") } default { return("other") } }`, `items = [value]`, and `meta = { key => value }`.

## What this means for readers

- Some older historical names appear in repo history and older notes. The active code path uses the current vocabulary.
- The current public and architectural explanations in this book prefer the active surfaces, not the oldest historical vocabulary.
- For the most current implementation status, the repo's `ROADMAP_V2.md` and `ARCHITECTURE_STATE.md` remain the fastest-changing references. This book absorbs that understanding over time in a more stable, explanatory form.

The project is healthy, actively maintained, and moving in a clear direction. Each phase leaves the codebase in a more explainable, more trustworthy state than it found it.
