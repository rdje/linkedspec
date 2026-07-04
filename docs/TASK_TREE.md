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
| `SPEC-FORMAT-TERSE` | `active` (frontier empty) | `Overall roadmap — .spec language evolution (terse format)` | `.0` done 2026-06-18 (ratified — ADR `0007`). Implementation gate CLEARED 2026-06-22 (`t/phase0_regression.t` green + `tools/run_ci_local.sh` EXIT 0; gradual-alias migration). **`.1.1` DONE 2026-06-24** (auto-existing wrapper-referenced working vars on Perl + Rust). **`.1.2` SPLIT** by inference channel; **`.1.2.1`+`.1.2.2` DONE 2026-06-24 — Channel 1 complete on BOTH variants** (Channel 2 deferred behind `.1.5`). **`.1.4` DONE 2026-06-29** (helper renames closed on both variants; Perl reference + Rust parity, phase0 **975 green**). **`.1.3` DONE 2026-06-29** — mutation surface closed by mechanism: scalar `set(name,val)` already satisfied by `.1.4`; `push(target,value)` explicit append with child-call precedence; `set_key(name,key,value)` statement mutation while value form stays pure; operator family closed with scalar `name = value`, array `items += value`, and hash `name[key] = value` for explicit key/value expressions. **`.1.5` SPLIT 2026-06-29** — audit showed literal parity, call spacing, separator semantics, and direct nested access are separate leaves. **`.1.5.2` DONE 2026-06-29** — primitive literals are typed values on Perl/Rust, with JSON booleans and Rust statement-form `if(false)` gating. **`.1.5.3` DONE 2026-06-29** — call spacing locked: optional whitespace before `(` works at supported helper/value sites, while no-parenthesis helpers remain out of scope. **`.1.5.4` DONE 2026-06-29** — statement separators locked: newline-or-semicolon, same-line multiple statements require `;`, nested semicolons protected. **`.1.5.5` SPLIT 2026-06-29** — direct nested access divided into explicit-segment and Channel-2 coordination. **`.1.5.5.1` DONE 2026-06-29** — explicit direct access landed; **`.1.5.5.2` SUPERSEDED/MERGED 2026-06-29**. **`.1.2.3` through `.1.2.3.5.4` DONE 2026-06-29** — Channel 2 aggregate/scalar bare reads, direct path atoms, shape-literal values, and RHS target-kind inference landed on Perl/Rust; corpus 32 fixtures. **`.1.6` DONE 2026-06-29** — array end-mutation methods landed; phase0 **990 green**, corpus 33 fixtures, Round 1 closed. **`.2.1.1` DONE/SPLIT 2026-06-29**; **`.2.1.2` DONE 2026-06-29** — Perl block values; **`.2.1.3` DONE 2026-06-29** — Rust block values; corpus **34 fixtures**. **`.2.1.4` DONE 2026-06-30** — block-local early return landed on Perl/Rust; corpus **35 fixtures**. **`.2.2.1` DONE/SPLIT 2026-06-30** — control-flow keyword surface split. **`.2.2.2` DONE 2026-06-30** — Perl attached-block if landed. **`.2.2.3` DONE 2026-06-30** — Rust attached-block if parity landed; corpus **36 fixtures**. **`.2.2.4` DONE 2026-06-30** — `when/otherwise` aliases landed; corpus **37 fixtures**. **`.2.2.5` SPLIT/OWNED 2026-06-30**; **`.2.2.5.1` DONE 2026-06-30** — Perl attached switch separator/source lock; **`.2.2.5.2` DONE 2026-06-30** — Rust attached switch parity, corpus **38 fixtures**. **`.2.2.6` DONE 2026-06-30** — attached `while(cond) { ... }` split and closed; **`.2.2.6.1` DONE 2026-06-30** — Perl attached while loop/safety landed; **`.2.2.6.2` DONE 2026-06-30** — Rust attached while parity landed, corpus **39 fixtures**. **`.2.3` SPLIT/OWNED 2026-06-30**; **`.2.3.1` DONE 2026-06-30** — Perl fluent `.when(cond) { ... }.otherwise { ... }` block-chain fallback contract landed, phase0 **993 green**; **`.2.3.2` DONE 2026-06-30** — lifecycle value/drop return-channel lock landed, phase0 **994 green**; **`.2.3.3` SPLIT/OWNED 2026-06-30**; **`.2.3.3.1` DONE 2026-06-30** — Rust action-edge fluent no-arg `.push` / `.return(expr)` parity landed; **`.2.3.3.2` DONE 2026-06-30** — Rust attached fluent `.when(cond) { ... }` block payloads now execute on action-edge/lifecycle surfaces with dotted and no-dot fallback tails; **`.2.3.3.3` SPLIT 2026-06-30** — remaining Rust fluent continuations split into compact lifecycle/body chains, action-edge explicit/flow chains, and `tclite` re-enable/default-mode repetition audit; **`.2.3.3.3.1` DONE 2026-06-30** — Rust compact lifecycle/body receiver chains now execute as lifecycle `CodeBlock` statements; **`.2.3.3.3.2` DONE 2026-06-30** — Rust action-edge explicit/flow fluent chains now execute with explicit-target child-return appends and statement-control gating; **`.2.3.3.3.3` DONE/SPLIT 2026-06-30** — `tclite` retry after fluent parity still returned Rust `[]` for `[]`/`""`, splitting default-mode recursive repetition parity; **`.2.3.3.3.3.1` DONE 2026-06-30** — Rust default-mode repetition parity landed and the two `tclite` fixtures are active (corpus **41 fixtures**); **`.2.3.4` DONE/SPLIT 2026-06-30** — full composability audit added a green deep pure-helper oracle fixture (corpus **42 fixtures**) and split Rust helper-context aggregate bare reads plus Perl inline value-control lowering into children; **`.2.3.4.1` DONE 2026-06-30** — Rust helper-context bare aggregate arguments landed for hash- and array-consuming helper slots, corpus **44 fixtures**; **`.2.3.4.2` DONE 2026-06-30** — Perl inline value-control lowering landed for `if`/`switch` in supported value positions, corpus **46 fixtures**; **`.2.3.5` DONE/SPLIT 2026-07-01** — return-type method chaining specified before code and split into array/hash/string/number implementation leaves plus a block-valued receiver audit; **`.2.3.5.1` DONE 2026-07-01** — array receiver-dot value chains landed on Perl/Rust, phase0 **996 green**, corpus **47 fixtures**; **`.2.3.5.2` DONE 2026-07-01** — hash receiver-dot value chains landed on Perl/Rust, corpus **48 fixtures**, statement-level hash mutations preserved, Rust `merge_hash` override parity fixed; **`.2.3.5.3` DONE 2026-07-01** — string/scalar receiver-dot value chains landed on Perl/Rust, split bridges into array chains, string literal receivers parse on Rust, value-form split/substr payloads are portable, phase0 **998 green**, corpus **49 fixtures**; **`.2.3.5.4` DONE 2026-07-01** — number receiver-dot value chains landed on Perl/Rust; numeric literal receivers parse, comparisons are terminal, value-form numeric comparisons lower on Perl, Rust `num_add`/`num_mul` consume all operands, phase0 **999 green**, corpus **50 fixtures**; **`.2.3.5.6` DONE 2026-07-01** — aggregate wrapper quoted-name boundaries and direct shape constructor preference locked, phase0 **1000 green**, corpus **51 fixtures**; **`.2.3.5.5` DONE 2026-07-01** — block-valued receiver-dot chains landed by yielded runtime type, phase0 **1001 green**, corpus **52 fixtures**; **`.5.0` DONE 2026-07-01** — future variant parity ownership/inventory landed before non-Rust variant code; **`.3.1` DONE 2026-07-01** — edge syntax contract locked with no behavior change (`->` action, `=>` blind-call, grouped action targets require a shared block); **`.3.2` SPLIT/OWNED 2026-07-01** — arithmetic/comparison call surface split before code, with one `callee(args)` grammar, word aliases first, arithmetic symbol callees second, and comparison spelling policy isolated; **`.3.2.1` DONE 2026-07-01** — numeric word aliases landed on Perl/Rust while bare comparison words stayed string helpers until `.3.2.3.3` later flipped them. **`.4` SPLIT/OWNED 2026-07-01** — user-defined pure functions accepted into Round 4; calls are value expressions, receiver-chain capable, and standalone results are silently discarded; permanent `fn` grammar belongs in `specs/spec.spec`, with bootstrap-parser support temporary/removable after text-to-AST handoff. **`.4.1` DONE 2026-07-01** — MVP contract/inventory locked before code; `.4.2` split into Perl grammar/registry, value-call execution, and discard/purity hardening leaves; `.4.3` split into Rust registry and runtime/oracle parity. **`.4.2.1` DONE 2026-07-01** — Perl function-definition grammar/registry descriptor seam landed; **`.4.2.2` DONE 2026-07-01** — registered exact-arity Perl user-function value calls now execute in value positions and compatible receiver chains. **`.4.2.3` DONE 2026-07-01** — Perl standalone discard and hardening landed; registered standalone calls lower as `VALUE_DROP`, recursion/unsupported body diagnostics are locked. **`.4.3.1` DONE 2026-07-02** — Rust function-definition AST/compiler registry parity landed. **`.4.3.2` DONE 2026-07-02** — Rust registered user-function calls now execute as values, feed compatible receiver chains, discard standalone results, and pass the Perl/Rust oracle fixture; corpus **54 fixtures**. **`.4.4` DONE 2026-07-02** — function MVP surface/deferral ledger finalized: explicit-paren braced `fn` stays the accepted surface; alternate spellings, optional zero-arg parentheses, brace-less bodies, side-effect/caller-mutating functions, recursion, closures/lambdas/currying, and namespaces remain deferred. **`.3.2.2` DONE 2026-07-02** — arithmetic symbol callees `+(...)`, `-(...)`, `*(...)`, `/(...)`, and `%(...)` now map to `num_add/sub/mul/div/mod` on Perl/Rust while slash regex literals remain regexes; corpus **55 fixtures**, phase0 **1008 green**. **`.3.2.3` SPLIT/OWNED 2026-07-02** — comparison call-surface migration is split behind explicit `str_*` string helpers, numeric comparison word aliases, and numeric comparison symbol callees. **`.3.2.3.1` DONE 2026-07-02** — explicit `str_eq`/`str_ne`/`str_gt`/`str_ge`/`str_lt`/`str_le` string-bridge contract locked before code. **`.3.2.3.2` DONE 2026-07-02** — explicit `str_*` string-comparison helpers now ship on Perl/Rust. **`.3.2.3.3` DONE 2026-07-02** — bare comparison word calls now map to numeric `num_*` aliases on Perl/Rust while lexical strings use explicit `str_*`; corpus **57 fixtures**, phase0 **1010 green**. **`.3.2.3.4` DONE 2026-07-02** — comparison symbol callees `==`/`!=`/`>`/`>=`/`<`/`<=` now map to numeric `num_*` aliases on Perl/Rust; corpus **58 fixtures**, phase0 **1011 green**. **`.3.3` SPLIT/DONE 2026-07-02** — expression-valued assignment split before code. **`.3.3.1` DONE 2026-07-02** — scalar non-shape assignment expressions and scalar `=(target,value)` equivalence now ship on Perl/Rust; **`.3.3.2` DONE 2026-07-02** — aggregate assignment expression values after target-kind inference now ship on Perl/Rust; **`.3.3.3` DONE 2026-07-02** — array append and hash-index mutation expression values now return updated aggregate snapshots on Perl/Rust; corpus **61 fixtures**, phase0 **1014 green**. **`.3.3.4` DONE 2026-07-02** — assignment-expression closure and legacy spelling cleanup landed; public examples prefer `set(...)`/operators while `assign(...)` remains a legacy alias, corpus **62 fixtures**, phase0 **1015 green**; `.6` shipped-spec migration and `.7` type-method surface are closed; no `SPEC-FORMAT-TERSE` leaf is currently pending, and PNT returns to `TRACE-OBSERVABILITY.4.1` unless a new terse leaf is split or another active tree is reprioritized. | [docs/tasks/SPEC-FORMAT-TERSE.md](docs/tasks/SPEC-FORMAT-TERSE.md) |
| `STAGED-LINKED-PARSING` | `active` (prototype complete; frontier empty) | `Overall roadmap — .spec language model / parser composition` | The first function-body staged prototype is complete: `.1` adopted staged linked parsing doctrine, `.2` specified future import/composition, `.3` specified future parse-job annotations, `.4` specified deterministic registry/dispatch queue semantics, `.5.1` selected user-function body text as the first prototype payload family, `.5.2` audited the function-definition AST shape/harness before code, `.5.3.1` added `specs/user_function_definition.spec` as the executable user-function definition AST parser consumed by the Perl registry, `.5.3.2` retired the Rust raw definition parser bridge, `.5.4` added the neutral `body_parse_job` sidecar, `.5.5` dispatched function-body jobs to `actionir-body.spec` / `action_block` and stitched `body_ast`, and `.5.6` proved descriptor/parsed/compiled AST shape, runtime stability, source-provenance diagnostics, and Perl/Rust parity. Current frontier: _empty_; PNT returns to `TRACE-OBSERVABILITY.4.1` unless a new staged linked parsing leaf is split or another active tree is reprioritized. | [docs/tasks/STAGED-LINKED-PARSING.md](docs/tasks/STAGED-LINKED-PARSING.md) |
| `DOCTRINE-ENFORCEMENT-ADOPT` | `active` | `Overall roadmap — durable architecture / doctrine enforcement` | User directive 2026-06-22: adopt the portable Doctrine-Enforcement architecture + a LinkedSpec `TOOLBOX.md`. **`.1`+`.2` DONE** (atomic): `TOOLBOX.md` (LinkedSpec's OWN debug tools), `DOCTRINE_ENFORCEMENT.md`, `scripts/check_doctrines.sh` (driver+registry = `MEMORY-ARCH`+`KNOWLEDGE-MAP`, 2/2 PASS), `.githooks/pre-commit`→driver, `tools/run_ci_local.sh`→driver, discovery pointers, ADR `0009`. Frontier → **`.3`** (deferred — evidence/task-acceptance hard-gate). | [docs/tasks/DOCTRINE-ENFORCEMENT-ADOPT.md](docs/tasks/DOCTRINE-ENFORCEMENT-ADOPT.md) |
| `TRACE-OBSERVABILITY` | `active` | `Overall roadmap — engine observability / developer experience` | User directive 2026-06-19: discoverable CLI trace control + comprehensive "see everything" trace (function enter/exit, if/switch/case branches). Framework EXISTS (`Trace.pm`: enter/exit/decision/levels/sinks; env/per-call control works). `.1` audit showed trace was not exhaustive; `.2` added discoverable `bin/linkedspec` CLI flags and docs. `.3` split and closed Perl reference coverage through generated-handler, RuleIR, EmitContext, ActionIR pipeline, compact lowerer, MethodLowering, and compile/ActionIR closeout leaves. `.3.5` closed trace no-drift/contract docs and split required backend parity. Frontier `.4.1` maps the neutral mdBook trace contract onto Rust surfaces before Rust trace code. | [docs/tasks/TRACE-OBSERVABILITY.md](docs/tasks/TRACE-OBSERVABILITY.md) |
| `SPEC-LANG-REFERENCE` | `active` (scorch ⏸ PAUSED) | `Overall roadmap — documentation and book sync` | **SCORCH PAUSED 2026-06-18** — `.10.5.2`/`.10.5.3`/`.10.5.4` done (2-rule idiom, verified outputs); remaining fix leaves `.10.5.5`–`.10.5.19` paused because the user **activated `SPEC-FORMAT-TERSE`** (terse `.spec` format), whose migration will re-sweep every book example in lockstep with the engine. Resume the scorch only if directed, or fold the remaining files into the terse book-sweep. | [docs/tasks/SPEC-LANG-REFERENCE.md](docs/tasks/SPEC-LANG-REFERENCE.md) |
| `ROADMAP-DRIFT-RECONCILE` | `active` (leaves **DEFERRED** behind `SPEC-FORMAT-TERSE`) | `Overall roadmap — documentation and book sync` | Created 2026-06-23 to OWN a deferred reconciliation. A full-read drift audit of `ROADMAP.md` (1266 lines) vs `ROADMAP_V2.md` + the tree ledger found the long-form `ROADMAP.md` stale: it never names the active `SPEC-FORMAT-TERSE` tree / terse direction, still presents `declare(...)` as the permanent required form, still lists `RTLUtils` + the 36-`.plg` corpus as live (misses `LEGACY-VHDL-RETIRE` deletion + `NONCORE-QUARANTINE` relocation to `noncore/` + `perl/` core-only + the phase0 count), and frames multi-backend as Rust-only. `ARCHITECTURE_STATE.md` is mildly stale (dated 2026-06-14; model still broadly accurate). Leaves `.1` (ROADMAP.md reconcile) + `.2` (ARCHITECTURE_STATE.md refresh) are tracked `pending` but **deferred behind the active terse track** per the user's 2026-06-23 decision ("Defer — track as a new leaf") — not PNT-eligible until the terse track pauses or the user directs. | [docs/tasks/ROADMAP-DRIFT-RECONCILE.md](docs/tasks/ROADMAP-DRIFT-RECONCILE.md) |

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

Index note 2026-07-04: `SPEC-FORMAT-TERSE.6.4` is now done. Declaration helpers remain accepted legacy
compatibility for existing specs, but new shipped specs, public examples, and current corpus examples use terse
auto-existing variables and assignment/mutation forms. ADR `0018`, mdBook policy notes, and Knowledge Map coverage
record the decision; future removal or diagnostics require a separate focused leaf. Declaration-retirement `.6`
is closed. Frontier advances to `.7.1` for the supported-type method audit.

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
`SPEC-FORMAT-TERSE` frontier is empty. `TRACE-OBSERVABILITY.3` has since split, `.3.1` through `.3.5` have closed; PNT returns to `TRACE-OBSERVABILITY.4.1` unless a new terse leaf is split or another active tree is reprioritized.

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
Perl/Rust; it reads scalar slot `name`, and `set(:payload, [value])` keeps scalar-held direct-shape payload
assignment while bare direct-shape targets still infer aggregates. Phase0 passes with **1019** tests and the Rust
oracle corpus passes over **73 fixtures** including `terse_6_2_3_1_scalar_slot_shorthand`. Frontier advances to
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
`RUST-PARITY` unblocked `TOP-RULE-AS-NORMAL.3.2`; that leaf has since closed, `TRACE-OBSERVABILITY.1` has completed its read-only audit, `TRACE-OBSERVABILITY.2` has added CLI trace control, `.3` has split before code, `.3.1` through `.3.5` have closed, and PNT advances to `TRACE-OBSERVABILITY.4.1`.

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
| `TOP-RULE-AS-NORMAL` | `done` | `Overall roadmap — .spec language model / engine evolution` | All leaves `.1`–`.4` done 2026-07-04: top rule documented and tested as an ordinary rule entered first; Perl and Rust forward-progress recursion guards landed; recursive-top-rule `LX` authoring model documented; Rust recursive top-rule/body value parity locked by declared-variable scoping and 91-fixture oracle corpus coverage. PNT advanced through `TRACE-OBSERVABILITY.1` and `.2`; `.3` has since split and `.3.1` through `.3.5` have closed, so the next eligible frontier is `TRACE-OBSERVABILITY.4.1`. | [docs/tasks/TOP-RULE-AS-NORMAL.md](docs/tasks/TOP-RULE-AS-NORMAL.md) |
| `RUST-PARITY` | `done` | `Phase 9 — Rust variant (parity follow-on)` | All leaves `.1`–`.9` done 2026-07-04: deferred runtime/helper gaps closed, recursive shipped-spec parity and 88-fixture oracle finalized, generated-source direct execution covers all current structural families with all-family plus manifest-backed subset proof, and roadmap/live-doc/book/architecture alignment finalized. PNT advanced through `TOP-RULE-AS-NORMAL.3.2` and `TRACE-OBSERVABILITY.1`/`.2`; `.3` has since split and `.3.1` through `.3.5` have closed, so the next eligible frontier is `TRACE-OBSERVABILITY.4.1`. | [docs/tasks/RUST-PARITY.md](docs/tasks/RUST-PARITY.md) |
| `SCALAREF-RETIREMENT` | `done` | `Overall roadmap — .spec language evolution / compatibility retirement` | All 5 leaves done 2026-07-02: directive owned, inventory/replacement contract locked, live specs/tests/corpus/docs migrated, Perl/Rust implementation support removed, final no-drift sweep closed. | [docs/tasks/SCALAREF-RETIREMENT.md](docs/tasks/SCALAREF-RETIREMENT.md) |
| `PERL-ACTIONIR-AST-MIGRATION` | `done` | `Overall roadmap — compiler architecture / variant contract` | All leaves `.0`–`.5.4` done 2026-07-01: text-to-AST doctrine adopted, Perl ActionIR AST parser seam landed, value/statement/control lowering moved to typed AST nodes, supported fallback leakage retired, return/value unknown calls diagnose, short wrappers retired, and `fn` grammar ownership locked to `specs/spec.spec`. PNT returned to `SPEC-FORMAT-TERSE.4.1`; `.4.1`, `.4.2.1`, `.4.2.2`, `.4.2.3`, `.4.3.1`, `.4.3.2`, `.4.4`, `.3.2.2`, `.3.2.3`, `.3.2.3.1`, `.3.2.3.2`, `.3.2.3.3`, `.3.2.3.4`, `.3.3`, `.3.3.1`, `.3.3.2`, `.3.3.3`, and `.3.3.4` are now complete/owned; later `.6` shipped-spec migration and `.7` type-method surface both closed, and no `SPEC-FORMAT-TERSE` leaf is currently pending. | [docs/tasks/PERL-ACTIONIR-AST-MIGRATION.md](docs/tasks/PERL-ACTIONIR-AST-MIGRATION.md) |
| `PHASE0-BACKHALF-TRIAGE` | `done` | `Overall roadmap — regression-gate health (back-half core failures)` | `.1` triage (108 STALE / 65 REAL) + `.2` re-bless 108 STALE + `.3`/`.4` two authorized engine defect fixes (ADR `0008`) + `.5` green-phase0 (corpus hang fix + dark-tail re-bless + full-gate-green + status/doc/book drift sync, closing `LEGACY-VHDL-RETIRE` + `NONCORE-QUARANTINE`) → **`t/phase0_regression.t` 960/960 GREEN** + `tools/run_ci_local.sh` EXIT 0. `.6` (book `:AND`) `superseded` by `TOP-RULE-AS-NORMAL` (escalated to an engine change, ADR `0010`). | [docs/tasks/PHASE0-BACKHALF-TRIAGE.md](docs/tasks/PHASE0-BACKHALF-TRIAGE.md) |
| `LEGACY-VHDL-RETIRE` | `done` | `Overall roadmap — keep only portable/cross-variant code (retirement)` | All 5 leaves (`.1` inventory; `.2`+`.3` retire 3 Perl-only modules + 6 `.plg` + phase0 smoke ≈6,701 lines; `.4` RTLUtils hang cleared + full local gate green; `.5` doc/book/KM drift sync via `PHASE0-BACKHALF-TRIAGE.5.3.2.2`) | [docs/tasks/LEGACY-VHDL-RETIRE.md](docs/tasks/LEGACY-VHDL-RETIRE.md) |
| `NONCORE-QUARANTINE` | `done` | `Overall roadmap — keep only portable/cross-variant code (non-core quarantine)` | Primary acceptance met: `.1`–`.4` relocated 36 non-core `.pm` + 13 `.plg` to `noncore/` (`perl/` core-only); `.V` verify (phase0 960/960 + full gate EXIT 0) + doc/book/KM sync (via `PHASE0-BACKHALF-TRIAGE.5.3.2.2`); `.N` (plugin-machinery fate) `deferred` as an explicit Non-Goal | [docs/tasks/NONCORE-QUARANTINE.md](docs/tasks/NONCORE-QUARANTINE.md) |
| `DOC-DRIFT-SYNC` | `completed` | `Overall roadmap — documentation and book sync` | Both leaves (`.1` ROADMAP.md Phase 8/9 + Overall `done` sync; `.2` formal-grammar.md `:&`/`:|` rule-mode cell fix) | [docs/tasks/DOC-DRIFT-SYNC.md](docs/tasks/DOC-DRIFT-SYNC.md) |
| `ALIAS-RETIREMENT-DOC-SYNC` | `completed` | `Overall roadmap — documentation and book sync` | `.1` (book formal-grammar + ROADMAP_V2 + ROADMAP: array-edge aliases `tail`/`drop_last`/`flatten`/`array_values` marked retired) | [docs/tasks/ALIAS-RETIREMENT-DOC-SYNC.md](docs/tasks/ALIAS-RETIREMENT-DOC-SYNC.md) |
| `MDBOOK-FORMAT-CORRECTNESS` | `completed` | `Overall roadmap — documentation and book sync` | All 3 leaves (`.1` runtime-semantics §5.2/§5.3, `.2` full-book sweep + formal-grammar §8.1/§12, `.3` finalize) | [docs/tasks/MDBOOK-FORMAT-CORRECTNESS.md](docs/tasks/MDBOOK-FORMAT-CORRECTNESS.md) |
| `MDBOOK-VARIANT-AGNOSTIC` | `completed` | `Overall roadmap — documentation and book sync` | All 7 leaves (`.1` audit, `.2` overview, `.3` user-model, `.4` public-api, `.5` DSL+compiler/arch, `.6` appendix+corpus+dev, `.7` final consistency sweep) | [docs/tasks/MDBOOK-VARIANT-AGNOSTIC.md](docs/tasks/MDBOOK-VARIANT-AGNOSTIC.md) |
| `SPEC-SPEC-SELFHOST` | `completed` | `Phase 7 follow-on — self-hosted .spec grammar (rewrite)` | All 4 leaves (`.1` inventory, `.2` rewrite spec.spec, `.3` verify + cross-check, `.4` docs sync) | [docs/tasks/SPEC-SPEC-SELFHOST.md](docs/tasks/SPEC-SPEC-SELFHOST.md) |
| `TASK-TREE-INDEX-SYNC` | `completed` | `Overall roadmap — documentation and tracker maintenance` | `TASK-TREE-INDEX-SYNC.1` (reconcile stale frontier index) | [docs/tasks/TASK-TREE-INDEX-SYNC.md](docs/tasks/TASK-TREE-INDEX-SYNC.md) |
| `REPO-HYGIENE` | `completed` | `Overall roadmap — repository maintenance` | `REPO-HYGIENE.1` | [docs/tasks/REPO-HYGIENE.md](docs/tasks/REPO-HYGIENE.md) |
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
