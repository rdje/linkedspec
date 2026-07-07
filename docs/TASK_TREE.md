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
| `SPEC-FORMAT-TERSE` | `active` (frontier `.14.2` after user reactivated trailing block arguments) | `Overall roadmap — .spec language evolution (terse format)` | `.0` done 2026-06-18 (ratified — ADR `0007`). Implementation gate CLEARED 2026-06-22 (`t/phase0_regression.t` green + `tools/run_ci_local.sh` EXIT 0; gradual-alias migration). **`.1.1` DONE 2026-06-24** (auto-existing wrapper-referenced working vars on Perl + Rust). **`.1.2` SPLIT** by inference channel; **`.1.2.1`+`.1.2.2` DONE 2026-06-24 — Channel 1 complete on BOTH variants** (Channel 2 deferred behind `.1.5`). **`.1.4` DONE 2026-06-29** (helper renames closed on both variants; Perl reference + Rust parity, phase0 **975 green**). **`.1.3` DONE 2026-06-29** — mutation surface closed by mechanism: scalar `set(name,val)` already satisfied by `.1.4`; `push(target,value)` explicit append with child-call precedence; `set_key(name,key,value)` statement mutation while value form stays pure; operator family closed with scalar `name = value`, array `items += value`, and hash `name[key] = value` for explicit key/value expressions. **`.1.5` SPLIT 2026-06-29** — audit showed literal parity, call spacing, separator semantics, and direct nested access are separate leaves. **`.1.5.2` DONE 2026-06-29** — primitive literals are typed values on Perl/Rust, with JSON booleans and Rust statement-form `if(false)` gating. **`.1.5.3` DONE 2026-06-29** — call spacing locked: optional whitespace before `(` works at supported helper/value sites, while no-parenthesis helpers remain out of scope. **`.1.5.4` DONE 2026-06-29** — statement separators locked: newline-or-semicolon, same-line multiple statements require `;`, nested semicolons protected. **`.1.5.5` SPLIT 2026-06-29** — direct nested access divided into explicit-segment and Channel-2 coordination. **`.1.5.5.1` DONE 2026-06-29** — explicit direct access landed; **`.1.5.5.2` SUPERSEDED/MERGED 2026-06-29**. **`.1.2.3` through `.1.2.3.5.4` DONE 2026-06-29** — Channel 2 aggregate/scalar bare reads, direct path atoms, shape-literal values, and historical RHS target-kind inference landed on Perl/Rust before `.11` superseded the storage behavior; corpus 32 fixtures. **`.1.6` DONE 2026-06-29** — array end-mutation methods landed; phase0 **990 green**, corpus 33 fixtures, Round 1 closed. **`.2.1.1` DONE/SPLIT 2026-06-29**; **`.2.1.2` DONE 2026-06-29** — Perl block values; **`.2.1.3` DONE 2026-06-29** — Rust block values; corpus **34 fixtures**. **`.2.1.4` DONE 2026-06-30** — block-local early return landed on Perl/Rust; corpus **35 fixtures**. **`.2.2.1` DONE/SPLIT 2026-06-30** — control-flow keyword surface split. **`.2.2.2` DONE 2026-06-30** — Perl attached-block if landed. **`.2.2.3` DONE 2026-06-30** — Rust attached-block if parity landed; corpus **36 fixtures**. **`.2.2.4` DONE 2026-06-30** — `when/otherwise` aliases landed; corpus **37 fixtures**. **`.2.2.5` SPLIT/OWNED 2026-06-30**; **`.2.2.5.1` DONE 2026-06-30** — Perl attached switch separator/source lock; **`.2.2.5.2` DONE 2026-06-30** — Rust attached switch parity, corpus **38 fixtures**. **`.2.2.6` DONE 2026-06-30** — attached `while(cond) { ... }` split and closed; **`.2.2.6.1` DONE 2026-06-30** — Perl attached while loop/safety landed; **`.2.2.6.2` DONE 2026-06-30** — Rust attached while parity landed, corpus **39 fixtures**. **`.2.3` SPLIT/OWNED 2026-06-30**; **`.2.3.1` DONE 2026-06-30** — Perl fluent `.when(cond) { ... }.otherwise { ... }` block-chain fallback contract landed, phase0 **993 green**; **`.2.3.2` DONE 2026-06-30** — lifecycle value/drop return-channel lock landed, phase0 **994 green**; **`.2.3.3` SPLIT/OWNED 2026-06-30**; **`.2.3.3.1` DONE 2026-06-30** — Rust action-edge fluent no-arg `.push` / `.return(expr)` parity landed; **`.2.3.3.2` DONE 2026-06-30** — Rust attached fluent `.when(cond) { ... }` block payloads now execute on action-edge/lifecycle surfaces with dotted and no-dot fallback tails; **`.2.3.3.3` SPLIT 2026-06-30** — remaining Rust fluent continuations split into compact lifecycle/body chains, action-edge explicit/flow chains, and `tclite` re-enable/default-mode repetition audit; **`.2.3.3.3.1` DONE 2026-06-30** — Rust compact lifecycle/body receiver chains now execute as lifecycle `CodeBlock` statements; **`.2.3.3.3.2` DONE 2026-06-30** — Rust action-edge explicit/flow fluent chains now execute with explicit-target child-return appends and statement-control gating; **`.2.3.3.3.3` DONE/SPLIT 2026-06-30** — `tclite` retry after fluent parity still returned Rust `[]` for `[]`/`""`, splitting default-mode recursive repetition parity; **`.2.3.3.3.3.1` DONE 2026-06-30** — Rust default-mode repetition parity landed and the two `tclite` fixtures are active (corpus **41 fixtures**); **`.2.3.4` DONE/SPLIT 2026-06-30** — full composability audit added a green deep pure-helper oracle fixture (corpus **42 fixtures**) and split Rust helper-context aggregate bare reads plus Perl inline value-control lowering into children; **`.2.3.4.1` DONE 2026-06-30** — Rust helper-context bare aggregate arguments landed for hash- and array-consuming helper slots, corpus **44 fixtures**; **`.2.3.4.2` DONE 2026-06-30** — Perl inline value-control lowering landed for `if`/`switch` in supported value positions, corpus **46 fixtures**; **`.2.3.5` DONE/SPLIT 2026-07-01** — return-type method chaining specified before code and split into array/hash/string/number implementation leaves plus a block-valued receiver audit; **`.2.3.5.1` DONE 2026-07-01** — array receiver-dot value chains landed on Perl/Rust, phase0 **996 green**, corpus **47 fixtures**; **`.2.3.5.2` DONE 2026-07-01** — hash receiver-dot value chains landed on Perl/Rust, corpus **48 fixtures**, statement-level hash mutations preserved, Rust `merge_hash` override parity fixed; **`.2.3.5.3` DONE 2026-07-01** — string/scalar receiver-dot value chains landed on Perl/Rust, split bridges into array chains, string literal receivers parse on Rust, value-form split/substr payloads are portable, phase0 **998 green**, corpus **49 fixtures**; **`.2.3.5.4` DONE 2026-07-01** — number receiver-dot value chains landed on Perl/Rust; numeric literal receivers parse, comparisons are terminal, value-form numeric comparisons lower on Perl, Rust `num_add`/`num_mul` consume all operands, phase0 **999 green**, corpus **50 fixtures**; **`.2.3.5.6` DONE 2026-07-01** — aggregate wrapper quoted-name boundaries and direct shape constructor preference locked, phase0 **1000 green**, corpus **51 fixtures**; **`.2.3.5.5` DONE 2026-07-01** — block-valued receiver-dot chains landed by yielded runtime type, phase0 **1001 green**, corpus **52 fixtures**; **`.5.0` DONE 2026-07-01** — future variant parity ownership/inventory landed before non-Rust variant code; **`.3.1` DONE 2026-07-01** — edge syntax contract locked with no behavior change (`->` action, `=>` blind-call, grouped action targets require a shared block); **`.3.2` SPLIT/OWNED 2026-07-01** — arithmetic/comparison call surface split before code, with one `callee(args)` grammar, word aliases first, arithmetic symbol callees second, and comparison spelling policy isolated; **`.3.2.1` DONE 2026-07-01** — numeric word aliases landed on Perl/Rust while bare comparison words stayed string helpers until `.3.2.3.3` later flipped them. **`.4` SPLIT/OWNED 2026-07-01** — user-defined pure functions accepted into Round 4; calls are value expressions, receiver-chain capable, and standalone results are silently discarded; permanent `fn` grammar belongs in `specs/spec.spec`, with bootstrap-parser support temporary/removable after text-to-AST handoff. **`.4.1` DONE 2026-07-01** — MVP contract/inventory locked before code; `.4.2` split into Perl grammar/registry, value-call execution, and discard/purity hardening leaves; `.4.3` split into Rust registry and runtime/oracle parity. **`.4.2.1` DONE 2026-07-01** — Perl function-definition grammar/registry descriptor seam landed; **`.4.2.2` DONE 2026-07-01** — registered exact-arity Perl user-function value calls now execute in value positions and compatible receiver chains. **`.4.2.3` DONE 2026-07-01** — Perl standalone discard and hardening landed; registered standalone calls lower as `VALUE_DROP`, recursion/unsupported body diagnostics are locked. **`.4.3.1` DONE 2026-07-02** — Rust function-definition AST/compiler registry parity landed. **`.4.3.2` DONE 2026-07-02** — Rust registered user-function calls now execute as values, feed compatible receiver chains, discard standalone results, and pass the Perl/Rust oracle fixture; corpus **54 fixtures**. **`.4.4` DONE 2026-07-02** — function MVP surface/deferral ledger finalized: explicit-paren braced `fn` stays the accepted surface; alternate spellings, optional zero-arg parentheses, brace-less bodies, side-effect/caller-mutating functions, recursion, closures/lambdas/currying, and namespaces remain deferred. **`.3.2.2` DONE 2026-07-02** — arithmetic symbol callees `+(...)`, `-(...)`, `*(...)`, `/(...)`, and `%(...)` now map to `num_add/sub/mul/div/mod` on Perl/Rust while slash regex literals remain regexes; corpus **55 fixtures**, phase0 **1008 green**. **`.3.2.3` SPLIT/OWNED 2026-07-02** — comparison call-surface migration is split behind explicit `str_*` string helpers, numeric comparison word aliases, and numeric comparison symbol callees. **`.3.2.3.1` DONE 2026-07-02** — explicit `str_eq`/`str_ne`/`str_gt`/`str_ge`/`str_lt`/`str_le` string-bridge contract locked before code. **`.3.2.3.2` DONE 2026-07-02** — explicit `str_*` string-comparison helpers now ship on Perl/Rust. **`.3.2.3.3` DONE 2026-07-02** — bare comparison word calls now map to numeric `num_*` aliases on Perl/Rust while lexical strings use explicit `str_*`; corpus **57 fixtures**, phase0 **1010 green**. **`.3.2.3.4` DONE 2026-07-02** — comparison symbol callees `==`/`!=`/`>`/`>=`/`<`/`<=` now map to numeric `num_*` aliases on Perl/Rust; corpus **58 fixtures**, phase0 **1011 green**. **`.3.3` SPLIT/DONE 2026-07-02** — expression-valued assignment split before code. **`.3.3.1` DONE 2026-07-02** — scalar non-shape assignment expressions and scalar `=(target,value)` equivalence now ship on Perl/Rust; **`.3.3.2` DONE 2026-07-02** — aggregate assignment expression values shipped under the historical target-kind inference contract later superseded by `.11` duck-typed value binding; **`.3.3.3` DONE 2026-07-02** — array append and hash-index mutation expression values now return updated aggregate snapshots on Perl/Rust; corpus **61 fixtures**, phase0 **1014 green**. **`.3.3.4` DONE 2026-07-02** — assignment-expression closure and legacy spelling cleanup landed; public examples prefer `set(...)`/operators while `assign(...)` remains a legacy alias, corpus **62 fixtures**, phase0 **1015 green**; `.6` shipped-spec migration and `.7` type-method surface are closed; `.8.3` hard-retired Perl legacy helper spellings, `.8.4` hard-retired Rust legacy helper spellings, `.8.5` reconciled public docs/KM, and `.8.6` closed final helper-retirement no-drift; `SPEC-FORMAT-TERSE.9` is closed: `.9.1` split the migration, `.9.2` added Perl colon support, `.9.3` added Rust parity, `.9.4` migrated current source/docs/KM/corpus/tests, `.9.5` retired old `{ key => value }`, and `.9.6` closed final no-drift scans. No concrete `SPEC-FORMAT-TERSE` PNT-eligible leaf remained after `.9` until the user explicitly reactivated `.14` on 2026-07-07. **`.14.1` DONE 2026-07-07** — trailing block arguments are split before code with `with(value) { ... }` as the first helper-form MVP, Rust parity and receiver `.with() { ... }` behind it, and no closures/assignable blocks/returnable blocks. Active frontier is now **`SPEC-FORMAT-TERSE.14.2`** for the Perl reference helper-form implementation. `SPEC-FORMAT-TERSE.10` remains deferred/potential for dynamic/computed hash-literal keys, and `SPEC-FORMAT-TERSE.12`/`.13` remain deferred/backlog for hash-tree and array-tree traversal. | [docs/tasks/SPEC-FORMAT-TERSE.md](docs/tasks/SPEC-FORMAT-TERSE.md) |
| `STAGED-LINKED-PARSING` | `active` (prototype complete; frontier empty) | `Overall roadmap — .spec language model / parser composition` | The first function-body staged prototype is complete: `.1` adopted staged linked parsing doctrine, `.2` specified future import/composition, `.3` specified future `parse_job(text_expr, options)` annotations, `.4` specified deterministic registry/dispatch queue semantics, `.5.1` selected user-function body text as the first prototype payload family, `.5.2` audited the function-definition AST shape/harness before code, `.5.3.1` added `specs/user_function_definition.spec` as the executable user-function definition AST parser consumed by the Perl registry, `.5.3.2` retired the Rust raw definition parser bridge, `.5.4` added the neutral `body_parse_job` sidecar, `.5.5` dispatched function-body jobs to `actionir-body.spec` / `action_block` and stitched `body_ast`, and `.5.6` proved descriptor/parsed/compiled AST shape, runtime stability, source-provenance diagnostics, and Perl/Rust parity. Current frontier: _empty_; the trace tree has since closed, so PNT returns to the active task-tree index unless a new staged linked parsing leaf is split or another active tree is reprioritized. | [docs/tasks/STAGED-LINKED-PARSING.md](docs/tasks/STAGED-LINKED-PARSING.md) |
| `DOCTRINE-ENFORCEMENT-ADOPT` | `active` | `Overall roadmap — durable architecture / doctrine enforcement` | User directive 2026-06-22: adopt the portable Doctrine-Enforcement architecture + a LinkedSpec `TOOLBOX.md`. **`.1`+`.2` DONE** (atomic): `TOOLBOX.md` (LinkedSpec's OWN debug tools), `DOCTRINE_ENFORCEMENT.md`, `scripts/check_doctrines.sh` (driver+registry = `MEMORY-ARCH`+`KNOWLEDGE-MAP`, 2/2 PASS), `.githooks/pre-commit`→driver, `tools/run_ci_local.sh`→driver, discovery pointers, ADR `0009`. Frontier → **`.3`** (deferred — evidence/task-acceptance hard-gate). | [docs/tasks/DOCTRINE-ENFORCEMENT-ADOPT.md](docs/tasks/DOCTRINE-ENFORCEMENT-ADOPT.md) |
| `TASK-TREE-METADATA-HYGIENE` | `active` | `Overall roadmap — durable architecture / task-tree hygiene` | Created 2026-07-07 to own the user-requested audit of non-closed task trees and stale per-file task metadata. **`.0` DONE** (tracking-only): central live non-closed trees are `SPEC-FORMAT-TERSE`, `STAGED-LINKED-PARSING`, `DOCTRINE-ENFORCEMENT-ADOPT`, `SPEC-LANG-REFERENCE`, and `ROADMAP-DRIFT-RECONCILE`, with their frontiers empty/deferred/paused at `.0` creation time. The user then reactivated `SPEC-FORMAT-TERSE.14`; hygiene cleanup waits behind that active lane while stale metadata candidates remain owned here. Frontier -> **`.1`** top-level metadata reconciliation, then `.2` stale frontier/verification rows; `.3` gate decision is deferred. | [docs/tasks/TASK-TREE-METADATA-HYGIENE.md](docs/tasks/TASK-TREE-METADATA-HYGIENE.md) |
| `SPEC-LANG-REFERENCE` | `active` (scorch ⏸ PAUSED) | `Overall roadmap — documentation and book sync` | **SCORCH PAUSED 2026-06-18** — `.10.5.2`/`.10.5.3`/`.10.5.4` done (2-rule idiom, verified outputs); remaining fix leaves `.10.5.5`–`.10.5.19` paused because the user **activated `SPEC-FORMAT-TERSE`** (terse `.spec` format), whose migration will re-sweep every book example in lockstep with the engine. Resume the scorch only if directed, or fold the remaining files into the terse book-sweep. | [docs/tasks/SPEC-LANG-REFERENCE.md](docs/tasks/SPEC-LANG-REFERENCE.md) |
| `ROADMAP-DRIFT-RECONCILE` | `active` (leaves **DEFERRED** behind `SPEC-FORMAT-TERSE`) | `Overall roadmap — documentation and book sync` | Created 2026-06-23 to OWN a deferred reconciliation. A full-read drift audit of `ROADMAP.md` (1266 lines) vs `ROADMAP_V2.md` + the tree ledger found the long-form `ROADMAP.md` stale: it never names the active `SPEC-FORMAT-TERSE` tree / terse direction, still presents `declare(...)` as the permanent required form, still lists `RTLUtils` + the 36-`.plg` corpus as live (misses `LEGACY-VHDL-RETIRE` deletion + `NONCORE-QUARANTINE` relocation to `noncore/` + `perl/` core-only + the phase0 count), and frames multi-backend as Rust-only. `ARCHITECTURE_STATE.md` is mildly stale (dated 2026-06-14; model still broadly accurate). Leaves `.1` (ROADMAP.md reconcile) + `.2` (ARCHITECTURE_STATE.md refresh) are tracked `pending` but **deferred behind the active terse track** per the user's 2026-06-23 decision ("Defer — track as a new leaf") — not PNT-eligible until the terse track pauses or the user directs. | [docs/tasks/ROADMAP-DRIFT-RECONCILE.md](docs/tasks/ROADMAP-DRIFT-RECONCILE.md) |

Index note 2026-07-04: `SPEC-FORMAT-TERSE.8` is now pending by explicit user directive. The `.6.4` decision to
retain legacy compatibility helpers is superseded for this unreleased project; the new frontier removes remaining
compatibility-only helper spellings so the terse surface is the only current accepted helper surface.

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

Index note 2026-07-07: `SPEC-FORMAT-TERSE.9.2` Perl reference colon hash-literal support is done. Perl accepts
`{ key : value }` during the migration window, preserves old `{ key => value }` until hard retirement, keeps
generated Perl host `=>` internal, and protects block-vs-hash classification such as `{ JSON::PP }`. Frontier
advances to `SPEC-FORMAT-TERSE.9.3` for Rust parser/runtime parity.

Index note 2026-07-04: `SPEC-FORMAT-TERSE.10` is now tracked as deferred/potential by explicit user directive.
It owns the question of dynamic/computed hash-literal keys only if the spec first defines exact syntax and
semantics; it may instead be closed as dropped if the accepted `.9` hash-literal surface stays fixed-key only.

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

Index note 2026-07-05: `SPEC-FORMAT-TERSE.14` is now tracked as deferred/spec backlog by explicit user directive.
It owns a future trailing block-argument type for helpers and receiver methods: blocks may be passed only as the
final argument, preferred syntax is `fn(args) { ... }`, invocation by the callee must be specified explicitly, and
closures/assignable blocks/returnable blocks remain out of scope.

Index note 2026-07-07: `SPEC-FORMAT-TERSE.14` is reactivated by explicit user directive. `.14.1` split the work
before code and selected `with(value) { ... }` as the helper-form MVP for immediate, non-closure block arguments;
receiver `.with() { ... }`, Rust parity, and docs/KM/oracle closeout are later children. Current frontier is
`SPEC-FORMAT-TERSE.14.2`.

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
| `PPLUGIN-WALKTHROUGH-DRIFT` | `done` | `Overall roadmap — documentation and book sync` | Two leaves done 2026-07-07: `.0` created the owner tree before edits; `.1` aligned the pplugin walkthrough with the current descriptor-ready parser status while keeping `.plg` coderef execution scoped to the legacy Perl runtime, and added a durable Knowledge fact for that boundary. | [docs/tasks/PPLUGIN-WALKTHROUGH-DRIFT.md](docs/tasks/PPLUGIN-WALKTHROUGH-DRIFT.md) |
| `BOOTSTRAP-RESUME-SYNC` | `done` | `Overall roadmap — durable architecture / memory continuity` | Leaf `.1` done 2026-07-07: stale `MEMORY.md` closeout wording was corrected after bootstrap confirmed `PUBLIC-STATUS-DRIFT-SYNC.1` was already committed and the repo was clean; live continuity docs now describe a clean handoff with no parser/runtime/book behavior changes. | [docs/tasks/BOOTSTRAP-RESUME-SYNC.md](docs/tasks/BOOTSTRAP-RESUME-SYNC.md) |
| `PUBLIC-STATUS-DRIFT-SYNC` | `done` | `Overall roadmap — documentation and book sync` | Three leaves done 2026-07-07: `.0` created the owner tree before edits; `.1` synchronized mdBook public project status and backend handoff corpus wording to the current 93-fixture Rust interpreter oracle, generated-source subset boundary, and manifest path; `.2` corrected the residual shipped-specs/corpora page count and now points readers at the manifest for the exact case list; related Knowledge cards refreshed by `.1`. | [docs/tasks/PUBLIC-STATUS-DRIFT-SYNC.md](docs/tasks/PUBLIC-STATUS-DRIFT-SYNC.md) |
| `TRACE-OBSERVABILITY` | `done` | `Overall roadmap — engine observability / developer experience` | All leaves `.1`–`.4.5` done 2026-07-04: discoverable Perl CLI trace control landed; Perl reference generated-handler, RuleIR, EmitContext, ActionIR pipeline, compact lowerer, MethodLowering, and compile/ActionIR closeout coverage landed; the neutral mdBook trace contract was locked; Rust controls/sinks, compile/spec-parser/staged-dispatch events, runtime branch/lifecycle/mark-capture events, and cross-variant parity proof landed. Rust can claim parity for the documented external trace capability contract; future variants must satisfy the mdBook checklist before claiming parity. | [docs/tasks/TRACE-OBSERVABILITY.md](docs/tasks/TRACE-OBSERVABILITY.md) |
| `TOP-RULE-AS-NORMAL` | `done` | `Overall roadmap — .spec language model / engine evolution` | All leaves `.1`–`.4` done 2026-07-04: top rule documented and tested as an ordinary rule entered first; Perl and Rust forward-progress recursion guards landed; recursive-top-rule `LX` authoring model documented; Rust recursive top-rule/body value parity locked by declared-variable scoping and 91-fixture oracle corpus coverage. PNT advanced through `TRACE-OBSERVABILITY.1` and `.2`; `.3` has since split, `.3.1` through `.3.5` have closed, and `.4.2` has added Rust trace controls, `.4.3` has added Rust compile/spec-parser events, and `.4.4` has added Rust runtime trace events, and `.4.5` has since closed the parity proof, so no `TRACE-OBSERVABILITY` frontier remains. | [docs/tasks/TOP-RULE-AS-NORMAL.md](docs/tasks/TOP-RULE-AS-NORMAL.md) |
| `RUST-PARITY` | `done` | `Phase 9 — Rust variant (parity follow-on)` | All leaves `.1`–`.9` done 2026-07-04: deferred runtime/helper gaps closed, recursive shipped-spec parity and 88-fixture oracle finalized, generated-source direct execution covers all current structural families with all-family plus manifest-backed subset proof, and roadmap/live-doc/book/architecture alignment finalized. PNT advanced through `TOP-RULE-AS-NORMAL.3.2` and `TRACE-OBSERVABILITY.1`/`.2`; `.3` has since split, `.3.1` through `.3.5` have closed, and `.4.2` has added Rust trace controls, `.4.3` has added Rust compile/spec-parser events, and `.4.4` has added Rust runtime trace events, and `.4.5` has since closed the parity proof, so no `TRACE-OBSERVABILITY` frontier remains. | [docs/tasks/RUST-PARITY.md](docs/tasks/RUST-PARITY.md) |
| `SCALAREF-RETIREMENT` | `done` | `Overall roadmap — .spec language evolution / compatibility retirement` | All 5 leaves done 2026-07-02: directive owned, inventory/replacement contract locked, live specs/tests/corpus/docs migrated, Perl/Rust implementation support removed, final no-drift sweep closed. | [docs/tasks/SCALAREF-RETIREMENT.md](docs/tasks/SCALAREF-RETIREMENT.md) |
| `PERL-ACTIONIR-AST-MIGRATION` | `done` | `Overall roadmap — compiler architecture / variant contract` | All leaves `.0`–`.5.4` done 2026-07-01: text-to-AST doctrine adopted, Perl ActionIR AST parser seam landed, value/statement/control lowering moved to typed AST nodes, supported fallback leakage retired, return/value unknown calls diagnose, short wrappers retired, and `fn` grammar ownership locked to `specs/spec.spec`. PNT returned to `SPEC-FORMAT-TERSE.4.1`; `.4.1`, `.4.2.1`, `.4.2.2`, `.4.2.3`, `.4.3.1`, `.4.3.2`, `.4.4`, `.3.2.2`, `.3.2.3`, `.3.2.3.1`, `.3.2.3.2`, `.3.2.3.3`, `.3.2.3.4`, `.3.3`, `.3.3.1`, `.3.3.2`, `.3.3.3`, and `.3.3.4` are now complete/owned; later `.6` shipped-spec migration and `.7` type-method surface both closed, and the active `SPEC-FORMAT-TERSE.15` frontier now owns colon scalar-slot retirement. | [docs/tasks/PERL-ACTIONIR-AST-MIGRATION.md](docs/tasks/PERL-ACTIONIR-AST-MIGRATION.md) |
| `PHASE0-BACKHALF-TRIAGE` | `done` | `Overall roadmap — regression-gate health (back-half core failures)` | `.1` triage (108 STALE / 65 REAL) + `.2` re-bless 108 STALE + `.3`/`.4` two authorized engine defect fixes (ADR `0008`) + `.5` green-phase0 (corpus hang fix + dark-tail re-bless + full-gate-green + status/doc/book drift sync, closing `LEGACY-VHDL-RETIRE` + `NONCORE-QUARANTINE`) → **`t/phase0_regression.t` 960/960 GREEN** + `tools/run_ci_local.sh` EXIT 0. `.6` (book `:AND`) `superseded` by `TOP-RULE-AS-NORMAL` (escalated to an engine change, ADR `0010`). | [docs/tasks/PHASE0-BACKHALF-TRIAGE.md](docs/tasks/PHASE0-BACKHALF-TRIAGE.md) |
| `LEGACY-VHDL-RETIRE` | `done` | `Overall roadmap — keep only portable/cross-variant code (retirement)` | All 5 leaves (`.1` inventory; `.2`+`.3` retire 3 Perl-only modules + 6 `.plg` + phase0 smoke ≈6,701 lines; `.4` RTLUtils hang cleared + full local gate green; `.5` doc/book/KM drift sync via `PHASE0-BACKHALF-TRIAGE.5.3.2.2`) | [docs/tasks/LEGACY-VHDL-RETIRE.md](docs/tasks/LEGACY-VHDL-RETIRE.md) |
| `NONCORE-QUARANTINE` | `done` | `Overall roadmap — keep only portable/cross-variant code (non-core quarantine)` | Primary acceptance met: `.1`–`.4` relocated 36 non-core `.pm` + 13 `.plg` to `noncore/` (`perl/` core-only); `.V` verify (phase0 960/960 + full gate EXIT 0) + doc/book/KM sync (via `PHASE0-BACKHALF-TRIAGE.5.3.2.2`); `.N` (plugin-machinery fate) `deferred` as an explicit Non-Goal | [docs/tasks/NONCORE-QUARANTINE.md](docs/tasks/NONCORE-QUARANTINE.md) |
| `DOC-DRIFT-SYNC` | `completed` | `Overall roadmap — documentation and book sync` | Both leaves (`.1` ROADMAP.md Phase 8/9 + Overall `done` sync; `.2` formal-grammar.md `:&`/`:|` rule-mode cell fix) | [docs/tasks/DOC-DRIFT-SYNC.md](docs/tasks/DOC-DRIFT-SYNC.md) |
| `ALIAS-RETIREMENT-DOC-SYNC` | `completed` | `Overall roadmap — documentation and book sync` | `.1` (book formal-grammar + ROADMAP_V2 + ROADMAP: array-edge aliases `tail`/`drop_last`/`flatten`/`array_values` marked retired) | [docs/tasks/ALIAS-RETIREMENT-DOC-SYNC.md](docs/tasks/ALIAS-RETIREMENT-DOC-SYNC.md) |
| `MDBOOK-FORMAT-CORRECTNESS` | `completed` | `Overall roadmap — documentation and book sync` | All 3 leaves (`.1` runtime-semantics §5.2/§5.3, `.2` full-book sweep + formal-grammar §8.1/§12, `.3` finalize) | [docs/tasks/MDBOOK-FORMAT-CORRECTNESS.md](docs/tasks/MDBOOK-FORMAT-CORRECTNESS.md) |
| `MDBOOK-VARIANT-AGNOSTIC` | `completed` | `Overall roadmap — documentation and book sync` | All 7 leaves (`.1` audit, `.2` overview, `.3` user-model, `.4` public-api, `.5` DSL+compiler/arch, `.6` appendix+corpus+dev, `.7` final consistency sweep) | [docs/tasks/MDBOOK-VARIANT-AGNOSTIC.md](docs/tasks/MDBOOK-VARIANT-AGNOSTIC.md) |
| `SPEC-SPEC-SELFHOST` | `completed` | `Phase 7 follow-on — self-hosted .spec grammar (rewrite)` | All 4 leaves (`.1` inventory, `.2` rewrite spec.spec, `.3` verify + cross-check, `.4` docs sync) | [docs/tasks/SPEC-SPEC-SELFHOST.md](docs/tasks/SPEC-SPEC-SELFHOST.md) |
| `TASK-TREE-INDEX-SYNC` | `completed` | `Overall roadmap — documentation and tracker maintenance` | `TASK-TREE-INDEX-SYNC.1` (reconcile stale frontier index) | [docs/tasks/TASK-TREE-INDEX-SYNC.md](docs/tasks/TASK-TREE-INDEX-SYNC.md) |
| `REPO-HYGIENE` | `completed` | `Overall roadmap — repository maintenance` | All 2 leaves (`.1` tool-artifact ignore cleanup, `.2` local-only `rgx/` + `.claude/projects/` cleanup) | [docs/tasks/REPO-HYGIENE.md](docs/tasks/REPO-HYGIENE.md) |
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
