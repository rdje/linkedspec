# Repo-Local Task Tree Workflow

This document defines the repo-local task-tree workflow used by LinkedSpec.
It is intentionally portable: another project can copy this file, the
`docs/tasks/TEMPLATE.md` template, and the commit-subject rule, then replace
the roadmap lane names and live-doc file names with local equivalents.

For a step-by-step setup guide that can be reused by another project, read
[docs/TASK_TREE_README.md](docs/TASK_TREE_README.md).

## Purpose

Use a task tree when a top-level task is too broad to finish safely as one
signoff-level slice, or when a task is expected to discover subtasks and
sub-subtasks over time.

The goal is not to create a second roadmap. The roadmap states the high-level
workstream direction. A task tree owns the recursive breakdown, current
frontier, acceptance criteria, blockers, decisions, validation, and completion
evidence for one top-level task.

## Active Task Trees

| Tree | Status | Roadmap lane | Current frontier | File |
| --- | --- | --- | --- | --- |
| `STATEMENT-SEPARATOR-EXAMPLE-ALIGNMENT` | `done` / `closed` | `.spec language evolution / documentation and test no-drift` | `.1` done 2026-07-10 - the director-identified Dart hash-helper fixture now uses newlines between multiline statements and no trailing semicolons; focused execution is unchanged. | [docs/tasks/STATEMENT-SEPARATOR-EXAMPLE-ALIGNMENT.md](docs/tasks/STATEMENT-SEPARATOR-EXAMPLE-ALIGNMENT.md) |
| `NONCURRENT-HELPER-CODE-PURGE` | `done` / `closed` | `.spec language evolution / codebase no-drift` | `.5` done 2026-07-09 - Perl/Rust retired-helper source cleanup, active fixture/spec migration, and final no-drift closeout are complete. Active retired-helper call-shape, label/tag, and `?concat:` scans are clean; generic unknown-helper tests use invented helper names. | [docs/tasks/NONCURRENT-HELPER-CODE-PURGE.md](docs/tasks/NONCURRENT-HELPER-CODE-PURGE.md) |
| `BACKTRACK-SURFACE-RUST-ALIGNMENT` | `done` / `closed` | `.spec language evolution / backend parity no-drift` | `.2` done 2026-07-09 - Perl, Rust, and Dart now share explicit `save_cursor()` / `restore_cursor()` stack controls, `rewind_match_start()` / `rewind_entry_start()` anchor rewinds, and `capture_until_boundary(rule[, ...])` non-consuming structural boundary capture. EBNF semantic annotations use the boundary helper instead of consume-then-rewind. | [docs/tasks/BACKTRACK-SURFACE-RUST-ALIGNMENT.md](docs/tasks/BACKTRACK-SURFACE-RUST-ALIGNMENT.md) |
| `DART-BACKEND-PARITY` | `done` / `closed` | `Overall roadmap - future backend parity (Dart first)` | Global proof is 181 tests, 105 interpreter corpus, exact 61x2 CLI, full native trace/API parity, deterministic v1 emission, ten-family direct execution/four rejections, and exact accepted 8/105 host proof. Dart passes all current capabilities. | [docs/tasks/DART-BACKEND-PARITY.md](docs/tasks/DART-BACKEND-PARITY.md) |
| `FUTURE-PARITY-BACKLOG` | `active` | `Overall roadmap - future parity backlog` | Punctuation-light parent `.16` is complete at capability 64/0/0 and condition headers remain parenthesized. Named-mark `.17.1-.17.3` align Perl/Rust/Dart/Julia with exact backend/canonical proof; Lua `.17.4` is active before shared admission `.17.5`. | [docs/tasks/FUTURE-PARITY-BACKLOG.md](docs/tasks/FUTURE-PARITY-BACKLOG.md) |
| `LUA-BACKEND-PARITY` | `active` | `Overall roadmap - future backend parity (Lua third)` | Eager blocks/controls/callbacks close at 114/114; input/cursor `.4.3.7.1` passes 115/115; all 16 anonymous capture calls `.4.3.7.2` pass 116/116; and non-consuming earliest-boundary `.4.3.7.5` passes 117/117 on both Lua ABIs. Perl/Rust/Dart/Julia named-mark `.17.1-.17.3` are complete; Lua `.17.4` is active before its `.4.3.7.3` consumer. | [docs/tasks/LUA-BACKEND-PARITY.md](docs/tasks/LUA-BACKEND-PARITY.md) |
| `JULIA-BACKEND-PARITY` | `active` (delegated global obligations) | `Overall roadmap - future backend parity (Julia second)` | Current proof is 1,339 package assertions, 105 fixtures, and exact CLI 61x2. Uniform-binding execution and selector rejection are complete; only later explicitly delegated language evolution remains. | [docs/tasks/JULIA-BACKEND-PARITY.md](docs/tasks/JULIA-BACKEND-PARITY.md) |
| `SPEC-SOURCE-TERSE-CLOSEOUT` | `done` / `closed` | `Overall roadmap - .spec language evolution (terse format)` | `.1` done 2026-07-08 - root `specs/*.spec` source-format closeout completed; retired-helper and host-action residue scans are clean, all 21 descriptors report `1.0000 0 0`, hlink bracket/mixed fixtures are active in the 99-fixture Rust oracle, and pplugin body execution is isolated in the Perl runtime adapter. | [docs/tasks/SPEC-SOURCE-TERSE-CLOSEOUT.md](docs/tasks/SPEC-SOURCE-TERSE-CLOSEOUT.md) |
| `SPEC-FORMAT-TERSE` | `done` / `closed` (closed by `.13.5`; no current PNT-eligible leaf) | `Overall roadmap — .spec language evolution (terse format)` | `.0` done 2026-06-18 (ratified — ADR `0007`). Implementation gate CLEARED 2026-06-22 (`t/phase0_regression.t` green + `tools/run_ci_local.sh` EXIT 0; gradual-alias migration). **`.1.1` DONE 2026-06-24** (auto-existing wrapper-referenced working vars on Perl + Rust). **`.1.2` SPLIT** by inference channel; **`.1.2.1`+`.1.2.2` DONE 2026-06-24 — Channel 1 complete on BOTH variants** (Channel 2 deferred behind `.1.5`). **`.1.4` DONE 2026-06-29** (helper renames closed on both variants; Perl reference + Rust parity, phase0 **975 green**). **`.1.3` DONE 2026-06-29** — mutation surface closed by mechanism: scalar `set(name,val)` already satisfied by `.1.4`; `push(target,value)` explicit append with child-call precedence; `set_key(name,key,value)` statement mutation while value form stays pure; operator family closed with scalar `name = value`, array `items += value`, and hash `name[key] = value` for explicit key/value expressions. **`.1.5` SPLIT 2026-06-29** — audit showed literal parity, call spacing, separator semantics, and direct nested access are separate leaves. **`.1.5.2` DONE 2026-06-29** — primitive literals are typed values on Perl/Rust, with JSON booleans and Rust statement-form `if(false)` gating. **`.1.5.3` DONE 2026-06-29** — call spacing locked: optional whitespace before `(` works at supported helper/value sites, while no-parenthesis helpers remain out of scope. **`.1.5.4` DONE 2026-06-29** — statement separators locked: newline-or-semicolon, same-line multiple statements require `;`, nested semicolons protected. **`.1.5.5` SPLIT 2026-06-29** — direct nested access divided into explicit-segment and Channel-2 coordination. **`.1.5.5.1` DONE 2026-06-29** — explicit direct access landed; **`.1.5.5.2` SUPERSEDED/MERGED 2026-06-29**. **`.1.2.3` through `.1.2.3.5.4` DONE 2026-06-29** — Channel 2 aggregate/scalar bare reads, direct path atoms, shape-literal values, and historical RHS target-kind inference landed on Perl/Rust before `.11` superseded the storage behavior; corpus 32 fixtures. **`.1.6` DONE 2026-06-29** — array end-mutation methods landed; phase0 **990 green**, corpus 33 fixtures, Round 1 closed. **`.2.1.1` DONE/SPLIT 2026-06-29**; **`.2.1.2` DONE 2026-06-29** — Perl block values; **`.2.1.3` DONE 2026-06-29** — Rust block values; corpus **34 fixtures**. **`.2.1.4` DONE 2026-06-30** — block-local early return landed on Perl/Rust; corpus **35 fixtures**. **`.2.2.1` DONE/SPLIT 2026-06-30** — control-flow keyword surface split. **`.2.2.2` DONE 2026-06-30** — Perl attached-block if landed. **`.2.2.3` DONE 2026-06-30** — Rust attached-block if parity landed; corpus **36 fixtures**. **`.2.2.4` DONE 2026-06-30** — `when/otherwise` aliases landed; corpus **37 fixtures**. **`.2.2.5` SPLIT/OWNED 2026-06-30**; **`.2.2.5.1` DONE 2026-06-30** — Perl attached switch separator/source lock; **`.2.2.5.2` DONE 2026-06-30** — Rust attached switch parity, corpus **38 fixtures**. **`.2.2.6` DONE 2026-06-30** — attached `while(cond) { ... }` split and closed; **`.2.2.6.1` DONE 2026-06-30** — Perl attached while loop/safety landed; **`.2.2.6.2` DONE 2026-06-30** — Rust attached while parity landed, corpus **39 fixtures**. **`.2.3` SPLIT/OWNED 2026-06-30**; **`.2.3.1` DONE 2026-06-30** — Perl fluent `.when(cond) { ... }.otherwise { ... }` block-chain fallback contract landed, phase0 **993 green**; **`.2.3.2` DONE 2026-06-30** — lifecycle value/drop return-channel lock landed, phase0 **994 green**; **`.2.3.3` SPLIT/OWNED 2026-06-30**; **`.2.3.3.1` DONE 2026-06-30** — Rust action-edge fluent no-arg `.push` / `.return(expr)` parity landed; **`.2.3.3.2` DONE 2026-06-30** — Rust attached fluent `.when(cond) { ... }` block payloads now execute on action-edge/lifecycle surfaces with dotted and no-dot fallback tails; **`.2.3.3.3` SPLIT 2026-06-30** — remaining Rust fluent continuations split into compact lifecycle/body chains, action-edge explicit/flow chains, and `tclite` re-enable/default-mode repetition audit; **`.2.3.3.3.1` DONE 2026-06-30** — Rust compact lifecycle/body receiver chains now execute as lifecycle `CodeBlock` statements; **`.2.3.3.3.2` DONE 2026-06-30** — Rust action-edge explicit/flow fluent chains now execute with explicit-target child-return appends and statement-control gating; **`.2.3.3.3.3` DONE/SPLIT 2026-06-30** — `tclite` retry after fluent parity still returned Rust `[]` for `[]`/`""`, splitting default-mode recursive repetition parity; **`.2.3.3.3.3.1` DONE 2026-06-30** — Rust default-mode repetition parity landed and the two `tclite` fixtures are active (corpus **41 fixtures**); **`.2.3.4` DONE/SPLIT 2026-06-30** — full composability audit added a green deep pure-helper oracle fixture (corpus **42 fixtures**) and split Rust helper-context aggregate bare reads plus Perl inline value-control lowering into children; **`.2.3.4.1` DONE 2026-06-30** — Rust helper-context bare aggregate arguments landed for hash- and array-consuming helper slots, corpus **44 fixtures**; **`.2.3.4.2` DONE 2026-06-30** — Perl inline value-control lowering landed for `if`/`switch` in supported value positions, corpus **46 fixtures**; **`.2.3.5` DONE/SPLIT 2026-07-01** — return-type method chaining specified before code and split into array/hash/string/number implementation leaves plus a block-valued receiver audit; **`.2.3.5.1` DONE 2026-07-01** — array receiver-dot value chains landed on Perl/Rust, phase0 **996 green**, corpus **47 fixtures**; **`.2.3.5.2` DONE 2026-07-01** — hash receiver-dot value chains landed on Perl/Rust, corpus **48 fixtures**, statement-level hash mutations preserved, Rust `merge_hash` override parity fixed; **`.2.3.5.3` DONE 2026-07-01** — string/scalar receiver-dot value chains landed on Perl/Rust, split bridges into array chains, string literal receivers parse on Rust, value-form split/substr payloads are portable, phase0 **998 green**, corpus **49 fixtures**; **`.2.3.5.4` DONE 2026-07-01** — number receiver-dot value chains landed on Perl/Rust; numeric literal receivers parse, comparisons are terminal, value-form numeric comparisons lower on Perl, Rust `num_add`/`num_mul` consume all operands, phase0 **999 green**, corpus **50 fixtures**; **`.2.3.5.6` DONE 2026-07-01** — aggregate wrapper quoted-name boundaries and direct shape constructor preference locked, phase0 **1000 green**, corpus **51 fixtures**; **`.2.3.5.5` DONE 2026-07-01** — block-valued receiver-dot chains landed by yielded runtime type, phase0 **1001 green**, corpus **52 fixtures**; **`.5.0` DONE 2026-07-01** — future variant parity ownership/inventory landed before non-Rust variant code; **`.3.1` DONE 2026-07-01** — edge syntax contract locked with no behavior change (`->` action, `=>` blind-call, grouped action targets require a shared block); **`.3.2` SPLIT/OWNED 2026-07-01** — arithmetic/comparison call surface split before code, with one `callee(args)` grammar, word aliases first, arithmetic symbol callees second, and comparison spelling policy isolated; **`.3.2.1` DONE 2026-07-01** — numeric word aliases landed on Perl/Rust while bare comparison words stayed string helpers until `.3.2.3.3` later flipped them. **`.4` SPLIT/OWNED 2026-07-01** — user-defined pure functions accepted into Round 4; calls are value expressions, receiver-chain capable, and standalone results are silently discarded; permanent `fn` grammar belongs in `specs/spec.spec`, with bootstrap-parser support temporary/removable after text-to-AST handoff. **`.4.1` DONE 2026-07-01** — MVP contract/inventory locked before code; `.4.2` split into Perl grammar/registry, value-call execution, and discard/purity hardening leaves; `.4.3` split into Rust registry and runtime/oracle parity. **`.4.2.1` DONE 2026-07-01** — Perl function-definition grammar/registry descriptor seam landed; **`.4.2.2` DONE 2026-07-01** — registered exact-arity Perl user-function value calls now execute in value positions and compatible receiver chains. **`.4.2.3` DONE 2026-07-01** — Perl standalone discard and hardening landed; registered standalone calls lower as `VALUE_DROP`, recursion/unsupported body diagnostics are locked. **`.4.3.1` DONE 2026-07-02** — Rust function-definition AST/compiler registry parity landed. **`.4.3.2` DONE 2026-07-02** — Rust registered user-function calls now execute as values, feed compatible receiver chains, discard standalone results, and pass the Perl/Rust oracle fixture; corpus **54 fixtures**. **`.4.4` DONE 2026-07-02** — function MVP surface/deferral ledger finalized: explicit-paren braced `fn` stays the accepted surface; alternate spellings, optional zero-arg parentheses, brace-less bodies, side-effect/caller-mutating functions, recursion, closures/lambdas/currying, and namespaces remain deferred. **`.3.2.2` DONE 2026-07-02** — arithmetic symbol callees `+(...)`, `-(...)`, `*(...)`, `/(...)`, and `%(...)` now map to `num_add/sub/mul/div/mod` on Perl/Rust while slash regex literals remain regexes; corpus **55 fixtures**, phase0 **1008 green**. **`.3.2.3` SPLIT/OWNED 2026-07-02** — comparison call-surface migration is split behind explicit `str_*` string helpers, numeric comparison word aliases, and numeric comparison symbol callees. **`.3.2.3.1` DONE 2026-07-02** — explicit `str_eq`/`str_ne`/`str_gt`/`str_ge`/`str_lt`/`str_le` string-bridge contract locked before code. **`.3.2.3.2` DONE 2026-07-02** — explicit `str_*` string-comparison helpers now ship on Perl/Rust. **`.3.2.3.3` DONE 2026-07-02** — bare comparison word calls now map to numeric `num_*` aliases on Perl/Rust while lexical strings use explicit `str_*`; corpus **57 fixtures**, phase0 **1010 green**. **`.3.2.3.4` DONE 2026-07-02** — comparison symbol callees `==`/`!=`/`>`/`>=`/`<`/`<=` now map to numeric `num_*` aliases on Perl/Rust; corpus **58 fixtures**, phase0 **1011 green**. **`.3.3` SPLIT/DONE 2026-07-02** — expression-valued assignment split before code. **`.3.3.1` DONE 2026-07-02** — scalar non-shape assignment expressions and scalar `=(target,value)` equivalence now ship on Perl/Rust; **`.3.3.2` DONE 2026-07-02** — aggregate assignment expression values shipped under the historical target-kind inference contract later superseded by `.11` duck-typed value binding; **`.3.3.3` DONE 2026-07-02** — array append and hash-index mutation expression values now return updated aggregate snapshots on Perl/Rust; corpus **61 fixtures**, phase0 **1014 green**. **`.3.3.4` DONE 2026-07-02** — assignment-expression closure and legacy spelling cleanup landed; public examples prefer `set(...)`/operators while `assign(...)` remains a legacy alias, corpus **62 fixtures**, phase0 **1015 green**; `.6` shipped-spec migration and `.7` type-method surface are closed; `.8.3` hard-retired Perl legacy helper spellings, `.8.4` hard-retired Rust legacy helper spellings, `.8.5` reconciled public docs/KM, and `.8.6` closed final helper-retirement no-drift; `SPEC-FORMAT-TERSE.9` is closed: `.9.1` split the migration, `.9.2` added Perl colon support, `.9.3` added Rust parity, `.9.4` migrated current source/docs/KM/corpus/tests, `.9.5` retired old `{ key => value }`, and `.9.6` closed final no-drift scans. No concrete `SPEC-FORMAT-TERSE` PNT-eligible leaf remained after `.9` until the user explicitly reactivated `.14` on 2026-07-07. **`.14.1` DONE 2026-07-07** — trailing block arguments are split before code with `with(value) { ... }` as the first helper-function MVP, Rust parity and receiver `.with() { ... }` behind it, and no closures/assignable blocks/returnable blocks. **`.14.2` DONE 2026-07-07** — Perl reference helper-function form `with(value) { ... }` and `with() { ... }` now parse as flagged final block arguments, lower with scoped `value`, preserve block-local return, and diagnose unknown trailing-block callees. **`.14.3` DONE 2026-07-07** — Rust helper-function form parity landed for `with(value) { ... }` / `with() { ... }`, with call-site execution context docs and a 94th oracle fixture. **`.14.4` DONE 2026-07-07** — receiver `.with() { ... }` landed on Perl/Rust with scoped receiver `value`, compatible continuations, and a 95th oracle fixture. **`.14.5` DONE 2026-07-07** — final trailing block-argument no-drift closeout locked helper-function and receiver-method `with` docs/KM/oracle state; user reactivated `SPEC-FORMAT-TERSE.12` on 2026-07-08 for hash-tree attached-block traversal. `SPEC-FORMAT-TERSE.12.1` through `.12.4` are done, and `.12` is closed/exhausted after mdBook/Knowledge Map/live-doc/oracle no-drift closeout on the 96-fixture boundary. `SPEC-FORMAT-TERSE.10.1` ratified dynamic/computed hash-literal keys with no parser/runtime behavior change, and `.10` is closed. `SPEC-FORMAT-TERSE.13.1` split array-tree traversal before parser/runtime code. `SPEC-FORMAT-TERSE.13.2` landed Perl reference array-tree traversal with phase0 `1..1028`; `SPEC-FORMAT-TERSE.13.3` landed Rust/oracle parity with the 97th generated fixture; `SPEC-FORMAT-TERSE.13.4` closed docs/KM/no-drift alignment, `SPEC-FORMAT-TERSE.13.5` reconciled the parent task-tree status, and `SPEC-FORMAT-TERSE` is done/closed with no current PNT-eligible leaf remaining. | [docs/tasks/SPEC-FORMAT-TERSE.md](docs/tasks/SPEC-FORMAT-TERSE.md) |
| `SPEC-LANG-REFERENCE` | `done` / `closed` | `Overall roadmap — documentation and book sync` | Closed by `.8` on 2026-07-08. Final consistency corrected stale top-rule doctrine drift: ADR `0010` is current (`::` marks the rule entered first; after entry selection, `::` and `:` share the same feature surface), while the older no-regex/two-rule-minimum rule is historical. mdBook, KM, memory, task-tree metadata, doctrine, and whitespace gates pass. | [docs/tasks/SPEC-LANG-REFERENCE.md](docs/tasks/SPEC-LANG-REFERENCE.md) |

Index note 2026-07-09: `FUTURE-PARITY-BACKLOG.0` created the active future-backlog tree for
the seven deferred/future lanes surfaced after `SPEC-LANG-REFERENCE.8`. ADR `0021` adopts
the backend rollout order Dart -> Julia -> Lua, all targeting full parity with Perl5 and
Rust. The then-active frontier was `FUTURE-PARITY-BACKLOG.1.1` for Dart backend parity scoping.

Index note 2026-07-09: `FUTURE-PARITY-BACKLOG.1.1` is done. It created
`docs/tasks/DART-BACKEND-PARITY.md`, selected interpreter-first Dart parity, and deferred
generated Dart source to a later proof lane after interpreter/corpus parity. The next PNT
frontier was `DART-BACKEND-PARITY.1.1` for Dart toolchain/package-layout preflight.

Index note 2026-07-09: `DART-BACKEND-PARITY.1.1` is done. `/opt/homebrew/bin/dart` reports
Dart SDK 3.9.2 on macOS arm64, Flutter is absent/non-blocking for the CLI/library backend,
and the intended `dart/` package layout plus format/analyze/test/corpus-runner commands are recorded.
Active frontier advances to `DART-BACKEND-PARITY.1.2`.

Index note 2026-07-09: `DART-BACKEND-PARITY.1.2` is done. The repo-owned `dart/` package now has
metadata, committed lockfile, analyzer options, README, public scaffold API, CLI and corpus-runner
stubs, and a `package:test` smoke test. Dart format, analyze, test, and CLI smoke commands pass.
Active frontier advances to `DART-BACKEND-PARITY.1.3`.

Index note 2026-07-09: `DART-BACKEND-PARITY.1.3` is done. Dart corpus manifest IO now loads the
checked-in 99-fixture corpus, validates manifest shape, detects missing/stale fixture directories, and
checks required fixture files and expected JSON syntax without parser/runtime execution. The `.1`
foundation container is closed; active frontier advances to `DART-BACKEND-PARITY.2.1`.

Index note 2026-07-09: `DART-BACKEND-PARITY.2.1` is done. Dart source-level AST/data types now
round-trip through JSON for spec files, function definitions, source spans, staged parse jobs, rules,
rule modes, body elements, edges, and fluent calls. Active frontier advances to `DART-BACKEND-PARITY.2.2`.

Index note 2026-07-09: `DART-BACKEND-PARITY.2.2` is done. Dart `parseSpec(...)` now parses core
rule paragraphs into source AST types, including headers/modes, regex literals, lifecycle blocks,
action/blind-call edges, fluent continuations, markers, comments, and block boundaries. Active frontier
advances to `DART-BACKEND-PARITY.2.3` for frontend validation and strict syntax behavior.

Index note 2026-07-09: `DART-BACKEND-PARITY.2.3` is done. Dart `validateSpec(...)` now validates parsed
source ASTs in non-strict and strict modes, covering top-rule presence, duplicates, function registry
records, edge consistency, target references/indexes, malformed raw lines, regex structure, and unused rules
in strict mode. Active frontier advances to `DART-BACKEND-PARITY.2.4`.

Index note 2026-07-09: `DART-BACKEND-PARITY.2.4` is done. Dart now consumes the spec-defined
`function_definition` / `function_definition_error` AST shape from `specs/user_function_definition.spec`,
normalizes function-body `body_payload` / `body_parse_job` sidecars, strips returned source spans before
rule parsing, and attaches ordered `FunctionDefinition` records without a host-language raw scanner. The
`.2` frontend container is closed; active frontier advances to `DART-BACKEND-PARITY.3.1`.

Index note 2026-07-09: `DART-BACKEND-PARITY.3.1` is done. Dart now has typed ActionIR node classes
and `parseActionBlock(...)` / `parseActionStatement(...)` / `parseActionExpression(...)` for helper/action
source. The parser covers calls, literals, access, shape literals, assignments, block values, attached
control flow, receiver chains, trailing block arguments, standalone value-drop statements, and structural
`raw_perl` fallback. Active frontier advances to `DART-BACKEND-PARITY.3.2`.

Index note 2026-07-09: `DART-BACKEND-PARITY.3.2` is done. Dart now has
`resolveActionBlockContracts(...)`, `resolveActionStatementContracts(...)`, and
`resolveActionExpressionContracts(...)` for typed ActionIR nodes. The resolver records current canonical
helper/control contracts for calls, receiver methods, structural assignments, controls, nested arguments,
block values, shapes, and access expressions; non-current helper-looking calls diagnose as `unknown_helper`.
The shared current-name table now backs Dart function-registry collision validation. Active frontier advances
to `DART-BACKEND-PARITY.3.3`.

Index note 2026-07-09: `DART-BACKEND-PARITY.3.3` is done. Dart now has
`UserFunctionRegistry` / `UserFunctionEntry` over ordered `FunctionDefinition` records, staged body parse-job
exposure, sidecar/body-AST preservation, and registry-aware ActionIR contract resolution for exact-arity user
calls before helper fallback. Active frontier advances to `DART-BACKEND-PARITY.3.4`.

Index note 2026-07-09: `DART-BACKEND-PARITY.3.4` is done. Dart now has `compileSpec(...)` and
`CompiledSpec` / `CompiledRule` / `CompiledDependencyRegexState` / `CompiledDescriptorState` over parsed
`SpecFile`s. The compiled state records ordered rule metadata, dependency refs, structured dependency-regex data,
lifecycle/action `ActionBlock` payloads with registry-aware contracts, function registry projection, and the
public descriptor shape. Active frontier advances to `DART-BACKEND-PARITY.4.1`.

Index note 2026-07-09: `DART-BACKEND-PARITY.4.1` is done. Dart now has `RuntimeRegexAlternation`,
`RuntimeRegexMatch`, and `RuntimeMatchRegisters` for seek/consume matching over compiled rule regex lists,
stable alternative indexes, capture/named-capture records, char-offset projection, entry/local match separation,
cursor state, and zero-progress detection. Active frontier advances to `DART-BACKEND-PARITY.4.2`.

Index note 2026-07-09: `DART-BACKEND-PARITY.4.2` is done. Dart now has `LinkedSpecRuntimeEngine`
over `CompiledSpec` rules, with default/AND/OR/repetition dispatch, action-edge and blind-call child execution,
lifecycle blocks, explicit returns, `retv`, accumulator collection, bounded repetition, zero-progress cutoffs,
recursion cutoffs, and focused runtime interpreter tests. Active frontier advances to `DART-BACKEND-PARITY.4.3`.

Index note 2026-07-09: `DART-BACKEND-PARITY.4.3.0` is done. The broad runtime value/helper-family leaf is split
before code into `.4.3.1` core value/store/capture helpers, `.4.3.2` string/number helpers, `.4.3.3` array
helpers, `.4.3.4` hash helpers, `.4.3.5` value-block/control/tree traversal helpers, and `.4.3.6` no-drift
closeout. Active frontier advances to `DART-BACKEND-PARITY.4.3.1`.

Index note 2026-07-09: `DART-BACKEND-PARITY.4.3.1` is done. Dart runtime values now preserve scalar, array,
hash, null, boolean, and number shapes through assignment and wrapper snapshots; hash-index mutation and
nested reads execute; and `entry_*` / `match_*` named/map/length/start/end helpers are covered by focused runtime
tests. Active frontier advances to `DART-BACKEND-PARITY.4.3.2`.

