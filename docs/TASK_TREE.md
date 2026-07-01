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
| `SPEC-FORMAT-TERSE` | `active` | `Overall roadmap — .spec language evolution (terse format)` | `.0` done 2026-06-18 (ratified — ADR `0007`). Implementation gate CLEARED 2026-06-22 (`t/phase0_regression.t` green + `tools/run_ci_local.sh` EXIT 0; gradual-alias migration). **`.1.1` DONE 2026-06-24** (auto-existing wrapper-referenced working vars on Perl + Rust). **`.1.2` SPLIT** by inference channel; **`.1.2.1`+`.1.2.2` DONE 2026-06-24 — Channel 1 complete on BOTH variants** (Channel 2 deferred behind `.1.5`). **`.1.4` DONE 2026-06-29** (helper renames closed on both variants; Perl reference + Rust parity, phase0 **975 green**). **`.1.3` DONE 2026-06-29** — mutation surface closed by mechanism: scalar `set(name,val)` already satisfied by `.1.4`; `push(target,value)` explicit append with child-call precedence; `set_key(name,key,value)` statement mutation while value form stays pure; operator family closed with scalar `name = value`, array `items += value`, and hash `name[key] = value` for explicit key/value expressions. **`.1.5` SPLIT 2026-06-29** — audit showed literal parity, call spacing, separator semantics, and direct nested access are separate leaves. **`.1.5.2` DONE 2026-06-29** — primitive literals are typed values on Perl/Rust, with JSON booleans and Rust statement-form `if(false)` gating. **`.1.5.3` DONE 2026-06-29** — call spacing locked: optional whitespace before `(` works at supported helper/value sites, while no-parenthesis helpers remain out of scope. **`.1.5.4` DONE 2026-06-29** — statement separators locked: newline-or-semicolon, same-line multiple statements require `;`, nested semicolons protected. **`.1.5.5` SPLIT 2026-06-29** — direct nested access divided into explicit-segment and Channel-2 coordination. **`.1.5.5.1` DONE 2026-06-29** — explicit direct access landed; **`.1.5.5.2` SUPERSEDED/MERGED 2026-06-29**. **`.1.2.3` through `.1.2.3.5.4` DONE 2026-06-29** — Channel 2 aggregate/scalar bare reads, direct path atoms, shape-literal values, and RHS target-kind inference landed on Perl/Rust; corpus 32 fixtures. **`.1.6` DONE 2026-06-29** — array end-mutation methods landed; phase0 **990 green**, corpus 33 fixtures, Round 1 closed. **`.2.1.1` DONE/SPLIT 2026-06-29**; **`.2.1.2` DONE 2026-06-29** — Perl block values; **`.2.1.3` DONE 2026-06-29** — Rust block values; corpus **34 fixtures**. **`.2.1.4` DONE 2026-06-30** — block-local early return landed on Perl/Rust; corpus **35 fixtures**. **`.2.2.1` DONE/SPLIT 2026-06-30** — control-flow keyword surface split. **`.2.2.2` DONE 2026-06-30** — Perl attached-block if landed. **`.2.2.3` DONE 2026-06-30** — Rust attached-block if parity landed; corpus **36 fixtures**. **`.2.2.4` DONE 2026-06-30** — `when/otherwise` aliases landed; corpus **37 fixtures**. **`.2.2.5` SPLIT/OWNED 2026-06-30**; **`.2.2.5.1` DONE 2026-06-30** — Perl attached switch separator/source lock; **`.2.2.5.2` DONE 2026-06-30** — Rust attached switch parity, corpus **38 fixtures**. **`.2.2.6` DONE 2026-06-30** — attached `while(cond) { ... }` split and closed; **`.2.2.6.1` DONE 2026-06-30** — Perl attached while loop/safety landed; **`.2.2.6.2` DONE 2026-06-30** — Rust attached while parity landed, corpus **39 fixtures**. **`.2.3` SPLIT/OWNED 2026-06-30**; **`.2.3.1` DONE 2026-06-30** — Perl fluent `.when(cond) { ... }.otherwise { ... }` block-chain fallback contract landed, phase0 **993 green**; **`.2.3.2` DONE 2026-06-30** — lifecycle value/drop return-channel lock landed, phase0 **994 green**; **`.2.3.3` SPLIT/OWNED 2026-06-30**; **`.2.3.3.1` DONE 2026-06-30** — Rust action-edge fluent no-arg `.push` / `.return(expr)` parity landed; **`.2.3.3.2` DONE 2026-06-30** — Rust attached fluent `.when(cond) { ... }` block payloads now execute on action-edge/lifecycle surfaces with dotted and no-dot fallback tails; **`.2.3.3.3` SPLIT 2026-06-30** — remaining Rust fluent continuations split into compact lifecycle/body chains, action-edge explicit/flow chains, and `tclite` re-enable/default-mode repetition audit; **`.2.3.3.3.1` DONE 2026-06-30** — Rust compact lifecycle/body receiver chains now execute as lifecycle `CodeBlock` statements; **`.2.3.3.3.2` DONE 2026-06-30** — Rust action-edge explicit/flow fluent chains now execute with explicit-target child-return appends and statement-control gating; **`.2.3.3.3.3` DONE/SPLIT 2026-06-30** — `tclite` retry after fluent parity still returned Rust `[]` for `[]`/`""`, splitting default-mode recursive repetition parity; **`.2.3.3.3.3.1` DONE 2026-06-30** — Rust default-mode repetition parity landed and the two `tclite` fixtures are active (corpus **41 fixtures**); **`.2.3.4` DONE/SPLIT 2026-06-30** — full composability audit added a green deep pure-helper oracle fixture (corpus **42 fixtures**) and split Rust helper-context aggregate bare reads plus Perl inline value-control lowering into children; **`.2.3.4.1` DONE 2026-06-30** — Rust helper-context bare aggregate arguments landed for hash- and array-consuming helper slots, corpus **44 fixtures**; **`.2.3.4.2` DONE 2026-06-30** — Perl inline value-control lowering landed for `if`/`switch` in supported value positions, corpus **46 fixtures**; **`.2.3.5` DONE/SPLIT 2026-07-01** — return-type method chaining specified before code and split into array/hash/string/number implementation leaves plus a block-valued receiver audit; **`.2.3.5.1` DONE 2026-07-01** — array receiver-dot value chains landed on Perl/Rust, phase0 **996 green**, corpus **47 fixtures**; **`.2.3.5.2` DONE 2026-07-01** — hash receiver-dot value chains landed on Perl/Rust, phase0 **997 green**, corpus **48 fixtures**, Rust `merge_hash` later-override parity fixed; **`.2.3.5.3` DONE 2026-07-01** — string/scalar receiver-dot value chains landed on Perl/Rust, phase0 **998 green**, corpus **49 fixtures**, split bridges to array chains and string literal receivers parse on Rust; **`.2.3.5.4` DONE 2026-07-01** — number receiver-dot value chains landed on Perl/Rust, phase0 **999 green**, corpus **50 fixtures**, numeric literal receivers parse and comparisons are terminal; **`.2.3.5.6` DONE 2026-07-01** — aggregate wrapper quoted-name boundaries and direct shape constructor preference locked, phase0 **1000 green**, corpus **51 fixtures**; **`.2.3.5.5` DONE 2026-07-01** — block-valued receiver-dot chains landed by yielded runtime type, phase0 **1001 green**, corpus **52 fixtures**; **`.5.0` DONE 2026-07-01** — future variant parity ownership/inventory landed before non-Rust variant code; **`.3.1` DONE 2026-07-01** — edge syntax contract locked with no behavior change (`->` action, `=>` blind-call, grouped action targets require a shared block); **`.3.2` SPLIT/OWNED 2026-07-01** — arithmetic/comparison call surface split before code, with one `callee(args)` grammar, word aliases first, arithmetic symbol callees second, and comparison spelling policy isolated; **`.3.2.1` DONE 2026-07-01** — numeric word aliases landed on Perl/Rust while bare comparison words stay string helpers. **`.4` SPLIT/OWNED 2026-07-01** — user-defined pure functions accepted into Round 4; calls are value expressions, receiver-chain capable, and standalone results are silently discarded; permanent `fn` grammar belongs in `specs/spec.spec`, with bootstrap-parser support temporary/removable after text-to-AST handoff. **`.4.1` DONE 2026-07-01** — MVP contract/inventory locked before code; `.4.2` split into Perl grammar/registry, value-call execution, and discard/purity hardening leaves; `.4.3` split into Rust registry and runtime/oracle parity. **Frontier -> `SPEC-FORMAT-TERSE.4.2.1`** (Perl function-definition grammar/registry seam), then `.4.2.2`, `.4.2.3`, `.4.3.1`, `.4.3.2`, `.3.2.2`, `.3.2.3`. | [docs/tasks/SPEC-FORMAT-TERSE.md](docs/tasks/SPEC-FORMAT-TERSE.md) |
| `TOP-RULE-AS-NORMAL` | `active` (acceptance MET; only `.3.2` blocked on `RUST-PARITY`) | `Overall roadmap — .spec language model / engine evolution` | User authorized 2026-06-23 (ADR `0010`): treat the top rule as an ordinary rule (merely entered first) w.r.t. regex + recursion; engine-touch sanctioned (scoped exception, cross-variant parity required). **`.1` read-only investigation DONE** — the regex/codegen dimension is already uniform (top = `&{$descr->{spec}{$top_rule}}(...)`; `while(1)` is mode-driven not top-driven; `Pair::AND`+regex emits a normal AND handler), so the open gap is **top re-entry recursion + termination**. **`.2` DONE 2026-06-23** — `.2.1` forward-progress/consume-before-recurse termination guard (a one-site (rule,pos) non-progress cutoff in `SpecEntry`'s runtime-handler closure) + `.2.2` CONFIRMED no engine defect (top re-entry recursion already works with the `LX` accumulator idiom; the `null` was the missing-`LX` authoring case; TOP vs BODY differ by arity, not a bug — engine stays frozen). **phase0 960→964 green**, `tools/run_ci_local.sh` EXIT 0, zero regression; +4 phase0 locks. **`.3` SPLIT 2026-06-23 → `.3.1` (done) + `.3.2` (blocked)** after a Rust diagnosis: the cross-variant gap has two layers — (a) termination (Rust no-consume recursion **stack-overflowed/SIGABRT**) and (b) value (Rust returns nulls even for the standard body idiom = the GENERAL recursive-grammar parse gap, owned by `RUST-PARITY`). **`.3.1` DONE** — Rust forward-progress / consume-before-recurse guard (mirror of `.2.1`) in `rust/linkedspec-runtime/src/{runtime,engine}.rs`: a no-consume cycle now terminates cleanly (returns `[null]` = Perl `undef` wrapped) instead of crashing; +2 Rust locks; Rust 242→244 green; phase0 964/964 + gate EXIT 0 (Perl untouched). `.3.2` `blocked` on `RUST-PARITY` recursive-grammar parity. **`.4` DONE 2026-06-23** — book reconciliation (absorbs `PHASE0-BACKHALF-TRIAGE.6`): demoted law→idiom across 6 book files; documented `::`=entry-marker, the consume-before-recurse termination rule (formal-grammar §5.4), recursive-top-rule-needs-`LX`; de-footgunned the `Pair::AND` example + fixed the multi-pair consume/seek output bug; +1 phase0 lock (**964→965**); KM card [[top-rule-reads-own-match-with-match-family]]; `mdbook build` EXIT 0; full local gate EXIT 0. **Tree acceptance MET; frontier EMPTY** — tree stays `active` only because `.3.2` (value parity) is `blocked` on `RUST-PARITY`. PNT → next active tree (`SPEC-FORMAT-TERSE.1.x`). | [docs/tasks/TOP-RULE-AS-NORMAL.md](docs/tasks/TOP-RULE-AS-NORMAL.md) |
| `DOCTRINE-ENFORCEMENT-ADOPT` | `active` | `Overall roadmap — durable architecture / doctrine enforcement` | User directive 2026-06-22: adopt the portable Doctrine-Enforcement architecture + a LinkedSpec `TOOLBOX.md`. **`.1`+`.2` DONE** (atomic): `TOOLBOX.md` (LinkedSpec's OWN debug tools), `DOCTRINE_ENFORCEMENT.md`, `scripts/check_doctrines.sh` (driver+registry = `MEMORY-ARCH`+`KNOWLEDGE-MAP`, 2/2 PASS), `.githooks/pre-commit`→driver, `tools/run_ci_local.sh`→driver, discovery pointers, ADR `0009`. Frontier → **`.3`** (deferred — evidence/task-acceptance hard-gate). | [docs/tasks/DOCTRINE-ENFORCEMENT-ADOPT.md](docs/tasks/DOCTRINE-ENFORCEMENT-ADOPT.md) |
| `TRACE-OBSERVABILITY` | `active` | `Overall roadmap — engine observability / developer experience` | User directive 2026-06-19: discoverable CLI trace control + comprehensive "see everything" trace (function enter/exit, if/switch/case branches). Framework EXISTS (`Trace.pm`: enter/exit/decision/levels/sinks; env control `LINKEDSPEC_TRACE_LEVEL=debug` works) but is undiscoverable (no CLI/docs) + coverage isn't exhaustive. `.1` coverage audit → `.2` CLI+docs → `.3` extend coverage (pipeline + generated runtime parser). | [docs/tasks/TRACE-OBSERVABILITY.md](docs/tasks/TRACE-OBSERVABILITY.md) |
| `SPEC-LANG-REFERENCE` | `active` (scorch ⏸ PAUSED) | `Overall roadmap — documentation and book sync` | **SCORCH PAUSED 2026-06-18** — `.10.5.2`/`.10.5.3`/`.10.5.4` done (2-rule idiom, verified outputs); remaining fix leaves `.10.5.5`–`.10.5.19` paused because the user **activated `SPEC-FORMAT-TERSE`** (terse `.spec` format), whose migration will re-sweep every book example in lockstep with the engine. Resume the scorch only if directed, or fold the remaining files into the terse book-sweep. | [docs/tasks/SPEC-LANG-REFERENCE.md](docs/tasks/SPEC-LANG-REFERENCE.md) |
| `RUST-PARITY` | `active` | `Phase 9 — Rust variant (parity follow-on)` | `RUST-PARITY.7.5.3` | [docs/tasks/RUST-PARITY.md](docs/tasks/RUST-PARITY.md) |
| `ROADMAP-DRIFT-RECONCILE` | `active` (leaves **DEFERRED** behind `SPEC-FORMAT-TERSE`) | `Overall roadmap — documentation and book sync` | Created 2026-06-23 to OWN a deferred reconciliation. A full-read drift audit of `ROADMAP.md` (1266 lines) vs `ROADMAP_V2.md` + the tree ledger found the long-form `ROADMAP.md` stale: it never names the active `SPEC-FORMAT-TERSE` tree / terse direction, still presents `declare(...)` as the permanent required form, still lists `RTLUtils` + the 36-`.plg` corpus as live (misses `LEGACY-VHDL-RETIRE` deletion + `NONCORE-QUARANTINE` relocation to `noncore/` + `perl/` core-only + the phase0 count), and frames multi-backend as Rust-only. `ARCHITECTURE_STATE.md` is mildly stale (dated 2026-06-14; model still broadly accurate). Leaves `.1` (ROADMAP.md reconcile) + `.2` (ARCHITECTURE_STATE.md refresh) are tracked `pending` but **deferred behind the active terse track** per the user's 2026-06-23 decision ("Defer — track as a new leaf") — not PNT-eligible until the terse track pauses or the user directs. | [docs/tasks/ROADMAP-DRIFT-RECONCILE.md](docs/tasks/ROADMAP-DRIFT-RECONCILE.md) |

Index note 2026-07-01: `SPEC-FORMAT-TERSE.3.3` is now queued after `.3.2.3`; it owns expression-valued
assignment plus `=(target,value)` equivalence before any statement-only assignment implementation is broadened.

## Proposed Task Trees

Proposed trees record accepted backlog direction, but they are not
PNT-eligible until explicitly activated or until the roadmap selects that lane.

| Tree | Status | Roadmap lane | Proposed first leaf | File |
| --- | --- | --- | --- | --- |
| _(none — `SPEC-FORMAT-TERSE` was activated 2026-06-18; see Active Task Trees)_ | — | — | — | — |

## Completed Task Trees

| Tree | Status | Roadmap lane | Completed frontier | File |
| --- | --- | --- | --- | --- |
| `PERL-ACTIONIR-AST-MIGRATION` | `done` | `Overall roadmap — compiler architecture / variant contract` | All leaves `.0`–`.5.4` done 2026-07-01: text-to-AST doctrine adopted, Perl ActionIR AST parser seam landed, value/statement/control lowering moved to typed AST nodes, supported fallback leakage retired, return/value unknown calls diagnose, short wrappers retired, and `fn` grammar ownership locked to `specs/spec.spec`. PNT returned to `SPEC-FORMAT-TERSE.4.1`; that inventory leaf is now complete and the current frontier is `SPEC-FORMAT-TERSE.4.2.1`. | [docs/tasks/PERL-ACTIONIR-AST-MIGRATION.md](docs/tasks/PERL-ACTIONIR-AST-MIGRATION.md) |
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