Index note 2026-07-09: `DART-BACKEND-PARITY.4.3.2` is done. Dart runtime helper execution now covers
string/scalar helpers, explicit `str_*` lexical comparisons, numeric arithmetic/reducer/comparison helpers,
numeric word aliases and arithmetic/comparison symbol callees, plus compatible receiver chains over strings and
numbers. Active frontier advances to `DART-BACKEND-PARITY.4.3.3`.

Index note 2026-07-09: `DART-BACKEND-PARITY.4.3.3` is done. Dart runtime helper execution now covers array
helper family breadth, bare array working-variable receiver chains, regex split/filter bridges, delimiter-first
`join_values`, array numeric reducers, `split_tagged_records`, and statement-only array end mutations. Active
frontier advances to `DART-BACKEND-PARITY.4.3.4`.

Index note 2026-07-09: `DART-BACKEND-PARITY.4.3.4` is done. Dart runtime helper execution now covers hash
helper family breadth, bare hash working-variable receiver chains, statement-form `set_key(...)` mutation,
pure value/receiver `set_key(...)` behavior, direct hash-index assignment values, bare-overlay `merge_hash`,
and explicit flat-style hash splicing. Active frontier advances to `DART-BACKEND-PARITY.4.3.5`.

Index note 2026-07-09: `DART-BACKEND-PARITY.7.3` is done as a docs-only planning slice. The director's
per-variant CLI requirement is recorded: each backend variant should have its own distinct LinkedSpec CLI.
Dart-specific CLI productization is split to `DART-BACKEND-PARITY.7.4`; final Dart closeout shifts to `.7.5`.
The implementation frontier later advanced through `DART-BACKEND-PARITY.4.3.5`.

Index note 2026-07-09: `DART-BACKEND-PARITY.7.1` is done. The mdBook now documents the focused Dart gate,
optional `LINKEDSPEC_RUN_DART=1` local-CI inclusion, direct `dart test` and full corpus-runner commands, the
interpreter-first 99/99 corpus parity boundary, and remaining generated-source / Dart-specific CLI follow-ups.
Active frontier advances to `DART-BACKEND-PARITY.7.2`.

Index note 2026-07-09: `DART-BACKEND-PARITY.7.2` is done. Generated Dart source is deliberately deferred instead
of implemented as a one-slice add-on. A future source-emitter lane must split scaffold/compile-run harness,
generated family-plan metadata, direct structural-family execution, and curated manifest-backed corpus proof. The
interpreter-first 99/99 corpus run remains the Dart conformance gate; active frontier advances to
`DART-BACKEND-PARITY.7.4`.

Index note 2026-07-09: `DART-BACKEND-PARITY.7.4` is done. Dart-specific CLI productization is complete:
`dart/bin/linkedspec_dart.dart` owns backend help text plus the `corpus --corpus <path> [--execute] ...` command,
which routes through the existing manifest-backed Dart parser/compiler/runtime harness. The compatibility
`dart/bin/corpus_runner.dart` wrapper remains available for corpus-focused diagnostics. Active frontier advances
to `DART-BACKEND-PARITY.7.5` for final no-drift closeout.

Index note 2026-07-09: `DART-BACKEND-PARITY.7.5` is done, closing the Dart scoped interpreter-first milestone.
The Dart tree has no active frontier: parser/frontend, typed ActionIR, compiled state, runtime interpretation,
staged user-function execution, diagnostics/trace, focused local verification, Dart-specific CLI productization,
99/99 corpus execution, mdBook/live-doc alignment, and generated-source deferral are all recorded. That handoff
has since completed in `FUTURE-PARITY-BACKLOG.1.2`; the active backend frontier has moved through
`JULIA-BACKEND-PARITY.4.3.0` and now sits at `JULIA-BACKEND-PARITY.4.3.1`. Generated Dart source remains a future
split proof lane.

Index note 2026-07-09: `FUTURE-PARITY-BACKLOG.1.2` is done. It created
`docs/tasks/JULIA-BACKEND-PARITY.md`, selected interpreter-first Julia parity, required a distinct Julia
LinkedSpec CLI in package planning, and deferred generated Julia source to a later proof decision. At that point
the next active frontier was `JULIA-BACKEND-PARITY.1.1` for Julia toolchain/package-layout preflight.

Index note 2026-07-10: `JULIA-BACKEND-PARITY.1.1` is done. `/opt/homebrew/bin/julia`
reports Julia 1.12.6, Homebrew owns the installed formula, and the official Julia downloads page lists 1.12.6 as
the current stable release. The planned `julia/` package layout, `Pkg.instantiate()` / `Pkg.test()` commands,
optional `JuliaFormatter` / `JET` commands, `julia/bin/linkedspec_julia.jl` CLI, and
`julia/bin/corpus_runner.jl` corpus runner are recorded. Active frontier advances to
`JULIA-BACKEND-PARITY.1.2`.

Index note 2026-07-10: `JULIA-BACKEND-PARITY.1.2` is done. The repo-owned `julia/`
package scaffold now has `Project.toml`, committed `Manifest.toml`, README commands,
`src/LinkedSpecJulia.jl`, CLI/corpus modules, `bin/linkedspec_julia.jl`,
`bin/corpus_runner.jl`, and a smoke test. `Pkg.instantiate()`, `Pkg.test()`, Julia CLI
help/status, and corpus-runner scaffold commands pass with a writable depot. Active
frontier advances to `JULIA-BACKEND-PARITY.1.3` for manifest-backed corpus IO and drift
detection before parser/runtime semantics.

Index note 2026-07-10: `JULIA-BACKEND-PARITY.1.3` is done. Julia corpus IO now loads the
checked-in 99-fixture manifest, validates manifest format/count/names, detects missing/stale
fixture directories, requires `input.spec` / `input.txt` / `expected.json`, and parses expected
JSON through JSON3. `--execute` remains rejected. The `.1` foundation container is closed, and
active frontier advances to `JULIA-BACKEND-PARITY.2.1`.

Index note 2026-07-10: `JULIA-BACKEND-PARITY.2.1` is done. Julia source AST/data types now
round-trip through JSON for spec files, function definitions, source spans, staged parse jobs, rules,
rule modes, body elements, edges, and fluent calls. Active frontier advances to `JULIA-BACKEND-PARITY.2.2`.

Index note 2026-07-10: `JULIA-BACKEND-PARITY.2.2` is done. Julia `parse_spec(...)` now parses
core `.spec` rule paragraphs into source AST types, including headers/modes, regex slots, lifecycle blocks,
action/blind-call edges, fluent continuations, markers, comments, and block boundaries. Active frontier advances to
`JULIA-BACKEND-PARITY.2.3`.

Index note 2026-07-10: `JULIA-BACKEND-PARITY.2.3` is done. Julia `validate_spec(...)` now validates
parsed source ASTs for top-rule presence, duplicate rule/function definitions, function registry collisions,
raw fallback lines, mixed edge families, grouped action blocks, undefined references, regex-slot bounds,
regex structure, and strict unused-rule checks. Active frontier advances to `JULIA-BACKEND-PARITY.2.4`.

Index note 2026-07-10: `JULIA-BACKEND-PARITY.2.4` is done. Julia consumes the spec-defined
`function_definition` / `function_definition_error` node shape from `specs/user_function_definition.spec`,
validates source/body spans and staged sidecars, strips function spans before rule parsing, and keeps direct
`parse_spec(...)` rule-only. The `.2` frontend container is closed; active frontier advances to
`JULIA-BACKEND-PARITY.3.1`.

Index note 2026-07-10: `JULIA-BACKEND-PARITY.3.1` is done. Julia now has typed ActionIR parsing for action
blocks, value-drop statements, calls, literals, direct/nested access, shape literals, assignments, receiver chains,
trailing blocks, block values, structured controls, and raw fallback nodes. Active frontier advances to
`JULIA-BACKEND-PARITY.3.2` for helper-contract resolution and diagnostics.

Index note 2026-07-10: `JULIA-BACKEND-PARITY.3.2` is done. Julia now resolves typed ActionIR nodes through
current canonical helper/control contracts, records generic `unknown_helper` and `raw_perl` diagnostics, and shares
the current helper-name predicate with frontend validation. Active frontier advances to `JULIA-BACKEND-PARITY.3.3`
for the user-function registry and staged function-body parse-job records.

Index note 2026-07-10: `JULIA-BACKEND-PARITY.3.3` is done. Julia now records ordered user-function registry
entries, exposes staged function-body parse-job queues, immutably stitches parsed body ASTs back into `SpecFile`,
rejects duplicate function names through registry construction, and lets ActionIR contract resolution classify
exact-arity registered user calls before helper fallback while diagnosing wrong arity. Active frontier advances to
`JULIA-BACKEND-PARITY.3.4` for compiled-spec and interpreter-state construction.

Index note 2026-07-10: `JULIA-BACKEND-PARITY.3.4` is done. Julia now has `compile_spec(...)` and
`CompiledSpec` / `CompiledRule` / `CompiledDependencyRegexState` / `CompiledDescriptorState` over parsed
`SpecFile`s. The compiled state records ordered rules, dependency refs, dependency-regex rows, lifecycle/action
payload ASTs with registry-aware contracts, function registry projection, mode metadata, and descriptor JSON.
Active frontier advances to `JULIA-BACKEND-PARITY.4.1` for regex matching and match-state tracking.

Index note 2026-07-10: `JULIA-BACKEND-PARITY.4.1` is done. Julia now compiles stable indexed native-PCRE
alternatives, executes seek/consume selection, preserves full/compact/named captures, projects zero-based code-unit
spans into public character and line/column positions, separates entry/local match registers, tracks cursor and
capture anchors, and detects zero-width/zero-progress matches. Active frontier advances to
`JULIA-BACKEND-PARITY.4.2` for first executable rule dispatch over compiled state.

Index note 2026-07-10: `JULIA-BACKEND-PARITY.4.2` is done. Julia now executes compiled default, AND, OR, and
repetition rule families with seek/consume matching, lifecycle events, action/blind child dispatch, `retv`,
explicit returns, narrow accumulators/capture reads, one-element output projection, repetition bounds,
zero-progress termination, and same-rule/slot/cursor recursion cutoffs. Active frontier advances to
`JULIA-BACKEND-PARITY.4.3`; `.4.3.0` has since split that broad helper/value container into safe owned batches.

Index note 2026-07-10: `JULIA-BACKEND-PARITY.4.3.0` is done. The `.4.3` helper/value container is split before
broader evaluator code into `.4.3.1` core stores/captures, `.4.3.2` string/numeric helpers, `.4.3.3` arrays,
`.4.3.4` hashes, `.4.3.5` value/control/block/callback execution, and `.4.3.6` no-drift closeout. Active frontier
advances to `.4.3.1`; the Julia runtime behavior remains at the `.4.2` 550-assertion baseline.

Index note 2026-07-10: `JULIA-BACKEND-PARITY.4.3.1` is done. Julia now preserves portable scalar/array/hash
value shapes through typed and bare snapshots, assignments, direct/nested access, and final checked
no-autovivification nested writes; entry/local named maps and source positions are exposed too. Active frontier
advances to `.4.3.2` for string/scalar and numeric helpers; full Julia tests pass with 554 assertions.

Index note 2026-07-10: `JULIA-BACKEND-PARITY.4.3.2` is done. Julia now executes current string/scalar and numeric
helpers through one canonical dispatcher, preserving regex flags, aliases/symbol callees, receiver composition,
and invalid-input `nothing` behavior. Active frontier advances to `.4.3.3` for array-aware helper and mutation
behavior; full Julia tests pass with 556 assertions.

Index note 2026-07-10: `JULIA-BACKEND-PARITY.4.3.3` is done. Julia now executes copied array helper/receiver
pipelines, string/regex/split bridges, explicit flatten splicing, numeric terminals, typed split replacement, and
statement-only named/scalar-held end mutations with value-position no-op behavior. Active frontier advances to
`.4.3.4` for hashes; full Julia tests pass with 558 assertions.

Index note 2026-07-10: `JULIA-BACKEND-PARITY.4.3.4` is done. Julia now executes copied hash helper/receiver
views and transformations, statement-only named set-key mutation, direct hash-index assignment, base/overlay-aware
merge resolution, explicit flat-style splicing, and ordinary nested-map preservation. Active frontier advances to
`.4.3.5` for value/control/block/callback execution; full Julia tests pass with 559 assertions.

Index note 2026-07-10: `JULIA-BACKEND-PARITY.4.3.5` is done. Julia now executes expression-valued blocks with
block-local returns, attached and marker statement controls, lazy inline branches, deterministic while guards,
helper/receiver with-blocks, and scoped hash/array walk/map/reduce callbacks with lazy non-aggregate failure.
Active frontier advances to `.4.3.6` for final helper/value no-drift; full Julia tests pass with 567 assertions.

Index note 2026-07-10: `JULIA-BACKEND-PARITY.4.3.6` is done. Julia's helper/value tests, package status, mdBook
contracts, live docs, and Knowledge Map agree at 567 assertions; the final nested-write contract was already
correct, stale `.3`/`.4.3` parent metadata is reconciled, and central helper-catalog examples follow separator-only
semicolon style. Active frontier advances to `.4.4` for cursor controls and boundary capture.

Index note 2026-07-10: `JULIA-BACKEND-PARITY.4.4` is done. Julia now has an explicit LIFO cursor stack,
entry/local anchor rewinds, synchronized live/register cursor updates, character-based cursor/input helpers, and
earliest usable non-consuming boundary capture with EOF/unresolved-rule behavior. Active frontier advances to
`.4.5` for runtime diagnostics and trace controls; full Julia tests pass with 581 assertions.

Index note 2026-07-10: `JULIA-BACKEND-PARITY.4.5.0` is done. The diagnostics/trace container is split before
code into `.4.5.1` structured diagnostics, `.4.5.2` trace controls/events/sinks, `.4.5.3` runtime
instrumentation, and `.4.5.4` no-drift closeout. Active frontier advances to `.4.5.1`; Julia runtime behavior and
package status remain unchanged.

Index note 2026-07-10: `JULIA-BACKEND-PARITY.4.5.1` is done. Exported Julia `RuntimeDiagnostic` payloads now
carry neutral diagnostic fields through `RuntimeInterpreterException`, preserving optional spec identity and
top/rule/handler attribution without changing successful parse output. Active frontier advances to `.4.5.2` for
trace controls/events/sinks; full Julia tests pass with 588 assertions.

Index note 2026-07-10: `JULIA-BACKEND-PARITY.4.5.2` is done. Julia now exports ordered trace levels,
environment/config controls, structured event/scope/decision/log/dump primitives, stdout/route/mirror sinks with
reset, and opt-in traced runtime entrypoints that preserve output. Active frontier advances to `.4.5.3` for
runtime instrumentation; full Julia tests pass with 617 assertions.

Index note 2026-07-10: `JULIA-BACKEND-PARITY.4.5.3` is done. Julia runtime tracing now emits rule scopes, regex
decisions, action/blind child dispatch, lifecycle marks, recursion cutoffs, cursor transitions, and source-boundary
events while preserving untraced results. Active frontier advances to `.4.5.4` diagnostics/trace no-drift; full
Julia tests pass with 631 assertions and status `runtime-trace-events`.

Index note 2026-07-10: `JULIA-BACKEND-PARITY.4.5.4` is done. Julia's 631-assertion diagnostics/trace boundary,
package/CLI status `runtime-trace-events`, README, mdBook, Knowledge Map, roadmap/task/live docs, and architecture
are no-drift without a source correction. `.4.5` closes and `.5.1` staged registry provider execution is active.

Index note 2026-07-10: `JULIA-BACKEND-PARITY.5.1` is done. Julia now resolves/loads/compiles/executes the built-in
ActionIR body provider in stable queue order, records portable cache/compiled/result metadata, and immutably
stitches neutral JSON `body_ast`. Full tests pass with 662 assertions and status `runtime-staged-registry`;
`.5.2` registered user-function runtime execution has since landed.

Index note 2026-07-10: `JULIA-BACKEND-PARITY.5.2` is done. Julia now resolves registered exact-arity calls before
helper fallback, evaluates args eagerly, executes cached ActionIR bodies with fresh scalar/array/hash stores,
restores caller stores, supports value/receiver/drop positions, and diagnoses direct/mutual recursion. Full tests
pass with 671 assertions and status `runtime-user-functions`; `.5.3` has since closed `.5`.

Index note 2026-07-10: `JULIA-BACKEND-PARITY.5.3` is done. Twenty assertions preserve two spec-returned functions
through source order, normalized payload/jobs, stitched bodies, compiled registry, descriptor metadata, and runtime
output. Full tests pass with 691 assertions; status remains `runtime-user-functions`, `.5` closes, and `.6.1`
controlled corpus execution is active.

Index note 2026-07-10: `JULIA-BACKEND-PARITY.6.1` is done. Julia now exposes controlled corpus execution with
manifest validation, parse/compile/runtime composition, one-level wrapped structural output comparison, optional
trace capture, structured runtime diagnostics, and all-fixture failure reporting. Twenty-four focused assertions
bring the full suite to 715 with status `runtime-controlled-corpus`; `.6.2.0` has since split the rollout and
`.6.2.1` through `.6.2.5` have since landed; `.6.3` is active.

Index note 2026-07-10: `JULIA-BACKEND-PARITY.6.2.0` is done. The 99-fixture Julia rollout is split into bounded
selection/reporting, starter 0–39, middle non-function 40–67, shipped-spec/parser-smoke 68–98, and spec-defined
function-shell owners before behavior changes. `.6.2.1` has since landed.

Index note 2026-07-10: `JULIA-BACKEND-PARITY.6.2.1` is done. Ordered named and offset/limit library selection plus
bounded runner PASS/FAIL reporting are green with strict selection/unbounded guards. Thirty added assertions bring
full tests to 745 with status `runtime-corpus-selection`; `.6.2.2` has since closed 40/40.

Index note 2026-07-10: `JULIA-BACKEND-PARITY.6.2.2` is done. Shipped manifest fixtures 0–39 pass 40/40 unchanged,
and six permanent assertions lock the exact window and empty failure ledger. Full tests pass with 751 assertions
and status `runtime-corpus-starter` at that boundary; `.6.2.3` has since closed 25/25.

Index note 2026-07-10: `JULIA-BACKEND-PARITY.6.2.3` is done. Non-function manifest windows 40–56, 58–59, and
62–67 pass 25/25 unchanged, and six permanent assertions lock exact windows/endpoints, empty failures, and the
three top-level function routes to `.6.2.5`. Full tests pass with 757 assertions and status
`runtime-corpus-middle`; `.6.2.4.0` has since split the shipped-smoke diagnostic boundary.

Index note 2026-07-10: `JULIA-BACKEND-PARITY.6.2.4.0` is done. The complete shipped-spec/parser-smoke window
starts at 10 passed / 21 failed. Capture-boundary, logical/output helper, recursive top-rule, EBNF/spec.spec
structural-output, lib_reader quote-normalization, and final no-drift work now have separate owners before Julia
behavior changes; `.6.2.4.1` has since closed the capture-helper group.

Index note 2026-07-10: `JULIA-BACKEND-PARITY.6.2.4.1` is done. The complete direct anonymous capture family is
Unicode/location/mutation safe, all three hlink delimiter fixtures pass, and EBNF logging is routed to its
structural-output owner. Full tests pass with 766 assertions and status `runtime-corpus-capture-boundaries`; the
window is 13/31 and `.6.2.4.2.1` has since closed eager logical helpers.

Index note 2026-07-10: `JULIA-BACKEND-PARITY.6.2.4.2.1` is done. Eager `and`/`or`/`not` closes three portmap
cases plus tablegrep. Direct captures and runtime trace route portmap constant's remaining mismatch to helper-regex
flag normalization under `.6.2.4.2.3`. Full tests pass with 772 assertions and status
`runtime-corpus-logical-helpers` at that boundary; `.6.2.4.2.3` has since closed the residual.

Index note 2026-07-10: `JULIA-BACKEND-PARITY.6.2.4.2.3` is done. Strict shared helper regex compilation keeps
`imsx`, ignores runtime-only `g` and Perl no-op `o`, and rejects unknown flags. Portmap constant passes; full tests
remain 772, shipped smoke is 18/31, and `.6.2.4.2.2` has since closed diagnostic output.

Index note 2026-07-10: `JULIA-BACKEND-PARITY.6.2.4.2.2` is done. Trace-routed `print`/`print_each`/`say` return
no parse value and advance simenv to unsupported `exit_now` and history to its leading-trivia output mismatch.
Full tests pass with 780 assertions, shipped smoke remains 18/31, status is
`runtime-corpus-diagnostic-output`, and `.6.2.4.2` closes.

Index note 2026-07-10: `JULIA-BACKEND-PARITY.6.2.4.3` is done. First-reset rule-local snapshots preserve caller
array/hash bindings across recursive explicit resets while leaving ordinary child mutation visible. All three
recursive fixtures pass; full tests pass with 785 assertions, shipped smoke is 21/31, status is
`runtime-corpus-recursive-rule-scope` at that boundary.

Index note 2026-07-10: `JULIA-BACKEND-PARITY.6.2.4.4` is done. Action-edge child-push precedence/reuse closes all
four spec.spec smokes. Both EBNF cases preserve complete structures and route quote-only statement mutation to
`.6.2.4.5.2`. Full tests pass with 793 assertions, shipped smoke is 25/31, status is
`runtime-corpus-action-edge-child-push` at that boundary.

Index note 2026-07-10: `JULIA-BACKEND-PARITY.6.2.4.5.1` is done. Immediate fatal `exit_now(...)` execution
preserves explicit numeric status, defaults to `1`, and retains structured runtime attribution. Simenv advances
from an unsupported helper to deliberate `exit_now(1)` in `begin_end_blocks`, exposing its earlier statement-form
mutation prerequisite. Full tests pass with 801 assertions, shipped smoke remains 25/31, status is
`runtime-corpus-exit-now` at that boundary; `.6.2.4.5.2`, `.5.3`, and `.6.2.4.6` have since closed.

Index note 2026-07-10: `JULIA-BACKEND-PARITY.6.2.4.5.2` is done. Statement-context four-argument scalar regex
substitution preserves strict flags and `$n` expansion while numeric slicing remains pure. Both EBNF, both
lib_reader, and simenv fixtures pass. Full tests pass with 808 assertions, shipped smoke is 30/31, status is
`runtime-corpus-statement-mutation` at that boundary; `.6.2.4.5.3` has since closed history, and `.6.2.4.6` is
active.

Index note 2026-07-10: `JULIA-BACKEND-PARITY.6.2.4.5.3` is done. Julia now mirrors public-parser leading
blank/comment skipping through its in-memory runtime cursor seam, so history matches the null-object oracle while
ordinary indexed reads remain intact. Full tests pass with 810 assertions, shipped smoke is 31/31, status is
`runtime-corpus-leading-trivia` at that boundary; `.6.2.4.6` has since closed final no-drift.

Index note 2026-07-10: `JULIA-BACKEND-PARITY.6.2.4.6` is done. One permanent offset-68/limit-31 regression locks
the full shipped window's counts, endpoints, 31/31 pass result, zero failures, and exact outputs. Full tests pass
with 816 assertions, status is `runtime-corpus-shipped`, `.6.2.4` closes, and `.6.2.5` becomes active at that
boundary. That function-shell leaf has since closed and `.6.3` is active.

Index note 2026-07-10: `JULIA-BACKEND-PARITY.6.2.5` is done. Julia executes
`specs/user_function_definition.spec` over source in memory, feeds its neutral nodes through existing staged body
parsing and runtime compilation, and passes all three routed function fixtures. Full tests pass with 827 assertions,
status is `runtime-corpus-function-shells`, no raw scanner was added, and `.6.3` is active for the full-manifest gate.

Index note 2026-07-10: `JULIA-BACKEND-PARITY.6.3` is done. Complete validation precedes one ordered 99-fixture
library gate and unbounded CLI execution; both pass 99/99 with exact outputs and zero failures. Full tests pass with
840 assertions, status is `runtime-corpus-full`, and `.6.4` becomes active for verification wiring at that
boundary. That leaf has since closed.

Index note 2026-07-10: `JULIA-BACKEND-PARITY.6.4` is done. `tools/run_julia_local.sh` owns package tests, Julia
CLI checks, and full 99-fixture execution with configurable executable/depot paths. Shared local CI includes it
only under `LINKEDSPEC_RUN_JULIA=1`, preserving SDK-independent defaults; `.7.1` becomes active at that boundary
and has since closed.

Index note 2026-07-10: `JULIA-BACKEND-PARITY.7.1` is done. The mdBook now presents Julia as a native in-memory
99/99 interpreter backend with self-contained rule/function examples, focused/direct/opt-in commands, current
status, and precise generated-source/trace/tooling limitations. `.7.2` is active for generated-source disposition.

Index note 2026-07-10: `JULIA-BACKEND-PARITY.7.2` is done. Generated Julia source is deferred to
`FUTURE-PARITY-BACKLOG.3`, where a future split must own emitter/compile-run, family-plan, direct structural, and
curated corpus proof. Native interpreter parity remains 99/99; `.7.3` is active for final no-drift closeout.

Index note 2026-07-10: `JULIA-BACKEND-PARITY.7.3.0` is done. The director clarified that all variants must have
the exact same user-visible features/behavior and that distinct CLI executables must expose the identical command
API. Source audit proves current CLI drift: Perl is parser-oriented, Dart/Julia are corpus/status-oriented, and
Rust has no binary target. `.7.3.1` is active for the durable contract and cross-backend repair ownership.

Index note 2026-07-10: `JULIA-BACKEND-PARITY.7.3.1` / delegated `FUTURE-PARITY-BACKLOG.1.5.0` are done. ADR
`0023` makes complete parity exact user-observable capability/behavior identity and gives distinct backend command
names one parser-oriented interface with no subcommands or positional arguments. Julia `.7.3.2` is active;
global `.1.5`, `.1.6`, and `.3` own CLI, full capability, and public generated-source convergence before Lua.

Index note 2026-07-10: `JULIA-BACKEND-PARITY.7.3.2.0` is done. Source audit found reusable native parser/
compiler/runtime, structured diagnostics, and runtime trace sinks, but five distinct CLI mechanisms. `.7.3.2.1`
has since closed compile/parser/staged tracing, followed by argument/IO, execution/JSON, error/routing, and direct
conformance leaves. No implementation behavior changed in the split.

Index note 2026-07-10: `JULIA-BACKEND-PARITY.7.3.2.1` is done. Julia's existing optional emitter now propagates
through parse/validation/compile, spec-driven function-shell parsing and runtime execution, and staged job phases.
Twenty-eight focused assertions, the 868-assertion package suite, CLI smokes, and 99/99 corpus gate pass;
`.7.3.2.2` has since closed exact primary arguments plus source/input resolution and loading.

Index note 2026-07-10: `JULIA-BACKEND-PARITY.7.3.2.2` is done. Julia's primary module accepts only ADR `0023`
options, rejects subcommands/positionals, resolves named specs through deterministic current/repository/fallback
precedence, and loads exact file/inline content. Fifty focused assertions, 920 package assertions, direct CLI
checks, and 99/99 pass; `.7.3.2.3` has since closed native execution and canonical JSON.

Index note 2026-07-10: `JULIA-BACKEND-PARITY.7.3.2.3` is done. Rule-only and top-level-function requests flow
through the native traced parse/compile/runtime pipeline with top-rule and parse-mode controls. The direct top-rule
value is recursively serialized with sorted object keys and one newline. Twenty-two focused assertions, 942
package assertions, direct canonical primary smoke, and 99/99 pass; `.7.3.2.4` has since closed normalized failures,
exit status, and trace routing.

Index note 2026-07-10: `JULIA-BACKEND-PARITY.7.3.2.4` is done. Source compilation precedes deferred input-file
loading; stable compilation/input/invocation stderr exits `1`, usage exits `2`, and stdout/route/mirror plus file,
reset, quiet, and emoji controls compose with canonical JSON. Seventy-five focused assertions, 1,017 package
assertions, and 99/99 pass; `.7.3.2.5` has since closed direct-process/no-drift.

Index note 2026-07-10: `JULIA-BACKEND-PARITY.7.3.2.5` and parent `.7.3.2` are done. A standalone checker locks
nine real-process help/success/usage/operational/route/mirror families with exact output/newline/file bytes and
exit 0/1/2. The focused gate retains 1,017 package assertions and 99/99; status is the precise local milestone
`runtime-corpus-primary-cli`. `.7.3.3` has since closed honest outer no-drift; global parity remains separately owned.

Index note 2026-07-10: `JULIA-BACKEND-PARITY.7.3.3` is done. One stale mdBook sentence that denied the now-
implemented exact Julia primary CLI is corrected. The Julia tree remains active/delegated rather than falsely
complete because `.1.5`, `.1.6`, and `.3` still own cross-backend CLI identity, capability census, and generated
source. PNT advances to `FUTURE-PARITY-BACKLOG.1.5.1`.

Index note 2026-07-10: `FUTURE-PARITY-BACKLOG.1.5.1.0` is done. Perl's current parser CLI ignores positionals,
accepts case/abbreviation/negated aliases, inherits environment-dependent `Getopt::Long` policy, and leaks
timestamped level-zero failure trace to stdout. Neutral harness/help, strict arguments, success/IO, operational
failures, and trace/gate are split before code; `.1.5.1.1` has since closed the runner/help baseline.

Index note 2026-07-10: `FUTURE-PARITY-BACKLOG.1.5.1.1` is done. `cli_conformance/manifest.json` and the arbitrary-
command runner now lock isolated fixture workspaces, raw stdout/stderr, exit status, generated files, safe paths,
explicit placeholders, and exact backend-neutral help. Four runner subtests (13 assertions), two trace CLI
subtests, and direct Perl help conformance pass; `.1.5.1.2` has since closed strict argument/usage fixtures.

Index note 2026-07-10: `FUTURE-PARITY-BACKLOG.1.5.1.2` is done. Perl uses one explicit case-sensitive parser;
20 shared usage cases reject all positional/subcommand/case/abbreviation/negation/invalid-value drift with exact
stderr and exit `2`. Together with both help forms, 22/22 pass under default and `POSIXLY_CORRECT=1` environments.
`.1.5.1.3` has since closed successful source/input/parser controls and canonical bytes.

Index note 2026-07-10: `FUTURE-PARITY-BACKLOG.1.5.1.3` is done. Seven shared success cases lock named/file/inline
source, literal/file input, explicit top rule, seek/consume, recursively canonical nested JSON, exact input-newline
bytes, empty stderr, exit `0`, and one record newline. The suite is 29/29 in default/POSIX environments;
`.1.5.1.4` has since closed operational failures and stdout purity.

Index note 2026-07-10: `FUTURE-PARITY-BACKLOG.1.5.1.4` is done. Four shared cases lock compile-before-input,
missing source/input, missing-top-rule invocation, empty failure stdout, exact one-line stderr, exit `1`, and no
files. Ambient backend trace state cannot opt in an untraced primary command; 33/33 pass in default/POSIX
environments. `.1.5.1.5` has since closed explicit trace and reusable-runner local-gate integration.

Index note 2026-07-10: `FUTURE-PARITY-BACKLOG.1.5.1.5` closes canonical trace. ADR `0024` defines one phase trace
while native embedding retains rich internals. Twenty exact trace cases bring the current Perl suite to 53/53 and
the local gate runs it under default/POSIX environments. Signoff exposed `xé` argv serializing as `xÃ©`; active
`.1.5.1.6` owns the UTF-8 reference boundary before pending Rust `.1.5.2`, so parent `.1.5.1` remains active.

Index note 2026-07-10: `FUTURE-PARITY-BACKLOG.1.5.1.6.0` is done. ADR `0025` defines strict preserved UTF-8 text
for primary args/source/input/JSON/trace. Decoded Perl native probes are exact, isolating mojibake to the adapter.
The work is split into neutral runner hex bytes (`.6.1`, active), Perl decoding/fixtures (`.6.2`), and no-drift
closure (`.6.3`) before Rust.

Index note 2026-07-10: `FUTURE-PARITY-BACKLOG.1.5.1.6.1` is done. Schema-v1 input files now accept exactly one
checked-in `source` or non-empty lowercase even-length `bytes_hex`; raw materialization and six focused runner
subtests lock exact non-text bytes plus malformed/ambiguous pre-launch errors. `.6.2` is active for Perl decoding
and valid/invalid UTF-8 behavior fixtures.

Index note 2026-07-10: `FUTURE-PARITY-BACKLOG.1.5.1.6.2` is done. Perl now strictly decodes valid argv and raw
source/input files, preserves code points/BOM/newlines/normalization, emits recursive canonical UTF-8 JSON once,
and keeps invalid files in stable compilation/input phases. Eight exact cases expand the shared manifest to
61/61 in default/POSIX environments; `.6.3` has since closed final reference no-drift.

Index note 2026-07-10: `FUTURE-PARITY-BACKLOG.1.5.1.6.3` is done. Parent `.1.5.1`/`.1.5.1.6` are closed, current
surfaces agree on the strict 61-case Perl reference, Rust `.1.5.2.4` closes all 61 unchanged cases in both
environments with recurring verification, and Dart `.1.5.3` is the active frontier against the unchanged
manifest. Historical 53-case and initiating-mojibake entries remain dated evidence rather than live status.

Index note 2026-07-10: `FUTURE-PARITY-BACKLOG.1.5.3.0` is done. Dart's current primary executable is a
corpus-oriented command and passes 0/61 unchanged primary-command cases, while the native staged parser,
validation/compiler, direct-value runtime, top-rule/global-mode controls, rich trace, and canonical-JSON pattern
already exist. `.1.5.3.1` is active for the exact process boundary/loading replacement; execution/results,
canonical trace, and recurring default/POSIX closeout follow in `.2`-`.4`. `bin/corpus_runner.dart` remains the
separate developer corpus surface.

Index note 2026-07-10: `FUTURE-PARITY-BACKLOG.1.5.3.1` is done. Dart now exposes the exact shared primary
arguments/help, deterministic source resolution, strict preserved UTF-8, compile-before-input phases, and stable
raw failures while `bin/corpus_runner.dart` retains corpus-only behavior. The staged extractor now accepts an
ordinary spec with no user functions. The exact subset is 29/29 in default/POSIX environments, all 147 Dart tests
and 99/99 corpus pass, and `.1.5.3.2` is active for the 11 direct-result cases before 21 trace cases under `.3`.

Index note 2026-07-10: `FUTURE-PARITY-BACKLOG.1.5.3.2` is done. The primary adapter now executes through native
`LinkedSpecRuntimeEngine` entry/mode controls, serializes direct `RuntimeParseResult.value`, recursively sorts map
keys, and emits compact UTF-8 JSON plus one newline. All 11 result cases and quiet trace pass in default/POSIX;
the full baseline is 41/61 with exactly 20 canonical-trace residuals under active `.1.5.3.3`.

Index note 2026-07-10: `FUTURE-PARITY-BACKLOG.1.5.3.3` is done. An adapter-local ADR `0024` trace remains
independent of rich Dart trace while matching exact levels/events, UTF-8 byte counts, escaping, emoji, sinks,
reset/append/persistence, and phase failures. Focused tests, full Dart/99-corpus gates, and all 61 unchanged cases
pass default/POSIX. `.1.5.3.4` is active for recurring-gate integration and final no-drift.

Index note 2026-07-10: `FUTURE-PARITY-BACKLOG.1.5.3.4` and parent `.1.5.3` are done. The focused Dart gate passes
format/analyzer, 151 tests, 61/61 default, 61/61 POSIX, and 99/99 corpus; the broader core gate passes through
Phase 0 `1..1028` in 527 seconds. Live/public surfaces agree, and global four-backend identity `.1.5.4` is active.

Index note 2026-07-10: `FUTURE-PARITY-BACKLOG.1.5.4.0` is done. Warmed Julia passes 13/61: all 11 ordinary
results plus silent trace. Its 48 failures split into shared help/strict UTF-8/stable phase-only errors (`.1`),
independent canonical trace (`.2`), and the warmed recurring four-command driver (`.3`). `.1.5.4.1` is active.

Index note 2026-07-10: `FUTURE-PARITY-BACKLOG.1.5.4.1` is done. Julia now renders exact shared help, rejects
malformed source/input bytes as UTF-8 without text conversion, and emits phase-only primary stderr while retaining
native structured exceptions. Package tests pass 1,019 assertions and the shared suite is 42/61 default/POSIX;
all 19 residuals are canonical trace under active `.1.5.4.2`.

Index note 2026-07-10: `FUTURE-PARITY-BACKLOG.1.5.4.2` is done. Julia's primary command now emits ADR `0024`'s
canonical phases independently of rich native trace, including exact levels, byte counts, escaping, emoji, sinks,
file lifecycle, failures, and result framing. Local 1,019/nine-process/99 proof and 61/61 default/POSIX pass;
`.1.5.4.3` is active for one warmed recurring four-command gate and exact CLI-lane closeout.

Index note 2026-07-10: `FUTURE-PARITY-BACKLOG.1.5.4.3` and parent `.1.5` are done. The repo-owned matrix builds,
prepares, and warms Perl/Rust/Dart/Julia, then passes the same 61 cases in default/POSIX environments (4x2x61).
Focused backend gates and the broader Phase 0 `1..1028` gate pass; capability census `.1.6` is active.

Index note 2026-07-10: `FUTURE-PARITY-BACKLOG.1.6.0` is done with the validated machine-readable capability census.
Its 15 rows/60 backend states classify 47 pass, five partial-proof, and eight gap states. `.1.6.1`–`.1.6.5` own
current non-codegen residuals, `.1.6.6` owns closeout, and top-level `.3` retains generated-source parity. `.1.6.1`
is active for exhaustive neutral language/helper proof.

Index note 2026-07-11: `FUTURE-PARITY-BACKLOG.1.6.5.0` confirms Dart native trace injection begins at the runtime
interpreter despite complete public controls/events/sinks. Frontend/compiler `.1`, function/staged `.2`, and public
composition/admission `.3` are separately owned before behavior changes; `.1` is active.

Index note 2026-07-11: `FUTURE-PARITY-BACKLOG.1.6.5.1` propagates one optional caller emitter through Dart parse,
validation, compile, and function-registry owners with balanced failures and exact traced/untraced JSON. The full
168-test/61x2/105 gate passes; function-shell/staged `.1.6.5.2` is active and census promotion remains deferred.

Index note 2026-07-11: `FUTURE-PARITY-BACKLOG.1.6.5.2` carries the same emitter through function parser/shell,
runtime definition extraction, projection, staged queue ordering, resolve/load/compile/execute, and body stitching.
Four focused tests and the full 172-test/61x2/105 gate pass; native composition/admission `.1.6.5.3` is active.

Index note 2026-07-11: `FUTURE-PARITY-BACKLOG.1.6.5.3` adds public native loader injection and proves one routed
emitter from IO through frontend/function/staged/compiler and final runtime, plus quiet and exact structured failure
identity. Full 175-test/61x2/105 and core gates pass; Dart trace promotes at 57/1/2, parent closes, `.1.6.6` active.

Index note 2026-07-11: `FUTURE-PARITY-BACKLOG.1.6.6` enumerates exactly three non-pass census states: Rust partial
and Dart/Julia gaps for generated parser source, all owned by `.3`. Every non-codegen row passes; `.1.6` closes and
generated-source `.3` is active without a premature complete-parity claim.

Index note 2026-07-11: `LUA-BACKEND-PARITY.3.1` is done. Lua now parses helper/action blocks, statements, and
expressions into typed structural nodes with Unicode character spans, all four value kinds, both quote forms,
newline/same-line-semicolon separation, access/assignments/controls/receiver chains, and generic final-codeblock
arguments. PUC Lua and LuaJIT each pass 41/41; `.3.2` is active for current contract resolution and diagnostics.

Index note 2026-07-11: `LUA-BACKEND-PARITY.3.2` is done. Lua shares validation's exact 239-name inventory while
resolving typed calls, aliases, families, structural assignments/controls, methods, nested values, generic
unknown/raw diagnostics, and a registry-first interface. The governed `=(...)` parser alias is restored. Both
runtimes pass 46/46; `.3.3` is active for the concrete ordered function/body-job registry.

Index note 2026-07-11: `LUA-BACKEND-PARITY.3.3` is done. Lua now snapshots ordered function definitions and staged
body jobs, resolves exact arity before helpers, immutably stitches body ASTs, and prepares fresh data-only frames
from eager scalar/array/harray/codeblock values without caller capture or Lua closures. Typed recursion diagnostics
carry rule and handler-source identity. Both runtimes pass 50/50; compiled state `.3.4` is active.

Index note 2026-07-11: `LUA-BACKEND-PARITY.3.4` is done. Lua now compiles typed source into ordered effective rule/
function state, modes, resolved regex/dependency rows, action/blind/lifecycle/plain ActionIR payloads and contracts,
typed dependency diagnostics, and the exact shared four-key outward descriptor. Both runtimes pass 55/55; compiler
layer `.3` closes and regex/match-state adapter `.4.1` is active.

Index note 2026-07-11: `LUA-BACKEND-PARITY.4.1` is done. LPeg was rejected as a PCRE parser; a narrow repository
PCRE2 binding builds separately for PUC Lua/LuaJIT into disposable owned temp state. Stable seek/consume,
governed PCRE syntax, full/compact/named captures, Unicode positions, entry/local registers, zero-width presence,
progress, JSON, and typed failures pass 60/60 on both runtimes; compiled rule interpreter `.4.2` is active.

Index note 2026-07-11: `LUA-BACKEND-PARITY.4.2` is done. Lua now executes compiled default/AND/OR/repetition
families, action/blind children, lifecycle order, local stores, `retv`, `return`/`next`/`exit_now`, bounds,
direct output, and recursion/zero-progress guards. Both runtimes pass 66/66; helper-family split `.4.3.0` is active.

Index note 2026-07-11: `LUA-BACKEND-PARITY.4.3.0` is done. The complete governed runtime surface is split into
core four-kind stores/access/entry-match, scalar/string, numeric, array, harray, codeblock/control/callback,
capture/mark/input/cursor, diagnostic-output, and exhaustive no-drift leaves. `.4.3.1` is the sole active frontier.

Index note 2026-07-11: `LUA-BACKEND-PARITY.4.3.1` is done. Lua now preserves scalar/array/harray/codeblock values,
typed stores/snapshots, false/null identity, checked mixed access/assignment, current-edge `retv`, and all
entry/match capture/map/Unicode-position helpers. Both runtimes pass 69/69; scalar/string `.4.3.2` is active.

Index note 2026-07-11: `LUA-BACKEND-PARITY.4.3.2.0` is done. Pure scalar/string values, lexical comparisons, and
receivers are owned by active `.4.3.2.1`; regex/split flags and statement-only scalar mutation are `.4.3.2.2`.

Index note 2026-07-11: active `LUA-BACKEND-PARITY.4.3.2.1.0` measured a previously unspecified Unicode casing
contract gap: Perl/Rust, Dart, and Julia disagree on special cases such as `ß`, `İ`, and `ﬃ`. Deterministic non-case
pure helpers move to `.4.3.2.1.1`; `.4.3.2.1.2` owns a versioned all-variant casing decision and implementation.

Index note 2026-07-11: `LUA-BACKEND-PARITY.4.3.2.1.1` is done at 70/70 on PUC Lua and LuaJIT. Lazy coalesce,
non-case scalar/string helpers, Unicode trim/length/substrings, lexical comparisons, and receiver chains execute.
Unicode casing `.4.3.2.1.2` is active; measured scalar-to-text host drift follows under `.4.3.2.1.3`.

Index note 2026-07-12: `LUA-BACKEND-PARITY.4.3.2.1.2.0` adopts Unicode 17.0.0 full Default Case Conversion,
locale-independent with standard context rules and no implicit normalization. Active `.1` adds verified official
data/generation/neutral fixtures; `.2` aligns Perl/Rust, `.3` Dart/Julia, and `.4` Lua plus six-variant admission.

Index note 2026-07-12: `LUA-BACKEND-PARITY.4.3.2.1.2.1` is done. Exact gzip-preserved Unicode 17 inputs generate
1,563 lower/1,581 upper mappings, 158/464 merged property ranges, Final_Sigma, and 12 fixtures; the offline checker
is in full CI. Active `.2` now aligns Perl and Rust without host-Unicode fallback.

Index note 2026-07-12: `LUA-BACKEND-PARITY.4.3.2.1.2.2` is done. Generated Perl/Rust modules now own scalar,
receiver, and array casing with all 12 fixtures and full backend gates green; active `.3` aligns Dart and Julia.

Index note 2026-07-12: `LUA-BACKEND-PARITY.4.3.2.1.2.3` is done. Generated Dart/Julia modules pass all 12 fixtures
and full local gates; active `.4` aligns PUC Lua/LuaJIT and admits exact six-variant Unicode casing.

Index note 2026-07-12: `LUA-BACKEND-PARITY.4.3.2.1.2.4` closes Unicode casing. PUC Lua/LuaJIT pass 71/71 and all
six variants share 12 exact fixtures; active `.4.3.2.1.3` aligns scalar-to-text coercion.

Index note 2026-07-12: `LUA-BACKEND-PARITY.4.3.2.1.3` closes pure scalar/string parity. ADR `0028` and one
neutral fixture align typed `cat` coercion across Perl/Rust/Dart/Julia/PUC Lua/LuaJIT; Lua passes 72/72 on both
ABIs. Regex/split/mutation `.4.3.2.2` is active.

Index note 2026-07-12: `LUA-BACKEND-PARITY.4.3.2.2.0` splits the remaining string runtime work by mechanism.
Active `.1` owns typed helper-regex values, governed flags, and `matches`; `.2` owns pure split/receiver bridging;
`.3` scalar regex mutation; `.4` explicit array split replacement; `.5` corpus/public no-drift.

Index note 2026-07-12: `LUA-BACKEND-PARITY.4.3.2.2.1` is done. Function and terminal-receiver `matches` reuse
in-process PCRE2 with strict `i/m/s/x`, no-op `g/o`, and fail-closed unknown/invalid input. Both Lua ABIs pass
73/73; pure literal/regex split and receiver continuation `.2` is active.

Index note 2026-07-12: `LUA-BACKEND-PARITY.4.3.2.2.2` is done. Literal and PCRE2 split values preserve empty
fields; empty delimiters split strict UTF-8 scalars; zero-width patterns progress safely; receiver form stays pure.
Both Lua ABIs pass 74/74; statement scalar substitution `.3` is active.

Index note 2026-07-12: `LUA-BACKEND-PARITY.4.3.2.2.3` is done. Dropped four-argument `substr`/`regex_subst`
mutate bare scalar targets with strict flags, first/global replacement, `$0`/`$n`, Unicode-safe zero-width
progress, and rule-attributed invalid diagnostics. Both Lua ABIs pass 75/75; explicit array split `.4` is active.

Index note 2026-07-12: `LUA-BACKEND-PARITY.4.3.2.2.4` is done. Dropped `split(array(target), source, delimiter)`
replaces only the explicit typed aggregate through copied pure split semantics; scalar-held/source values stay
unchanged. Both Lua ABIs pass 76/76; regex/split corpus and public no-drift `.5` is active.

Index note 2026-07-12: `.4.3.2.2.5.0` routes premature shipped proof correctly. Direct probes stop at later-owned
`control_if`, `print`, or array/child-flow breadth, and the official runner rejects execution until phase 6. Exact
named cases now sit in `.6.2`; focused string public no-drift `.5.1` is active.

Index note 2026-07-12: `FUTURE-PARITY-BACKLOG.12.0` captures the director's settled doctrine that every construct
is a four-kind expression, unused values drop silently, dispatch is duck-typed, trailing codeblocks are signature-
governed, and backward compatibility is temporary. `.12.1` owns eventual wrapper/storage compatibility retirement;
Lua string closeout `.4.3.2.2.5.1` remains the execution frontier.

Index note 2026-07-12: `LUA-BACKEND-PARITY.4.3.2.2.5.1` closes scalar/string parity at 76/76 on both ABIs.
Public active surfaces lead with canonical `cat`; regex/split/mutation docs agree; exact shipped proof stays in
phase 6. Numeric helpers `.4.3.3` are active.

Index note 2026-07-12: `LUA-BACKEND-PARITY.4.3.3.0` splits numeric work by runtime mechanism. Active `.1` owns
strict scalar evaluation and invalid-result fences; `.2` aliases/symbols/number receivers; `.3` aggregate reducers
and array terminals; `.4` focused public no-drift.

Index note 2026-07-12: `LUA-BACKEND-PARITY.4.3.3.1.0` measures incompatible boolean, invalid, arity,
numeric-string, and signed-modulo behavior across Perl/Rust/Dart/Julia. Active `.1` adopts a neutral executable
scalar contract before admitted-backend repairs `.2`/`.3` and Lua six-runtime admission `.4`.

Index note 2026-07-12: `LUA-BACKEND-PARITY.4.3.3.1.1` adopts ADR `0029` and the 55-case
`linkedspec-scalar-numeric-v1` fixture. The offline evaluator/source renderer is in local CI; active `.2` aligns
Perl/Rust before Dart/Julia `.3` and Lua six-runtime admission `.4`.

Index note 2026-07-12: `LUA-BACKEND-PARITY.4.3.3.1.2` is done. Dedicated Perl and Rust numeric adapters now
consume all 55 unchanged cases with strict finite decimals, exact arities, invalid nulls, half-away rounding, and
floor signed modulo while generic coercion remains unchanged. Dart/Julia alignment `.3` is the active frontier.

Index note 2026-07-12: `LUA-BACKEND-PARITY.4.3.3.1.3` is done. Dart and Julia consume all 55 unchanged cases;
their authoritative package/analyzer/CLI/corpus gates pass, so Lua numeric `.1.4` is ready. The director's new
purpose-specific variadic callable/user-function direction is durably split under `FUTURE-PARITY-BACKLOG.4`;
audit leaf `.4.0` is the next clean-tree frontier before choosing syntax or changing behavior.

Index note 2026-07-12: `FUTURE-PARITY-BACKLOG.4.0` is done. The read-only audit proves open-bound built-ins
already encode purpose-specific variadicity, but user-function exact `arity` crosses the grammar, staged sidecars,
public descriptor, every compiled registry/runtime, generated source, and Lua invocation frame. Neutral versioned
signature/fixture `.4.1` is active; paired backend rollout and Lua routing are split without behavior changes.

Index note 2026-07-12: `FUTURE-PARITY-BACKLOG.4.1` adopts ADR 0030 and the recurring
`linkedspec-callable-signature-v1` checker. The chosen form is `fn name(fixed, ...rest) { ... }`; fixed definitions
remain exact version 1, variadic definitions use version 2 signature records, and extras bind as a fresh typed
array. Current capability remains 60/0/0 with variadic behavior future/owned; Perl `.4.2.1` is active.

Index note 2026-07-12: `FUTURE-PARITY-BACKLOG.4.2.1` is done. Perl preserves exact v1 records and executes v2
fixed-prefix/rest signatures through generated source; the 66-assertion adapter and canonical gate pass.

Index note 2026-07-12: `FUTURE-PARITY-BACKLOG.4.2.2` and parent `.4.2` are done. Rust carries the same signature
through parsed/compiled/public/generated records and passes the seven-test neutral fixture suite plus core gates.
The fixture corrected latent Rust array `length` drift without changing scalar Unicode length. Dart `.4.3.1`
became the callable-signature frontier at that boundary.

Index note 2026-07-12: `FUTURE-PARITY-BACKLOG.4.3.1` is done. Dart's typed v2 signature survives spec/staged,
registry/action, descriptor, native, normalized emitted, generated-plan, and reconstructed execution paths. Six
neutral tests and the complete 190-test/61x2/105 gate pass; Julia `.4.3.2` is the sole callable-signature frontier.

Index note 2026-07-12: `FUTURE-PARITY-BACKLOG.4.3.2` and parent `.4.3` are done. Julia's typed v2 signature
survives spec/staged, registry/action, descriptor, native, normalized hex-emitted, generated-plan, and reconstructed
execution paths. The 55-assertion neutral suite and complete package/61x2/105 gate pass; `.4.4` closes no-drift and
routes Lua parity to its dependency-complete owner.

Index note 2026-07-12: `FUTURE-PARITY-BACKLOG.4.4` closes callable extension `.4`. Four admitted backends agree on
exact v1 and variadic v2 native/generated behavior. Lua's existing shell/registry/frame stop before body dispatch,
so native parity is routed to dependency-complete `.5.1`, descriptor admission to `.5.3`, and generated preservation,
execution, proof, and capability retirement to `.8.1-.4`. Lua scalar numeric `.4.3.3.1.4` resumes as active.

Index note 2026-07-12: Director agreement closes `FUTURE-PARITY-BACKLOG.11.1` design. ADR 0031 selects exact
`{|args| body }` (`{|| body }` for zero params), final `...rest`, deferred construction, `cb(args)` invocation,
dynamic caller context with temporary copied params and no lexical capture, block-local return, static callable
precedence, retained `with`, and deterministic harray/eager-block disambiguation. Neutral contract `.11.2` is active;
Perl, Rust, Dart, Julia, and Lua-routing leaves are split before parser/runtime behavior changes.

Index note 2026-07-12: `FUTURE-PARITY-BACKLOG.11.2` adopts `linkedspec-callable-codeblock-v1`. Its independent
checker locks exact brace classification, typed deferred AST data, dynamic caller invocation/restoration,
diagnostics, contextual final blocks, and one deterministic future fixture before backend code. Perl typed-literal
parsing `.11.3.1` became active there and has since completed; capability remains future.

Index note 2026-07-12: `FUTURE-PARITY-BACKLOG.11.3.1` implements Perl typed literal construction only. Exact
AST/signature/body/spans, malformed codes, assignment/copying, user-function argument/results, and canonical
JSON-to-ASCII-hex generated preservation pass 126 assertions without host closures or execution. Dynamic
`cb(args)` invocation remains active `.11.3.2`; capability stays future.

Index note 2026-07-12: `FUTURE-PARITY-BACKLOG.11.3.2` executes closure-free Perl typed records through explicit
dynamic caller bindings. Exact neutral live/standalone behavior, parameter restoration, persistent nonparameter
mutation, static precedence, result chaining/drop, and typed failures pass. Generic final-codeblock normalization
is active `.11.3.3`; capability remains future until the full multi-backend lane closes.

Index note 2026-07-12: `FUTURE-PARITY-BACKLOG.11.3.3.0` proves attached and parenthesized contextual blocks already
share a final `block_value` payload, but no helper/user-function/receiver signature declares contextual codeblock
acceptance. The audit initially over-proposed nested callback params; director clarification in `.1` leaves those
on the value. Declaration design `.11.3.3.1` became active; no backend behavior changed.

Index note 2026-07-12: Director clarification closes `FUTURE-PARITY-BACKLOG.11.3.3.1`. ADR 0032 adopts exact
final-only `name: codeblock`; the receiving slot carries no nested callback argument list because explicit
`{|params| ...}` values own their invocation signature. The checker locks four invalid declarations and eight
helper/user-function/receiver contextual forms. Perl behavior `.11.3.3.2` and closeout `.11.3.4` are complete.

Index note 2026-07-12: `FUTURE-PARITY-BACKLOG.11.3.3.2` preserves exact final `name: codeblock` metadata in
typed user-function and staged records, moves helper/receiver acceptance behind `LinkedSpec::CallableContract`,
removes receiver parser method-name gating, and normalizes attached/parenthesized contextual blocks to one
zero-positional `codeblock_argument`. Live and standalone generated helper/user-function/receiver behavior,
explicit literals, harray rejection, and typed invalid declarations pass focused proof. Perl closeout `.11.3.4`
is complete; the capability remains future before cross-backend parity.

Index note 2026-07-12: `FUTURE-PARITY-BACKLOG.11.3.4` finds no raw-host fallback, stored coderef/capture, parser
method allowlist, harray drift, compatibility rewrite, or unresolved helper on the final Perl surface. Perl `.11.3`
is closed. Active `.12.1` must remove spec-facing `array(IDENTIFIER)` / `hash(IDENTIFIER)` namespace, typed-read,
and mutation semantics before Rust codeblocks or resumed Lua work; only ordinary constructor classification is
separate.

Index note 2026-07-12: boundary-correct `FUTURE-PARITY-BACKLOG.12.1.0` inventory is 600 exact selector-shaped calls
in 82 tracked specs, including 210 in 15 shipped specs; `.12.1.7.1` corrected the original scan, which had also
counted 51 `flat_array(name)` suffixes. Perl toolbox probes prove bare reads and receivers exist but
`push(items, value)` still selects child-rule push and bare three-argument mutable `split` is unsupported. Active
`.12.1.1` fixes the neutral replacement contract before five backend enablement leaves, three migration slices,
per-backend hard rejection, and final no-drift. Selector survival is not an open question.

Index note 2026-07-12: `FUTURE-PARITY-BACKLOG.12.1.1` adopts `linkedspec-uniform-binding-v1`. Its checker locks
11 migrations, seven execution cases, six exact selector failures, eight valid constructor/literal cases, and one
deterministic future fixture. Bare typed bindings, post-assignment `set`, updated mutation results, absent/wrong-
kind behavior, static-rule push precedence, pure/mutable split, and `aggregate_selector_removed` are fixed before
behavior. Perl `.12.1.2` was the first consumer; current sources still use compatibility forms until all backends
are enabled.

Index note 2026-07-12: `FUTURE-PARITY-BACKLOG.12.1.2` makes Perl the first executable consumer. Bare set/push/
append/split/hash/index/collection mutations, reads, copies, receivers, calls, controls, and chains share one typed
binding; mutations return independent updated values, absent targets auto-create, wrong kinds are typed failures,
and registered rules keep ambiguous-push precedence. Temporary selectors remain compatible only until migration;
the Rust handoff is now complete under `.12.1.3`, and Dart `.12.1.4` is the current consumer.

Index note 2026-07-12: `FUTURE-PARITY-BACKLOG.12.1.3` makes Rust the second executable consumer. Native and
generated-plan execution pass the neutral fixture plus all seven execution cases: post-assignment `set`, saved
push results, static-rule precedence, mutable/pure split, hash update/snapshot, silent value drop, and wrong-kind
fields. Bare append, array-end, and standalone collection mutations share the typed value path. An existing oracle
caught and locked the statement-append bridge. The Dart handoff is now complete under `.12.1.4`;
selector migration/rejection remains ordered.

Index note 2026-07-12: `FUTURE-PARITY-BACKLOG.12.1.4` makes Dart the third executable consumer. Native and
generated-plan execution pass the future fixture, all seven neutral cases, independent results, mutation
continuation, collection rebinding, static precedence, and wrong-kind fields. Temporary wrapper mutations alias the
same typed binding for mixed-source migration. Format/analyze, 199 tests, generated packages, 105 corpus fixtures,
and CLI 61x2 pass; the Julia handoff is complete under `.12.1.5`.

Index note 2026-07-12: `FUTURE-PARITY-BACKLOG.12.1.5` makes Julia the fourth executable consumer. Native and
generated execution pass the future fixture, seven neutral cases, independent updates, mutation continuation,
collection rebinding, static precedence, and wrong-kind fields. The complete Julia gate passes 1,311 package
assertions, CLI 61x2, and 105 corpus fixtures; canonical Phase 0 passes `1..1030` in 865 seconds.
The Lua handoff is complete under `.12.1.6`; selector migration/rejection remains dependency-ordered.

Index note 2026-07-12: `FUTURE-PARITY-BACKLOG.12.1.6` makes Lua the fifth executable consumer. `lookup_binding`
now governs kind-checked bare mutations and updated results on PUC Lua and LuaJIT; static rules retain push
precedence, and minimal array continuations execute the unchanged fixture. Both ABIs pass 85/85. All backend
alternatives are enabled, so shipped-source migration `.12.1.7.1` is active before remaining migration/rejection.

Index note 2026-07-12: `FUTURE-PARITY-BACKLOG.12.1.7.1` removes the boundary-correct 210 exact selectors from all
15 affected shipped specs and corrects the overall baseline from 651 to 600 by excluding 51 `flat_array(name)`
suffixes. Migrated Lispish exposed and closed Perl's `$name` mutation versus `@name` pure-read split. Canonical
doctrines/contracts, CLI 61x2, and Phase 0 `1..1031` pass; `.12.1.7.2` is active with 390 tracked occurrences left.

Index note 2026-07-12: `FUTURE-PARITY-BACKLOG.12.1.7.2` removes the remaining 390 exact selectors from 67
file-backed capability/oracle/corpus specs. Every tracked `*.spec` file now scans at zero; five-backend proof
preserves expected behavior, and embedded test/tool/backend source strings are active under `.12.1.7.3` before
hard syntax rejection.

Index note 2026-07-12: `FUTURE-PARITY-BACKLOG.12.1.7.3` removes all 1,356 positive exact selectors from 25
embedded test/tool/backend source owners. The recurring classifier reports zero executable positives and 25
implementation/recognition occurrences reserved for hard retirement. Complete backend gates, the regenerated
105-fixture oracle, standalone Phase 0 `1..1031`/920s, and canonical Phase 0 `1..1031`/918s pass. Source migration
is complete; Perl rejection `.12.1.8.1` is next.

Index note 2026-07-12: `FUTURE-PARITY-BACKLOG.12.1.8.1` hard-retires exact aggregate selectors on Perl. The
canonical ActionIR boundary rejects direct, nested, dead, and unused-function occurrences before lowering with
portable `aggregate_selector_removed` fields; live and generated-source failure paths agree, while retained
constructors/literals still execute. A whitespace-aware scanner closed three missed spaced embedded residues and
now reports zero positives/19 classified recognizers. Focused Perl 41, regenerated oracle 105, Rust corpus 3/3,
and standalone Phase 0 `1..1031`/934s pass. Rust `.12.1.8.2` is active.

Index note 2026-07-12: `FUTURE-PARITY-BACKLOG.12.1.8.2` hard-retires exact aggregate selectors on Rust. One
recursive typed-AST detector and whole-compiled-state validator cover normal/traced compilation, nested/dead code,
unused functions, deferred edge-fluent arguments, generated emission, decoded v1 plans, and legacy adapters. The
focused suite passes 15/15, the scanner reports zero positives/13 classified rejection sites, and complete Rust,
105 interpreted/generated corpus, integration 197/197, CLI, and canonical local gates pass. Selector-specific
runtime dispatch is deleted; Dart `.12.1.8.3` is active.

Index note 2026-07-12: Dart selector retirement is split at the measured full-gate boundary.
`FUTURE-PARITY-BACKLOG.12.1.8.3.1` owns whole-compiled-state selector rejection and runtime-dispatch deletion;
its focused proof passes 15/15 with clean analysis and a zero-positive/14-classified scan. The complete Dart test
leg reaches 203 passes and exposes only two `spec_spec_*` failures: the existing bounded structural regex bridge
recognizes fixed `blkFN`, while the shipped variadic function-definition pattern now uses `blkVFN`.
`.12.1.8.3.2` owns that exact capture-preserving bridge repair and the complete Dart no-drift gate before Julia.

Index note 2026-07-12: `FUTURE-PARITY-BACKLOG.12.1.8.3.2` restores the exact bounded Dart bridge for shipped
variadic function definitions. Fixed `blkFN` and variadic `blkVFN` have distinct prefixes; the variadic matcher
returns name/fixed/rest/body captures and the `blkVFN` named block. Focused matching+selector tests pass 22, all
four `spec_spec_*` smokes pass, and the authoritative Dart gate passes 205 tests, CLI 61x2, and 105/105 corpus.
Dart parent `.12.1.8.3` is done; Julia `.12.1.8.4` is active.

Index note 2026-07-12: `FUTURE-PARITY-BACKLOG.12.1.8.4` hard-retires Julia exact aggregate selectors. Recursive
typed-ActionIR inspection plus whole-compiled-state validation covers rule payloads, valid deferred fluent calls,
unused function bodies, generated emission, and generated plan/execution entry. Selector-specific runtime dispatch
is deleted; focused proof passes 59/59, the executable scan is zero-positive/15 classified, and the authoritative
Julia gate passes 1,339 assertions, CLI 61x2, and 105/105 corpus. Lua `.12.1.8.5` is active.

Index note 2026-07-12: `FUTURE-PARITY-BACKLOG.12.1.8.5` hard-retires Lua exact aggregate selectors. Recursive
ActionIR plus whole-compiled-state validation covers rule payloads, valid deferred fluents, unused function bodies,
and caller-mutated compiled tables at runtime-engine admission. Selector-only runtime reads/targets/receivers/
split/transform dispatch is deleted. PUC Lua and LuaJIT each pass 88/88; the exact 105-manifest/CLI scaffold and
zero-positive/19-classified source scan pass. Cross-variant no-drift `.12.1.8.6` followed and is now complete.

Index note 2026-07-12: `FUTURE-PARITY-BACKLOG.12.1.8.6` closes aggregate-selector hard retirement. One canonical
checker requires all five backends to consume the six invalid cases and portable diagnostic fields, locks each
compiled-state validation boundary and all eight retained constructor/literal classes, forbids known selector-only
runtime mechanisms, and composes the executable-source scan. It reports zero runtime compatibility and zero
executable positives/19 classified rejection occurrences. Focused proof passes Perl 11, Rust 15/15, Dart 15/15,
Julia 59/59, and Lua 88/88 on both ABIs. Final public admission `.12.1.9` followed and is now complete.

Index note 2026-07-12: `FUTURE-PARITY-BACKLOG.12.1.9` admits the selector-free public surface and closes `.12.1`.
One canonical checker scans 47 root/capability/mdBook files, classifies 31 exact mentions only as removed/rejected/
migrated history, requires current bare set/push/copy guidance, and reports zero current examples. It composes the
five-backend runtime/source gates and removes the capability future exclusion at 60/0/0. Canonical CLI 61x2 and
Phase 0 `1..1031`/626s pass. Existing active Lua scalar-numeric `.4.3.3.1.4` resumes.

Index note 2026-07-12: `LUA-BACKEND-PARITY.4.3.3.1.4` and scalar parent `.4.3.3.1` are done. One portable Lua
evaluator consumes the unchanged 55-case strict scalar numeric v1 contract on both PUC Lua and LuaJIT. The complete
Lua gate passes 89/89 on each ABI plus the exact 105-manifest/CLI scaffold; a composed checker proves Perl, Rust,
Dart, Julia, PUC Lua, and LuaJIT return the exact same fixture value. Alias/symbol/number-receiver admission
`.4.3.3.2` is active.

Index note 2026-07-12: `FUTURE-PARITY-BACKLOG.12.1.10` corrects the public-checker omission discovered after
`.12.1.9`. The prior curated 47-file root/capability/mdBook list excluded backend READMEs, allowing 14 current
positive selector forms across Rust, Dart, Julia, and Lua. Those documents now use bare typed bindings. The
checker discovers every immediate component README, requires exact 56-file/31-classified inventories and four
backend anchors, and reports zero current examples while composed runtime/source/capability proof remains green.
Selector-retirement `.12.1` and compatibility parent `.12` re-close; Lua numeric `.4.3.3.2` resumes.

Index note 2026-07-12: `LUA-BACKEND-PARITY.4.3.3.2` admits all scalar numeric word aliases, 11 symbol callees,
and integer/float/bare-scalar receiver chains through the strict evaluator. Number links compose; comparisons are
terminal. A `/`-callee versus regex-start ambiguity found inside harray values is structurally disambiguated while
grouped/class/zero-width/invalid regex fixtures remain green. PUC Lua and LuaJIT pass 90/90 plus the exact
manifest/CLI scaffold; aggregate reducers and array receiver terminals `.4.3.3.3` are active.

Index note 2026-07-12: `LUA-BACKEND-PARITY.4.3.3.3` adds strict copied-array sum/avg/median/range/min/max with
explicit, bare-binding, and terminal receiver forms. Empty and invalid boundaries match the catalog, sources remain
unchanged, and both Lua ABIs pass 91/91. Focused numeric/public no-drift `.4.3.3.4` is active.

Index note 2026-07-12: `LUA-BACKEND-PARITY.4.3.3.4` closes numeric helper/public no-drift and parent `.4.3.3`.
The focused proof now directly covers every reducer canonical/alias spelling in addition to scalar canonical,
word/symbol, receiver, terminal, and invalid boundaries. Both Lua ABIs remain 91/91 and the six-runtime scalar
contract remains 55/55. General array helper family `.4.3.4` is active; exact shipped-corpus execution stays in
dependency-complete phase 6.

Index note 2026-07-12: `LUA-BACKEND-PARITY.4.3.4.0` splits array execution into construction/splicing, copied
selection, scalar/regex transforms, mutation/child flow, tagged records, and closeout. The audit found that the
admitted uniform-binding updated-mutation-value contract superseded older statement-only array-end result prose,
yet several current book/KM/backend summaries still taught the old rule. This audit activated
`FUTURE-PARITY-BACKLOG.12.1.11` to repair and gate that cross-cutting drift before Lua construction `.4.3.4.1`.

Index note 2026-07-12: `FUTURE-PARITY-BACKLOG.12.1.11` reconciles array-end mutation results across Perl
value-position lowering, all five focused backends, public/mdBook/KM guidance, and a recurring 48-file checker.
All four end methods return independent updated arrays, pop discards the removed element, and compatible
continuations consume the update. Compatibility parents `.12.1`/`.12` re-close; Lua `.4.3.4.1` is active.

Index note 2026-07-12: `LUA-BACKEND-PARITY.4.3.4.1` adds ordered copied array construction, explicit direct and
terminal-receiver flat splicing in calls/literals, ordinary nested-array preservation, copied concat, and
snapshot isolation. PUC Lua and LuaJIT pass 92/92; `.4.3.4.2` is active. Measured Perl versus newer-backend
zero/variadic flat/concat drift is routed to `FUTURE-PARITY-BACKLOG.5` rather than hidden.

Index note 2026-07-12: `LUA-BACKEND-PARITY.4.3.4.2` adds copied take/drop/default counts, zero-based slice,
ordering, scalar-text membership/index, and stable uniqueness through function and receiver chains. Sources stay
unchanged and both Lua ABIs pass 93/93; `.4.3.4.3` is active. Pre-existing negative-count policy drift is routed
to `FUTURE-PARITY-BACKLOG.5` rather than silently selecting one backend.

Index note 2026-07-12: `LUA-BACKEND-PARITY.4.3.4.3` adds delimiter-first joins, literal/PCRE2 split pipelines,
PCRE2 filters, Unicode transforms, terminal join receivers, and seven kind-checked dropped-call rebindings. Both
Lua ABIs pass 95/95 and mutation/child flow `.4.3.4.4` is active. Toolbox proof routes pre-existing newer-backend
dropped-transform and invalid-join drift to `FUTURE-PARITY-BACKLOG.5`.

Index note 2026-07-12: `LUA-BACKEND-PARITY.4.3.4.4` types current-rule accumulators, exposes absent compiled-rule
arrays, reuses cached action-edge child results, and supports whole/indexed push into implicit or explicit targets.
Uniform append/end/split paths remain exact and both Lua ABIs pass 98/98; tagged records/remaining bridges
`.4.3.4.5` are active.

Index note 2026-07-12: `LUA-BACKEND-PARITY.4.3.4.5` reuses governed literal/PCRE2 split semantics and constructs
fresh exact `[tag, item, fields...]` records after evaluating source and carried fields once. Direct and receiver
forms, copied nested fields, invalid boundaries, and empty items pass 99/99 on both Lua ABIs; complete array helper
and public-surface no-drift `.4.3.4.6` is active.

Index note 2026-07-12: `LUA-BACKEND-PARITY.4.3.4.6` closes all 34 non-callback ActionIR array names and six
numeric terminals at 99/99 on both Lua ABIs. The audit aligned invalid count/take, ordinary/explicit-target push,
and named end-mutation result prose and expanded the recurring public guard. Direct Perl `push(Child)` count versus
Lua updated-accumulator expression drift is routed to `.5`; three tree callbacks remain `.4.3.6`. Parent `.4.3.4`
is done and harray helpers `.4.3.5` are active.

Index note 2026-07-12: `LUA-BACKEND-PARITY.4.3.5.0` audits 16 admitted hash names and splits the 13 ordinary
helpers into construction/splicing, deterministic views, copied transforms/receivers, named mutation, and
no-drift. Lua already has typed harray values/copy/index assignment but no hash dispatcher; shared `flat` currently
uses the array route. Odd `hash(...)` arity stays backlog `.5`, callbacks stay `.4.3.6`, and `.4.3.5.1` is active.

Index note 2026-07-13: `LUA-BACKEND-PARITY.4.3.5.1` makes generic `flat` runtime-kind aware, adds copied direct/
receiver `flat_hash`, preserves ordinary nested harray fields, and splices only explicit direct/terminal flat ASTs.
Explicit harray flattening into array context emits deterministic sorted key/value pairs. Both Lua ABIs pass
100/100 with one-time evaluation, deep isolation, and unchanged odd-arity behavior; deterministic views `.4.3.5.2`
are active.

Index note 2026-07-13: `LUA-BACKEND-PARITY.4.3.5.2` adds lexical `sorted_keys`, values ordered by those keys,
exact count/presence terminals, copied nested values, and function/receiver/array-chain bridges. A Perl toolbox
matrix confirmed wrong-kind/missing results `0`/`[]` and present-null membership, correcting one stale catalog
`undef` claim. Both Lua ABIs pass 101/101; bare base/overlay transform contracts are revalidated in `.4.3.5.3.0`
and Lua implementation `.4.3.5.3.1` is active.

Index note 2026-07-13: `LUA-BACKEND-PARITY.4.3.5.3.0` supersedes the pre-uniform-binding Knowledge Map claim
that `merge_hash(base, overlay)` loses its base. Perl now returns the correct result and exact `hash(base)` is a
removed selector; the checked-in bare-first neutral case passes Dart, Julia, and the 105-case Rust oracle.

Index note 2026-07-13: `LUA-BACKEND-PARITY.4.3.5.3.1` adds copied merge/set/rename/drop/pick values with later
override, deep isolation, and compatible receiver flow at 102/102 on both Lua ABIs. Rename-to-existing-key probes
split Perl/Julia old-value-wins from Dart/Rust destination-wins; Lua follows the reference and backlog `.5` owns
portable normalization. Named set-key/direct mutation `.4.3.5.4` is active.

Index note 2026-07-13: `LUA-BACKEND-PARITY.4.3.5.4` routes dropped statement `set_key(target, key, value)` and
direct `target[key] = value` through one kind-checked harray binding seam. Absent targets create harrays, wrong
kinds expose neutral diagnostic fields, saved direct-assignment snapshots remain isolated, and assigned/function/
receiver `set_key` stays pure. Both Lua ABIs pass 103/103; non-callback harray closeout `.4.3.5.5` is active.

Index note 2026-07-13: `LUA-BACKEND-PARITY.4.3.5.5` inventories all 13 ordinary harray names across constructor,
runtime-kind generic, copied dispatcher, and uniform mutation routes. Existing focused proof stays 103/103 on both
Lua ABIs; the public mutation-result guard now locks independent hash-index snapshots and pure receiver set-key.
Parent `.4.3.5` is done; codeblock/control/tree-callback parent `.4.3.6` is active and must split before code.

Index note 2026-07-13: `LUA-BACKEND-PARITY.4.3.6.0` finds Lua's parser/resolver already structural for eager
blocks, generic final block arguments, and controls, while the interpreter still treats blocks as inert data and
does not dispatch controls/callbacks. Six mechanism leaves plus closeout now own eager blocks, inline controls,
statement controls, contextual built-ins/`with`, and tree callbacks. General user-function final blocks remain
`.5.1`; first-class callable codeblocks remain future `.11.7`; eager block execution `.4.3.6.1` is active.

Index note 2026-07-13: `LUA-BACKEND-PARITY.4.3.6.1` executes ordinary no-pair brace values with final-expression
results, block-local early/null return, existing dropped-statement mutation, harray precedence, and receiver
continuation at 104/104 on both Lua ABIs. It corrects the earlier Lua-only inert assignment scaffold expectation:
ordinary braces are eager, contextual trailing blocks stay structural, and explicit callable values remain future
`{|params| ...}`. Lazy inline value controls `.4.3.6.2` then pass 105/105 with selected-only evaluation,
one-time switch subjects, literal bare case labels, block-local returns, generic arity failures, and fluent return
composition. Structural `i`/`elif` and `when`/`otherwise` aliases are not inline values; attached/marker if-family
execution `.4.3.6.3.1` then passes 106/106 with selected-only attached/marker branches, nested boundaries, empty
branches, local return, and typed malformed/orphaned diagnostics. Portable authoring keeps `i`/`elif` marker-only
and `when`/`otherwise` attached-only; broader backend acceptance joins truthiness normalization in
`FUTURE-PARITY-BACKLOG.5`. Attached and marker switch execution `.4.3.6.3.2` then passes 107/107: subjects run
once, first matching case/default ranges are lazy and nesting-aware, literal labels and local return are preserved,
and malformed/orphaned structures stay typed. Boolean/number and aggregate switch equality plus Perl-versus-newer
outside-branch marker execution drift are routed to backlog `.5`. Attached while `.4.3.6.3.3` then passes 108/108
with condition re-evaluation, state-visible bodies, action/expression-block return, Perl-reference inner-loop
`next`, and typed exact-limit rule attribution. Guard timing and `next` drift join backlog `.5`. Built-in final
blocks/scoped `with` `.4.3.6.4` then pass 112/112 in attached and parenthesized helper/receiver form with copied
metadata, cleanup-safe uniform binding restoration, aggregate isolation, result chaining, and typed kind/arity
failures; `.4.3.6.5.1.1` repairs reference authored-value precedence, Lua harray callbacks `.1.2` pass 113/113,
and root-kind array callbacks `.5.2` close at 114/114 on both ABIs. No-drift `.4.3.6.6` closes the parent and
advances capture/cursor `.4.3.7`. The punctuation-light contract, all five backend
implementations, and public/capability no-drift admission `.16.7` are complete at 64/0/0.

Index note 2026-07-13: `LUA-BACKEND-PARITY.4.3.7.0` audits the canonical state/endpoint/timing contracts and
splits input/cursor controls, anonymous capture, governed named marks/bridges, placement markers, earliest-boundary
lookahead, and no-drift. Lua parses but does not compile/execute split-marker nodes; shipped EBNF source uses
`@move_pos`. The audit also finds seven public current mark helpers missing identically from the governed 239-name
backend inventories because the coverage checker's reverse leg is corpus-seeded. A clean-pivot cross-backend owner
must exist before named-mark `.4.3.7.3`; input/cursor `.4.3.7.1` is otherwise dependency-ready.

Index note 2026-07-13: `FUTURE-PARITY-BACKLOG.17.0` classifies all 16 identifier-shaped current Perl contract
diagnostics outside the aligned 239-name backend inventories: seven public current mark helpers, two compatibility
map aliases, two legacy capture names, and five internal lowering operations. `.17.1-.17.5` own neutral/Perl/Rust,
Dart, Julia, Lua, and final admission/gate hardening. This tracking split changes no behavior and returns the clean
frontier to Lua input/cursor `.4.3.7.1`; named-mark `.4.3.7.3` must later consume the shared resolution.

Index note 2026-07-13: `LUA-BACKEND-PARITY.4.3.7.1` implements all whole-input/live-cursor projections and
explicit cursor controls over Lua's byte-safe register seam. Public positions, lengths, and slices use Unicode
characters; save/restore is parse-scoped LIFO; entry/local rewinds synchronize the live and register cursor while
preserving match snapshots; consume continuation sees the rewound cursor. PUC Lua and LuaJIT pass 115/115, and
the frontier advances to anonymous capture-boundary helpers `.4.3.7.2` without a named-mark/capability claim.

Index note 2026-07-13: `LUA-BACKEND-PARITY.4.3.7.2` executes all 16 anonymous capture calls through one byte-safe
rule-local register boundary. Local-match/live-cursor/input-end endpoints, Unicode locations and lengths, stable
versus valid-only advancing reads, receiver continuation, void setter behavior, reversed-span neutrality, and
typed arity pass 116/116 on PUC Lua and LuaJIT. `FUTURE-PARITY-BACKLOG.5` owns the discovered Perl-only setter
result leak. Named marks remain dependency-gated by `.17`, so earliest-boundary `.4.3.7.5` is next.

Index note 2026-07-13: `LUA-BACKEND-PARITY.4.3.7.5` implements `capture_until_boundary(...)` with a separate
compiled-alternation cache and unconditional seek from the live cursor. Earliest selection, non-consumption,
Unicode cursor projection, consume-mode independence, EOF fallback, quoted/bare names, all-unusable no-op, and
receiver continuation pass 117/117 on PUC Lua and LuaJIT. Zero-argument Perl/typed-backend drift is owned by `.5`;
cross-backend complete named-mark `.17.1` aligns Perl/Rust; Dart `.17.2` and Julia `.17.3` close exact
native/generated/CLI plus canonical proof; Lua `.17.4` is active before Lua `.4.3.7.3`.

Index note 2026-07-13: `FUTURE-PARITY-BACKLOG.17.2` makes Dart consume the unchanged seven-helper complete
named-mark contract through its existing rule-local code-unit store and character projection seam. Native,
generated-plan, emitted-state, and primary-CLI paths agree; exact staged inventory, 214 package tests, CLI 61x2,
corpus 105/105, capability 64/0/0, shared coverage 239/105, and Phase 0 `1..1031` pass. Julia `.17.3` is active.

Index note 2026-07-14: `FUTURE-PARITY-BACKLOG.17.3` makes Julia consume that unchanged contract through its
existing rule-local code-unit store and character projection seam. Native, generated-plan, emitted-state, and
primary-CLI paths agree; exact staged inventory, 1,414 package assertions, shared CLI 61x2, and corpus 105/105
pass. Canonical proof preserves capability 64/0/0 and shared coverage 239/105, passes Phase 0 `1..1031`, and
activates Lua `.17.4`.

Index note 2026-07-13: `FUTURE-PARITY-BACKLOG.16.0` is done. ADR `0033` preserves the general parenthesized call
grammar while adopting six standalone zero-argument aliases plus a final zero-argument ActionIR receiver segment.
The five-backend audit distinguishes already-supported rule/lifecycle suffixes from inconsistent typed ActionIR
paths. Parenthesis-free condition-bearing `if`/`while` headers remain explicitly deferred. `.16.1` now locks six
standalone aliases, final-only receiver omission, retained value reads, exclusions, arity delegation, and one
portable fixture. `.16.2.0` corrects its receiver-arity example against measured Perl behavior, `.16.2.1`
implements the contract on Perl with exact live/generated execution, `.16.3` adds Rust typed/native/serialized/
emitted/generated execution, `.16.4` adds Dart typed/native/generated/emitted/CLI execution, `.16.5` adds the same
Julia paths, and `.16.6` adds Lua typed/serialized/native dual-ABI execution while narrowing parser-ahead receiver
support to final-only. Public/capability closeout `.16.7` admits the syntax at 64/0/0 and adds the recurring
five-backend/two-Lua-ABI proof; Rust/Dart/Julia/Lua pre-existing `.contains()` missing-argument outcomes are
delegated to helper owner `.5`; future generated Lua preservation remains `.8`; Lua `.4.3.6.4` is the clean-pivot
resume target.

Index note 2026-07-12: `FUTURE-PARITY-BACKLOG.7.0` owns a verification-tool calibration found while closing Rust
selector retirement. The current shipped VHDL parser builds in 19.627 seconds and parses its input in 0.001 seconds,
so the generator's 15-second default kills healthy construction. Complete regeneration remains available through
the documented `ORACLE_TIMEOUT=30` override; the pending leaf must recalibrate the default while preserving the
per-case fork/`SIGKILL` guard and zero-timeout kill proof.

Index note 2026-07-12: `FUTURE-PARITY-BACKLOG.13.1` records a toolbox regression discovered during `.12.1.7.3`:
`tools/inspect_spec_codegen.pl` still calls private methods through the Phase 1A-thinned facade, so plugin AUTOLOAD
reports `_rewrite_action_code_with_diagnostics` / `_render_method_call_chain` as unknown plugins. Repair and a
recurring smoke lock are dependency-ready after selector retirement but remain queued behind the resumed active
Lua scalar-numeric frontier.

Index note 2026-07-12: `FUTURE-PARITY-BACKLOG.14.0` captures the director's complete authoring model. Typical
zero/one/two-regex roles keep boundaries simple while recursion lives in action-edge OR and blind-call AND rule
connections. Progressive parsing invokes loaded specs over cursor-relative extracted text during a parse; staged
parsing refines selected fields from a returned AST level. In the function-body prototype, the outer `.spec`
extracts the bounded body and the `actionir-body.spec` job identity resolves to a built-in backend-native ActionIR
parser adapter, not another owning `.spec`; it therefore proves staging but not spec-loading-spec. ADR 0012 remains
the base, while general in-parse composition, public parse jobs, multiple parser families, recursive queues, and
two contradictory walkthrough idioms are owned by queued `.14.1-.14.4` after selector retirement.

Index note 2026-07-12: `FUTURE-PARITY-BACKLOG.15.0-.15.2` own the director's equivalence between any standalone/
dangling rule-level `{ ... }` block and `I { ... }`. There is currently no dangling-brace rule-body form. Edge code
blocks are not dangling because the action-edge or blind-call production precedes and owns them; nested expression/
callable blocks are owned after code parsing begins. The shorthand may therefore occur anywhere as a top-level
rule-body item in every rule kind and normalize to the existing I-lifecycle AST, inheriting explicit-I order and
duplicate behavior rather than adding runtime semantics. Implementation remains queued after selector retirement.

Index note 2026-07-10: active `FUTURE-PARITY-BACKLOG.1.6.1.0` derives an identical 237-name current ActionIR
inventory from Dart and Julia. All names occur in the mdBook, while 98 do not yet occur in the 99-fixture neutral
corpus. Bounded Perl fixtures expose a common physical-newline separator/lowering gap for capture assignments,
cursor controls, and marker chains. `.1.6.1.1` owns repair before `.1.6.1.2` completes strict corpus coverage.

Index note 2026-07-10: `FUTURE-PARITY-BACKLOG.1.6.1.1` is done. `StatementSplit::Core` now treats every unquoted
depth-zero LF/CRLF/CR as a statement separator, including line-comment completion, while nested call/block/string/
regex payloads and same-line rules remain protected. Phase 0 passes `1..1029`; unchanged Perl/Rust/Dart/Julia
corpus proof is 99/99 each. `.1.6.1.2` is active for strict current-call fixture closure.

Index note 2026-07-10: `FUTURE-PARITY-BACKLOG.1.6.1.2.0` is done. Corrected in-memory three-slot capture/mark
fixtures return exact hashes, but the newline-only combined control fixture exposed invalid emitted Perl after
`endswitch()`: `} }` was followed directly by `return`. The resulting `.1.6.1.2.1` repair is now closed;
`.1.6.1.2.2` retains final fixture/oracle admission and strict 237-name proof.

Index note 2026-07-10: `FUTURE-PARITY-BACKLOG.1.6.1.2.1` is done. Pending newline termination now carries the
canonical contract: `endswitch_flow` emits the required Perl `};` before a following statement while ordinary
block closures remain unchanged. Phase 0 passes `1..1030`; `.1.6.1.2.2` is active for final fixture/oracle proof.

Index note 2026-07-10: `FUTURE-PARITY-BACKLOG.1.6.1.2.2.0` is done. Provisional 105-case execution proves name
coverage is not semantic parity: Rust, Dart, and Julia each pass 100/105, with residual pure-value, empty-local-
match, marker-control, and capture/mark mechanisms split by backend. The governed sources and safe `source_file`
generator seam remain; mandatory corpus stays green at 99. The first Rust pure-value repair is now closed.

Index note 2026-07-10: `FUTURE-PARITY-BACKLOG.1.6.1.2.2.1.1` is done. Rust now matches the exact pure fixture for
numeric predicate values, direct-literal `flat` splicing, and explicit working-array statement transforms. The
focused fixture, 191 integration tests, and 99-case oracle pass; active `.2.2.1.2` aligns Dart.

Index note 2026-07-10: `FUTURE-PARITY-BACKLOG.1.6.1.2.2.1.2` is done. Dart now matches the same exact pure fixture
without backend-specific source: 152 package tests, both 61-case CLI environments, and the unchanged 99-case
corpus pass. Active `.2.2.1.3` aligns Julia.

Index note 2026-07-10: `FUTURE-PARITY-BACKLOG.1.6.1.2.2.1.3` is done. Julia now matches the same exact pure fixture;
1,020 assertions, both 61-case CLI environments, and the unchanged 99-case corpus pass. The pure parent closes and
active `.2.2.2.1` aligns Rust empty-local-match projection.

Index note 2026-07-10: `FUTURE-PARITY-BACKLOG.1.6.1.2.2.2.1` is done. Rust now distinguishes an absent local match
from a real zero-width match and matches the exact position fixture. All 137 library and 193 integration tests plus
the unchanged 99-case oracle pass; active `.2.2.2.2` aligns Dart.

Index note 2026-07-10: `FUTURE-PARITY-BACKLOG.10.0` captures the director's deep semantic-introspection API/MCP
direction without changing the active frontier. Pending `.10.1` must design one versioned, deterministic semantic
model exposed by every native backend, exact parity fixtures, stable provenance, bounded/privacy-aware queries,
and a thin MCP transport that owns no semantic behavior. The active backend frontier is Dart `.1.5.3`.

Index note 2026-07-10: `FUTURE-PARITY-BACKLOG.1.4` is done. ADR `0022` ratifies native in-memory embedding as
the primary multi-backend product contract: Perl/Rust/Dart/Julia expose host-process parse/compile/execute
surfaces, and Lua plus future backends must do the same. CLIs and corpus runners remain thin adapters without
exclusive semantics. PNT resumes at `JULIA-BACKEND-PARITY.6.2.4.6`.

Index note 2026-07-09: `DART-BACKEND-PARITY.4.3.5` is done. Dart runtime execution now supports
expression-valued blocks with block-local return, attached and inline controls, helper/receiver `with` trailing
blocks, and hash/array `walk_leaves`, `map_leaves`, and `reduce_leaves` receiver callbacks with scoped callback
bindings. Active frontier advances to `DART-BACKEND-PARITY.4.3.6` for helper/value no-drift closeout before
BACKTRACK work.

Index note 2026-07-09: `DART-BACKEND-PARITY.4.3.6` is done. The helper/value no-drift closeout fixed Dart
nested value-path assignment to match the Perl/Rust contract: successful writes return the updated root, missing
or wrong intermediate paths return `null` without mutation, final array writes only replace or append at len, and
intermediate containers are not autovivified. The `.4.3` helper/value container is closed; active frontier
advances to `DART-BACKEND-PARITY.4.4` for BACKTRACK behavior.

Index note 2026-07-09: `DART-BACKEND-PARITY.4.4` is done. Dart runtime execution first landed local-match and
entry/initial-match cursor rewinds plus char-based cursor/input helpers including `cursor_pos`, `cursor_rest`,
`input_slice`, and `input_end_pos`. `BACKTRACK-SURFACE-RUST-ALIGNMENT.1` supersedes the short-lived public names
with `save_cursor()` / `restore_cursor()` and `rewind_match_start()` / `rewind_entry_start()`. Active frontier
advances to `DART-BACKEND-PARITY.4.5` for runtime diagnostics and trace controls.

Index note 2026-07-09: `BACKTRACK-SURFACE-RUST-ALIGNMENT` is done/closed. `.2` added
`capture_until_boundary(rule[, ...])` across Perl, Rust, and Dart as the non-consuming structural boundary helper;
`specs/ebnf.spec` and Rust corpus copies now use it for semantic annotations instead of consume-then-rewind.
The deferred AND compact-sequence / child-edge quantifier idea remains recorded in that task tree, not active.

Index note 2026-07-09: `DART-BACKEND-PARITY.4.5.0` is done as a task-tree split before code. Runtime
diagnostics/trace controls are now divided into `.4.5.1` structured runtime diagnostics, `.4.5.2` trace levels,
controls, event classes, and sinks, `.4.5.3` runtime branch/lifecycle/source-boundary instrumentation, and
`.4.5.4` no-drift closeout. Active frontier advances to `DART-BACKEND-PARITY.4.5.1`.

Index note 2026-07-09: `DART-BACKEND-PARITY.4.5.1` is done. Dart exports `RuntimeDiagnostic` and attaches it to
`RuntimeInterpreterException.diagnostic`; missing-rule and wrapped action-helper runtime failures now preserve
type/stage/owner/summary/detail/top-rule/rule/handler attribution plus optional spec identity, while successful
parse output remains unchanged. Active frontier advances to `DART-BACKEND-PARITY.4.5.2` for trace controls,
event classes, and sink behavior.

Index note 2026-07-09: `DART-BACKEND-PARITY.4.5.2` is done. Dart now exports trace levels/config/emitter/event
primitives, reads the documented `LINKEDSPEC_TRACE_*` controls, supports stdout/routed-file/mirror sinks with
reset/truncate behavior, and offers traced runtime entrypoints that preserve parse output while emitting a
parse-scope event. Active frontier advances to `DART-BACKEND-PARITY.4.5.3` for runtime branch/lifecycle and
source-boundary trace events.

Index note 2026-07-09: `DART-BACKEND-PARITY.4.5.3` is done. Dart runtime tracing now emits parse/rule scopes,
regex match/no-match decisions, action-edge and blind-call child-dispatch decisions, lifecycle block marks,
cursor-control helper marks, recursion-cutoff decisions, and `capture_until_boundary(...)` source-boundary marks
while preserving traced/untraced parse output. Active frontier advances to `DART-BACKEND-PARITY.4.5.4` for
diagnostics/trace no-drift before staged runtime work.

Index note 2026-07-09: `DART-BACKEND-PARITY.4.5.4` is done. Dart diagnostics/trace status is aligned across Dart
README, CLI/scaffold text, mdBook trace/status/handoff pages, live docs, roadmap, task tree, MEMORY, and Knowledge
Map. The `.4.5` diagnostics/trace container is closed; active frontier advances to `DART-BACKEND-PARITY.5.1` for
the minimal staged registry provider.

Index note 2026-07-09: `DART-BACKEND-PARITY.5.1` is done. Dart now resolves function-body
`body_parse_job` records through the minimal staged parser registry, executes the built-in
`actionir-body.spec` / `action_block` provider in stable queue order, records staged cache/compiled-parser
metadata, and stitches returned `action_block` JSON into `body_ast`. Active frontier advances to
`DART-BACKEND-PARITY.5.2` for user-function runtime execution.

Index note 2026-07-09: `NONCURRENT-HELPER-CODE-PURGE.1` is done. After the director clarified that removed
helper spellings must be deleted from the Perl and Rust codebases, read-only scans split the purge into Perl
source, Rust source, active tests/tools/spec fixtures, and final no-drift leaves. Active frontier is
`NONCURRENT-HELPER-CODE-PURGE.2` for Perl source recognition/diagnostic path removal.

Index note 2026-07-09: `NONCURRENT-HELPER-CODE-PURGE.2.1` is done. Perl ActionIR current `cat(...)`,
`copy(...)`, `set(...)`, and `push(...)` lowering now stays on current method/contract names, removed
append-helper recognition/diagnostic branches are gone from the touched Perl source owners, and focused
syntax, AST parser, compact-lowerer, direct current-helper probes, and removed-append scans pass. Active
frontier advances to `NONCURRENT-HELPER-CODE-PURGE.2.2`.

Index note 2026-07-09: `NONCURRENT-HELPER-CODE-PURGE.2.2` is done. Perl declaration/return/wrapper
helper-call source-owner paths are gone from the touched ActionIR/RuleIR owners and active regression tests,
current return/setup/read behavior remains covered, and syntax, AST parser, compact-lowerer, scoped scans,
mdBook scans, and full phase0 (`1027` tests) pass. Active frontier advances to
`NONCURRENT-HELPER-CODE-PURGE.2.3`.

Index note 2026-07-09: `NONCURRENT-HELPER-CODE-PURGE.2.3` is done. Perl ActionIR raw-compat metadata no longer
uses exact retired helper names as diagnostic labels, a focused metadata test locks the retired helper set out of
contract/canonical metadata, and phase0 (`1027` tests) passes. Active frontier advances to
`NONCURRENT-HELPER-CODE-PURGE.2.4`.

Index note 2026-07-09: `NONCURRENT-HELPER-CODE-PURGE.2.4` is done. Focused Perl source scans are clean for exact
retired helper call-shape recognition paths, current helper lowering probes still pass for `cat(...)`,
`copy(...)`, `set(...)`, and `push(...)`, retired value-position helper-looking calls use the same generic
unsupported-helper sentinel path as invented unknown helpers, focused ActionIR tests pass, and full phase0
passes (`1027` tests). Active frontier advances to `NONCURRENT-HELPER-CODE-PURGE.3` for Rust source cleanup.

Index note 2026-07-09: `NONCURRENT-HELPER-CODE-PURGE.3` is done. Rust known-call validation, expression parsing,
and runtime dispatch no longer carry name-specific retired-helper recognition or diagnostic paths; internal
runtime context append/snapshot methods use neutral current names, retired helper-looking calls follow the
generic unknown-helper fallback, and full `linkedspec-core` plus `linkedspec-runtime` package tests pass.
Active frontier advances to `NONCURRENT-HELPER-CODE-PURGE.4`.

Index note 2026-07-09: `NONCURRENT-HELPER-CODE-PURGE.4` is done. Active tests, tools, generated fixture inputs,
and checked-in `.spec` labels/source strings were migrated away from the retired helper spelling set; EBNF return
labels now use `return_scalar_value` / `return_array_value`, portmap concatenation now uses `?concatenation:`,
and phase0/runtime/book checks pass. Active frontier advances to `NONCURRENT-HELPER-CODE-PURGE.5`.

Index note 2026-07-09: `NONCURRENT-HELPER-CODE-PURGE.5` is done. Final no-drift scans are clean for active
retired-helper call shapes, label/tag collisions, and exact `?concat:`; one remaining Rust runtime unit-test
fixture was migrated from retired helper examples to invented unknown helper names while preserving generic
fallback coverage. The tree is closed, and the next eligible active frontier is `DART-BACKEND-PARITY.3.3`.

Index note 2026-07-04: `SPEC-FORMAT-TERSE.8` is now pending by explicit user directive. The `.6.4` decision to
retain legacy compatibility helpers is superseded for this unreleased project; the new frontier removes remaining
compatibility-only helper spellings so the terse surface is the only current accepted helper surface.

Index note 2026-07-08: `SPEC-LANG-REFERENCE.10.5.5` is done. The spec-file paragraph page's runnable examples
now use the verified 2-rule idiom, and the bare `label:` open-block case is documented as the validation error
`Rule definition not allowed inside open block`. Active frontier advances to `SPEC-LANG-REFERENCE.10.5.6`.

Index note 2026-07-08: `SPEC-LANG-REFERENCE.10.5.6` is done. The rule-modes/parse-modes page no longer puts
regex slots on `::` examples; regex-owning mode fragments use `:` labels, parse-mode examples use a verified
`Top::` + `Word:` wrapper, and the active frontier advances to `SPEC-LANG-REFERENCE.10.5.7`.

Index note 2026-07-08: `SPEC-LANG-REFERENCE.10.5.7` is done. The regex chapter's keyword, capture, and
compaction examples now use no-regex `Top::` wrappers plus single-colon regex-bearing rules, and the active
frontier advances to `SPEC-LANG-REFERENCE.10.5.8`.

Index note 2026-07-08: `SPEC-LANG-REFERENCE.10.5.8` is done. The blind-call orchestration chapter keeps
no-regex `::` wrapper examples, converts regex-owning action-edge examples to `:` labels, and the active
frontier advances to `SPEC-LANG-REFERENCE.10.5.9`.

Index note 2026-07-08: `SPEC-LANG-REFERENCE.10.5.9` is done. The action/lifecycle placement chapter now
uses normal `:` labels for regex-bearing examples, distinguishes entry-match `I`/`entry_*` from local-slot
action `match_*`, documents explicit lifecycle returns, and records the Perl lifecycle handler drift follow-up.
The active frontier advances to `SPEC-LANG-REFERENCE.10.5.10`.

Index note 2026-07-08: `SPEC-LANG-REFERENCE.10.5.20` is done. ADR `0020` records lifecycle
final-value/direct-`E` Perl handler-shape drift as a documented current-reference caveat until a
separately-owned implementation/parity leaf authorizes engine changes. The `.10.5` whole-book scorch
is complete and the active frontier returns to `SPEC-LANG-REFERENCE.5.3`.

Index note 2026-07-08: `SPEC-LANG-REFERENCE.5.3` is done. The helper-contract catalog now has
verified Array helper examples for value helpers, split/pipeline helpers, receiver chains, mutations,
and array-tree traversal; KM fact `array-helper-return-shape-caveats` records the compact split and
pipeline return-shape caveats. Optional normalization is deferred to `.5.3.1`; active frontier
advances to `SPEC-LANG-REFERENCE.5.4`.

Index note 2026-07-08: `SPEC-LANG-REFERENCE.5.4` is done. The helper-contract catalog now has
verified Hash and Control Flow helper examples; KM fact `hash-helper-odd-arity-current-behavior`
records the direct odd-arity `hash(...)` current-Perl caveat. Optional normalization is deferred
to `.5.4.1`; active frontier advances to `SPEC-LANG-REFERENCE.5.5`.

Index note 2026-07-08: `SPEC-LANG-REFERENCE.5.5` is done. The helper-contract catalog now has
verified examples for Declaration, Capture/Mark, Entry/Match, Input, and Call helper families;
stale entry-vs-match examples in the source-boundary chapters now use the verified ordered-child
shape recorded in KM fact `entry-match-divergence-verified-shape`. Helper-catalog sweep `.5`
is closed; active frontier advances to `SPEC-LANG-REFERENCE.6`.

Index note 2026-07-08: `SPEC-LANG-REFERENCE.6` is done. The source-boundary and action-placement
chapters now include a verified marker-form capture/mark cross-example using `@capture_slice`,
`@mark(body_start)`, `mark_match_start(close_start)`, `capture_slice()`, `capture_from(...)`, and
`capture_between(...)`; placement-sensitive named-mark examples now use action-local `mark_here(...)`
where exact timing is needed. KM fact `split-boundary-marker-action-timing` records the durable
marker visibility rule. Active frontier advances to `SPEC-LANG-REFERENCE.7`.

Index note 2026-07-08: `SPEC-LANG-REFERENCE.7` is done. The Knowledge Map now has canonical
`.spec`-language retrieval cards for output/return shape, regex backend feature contract,
rule-mode semantics, lifecycle/`retv` order, and capture/mark taxonomy; `spec-edge-syntax-contract`
now also routes action-vs-blind dispatch questions. Active frontier advances to
`SPEC-LANG-REFERENCE.8`.

Index note 2026-07-08: `SPEC-LANG-REFERENCE.8` is done and the `SPEC-LANG-REFERENCE` tree is closed.
Final consistency corrected stale top-rule doctrine drift after user reminder: ADR `0010` (2026-06-23)
is current doctrine (`::` is the entered-first marker; `::` and `:` share the same feature surface after
entry selection), and the June 17 no-regex/two-rule-minimum correction is historical. Focused probes,
mdBook, KM, memory, task-tree metadata, doctrine, and whitespace checks pass.

Index note 2026-07-04: `SPEC-FORMAT-TERSE.9` is now pending behind `.8` by explicit user directive. It replaces
Perlish direct hash-literal association syntax `{ key => value }` with terse `{ key : value }` across parser,
fixtures, active tests, mdBook, and current Knowledge Map facts.

Index note 2026-07-07: `SPEC-FORMAT-TERSE.9.3` Rust parser/runtime colon hash-literal parity is done. Rust now
accepts `{ key : value }` in direct hash literals during the migration window while old hash-pair `=>` remains
accepted until hard retirement and blind-call edge `=>` remains separate. Active frontier advances to
`SPEC-FORMAT-TERSE.9.4` for current-source/docs/corpus migration to colon hash-literal syntax.

Index note 2026-07-07: `SPEC-FORMAT-TERSE.9.4` current-source/docs/corpus migration is done. Current specs,
generated oracle inputs, active tests, mdBook examples, root docs, and current Knowledge facts now prefer
`{ key : value }` for direct hash-literal association; remaining `=>` owners are classified as blind-call edges,
source-language associations, generated Perl host output, metadata, historical material, or explicit compatibility
locks. Active frontier advances to `SPEC-FORMAT-TERSE.9.5` for hard retirement of old hash-literal `=>`.

Index note 2026-07-07: `SPEC-FORMAT-TERSE.9.6` final hash-literal colon no-drift closeout is done. Current
`.spec` source inputs are clean for direct hash-literal `=>`; remaining `=>` owners are blind-call edge syntax,
VHDL/source-language associations, generated Perl host output, metadata/test data, value-rendering examples,
explicit retired-syntax diagnostics/tests, or historical records. mdBook documents `:` as the current direct
hash-literal separator and old `{ key => value }` only as retired. The `.9` container is closed; no concrete
`SPEC-FORMAT-TERSE` PNT-eligible leaf remains unless a deferred/potential leaf is explicitly activated.

Index note 2026-07-08: `SPEC-FORMAT-TERSE.12.4` final no-drift closeout is done. mdBook helper/reference/formal/
backend-handoff docs, Knowledge Map retrieval, live docs, roadmap/architecture state, task-tree rows, and the
generated 96-fixture oracle corpus agree on the shipped hash-tree traversal surface. `SPEC-FORMAT-TERSE.12` is
closed/exhausted; `.10` and `.13` remain deferred/backlog unless explicitly activated.

Index note 2026-07-07: `SPEC-FORMAT-TERSE.9.2` Perl reference colon hash-literal support is done. Perl accepts
`{ key : value }` during the migration window, preserves old `{ key => value }` until hard retirement, keeps
generated Perl host `=>` internal, and protects block-vs-hash classification such as `{ JSON::PP }`. Frontier
advances to `SPEC-FORMAT-TERSE.9.3` for Rust parser/runtime parity.

Index note 2026-07-04: `SPEC-FORMAT-TERSE.10` is now tracked as deferred/potential by explicit user directive.
It owns the question of dynamic/computed hash-literal keys only if the spec first defines exact syntax and
semantics; it may instead be closed as dropped if the accepted `.9` hash-literal surface stays fixed-key only.

Index note 2026-07-08: `SPEC-FORMAT-TERSE.10.1` is done. The current direct hash-literal surface is explicitly
expression-keyed, not fixed-key-only: `{ key_expr : value_expr }` evaluates and stringifies the key expression,
bare keys are scalar reads, quoted keys are fixed fields, and computed helper expressions such as
`cat(prefix,suffix)` may supply keys. No parser/runtime behavior changed in this slice. `SPEC-FORMAT-TERSE.10`
is closed; the then-frontier moved to `.13` for the remaining `SPEC-FORMAT-TERSE` exhaustion work.

Index note 2026-07-05: `SPEC-FORMAT-TERSE.11` is now active by explicit user directive. It owns duck-typed
assignment semantics: `name = value` binds runtime typed values, including array/hash RHS values, without exposing
Perl scalar/array/hash storage classes as the `.spec` language model. The MVP keeps aggregate RHS values
delimiter-explicit (`name = [...]`, `name = {...}`); delimiterless comma/pair RHS sugar is out of scope unless a
future leaf specifies it. Nested references and assignments through mixed array/hash value trees are part of the
`.11` contract and must not inherit Perl autovivification behavior accidentally.

Index note 2026-07-05: `SPEC-FORMAT-TERSE.11.1` split/probe closure is done. The current source and toolbox probes
show that Perl still lowers direct RHS shape assignments into `@name`/`%name` target-kind inference and Rust still
has matching direct-shape assignment branches. Frontier advances to `SPEC-FORMAT-TERSE.11.2` for the Perl reference
duck-typed value-binding implementation, with Rust parity, nested value paths, and docs/KM/corpus closeout split
behind it.

Index note 2026-07-05: `SPEC-FORMAT-TERSE.11.2` Perl reference value binding is done. Bare Perl assignment targets
now bind typed RHS values through `$name`; direct RHS shape no longer emits `@name`/`%name` or matching aggregate
declarations solely from RHS shape. Explicit `array(...)` / `hash(...)` mutation targets remain aggregate storage,
and scalar-bound `array(name)` / `hash(name)` views read guarded snapshots. Frontier advances to
`SPEC-FORMAT-TERSE.11.3` for Rust parity.

Index note 2026-07-05: `SPEC-FORMAT-TERSE.11.3` Rust duck-typed assignment parity is done. Bare Rust assignment
and `set`/`=` helper forms now bind evaluated scalar/array/hash `RuntimeValue`s through the scalar value slot,
while explicit `array(...)` / `hash(...)` targets remain aggregate storage. The same leaf closed the
oracle-exposed Perl scalar-held `copy(name)` / bare array receiver fallback gap. The generated oracle corpus is 91
fixtures with `.11.3` value-binding cases, and the Rust oracle passes. Frontier advances to
`SPEC-FORMAT-TERSE.11.4` for nested mixed array/hash value paths.

Index note 2026-07-05: `SPEC-FORMAT-TERSE.11.4` nested mixed value-path assignment is done. Perl/Rust now support
direct-access lvalue paths such as `payload["items"][0]["name"] = value` over scalar-held array/hash values with
explicit no-autovivification semantics: intermediates must exist and match shape, final hash keys may be created,
final array indexes may replace or append at len, and failed path checks return `undef`/`null` without mutation.
The generated oracle corpus is 92 fixtures with `terse_11_4_nested_mixed_value_path_assignment`, and the Rust
oracle passes. Frontier advances to `SPEC-FORMAT-TERSE.11.5` for duck-typed assignment closeout alignment.

Index note 2026-07-05: `SPEC-FORMAT-TERSE.11.5` duck-typed assignment closeout alignment is done. Current roadmap
and Knowledge Map retrieval now describe direct RHS shapes as typed value binding; target-kind inference remains
only as explicitly superseded history. The `.11` container is closed and the active frontier advances to
`SPEC-FORMAT-TERSE.15`, followed by `.8` and `.9`.

Index note 2026-07-05: `SPEC-FORMAT-TERSE.12` and `.13` are now tracked as deferred/backlog by explicit user
directive. `.12` owns future hash-tree attached-block traversal; for that backlog item a hash-tree has a hash root,
hash interior nodes, and scalar or array leaves. `.13` tracks the analogous lower-priority array-tree traversal
idea. Neither is PNT-eligible unless explicitly reactivated.

Index note 2026-07-08: `SPEC-FORMAT-TERSE.13.1` is done. The user reactivated the remaining terse-format backlog,
and `.13` is now split before implementation. The accepted array-tree MVP uses `walk_leaves`, `map_leaves`, and
`reduce_leaves(initial)` on array-valued receivers, traverses nested arrays depth-first by zero-based index, treats
hashes as leaves, and binds scoped `value`, `index`, `path`, `depth`, plus reduce-only `acc`. The then-frontier
advanced to
`SPEC-FORMAT-TERSE.13.2` for the Perl reference implementation.

Index note 2026-07-08: `SPEC-FORMAT-TERSE.13.2` is done. The Perl reference now dispatches receiver
`walk_leaves`, `map_leaves`, and `reduce_leaves(initial)` over hash or array receiver values. Hash receivers keep
the `.12` sorted-key traversal contract; array receivers traverse nested arrays by zero-based index, treat hashes
as leaves, bind scoped `value`, `index`, `path`, `depth`, and reduce-only `acc`, and can feed array-family
continuations after `walk_leaves` / `map_leaves`. Full phase0 passes `1..1028`; the then-frontier advanced to
`SPEC-FORMAT-TERSE.13.3` for Rust/oracle parity.

Index note 2026-07-08: `SPEC-FORMAT-TERSE.13.3` is done. Rust now dispatches receiver `walk_leaves`,
`map_leaves`, and `reduce_leaves(initial)` over hash or array receiver values, preserving `.12` hash-tree
sorted-key traversal while array receivers recurse through nested arrays by zero-based index, treat hashes as
leaves, bind scoped `value`, `index`, `path`, `depth`, and reduce-only `acc`, and feed array-family continuations
after `walk_leaves` / `map_leaves`. The generated oracle corpus was then 97 fixtures after
`terse_13_3_array_tree_traversal_receiver_blocks`, and the Rust oracle passes. The then-frontier advanced to
`SPEC-FORMAT-TERSE.13.4` for final docs/KM/no-drift closeout.

Index note 2026-07-08: `SPEC-FORMAT-TERSE.13.4` is done. mdBook, Knowledge Map, live docs, task-tree rows,
roadmap state, and the then-current 97-fixture oracle manifest agree that array-tree traversal receiver blocks are shipped on
Perl/Rust. `SPEC-FORMAT-TERSE.13` is closed/exhausted, and no current `SPEC-FORMAT-TERSE` PNT-eligible leaf
remains unless the director activates new terse-format work.

Index note 2026-07-08: `SPEC-FORMAT-TERSE.13.5` is done. The parent `SPEC-FORMAT-TERSE` task-tree is now
`done` / `closed` in both the central index and task-file metadata. Stale internal split-container rows that
still looked active were converted to historical done/closed wording. No parser/runtime, corpus, or behavioral
mdBook semantics changed.

Index note 2026-07-08: `SPEC-FORMAT-TERSE.12` is reactivated by explicit user directive. `SPEC-FORMAT-TERSE.12.1`
split the accepted receiver methods, attached-block syntax, scoped callback bindings, traversal order,
array-leaf/error semantics, Perl/Rust parity, mdBook examples, tests, oracle fixtures, and Knowledge Map facts
before implementation.

Index note 2026-07-08: `SPEC-FORMAT-TERSE.12.2` Perl reference implementation is done. Perl now accepts
`walk_leaves`, `map_leaves`, and `reduce_leaves(initial)` receiver attached-block traversal with sorted
depth-first leaf walking, scoped callback bindings, array leaves, invalid-receiver `undef`, and unsupported-helper
diagnostics for malformed calls. Full phase0 passes `1..1027`. Frontier advances to `SPEC-FORMAT-TERSE.12.3` for
Rust parser/runtime parity and generated oracle fixtures.

Index note 2026-07-08: `SPEC-FORMAT-TERSE.12.3` Rust parser/runtime parity is done. Rust now accepts
`walk_leaves`, `map_leaves`, and `reduce_leaves(initial)` receiver attached-block traversal with sorted depth-first
hash-tree walking, scoped callback bindings, array leaves, invalid-receiver `undef`, malformed-call diagnostics,
and compatible hash-family continuations for `walk_leaves` / `map_leaves`. The generated oracle corpus is now
96 fixtures after `terse_12_3_hash_tree_traversal_receiver_blocks`, and the Rust oracle passes. Frontier advances
to `SPEC-FORMAT-TERSE.12.4` for mdBook, Knowledge Map, live-doc, and no-drift closeout.

Index note 2026-07-05: `SPEC-FORMAT-TERSE.14` is now tracked as deferred/spec backlog by explicit user directive.
It owns a future trailing block-argument type for helpers and receiver methods: blocks may be passed only as the
final argument, preferred syntax is `fn(args) { ... }`, invocation by the callee must be specified explicitly, and
closures/assignable blocks/returnable blocks remain out of scope.

Index note 2026-07-07: `SPEC-FORMAT-TERSE.14` is reactivated by explicit user directive. `.14.1` split the work
before code and selected `with(value) { ... }` as the helper-function MVP for immediate, non-closure block arguments;
receiver `.with() { ... }`, Rust parity, and docs/KM/oracle closeout are later children. `.14.2` then landed the
Perl reference helper-function form implementation.

Index note 2026-07-07: `SPEC-FORMAT-TERSE.14.2` Perl helper-function form trailing block arguments are done.
`with(value) { ... }` / `with() { ... }` now parse as flagged final block arguments on the Perl reference, bind
scoped `value`, preserve block-local `return(expr)`, keep hash literals separate, and diagnose unknown trailing-block
callees. Frontier moved to `SPEC-FORMAT-TERSE.14.3` for Rust helper-function form parity.

Index note 2026-07-07: `SPEC-FORMAT-TERSE.14.3` Rust helper-function form trailing block parity is done. Rust now parses
and executes `with(value) { ... }` / `with() { ... }` with call-site execution context, scoped scalar `value`,
block-local `return(expr)`, hash payload preservation, and a 94th oracle fixture. Frontier moved to
`SPEC-FORMAT-TERSE.14.4` for receiver `.with() { ... }`.

Index note 2026-07-07: `SPEC-FORMAT-TERSE.14.4` receiver-form trailing block arguments are done. Perl/Rust now
accept receiver `.with() { ... }`, bind the receiver as scoped `value`, feed the block result into compatible
receiver-family continuations, and reject explicit receiver `.with(value) { ... }`. The Rust oracle corpus is now
95 fixtures after `terse_14_4_receiver_with_trailing_block`. Frontier moved to `SPEC-FORMAT-TERSE.14.5` for final trailing block-argument no-drift closeout.

Index note 2026-07-07: `SPEC-FORMAT-TERSE.14.5` final trailing block no-drift closeout is done. Roadmap, mdBook
status, Knowledge Map retrieval, live docs, task-tree rows, and the generated 95-fixture oracle corpus now agree
that the shipped trailing block surface is helper-function `with(value) { ... }` / `with() { ... }` plus
receiver-method `.with() { ... }` only. `SPEC-FORMAT-TERSE.14` is closed; no current PNT-eligible
`SPEC-FORMAT-TERSE` leaf remains unless a deferred leaf is explicitly reactivated or a new owned leaf is split.

Index note 2026-07-05: `SPEC-FORMAT-TERSE.15` is now pending by explicit user directive. It owns removing
colon-prefixed scalar variable references from the future duck-typed surface: bare names read variables/parameters
in value positions, while bare names in hash-literal key position remain stringified keys.

Index note 2026-07-05: `SPEC-FORMAT-TERSE.15.1` colon scalar-slot removal audit/split is done. Current `:name`
usage spans shipped/root specs, corpora, generated oracle fixtures, mdBook guidance, Knowledge Map facts,
Perl/Rust tests, oracle generation sources, and parser/runtime support, so hard removal is split. Current frontier
advances to `SPEC-FORMAT-TERSE.15.2` for current spec/corpus/docs/KM migration to bare value reads before Perl and
Rust parser/runtime retirement.

Index note 2026-07-05: `SPEC-FORMAT-TERSE.15.2` is RE-SCOPED engine-first and `.15` is re-sequenced. Executing the
source-first `.15.2` migration proved it is NOT output-preserving at `104088e5`: bare identifiers are not read as
the bound variable value in `switch(...)`, numeric callees, `if(...)` conditions, or all-bare `push(A,B)` second
args, and collide with rule names in `spec.spec`/`ebnf.spec` (direct probe: `switch(:kind)`->`'good'` vs
`switch(kind)`->`'def'`). Per the user directive that `:name` shall NOT be supported, `.15.2` now owns engine-first
bare-read completion (`.15.2.1` design, `.15.2.2` Perl, `.15.2.3` Rust, `.15.2.4` source migration), then `.15.3`
(Perl) and `.15.4` (Rust) remove `:name` entirely with no compat, then `.15.5` closes drift. A prior session's
uncommitted intermingled `.15.2/.15.3/.15.4/.8/.9` work (phase0 RED) is preserved on branch
`recovery/terse-15-uncommitted-20260705`; `main` is clean at `104088e5`. See ADR `0019` and KM card
`terse-bare-read-value-position-gap`. Current frontier advances to `SPEC-FORMAT-TERSE.15.2.1`.

Index note 2026-07-06: `SPEC-FORMAT-TERSE.15.2.1`, `.15.2.2`, and `.15.2.3` are now done. Perl and Rust both
honor the value-position-is-variable policy for bare switch subjects, numeric/comparison helper args, and
`if(...)`/condition positions, while bare switch `case(foo)` labels remain literal tags on attached and inline
switch forms. The Rust oracle corpus is **93 fixtures** after
`terse_15_2_3_bare_value_reads_and_case_labels`, and `specs/spec.spec` initializes self-hosted parser aggregates
with explicit `array(...)` targets after the `.11` duck-typed assignment model. Current frontier advances to
`SPEC-FORMAT-TERSE.15.2.4` for the output-preserving source/corpus/docs/KM migration from `:name` to bare reads.

Index note 2026-07-06: `SPEC-FORMAT-TERSE.15.2.4` source/corpus/docs migration is done. Current shipped specs,
root corpus inputs, generated Rust oracle inputs, and mdBook examples now use bare value reads instead of live
`:name` scalar-slot reads; regenerated **93** fixture oracle expected JSON and manifest are unchanged, phase0 and
Rust corpus oracle pass, and mdBook builds. Current frontier advances to `SPEC-FORMAT-TERSE.15.3` for Perl
reference `:name` parser/lowering removal.

Index note 2026-07-06: `SPEC-FORMAT-TERSE.15.3` Perl reference retirement is done. Perl ActionIR AST parsing,
lowering, rewrite diagnostics, and EmitContext compatibility no longer accept `:name` as a successful scalar read or
target; retired colon scalar slots emit `LINKEDSPEC_UNSUPPORTED_ACTIONIR_HELPER:colon_scalar_slot_use_bare_read`,
active Perl tests/fixtures use bare reads, focused ActionIR/trace tests pass, and full phase0 reaches `1..1022`.
Current frontier advances to `SPEC-FORMAT-TERSE.15.4` for Rust `Expr::ScalarSlot` parser/runtime retirement.

Index note 2026-07-06: `SPEC-FORMAT-TERSE.15.4` Rust retirement is done. Rust `Expr::ScalarSlot` is gone from the
core AST and runtime/source-emitter paths; retired colon scalar slots now emit
`LINKEDSPEC_UNSUPPORTED_ACTIONIR_HELPER:colon_scalar_slot_use_bare_read` with bare-read migration guidance. Current
Rust fixtures use bare reads, the EBNF spec and generated EBNF oracle inputs use `rule_header` instead of the old
same-name scalar/array `rule` collision, and the generated corpus case was renamed to
`terse_15_4_bare_scalar_payload_readback`. Focused Rust suites and the 93-fixture corpus oracle pass. Current
frontier advances to `SPEC-FORMAT-TERSE.15.5` for final no-drift closeout.

Index note 2026-07-06: `SPEC-FORMAT-TERSE.15.5` final no-drift closeout is done. Current specs, generated corpus
inputs, mdBook guidance, active tests, and non-historical Knowledge Map facts no longer depend on successful
`:name` scalar slots; remaining hits are retired-diagnostic code/tests, rule-mode/regex/public-API colon syntax, or
historical records. The closeout corrected stale Knowledge fact-card examples to bare `items` / `meta` and
`substr(target, ...)`. The `.15` container is closed and the active frontier advances to `SPEC-FORMAT-TERSE.8`;
`SPEC-FORMAT-TERSE.9` remains pending behind `.8`.

Index note 2026-07-06: `SPEC-FORMAT-TERSE.8.1` split legacy helper retirement before behavior changes. Perl probes
show `assign(...)`, `scalar(...)`, and `s(...)`/`a(...)`/`h(...)` are already raw or diagnostic, while declaration
helpers, `concat(...)`, `array_copy(...)`, `hash_copy(...)`, `push_value(...)`, and `push_nonempty(...)` still have
successful Perl paths. Rust still executes `declare`, `array_copy`, `hash_copy`, `concat`, `push_value`,
`push_nonempty`, and `array|a` / `hash|h` wrapper aliases. The frontier then advanced to `SPEC-FORMAT-TERSE.8.2`, which
owns current-source/test/corpus/doc migration and the `push_nonempty(...)` replacement decision before hard
retirement.

Index note 2026-07-06: `SPEC-FORMAT-TERSE.8.2.1` migrated the live EBNF optional-capture append away from
`push_nonempty(...)`. The shipped `logging_annotation` rule now evaluates `trim(capture_slice())` once into
`logging_annotation_part`, gates with `is_nonempty(...)`, and appends with `push(...)`; generated EBNF oracle
inputs and the EBNF mdBook walkthrough match the shipped spec with unchanged `expected.json`. Active frontier is
now `SPEC-FORMAT-TERSE.8.2.2` for incidental active test/corpus old-helper cleanup.

Index note 2026-07-06: `SPEC-FORMAT-TERSE.8.2.2.1` migrated Rust source-emitter smoke specs away from incidental
legacy helper spellings. The fixtures now use `set(array(...), [])`, `push(...)`, `copy(...)`, and `cat(...)`;
explicit aggregate reset is required where the old `declare(array, name)` prepared named aggregate storage. The
source-emitter generated Rust compile/run suite passes all 3 tests. Active frontier is now
`SPEC-FORMAT-TERSE.8.2.2.2` for Rust integration-test helper-string migration/classification.

Index note 2026-07-06: `SPEC-FORMAT-TERSE.8.2.2.2.1` migrated the non-compatibility Rust integration smoke
fixtures before the recursive and explicit compatibility blocks. The full Rust integration suite passes all 172
tests. The next active frontier then became `SPEC-FORMAT-TERSE.8.2.2.2.2` for TOP-RULE-AS-NORMAL recursive
helper-string migration/classification.

Index note 2026-07-06: `SPEC-FORMAT-TERSE.8.2.2.2.2` migrated the TOP-RULE-AS-NORMAL recursive integration-test
append/snapshot helpers to current `push(...)`, `copy(...)`, and `array(...)` spellings. `declare(array, items)`
is intentionally retained there as a Rust scoped-declaration compatibility lock: the current-surface
`set(array(items), [])` replacement preserves the Perl probe but fails Rust recursive value parity. The active
frontier then became `SPEC-FORMAT-TERSE.8.2.2.2.3` for explicit legacy-helper compatibility/equivalence tests.

Index note 2026-07-06: `SPEC-FORMAT-TERSE.8.2.2.2.3` migrated current-side helper spellings and annotated retained
old-helper sides in explicit Rust legacy-helper compatibility/equivalence tests. The full Rust integration suite
passes all 172 tests. The next active frontier then became `SPEC-FORMAT-TERSE.8.2.2.2.4` for later current-feature
Rust integration fixture cleanup.

Index note 2026-07-06: `SPEC-FORMAT-TERSE.8.2.2.2.4` migrated later current-feature Rust integration fixtures to
current helper spellings where supported. The full Rust integration suite passes all 172 tests. Hash receiver
`.hash_copy()` and wrapper alias `h(...)` remained for `SPEC-FORMAT-TERSE.8.2.2.2.5` classification. The next
active frontier then became `SPEC-FORMAT-TERSE.8.2.2.2.5`.

Index note 2026-07-06: `SPEC-FORMAT-TERSE.8.2.2.2.5` closed Rust integration-test helper-string residue
classification. Remaining `integration_test.rs` old-helper hits are explicitly owned by recursive declaration
scope, `.8.4` legacy-helper compatibility, current hash receiver-method surface, or wrapper-alias retirement. Active
frontier then became `SPEC-FORMAT-TERSE.8.2.2.3` for generated oracle corpus fixture input cleanup.

Index note 2026-07-06: `SPEC-FORMAT-TERSE.8.2.2.3` migrated generated oracle corpus fixture inputs to current
`push(...)`/`copy(...)` spellings where behavior is current-surface, while retaining/classifying declaration,
aggregate-copy, and hash receiver-method residues. Regeneration kept oracle expected JSON and manifest output
stable, and Rust `corpus_oracle` passes over 93 fixtures. Active frontier is now
`SPEC-FORMAT-TERSE.8.2.2.4` for Perl phase0 helper-string migration/classification.

Index note 2026-07-06: `SPEC-FORMAT-TERSE.8.2.2.4` migrated/classified Perl phase0 helper strings. Current-surface
fixtures now use `cat(...)`, `push(...)`, and `copy(...)` where they are not compatibility locks; retained
old-helper residue is owned by scoped-declaration compatibility, `push_nonempty(...)` semantic filtering,
aggregate-copy compatibility, helper-renaming equivalence, canonical old-side equivalence, or current
`.hash_copy()` receiver-method surface. Full phase0 passes 1022 tests. Active frontier is now
`SPEC-FORMAT-TERSE.8.2.2.5` for active-test/corpus residue scans.

Index note 2026-07-06: `SPEC-FORMAT-TERSE.8.2.2.5` closed active-test/corpus helper residue scans. Root
`specs/` and `tests/corpus/` are clean for retired helper spellings; generated oracle inputs retain only owned
declaration, aggregate-copy, and current hash receiver-method categories; phase0 residue remains within
`.8.2.2.4` compatibility/equivalence categories; and Rust integration `a(...)` / `h(...)` wrapper-alias residue is
labelled for `.8.4` retirement. `.8.2.2` is done and active frontier is now `SPEC-FORMAT-TERSE.8.2.3` for
current-facing mdBook/KM helper-reference cleanup.

Index note 2026-07-06: `SPEC-FORMAT-TERSE.8.2.3` migrated current-facing mdBook and Knowledge Map helper
references before engine retirement. Book examples now teach `cat(...)`, `copy(...)`, assignment/operator forms,
`push(...)`, and explicit `is_nonempty(...)` guards before `push(...)`; old helper names remain only in
compatibility, retired-diagnostic, or historical contexts. Knowledge fact-card `reverify` commands avoid removed
spellings unless explicitly proving retirement/compatibility, and `KNOWLEDGE_MAP.md` was regenerated. Active
frontier is now `SPEC-FORMAT-TERSE.8.2.4` for the `.8.2` no-drift scan/gate closeout before hard retirement.

Index note 2026-07-06: `SPEC-FORMAT-TERSE.8.2.4` closed the `.8.2` migration parent before hard retirement.
Root `specs/` and `tests/corpus/` scans are clean for primary retired helper spellings and wrapper aliases;
generated corpus/test residues are classified as `.8.3`/`.8.4` compatibility/retirement locks or current
receiver-method surface; oracle regeneration remains stable over **93** fixtures; Rust `corpus_oracle`, full
phase0 **1022**, mdBook, whitespace, and doctrine gates pass. `.8.2` is done and active frontier is now
`SPEC-FORMAT-TERSE.8.3` for Perl reference hard retirement.

Index note 2026-07-06: `SPEC-FORMAT-TERSE.8.3` hard-retired Perl reference support for legacy helper spellings.
Declaration helpers and aliases, function-form `concat(...)`, `array_copy(...)`, `hash_copy(...)`,
`push_value(...)`, and `push_nonempty(...)` now emit `LINKEDSPEC_UNSUPPORTED_ACTIONIR_HELPER:<name>` diagnostics
instead of lowering successfully. Current `cat(...)`, `copy(...)`, `push(...)`, assignments, typed wrappers, and
receiver methods still lower; source-method preservation keeps current `cat(...)` distinct from retired
parser-normalized `concat(...)`. Focused Perl AST/trace/validation suites and full phase0 **1022** pass. Frontier
advanced to `SPEC-FORMAT-TERSE.8.4` for Rust hard retirement.

Index note 2026-07-07: `SPEC-FORMAT-TERSE.8.4` hard-retired Rust parser/runtime support for legacy helper
spellings. Rust now diagnoses `declare`, `array_copy`, `hash_copy`, `concat`, `push_value`, `push_nonempty`, and
wrapper aliases `a(...)` / `h(...)` instead of executing them successfully. Current `set(array(...), [])`,
`push(...)`, `copy(...)`, `cat(...)`, `array(...)`, `hash(...)`, and receiver `.copy()` spellings keep Perl/Rust
corpus parity; recursive TOP-RULE aggregate reset now records rule-local bindings so `set(array(items), [])`
replaces the old scoped `declare(array, items)` boundary. Oracle regeneration also fixed attached control-flow source
reconstruction to preserve `source_method` for current helper spellings. Full Rust core/runtime package tests and
full phase0 **1022** pass. Active frontier is now `.8.5` / `.8.6` cleanup.

Index note 2026-07-07: `SPEC-FORMAT-TERSE.8.5` reconciled current-facing docs, root guide framing, Rust README,
Knowledge facts, and live task records after Perl/Rust helper hard retirement. Current guidance teaches
auto-existing variables, assignments, `set(...)`, `push(...)`, `copy(...)`, `cat(...)`, `array(...)`, `hash(...)`,
and bare scalar reads; old helper names are retained only as historical or retired-diagnostic material. Knowledge
Map and mdBook checks pass. Active frontier is now `.8.6` final helper-retirement no-drift closeout before `.9`.

Index note 2026-07-07: `SPEC-FORMAT-TERSE.8.6` closed final helper-retirement no-drift. Current specs/corpora are
clean for retired helper calls; remaining old helper names are classified as diagnostics, regression locks,
historical notes, Knowledge facts, or explicit retired-helper reference material. The root guide now teaches
`cat(...)` for scalar assembly and marks source-spelled `concat(...)` retired. Oracle regeneration is byte-identical
over **93** fixtures and Rust `corpus_oracle` passes **3** tests. Active frontier advances to
`SPEC-FORMAT-TERSE.9` for hash-literal colon association syntax.

Index note 2026-07-07: `SPEC-FORMAT-TERSE.9.1` split the hash-literal colon migration before implementation.
Direct ActionIR hash-literal `=>` candidates are now separated from blind-call edge syntax, VHDL/source-language
associations, historical records, active fixture strings, and parser/runtime support sites. A Knowledge fact records
the split and the implementation order. Active frontier advances to `SPEC-FORMAT-TERSE.9.2` for Perl reference
`{ key : value }` support.

Index note 2026-07-02: `SPEC-FORMAT-TERSE.3.3.4` is now done. Scalar, direct-shape aggregate, array append, hash-index mutation, operator-call, canonical `set(...)`, and legacy `assign(...)` assignment expressions are shipped on Perl/Rust; corpus is **62 fixtures**, phase0 is **1015 green**. The later `.6` shipped-spec terse migration lane reactivated concrete `SPEC-FORMAT-TERSE` frontier leaves.

Index note 2026-07-04: `SPEC-FORMAT-TERSE.6.2.4` is now done. All 21 shipped `specs/*.spec` files compile from
this checkout, shipped-spec scans are clean for retired `scalar(...)` / `assign(...)`, `declare(...)`, and older
helper spellings, phase0 passes with **1020** tests, oracle regeneration remains stable at **73 fixtures** with no
tracked corpus diff, Rust `corpus_oracle` passes all 73, and mdBook builds with no `scalar(...)` / `assign(...)`
hits. Broader checked-in corpus/book `declare(...)` and old-helper references are explicitly owned by `.6.3`.
Frontier advances to `.6.3` for the public docs/corpus/example sweep.

Index note 2026-07-04: `SPEC-FORMAT-TERSE.6.3` is now done. Current-facing mdBook examples and root checked-in
corpus specs now use terse initialization/mutation and canonical helper spellings instead of active
`declare(...)` or old helper names. Generated Rust oracle inputs use canonical helpers where old spellings were
incidental; residual old spellings are compatibility/reference-only. Root corpus probes pass, oracle regeneration
remains **73 fixtures** with no expected-output drift, Rust `corpus_oracle` passes, and mdBook builds. Frontier
advances to `.6.4` for the post-migration compatibility-support policy.

Index note 2026-07-04: `SPEC-FORMAT-TERSE.6.4` is now done. At this historical leaf, declaration helpers were kept as
legacy compatibility for existing specs while new shipped specs, public examples, and current corpus examples used
terse auto-existing variables and assignment/mutation forms. `SPEC-FORMAT-TERSE.8` later superseded this retention
policy and hard-retired the helpers. Declaration-retirement `.6` is closed. Frontier advances to `.7.1` for the
supported-type method audit.

Index note 2026-07-04: `SPEC-FORMAT-TERSE.7.1` is now done. The supported receiver/value families are
inventoried before code: string/scalar, array/list, hash, and number have existing receiver method tables;
booleans/flow results are terminal today; expression-valued blocks and user-function returns dispatch by yielded
runtime type. String `substr()` is already a receiver method on the current Perl/Rust surface. Mutation,
lifecycle/control, child-dispatch, parser-state reader, declaration, and compatibility helpers remain
function/statement/lifecycle-only unless a future leaf defines safe receiver semantics. Frontier advances to
`.7.2` for string/scalar verification and any real backfill.

Index note 2026-07-04: `SPEC-FORMAT-TERSE.7.2` is now done. String/scalar receiver backfill needed no
parser/runtime change: `substr()` and the other useful pure string links from `.7.1` are already method-callable
on Perl/Rust, and public docs already demonstrate helper-form/method-form equivalence. Focused Perl probes return
`["BCD","BCD",2]` for method `substr`, helper `substr`, and split bridge evidence with zero fallback/raw/
unresolved descriptor counts; focused Rust `terse_2_3_5_3` tests pass. Frontier advances to `.7.3` for
array/list, hash, and number receiver backfill audit.

Index note 2026-07-04: `SPEC-FORMAT-TERSE.7.3` is now done. Array/list numeric reducer receiver methods
`sum`, `avg`, `median`, `range`, `min`, and `max` are terminal links on Perl/Rust, including after array-returning
links such as `sorted().take(...)` and Perl internal pure array-pipeline links such as `uniq()`. Invalid reducer
continuations return `undef`/`null`; hash and number mutation/ambiguous boundaries remain explicit. Phase0 passes
with **1021** tests, the Rust oracle corpus passes **74 fixtures**, and mdBook examples/catalog entries are in sync.
Frontier advances to `.7.4` for the final type-method no-drift sweep.

Index note 2026-07-04: `SPEC-FORMAT-TERSE.7.4` is now done. The type-method no-drift sweep reconciled current
roadmap, task-tree, mdBook helper/reference summaries, and Knowledge Map facts. Current receiver families are
string/scalar, array/list, hash, and number; array numeric reducers are terminal array/list receiver methods, not
scalar number receiver links; mutation/lifecycle/control/child-dispatch/parser-state/declaration/compatibility
surfaces remain explicit unless a future leaf defines safe receiver semantics. The `.7` lane is closed and the
`SPEC-FORMAT-TERSE` frontier is empty. `TRACE-OBSERVABILITY.3` has since split, `.3.1` through `.3.5` have closed, `.4.2` has added Rust trace controls, `.4.3` has added Rust compile/spec-parser trace events, and `.4.4` has added Rust runtime trace events; the trace tree has since closed; PNT returns to the active task-tree index unless a new terse leaf is split or another active tree is reprioritized.

Index note 2026-07-03: `SPEC-FORMAT-TERSE.6.1` is now done. The user directive that `declare(...)` shall not be
used in spec files is owned under the existing terse-format tree, not under `RUST-PARITY`. Active inventory found
70 `declare(...)` hits across 13 shipped specs. Frontier advances to `.6.2` to migrate shipped specs to
auto-existing variables, assignments, direct shape literals, and type-implying terse positions.

Index note 2026-07-03: `SPEC-FORMAT-TERSE.6.2.1` is now done. Active shipped specs no longer use
`declare(...)` or fluent `.declare(...)`; focused compile, phase0 (**1018 green**), and the Rust corpus oracle
(**66 fixtures**) pass. Frontier advances to `.6.2.2` for old helper spellings. The user's broader type-method
directive, including string `substr()` as a receiver method and a full useful-method audit by supported type, is
tracked as future `SPEC-FORMAT-TERSE.7.1` backlog after the `.6` migration lane unless explicitly reprioritized.

Index note 2026-07-03: `SPEC-FORMAT-TERSE.6.2.2` is now done. Active shipped specs no longer use old helper
spellings `assign(...)`, `push_value(...)`, `array_copy(...)`, `hash_copy(...)`, or `concat(...)`; `portmap.spec`
also omits redundant standalone separators after flow markers. Focused compile, phase0 (**1018 green**), and the
Rust corpus oracle (**66 fixtures**) pass. Frontier advances to `.6.2.3` for typed-wrapper/direct-shape cleanup.

Index note 2026-07-04: `SPEC-FORMAT-TERSE.6.2.3.2` is now done. Authored/current `.spec` files no longer use or
support `scalar(...)` scalar-slot reads or `assign(...)` assignment aliases; scalar slots use `:name`, assignment
uses `LHS = RHS` or `set(...)`, initialized bare identifiers remember scalar/array/hash kind, active spec/corpus
and mdBook scans are clean, and phase0 passes with **1020** tests. Frontier advances to `.6.2.4` for final
shipped-spec terse-surface verification and no-drift inventory.

Index note 2026-07-03: `SPEC-FORMAT-TERSE.6.2.3.1` is now done. `:name` is the terse scalar-slot spelling on
Perl/Rust; it reads scalar slot `name`, and `set(:payload, [value])` kept scalar-held direct-shape payload
assignment at that migration point. The then-current bare direct-shape aggregate inference behavior has since been
superseded by `.11` duck-typed value binding. Phase0 passes with **1019** tests and the Rust oracle corpus passes
over **73 fixtures** including `terse_6_2_3_1_scalar_slot_shorthand`. Frontier advances to
`.6.2.3.2` for shipped-spec wrapper migration.

Index note 2026-07-03: `RUST-PARITY.7.3.4.2` is now done. Runtime boolean helpers (`or`/`and`/`not`), list-context
splicing for explicit flattening helper arguments, and per-rule regex alternation isolation now make `portmap`
scalar classifications match Perl for `foo`, `bar[3]`, `baz[7:0]`, and `0x1f`. Four `portmap_*` oracle fixtures
entered the corpus, which is green over **72 fixtures**. Frontier advances to `.7.3.4.3` for action-edge fluent
child/target aggregation (`ebnf` payloads and `portmap` concatenation).

Index note 2026-07-04: `RUST-PARITY.7.3.4.3` is now done. Rust action-edge blocks and fluent chains reuse the
already matched child return for `call(child)`, `push(child)`, `push(child,target)`, and child-index push forms,
and passive terminal children are not re-searched after the parent edge match. Added `portmap_concatenation`,
`ebnf_expression_rules`, and `ebnf_logging_annotation`; the Rust oracle corpus is green over **77 fixtures**.
Frontier advances to `.7.3.5` for `.7.2` null/action-parser candidate triage.

Index note 2026-07-04: `RUST-PARITY.7.3.5` is now done. `BNF`, `DT`, `ifelse`, and `operators_try`
representative inputs are Perl `null` diagnostic/debug-print cases and were not promoted as semantic oracle
fixtures; Rust now ignores quoted braces while scanning `.spec` code blocks, fixing the `operators_try`
action-parser warnings. Added `spec_spec_minimal_rule`, `spec_spec_action_edge`,
`spec_spec_user_function_definition`, and `spec_spec_comment_skip`; the Rust oracle corpus is green over
**81 fixtures**. Frontier advances to `.7.3.6` for RTL/plugin/legacy shipped-spec smoke audit under the hardened
timeout guard.

Index note 2026-07-04: `RUST-PARITY.7.3.6` is now done. Added seven green RTL/plugin/legacy safety smokes:
`regdef_nested_register_fields`, `tablegrep_simple_term`, `simenv_multiline_value`, `vhdl_library_use`,
`ds_vhistory_version_entry`, `pplugin_empty`, and `tkgui_empty`; the Rust oracle corpus is green over
**88 fixtures**. Richer `pplugin`, `tkgui`, `sdce`, recursive `tablegrep`, `simenv`, VHDL, `ds_vhistory`, and
placeholder `verilog` mismatches are recorded for follow-up. Frontier advances to `.7.4` for the final oracle
corpus guard/finalization leaf.

Index note 2026-07-04: `RUST-PARITY.7.4` is now done. The oracle generator writes a root
`manifest.json` with the intended 88-fixture set and rejects duplicate case names; the Rust oracle runner loads
that manifest, rejects missing fixture directories and stale extra fixture directories, then executes all fixtures
in manifest order. The corpus oracle passes **3 tests** including two focused drift guards plus all **88**
fixtures. `RUST-PARITY.7` is closed and the frontier advances to `.8` for the code-generation emitter.

Index note 2026-07-04: `RUST-PARITY.8.1` is now done. The broad code-generation emitter leaf is split before
implementation: Rust currently interprets a native `CompiledSpec`/`CompiledRule` structural contract with parsed
lifecycle `CodeBlock`s, while Perl HandlerIR has 10 structural variants and Perl/JSON emitters. The `.8` lane now
owns a generated Rust-source path without weakening the interpreter or oracle gates. Frontier advances to `.8.2`
for the minimal emitter API plus compile/run harness.

Index note 2026-07-04: `RUST-PARITY.8.3` is now split before implementation. The non-repetition generated-family
lane still bundled rule-mode/family metadata, generated family-plan emission, direct acode execution, direct bcode
execution, and final matrix closeout. The frontier then advanced to `.8.3.1` for rule-mode/family metadata plus
generated non-REP family-plan emission.

Index note 2026-07-04: `RUST-PARITY.8.3.1` is now done. Rust `CompiledRule` preserves parsed rule mode, generated
Rust source embeds a `GENERATED_RULES` family plan, and the generated entry point validates that plan against the
embedded compiled spec before delegating through the current interpreter. The focused generated-source matrix covers
default, OR acode, AND single-acode, AND sequential-acode, AND bcode, and OR bcode family markers. Current frontier
advanced to `.8.3.2` for direct default/OR acode generated execution.

Index note 2026-07-04: `RUST-PARITY.8.3.2` is now done. Generated source now enters the plan-aware executor instead
of whole-parser `Engine::execute(...)`; default and OR acode families run directly with interpreter-equivalent
lifecycle, action-edge child-return, default repetition, and zero-progress semantics. Current frontier advances to
`.8.3.3` for direct AND acode generated execution.

Index note 2026-07-04: `RUST-PARITY.8.3.3` is now done. Generated source now directly handles AND single-acode and
AND sequential-acode families; Rust non-repetition AND regex/acode matching now requires ordered regex-slot
sequence before completion. The frontier then advanced to `.8.3.4` for direct AND/OR bcode generated execution.

Index note 2026-07-04: `RUST-PARITY.8.3.4` is now done. Generated source now directly handles AND bcode sequential
dispatch and OR bcode first-match dispatch; blind-edge tail execution is shared with the interpreted path. The
frontier then advanced to `.8.3.5` for the non-repetition generated-family matrix closeout before REP work.

Index note 2026-07-04: `RUST-PARITY.8.3.5` is now done. Generated-plan routing is exhaustive across all six
non-repetition generated families, and the source-emitter matrix asserts that complete family coverage before REP
work starts. `.8.4` has since closed direct REP generated-family execution and `.8.5` has closed
oracle/corpus subset integration, and `.9` has since closed the tree.

Index note 2026-07-04: `RUST-PARITY.8.5` is now done. The generated-source proof now combines the all-family
matrix with a manifest-backed oracle corpus subset covering authored proof cases, terse helper/control/user-function
cases, and shipped `tclite`/`portmap` smokes. The full 88-fixture corpus remains the interpreter oracle gate; ``.8`
is closed; `.9` has since closed the tree.

Index note 2026-07-04: `RUST-PARITY.9` is now done, closing the `RUST-PARITY` tree. Roadmap, live docs, mdBook
backend handoff, Rust README, task-tree index, and `ARCHITECTURE_STATE.md` now agree on the Rust state: the
interpreter oracle is green over 88 manifest fixtures plus drift guards, generated source directly executes every
current structural family, and generated-source corpus proof is curated rather than the full corpus. Closing
`RUST-PARITY` unblocked `TOP-RULE-AS-NORMAL.3.2`; that leaf has since closed, `TRACE-OBSERVABILITY.1` completed its read-only audit, `TRACE-OBSERVABILITY.2` added CLI trace control, `.3` split before code, `.3.1` through `.3.5` closed, `.4.2` added Rust trace controls, `.4.3` added Rust compile/spec-parser trace events, `.4.4` added Rust runtime trace events, and `.4.5` closed the parity proof. No `TRACE-OBSERVABILITY` frontier remains.

Index note 2026-07-02: `RUST-PARITY.7.5.3` is now reconciled done. The action-edge fluent implementation landed
under `SPEC-FORMAT-TERSE.2.3.3.*`, the `tclite_command_subst` and `tclite_double_quote` oracle fixtures are active
and green, and the `RUST-PARITY` frontier advances to `.7.5.2` for Lispish `scalaref(retv, {content})`.

Index note 2026-07-02: `RUST-PARITY.7.5.2` is now done. Rust temporarily parsed/evaluated Lispish legacy
`scalaref(retv, {content})` paths, contains child-return accumulator pushes, supports the Lispish aggregate-wrapper
assignment clear, and the `lispish_x_y` fixture entered the 63-fixture oracle corpus. `SCALAREF-RETIREMENT.3/.4`
later migrated that fixture to direct access and removed `scalaref` support. The `RUST-PARITY` frontier advances
to `.7.2` after the retirement tree closes.

Index note 2026-07-02: `SCALAREF-RETIREMENT` is now active from the user directive that `scalaref(...)` shall be
retired and removed. `.1` owns/splits the directive; frontier is `.2` inventory and replacement contract before any
behavior change.

Index note 2026-07-02: `SCALAREF-RETIREMENT.2` is now done. Inventory found 16 function-form calls in shipped
specs, live corpus/docs/tests/implementation support, and receiver-dot `.scalaref(...)` examples. The canonical
replacement is direct nested access for function form (`retv["content"]`, `retv["children"][0]["name"]`) and
named hash temporary plus `scalar(hash(temp), key)` for expression receiver-dot cases. Direct bracket reads are
for scalar hashref payloads, not named working-hash value reads. Frontier advances to `.3` migration.

Index note 2026-07-02: `SCALAREF-RETIREMENT.3` is now done. Shipped specs, checked-in Rust oracle fixtures,
focused tests, public mdBook chapters, user guides, and the oracle generator no longer use active
`scalaref(...)` or receiver-dot `.scalaref(...)` examples. Replacement examples use direct scalar payload access
such as `retv["content"]` / `retv[0]` and named working-hash reads through `scalar(hash(name), key)`. Phase0 is
**1015 green**, the Rust corpus oracle is green over **63 fixtures**, and the frontier advances to `.4`
implementation removal.

Index note 2026-07-02: `SCALAREF-RETIREMENT.4` is now done. Perl/Rust no longer recognize or execute
function-form `scalaref(...)` or receiver-dot `.scalaref(...)`; focused negative locks cover both old spellings,
and migrated direct-access positives stay green. Frontier advances to `.5` final no-drift sweep.

Index note 2026-07-02: `SCALAREF-RETIREMENT.5` is now done. The final drift sweep migrated root
language-neutral corpus fixtures, reconciled current-facing roadmap/architecture/task/KM wording, confirmed active
surface scans show only intentional negative locks, and closed the tree. PNT returns to `RUST-PARITY.7.2`.

Index note 2026-07-02: `RUST-PARITY.7.2` is now done. Rust header-rest multiline lifecycle parsing and
captures-only `entry_group`/`match_group` parity are fixed, `hlink_substitution` raw-string cases are active, and
the Rust oracle corpus passes over **65 fixtures**. Broader simple-spec candidate divergences are recorded in the
task tree. Frontier advances to `.7.3`.

Index note 2026-07-03: `RUST-PARITY.7.3.1` is now done. The broad batch-2 shipped-spec oracle leaf is split into
a trace-first timeout/hang investigation (`.7.3.2`), `hlink_substitution` delimiter/link-path fixtures (`.7.3.3`),
simple-spec structural divergence triage (`.7.3.4`), action-parser/null-output candidate triage (`.7.3.5`), and
post-timeout RTL/plugin/legacy safety smoke (`.7.3.6`). Frontier advances to `.7.3.2`.

Index note 2026-07-03: `RUST-PARITY.7.3.2` is now done. The historic `RTLUtils` timeout is retired from the
current core tree, and `tools/gen_oracle_corpus.pl` now enforces `ORACLE_TIMEOUT` with a process-level child
parse plus parent `SIGKILL` instead of `alarm()`. Frontier advances to `.7.3.3`.

Index note 2026-07-03: `RUST-PARITY.7.3.3.1` is now done. Hlink delimiter candidates are split: `{abc}` is
JSON-safe and moves to `.7.3.3.2`, while `[abc]` and mixed bracket/brace inputs require scalar-ref oracle
representation ownership in `.7.3.3.3`. Frontier advances to `.7.3.3.2`.

Index note 2026-07-03: `RUST-PARITY.7.3.3.2` is now done. The JSON-safe `hlink_curly_brace` fixture for `{abc}`
is active in the oracle corpus, raising the Rust corpus to **66 fixtures**. Frontier advances to `.7.3.3.3` for
the scalar-ref representation decision.

Index note 2026-07-03: `RUST-PARITY.7.3.3.3` is now done. Bracket/mixed `hlink_substitution` fixtures are deferred
to `.7.3.3.4` because Perl emits scalar refs that the JSON oracle cannot encode and Rust currently cannot execute
the shipped scalar-ref action branch. Frontier advances to `.7.3.4`.

Index note 2026-07-03: `RUST-PARITY.7.3.7` is now done. The user-directed timeout re-debug found the live gap in
the oracle guard boundary: `BNF` exceeded a 5s build+parse wrapper because parser construction took about 6.4s,
while parse execution was fast after build and trace reached successful parser generation. `tools/gen_oracle_corpus.pl`
now builds and parses inside the forked `ORACLE_TIMEOUT` child, so parser-build hangs are hard-killed too. Frontier
returns to `.7.3.4`.

Index note 2026-07-03: `RUST-PARITY.7.3.4` is now done as triage. `portmap`, `lib_reader`, and `ebnf` structural
oracle mismatches were reproduced against Perl and the Rust `corpus_oracle` execution path. No fixture was safe to
land; implementation is split into `.7.3.4.1` (parser/compiler header-rest action edge on regex-less top rules),
`.7.3.4.2` (runtime boolean/list-context parity for `portmap`), and `.7.3.4.3` (runtime action-edge fluent
child/target aggregation for `ebnf` payloads and `portmap` concatenation). Frontier advances to `.7.3.4.1`.

Index note 2026-07-03: `RUST-PARITY.7.3.4.1` is now done. Rust preserves unrecognized header-rest tokens instead
of swallowing compact body syntax as an invalid mode suffix, and action/blind edge parsing now follows
`specs/spec.spec` optional spacing after `->`/`=>`. `lib_reader` top dispatch now compiles, but representative
outputs still have null capture fields; runtime capture propagation is split to `.7.3.4.4`.

Index note 2026-07-03: `RUST-PARITY.7.3.4.4` is now done. A focused edge-only child-regex regression showed
dependency-resolved child entry captures already work; the remaining `lib_reader` divergence was statement-form
helper mutation. Rust now mutates scalar targets for `substr`/`regex_subst` regex substitution and array targets
for `split(array(target), scalar(source), delimiter)`. The `lib_reader_sattribute` and `lib_reader_cattribute`
oracle fixtures are active, raising the Rust corpus to **68 fixtures**. Frontier advances to `.7.3.4.2`.

## Proposed Task Trees

Proposed trees record accepted backlog direction, but they are not
PNT-eligible until explicitly activated or until the roadmap selects that lane.

| Tree | Status | Roadmap lane | Proposed first leaf | File |
| --- | --- | --- | --- | --- |
| _(none — `SPEC-FORMAT-TERSE` was activated 2026-06-18; see Active Task Trees)_ | — | — | — | — |

## Completed Task Trees

| Tree | Status | Roadmap lane | Completed frontier | File |
| --- | --- | --- | --- | --- |
| `DOCTRINE-ENFORCEMENT-ADOPT` | `done` | `Overall roadmap — durable architecture / doctrine enforcement` | All leaves done 2026-06-22 through 2026-07-08: `.1` wrote `TOOLBOX.md`, `.2` adopted the doctrine driver/hook/local-gate architecture, `.3.1` split the deferred evidence gate before code, `.3.2` implemented and registered `TASK-ACCEPTANCE`, and `.3.3` closed docs/KM/no-drift with the false-positive path and known limits documented. | [docs/tasks/DOCTRINE-ENFORCEMENT-ADOPT.md](docs/tasks/DOCTRINE-ENFORCEMENT-ADOPT.md) |
| `STAGED-LINKED-PARSING` | `done` | `Overall roadmap — .spec language model / parser composition` | Six leaves done 2026-07-02 through 2026-07-08: staged linked parsing doctrine, import/composition design, parse-job metadata design, registry/dispatch design, function-body staged prototype implementation/proof, and final closeout removing the stale PNT pointer to already-closed `TOP-RULE-AS-NORMAL.3.2`. | [docs/tasks/STAGED-LINKED-PARSING.md](docs/tasks/STAGED-LINKED-PARSING.md) |
| `MEMORY-PUSH-POINTER-SYNC` | `done` | `Overall roadmap — durable architecture / memory continuity` | Leaf `.1` done 2026-07-08: `MEMORY.md` no longer hardcodes the stale "over 300 commits" branch-threshold state and instead tells future sessions to check `git status -sb` before applying the push policy. | [docs/tasks/MEMORY-PUSH-POINTER-SYNC.md](docs/tasks/MEMORY-PUSH-POINTER-SYNC.md) |
| `ROADMAP-POST-12-DRIFT-SYNC` | `done` | `Overall roadmap — documentation and book sync` | Leaf `.1` done 2026-07-08: startup-discovered `ROADMAP.md` current-state drift was synchronized from `1..1026` / 95 fixtures to the current phase0 `1..1027` / 96-fixture Rust interpreter oracle baseline after mdBook review confirmed the book was already current. | [docs/tasks/ROADMAP-POST-12-DRIFT-SYNC.md](docs/tasks/ROADMAP-POST-12-DRIFT-SYNC.md) |
| `RUST-STATUS-DRIFT-SYNC` | `done` | `Overall roadmap — documentation and book sync` | Leaf `.1` done 2026-07-08: current-facing `ROADMAP.md`, `rust/README.md`, and mdBook shipped-corpora status now align with the 97-fixture Rust oracle, 21 shipped specs, and phase0 `1..1028`; historical earlier-count records remain unchanged. | [docs/tasks/RUST-STATUS-DRIFT-SYNC.md](docs/tasks/RUST-STATUS-DRIFT-SYNC.md) |
| `ROADMAP-DRIFT-RECONCILE` | `done` | `Overall roadmap — documentation and book sync` | Three leaves done 2026-07-08: `.0` owned deferred `ROADMAP.md` / `ARCHITECTURE_STATE.md` drift, `.1` reconciled long-form `ROADMAP.md`, and `.2` refreshed `ARCHITECTURE_STATE.md` plus narrow mdBook status/count drift to the then-current 21-spec / phase0 `1..1026` / 95-fixture Rust oracle / noncore-plugin state. | [docs/tasks/ROADMAP-DRIFT-RECONCILE.md](docs/tasks/ROADMAP-DRIFT-RECONCILE.md) |
| `RUST-README-DRIFT-SYNC` | `done` | `Overall roadmap — documentation and book sync` | Two leaves done 2026-07-08: `.0` owned the isolated startup-discovered Rust README count drift, and `.1` synchronized `rust/README.md` to the current 95-fixture interpreter oracle boundary. | [docs/tasks/RUST-README-DRIFT-SYNC.md](docs/tasks/RUST-README-DRIFT-SYNC.md) |
| `TASK-TREE-METADATA-HYGIENE` | `done` | `Overall roadmap — durable architecture / task-tree hygiene` | Five leaves done 2026-07-08: `.0` owned the open-task-tree audit, `.1` reconciled stale top metadata, `.2` reconciled stale completed-tree frontier/verification/commit rows and classified deferred/non-goal cases, `.3` added the `TASK-TREE-METADATA` doctrine gate for completed-tree `Current Frontier` rows, and `.4` reconciled the just-closed root-spec closeout commit metadata. | [docs/tasks/TASK-TREE-METADATA-HYGIENE.md](docs/tasks/TASK-TREE-METADATA-HYGIENE.md) |
| `PPLUGIN-WALKTHROUGH-DRIFT` | `done` | `Overall roadmap — documentation and book sync` | Two leaves done 2026-07-07: `.0` created the owner tree before edits; `.1` aligned the pplugin walkthrough with the current descriptor-ready parser status while keeping `.plg` coderef execution scoped to the legacy Perl runtime, and added a durable Knowledge fact for that boundary. | [docs/tasks/PPLUGIN-WALKTHROUGH-DRIFT.md](docs/tasks/PPLUGIN-WALKTHROUGH-DRIFT.md) |
| `BOOTSTRAP-RESUME-SYNC` | `done` | `Overall roadmap — durable architecture / memory continuity` | Leaf `.1` done 2026-07-07: stale `MEMORY.md` closeout wording was corrected after bootstrap confirmed `PUBLIC-STATUS-DRIFT-SYNC.1` was already committed and the repo was clean; live continuity docs now describe a clean handoff with no parser/runtime/book behavior changes. | [docs/tasks/BOOTSTRAP-RESUME-SYNC.md](docs/tasks/BOOTSTRAP-RESUME-SYNC.md) |
| `PUBLIC-STATUS-DRIFT-SYNC` | `done` | `Overall roadmap — documentation and book sync` | Three leaves done 2026-07-07: `.0` created the owner tree before edits; `.1` synchronized mdBook public project status and backend handoff corpus wording to the current 93-fixture Rust interpreter oracle, generated-source subset boundary, and manifest path; `.2` corrected the residual shipped-specs/corpora page count and now points readers at the manifest for the exact case list; related Knowledge cards refreshed by `.1`. | [docs/tasks/PUBLIC-STATUS-DRIFT-SYNC.md](docs/tasks/PUBLIC-STATUS-DRIFT-SYNC.md) |
| `TRACE-OBSERVABILITY` | `done` | `Overall roadmap — engine observability / developer experience` | All leaves `.1`–`.4.5` done 2026-07-04: discoverable Perl CLI trace control landed; Perl reference generated-handler, RuleIR, EmitContext, ActionIR pipeline, compact lowerer, MethodLowering, and compile/ActionIR closeout coverage landed; the neutral mdBook trace contract was locked; Rust controls/sinks, compile/spec-parser/staged-dispatch events, runtime branch/lifecycle/mark-capture events, and cross-variant parity proof landed. Rust can claim parity for the documented external trace capability contract; future variants must satisfy the mdBook checklist before claiming parity. | [docs/tasks/TRACE-OBSERVABILITY.md](docs/tasks/TRACE-OBSERVABILITY.md) |
| `TOP-RULE-AS-NORMAL` | `done` | `Overall roadmap — .spec language model / engine evolution` | All leaves `.1`–`.4` done 2026-07-04: top rule documented and tested as an ordinary rule entered first; Perl and Rust forward-progress recursion guards landed; recursive-top-rule `LX` authoring model documented; Rust recursive top-rule/body value parity locked by declared-variable scoping and 91-fixture oracle corpus coverage. PNT advanced through `TRACE-OBSERVABILITY.1` and `.2`; `.3` has since split, `.3.1` through `.3.5` have closed, and `.4.2` has added Rust trace controls, `.4.3` has added Rust compile/spec-parser events, and `.4.4` has added Rust runtime trace events, and `.4.5` has since closed the parity proof, so no `TRACE-OBSERVABILITY` frontier remains. | [docs/tasks/TOP-RULE-AS-NORMAL.md](docs/tasks/TOP-RULE-AS-NORMAL.md) |
| `RUST-PARITY` | `done` | `Phase 9 — Rust variant (parity follow-on)` | All leaves `.1`–`.9` done 2026-07-04: deferred runtime/helper gaps closed, recursive shipped-spec parity and 88-fixture oracle finalized, generated-source direct execution covers all current structural families with all-family plus manifest-backed subset proof, and roadmap/live-doc/book/architecture alignment finalized. PNT advanced through `TOP-RULE-AS-NORMAL.3.2` and `TRACE-OBSERVABILITY.1`/`.2`; `.3` has since split, `.3.1` through `.3.5` have closed, and `.4.2` has added Rust trace controls, `.4.3` has added Rust compile/spec-parser events, and `.4.4` has added Rust runtime trace events, and `.4.5` has since closed the parity proof, so no `TRACE-OBSERVABILITY` frontier remains. | [docs/tasks/RUST-PARITY.md](docs/tasks/RUST-PARITY.md) |
| `SCALAREF-RETIREMENT` | `done` | `Overall roadmap — .spec language evolution / compatibility retirement` | All 5 leaves done 2026-07-02: directive owned, inventory/replacement contract locked, live specs/tests/corpus/docs migrated, Perl/Rust implementation support removed, final no-drift sweep closed. | [docs/tasks/SCALAREF-RETIREMENT.md](docs/tasks/SCALAREF-RETIREMENT.md) |
| `PERL-ACTIONIR-AST-MIGRATION` | `done` | `Overall roadmap — compiler architecture / variant contract` | All leaves `.0`–`.5.4` done 2026-07-01: text-to-AST doctrine adopted, Perl ActionIR AST parser seam landed, value/statement/control lowering moved to typed AST nodes, supported fallback leakage retired, return/value unknown calls diagnose, short wrappers retired, and `fn` grammar ownership locked to `specs/spec.spec`. PNT returned to `SPEC-FORMAT-TERSE.4.1`; `.4.1`, `.4.2.1`, `.4.2.2`, `.4.2.3`, `.4.3.1`, `.4.3.2`, `.4.4`, `.3.2.2`, `.3.2.3`, `.3.2.3.1`, `.3.2.3.2`, `.3.2.3.3`, `.3.2.3.4`, `.3.3`, `.3.3.1`, `.3.3.2`, `.3.3.3`, and `.3.3.4` are now complete/owned; later `.6` shipped-spec migration, `.7` type-method surface, `.15` colon scalar-slot retirement, and `.14` trailing blocks all closed; the current active terse frontier is `SPEC-FORMAT-TERSE.12.3`. | [docs/tasks/PERL-ACTIONIR-AST-MIGRATION.md](docs/tasks/PERL-ACTIONIR-AST-MIGRATION.md) |
| `PHASE0-BACKHALF-TRIAGE` | `done` | `Overall roadmap — regression-gate health (back-half core failures)` | `.1` triage (108 STALE / 65 REAL) + `.2` re-bless 108 STALE + `.3`/`.4` two authorized engine defect fixes (ADR `0008`) + `.5` green-phase0 (corpus hang fix + dark-tail re-bless + full-gate-green + status/doc/book drift sync, closing `LEGACY-VHDL-RETIRE` + `NONCORE-QUARANTINE`) → **`t/phase0_regression.t` 960/960 GREEN** + `tools/run_ci_local.sh` EXIT 0. `.6` (book `:AND`) `superseded` by `TOP-RULE-AS-NORMAL` (escalated to an engine change, ADR `0010`). | [docs/tasks/PHASE0-BACKHALF-TRIAGE.md](docs/tasks/PHASE0-BACKHALF-TRIAGE.md) |
| `LEGACY-VHDL-RETIRE` | `done` | `Overall roadmap — keep only portable/cross-variant code (retirement)` | All 5 leaves (`.1` inventory; `.2`+`.3` retire 3 Perl-only modules + 6 `.plg` + phase0 smoke ≈6,701 lines; `.4` RTLUtils hang cleared + full local gate green; `.5` doc/book/KM drift sync via `PHASE0-BACKHALF-TRIAGE.5.3.2.2`) | [docs/tasks/LEGACY-VHDL-RETIRE.md](docs/tasks/LEGACY-VHDL-RETIRE.md) |
| `NONCORE-QUARANTINE` | `done` | `Overall roadmap — keep only portable/cross-variant code (non-core quarantine)` | Primary acceptance met: `.1`–`.4` relocated 36 non-core `.pm` + 13 `.plg` to `noncore/` (`perl/` core-only); `.V` verify (phase0 960/960 + full gate EXIT 0) + doc/book/KM sync (via `PHASE0-BACKHALF-TRIAGE.5.3.2.2`); `.N` (plugin-machinery fate) `deferred` as an explicit Non-Goal | [docs/tasks/NONCORE-QUARANTINE.md](docs/tasks/NONCORE-QUARANTINE.md) |
| `DOC-DRIFT-SYNC` | `completed` | `Overall roadmap — documentation and book sync` | Both leaves (`.1` ROADMAP.md Phase 8/9 + Overall `done` sync; `.2` formal-grammar.md `:&`/`:|` rule-mode cell fix) | [docs/tasks/DOC-DRIFT-SYNC.md](docs/tasks/DOC-DRIFT-SYNC.md) |
| `ALIAS-RETIREMENT-DOC-SYNC` | `completed` | `Overall roadmap — documentation and book sync` | `.1` (book formal-grammar + ROADMAP_V2 + ROADMAP: array-edge aliases `tail`/`drop_last`/`flatten`/`array_values` marked retired) | [docs/tasks/ALIAS-RETIREMENT-DOC-SYNC.md](docs/tasks/ALIAS-RETIREMENT-DOC-SYNC.md) |
| `MDBOOK-FORMAT-CORRECTNESS` | `completed` | `Overall roadmap — documentation and book sync` | All 3 leaves (`.1` runtime-semantics §5.2/§5.3, `.2` full-book sweep + formal-grammar §8.1/§12, `.3` finalize) | [docs/tasks/MDBOOK-FORMAT-CORRECTNESS.md](docs/tasks/MDBOOK-FORMAT-CORRECTNESS.md) |
| `MDBOOK-VARIANT-AGNOSTIC` | `completed` | `Overall roadmap — documentation and book sync` | All 7 leaves (`.1` audit, `.2` overview, `.3` user-model, `.4` public-api, `.5` DSL+compiler/arch, `.6` appendix+corpus+dev, `.7` final consistency sweep) | [docs/tasks/MDBOOK-VARIANT-AGNOSTIC.md](docs/tasks/MDBOOK-VARIANT-AGNOSTIC.md) |
| `SPEC-SPEC-SELFHOST` | `completed` | `Phase 7 follow-on — self-hosted .spec grammar (rewrite)` | All 4 leaves (`.1` inventory, `.2` rewrite spec.spec, `.3` verify + cross-check, `.4` docs sync) | [docs/tasks/SPEC-SPEC-SELFHOST.md](docs/tasks/SPEC-SPEC-SELFHOST.md) |
| `TASK-TREE-INDEX-SYNC` | `completed` | `Overall roadmap — documentation and tracker maintenance` | `TASK-TREE-INDEX-SYNC.1` (reconcile stale frontier index) | [docs/tasks/TASK-TREE-INDEX-SYNC.md](docs/tasks/TASK-TREE-INDEX-SYNC.md) |
| `REPO-HYGIENE` | `completed` | `Overall roadmap — repository maintenance` | All 4 leaves done: `.1` tool-artifact ignore cleanup, `.2` local-only `rgx/` + `.claude/projects/` cleanup, `.3` first urgent generated-artifact cleanup, and `.4` recurring cleanup reclaiming about 20G from Rust/mdBook output, Julia compiled caches, and provenance-checked stale generation logs while preserving depot data, unrelated temp trees, and `rgx` corpus artifacts. | [docs/tasks/REPO-HYGIENE.md](docs/tasks/REPO-HYGIENE.md) |
| `RUST-EDGE-SEMANTICS` | `completed` | `Phase 9 — Rust variant (correctness fix)` | All 4 leaves (`.1` audit, `.2` compiler rewrite, `.3` regression tests, `.4` finalization) | [docs/tasks/RUST-EDGE-SEMANTICS.md](docs/tasks/RUST-EDGE-SEMANTICS.md) |
| `ROADMAP-V2-TRACKER-SYNC` | `completed` | `Overall roadmap — documentation and tracker maintenance` | All 5 leaves (`.1` audit, `.2` tracker update, `.3` live docs, `.4` mdBook audit, `.5` finalization) | [docs/tasks/ROADMAP-V2-TRACKER-SYNC.md](docs/tasks/ROADMAP-V2-TRACKER-SYNC.md) |
| `LIFECYCLE-FAMILY-AUDIT` | `completed` | `Overall roadmap — near-term priority 1: lifecycle-family follow-through` | All 4 leaves (`.1` inventory, `.2` gap analysis, `.3` documentation, `.4` finalization) | [docs/tasks/LIFECYCLE-FAMILY-AUDIT.md](docs/tasks/LIFECYCLE-FAMILY-AUDIT.md) |
| `COMPAT-ALIAS-TEST-CLEANUP` | `completed` | `Overall roadmap — method-like DSL migration track (near-term priority 2)` | All 3 leaves (`.1` scanner contract test blocks, `.2` delegation/override test blocks, `.3` finalization) | [docs/tasks/COMPAT-ALIAS-TEST-CLEANUP.md](docs/tasks/COMPAT-ALIAS-TEST-CLEANUP.md) |
| `COMPAT-ALIAS-RETIREMENT-V2` | `completed` | `Overall roadmap — method-like DSL migration track (near-term priority 2)` | All 3 leaves (`.1` short-term alias audit + doc cleanup, `.2` medium-term return helper retirement, `.3` finalization) | [docs/tasks/COMPAT-ALIAS-RETIREMENT-V2.md](docs/tasks/COMPAT-ALIAS-RETIREMENT-V2.md) |
| `FLUENT-BLOCK-EQUIVALENCE` | `completed` | `Overall roadmap — method-like DSL migration track (near-term priority 2)` | All 2 leaves (`.1` inventory/audit, `.2` book documentation + regression verification) | [docs/tasks/FLUENT-BLOCK-EQUIVALENCE.md](docs/tasks/FLUENT-BLOCK-EQUIVALENCE.md) |
| `MEDIUM-IMPACT` | `completed` | `Overall roadmap — medium-impact follow-on` | All 16 leaves (`.1.1`–`.1.5` SpecEntry decoupling, `.2.1`–`.2.4` Validation fuzzing, `.3.1`–`.3.6` spec.spec handoff) | [docs/tasks/MEDIUM-IMPACT.md](docs/tasks/MEDIUM-IMPACT.md) |
| `PHASE1A-CLOSE-OUT` | `completed` | `Phase 1A` | All 2 leaves (`.1` inventory audit, `.2` ROADMAP status flip) | [docs/tasks/PHASE1A-CLOSE-OUT.md](docs/tasks/PHASE1A-CLOSE-OUT.md) |
| `PHASE3-EXECUTION-SEMANTICS` | `completed` | `Phase 3` | All 4 leaves (`.1` inventory, `.2` BACKTRACK contract, `.3` non-backtracking model, `.4` BACKTRACK+parse_mode verification) | [docs/tasks/PHASE3-EXECUTION-SEMANTICS.md](docs/tasks/PHASE3-EXECUTION-SEMANTICS.md) |
| `PHASE4-CAPTURE-MARK-API` | `completed` | `Phase 4` | All 4 leaves (`.1` inventory, `.2` compat alias verification, `.3` mark-helper verification, `.4` finalize) | [docs/tasks/PHASE4-CAPTURE-MARK-API.md](docs/tasks/PHASE4-CAPTURE-MARK-API.md) |
| `PHASE5-RUNTIME-DIAGNOSTICS` | `completed` | `Phase 5` | All 2 leaves (`.1` inventory, `.2` stderr leak fix) | [docs/tasks/PHASE5-RUNTIME-DIAGNOSTICS.md](docs/tasks/PHASE5-RUNTIME-DIAGNOSTICS.md) |
| `PHASE2-DSL-FRONTEND` | `completed` | `Phase 2` | All 6 leaves (`.1` inventory, `.2` construct alignment, `.6` fluent-continuation, `.4` inside-block rejection, `.5` extra-colon, `.3` strict_syntax) | [docs/tasks/PHASE2-DSL-FRONTEND.md](docs/tasks/PHASE2-DSL-FRONTEND.md) |
| `PHASE6-DOCUMENTATION` | `completed` | `Phase 6` | All 8 leaves (`.1` inventory, `.2` LinkedRE, `.3` Validation, `.4` public API, `.5` cross-linking, `.6` overviews, `.7` ActionIR lowering, `.8` per-spec walkthroughs) | [docs/tasks/PHASE6-DOCUMENTATION.md](docs/tasks/PHASE6-DOCUMENTATION.md) |
| `BACKBONE-ACTION-IR-LOWERING` | `completed` | `Backbone Item 3` | All 1 leaf (`.1` owner-contract audit — all 12 owners clean) | [docs/tasks/BACKBONE-ACTION-IR-LOWERING.md](docs/tasks/BACKBONE-ACTION-IR-LOWERING.md) |
| `PLUGIN-MODERNIZATION` | `completed` | `Plugin modernization` | All 5 leaves (`.1` inventory, `.2` dead .plg removal, `.3` FSMGen de-scope, `.4` facade deprecation, `.5` retirement evaluation) | [docs/tasks/PLUGIN-MODERNIZATION.md](docs/tasks/PLUGIN-MODERNIZATION.md) |
| `PHASE7-SELF-HOSTED-SPEC` | `completed` | `Phase 7` | All 5 leaves (`.1` language-surface inventory, `.2` structural rules, `.3` DSL rules, `.4` regression coverage, `.5` extension-surface policy) | [docs/tasks/PHASE7-SELF-HOSTED-SPEC.md](docs/tasks/PHASE7-SELF-HOSTED-SPEC.md) |
| `PHASE1-PARSER-CORE-ISOLATION` | `completed` | `Phase 1` | All 3 leaves (`.1` compatibility-seam inventory, `.2` ActionRewriter.pm removal, `.3` rewrite_action_code_for_compat evaluation) | [docs/tasks/PHASE1-PARSER-CORE-ISOLATION.md](docs/tasks/PHASE1-PARSER-CORE-ISOLATION.md) |
| `METHOD-LIKE-DSL-MIGRATION` | `completed` | `Method-like DSL migration track` | All 5 leaves (`.1` alias-retirement policy audit, `.2` legacy return-helper cleanup, `.3` accumulator audit, `.4` missing-feature inventory, `.5` cross-nesting parity deferral) | [docs/tasks/METHOD-LIKE-DSL-MIGRATION.md](docs/tasks/METHOD-LIKE-DSL-MIGRATION.md) |
| `COMPAT-ALIAS-RETIREMENT` | `completed` | `Method-like DSL migration track` | All 4 leaves (`.1` short-term removed, `.2` medium-term deferred, `.3` test migration deferred, `.4` docs updated) | [docs/tasks/COMPAT-ALIAS-RETIREMENT.md](docs/tasks/COMPAT-ALIAS-RETIREMENT.md) |
| `DOC-BOOK-SYNC` | `completed` | `Overall roadmap — documentation and book sync` | All 4 leaves (`.0` bootstrap, `.1` audit, `.2` remediation, `.3` finalization) | [docs/tasks/DOC-BOOK-SYNC.md](docs/tasks/DOC-BOOK-SYNC.md) |
| `PLUGIN-ACTION-MIGRATION-STALE-REFERENCES` | `completed` | `Overall roadmap — documentation and tracker maintenance` | `.1` fix stale PLUGIN-ACTION-MIGRATION "proposed" → "retired" | [docs/tasks/PLUGIN-ACTION-MIGRATION-STALE-REFERENCES.md](docs/tasks/PLUGIN-ACTION-MIGRATION-STALE-REFERENCES.md) |
| `PHASE8-MULTI-BACKEND-HANDOFF` | `completed` | `Phase 8 — Multi-backend specification and handoff` | All 8 leaves (`.1` ADR, `.2` grammar, `.3` HandlerIR, `.4` helpers, `.5` semantics, `.6` corpus, `.7` handoff, `.8` finalization) | [docs/tasks/PHASE8-MULTI-BACKEND-HANDOFF.md](docs/tasks/PHASE8-MULTI-BACKEND-HANDOFF.md) |
| `PHASE9-RUST-VARIANT` | `completed` | `Phase 9 — Rust variant implementation` | All 17 leaves (`.1` bootstrap, `.2` parser, `.3` compiler, `.4` runtime, `.5` helpers, `.6` integration, `.7` corpus, `.8` code-gen, `.9` docs, `.10` finalization) | [docs/tasks/PHASE9-RUST-VARIANT.md](docs/tasks/PHASE9-RUST-VARIANT.md) |
| `BOOK-DOCUMENTATION-SYNC` | `completed` | `Documentation` | All 3 leaves (`.1` plugin-registry.md status, `.2` owner-tree.md deprecation, `.3` pplugin walkthrough + book/USER_GUIDE sweep) | [docs/tasks/BOOK-DOCUMENTATION-SYNC.md](docs/tasks/BOOK-DOCUMENTATION-SYNC.md) |
| `DOC-CODEBASE-ALIGNMENT` | `completed` | `Doc/codebase alignment (no-drift doctrine)` | All 5 leaves (`.1` task-tree index reconcile, `.2` ARCHITECTURE_STATE.md refresh, `.3` USER_GUIDE.md scrub, `.4` ROADMAP_V2.md Phase 1A, `.5` ROADMAP.md tracker sync) | [docs/tasks/DOC-CODEBASE-ALIGNMENT.md](docs/tasks/DOC-CODEBASE-ALIGNMENT.md) |
| `MEMORY-ARCHITECTURE-DOC` | `completed` | `Durable memory architecture (cross-project standard)` | All 5 leaves (`.1` standard + pointers, `.2` docs/decisions layer C, `.3` demote MEMORY.md + reconcile COMMIT.md, `.4` enforcement kit E1–E4, `.5` verify + close) | [docs/tasks/MEMORY-ARCHITECTURE-DOC.md](docs/tasks/MEMORY-ARCHITECTURE-DOC.md) |
| `KNOWLEDGE-MAP-DOC` | `completed` | `Durable memory architecture (cross-project standard)` | All 4 leaves (`.1` vendor bundle + map, `.2` seed 6 fact cards, `.3` wire KM gate + pointers + ADR 0005, `.4` verify + close) | [docs/tasks/KNOWLEDGE-MAP-DOC.md](docs/tasks/KNOWLEDGE-MAP-DOC.md) |
| `ACCUMULATOR-CONVENTION-AUDIT` | `completed` | `Method-like DSL migration follow-on` | All 3 leaves (`.1` ActionIR contract inventory, `.2` per-spec usage categorization, `.3` synthesis + recommendations) | [docs/tasks/ACCUMULATOR-CONVENTION-AUDIT.md](docs/tasks/ACCUMULATOR-CONVENTION-AUDIT.md) |
| `PLUGIN-ACTION-MIGRATION` | `retired` | `Plugin modernization follow-on` | All 5 leaves done; tree retired — 17 dead files deleted, 19 kept as legacy corpus | [docs/tasks/PLUGIN-ACTION-MIGRATION.md](docs/tasks/PLUGIN-ACTION-MIGRATION.md) |
| `LINKEDSPEC-ENHANCEMENTS` | `done` | `Overall roadmap` | All 3 leaves done — Knowledge Map grown, plugin lock live, test infrastructure split | [docs/tasks/LINKEDSPEC-ENHANCEMENTS.md](docs/tasks/LINKEDSPEC-ENHANCEMENTS.md) |
| `LINKEDSPEC-LOW-EFFORT` | `done` | `Overall roadmap` | All 3 leaves done — test sweep clean, post-commit hook active, accumulator docs backfilled | [docs/tasks/LINKEDSPEC-LOW-EFFORT.md](docs/tasks/LINKEDSPEC-LOW-EFFORT.md) |
| `RUST-FUNCTIONAL-PARITY` | `done` | `Phase 9 — Rust variant (functional parity)` | All 15 leaves done — 126 tests, 80+ helpers, full pipeline operational | [docs/tasks/RUST-FUNCTIONAL-PARITY.md](docs/tasks/RUST-FUNCTIONAL-PARITY.md) |
| `RGX-BUILD-REPRO` | `done` | `Phase 9 — Rust variant (rgx evaluation unblock)` | `.1` upstream fix verified: cold-clone `make` succeeds, rgx pin bumped b771c7b→8763a0e | [docs/tasks/RGX-BUILD-REPRO.md](docs/tasks/RGX-BUILD-REPRO.md) |
| `RGX-ADOPTION` | `done` | `Phase 9 — Rust variant (rgx adoption)` | All 3 leaves done — regex→rgx-core, 126/126 tests PASS | [docs/tasks/RGX-ADOPTION.md](docs/tasks/RGX-ADOPTION.md) |
| `RUST-DIAGNOSTICS` | `done` | `Phase 9 — Rust variant (engine quality)` | All 3 leaves done — runtime warnings for silent failures | [docs/tasks/RUST-DIAGNOSTICS.md](docs/tasks/RUST-DIAGNOSTICS.md) |
| `RGX-BRANCH-TRACKING` | `done` | `Phase 9 — Rust variant (regex engine optimization)` | All 3 leaves done — combined regex + matched_branch_number | [docs/tasks/RGX-BRANCH-TRACKING.md](docs/tasks/RGX-BRANCH-TRACKING.md) |

## Roadmap Task-Tree Ownership

All roadmap-phase work is task-tree-managed by default.

Before implementing any task, slice, or PNT-selected activity:

- Attach it to an existing active task tree, or create a new
  `docs/tasks/*.md` tree from [docs/tasks/TEMPLATE.md](docs/tasks/TEMPLATE.md).
- Slice the work into executable leaf nodes before changing parser, compiler,
  diagnostics, docs, or spec content.
- Put only executable leaf nodes in the tree's current frontier.
- Implement one frontier leaf at a time.
- Update the owning task file when the leaf status, blocker, decision,
  validation evidence, or completion evidence changes.
- Run the full [COMMIT.md](../COMMIT.md) workflow after each completed leaf before
  selecting another leaf.

Small documentation-only or diagnostics-only changes still need a tree
entry. If the change is genuinely small, the tree can contain one leaf, but the
task must still be visible in the task-tree ledger before implementation.

## Directory Layout

```text
docs/TASK_TREE.md
docs/TASK_TREE_README.md
docs/tasks/
  TEMPLATE.md
  <TREE>.md
```

`docs/TASK_TREE.md` is the workflow and active-tree index.
Each top-level task owns one file in `docs/tasks/`.
`docs/tasks/TEMPLATE.md` is copied when creating a new top-level tree.

## Definitions

- Task tree: the recursive decomposition of one top-level task.
- Node: one item in that tree.
- Container node: a node with children. It is not directly executable.
- Leaf node: a node with no children. It is the only unit PNT may implement.
- Current frontier: the ordered set of leaf nodes that are eligible to be
  picked next.
- Slice: one completed leaf task plus its tests, docs, live-doc updates, and
  commit workflow.
- Evidence: the validation output, changed-doc summary, and git commit subject
  that prove a leaf was completed.

## ID Rules

Each task tree has a stable top-level ID.

```text
<TREE>
<TREE>.1
<TREE>.1.1
<TREE>.1.1.1
```

Rules:

- `<TREE>` uses uppercase letters, digits, and hyphens.
- Child IDs append dot-separated positive integers.
- IDs are permanent once published.
- Never renumber closed nodes.
- If a new ordering is needed, add new IDs and mark old nodes `superseded` or
  `deferred` with a reason.
- A commit that completes a task-tree leaf must identify the leaf ID in the
  commit subject or in the first body line.

## Status Vocabulary

Use only these statuses.

| Status | Meaning |
| --- | --- |
| `proposed` | Captured but not yet accepted into the active tree. |
| `active` | The top-level tree is open, or a container has unfinished children. |
| `pending` | Ready to be selected once it reaches the current frontier. |
| `in_progress` | Currently being implemented in the worktree. |
| `blocked` | Cannot proceed without a named blocker and unblock condition. |
| `done` | Completed, validated, documented, and committed. |
| `deferred` | Deliberately postponed with an explicit consequence. |
| `superseded` | Replaced by another node, with the replacement ID named. |

## Required Task File Sections

Every top-level task file must contain:

- Metadata: tree ID, status, roadmap lane, created date, last updated date.
- Goal: the user-visible or project-visible outcome.
- Non-goals: what this tree deliberately does not try to solve.
- Acceptance criteria: concrete conditions that close the top-level task.
- Task tree: all known nodes, with status and short result intent.
- Current frontier: ordered leaf nodes that PNT may select next.
- Decisions: accepted technical decisions and their rationale.
- Open questions: unresolved questions that do not block the whole tree yet.
- Blockers: blockers with unblock conditions.
- Verification log: checks run for completed leaves.
- Commit log: leaf IDs mapped to completion commit subjects.
- Changelog: dated edits to the tree itself.

## Node Rules

Every node must be one of these two shapes.

Container node:

```text
- ID: <TREE>.<n>
  Status: active
  Goal: ...
  Children: <TREE>.<n>.1, <TREE>.<n>.2
```

Leaf node:

```text
- ID: <TREE>.<n>
  Status: pending
  Goal: ...
  Acceptance: ...
  Verification: pending
  Commit: pending
```

A node with children must not be marked `done` until every child is `done`,
`deferred`, or `superseded`, and every non-`done` child has a recorded reason.

## Current Frontier Rules

The current frontier is the only list PNT uses when selecting work from a task
tree.

Rules:

- The frontier contains only leaf nodes.
- The frontier is ordered by intended priority.
- A container never appears in the frontier.
- A blocked node stays out of the frontier until unblocked.
- When a leaf is split, remove that leaf from the frontier, mark it `active`,
  add children, and place the first executable child or children in the
  frontier.
- When a leaf completes, remove it from the frontier and add the next eligible
  leaf or leaves.

## PNT Selection Rules

When PNT is asked to continue and at least one active task tree exists:

1. Read `docs/TASK_TREE.md`.
2. Read the active task file named in the `Active Task Trees` table.
3. Pick the first eligible leaf in that file's `Current Frontier`.
4. Implement only that leaf.
5. If the leaf is too broad, split it before implementation and commit the
   tree update as the leaf's honest outcome.
6. Run the required validation for the leaf.
7. Update the task file, live docs, and roadmap if status changed.
8. Run the full commit workflow before selecting another leaf.

If several active trees exist, choose the first active tree in the table unless
the user names another tree or the roadmap status names a different immediate
lane.

## Splitting Rules

Split a node when any of these are true:

- It cannot be completed to signoff quality in one slice.
- It mixes design, implementation, diagnostics, tests, and docs in ways that
  can be reviewed independently.
- It hides an unresolved policy choice behind implementation wording.
- It would require touching unrelated ownership areas in one commit.
- It discovers a lower-level dependency that should be solved first.

Do not split merely to create vague placeholders. Every child must have a
clear goal and a way to verify completion.

## Completion Rules

A leaf is complete only when all of the following are true:

- Implementation or documentation work for that leaf is finished.
- Focused checks passed, and broader checks ran when warranted.
- The owning task file records the result, validation, and commit subject.
- `MEMORY.md`, `CHANGES.md`, `DEVELOPMENT_NOTES.md`,
  `LIVE_ACHIEVEMENT_STATUS.md`, and `ROADMAP_V2.md` are updated when the
  leaf changes project state.
- The commit workflow in `COMMIT.md` has completed.
- `git_message_brief.txt` has been cleared after commit.

Commit hashes are intentionally not required inside the same task-file update:
the final hash cannot be known until after the commit exists. The stable
join key is the leaf ID in the commit subject or first body line. Later status
refreshes may backfill hashes if useful.

## Blocker Rules

A blocked node must record:

- the exact blocker,
- why it blocks the node,
- the unblock condition,
- and the next task that should run instead, if any.

Do not leave a node as `blocked` only because it is large or unclear. Large or
unclear work should be split until a real blocker is visible.

## Relationship To Live Docs

The task tree is the detailed execution ledger.

- `ROADMAP_V2.md` remains the canonical high-level workstream status.
- `MEMORY.md` remains the recovery/handoff continuity log.
- `CHANGES.md` remains the chronological technical history.
- `DEVELOPMENT_NOTES.md` remains design rationale.
- `LIVE_ACHIEVEMENT_STATUS.md` remains the latest completed slice summary.

Do not duplicate the whole task tree into those files. Link to the task tree
and summarize only the part that changes live project state.

## Copying This Workflow To Another Project

The detailed project-adoption checklist lives in
[docs/TASK_TREE_README.md](docs/TASK_TREE_README.md).

To reuse this approach elsewhere:

1. Copy `docs/TASK_TREE_README.md`.
2. Copy `docs/TASK_TREE.md`.
3. Copy `docs/tasks/TEMPLATE.md`.
4. Add `docs/tasks/` to the project documentation index.
5. Add a commit-workflow rule requiring completed task-tree leaf commits to
   identify the leaf ID.
6. Add the task-tree file to the session bootstrap or fast ramp-up order.
7. Create one top-level task file per broad task.
8. Keep the roadmap high-level and the task files detailed.

The only project-specific parts are roadmap lane names, live-doc filenames,
validation commands, and commit-message conventions.
