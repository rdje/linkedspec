run non-strict — KM `working-vars-no-strict-need-my-lexical`). `declare(...)` keeps working unchanged
(optional/explicit form; gradual-alias migration).

**How.** A rule-level collector `RuleIR::EmitContext::_collect_auto_working_var_decls` (+ a literal-masker
`_mask_action_code_literals`) scans the RAW pre-lowering blocks (`code_blocks` + `acode`/`bcode`/
`and_icode` entries — **never** the regex `re` slots) for single-bare-identifier wrapper refs, takes the
sigil from the wrapper, and dedups against the `@<label>` accumulator + any same-sigil `my` already in
the LOWERED code (declare/raw-my). It excludes the DSL literals `undef`/`true`/`false` and the
engine-reserved handler locals. `build_rule_ir_emit_context` returns it as `auto_var_decls`;
`SpecEntry::compile_spec_entry` prepends it to the preamble icode — an **empty** prefix when nothing is
collected, so declared specs stay **byte-identical**.

**Verification (TOOLBOX-first, dump-don't-guess).** `dump_parser_source` confirmed the no-declare hazard
(bare leaky-global `$count`/`@items`) and the injected `my`. Generated source for **all 20 shipped specs**
diffed mine-vs-git-stashed = **19/20 byte-identical**; only `tkgui` differs (one legit `my $subgui_name;`
for its genuinely-undeclared working scalar) with **identical parse output before/after, incl. a 2nd
same-process parse** (no leak). A Lispish `a(undef)`→`my @undef` false positive was caught by the diff and
fixed via the reserved-literal exclusion. **+3 phase0 locks** (no-declare scalar+array work + no
cross-parse leak; declare-path single-`my`; reserved-literal not auto-declared) → **phase0 965→968 green**;
`bash tools/run_ci_local.sh` **EXIT 0** ("Result: PASS", 968); ratio 1.0000 preserved (phase0 all-target
guard); `mdbook build` EXIT 0.

**Book (variant-agnostic contract).** Taught auto-existence (declare optional) in
`dsl/declaration-helper-reference.md` (new section), `appendix/helper-contract-catalog.md` §1 (note +
corrected the `assign` "must exist"/undeclared-error contract), and
`dsl/value-container-flow-helper-reference.md`. Examples NOT re-authored (a later gradual leaf).

**Next:** `SPEC-FORMAT-TERSE.1.1.2` (Rust lockstep parity — now PNT-eligible to assess; ADR `0006`/`0007`).

## 2026-06-23 — ROADMAP-DRIFT-RECONCILE.0 — own the deferred ROADMAP.md / ARCHITECTURE_STATE.md drift (TRACKING-ONLY)

**Scope:** one new task-tree file (`docs/tasks/ROADMAP-DRIFT-RECONCILE.md`) + its index row in
`docs/TASK_TREE.md` + live continuity docs. **No code, book, roadmap-content, or KM change** — this
slice only *tracks* a drift finding so it survives; it does not fix it.

**Why.** On a fresh-session bootstrap (full README→MEMORY_ARCHITECTURE→SESSION_BOOTSTRAP→MEMORY→
COMMIT→TASK_TREE→ROADMAP_V2 read, plus delegated analyses of the `LinkedSpec.pm` import tree, the
mdBook, and a full read of `ROADMAP.md`), a drift audit found the long-form `ROADMAP.md` has diverged
from `ROADMAP_V2.md` + the tree ledger: it never names the active `SPEC-FORMAT-TERSE` tree / terse
direction, still presents `declare(...)` as the permanent required form, still lists `RTLUtils` + the
36-`.plg` corpus as live (misses `LEGACY-VHDL-RETIRE` deletion + `NONCORE-QUARANTINE` relocation to
`noncore/` + `perl/` core-only + the phase0 count), and frames multi-backend as Rust-only.
`ARCHITECTURE_STATE.md` is mildly stale (dated 2026-06-14; its architectural *model* is still broadly
accurate). The user chose **"Defer — track as a new leaf"** (AskUserQuestion, 2026-06-23): track now,
fix later, do **not** interrupt the signoff-critical `SPEC-FORMAT-TERSE.1.1.1` engine change.

**What landed.** Created the `ROADMAP-DRIFT-RECONCILE` tree (`active`) with leaves `.1` (ROADMAP.md
reconcile) + `.2` (ARCHITECTURE_STATE.md refresh), both `pending` but **deferred behind the active
terse track** — not in the immediate PNT frontier. Registered it in the `docs/TASK_TREE.md` Active
Task Trees table with a clear deferral note.

**Verification:** tracking-only — `scripts/check_memory_architecture.sh` + the doctrine driver
`scripts/check_doctrines.sh` + the KM gate run green via the pre-commit hook; phase0 unaffected (965;
no engine/test/book/spec touched). Doctrine rationale: ADR `0001` §1 (own before touching) + §4
(zero-drift) + the user's defer decision.

**Next:** PNT proceeds to implement `SPEC-FORMAT-TERSE.1.1.1` (Perl auto-existing variables).

## 2026-06-23 — SPEC-FORMAT-TERSE.1.1 — split into `.1.1.1` (Perl) + `.1.1.2` (Rust parity); record the auto-existing-variable design (DOCS/TREE/KM)

**Scope:** task-tree (`docs/tasks/SPEC-FORMAT-TERSE.md`) + index (`docs/TASK_TREE.md`) + one new KM fact card
(+ regenerated `KNOWLEDGE_MAP.md`) + live continuity docs. **No engine or book change** (`perl/`, `rust/`,
and `docs/linkedspec-book/` untouched). First step into the terse-`.spec`-format implementation track
(ADR `0007`), entered by PNT after `TOP-RULE-AS-NORMAL` reached acceptance.

**Why a split, not an implementation.** PNT picked the first terse-format leaf `.1.1` (auto-existing
variables). A TOOLBOX-first `dump_parser_source` ground-truth pass (scratchpad `probe_autovar*.pl`,
dump-don't-transcribe) showed it is too broad for one signoff slice — a multi-module Perl reference-engine
change **plus** a lockstep Rust parity obligation (ADR `0006`). Per the PNT splitting rule, split it.

**Verified engine facts (now in KM card `working-vars-no-strict-need-my-lexical.md`):**
- A rule's `I`-block + every edge + `LX` compile into **one** `sub` / **one** lexical scope. A `declare`
  emits its `my` **once** in the preamble (after the auto `my @<label>;` accumulator), before the
  `while(1)` dispatch loop; edges and `LX` reference it. So `declare(scalar,x)`→`my $x`,
  `declare(array,x)`→`my @x`, `declare(hash,x)`→`my %x`; `scalar(x)`/`array(x)`/`hash(x)` carry the
  `$`/`@`/`%` sigil.
- Generated handlers run with **NO `use strict`** (`SpecEntry.pm` has neither `use strict` nor
  `no strict`). So a working variable used **without** `declare` does **not** fail loudly — it silently
  becomes a **leaky package global** (state-leaks across parser invocations and recursion). The purpose
  of auto-existence is to make first-used working vars **per-invocation `my` lexicals**.

**Resulting design for `.1.1.1` (Perl reference):** a **rule-level** pass collects every typed-wrapper
variable reference (`scalar(NAME)`/`array(NAME)`/`hash(NAME)` + `s/a/h` aliases, single bare-identifier
arg) across all of a rule's blocks, takes the sigil **from the wrapper** (no inference — that is `.1.2`),
and injects one `my $NAME`/`@NAME`/`%NAME` into the **preamble** (not inline-at-first-use, which would
reset an accumulator each dispatch iteration). Dedupe against the `@<label>` accumulator and any explicit
`declare`d name (so no double `my`). Preserve ratio 1.0000 (ADR `0002`). `declare(...)` keeps working
unchanged (deprecated alias, gradual migration per ADR `0007`).

**Tree changes:** `.1.1` → container with children `.1.1.1` (Perl) + `.1.1.2` (Rust lockstep parity, a
follow-on that depends on `.1.1.1`); frontier → `.1.1.1`. Mirrors how `TOP-RULE-AS-NORMAL` split its Perl
`.2` from its Rust `.3`.

**Verification (docs/tree/KM-only slice):** `scripts/check_memory_architecture.sh`,
`scripts/check_doctrines.sh` (2/2 PASS), and `knowledge-map/scripts/check_knowledge_map.sh` all green; KM
map regenerated and in sync. phase0 baseline unchanged (965); no engine/book/test code touched, so the
regression gate is N/A to the split itself. **Next:** implement `.1.1.1`.

## 2026-06-23 — TOP-RULE-AS-NORMAL.4 — book reconciliation to the top-rule-as-ordinary model (BOOK + TEST + DOC)

**Scope:** mdBook + one phase0 lock + a KM card. **No engine/spec change** (`perl/` untouched). Closes the
final executable leaf of `TOP-RULE-AS-NORMAL`; tree acceptance MET (tree stays `active` only because `.3.2`
is `blocked` on `RUST-PARITY`). Absorbs the superseded `PHASE0-BACKHALF-TRIAGE.6` book work. Per ADR `0010`.

**What changed (6 book files, all examples verified via `LinkedSpec::Get` — dump-don't-transcribe):**
- `user-model/spec-files-and-rule-paragraphs.md` — new canonical section **"The top (`::`) rule is an ordinary
  rule, entered first"**: `::` = entry marker; modes/regex/recursion all legal on a top rule; the two-rule
  no-regex shape is idiom not law; the `entry_*` (entering match, dispatched child) vs `match_*` (own match,
  post-match edge) distinction; the consume-before-recurse termination rule; and the recursive-top-rule-needs-`LX`
  model with a verified `sexpr::`+`LX` example (`(a(b)c)`→`[["a",["b"],"c"]]`, `(a) (b)`→`[["a"],["b"]]`; no-`LX`→`null`).
- `appendix/formal-grammar.md` — §2.1 entry-marker/ordinary-rule note; §2.2 mode table column "Body rule only"
  → "Typical placement" with every mode cell "Body rule (idiom)" + an idiom-not-law note (`Top::AND`, `Stream::OR+`,
  `Pair::&` all valid); new **§5.4 Recursion and Forward-Progress Termination** (recursion may re-enter the top
  rule; consume-before-recurse; a non-progressing re-entry is cut to `undef`; backends MUST guarantee this —
  confirmed cross-variant by the `.3.1` Rust mirror; recursive top rule needs `LX`).
- `overview/what-is-linkedspec.md`, `user-model/worked-spec-walkthrough.md`, `appendix/helper-contract-catalog.md`
  — reframed "normal shape of every `.spec`" / "every `.spec` ... at least two rules" / "regex ... never on the
  `::` entry rule" / "a valid `.spec` needs at least two rules" from **law → recommended idiom**.
- `user-model/rule-modes-and-parse-modes.md` — **de-footgunned** the `Pair::AND` action example: it read
  `entry_text()` → `{name:null,value:null}` (a top rule has no entering match); fixed to a post-match edge +
  `match_group(0)` and folded the bare `\s*=\s*` separator into the name slot → `{name:"name",value:"value"}`.
  Added a model-tie note (`::`=entry-marker; termination) near the top.

**Correctness fix (book example bug found during verification):** `worked-spec-walkthrough.md` claimed
`'a = 1, b = 2'`→two pairs in the **`consume`** context, but under `consume` only the first pair matches (the
cursor stops at the comma); the two-pair result is a **`seek`** behavior. Reframed accurately as the
consume-vs-seek distinction in miniature.

**Discovered (out of `.4` scope; tracked as a tree open question):** in `AND` mode a bare edge-less middle
regex slot is a positional anchor that is **not separately consumed** (the value slot's `match_*` began before
the un-consumed `\s*=\s*`). Affects only illustrative no-output structural sketches — not a broken example.

**Lock + KM:** added `t/phase0_regression.t` subtest `top_rule_as_normal_regex_on_top_reads_own_match_with_match_family`
(3 assertions: parser builds; `match_group(0)`→populated values; `entry_text()` on a top rule→null). Wrote KM card
`docs/knowledge/top-rule-reads-own-match-with-match-family.md` (regenerated the derived `KNOWLEDGE_MAP.md`).

**Validation:** `mdbook build` EXIT 0 (cross-ref anchor verified from generated HTML); `perl -c perl/LinkedSpec.pm`
+ `perl -c -Iperl t/phase0_regression.t` clean; **phase0 964→965 green** (`1..965`, 0 `not ok`); doctrine driver
2/2 PASS (MEMORY-ARCH + KNOWLEDGE-MAP after regen); `bash tools/run_ci_local.sh` EXIT 0. Book variant-agnostic.

## 2026-06-23 — TOP-RULE-AS-NORMAL.3.1 — Rust forward-progress / consume-before-recurse termination guard (mirror of .2.1); split .3 (RUST)

**Scope:** Rust variant only — `rust/linkedspec-runtime/src/runtime.rs` + `rust/linkedspec-runtime/src/engine.rs`
+ 2 new integration-test locks. **No Perl/spec change** (phase0 stays 964/964). Splits `.3` into `.3.1` (this
slice) + `.3.2` (blocked). Book reconciliation stays owned by `.4`.

**Reproduce-first diagnosis (TOOLBOX, dump-don't-transcribe).** Drove the four Perl phase0 top-rule grammars
through the Rust pipeline (`parse_spec`→`validate`→`compile`→`Engine::execute`). Rust baseline: `cargo build`
clean, 242 tests green. Findings split the cross-variant gap into **two independent layers**:

| Grammar / input | Perl reference | Rust (before `.3.1`) | Layer |
|---|---|---|---|
| `top:: /a/ I{return(call(top))}` on `aaa` | `undef` (terminates) | **stack overflow → SIGABRT** | (a) termination |
| `top:: -> sexpr {…}` wrapper, `(a(b)c)` | `["a",["b"],"c"]` | `[[null],[null]]` | (b) value |
| `sexpr::`+`LX`, `(a(b)c)` / `(a) (b)` | `[["a",["b"],"c"]]` / `[["a"],["b"]]` | `[[null],[null]]` | (b) value |

Layer (b) is wrong **even for the standard body-recursion idiom**, so it is the **general recursive-grammar
parse gap** (atoms/`entry_text()` in nested dispatch, multi-slot `-> rule[1]` self-entry, accumulator), owned by
`RUST-PARITY` (recursive specs like Lispish are already deferred per `tests/corpus_oracle.rs`) — NOT a
top-rule-as-ordinary issue. Layer (a) is the genuinely top-rule-specific cross-variant obligation.

**Fix (layer a — `.3.1`).** Mirror the Perl `.2.1` `(rule,pos)` active-stack cutoff. Added
`recursion_active: HashSet<(String,usize)>` to `RuntimeContext` with `enter_recursion`/`exit_recursion`, and a
thin `Engine::execute_rule` guard wrapper around the renamed `execute_rule_inner`: re-entry at a `(label,pos)`
already active ⇒ return `undef` (cut); the frame is inserted on entry and removed on **both** the Ok and Err exit
paths (balanced; empty between parses). The seam is the Rust analogue of Perl's single
`SpecEntry::_build_runtime_handler` closure — every blind-call edge, action edge, and `call(rule)` helper passes
through it. Legitimate consume-before-recurse recursion advances `ctx.pos` before re-entry, so the cutoff never
fires for a terminating grammar.

**Validation.** A no-consume cycle now terminates cleanly and returns `[null]` — exactly Perl's `undef` wrapped
one level by the documented Perl↔Rust accumulator output-shape rule (`tests/corpus_oracle.rs`). Two new locks in
`tests/integration_test.rs`: `top_rule_as_normal_3_1_no_consume_recursion_terminates` (⇒ `[null]`, self-protecting
— a guard regression aborts the test process) and `top_rule_as_normal_3_1_consume_before_recurse_is_not_cut` (⇒
array; guard left legitimate recursion intact). **Full Rust suite 242→244 green** (integration 23→25; core/unit/
corpus unchanged); changed-lib clippy clean (no findings in `runtime.rs` / the added `engine.rs` wrapper;
pre-existing `clippy --tests` debt untouched). **phase0 964/964** + `bash tools/run_ci_local.sh` **EXIT 0** (Perl
untouched). KM card `top-rule-recursion-forward-progress-guard` updated with the Rust parity. `.3.2` records the
value gap and is `blocked` on `RUST-PARITY` recursive-grammar parity.

## 2026-06-23 — TOP-RULE-AS-NORMAL.2.2 — confirm top re-entry recursion works with the LX accumulator idiom (NO engine defect; engine frozen) + 1 phase0 lock; close .2 (TEST+DOC)

**Scope:** one new `t/phase0_regression.t` lock + task-tree/KM/live-docs. **No engine/spec change** — the
engine was already correct; ADR `0010`'s authorized engine change is NOT needed for the recursion value (only
`.2.1`'s termination guard was). Book documentation of the recursive-top-rule model is deferred to `.4`.

**TOOLBOX confirmation (`probe9.pl`, dump-don't-transcribe):** the reasoned fix-direction from the `.2.1`
discovery holds exactly. A recursive rule used directly AS the top rule parses with an `LX` accumulator-return:

| input | `sexpr::` + `LX { return(array_copy(a(items))) }` | BODY (`top:: -> sexpr {return(call(sexpr))}`) |
|---|---|---|
| `(a)` | `[["a"]]` | `["a"]` |
| `(a(b)c)` | `[["a",["b"],"c"]]` | `["a",["b"],"c"]` |
| `(a) (b)` | `[["a"],["b"]]` | `["a"]` |

**Root cause (why the bare `sexpr::` returned `null`):** the default-handler `while(1)` ends each no-match
iteration with `unless($minfo){ <lxcode> }`, and the default `lxcode` is `return undef`. When the recursive
rule is the entry rule, its OUTERMOST frame loops once more at EOF after the recursion consumes all input, hits
`return undef`, and discards its accumulator → `null`. Adding `LX` (the same accumulator-return any accumulating
top rule needs) returns the accumulator instead. The BODY wrapper `return`s on the first dispatch and never
loops to EOF.

**Conclusion:** top re-entry recursion already works as an ordinary recursive rule (ADR `0010`'s goal met by the
engine). TOP and BODY are intentionally different grammars — the `(a) (b)` case is decisive: TOP accumulates the
**sequence** of top-level forms (`[["a"],["b"]]`), BODY parses **one** form (`["a"]`) — so "make top re-entry
identical to a body rule" was a mis-framing, not a defect. The original `null` was the missing-`LX` authoring
case.

**Lock + verification:** added `top_rule_as_normal_recursion_with_lx_parses_sequence` (asserts
`(a(b)c)`→`[["a",["b"],"c"]]` and `(a) (b)`→`[["a"],["b"]]`). `perl -c` clean; **phase0 963→964 green**;
`bash tools/run_ci_local.sh` **EXIT 0** ("Result: PASS", 964 tests); zero regression. Marked `.2` + `.2.2`
`done`; updated KM card `top-rule-recursion-forward-progress-guard` with the resolution.

## 2026-06-23 — TOP-RULE-AS-NORMAL.2.1 — forward-progress / consume-before-recurse termination guard (SpecEntry runtime-handler closure) + 3 phase0 locks; split .2; discover the .2.2 top-recursion value gap (ENGINE, ADR 0010)

**Scope:** one engine file (`perl/LinkedSpec/SpecEntry.pm`) + three new `t/phase0_regression.t` locks +
task-tree/KM/live-docs. ADR `0010` authorizes the engine touch. **No spec/book change** (book reconciliation
is `.4`).

**TOOLBOX ground-truth first (scratchpad probes 1–7, no transcription):**
- `call_spec_handler_subst` showed `call(rule)` / `-> rule` lower to
  `&{$$descr{spec}{$rule}{handler}}($descr,$STRING,$minfo)` (`ActionIR/Contracts.pm:134`,
  `MethodLowering.pm:332`); `{handler}` is the `SpecEntry::_build_runtime_handler` closure
  (`SpecEntry.pm:438`). So **every cross-rule call + every recursion** flows through that ONE real-Perl
  closure — the ideal guard site. (`dump_parser_source` is a simplified standalone artifact
  `&{…{$rule}}` that does NOT match the runtime `…{$rule}{handler}` shape.)
- `LinkedRE::or`: seek `/(?{…})$re/gcp` scans forward to EOF→`undef`; consume `/\G(?{…})$re/gcp` is
  protected by Perl's repeated-zero-width-match prohibition + `/gc`. A fork+SIGKILL battery of
  zero-width/lookahead grammars (seek + consume) **never hangs** — the per-handler `while(1)` is already
  forward-progress-safe.
- The ONE reproduced engine hang: `top:: /a/ I { return(call(top)) }` — an unconditional no-consume
  self-tail-call (no match, no loop, empty dep-regex map) → OOM.

**Fix (`perl/LinkedSpec/SpecEntry.pm`):** a **(rule, pos) active-stack non-progress cutoff** in the
runtime-handler closure. A file-lexical `%__ls_recursion_active` keyed by `"$descr\0$label\0pos"`; if a
rule is re-entered at an input position already active on its own recursion stack, no input was consumed
since the enclosing entry — a non-progressing cycle — so the handler returns `undef`. Pushed on entry /
popped after the eval-wrapped invocation (balanced; empty between top-level parses, so no descriptor-shape
pollution). Legitimate consume-before-recurse recursion always advances `pos()` first, so the cutoff never
fires for a terminating grammar.

**Verification:** `perl -c` clean (SpecEntry.pm, LinkedSpec.pm, test); the E4 no-consume hang now returns
`null` (guard trace fires); consume-recursion grammars (probes 2/4/7) unchanged. **phase0 960 → 963** with
3 new locks (no-consume cycle terminates+undef; body S-expression recursion parses `(a(b)c)`→`["a",["b"],"c"]`;
top-recursion terminates). `bash tools/run_ci_local.sh` → **EXIT 0** ("Result: PASS", 963 tests). Zero
regression. New KM card `docs/knowledge/top-rule-recursion-forward-progress-guard.md`.

**Discovered (split `.2` → `.2.1` done + `.2.2` pending):** a recursive rule used directly AS the top/entry
rule returns `null`, while the IDENTICAL rule as a body rule (reached via a no-consume
`top:: -> sexpr {return(call(sexpr))}` wrapper) parses correctly — an **entry-alignment** divergence (who
consumes the leading token). The `.2.1` top-recursion lock pins TERMINATION only; the VALUE-correctness is
owned by `TOP-RULE-AS-NORMAL.2.2`.

## 2026-06-23 — TOP-RULE-AS-NORMAL.1 — own the lane + read-only investigation; ADR 0010 (authorize touching the Perl engine to treat the top rule as an ordinary rule entered first); supersede PHASE0-BACKHALF-TRIAGE.6 + close that tree (DOC-ONLY)

**No engine/spec/test/book code touched** — only `docs/decisions/0010-*.md` + `INDEX.md`, the new
`docs/tasks/TOP-RULE-AS-NORMAL.md` + the `docs/TASK_TREE.md` index, `docs/tasks/PHASE0-BACKHALF-TRIAGE.md`,
two KM fact cards (`docs/knowledge/`), and the live continuity docs.

A design conversation (off the `PHASE0-BACKHALF-TRIAGE.6` book `:AND` reconciliation) escalated: the user
reframed the top rule as **an ordinary rule that is merely entered first** (`::` = entry marker), with the
no-regex dispatch loop an **idiom, not a law**, and recursion into the top allowed under a
**consume-before-recurse** termination rule — then **authorized touching the Perl variant** to implement it.
Recorded in **ADR 0010** (a sanctioned, scoped exception to the engine-frozen doctrine, like 0008; cross-
variant parity required because the `.spec` file is the one universal contract).

Read-only investigation (`TOP-RULE-AS-NORMAL.1`, TOOLBOX probes — `LinkedSpec::Get`, `generate_only` +
`dump_parser_source`, codegen grep) corrected the model and narrowed the scope:
- The entry point is just `sub Get { &{$descr->{spec}{$top_rule}}($descr,$_[0]) }` (`Compiler.pm:1006`) —
  the top rule is **not** specially wrapped.
- `while(1)` is **mode-driven** (default/OR/REP repeat; `:AND` single-pass) in `HandlerVariantEmitter.pm`,
  **not** top-driven. The "top = dispatch loop" behavior is an emergent idiom (default-mode top + dispatch
  edges + `LX` accumulator).
- A regex on a top rule **already** compiles as a normal rule: `Pair::AND`+regex emits a standard AND
  handler — the earlier breakage was the AND-codegen defect already fixed (ADR 0008 / `.3`).
- Idiomatic recursion is body-rule + consume-before-recurse (`specs/Lispish.spec`), green; naive grammars
  recursing **back into the top rule** hang — the genuinely open dimension (top re-entry + termination).

So the authorized engine work is **narrower than it first looked**: confirm the {mode}×{regex}×{recursion}
matrix, enable/verify top re-entry recursion, add a forward-progress guard, lock with phase0 — then cross-
variant parity (`.3`) and the book reconciliation (`.4`, absorbing the superseded `.6`). The engine
implementation (`.2`) is signoff-critical codegen and is recommended for a fresh, sharp session.

Bookkeeping: `PHASE0-BACKHALF-TRIAGE.6` `superseded` by `TOP-RULE-AS-NORMAL`; `PHASE0-BACKHALF-TRIAGE` tree
flipped to `done` (`.1`–`.5` done, `.6` superseded) and moved to the Completed index; `TOP-RULE-AS-NORMAL`
added active (current focus). Two KM cards: new [[top-rule-is-ordinary-rule-entered-first]] (engine
mechanics) + corrected [[spec-top-rule-no-regex-two-rule-minimum]] (the stale `[]` claim was fixed by `.3`;
the doctrine is now recorded as idiom-not-law). Verification: doc-only — `scripts/check_memory_architecture.sh`
+ `scripts/check_doctrines.sh` green; KM map regenerates clean via the pre-commit hook; phase0 unaffected
(960/960). No engine/spec/test/book-behavior change.

## 2026-06-22 — PHASE0-BACKHALF-TRIAGE.5.3.2.2 — narrative-doc + book drift sync: ROADMAP_V2 + ARCHITECTURE_STATE + 2 mdBook files synced to the deleted/relocated module reality; close LEGACY-VHDL-RETIRE + NONCORE-QUARANTINE (DOC-ONLY)

**No engine/spec/test code touched** — only `ROADMAP_V2.md`, `ARCHITECTURE_STATE.md`, the two named mdBook files
(`docs/linkedspec-book/src/specs-and-corpora/shipped-specs-and-corpora.md`,
`docs/linkedspec-book/src/architecture/owner-tree.md`), the three downstream task trees, the task-tree index
(`docs/TASK_TREE.md`), and the live continuity docs.

The deferred `LEGACY-VHDL-RETIRE.5` body. Ground-truth-first: `git`/filesystem inspection (corroborated by an
Explore import-tree agent) pinned the real module state — `perl/RTLUtils.pm` / `perl/FSMGen.pm` /
`perl/VHDL/ConstantEval.pm` + 6 exclusively-dependent `.plg` were **deleted** (`06496b4`, `LEGACY-VHDL-RETIRE.2`);
the 12 remaining domain owners (`HTTP::FileAccess`, `HTML::PathLinks`, `InteractivePrompt`,
`Text::VariableSubstitution`, `MSOffice::Excel`, `QC::{Flow,Summary,TclInterconn}`, `Table::GenericFilter`,
`Timing::{SetupHold,StanBackend,StanOmap2430cBackend}`) + 13 `.plg` were **relocated to `noncore/`** (`336bded`
+ `2baddbd`, `NONCORE-QUARANTINE`); the root `plugin/` dir is gone and `perl/` is core-only; and
`generic_fake_memory_module.plg`/`wrapgen.plg` had already been deleted long ago (`cffac62`), so the
`ceil_log2`-caller prose was doubly stale.

Edits (guarded, content-anchored, match-count-asserted Perl transforms; full diffs reviewed):
- **`ARCHITECTURE_STATE.md`** — replaced the owner-migration bullet cluster, the "Project/domain utility owners"
  owner-tree block, the stale `PPlugin` FSMGen clause, and the `### Table::GenericFilter` + domain-owner migration
  prose with one accurate "deleted vs relocated-to-`noncore/`" account.
- **`ROADMAP_V2.md`** — replaced the 16 stale "Plugin modernization note" domain-owner bullets with one accurate
  bullet; appended a dated **Update** to the historical `done` plugin-modernization tracker cell (supersede,
  don't mutate — the milestone record stays, the current state is stated plainly).
- **mdBook `shipped-specs-and-corpora.md`** — `## plugin/` → `## noncore/plugin/`; fixed the two file-tree
  mentions + the two corpus-list bullets; dropped the now-removed `plugin` CI-input (matching `.5.3.1`'s
  `tools/run_ci_local.sh` change).
- **mdBook `architecture/owner-tree.md`** — replaced the package-extraction migration narrative with a concise
  current-state block; kept the facade/registry/bridge/PPlugin descriptions + the "healthier core story".

Verification: `mdbook build docs/linkedspec-book` EXIT 0; `git grep` confirms no deleted/relocated module is
presented as a live `perl/` owner (residual mentions are the new "Relocated to noncore/ / Deleted" lists, the
"stale prose is gone" explanatory sentences, or the dated historical tracker cell); book stays variant-agnostic;
phase0 still 960/960 (unaffected — doc-only). Flipped `LEGACY-VHDL-RETIRE.5` + `NONCORE-QUARANTINE.V` → `done`
(BOTH trees CLOSED; `NONCORE-QUARANTINE.N` deferred as an explicit Non-Goal); containers `.5.3.2`/`.5.3`/`.5`
→ `done`. **Frontier → `.6`** (book `:AND` — likely a short user policy check). `scripts/check_memory_architecture.sh`
+ `scripts/check_doctrines.sh` green.

## 2026-06-22 — PHASE0-BACKHALF-TRIAGE.5.3.2.1 — status & continuity reconciliation: flip the downstream gates now both phase0 and the full local gate are green (DOC-ONLY)

**No engine/spec/test/book code touched** — only task-tree ledgers (`docs/tasks/*.md`), the task-tree index
(`docs/TASK_TREE.md`), one KM fact card (`docs/knowledge/rtlutils-regex-hang.md`), and the live continuity docs.

Bootstrap-then-PNT: a thorough fresh-session resume (README → MEMORY_ARCHITECTURE → MEMORY → SESSION_BOOTSTRAP
→ COMMIT → TASK_TREE + the 5 downstream task trees + delegated `LinkedSpec.pm`-import-tree and mdBook analysis)
landed on the active frontier leaf `PHASE0-BACKHALF-TRIAGE.5.3.2`. Both `t/phase0_regression.t` (960/960) and the
full local gate (`bash tools/run_ci_local.sh` EXIT 0) are now green end-to-end, so the downstream blockers that
waited on a green phase0 can be cleared.

**Split.** `.5.3.2` spans 3 downstream trees + the index + a KM card + ~4 narrative/product docs (incl. 2 mdBook
files) + the live docs (~15 files), and the book/architecture drift is a distinct *pre-existing* concern (the
deferred `LEGACY-VHDL-RETIRE.5` body). Per COMMIT.md's "don't bundle unrelated changes," split → `.5.3.2.1`
(status & continuity reconciliation — this slice) + `.5.3.2.2` (narrative-doc + book drift sync — next).

**Flips (`.5.3.2.1`):**
- **`NONCORE-QUARANTINE.V`** — blocker (the ~173 back-half failures) CLEARED; `blocked`→`pending` (verification
  + downstream blocker clears recorded; the remaining doc/book/KM sync → `.5.3.2.2`, then `.V` is `done`).
- **`LEGACY-VHDL-RETIRE.4`** — `blocked`→`done` (RTLUtils hang cleared + full local gate green; the second
  back-half hang `HTML::PathLinks::link_path_tokens` at subtest 131 became *moot* — its smoke was excised when
  `NONCORE-QUARANTINE.3` relocated the module to `noncore/`). **`.5`** blocker cleared; `blocked`→`pending` (its
  narrative-doc + book drift body is `.5.3.2.2`).
- **`SPEC-FORMAT-TERSE`** — the implementation-gate blocker (usable `t/phase0_regression.t`) CLEARED; leaves
  `.1.x`+ are now PNT-eligible (NOT started here; migration policy already resolved = gradual-alias, ADR `0007`).
- **`docs/TASK_TREE.md`** index rows synced for all 4 trees.
- **KM card** `rtlutils-regex-hang.md` given a "Resolution" section + refreshed `evidence`/`reverify` (the
  back-half fix track is `PHASE0-BACKHALF-TRIAGE`; the subtest-131 smoke was excised by `NONCORE-QUARANTINE.3`).

**Verification:** doc-only — `scripts/check_memory_architecture.sh` + the doctrine driver `scripts/check_doctrines.sh`
(MEMORY-ARCH + KNOWLEDGE-MAP) green; KM map regenerated/staged by the pre-commit hook; a `grep` sweep confirms no
residual "blocked by phase0 / blocked by the 173 / not green" text remains in the task-tree ledgers. Book
unaffected (no public-surface change in this slice). **Next: `.5.3.2.2`** — the narrative-doc + book drift sync
(`ROADMAP_V2.md`/`ARCHITECTURE_STATE.md` owner-tree + 2 mdBook files; the
`generic_fake_memory_module.plg`/`wrapgen.plg`/`ceil_log2` drift), then flip `LEGACY-VHDL-RETIRE.5` +
`NONCORE-QUARANTINE.V` to `done`, then `.6` (book `:AND`).

## 2026-06-22 — PHASE0-BACKHALF-TRIAGE.5.3.1 — drop the stale `plugin/` reference in `tools/run_ci_local.sh`; the full local gate now passes green end-to-end

CI tooling only — **no engine/spec/production code touched** (only `tools/run_ci_local.sh` + task-tree/live docs).

Scoping `.5.3` (flip the downstream gates now that phase0 is green) surfaced that the "full local gate green"
acceptance was itself **RED**. `tools/run_ci_local.sh` is the **E4 source-of-truth gate** (hosted GitHub Actions
is disabled — ADR `0004` — so the local gate is authoritative). Running it confirmed it died at
`require_tracked_tree plugin` → `[ci] ERROR: required directory missing: plugin`, **EXIT 1, before phase0 even
ran**: `NONCORE-QUARANTINE.3` `git mv`'d the 13 `.plg` to `noncore/plugin/` and rmdir'd the top-level `plugin/`,
but left `plugin` in two of the gate's pathspec lists — the `require_tracked_tree` loop and the
`check_no_untracked_ci_inputs` git-status pathspec. This is the **same NONCORE-QUARANTINE leftover class** as the
test's stale plugin refs that `.5.1`/`.5.4` cleaned.

Because the remaining gate-flips span 3 trees + a doc/book/KM sync (too broad for one signoff slice), `.5.3` was
split → `.5.3.1` (this slice: make the full gate green) + `.5.3.2` (the status/doc/KM reconciliation, pending).

**Fix (`.5.3.1`):** removed `plugin` from both pathspec lists (left a rationale comment). The core gate stays
**core-only** — `plugin` is dropped, NOT retargeted to `noncore/plugin` (the `noncore/` tree is quarantined/parked,
not a core CI input), consistent with the `.5.1`/`.5.4` core-only precedent. The remaining required trees
(`specs conf tablescript ebnf perl t`) are all extant core/corpus inputs.

**Verification:** `bash -n tools/run_ci_local.sh` OK; **`bash tools/run_ci_local.sh` → EXIT 0 end-to-end** —
doctrine driver 2/2 PASS, tracked-input + machine-path audits pass, `perl -c perl/LinkedSpec.pm` +
`perl -c -Iperl t/phase0_regression.t` clean, RAM guard within threshold, and
`prove -v -Iperl t/phase0_regression.t` = `1..960` / `All tests successful` / `Files=1, Tests=960` (~198s) /
`Result: PASS`, ending `[ci] local CI gate passed`. Book unaffected (CI tooling, not a user surface).

This advances `NONCORE-QUARANTINE.V`'s "full local gate green" acceptance. Both the phase0 regression suite and
the full local gate are now green together for the first time. **Next: `.5.3.2`** — flip the downstream blocked
statuses + doc/KM sync across `NONCORE-QUARANTINE.V`, `LEGACY-VHDL-RETIRE.4/.5`, and the `SPEC-FORMAT-TERSE`
implementation gate — then `.6` (book `:AND`).

## 2026-06-22 — PHASE0-BACKHALF-TRIAGE.5.4 — re-bless the 3 dark-tail failures (TEST-ONLY); `t/phase0_regression.t` is now fully GREEN end-to-end (960/960)

User directive: bootstrap thoroughly (roadmap + codebase + mdBook) then continue the active frontier. **No
engine/spec/production code touched** — only `t/phase0_regression.t` (the 3 re-blesses) + the task-tree/live docs.

This closes the green-phase0 goal of `.5`: the back half of `t/phase0_regression.t` — dark for a long time
behind the `RTLUTILS-REGEX-HANG`, the legacy-island hangs, the plugin `opendir` die (`.5.1`), and the Lispish
multi-parse spin (`.5.2`) — now runs to completion **green: 960/960 ok, EXIT 0, plan `1..960` reached** for the
first time ever.

Driven **ground-truth-first per `TOOLBOX.md` Protocol A** — every got-value was *dumped* via `LinkedSpec::Get`,
never transcribed from the triage note:
- **952** `parse_mode_default_and_explicit_seek_preserve_progressive_matching` (line 43355) and **953**
  `parse_mode_consume_requires_contiguous_match` (line 43383): both use the non-idiomatic
  `Top:: /a/ -> Top { return(1) }`. Dumps: 952 default+seek on `xxa` → `CODE\n$VAR1 = 1;\n`; 953 consume on
  `a` → `CODE\n$VAR1 = 1;\n`, consume on `xxa` → `CODE\n__AST_UNDEF__\n` (reject unchanged). `return(1)` now
  resolves to a plain scalar `1` (the cluster-A/G class — KM `phase0`/`return(1)→scalar 1`), so the retired
  tagged `?Top:` shape never appears. Re-blessed `like(…, qr/\?Top:/)` → `like(…, qr/\$VAR1 = 1;/)`; 952's
  message clarified ("…(returns the matched value)") since the seek-forward proof is now the *defined* matched
  value vs consume's `__AST_UNDEF__`.
- **960** `plugin_bridge_dispatch_calls_mechanically_gated_in_plg_corpus`: another stale
  `discover_dir_files_by_suffix($Bin/../plugin, '.plg')` → `opendir '../plugin' or die` (the 13 `.plg` were
  `git mv`'d to `noncore/plugin/` by `NONCORE-QUARANTINE.3`) — the **same class as `.5.1`**. Following the
  `.5.1` precedent (the core regression gate stays core-only and does not reach into `noncore/`), rewrote the
  subtest to drop the 4 `.plg`-corpus assertions (the `opendir` census + the
  `get_plugin`/`run_plugin`/`dispatch_plugin_autoload_name` source scans) and keep the core-relevant
  `like($PluginBridge.pm, qr/Compatibility bridge/i)` guarantee (plan `5`→`1`, with a rationale comment).
  Confirmed `PluginBridge.pm:3` still carries "Compatibility bridge".

**Verification:** `perl -c -Iperl t/phase0_regression.t` OK; **before**-run = 957 ok / 3 not-ok (failing set =
exactly {952,953,960}, reach `not ok 960`, exit-255 — 960's `opendir` die aborted before `done_testing`);
**after**-run = **960 ok / 0 not-ok, EXIT 0, reach `ok 960`, plan `1..960` reached** (`done_testing` now seen);
`comm` name set-diff = **exactly the 3 cleared, new-failure set empty**. self-check + KM gate via the doctrine
driver. **Book unaffected** — parse_mode seek/consume behavior is unchanged (only the non-idiomatic
regression-test's expected AST shape changed), and the book teaches parse modes via the 2-rule idiom, not this
form; the 960 inspection is internal test infra.

**Unblocks the downstream chain:** the green-phase0 condition gating `SPEC-FORMAT-TERSE`,
`LEGACY-VHDL-RETIRE.4/.5`, and `NONCORE-QUARANTINE.V` is now satisfied. The gate-flip work is owned by `.5.3`
(now PNT-eligible), then `.6` (book `:AND` reconciliation).

## 2026-06-22 — PHASE0-BACKHALF-TRIAGE.5.2 — fix the Lispish corpus_regression hang (never-undef parser + unguarded multi-parse loop; forward-progress guard, TEST-ONLY)

User chose "investigate + fix". **No engine/spec/production code touched** — only `t/phase0_regression.t`
(one guard line) + the corrected KM card.

**Root cause CORRECTED by measurement — it is NOT a regex** (the earlier "catastrophic backtracking"
hypothesis is disproved). Dogfooding `TOOLBOX.md`: (1) input bisection — a *single* parse of the full
392-byte `ambitiming.conf` = **0.03s**, no backtracking; (2) loop instrumentation — `iter1 pos 0→350
(def)`, then `iter2.. pos 350→350 (+0, def)` forever, the stuck call re-returning form 1's exact AST;
(3) generalized — single-form `(rise_o_fall…)` at EOF and `(R rise)\n\n` both return defined + zero
advance. So **the Lispish parser never returns `undef`**: on any no-progress/EOF call it re-returns the
previous form's AST with `pos()` unchanged. `parse_with_lispish_multi`'s `while(1){ … last unless
defined $ast }` therefore spun to its 100000-iteration cap (~0.002s × 100000 ≈ 3 min/file × 76
conf/tablescript files = the multi-CPU-hour "hang"). `ebnf` was healthy only because it uses the
single-call probe, not the loop.

**Fix (TEST-ONLY):** added the missing streaming-loop invariant — a **forward-progress guard** to
`parse_with_lispish_multi` (`last if pos_after <= pos_before`): stop the stream the moment a call
consumes no input. **Measured: all 76 conf+tablescript files parse ok, 0 hang.** A full foreground
`perl -Iperl t/phase0_regression.t` (10-min budget — note `run_in_background` is killed at ~120s, never
reaching the corpus tail) now reaches **subtest 960** with **`ok 941 - corpus_regression`** (vs the old
exit-255 death at 941). The KM card `lispish-corpus-catastrophic-backtracking.md` was corrected (title +
body + reverify) from the wrong "catastrophic regex" framing to the real never-undef/unguarded-loop cause.

The deeper **parser-contract** defect (the parser should return `undef` at EOF) and the **grammar gap**
(the `Lispish::` top rule doesn't skip top-level inter-form whitespace, so a multi-form file parses only
its first form — ambitiming's 2nd form `rise_o_fall` is dropped) are engine/spec follow-ons with
cross-variant implications — not needed for the corpus smoke test, documented in the KM card.

**Running past corpus_regression for the first time revealed 3 TEST-ONLY dark-tail failures** (subtests
942–960), now owned by `.5.4`: **960** `plugin_bridge_dispatch_calls_mechanically_gated_in_plg_corpus`
is another stale `opendir '../plugin'` die (the `.plg` corpus moved to `noncore/` — same class as `.5.1`);
**952/953** `parse_mode_*` assert the retired `?Top:` tagged shape but `Top:: /a/ -> Top { return(1) }`
now returns scalar `1` (the cluster-A/G class). All re-bless-only; green phase0 is one slice away.

## 2026-06-22 — DOCTRINE-ENFORCEMENT-ADOPT.1+.2 — adopt the portable Doctrine-Enforcement architecture (driver+registry+gates) + a LinkedSpec TOOLBOX.md

User directive: adopt `DOCTRINE_ENFORCEMENT.md` (the 4th portable architecture, sibling of
`MEMORY_ARCHITECTURE.md` + the Knowledge Map) and add a `TOOLBOX.md` of LinkedSpec's **own** debug tools
(reinforced: "TOOLBOX.md should contain LinkedSpec own debug tools"). Landed `.1`+`.2` atomically (they
are mutually referential). No engine/spec/production code touched — tooling + docs only.

- **`TOOLBOX.md`** — LinkedSpec's own diagnostic/debug catalog, foregrounding the project's own tools:
  §1 facade probes (`LinkedSpec::Get`, `get_parser`, `call_spec_handler_subst`, `build_compiled_rule_table`);
  §2 introspection options (`return_descriptor`, `dump_parser_source`/`parser_source_ref`, `parse_only`/
  `generate_only`, `return_state`, `runtime_ctx_ref`, `parse_mode`/`top_rule`); §3 the
  `LINKEDSPEC_TRACE_LEVEL` trace framework (+ env knobs + the `configure_trace`/`trace_*` API); §4 the
  `tools/*` scripts (`inspect_spec_codegen.pl`, `cross_check_spec_parsers.pl`, `gen_oracle_corpus.pl`,
  `run_ci_local.sh`, `ram_guard.sh`); §5 the gates + Knowledge-Map grep. General supporting techniques
  (`comm` set-diff, focused-`Test::More` harness, fork+SIGKILL census, `perl -c`, the `PERL5LIB`/`-Iperl`
  hazard) are demoted to §6. Every tool/option name was verified against `perl/` (not guessed). Also
  carries the task-acceptance checklist template, a symptom→tool chooser, and three diagnosis protocols.
- **`scripts/check_doctrines.sh`** — the registry+driver: runs every registered `check_*.sh`, reports
  per-doctrine PASS/FAIL, exits nonzero on any breach, and meta-checks that each registered enforcer
  exists + is executable. Registry = `MEMORY-ARCH` (`scripts/check_memory_architecture.sh`) +
  `KNOWLEDGE-MAP` (`knowledge-map/scripts/check_knowledge_map.sh`) — the two existing structural checks,
  so the driver is honest and green from day one (2/2 PASS).
- **`.githooks/pre-commit`** rewritten to regenerate+stage the derived Knowledge Map, then call the
  driver (replacing the direct two-check stack). **`tools/run_ci_local.sh`** (E4) now calls the driver too
  and audits the new files as tracked CI inputs. `commit-msg` (work-unit-id) unchanged.
- **`DOCTRINE_ENFORCEMENT.md`** at the repo root — the standard, with §10 = the LinkedSpec instance and an
  honest E4 note (hosted CI disabled per ADR `0004`; the local gate is the source of truth).
- **Discovery (E1):** `README.md`, `AGENTS.md`, `CLAUDE.md` now name `DOCTRINE_ENFORCEMENT.md` + `TOOLBOX.md`
  (toolbox-first when debugging). **ADR `0009`** records the adoption (+ INDEX row).
- **Deferred (`.3`):** a `check_diagnosis_evidence.sh`-style EVIDENCE/task-acceptance hard-gate — its
  change-scope globs + tool-output signature regexes need careful project-specific design.

**Verification:** `bash scripts/check_doctrines.sh` → exit 0 (2/2 PASS); `bash -n` clean on
`.githooks/pre-commit` + `tools/run_ci_local.sh`; Knowledge Map in sync; the commit itself exercised the
rewired pre-commit hook (regenerate-and-stage KM + driver) green. (The full `tools/run_ci_local.sh` is
separately blocked by the pre-existing `PHASE0-BACKHALF-TRIAGE.5.2` corpus hang — not introduced here.)

## 2026-06-22 — PHASE0-BACKHALF-TRIAGE.5.1 — remove stale corpus_regression plugin dataset (TEST-ONLY); exposes .5.2 (Lispish corpus catastrophic backtracking)

`.5` ("green-phase0 verification + gate flips") **split**; `.5.1` done. **No engine/spec/production code
touched** — only `t/phase0_regression.t` (one dataset removed from `corpus_regression`) + docs/KM.

**The determination `.5` asked for:** subtest-941 `corpus_regression` ("No tests run", exit-255) is a
**real stale reference, NOT a natural-stop boundary.** `corpus_regression` runs 4 datasets in order;
dataset #1 (`plugin_plg_via_pplugin_spec`) `opendir`s `../plugin`, which `NONCORE-QUARANTINE.3` removed
(it `git mv`'d the 13 `.plg` to `noncore/plugin/` and rmdir'd `plugin/`) but left the dataset behind.
`discover_dir_files_by_suffix` does `opendir … or die`, so the subtest dies before any assertion → "No
tests run" + exit-255, **aborting the whole run at 941** (so the trace subtests 942-959 never ran). Every
prior session's "clean exit-255 corpus stop" was this death masking the rest of the subtest.

**Fix (TEST-ONLY):** removed the non-core `.plg` dataset from `corpus_regression`'s `@datasets` (the core
regression gate stays core-only and does not reach into `noncore/`; `plan tests` auto-adjusts 8→6), with a
rationale comment so it isn't re-added. The surviving datasets are conf/tablescript (via Lispish) + ebnf.

**This EXPOSED a real blocker (`.5.2`, green-phase0).** Re-running advanced *into* `corpus_regression`
and hung: a full `perl -Iperl t/phase0_regression.t` burned **374 CPU-min** (~100% CPU) stuck on the
first conf file. A fork+SIGKILL census (note: `alarm()` cannot interrupt a single C-level regex match)
hard-killed **~21/22 conf files (≈100%)** at 6s each — the **Lispish** parse of the conf/tablescript
corpus **catastrophically backtracks**. `ambitiming.conf` is **392 bytes**, so it's a ReDoS-style regex
in the Lispish spec/generated parser, not an input-size issue. The **`ebnf` dataset is healthy** (7 files,
0.1-0.6s). Long-masked behind the subtest-110 RTLUtils hang, then the plugin `opendir` death. Captured in
KM card `lispish-corpus-catastrophic-backtracking.md`. `.5.2` is **blocked on a user direction decision**
(quarantine the Lispish corpus datasets vs fix the regex vs add a hard-timeout guard).

**Also found:** a stale `PERL5LIB=…/pgen/fx/perl` in the shell points at a different, older checkout, so a
bare `use LinkedSpec` loads the wrong module — ad-hoc probes must use `perl -Iperl` (the tests already do).

**Verification:** `perl -c -Iperl t/phase0_regression.t` OK; baseline full run confirmed subtests 1-940
green + the `Cannot open directory '.../plugin'` die at 941; post-fix re-run + the corpus census established
`.5.2`; ebnf hard-timeout check (7/7 ok). phase0 **NOT green** (blocked by `.5.2`). Self-check + KM gate
pass. Book unaffected (`corpus_regression` is internal test infra; grep confirms no book reference).

## 2026-06-22 — PHASE0-BACKHALF-TRIAGE.2.4 — re-bless cluster F+G (5, TEST-ONLY); 5 phase0 failures cleared, zero regressions (cluster .2 complete)

Closes cluster `.2` (the 108 STALE re-blesses). **No engine/spec/production code touched** — only
`t/phase0_regression.t`. Driven ground-truth-first: a probe dumped every changed assertion's current value
before editing.

- **G ×2** (`bootstrap_registry_curly_brace_recursion_smoke`, `get_avoids_runtime_run_get_from_args_wrapper`):
  `return(1)` now lowers to a plain resolved `return 1`, so a single-top-rule parser returns scalar `1`
  rather than an array — re-blessed `ok(defined($ast) && ref($ast) eq 'ARRAY')` → `is($ast, 1, …)`.
- **F ×3** are migration-summary corpus aggregates. Two of them
  (`return_descriptor_exposes_action_rewriter_migration_summary`,
  `…migration_blocker_type_breakdown`) used `return(1)` to stand in for *unresolved-helper-blocked* rules
  under the retired-`return_a` model; since `return(1)` is now resolved/ready, those rules flipped ready
  and cascaded the ready/blocked counts, ratios, ready/blocked lists, and the raw-only/unresolved-only/mixed
  breakdown. **Restored** the corpus rules to genuinely-unresolved forms (`return(Leaf, $x)`; mixed =
  `return(Leaf, $x); my $tmp = 2`) so the original category coverage — and the original assertions — hold
  (migration_summary: 1 spec edit + 1 blocker-payload re-bless; blocker_type_breakdown: 2 spec edits, 0
  assertion changes).
- The third F test (`compatibility_surface_metadata_includes_legacy_helper_wrappers`) had an **obsolete
  premise**: it asserted the retired method-helpers `return_m`/`return_a` stay "ready compatibility
  surface", but those are now `RAW_PERL` (blocking, not ready compat). **Adapted** it to the still-live
  compat helpers (consistent with the test's intent): `Top` `return_m(Top)` → `return(a("?Top:"))`
  (canonical-ready, keeping `assign_call_my` + `capture_if` as the tracked compat surface); `Leaf`
  `return(1)` → bare `return 1` (`return_bare` compat); re-blessed the contract-id lists
  (`['assign_call_my','capture_if','return_m']`→`['assign_call_my','capture_if']`; Leaf `['return_a']`→
  `['return_bare']`), the per-rule statement count (3→2), and the "tagged-return"→"bare-return"
  descriptions.

**Verification:** `perl -c` OK; a load-independent focused Test::More harness ran all 5 = 5/5 pass; full
`perl -Iperl t/phase0_regression.t` + `comm` name set-diff vs the post-`.2.3` baseline = exactly the 5 F/G
cleared (phase0 **6 → 1**), new-failure set empty — the only remaining failing subtest is the
`corpus_regression` natural-stop tail (the suite's exit-255 boundary, owned by `.5`). Cluster `.2` is now
complete; the front 940 subtests are green. Book unaffected (internal IR-node / metadata test surfaces).

## 2026-06-22 — PHASE0-BACKHALF-TRIAGE.2.3 — re-bless/rewrite cluster C `emit_context` (20, TEST-ONLY); 20 phase0 failures cleared, zero regressions

Cluster C. **No engine/spec/production code touched** — only `t/phase0_regression.t`. All 20 failing
`emit_context` white-box subtests traced to the retired `return_a`/`return_imatch`/`return_array` helpers
plus the `return(1)`-as-accumulator model that the engine now lowers to a plain resolved `return 1`
(canonical node `RETURN`, contract `return_general`, language-agnostic-ready). Driven ground-truth-first:
one comprehensive probe (`LinkedSpec::Get` / `call_spec_handler_subst` / `EmitContext::*`) dumped the
current value of **every** changed assertion before editing.

- **`return(1)` → `return 1`** (resolved): re-blessed the deps-builder accumulator expecteds
  `return ['?Top:', \@Top]`→`return 1` and `['RETURN_A']`→`['RETURN']` (scanner / canonical_event /
  rewrite_pipeline), the require-subprocess rewrite-pipeline payload, and the `canonical_ir_lowering`
  push/return output.
- **retired-helper passthrough:** `return_imatch(...)`/`return_array(...)` return unchanged (facade-lowering
  subtest 12468/12469 re-blessed to passthrough + accurate descriptions).
- **`a(IMATCH)` ⇒ `[IMATCH]`** (15843, the mis-authored `@IMATCH`).
- **two stale plan off-by-ones** (`pipeline_helper_substitutions` 89→88; `lowers_method_contracts`
  80→79) — confirmed exactly that many real assertions run (no masked failure).
- **removed seam:** `_lower_return_array_statement` no longer exists in `EmitContext`, so the
  `method_lowering` deps-builder probe + its 2 asserts were dropped (plan 8→6).
- **diagnostics counting:** `_find_unresolved_action_helpers` inputs `return(1)`→`return_a(1)` (deps +
  require versions) so the counter still meaningfully finds 2; `_parse_method_function_expr('return(1)')`
  args re-blessed `'Top'`→`'1'`.
- **descriptor-meta semantic re-bless:** `RETURN_A`→`RETURN` node/event/hit + `return_a` contract →
  `return_general`/`return` across `helper_action_ir_nodes` / `canonical_action_ir_with_raw_fallback` /
  `payload_events` / `nested_semicolon`; `reports_unresolved` now reflects only the genuine label-mismatch
  `return` helper. **Three subtests whose assertions referenced an expression payload/label/nested-semicolon
  that the degenerate `return(1)` spec could not produce had their spec return forms restored** to
  `return(Top, $x + 1)` (payload_events, canonical_with_raw) and `return(do { my $x = 1; $x })`
  (nested_semicolon), and the `Unresolved`/`Combo` rules to `return(Leaf, $x)` (readiness, blocker) —
  preserving each test's original coverage intent rather than degrading it.

**Decision:** kept the harmless dead `LinkedSpec::Deps::*` traps in the deps-builder subtests (the
package was removed; the "Deps stays unloaded" guarantee is independently covered by
`emit_context_require_avoids_linkedspec_deps_load`, and removing the traps only from failing siblings
would split the family). A consistent dead-trap sweep across all 13 deps-builder siblings is deferred as
optional test hygiene (task-tree Open Questions).

**Verification:** `perl -c` OK; the after-run cleared the 11 cluster-C subtests at subtest ≤803 with zero
regressions in subtests 1–803; a load-independent focused Test::More harness re-ran the 9 late meta/nested
subtests (804–857) = 9/9 pass; the authoritative low-load full `perl -Iperl t/phase0_regression.t` +
`comm` name set-diff = exactly the 20 cluster-C cleared (phase0 **26 → 6**), new-failure set empty. The
first two full runs were SIGALRM-killed at the corpus tail by a transient external `rustc`/`nexsim_core`
build (system-load ~29) — the documented truncated-TAP false-cleared hazard; a clean low-load re-run gave
the authoritative diff. Remaining 6 = 5 cluster F/G (`.2.4`) + 1 `corpus_regression` tail (`.5`). Book
unaffected (internal IR-node test names, not a user surface).

## 2026-06-21 — PHASE0-BACKHALF-TRIAGE.2.2.2.2 — re-bless cluster B1-accumulator (4 `return_a`/`return_m`, TEST-ONLY); 4 phase0 failures cleared, zero regressions

Closed cluster B1 (`.2.2.2`). **No engine/spec/production code touched** — only `t/phase0_regression.t`.
The 4 failing subtests used the *retired* `return_a`/`return_m` helpers (→ `RAW_PERL` fallback). This was
the recon's *highest-risk* leaf (per-test judgment), so it was driven ground-truth-first: a pre-flight
probe replicated **every assertion of all 4 subtests** via `LinkedSpec::Get` before any edit.

- **Empirical findings:** (a) chained `.return_a().return_m()` and block `{ return(1); return_m(Top) }` both
  fall to `RAW_PERL` — the failure cause; (b) `RETURN_A`/`RETURN_M` are retired into a single canonical
  `RETURN` node, so subtest-1's distinct-node asserts test a dead feature; (c) the canonical chain
  `.return(1).return(array("?Top:", entry_groups()))` lowers **identically** to block
  `{ return(1); return(array("?Top:", entry_groups())) }` (`fallback=0`, `ready=1`,
  `nodes=[IMATCH_GROUPS_READ, RETURN]`, `hits={IMATCH_GROUPS_READ=>1, RETURN=>2}`); (d) blind-call fluent
  `.return(1)` produces byte-identical BCODE to block `{ return(1) }`.
- **Rewrites (8 lines, 4 subtests):** `.return_a().return_m()` → `.return(1).return(array("?Top:", entry_groups()))`
  (×3, replace_all — exactly 3 file-wide, all targets); block `return_m(Top)` → `return(array("?Top:", entry_groups()))`
  (×2, **line-scoped** — `return_m(Top)` is 3× file-wide but @39745 is a *passing* non-target, excluded);
  blind-call `.return_a()` → `.return(1)` (@6342); subtest-1's two `grep RETURN_A`/`grep RETURN_M` node
  asserts re-blessed to `grep RETURN` + `is(hits{RETURN}, 2)` (the distinct-variant feature is retired).
- **Scope:** the 4 *passing* `return_a(pipe_operator)` sites, `return_imatch`@12436 (→`.2.3`), and the
  negative source-assert @41730 all untouched.
- **Verification:** `perl -c -Iperl t/phase0_regression.t` OK; pre-flight assertion-replication → all PASS
  (plan counts unchanged); full `perl -Iperl t/phase0_regression.t` (complete TAP to the corpus tail)
  **30 → 26 failing**; `comm` name set-diff = **exactly the 4 cleared, new-failure set empty**. The gate was
  briefly unrunnable due to **external** CPU contention (an unrelated `cargo`/`rustc` build pushed system load
  to 32, exceeding the 10-min runner cap → SIGALRM-kill mid-run); a fresh low-load run gave the clean diff.
  Remaining 26 = 20 `emit_context` (`.2.3`) + 5 F/G (`.2.4`) + 1 `corpus_regression` tail (`.5`). self-check
  + KM gate pass. **Book unaffected** (internal IR-node names). **Next: `.2.3`.**

## 2026-06-21 — PHASE0-BACKHALF-TRIAGE.2.2.2.1 — re-bless cluster B1-array (33 `return_array`→`return(array(...))`, TEST-ONLY); 17 phase0 failures cleared, zero regressions

Executed the recorded `.2.2.2.1` plan. **No engine/spec/production code touched** — only `t/phase0_regression.t`.
The 17 failing B1-array `method_like*` subtests carried the *retired* `return_array(...)` helper in their spec
bodies (→ `RAW_PERL` fallback ⇒ `fallback_count>0`/stale `RETURN_A`), so their `fallback==0`/`ready`/hit-hash
assertions failed.

- **Rewrite (verified, matching-paren-aware):** `return_array(<Top,> semantic_annotation, X)` →
  `return(array("semantic_annotation", X))` — drops the `Top` label only on the L16601 `call_spec_handler_subst`
  arg, quotes the leading bareword, inserts exactly one matching close paren (`return(array(` opens 2 vs
  `return_array(`'s 1). Applied **identically to fluent + block** specs across 4 syntactic forms
  (`.return_array` tail / `; return_array }` / bare line / inline `if(...)`-arg) + the subst-arg.
- **Guarded line-scoped transform:** scoped to the 17 failing-subtest line-ranges only — **`return_array` is
  74× file-wide and byte-identical across failing + 40 passing switch-case subtests, so a global replace would
  have corrupted the passing ones.** The transform asserts `rewrites == in-range occurrence count` (**33**, not
  the recon's "34" — off by one) **and** file-wide `return_array(` delta == rewrites, dies-before-write on any
  drift; the full dry-run diff was inspected before applying.
- **Recon correction (caught by reading the test bodies):** the 2 BOTH subtests
  (`…lifecycle_inline_composite_switch_attached_branch_blocks` @17289,
  `…full_lifecycle_inline_composite_switch_attached_branch_blocks` @20105) do **not** "pin no literal output" —
  each pins a literal `canonical_action_ir_hits` hash carrying the now-stale `RETURN_A => 1`. That was the
  deferred `.2.2.1` Form-B merge, done here: `RETURN 2→3`, `RETURN_A` removed — **empirically dumped**
  (`{…RETURN=>3…}`, `fallback=0`, `ready=1`, tag-independent I==LX) before writing, not assumed. L16601's pinned
  `is(...)` expected confirmed unchanged-and-canonical via `call_spec_handler_subst`.
- **Verification:** `perl -c -Iperl t/phase0_regression.t` OK; `perl -c perl/LinkedSpec.pm` OK; full
  `perl -Iperl t/phase0_regression.t` **47 → 30 failing**; `comm` name set-diff vs baseline = **exactly the 17
  B1-array subtests cleared (incl. both BOTH), new-failure set empty**. Remaining 30 = `.2.2.2.2` (4
  `return_a`/`return_m` + blind_call) + `.2.3` (`emit_context`) + `.2.4` (F/G) + `.5` (`corpus_regression` tail).
  self-check + KM gate pass. **Book unaffected** (internal IR-node names, not a user surface). **Next: `.2.2.2.2`.**

## 2026-06-21 — PHASE0-BACKHALF-TRIAGE.2.2.2.1 (recon) — scope + verified rewrite rule for the B1-array leaf; no test change

Read-only pre-implementation recon of the `.2.2.2.1` leaf (17 `return_array` subtests), recorded so the
implementation runs mechanically. **No code change** — task-tree/MEMORY only.

- **Critical scope hazard found:** `return_array` appears **74× in `t/phase0_regression.t` = 34 in failing
  subtests / 40 in PASSING subtests**, and the spec-body strings (`return_array(semantic_annotation,
  hash("items", array(events)))`) are **byte-identical across failing and passing** switch-case families. So
  the rewrite **must be line-scoped to the 17 B1-array subtest ranges — a global replace would corrupt 40
  passing subtests.** One "failing" occurrence (~L12440) is actually a cluster-C `emit_context` site →
  belongs to `.2.3`, excluded. Net targets: 33 spec-body + 1 subst-arg (L16601).
- **Forms (verified):** 9× `.return_array(…)` fluent-tail, 9× `; return_array(…) }` block-tail, 10× bare
  line, 5× `if(…)`-mixed, 1× `call_spec_handler_subst` arg.
- **Verified rewrite (empirical `LinkedSpec::Get`):** `return_array(semantic_annotation, X)` →
  `return(array("semantic_annotation", X))` yields `fallback_count=0` / `raw_perl_dependency_count=0` /
  `ready=1` with fluent `ACODE`==block `ACODE` and equal node coverage. These spec-body subtests pin **no
  literal output** (only fluent==block + fallback==0 + ready), so the rewrite is shape-agnostic — apply it
  identically to fluent+block; `return(array(` needs one extra closing paren vs `return_array(`.
- Full execution plan written into the `.2.2.2.1` task node. `perl -c` OK (no test change); phase0
  unchanged at 47. A **fresh session** is recommended for the multi-form paren-level surgery.

## 2026-06-21 — PHASE0-BACKHALF-TRIAGE.2.2.2 — split cluster B1 into `.2.2.2.1` (return_array) + `.2.2.2.2` (return_a/return_m) — decomposition slice, no test change

Decomposed the judgment-heavy cluster-B1 leaf (21 retired-helper subtests) before implementation, after a
read-only recon and an archaeology pass. **No test/engine/spec code changed** — this slice is task-tree
decomposition plus a durable Knowledge Map fact card.

- **Recon (read-only):** mapped all 21 failing B1 subtests by the retired helper in their spec body —
  **17 use `return_array`** (incl. 2 of the 3 BOTH: `@17289`, `@20105`) and **4 use `return_a`/`return_m`**
  (incl. the 3rd BOTH `method_like_action_chain_parses_into_multiple_helper_events` + the re-bucketed
  `blind_call_fluent_post_call_chain_matches_block_form`).
- **Archaeology (verified):** recovered the original pre-retirement lowering of all six retired helpers
  (`return_a`/`return_m`/`return_ma`/`return_imatch`/`return_im`/`return_array`) from the
  COMPAT-ALIAS-RETIREMENT-V2.2 diff (commit `4e92503`) and **empirically confirmed** each canonical rewrite
  via `call_spec_handler_subst` probes. Key finding distinguishing the two families' blast radius:
  - `return_array(L, e1, e2, …)` is a **pure alias** — the first arg `L` is the rule label and is *dropped*,
    barewords are auto-quoted, and the output equals canonical `return(array(e1, e2, …))`. So the array
    family is mostly an **input-string rewrite** with the expected often already canonical.
  - `return_a`/`return_m`/`return_ma` add a `"?L:"` tag plus `array_copy(array(L))` (accumulator snapshot)
    / `entry_groups()` (`@IMATCH_LIST`) / `entry_text()` (`$IMATCH`) — these **change the dumped shape**, so
    their dependent `is_deeply` / node-coverage assertions must be re-dumped and re-blessed. `imatch()` /
    `imatch_list()` are NOT valid canonical helpers (they too pass through to `RAW_PERL`).
- **Decomposition:** `.2.2.2` → `.2.2.2.1` (17 `return_array` subtests — input-rewrite, mechanical-ish) +
  `.2.2.2.2` (4 `return_a`/`return_m` subtests incl. the 3rd BOTH — re-dump + re-bless + per-test
  retire-vs-rebless judgment).
- **Durable capture:** new KM card `docs/knowledge/retired-return-helpers-canonical-rewrite.md` records the
  verified per-helper mappings + pitfalls so the rewrite is never re-derived.
- **Validation:** no code change → phase0 unchanged at 47 failing; `perl -c -Iperl t/phase0_regression.t`
  OK; memory-architecture self-check + Knowledge-Map gate pass.

## 2026-06-21 — PHASE0-BACKHALF-TRIAGE.2.2.1 — re-bless cluster B2 (55 `method_like` `RETURN_A`→`RETURN`, TEST-ONLY) — 55 phase0 failures cleared

Re-blessed the cluster-B2 `method_like*` stale subtests in `t/phase0_regression.t`. **No engine, spec, or
production code touched** — only `t/phase0_regression.t`. These subtests hard-coded the *retired*
canonical action-IR node `RETURN_A` (return-accumulator) in their assertions; the current engine renames
that node to **`RETURN`** (COMPAT-ALIAS-RETIREMENT-V2; see KM `actionir-return-node-retired-to-return`),
so the assertions were stale, not the engine.

- **Two edit forms (one guarded one-pass transform):**
  - **Form A — 52 membership-grep flips:** `scalar(grep { $_ eq 'RETURN_A' } @{$X->{canonical_action_ir_nodes}})`
    (X ∈ `attached_meta`/`marker_meta`/`meta`) → `'RETURN'`. The node is still produced, just renamed.
  - **Form B — 19 hit-count-hash merges:** each failing `canonical_action_ir_hits` literal carried both
    `RETURN => M` and an adjacent `RETURN_A => 1`; since `RETURN_A` retired *into* `RETURN`, the counts
    **merge** to `RETURN => M+1` and the `RETURN_A` key is deleted — never two colliding `RETURN` keys (a
    naive `s/RETURN_A/RETURN/` would have produced `{RETURN=>M, RETURN=>1}` → wrong count).
  - **2 stale description strings** (`…DECLARE/ASSIGN/RETURN/RETURN_A helper mix` → `…RETURN helper mix`).
- **Guarded transform:** the one-pass script asserts every target's exact shape before writing (Form-A
  occurrence count must equal exactly 52; each Form-B `RETURN_A => 1` must sit directly below a
  `RETURN => N` line) and aborts without writing on any drift — so a 71-site bulk edit is signoff-safe.
- **Scope excluded (17 `RETURN_A` deliberately untouched):** the 14 cluster-C `emit_context` white-box
  sites — including the **passing** `helper_action_ir_nodes` / `helper_action_ir_events {kind}` sites where
  `RETURN_A` is a legitimate helper-event kind (→ `.2.3`) — and the 3 BOTH subtests `@17289`/`@20105`/
  `@39213` (retired helper in the spec body → `.2.2.2`).
- **Validation:** `perl -c -Iperl t/phase0_regression.t` OK; full `perl -Iperl t/phase0_regression.t` run
  **twice** with a `comm` set-diff vs the baseline → **102 → 47 failing; cleared = exactly the 55 pure-B2
  subtests; new-failure set empty (zero regressions).** One after-only name on the first run
  (`parser_invalid_input_fails_at_runtime_parser_boundary`, a `Lispish` `open3` subprocess test at source
  line 4163 — textually *before* every edit, engine byte-identical) was a CPU-contention flake, disproven
  by the clean re-run (`ok 137`). Remaining 47 = 20 `method_like` (B1+BOTH → `.2.2.2`) + 20 `emit_context`
  (`.2.3`) + 7 other (`.2.4`/`.5`, incl. the `corpus_regression` missing-`plugin/` tail). memory-architecture
  self-check + Knowledge-Map gate pass. **Book unaffected** — `RETURN_A`/`RETURN` are internal canonical-IR
  node names, not a user-facing DSL surface.

## 2026-06-21 — PHASE0-BACKHALF-TRIAGE.2.2 — split cluster B into `.2.2.1` (B2 token re-bless) + `.2.2.2` (B1 helper rewrites) — decomposition slice, no test change

Decomposed the largest remaining re-bless leaf (cluster B, 76 subtests) before implementation, because
read-only recon + empirical probing showed it is too broad and partly judgment-heavy for one
signoff-quality slice. **No test/engine/spec code changed** — this slice is task-tree decomposition plus a
durable Knowledge Map fact card.

- **Recon (read-only):** classified all 76 cluster-B failing subtests with a per-subtest line map —
  **B1 = 18** (a retired `return_*` helper appears in the spec heredoc inside the subtest), **B2 = 55**
  (a retired `RETURN_A`/`RETURN_M` IR-node token is hard-coded in an assertion, with no retired helper in
  the body), **BOTH = 3** (`method_like_action_chain_parses_into_multiple_helper_events` @39213,
  `method_like_full_lifecycle_inline_composite_switch_attached_branch_blocks_lower_equivalently` @20105,
  `method_like_lifecycle_inline_composite_switch_attached_branch_blocks_lower_equivalently` @17289).
- **Empirical probe:** dumped the actual engine behaviour. (1) A lifecycle/action spec with
  `return(1)`/`return_undef()` produces canonical action-IR node **`RETURN`** (hits `RETURN => 4`), never
  `RETURN_A` — so the retired `RETURN_A`/`RETURN_M` nodes are simply renamed to `RETURN`. (2) A
  `.return_a().return_m()` chain lowers to `canonical_action_ir_nodes = ['RAW_PERL']`
  (`fallback_count = 2`, `ACODE` undef), and `call_spec_handler_subst('Top', 'return_array(...)'|'return_a()')`
  returns the input unchanged — i.e. the retired helpers are genuinely unrecognized and must be rewritten
  to canonical `return(...)`/`return(array(...))`, not token-swapped.
- **Scope hazard found:** `RETURN_A` appears **90×** in `t/phase0_regression.t`, spanning cluster B,
  cluster-C `emit_context` white-box tests (12400/12588/12628 → `.2.3`), and apparently-passing
  helper-event tests (39526/39553/39581, where `RETURN_A` is a `helper_action_ir_events` kind). The
  re-bless is therefore **not** a global search-replace — every edit must be scoped to a specific failing
  cluster-B subtest.
- **Decomposition:** `.2.2` → `.2.2.1` (B2: re-bless `RETURN_A` → `RETURN`, scoped; merge hit-count
  hashes that carry both `RETURN` and `RETURN_A`) + `.2.2.2` (B1: rewrite retired-helper spec bodies to
  canonical helpers, re-dump, re-bless dependent assertions; judgment-heavy; includes the 3 BOTH subtests).
- **Durable capture:** new KM card `docs/knowledge/actionir-return-node-retired-to-return.md` records the
  `RETURN_A`→`RETURN` node rename and the retired-helper→`RAW_PERL` facts so the implementation is never
  re-derived. Owning task tree updated with the full per-leaf work-list and scoping warnings.
- **Validation:** no code change → phase0 unchanged at 102 failing; `perl -c -Iperl t/phase0_regression.t`
  OK; memory-architecture self-check + Knowledge-Map gate pass.

## 2026-06-21 — PHASE0-BACKHALF-TRIAGE.2.1 — re-bless cluster A (7 parser-collection-shape subtests, TEST-ONLY) — 7 phase0 failures cleared

Re-blessed the cluster-A "parser-collection-shape" stale subtests in `t/phase0_regression.t`. **No engine,
spec, or production code changed** — only stale `is_deeply` expected values in the regression test.

- **Root cause (already triaged in `.1`):** these subtests assert the *retired* auto-tag accumulator shape
  `['?Rule:', []]` (`[['?First:',[]],['?Second:',[]]]`, …) for blind-call `:AND` / `:OR` / `:+` / `AND+` /
  `AND{N,M}` rules whose child rules each carry `… { return(1) }`. The current engine surfaces each child's
  own `return(1)` instead of an auto-tag, so a blind-call collection is `[1, 1]` (and a single dispatch is
  scalar `1`, a repeated AND group is `[[1,1], …]`). The engine is correct; the expectations are stale.
- **Method:** dumped the *actual* engine output for every cluster-A spec+input with a focused repro
  (`Choice::OR+`, `Sequence::AND`, `Choice::|`, `Sequence::AND+`, `Sequence::AND{2}/{2,3}/{,2}`) before
  editing, so each re-bless matches real output rather than a guess. Mapping: `['?First:', []]` → `1`;
  `[['?First:',[]],['?Second:',[]]]` → `[1, 1]`; nested AND groups collapse `['?X:',[]]` → `1` in place.
- **Edits:** 13 `is_deeply` expected values across 7 subtests — `or_plus_blind_call_…` (144),
  `explicit_and_…` (149), `blind_call_choice_…` (152), `blind_call_repeated_choice_…` (153),
  `blind_call_bounded_and_shorthand_repeated_choice_runtime` (156), `and_plus_…` (163),
  `bounded_and_rule_labels_repeat_current_sequence_model` (166). Engine-to-engine `is_deeply` comparisons
  (e.g. `is_deeply($bounded_full, $or_plus_full, …)`) and the already-correct `[]`/`undef` assertions were
  left untouched.
- **Triage correction:** cluster A is **7 subtests, not the triaged "8"**. The 8th
  (`blind_call_fluent_post_call_chain_matches_block_form`, subtest 206) fails on the retired `.return_a()`
  helper, so it belongs to cluster B (`.2.2`), not the auto-tag family. Total STALE count is unchanged (108).
- **Validation:** `perl -c -Iperl t/phase0_regression.t` OK; full `perl -Iperl t/phase0_regression.t`
  **109 → 102 failing**; a `comm` set-diff of the failing-subtest names (baseline vs after) shows the
  cleared set is **exactly** the 7 cluster-A subtests and the new-failure set is **empty** (zero
  regressions). Remaining 102 = 101 STALE (`.2.2`–`.2.4`) + 1 `corpus_regression` tail (`.5`). (The gate
  run was SIGALRM-killed at the corpus tail under external `bin/fsmgen` CPU contention from another
  session — same place the baseline's EXIT=255 stops; not a regression.)

## 2026-06-21 — PHASE0-BACKHALF-TRIAGE.4 — engine fix: input-boundary-validation regression (#2) — 2 phase0 failures cleared

Fixed reference-engine Defect #2 (input-boundary-validation regression), **authorized by ADR `0008`**.
Touched one file: `perl/LinkedSpec/Runtime.pm` (the comment-skip parser wrapper added by
`MEDIUM-IMPACT.3.2`, commit `d7294d0`).

- **Root cause:** the wrapper ran `pos($$input_ref) = 0;` (an unguarded deref) before delegating to the
  inner parser that holds the documented input-boundary guard (`Compiler.pm` `validate_input_ref`,
  ~line 1109, `ref($input_ref) ne 'SCALAR'`). For non-SCALAR-ref input the wrapper died first with a raw
  `Not a SCALAR reference at … Runtime.pm line 126`, and because the die happened in the wrapper,
  `runtime_ctx->{last_error}` was never populated.
- **Fix:** gate the `pos()` reset + leading-comment/blank-line skip behind `if (ref($input_ref) eq
  'SCALAR')` (mirroring the inner guard's exact acceptance), and always `return
  $original_parser->($input_ref)`. Non-SCALAR-ref input now reaches the documented guard → the friendly
  `Top-level parser expects a SCALAR reference input; got ARRAY` error with a populated structured
  `last_error` (`type => 'runtime_parser'`). Valid scalar-ref input keeps the comment-skip behavior
  (the wrapper's original `MEDIUM-IMPACT.3.2` purpose).
- **Verification:** `perl -c` clean. Reproducer: invalid ARRAY input → friendly error + populated
  `last_error`; valid `\$input` still parses. Full `perl -Iperl t/phase0_regression.t`: **111 → 109
  failing** — the diff vs the post-`.3` failing set is exactly the 2 Defect #2 subtests cleared
  (`parser_invalid_input_fails_at_runtime_parser_boundary`,
  `get_parser_runtime_ctx_ref_records_invalid_input_ref_with_spec_identity`), zero other changes. The
  remaining 109 = 108 known-STALE (`.2.x`) + 1 `corpus_regression` tail (`.5`). Both reference-engine
  defects (#1, #2) are now fixed; only the test-only re-bless + the corpus tail remain before green phase0.

## 2026-06-21 — PHASE0-BACKHALF-TRIAGE.3 — engine fix: AND-rule action-codegen defect (#1) — 62 phase0 failures cleared

Fixed reference-engine Defect #1 (AND-rule action-codegen), **authorized by the user as a sanctioned,
scoped exception to the engine-frozen doctrine — ADR `0008`**. Touched one file:
`perl/LinkedSpec/HandlerVariantEmitter.pm` (the AND-acode handler emitters only).

- **Root cause:** both `_emit_and_acode_seq_handler` (multi-regex AND) and
  `_emit_and_single_acode_handler` (single-regex AND) rewrote an edge `return(...)` into a `$<label> =`
  assignment via `s/\breturn\s*/\$" . $label . " = "/eg`. The bare `\$"` parses as a *reference to* the
  list-separator variable `$"` (it stringifies to `SCALAR(0x…)`), so the emitter produced invalid Perl
  `SCALAR(0x…)<label> = …` — a compile error (`Bareword … near ")<Rule>"`) for a top rule (parser →
  `undef`) and a dropped payload for a child rule (→ `[]`). The correct literal form `"\$"` is already
  used at lines 524/594 (I-block return→assignment) and 928 (`_emit_rep_acode_handler`). The
  single-acode handler additionally never `push`ed its transformed acode onto `@acodes_transformed`, so
  the edge action was dropped entirely even when it would have compiled.
- **Fix:** emit edge acodes **verbatim**. They are already lowered (`return(array(...))` →
  `return [...]`, `assign(...)` → an in-place mutation), so a `return` edge surfaces the author payload
  directly — from the whole handler in a direct AND, or from the per-iteration coderef in a REP-AND
  (`:AND+`), because `_emit_rep_and_acode_handler` wraps the seq body in `sub { ... }` (a `return` there
  exits one iteration, the correct collection point). This also matches the test contract exactly: an
  `::AND` rule whose terminal indexed edge does `return(array("?Top:", X))` yields the **raw** payload
  `['?Top:', X]` (verified against all 21 cataloged AND-rule tests, incl. `call(Child)` edges always
  wrapped as `return(call(Child))`).
- **Verification:** `perl -c` clean (HandlerVariantEmitter.pm, LinkedSpec.pm). Book `Pair::AND` example
  and the `named_mark_capture_from_reads_rule_local_checkpoint` reproducer now compile and return the
  author payload (`['?Top:','bar']`). Full `perl -Iperl t/phase0_regression.t`: **173 → 111 failing
  (62 cleared)** — all 60 cluster-D capture/mark/cursor/entry/whole-input/current-match tests + the named
  cluster-G AND tests (`anonymous_and_named_capture_boundaries_can_bridge_explicitly`,
  `multi_rule_parsers_…`) + cluster-C `emit_context_lowers_push_nonempty_method_contract` now pass.
  **Zero regressions**: the remaining 111 are exactly the 108 known-STALE (re-bless in `.2.x`) + 2
  Defect #2 input-boundary (`.4`) + 1 newly-reached `corpus_regression` tail (`.5`). Only `:AND` emitters
  were touched; NORMAL/OR/REP/bcode rules are unaffected.

## 2026-06-19 — PHASE0-BACKHALF-TRIAGE.1 — read-only triage complete (173 → 108 STALE / 65 REAL, 2 engine defects)

Completed the read-only stale-vs-real triage of the 173 pre-existing back-half core failures. No
engine/spec/test code changed — this slice is the triage report + the `.2`–`.5` fix decomposition +
two Knowledge Map cards.

- **Method:** authoritative `perl -Iperl t/phase0_regression.t` run (173 fail / 707 pass; reached
  880/959 before the background run was terminated, exit 144 mid-subtest-881; TAP → `/tmp/phase0_triage.tap`).
  Bucketed all 173 by name into 6 clusters; pulled got/expected per cluster; reproduced representatives;
  ran two parallel read-only deep-dives (method_like; emit_context+descriptor+singles) against the engine
  + book contract.
- **Verdict — 108 STALE (re-bless) / 65 REAL (engine-fix):**
  - STALE: A parser-collection-shape (8 — engine returns `[1,1]` per child `return(1)`; test wants the
    retired `['?Rule:',[]]` auto-tag); B `method_like` (75 — retired `return_a/return_m/return_ma/
    return_imatch/return_im/return_array` helpers + `RETURN_A/RETURN_M` nodes, COMPAT-ALIAS-RETIREMENT-V2;
    branch-block canonical lowering itself is intended/working/book-documented); C `emit_context` (20 —
    white-box seams monkeypatching the removed `LinkedSpec::Deps::*`, a stale `plan 89`/88, retired-helper
    passthrough, one mis-authored re-bless); F migration-summary (3 — `return(1)` is a resolved plain
    return, not a `return_a` blocker); G singles (2 — `return(1)` AST shape is scalar `1`, not ARRAY).
  - REAL **Defect #1 — AND-rule action-codegen** (63): a multi-indexed-edge AND rule (`-> Rule[0..N]`)
    with a `return(...)` edge emits `SCALAR(0x…)Rule` in `AND_ACODE` (lowered payload replaced by a
    stringified scalar-ref + rule label) ⇒ compile-fail `near ")Top"` (top rule, parser→undef) or dropped
    payload `[]` (child rule). Bisected: single-edge AND OK, multi-edge all-`assign` OK, multi-edge +
    `return` BROKEN; per-edge helper lowering is valid Perl. Likely `HandlerVariantEmitter.pm`/`SpecEntry.pm`.
  - REAL **Defect #2 — input-boundary regression** (2): `Runtime.pm:~126` comment-skip wrapper (commit
    `d7294d0`, MEDIUM-IMPACT.3.2) runs `pos($$input_ref)=0` before the SCALAR-ref guard ⇒ raw die +
    unpopulated `runtime_ctx->{last_error}` for invalid input.
- **Decomposition:** `.2` re-bless/retire the 108 stale (`.2.1`–`.2.4`); `.3` engine fix Defect #1
  (blocked — needs user OK to touch the reference engine); `.4` engine fix Defect #2 (blocked); `.5`
  verify green phase0 (incl. the unobserved 881–959 tail). Knowledge cards
  `docs/knowledge/and-return-edge-codegen-defect.md` + `…/runtime-input-boundary-validation-regression.md`.
- **Validation:** `perl -c perl/LinkedSpec.pm` OK; self-check + KM gate run pre-commit. The read-only
  triage is vindicated — re-blessing cluster D (60) would have masked the AND-codegen defect.

## 2026-06-19 — Triage WIP + trace directive owned (PHASE0-BACKHALF-TRIAGE.1 in progress; TRACE-OBSERVABILITY created)

Read-only/ownership checkpoint (no engine/spec/test code changed). Owned the two follow-on efforts the
NONCORE-QUARANTINE discovery + the user's trace directives created:

- **`PHASE0-BACKHALF-TRIAGE` (new tree, `.1` in progress):** triage the ~173 pre-existing back-half
  core failures with LinkedSpec's trace. Established the trace driver: `LINKEDSPEC_TRACE_LEVEL=debug
  perl -Iperl <driver>` (existing env control; ~22k lines of ENTER/DECISION/dump to stdout).
  **Root-caused Cluster A (parser collection-shape, ~10+ subtests) = STALE tests:** reproduced
  `or_plus_blind_call` (`Choice::OR+ => First => Second`, children `return(1)`, input `"ab"`) → engine
  returns `[1, 1]` (each child's literal `return(1)`); the test asserts the retired tagged-accumulator
  shape `[['?First:',[]],['?Second:',[]]]`. Engine is correct per documented helper-DSL return
  semantics → re-bless. Clusters B–E (`method_like`×75, `emit_context`×21, capture/mark/entry families)
  pending root-cause.
- **`TRACE-OBSERVABILITY` (new tree):** owns the user's directives — a discoverable CLI trace control
  ("introduce a CLI control to this API") + a comprehensive "see everything" trace (function
  enter/exit, if/switch/case branches). Finding: the framework already exists (`Trace.pm`:
  `trace_enter`/`trace_exit`/`trace_decision`, levels none..debug, sinks; env control
  `LINKEDSPEC_TRACE_LEVEL`/`_FILE`/`_MIRROR_STDOUT`/etc.) and works — the gaps are **discoverability**
  (no `--trace` flag / `bin/` entrypoint / mdBook docs) and **coverage** (instrumentation isn't
  exhaustive; the generated runtime parser especially needs branch tracing). Plan: `.2` CLI+docs
  (quick win) → `.1` coverage audit → `.3` extend coverage.

Validation: `scripts/check_memory_architecture.sh`; KM gate; `perl -c perl/LinkedSpec.pm` (unchanged).
Session is very long → fresh session advisable; repo handoff-ready (relocation committed at `2baddbd`).

## 2026-06-19 — NONCORE-QUARANTINE.3+.4: relocate all remaining non-core `.pm`/`.plg` to `noncore/` + excise their phase0 subtests (reveals ~173 pre-existing back-half core failures)

Completed the quarantine (user: "straight through"). **`git mv`** the 23 remaining domain `.pm`
(`Global`, `HLinkSubst`, `HUtils`, `InteractivePrompt`, `Lispish`, `LispML`, `Table`, `Table2SS`,
`TableGrep`, `TableScript`, `TableSort`, `TcFlow`, `HTML/PathLinks`, `HTTP/FileAccess`, `MSOffice/Excel`,
`QC/{Flow,Summary,TclInterconn}`, `Table/GenericFilter`, `Text/VariableSubstitution`,
`Timing/{SetupHold,StanBackend,StanOmap2430cBackend}`) and all 13 `.plg` → `noncore/` (layout
preserved). **`perl/` is now core-only** (`LinkedSpec.pm` + `LinkedSpec/**` + `LinkedRE`/`PathSearch`/
`PPlugin`); the emptied `perl/{HTML,HTTP,MSOffice,QC,Text,Timing,Table,Plugin}/` + `plugin/` were rmdir'd.

Excised the **37-subtest legacy-migration block** from `t/phase0_regression.t` (source lines
3312–5378, from `subtest 'tablescript_http_exec…'` up to `subtest 'get_parser_normalizes…'`) via a
guarded anchor-splice — these tested the now-quarantined modules/`.plg`. Verified: `perl -c
perl/LinkedSpec.pm` OK; `perl -c t/phase0_regression.t` OK; subtest count 996→959; `git grep` = 0
references to any relocated module/`.plg` in the test. Method (key lesson): after the move, phase0
*fast-fails* on island subtests (instead of hanging), so phase0 itself pinpointed the contiguous
island block; checked there was no shared file-scope code in the block before excising.

**DISCOVERY — ~173 pre-existing back-half core-engine test failures (NOT caused by this work).** With
the island hangs gone, phase0 now runs the long-dark back half (subtests ~111+) for the first time
and reveals ~173 real, deterministic assertion failures — structural/shape mismatches (0 timeouts, 0
missing-module errors), e.g. `or_plus_blind_call`: parser returns scalar `'1'` where an array-of-arrays
is expected. Clustered `method_like`×75, `named_mark`×25, `emit_context`×21, capture/mark/entry
families. **This work changed zero engine bytes** (only `git mv` of non-engine files + test-subtest
removal + docs), so the engine behaves identically to before — these were masked by the original hang
(subtest 110) and never ran. Most likely **stale tests** (written for evolved ActionIR/HandlerIR
behavior, never re-run) rather than 173 real regressions (shipped specs + front 100 subtests pass).
Green phase0 (and the `SPEC-FORMAT-TERSE` / `LEGACY-VHDL-RETIRE.4-.5` / `NONCORE-QUARANTINE.V`
blockers) now depends on triaging these — a separate tree; **surfaced to the user**. Also observed:
external `bin/fsmgen --emit-semantic-json` (100% CPU, another session — not killed) slows runs but is
not the cause of the 173 (those are structural).

Validation: `perl -c` (core + test); `git grep` island-ref sweep = 0; `scripts/check_memory_architecture.sh`;
KM gate. phase0 is NOT green (173 pre-existing failures) and was not run to completion (external
contention). The relocation itself is correct + complete.

## 2026-06-19 — NONCORE-QUARANTINE.1+.2: dependency-tree inventory + relocate 12 zero-ref modules to `noncore/`

User reframed twice: (1) the real task is to extract `LinkedSpec.pm`'s full dependency tree and act
on what's unused; (2) **relocate (`git mv`) the non-core modules to a holding area, NOT delete them**
— so we keep the option to refactor / port (Rust/Julia/Dart) / publish / `git rm` each on its own
merits later, while making the "provably not in the LinkedSpec tree" boundary explicit. New tree
`NONCORE-QUARANTINE` (repurposed from the delete-framed `DEADCODE-PRUNE`).

`.1` Dependency-tree extraction (read-only): roots = `LinkedSpec.pm` (transitive `use`/`require` +
lazy `OwnerDispatch` string-name owner loads + dynamic `get_parser`/`get_plugin`/AUTOLOAD/`.plg`→`.pm`
edges) ∪ shipped `specs/*.spec` ∪ `conf/`+`ebnf/`+`tablescript/`. The decisive edges are dynamic —
`Lispish.pm`→`get_parser('Lispish')`→`PathSearch`→`Lispish.spec` — invisible to a `use` scan; and
reachability is **directional + rooted** (`Lispish.pm` depends on `Lispish.spec` but nothing depends
on `Lispish.pm` → dead consumer). Result (agent map + `git grep` cross-checks): **41 KEEP `.pm` /
36 non-core `.pm`; all 13 `.plg` non-core.** Shipped specs reference **zero** plugins/cross-specs →
the entire legacy domain island + `.plg` corpus is unreachable from the product. **Critical check:
zero core→domain edges** (only the `PluginBridge`→`PPlugin` machinery load + a comment). `tools/`/`bin/`
don't reference the island; the 12 zero-ref modules confirmed 0 refs repo-wide. The phase0 back-half
hangs (e.g. `HTML::PathLinks::link_path_tokens`) live entirely in the non-core island → removing its
subtests greens the suite.

`.2` Created `noncore/` + `noncore/README.md` (the parked fate ledger, with non-binding hints:
revive-candidate / replaceable / likely-rm). **`git mv`** the 12 zero-reference modules
(`AmbiTiming`, `EasyTk`, `EncounTiming`, `HDisplay`, `LibReader`, `MagmaTiming`, `PTiming`,
`Reportiming`, `rvp`, `TkGui`, `XLSreader`, `PluginUtils`) → `noncore/` (layout preserved; loadable
via `-Inoncore` if ever revived). 100% safe: these have **zero references** anywhere, so no code,
spec, or test was touched. perl/ top-level `.pm`: 28→16. `perl -c perl/LinkedSpec.pm` OK.

Plugin machinery (`PPlugin`/`PluginBridge`/`PluginRegistry` + the deprecated `LinkedSpec.pm` stubs)
stays in core for now (reachable via the stubs) — `.N`, POSTPONED. The 24 domain `.pm` + 13 `.plg`
relocate in following batches (`.3`/`.4`) together with their phase0 subtest removal (clears the
back-half hangs). `scripts/check_memory_architecture.sh` + KM gate pass.

## 2026-06-18 — LEGACY-VHDL-RETIRE.2+.3: retire the Perl-only legacy VHDL/RTL/FSM subsystem (RTLUtils hang cleared; a SECOND pre-existing back-half hang discovered)

User confirmed "Full subsystem closure" (AskUserQuestion). Retired the self-contained Perl-only
legacy VHDL/RTL/FSM subsystem:

- **`git rm`** `perl/RTLUtils.pm` (877), `perl/FSMGen.pm` (3,549), `perl/VHDL/ConstantEval.pm` (90)
  (the now-empty `perl/VHDL/` is gone), and 6 dependent `plugin/*.plg` (fsmgen, lte_digital_rf,
  mbist, msword, regtest, rtl) = ≈6,495 lines.
- Surgically cleaned `t/phase0_regression.t`: **8 whole module-smoke subtests deleted** + **7 mixed
  subtests cleaned** (those that used the deleted modules/`.plg` as corpus for *kept*-module
  assertions; per-subtest `plan` counts adjusted exactly). ≈206 lines. Updated the now-stale
  comments in `perl/LinkedSpec.pm` and `tools/gen_oracle_corpus.pl`.
- `git grep` = 0 functional references to the modules; `perl -c perl/LinkedSpec.pm` + `perl -c
  t/phase0_regression.t` OK; the edited subtests PASS in a live run.

**RTLUtils hang CLEARED — proven** via a pristine-HEAD worktree: the original suite hangs at
subtest **110** `rtlutils_header_context_clause_package_owner_preserves_payload` (the
`add_header_n_context_clause` smoke; recursive `add_package_re` `([[:alpha:]]\w+)(?:\.((?1)))?$`
applied at `RTLUtils.pm:104`), while subtest 109 `drive_entity_component` completes. **This corrects
`LEGACY-VHDL-RETIRE.1`'s wrong "line 746 / `drive_entity_component`" claim** — the original
MEMORY/ADR attribution (`add_header_n_context_clause`) was right. The post-retirement suite runs
**past** subtest 110 to subtest 130+.

**DISCOVERY — a SECOND, pre-existing, unrelated hang unmasked by removing the first.** The original
hang at subtest 110 had kept the **entire back half of phase0 (subtests 111+) dark**. With it gone,
the suite now reaches `HTML::PathLinks::link_path_tokens` (subtest 131
`html_path_link_owner_avoids_pplugin_and_preserves_link_wrapping_contract`), which **hangs** (a
separate catastrophic regex; the subprocess is alarm-killed → that subtest fails 3/7), plus other
back-half failures. `require HTML::PathLinks`/`HTTP::FileAccess` load fine; only the `link_path_tokens`
call hangs. HTML::PathLinks depends only on **kept** modules — so this is **not** caused by the
retirement (proven: pristine HEAD never reaches subtest 111+). Consequence: **the retirement clears
the RTLUtils hang but does NOT make phase0 green/usable**; the `SPEC-FORMAT-TERSE` gate stays blocked
— now by the back-half. This needs its own fix track — **surfaced to the user**.

Validation: `git grep` sweeps; `perl -c`; pristine-HEAD worktree comparison; direct
`link_path_tokens` timing (hangs under a timeout guard); `scripts/check_memory_architecture.sh`;
KM gate. The full `t/phase0_regression.t` is **not green** (back-half hang) and was not run to
completion. KM card [[rtlutils-regex-hang]] updated; `SPEC-FORMAT-TERSE` blocker updated (gate still
blocked).

## 2026-06-18 — LEGACY-VHDL-RETIRE.1: own retirement tree + read-only inventory of the Perl-only legacy VHDL/RTL/FSM subsystem

Owned a new task tree `LEGACY-VHDL-RETIRE` (`docs/tasks/LEGACY-VHDL-RETIRE.md`) and completed its
read-only feasibility/inventory leaf `.1` — the recorded next action in `MEMORY.md`. This is the
prerequisite that unblocks the `SPEC-FORMAT-TERSE` implementation gate (a usable
`t/phase0_regression.t`, currently hung by `RTLUTILS-REGEX-HANG`): per
[[feedback_keep-only-portable-cross-variant]] the direction is to **retire** the Perl-only legacy
subsystem (which also clears the hang), not patch a regex in soon-deleted code.

Verified inventory (`git grep` reference sweep + module inspection; no deletion):

- **Subsystem (3 Perl-only modules, no Rust/Julia/Dart counterpart):** `perl/RTLUtils.pm` (877),
  `perl/FSMGen.pm` (3,549; `use RTLUtils`; `AUTOLOAD`→PluginBridge), `perl/VHDL/ConstantEval.pm`
  (90; `require RTLUtils`) = **4,516 lines**.
- **Zero functional dependency from the active `.spec` parser/compiler/runtime core** — the only
  `perl/` reference is a comment (`perl/LinkedSpec.pm:246`); `tools/gen_oracle_corpus.pl:31` is also
  a comment. No shipped `specs/*.spec`, nothing in `bin/`.
- **6 exclusively-dependent `plugin/*.plg`:** `fsmgen`(464), `lte_digital_rf`(43), `mbist`(75),
  `msword`(326), `regtest`(345), `rtl`(726) = **1,979 lines**.
- **`t/phase0_regression.t`:** ≈206 lines of plugin→package-owner **migration-smoke** blocks
  (obsolete once the code is gone).
- **`RTLUTILS-REGEX-HANG`:** catastrophic-backtracking regex at `perl/RTLUtils.pm:746`
  (`/(\w+)(?=(?:\[.*?\])?\s*<=((?s).+?);)/go`), reached via `drive_entity_component`→`_drive_instances`.
  (Prior attribution named `add_header_n_context_clause`; actual pattern is at line 746.)
- **Removal footprint (recommended full closure):** ≈**6,701 lines**.
- **Doc drift found (defer fix to `.5`):** `ROADMAP_V2.md:157` / `ARCHITECTURE_STATE.md:588` describe
  `plugin/generic_fake_memory_module.plg` and `plugin/wrapgen.plg` as live `ceil_log2` callers, but
  **both files no longer exist** and no `.plg` references `ceil_log2`.

Wrote KM fact card `docs/knowledge/rtlutils-regex-hang.md`; registered the tree in
`docs/TASK_TREE.md`; updated the `SPEC-FORMAT-TERSE` blocker to point at the owned tree. Removal
leaves `.2`–`.5` are **blocked pending user removal-scope confirmation** (deletions; the doctrine +
`MEMORY.md` require confirming scope first).

Validation: `git grep` sweeps + `wc -l` counts (recorded in the tree); `scripts/check_memory_architecture.sh`
exit 0; KM gate regenerates `KNOWLEDGE_MAP.md`. No engine/spec/test code changed (docs + task-tree +
KM only); `t/phase0_regression.t` still hangs until `.2`–`.4` land.

## 2026-06-18 — SPEC-FORMAT-TERSE.0: activate + ratify the terse `.spec` format direction (ADR 0007)

The user activated the previously-`proposed` `SPEC-FORMAT-TERSE` tree (the terse, fully-composable
`.spec` format brainstormed 2026-06-15) and reinforced the key semantics across several messages:
`assign(x,v)` → `x = v` (op) / `set`; **no sigils** — bare typed identifiers (no `scalar()/array()/
hash()` wrappers); types inferred at initialization or by argument position; `copy()` unifies
`array_copy`/`hash_copy` (arrays + hashes); arrays/hashes/numbers/strings have **methods** (chain by
return type); **everything is an expression** → typed values, with control-flow constructs and `{}`
blocks as expressions. All consistent with the brainstorm card and the tree's Round 1–3 transcription.

Ratified the direction as ADR
[`0007-spec-format-terse-direction.md`](docs/decisions/0007-spec-format-terse-direction.md) (indexed):

- **Adopt Rounds 1–3** as transcribed (Round 4+ deferred to a discovery leaf).
- **Migration policy: canonical-new-form + deprecated-old-alias (gradual), then explicit
  retirement** — keeps the 20 shipped specs + the book compiling and the ActionIR-ready invariant
  (ADR 0002) intact at every step. (Open to a user override toward one-shot hard rename.)
- **`.spec` stays the single universal contract; all variants move in lockstep** (ADR 0006); the
  mdBook is updated only after the engine implements a form.
- Touching the Perl reference for this evolution is a **user-sanctioned exception** to the standing
  "do not fix the reference engine" default (this is intentional language evolution, not a
  docs-vs-reference fix).
- **Implementation leaves (`.1.x`+) are gated** by a usable `t/phase0_regression.t`, currently hung
  by the pre-existing `RTLUTILS-REGEX-HANG`. `.0` is design-only and not gated.

Tree state: `SPEC-FORMAT-TERSE` `proposed`→`active` (now the current focus); `.0` done;
`SPEC-LANG-REFERENCE` book scorch paused. Two execution decisions surfaced to the user (migration
policy confirmation; `RTLUTILS-REGEX-HANG`-first sequencing) before any implementation leaf.

Validation: `scripts/check_memory_architecture.sh` exit 0; KM gate in sync. No engine/book change.

## 2026-06-18 — SPEC-LANG-REFERENCE.10.5.4: fix `worked-spec-walkthrough.md` → verified 2-rule idiom (+ terse-format pivot)

Third fix slice of the whole-book scorch — and the slice on which the user **activated
`SPEC-FORMAT-TERSE`** (terse `.spec` format), pausing the scorch.

The chapter's central worked example was a single rule with a regex on the top rule and a broken
self-edge — `Pair::AND /([A-Za-z_]\w*)\s*=\s*([^,\n]+)/ -> Pair[0] { return(hash("kind","pair",
"name",match_group(0),"value",trim(match_group(1)))) }` — which actually returns `[]`, while the
whole chapter claimed it returns a single hash `{kind=>"pair",name=>"answer",value=>"42"}`.

Rewrote it to the verified 2-rule idiom:

```
Top::
 -> Pair .push

LX { return(array_copy(a(Top))) }

Pair:
 /([A-Za-z_]\w*)\s*=\s*([^,\n]+)/ I {
   return(hash("kind", "pair", "name", entry_group(0), "value", trim(entry_group(1))));
 }
```

**Every claimed input→output re-derived** through `LinkedSpec::Get` with a mode-aware driver
(`/tmp/lsq_me/runpm.pl`; scalar-ref input; `JSON::PP->canonical`; sanity-checked against the frozen
`["hello-world"]` idiom):

- `answer = 42` (default / `consume`) → `[{"kind":"pair","name":"answer","value":"42"}]`
- `junk answer = 42` under `consume` → `[]`; under `seek` → the pair
- `a = 1, b = 2` → a two-element list (the entry loop collects each match)

Corrections made to the prose: the output is a one-element **list** (the entry rule's accumulator
snapshot), not a bare hash; `match_group(...)` → `entry_group(...)` throughout (the dispatched
matcher's *local* match is unset, so `match_group` would be empty — documented + cross-linked to the
entry-vs-match divergence); the descriptor checks still hold (`ref eq HASH`, `meta.parse_mode eq
'consume'`, `exists spec{Pair}`) but **`ctx{top_rule}` is now `Top`**, not `Pair`. Three engine traps
were isolated and avoided: `:AND` on the matcher with a separated `I` block collapses the push to
`[0]`; an OR matcher with an `I` block over alternative capture groups is fragile (`[null]`/`[]`), so
the OR growth path is shown as a structural sketch with no output claim.

**Terse-format pivot.** The user flagged `declare()`/`assign()` in the chapter's advanced
"Evolving the spec" sketch. Investigation: `declare`/`assign` are **live** in the Perl reference
engine (active `Contracts.pm` contracts) and used across shipped specs (`tablegrep.spec`,
`ds_vhistory.spec`, `BNF.spec`) and the book; the removal/rename is owned by `SPEC-FORMAT-TERSE`,
which was `proposed` (not implemented). Removed `declare`/`assign` from the sketch (the `call(...)`
dataflow teaching is preserved without them). The user then chose to **activate `SPEC-FORMAT-TERSE`
now**, so the whole-book scorch is **paused after this leaf** (the terse migration will re-sweep every
book example in lockstep with the engine).

Validation: `mdbook build` exit 0; `scripts/check_memory_architecture.sh` exit 0. No Perl change.
**Frontier → whole-book scorch PAUSED; pivot to `SPEC-FORMAT-TERSE.0` (ratify + ADR).**

## 2026-06-17 — SPEC-LANG-REFERENCE.10.5.3: fix `get-and-get-parser.md` minimal `Get` example → verified 2-rule idiom

Second fix slice of the whole-book scorch. The `LinkedSpec::Get(...)` minimal example embedded an
inline `.spec` heredoc that was regex-on-top + a `::AND -> Top[0]` self-edge —
`Top::AND /foo/ -> Top[0] { return(hash("kind","top","text",match_text())) }` — which returns `[]`,
not a usable AST. Replaced the heredoc with the verified 2-rule idiom:

```
top::
 -> word .push

LX { return(array_copy(a(top))) }

word:
 /foo/ I {
   return(hash("kind", "top", "text", entry_text()));
 }
```

added a `# $ast is [ { kind => "top", text => "foo" } ]` comment and a sentence teaching the two-rule
shape. **Verified by extracting the heredoc from the book file** and running `LinkedSpec::Get`: `foo`
→ `[{"kind":"top","text":"foo"}]`. Caught the `match_text()`→`entry_text()` trap (same family as the
`.10.3` `entry_group`/`match_group` lesson): in the freshly-dispatched child rule the local match is
unset, so `match_text()` gives `null` (`[{"kind":"top","text":null}]`) — `entry_text()` (the entering
match) gives `"foo"`. Only one inline `.spec` heredoc exists on the page; the `get_parser` example
uses a named spec. `mdbook build` exit 0. Frontier → `.10.5.4` (`worked-spec-walkthrough.md`).

## 2026-06-17 — SPEC-LANG-REFERENCE.10.5.2: fix `what-is-linkedspec.md` minimal kv example → verified 2-rule idiom

First fix slice of the whole-book scorch. The overview chapter's "minimal key/value parser" example
was a single rule with a regex on the top rule **and** a `::AND -> Top[0]` self-edge:
`Top::AND+ /(\w+)=(\w+)/ -> Top[0] { return(hash(…)) }` — the generated handler **fails to compile**
and the parser returns `null`, while the prose claimed it "returns a hash per match." Replaced it with
the verified 2-rule idiom:

```
top::
 -> pair .push

LX { return(array_copy(a(top))) }

pair:
 /(\w+)=(\w+)/ I {
   return(hash("key", entry_group(0), "val", entry_group(1)));
 }
```

and rewrote the prose to teach the entry-rule-(no-regex) / normal-rule-(regex) structure with the real
output and cross-links to `regex-in-spec.md` + `spec-files-and-rule-paragraphs.md`. **Verified by
extracting the exact block from the book file** and running it through `LinkedSpec::Get`: `foo=bar
baz=qux` → `[{"key":"foo","val":"bar"},{"key":"baz","val":"qux"}]` (single `answer=42` →
`[{"key":"answer","val":"42"}]`). Idiom note: the bare action-block form `pair: /re/ { return }` (no
`I`) returns `[0,0]`; the `I { … }` lifecycle block is required. `mdbook build` exit 0. Frontier →
`.10.5.3` (`public-api/get-and-get-parser.md`).

## 2026-06-17 — SPEC-LANG-REFERENCE.10.5.1: whole-book `.spec`-snippet scorch AUDIT (findings + decomposition)

Ran the fresh exhaustive hunt for the whole-book scorch (`.10.5`). Method: **8 read-only `Explore`
agents** over chapter groups (enumerate every `.spec` block → classify A/B/C/D/CLEAN → run claimed
outputs), then **personally ground-truthed every load-bearing finding** through a private
`LinkedSpec::Get` driver. (Mid-run, an audit agent overwrote the shared scratch driver at
`/tmp/lsq/run.pl`; this was caught immediately and a private driver `/tmp/lsq_me/run.pl` was used for
all verification — so every agent ACTUAL_OUTPUT was treated as a hypothesis, per the `.10.6` lesson.)

**Engine facts established (probed via `LinkedSpec::Get`, not guessed):**
- `::` and `:` are **interchangeable on a non-first rule** (`child::AND /re/` ≡ `child:AND /re/` → both
  `[0]`); only the **first** rule is the top/`_INITIAL` entry; multiple `::` rules do not collide.
  Therefore "no regex on a `::` rule" is an **authoring doctrine**, not a hard engine constraint
  (consistent with the `.10.6` retraction — the engine is permissive).
- The `Rule::AND /regex/ -> Rule[N] { return(...) }` shape (AND mode + slot self-edge) **drops its edge
  return → `[]`** (the `.10.1` `_emit_and_single_acode_handler` finding).

**Headline finding:** the `Rule::AND /regex/ -> Rule[N] {return}` idiom is the book's **pervasive**
worked-example shape — `grep` finds **~105 `Name::<mode>` rule headers across ~20 files** — and it is
doctrine-divergent (regex on a `::` rule) **and** the `[]`-shaped form. The audit agents disagreed on
whether the isolated DSL helper-illustration fragments count as violations; the user was asked
(AskUserQuestion) and chose **FULL BOOK-WIDE SCORCH** — rewrite every worked example (incl. those
fragments) to the verified 2-rule idiom and correct all wrong outputs.

**Verified drifts (ground-truthed):** `tablegrep` `field1 =~ /foo/` → `sens` is `"="` not the claimed
`"=~"` (the regex captures only `([!=])`); `portmap` `clk` → `["?bare:",["clk"]]` and `addr[7:0]` →
`["?slice:",["addr","7","0"]]`, not the claimed flat `['?bare:','clk',undef,…]`. **Two preliminary-hunt
hypotheses overturned on re-verification:** `ebnf-spec-walkthrough.md`'s "richer example" **compiles +
parses to its claimed structure** (CLEAN — the earlier "does not compile" claim was wrong), and the
§5.5 regex-on-`::` forms run + return values. **Confirmed CLEAN:** all `compiler/*`/`architecture/*`/
`development/*` (no `.spec` blocks), `public-api/{trace,plugin,descriptor}`, helper-catalog §2/§5 (the
`.10.3` idiom), lispish/pplugin walkthroughs (faithful shipped-spec quotes).

Recorded the full findings table + engine facts + the scope Decision in
`docs/tasks/SPEC-LANG-REFERENCE.md` ("Audit Findings (`.10.5.1`)"), and decomposed the remediation into
per-file fix leaves `.10.5.2`–`.10.5.19` (one file/coherent group per leaf; `.10.5.16` folds the
`.10.4` §5.5 Pair fix; `.10.4` marked `superseded`). `scripts/check_memory_architecture.sh` exit 0.
**No book or Perl change in this slice (audit only).**

## 2026-06-17 — SPEC-LANG-REFERENCE.10.5 (scope): broaden to a whole-book example scorch (user directive)

User directive: *"scorch the book to hunt down book examples — the book shall not mislead, only
truthful + valid code snippets."* Broadened `.10.5` from "a few named chapters" into a **whole-book
exhaustive audit** of every `.spec` snippet in `docs/linkedspec-book/src/**` for (i) doctrine-validity
(no regex on a top `::` rule; ≥2 rules) and (ii) output-correctness (any claimed input→output matches
a `LinkedSpec::Get` run), followed by remediation. It is an audit-as-decomposition that produces fix
sub-leaves `.10.5.1…` and subsumes the `.10.4` §5.5 Pair fix; the frontier is repointed → `.10.5`.

A preliminary read-only fan-out hunt (4 of 5 verifying agents reported before this session exited;
NOT authoritative — re-run fresh) confirms the scorch is warranted: regex-on-top / single-rule
violations are **widespread** (rule-modes, regex-in-spec, the dsl helper-reference pages,
capture-marks, source-boundary), plus confirmed Class B drift in `worked-spec-walkthrough.md`
(`{kind=>"pair",…}` claimed; actually `[]`) and a single-rule regex-on-top "minimal example" in
`public-api/get-and-get-parser.md`. The `.10.3` helper-catalog examples re-verified CLEAN. Read-only
record/plan update only — no book/Perl change.

## 2026-06-17 — SPEC-LANG-REFERENCE.10.6: retract the inaccurate "regex-on-top → []" premise; reframe the .10 rationale as the 2-rule authoring doctrine

Ground-truthing the `.10` correction's premise via `LinkedSpec::Get` showed it was partly wrong: a
regex on a `::` rule with an OR self-ref / cross-rule **action edge runs and returns its value** —
the old `.5.2`/`.9` examples returned the documented values, and the §5.5 frozen oracle fixtures
(`Top:: /x/ -> Done {…}`) work. The only shape that silently returns `[]` is the explicit
`::AND … -> Rule[N] { return(...) }` form (the `.10.1` AND_SINGLE_ACODE finding).

Rewrote the Knowledge-Map card `docs/knowledge/spec-top-rule-no-regex-two-rule-minimum.md`
**doctrine-first**: a `.spec` is written as a top `::` entry rule (no regex — the dispatch loop) +
≥1 normal `:` rule carrying the regex(es); never put a regex on the top rule (all 20 shipped specs
follow this). The earlier "regex-on-top silently returns `[]`" mechanism claim is **retracted**. The
**doctrine and `.10.3` are unchanged** — only the remediation *rationale* is corrected: the examples
violated the 2-rule authoring doctrine, they were not returning `[]`. There is no rationale for ever
putting a regex on a top rule. KM gate regenerates `KNOWLEDGE_MAP.md`; self-check passes. No Perl, no
book-example change.

## 2026-06-17 — SPEC-LANG-REFERENCE.10.3: redo the Scalar+Numeric helper examples with the valid 2-rule idiom

Remediation of the structurally-invalid worked examples flagged by the `.10` correction. Rewrote, in
`docs/linkedspec-book/src/appendix/helper-contract-catalog.md`, the §2 (Scalar) and §5 (Numeric)
"Worked examples" preambles and **all 33 helper examples** (17 Scalar + 16 Numeric) from the invalid
`Demo:: /regex/ -> Demo { return(<expr>) }` form (a regex on the top rule → `[]`) to the **verified
two-rule idiom**:

```text
demo::  -> value  .push
LX { return(array_copy(a(demo))) }

value : /<regex>/  I.return( <helper-expression> )
```

- The normal rule reads its captures with **`entry_group(N)`** (the entering match), not
  `match_group(N)` (the local match, unset in the child's `I` block).
- Output is the top rule's accumulator snapshot — a **one-element array** holding the helper's value
  (e.g. `concat` → `["hello-world"]`, `num_add` → `[5]`, `num_div` `5/0` → `[null]`, booleans → `[1]`/`[0]`).
- `is_defined`/`is_undefined` keep the condition-only `I { if (...) … }` block form.

**Verification:** every example was build-AND-run re-derived through `LinkedSpec::Get` with a scratch
harness that builds each spec from the exact book scaffold and JSON-encodes the output
(`JSON::PP->canonical`), sanity-checked against the frozen `["hello-world"]` idiom. All 33 match the
documented outputs. One do-not-guess fix: `is_defined`'s `/(\w*)(\S*)/` matched twice (empty-matchable
→ two dispatch-loop hits → `["present","present"]`), corrected to `/(\w+)/` → `["present"]`. The only
remaining `match_group` in the catalog is the §8 Entry/Match helper *reference* (correct). `mdbook
build` exit 0 (rendered HTML confirms the full blocks stay single code blocks with the inter-rule
blank line). self-check + KM gate pass. No Perl change. Frontier → `.10.4`.

## 2026-06-17 — SPEC-LANG-REFERENCE.10 (correction): top rule has no regex; `.5.2`/`.9` examples are structurally invalid (NOT an engine bug)

**Major correction, from the user.** A `.spec` **top-level rule** (`::`) has **no regex of its own**:
it is the `_INITIAL` entry point, entered at startup, that runs a `while(1)` loop matching the regexes
of the **non-top (`:`) rules** and dispatching to them. A valid `.spec` therefore needs **at least two
rules** — the `::` entry rule plus ≥1 normal `:` rule carrying the regex(es).

Verified against the reference: `BootstrapSpec/Core.pm:414` (the rule-label line is the anchored
`\A LABEL (::|:) MODE \z` — a regex can't be part of it) and `:417` (`::`→target `_INITIAL`);
`RuleIR.pm:193-195` (`_INITIAL`→`top_rule`); and an audit of all 20 `specs/*.spec` (every top rule
`regex_on_top=no`).

**What this invalidates:**
- The `.10.1` "engine bug" verdict was **WRONG**. The single-rule `::AND … -> Rule[0] { return(...) }`
  examples returned `[]` because they are **structurally invalid** (a regex on the top rule, and only
  one rule), not because of an `AND_SINGLE_ACODE` regression. There is **no engine bug**, and the Perl
  reference is authoritative and **must not be touched**.
- `.5.2`'s 35 Scalar/Numeric examples **and the catalog "Worked examples" preamble** (which taught the
  `Demo:: /regex/ -> Demo { return(<expr>) }` scaffold), and `.9`'s §5.5 Pair example, all put a regex
  on the top rule — structurally invalid — and must be redone.

**This slice (records/correction only — no Perl, no book-example rewrite yet):**
- Deleted the mis-diagnosis KM card `docs/knowledge/and-single-acode-edge-return-dropped.md`; wrote
  `docs/knowledge/spec-top-rule-no-regex-two-rule-minimum.md` with the **verified 2-rule idiom**
  (modeled on `lib_reader.spec`/`tclite.spec`):
  ```text
  demo_top::  -> word_pair  .push
  LX {return(array_copy(a(demo_top)))}

  word_pair : /(\w+) (\w+)/  I.return(concat(entry_group(0), "-", entry_group(1)))
  ```
  Input `hello world` → `["hello-world"]`. The normal rule reads **`entry_group(N)`** (entry match),
  NOT `match_group(N)` (local match, unset in the child `I` block — the cause of an earlier `[null]`).
- Reframed `.10`: superseded `.10.1`'s verdict and the `.10.2` engine-fix-vs-doc fork; added
  remediation leaves `.10.3` (redo `.5.2` examples + preamble), `.10.4` (redo `.9` §5.5), `.10.5`
  (audit the other chapters flagged by `grep '::AND'`/`'-> \w+\[0\]'`).
- Saved durable guidance: `feedback_do-not-fix-reference-engine`, `feedback_spec-structure-top-plus-normal`.

Validation: `scripts/check_memory_architecture.sh` exit 0; KM gate regenerates `KNOWLEDGE_MAP.md`.
No Perl change; no `specs/*.spec` is affected (the shipped corpus already uses valid structure).
**FRESH SESSION recommended** to execute the remediation (`.10.3`+); repo left handoff-ready.

## 2026-06-17 — SPEC-LANG-REFERENCE.10.1: root-cause investigation — single-slot AND edge-return drop is a Perl-reference regression (not intended)

The user chose "investigate root cause first, then recommend before any change" for the `.9`-discovered
systemic drift (single-slot `::AND … -> Rule[0] { return(...) }` returns `[]`, not the value), and to
HOLD the PNT loop. This slice is that read-only investigation (no code/book change).

**Verdict: accidental regression in the Perl reference engine, NOT intended design.** A delegated
read-only codegen agent located the cause and I independently verified its three load-bearing claims
against source:

- **Root cause** — `_emit_and_single_acode_handler` (`perl/LinkedSpec/HandlerVariantEmitter.pm:564-630`):
  the loop at lines 575-582 builds `$transformed` for each edge acode but **never `push`es it** into
  `@acodes_transformed`, so `_build_acodes_dispatch_block(\@acodes_transformed)` (583) receives an empty
  list, the edge if/elsif dispatch is omitted, and the handler ends `return \@${label}_collect;` (628)
  over a never-written accumulator → `[]`. (Verified by reading the source.)
- **Provenance** — introduced by the MEDIUM-IMPACT.3.4.x emitter rework (`148c746` "apply
  return→assignment in AND_SINGLE_ACODE emitter" → `7fec186`); the sibling `_emit_and_acode_seq_handler`
  received the same edit **with** its `push` (so the omission is an oversight, not a degenerate-AND design).
  The sibling also has its own `\$"` list-separator bug in its return→assignment `s///e`.
- **Pre-documented gap** — `docs/knowledge/specentry-perl-coupling-inventory.md:234` already states
  "AND_SINGLE_ACODE and AND_ACODE lack E-block support … Adding E-block to AND_SINGLE_ACODE would fix
  MEDIUM-IMPACT.3.4." No `t/phase0_regression.t` assertion pins the `[]` runtime value as intended
  (single-regex-AND sites assert only metadata/descriptor/compilation).

**Behavioral matrix (verified via `LinkedSpec::Get`)** — single-slot AND `-> T[0] return`, terminal
`LX {return}`, terminal `E {return}`, and push+`LX` snapshot all → `[]`; whereas OR self-ref `-> T`,
multi-slot AND single-closing-slot return, and REP accumulate all surface their value.

A durable Knowledge Map card `docs/knowledge/and-single-acode-edge-return-dropped.md` was written (root
cause, provenance, verified idiomatic value-surfacing forms, reverify command) so the trap is not
re-derived.

`.10` was split into `.10.1` (this investigation — done) and `.10.2` (apply the fix — **blocked on a
user DIRECTION decision**): given it's a bug, (A) fix the engine (restore the edge-return path in
`AND_SINGLE_ACODE` + fix the sibling `\$"` bug + full `t/phase0_regression.t` gate + mirror in Rust for
parity; the intuitive book examples then become correct), (B) doc-rewrite only (to verified idioms), or
(C) both, sequenced. Recommended (A) or (C); if engine-fix, it belongs in a dedicated engine tree (not
this documentation tree). No code/book change in this slice; PNT loop remains held per the user.

## 2026-06-17 — SPEC-LANG-REFERENCE.9: fix drifted §5.5 Pair example output (+ surface a systemic variant)

`.9` corrects the confirmed defect `.5.2` discovered: the `runtime-semantics.md` §5.5 third
("Pair") example documented the output `["?pair:", "key", "val"]`, but its spec
(`Pair::AND … -> Pair[0] { return(array("?pair:", …)) }`) actually returns the empty accumulator
`[]`. Re-verified through `LinkedSpec::Get`: the `[]` result holds under default, `consume`, AND
`seek` parse modes (parse mode is not the variable), while the OR self-ref form
`Pair:: /(\w+)=(\w+)/ -> Pair { return(array("?pair:", match_group(0), match_group(1))) }` returns
`["?pair:", "key", "val"]`. Swapped §5.5 to that verified form and added a one-line note that the
self-referencing action edge (`-> Pair`) is what surfaces the `return(...)` value (§5.7 cross-ref).

§5.5/§5.6 sweep: the first two §5.5 examples are frozen Top→Done OR fixtures (correct); the §5.6
`object`/`manifest` snippets are `I.return` fluent forms on `:` body rules — a different construct
grounded in the shipped corpus, not the AND-`[N]`-self-edge class — and are left untouched (a faithful
standalone reconstruction is entangled with entry-group seeding per the `.4` lesson).

**Systemic finding (owned by new leaf `.10`, NOT fixed here — blocked on a user decision):** a
whole-book sweep (`grep -E '-> \w+\[0\]'` + `::AND`) shows the same single-slot
`::AND … -> Rule[0] { return(...) }` form is used in several other chapters that ALSO assert a
concrete top-level output — most importantly the canonical `user-model/worked-spec-walkthrough.md`,
which claims the output `{kind=>"pair", name=>"answer", value=>"42"}` for input `answer = 42` but
actually returns `[]` (verified). Ground-truthing against shipped specs (`portmap.spec`,
`hlink_substitution.spec`, `DT.spec`) confirms `-> Rule[N] { return(...) }` self-edges are a real
idiom — but on **multi-slot** rules returning at the closing slot (often an accumulator snapshot),
so the construct is valid; the drift is specifically single-slot `::AND` self-edge examples claiming
the `return` value as the output. The fix direction is a genuine fork — **engine-bug-fix** (make the
AND-self-edge `return` surface, fixing the Perl reference + Rust + oracle so the examples become
correct) vs **doc-rewrite** (rewrite the examples to a verified-producing form) — recorded as an
Open Question and surfaced to the user; `.10` is blocked until the direction is chosen.

Validation: `mdbook build` exit 0; corrected snippet re-confirmed through `LinkedSpec::Get`;
`scripts/check_memory_architecture.sh` exit 0. Frontier → `.5.3` (next unblocked leaf); `.10` blocked.

## 2026-06-17 — SPEC-LANG-REFERENCE.5.2: compile-verified worked examples for all Scalar + Numeric helpers

`.5.2` fills the example-density gap for the **Scalar (§2)** and **Numeric (§5)** families of
`docs/linkedspec-book/src/appendix/helper-contract-catalog.md` (which had 0 `.spec` examples). A
shared **Worked examples** preamble was added to §2 (with a §5 back-reference) defining the runnable
scaffold `Demo:: /<regex>/ -> Demo { return(<expr>) }` — a bare-`::` (OR/seek) top rule whose
self-referencing action edge returns the helper result, so the parser's top-level output *is* that
value (per `runtime-semantics.md §5.5`). An `Example` was then added to **all 35 helpers** (17 Scalar
+ 18 Numeric), with full `.spec` blocks for the high-frequency ones (`concat`, `trim`, `num_add`,
`num_sum`).

**Verification — nothing guessed (the `.4` discipline).** Every example was build-AND-run verified
through `LinkedSpec::Get` with a scratch oracle-style driver (build parser → run on the documented
input → JSON-encode the top-level value with the same `JSON::PP->canonical` encoder as
`tools/gen_oracle_corpus.pl`). The driver was sanity-checked against the two frozen oracle fixtures
(`rust/linkedspec-runtime/tests/corpus/proof_edge_{scalar,array}_literal`) and reproduced them
exactly, so its outputs are the reference behavior. All 35 examples produce the documented outputs.

**Two do-not-guess traps caught and avoided:**
- `is_defined` / `is_undefined` lower **only** via the control-flow path
  (`perl/LinkedSpec/ActionIR/FlowExpr.pm` `_lower_flow_composite_expr`, not the value-expression
  helper set at `FlowExpr.pm:270`), so `return(is_defined(x))` dies with "Undefined subroutine".
  They are documented in the verified `if (is_defined(x)) { … }` **condition-only** form with a usage
  note. The value-returning predicates (`matches`, `starts_with`, `ends_with`, `contains_substr`)
  ARE returnable and surface as `1`/`0`.
- `num_sum(split(...))` returns `null` (the `split → num_sum` composition does not flatten in this
  context). The array-form reducers (`num_sum`/`num_avg`/`num_median`/`num_range`, array
  `num_min`/`num_max`) are therefore documented with an explicit `array(...)` of capture groups or
  literals (verified: `num_sum(array(1,2,3,4))` → `10`); `split` is left to the Array family (`.5.3`).

**Discovered defect (owned separately by new leaf `.9`, not bundled here):** the §5.5
`runtime-semantics.md` "verified" Pair example (`Pair::AND … -> Pair[0] { return(array("?pair:", …)) }`)
actually outputs `[]`, not the documented `["?pair:","key","val"]`; the tagged array requires the OR
self-ref form `Pair:: … -> Pair { return(array(…)) }` (verified). `.3`'s live run used a self-ref-OR
shape that was mis-transcribed into the `AND`/`[0]` form. Recorded as a high-priority no-drift fix.

Validation: `mdbook build` exit 0; all documented snippets re-confirmed runnable through
`LinkedSpec::Get`; `scripts/check_memory_architecture.sh` exit 0. Frontier → `.9` then `.5.3`.

## 2026-06-17 — SPEC-LANG-REFERENCE.5.1: helper-catalog audit (0 completeness gaps) + variant-neutrality fixes + decomposition

`.5` (helper-contract catalog completeness + variant-neutrality + examples sweep) was **split**:
the surface is large, so this slice does the audit, the variant-neutrality fixes, and the
decomposition (ownership-first), and the example work becomes per-family sub-leaves.

A delegated read-only audit reconciled the `perl/LinkedSpec/ActionIR/Contracts.pm` helper-id set
against `docs/linkedspec-book/src/appendix/helper-contract-catalog.md`:

- **Completeness — 0 public-API gaps.** All ~130 public helpers are documented. The 158 (loose
  `\bid\b => '`) vs 146 (anchored) vs 140 (`###` headings) spread is **17 internal IR variants**
  (each maps to a documented DSL name, e.g. `capture_from_mark` → `capture_from(name)`) plus **~11
  deprecated `compatibility_surface => 1` contracts** (`my_declare_bare`, `exit_bare`, …) that are
  intentionally not public. Recorded so future sessions don't re-audit.
- **Variant-neutrality — 2 Perl-sigil leaks fixed.** `declare(scalar, name)` described "variable
  `$name`" → "named `name`" (line 13); `push(arr, child)` described "implicit accumulator
  `$rule_label`" → "named after the rule label" (line 159). Self-verified both at the cited lines,
  then re-swept the whole catalog for `$`/`@`/`%` sigils and `lowers to`/`do {`/`Data::Dumper`/
  `JSON::PP`/`//gcp` — **no others**.
- **Examples — 0 `.spec` examples across all 10 families / ~140 helpers.** The large remaining
  surface. Decomposed into per-family example sub-leaves: `.5.2` Scalar+Numeric, `.5.3` Array,
  `.5.4` Hash+Control Flow, `.5.5` Declaration/Capture-Mark/Entry-Match/Input/Call — each adding ≥1
  **compile-verified** (`LinkedSpec::Get`) example per family.

**Validation:** `mdbook build` exit 0; `scripts/check_memory_architecture.sh` exit 0; KM gate OK.
Documentation-only — no code/spec change. Frontier → `SPEC-LANG-REFERENCE.5.2`.

## 2026-06-17 — SPEC-LANG-REFERENCE.4: worked examples for grouped targets + entry-vs-match divergence (book)

Closes audit gaps **C** (grouped shared-code targets had no worked example) and **D**
(entry-vs-local-match lacked a divergence example).

- **Grouped action-edge targets** — new section in
  `docs/linkedspec-book/src/dsl/action-and-lifecycle-placement.md`: `-> RuleA | RuleB { ... }`
  binds one shared action block to multiple target rules (the block runs for whichever target
  matched). Grounded in the shipped `ebnf.spec` `semantic_annotation` rule and formal grammar §3.2;
  cross-linked. A minimal grouped-target spec was confirmed to **compile** via `LinkedSpec::Get`.
- **When `entry_*` and `match_*` diverge** — new section in
  `docs/linkedspec-book/src/dsl/capture-marks-and-source-locations.md`: a dispatched-child example
  (`Call` → `Inner` over `greet(world)`) where `entry_text()` reads the entering `greet(` match and
  `match_text()` reads the local `world` match (and likewise for the group/named readers). Cross-linked
  to the source-boundary "Entry versus match example". The example **compiles**.

**Verification (grounded, not guessed).** Both examples were compiled through the Perl reference.
The divergence semantics are grounded in `.2`'s verified source-wiring reading (`entry_*` = IMATCH /
the entering match; `match_*` = LMATCH / the local regex match) and are consistent with the book's
existing source-boundary example. **Honest scope note**: a clean *top-level runtime output* dump for
the divergence was deliberately **not** fabricated — ~9 minimal accumulator/dispatch shapes were run
and all collapsed to `[]`/`undef`/`0` (the hard accumulator-/child-return divergence axes documented in
`docs/knowledge/rust-perl-output-oracle.md`), so the divergence is documented at the verified
reader-wiring level (which span each family reads), matching the book's established style.

**Validation:** `mdbook build` exit 0; `scripts/check_memory_architecture.sh` exit 0; KM gate OK.
Documentation-only — no code/spec change. Frontier → `SPEC-LANG-REFERENCE.5`.

## 2026-06-17 — SPEC-LANG-REFERENCE.3: the output / return-value shape contract (book)

Closes the CRITICAL **GAP B** from the `.1` audit: the output/return-shape contract was
undocumented, so a new backend had to reverse-engineer the AST shape from `tests/corpus/`.

Expanded `docs/linkedspec-book/src/appendix/runtime-semantics.md §5` (renamed *Accumulator
Convention* → *Accumulator and Output Shape*) with four new subsections:
- **§5.5 What a Parser Returns** — a parser returns the top rule's value directly, with no
  envelope; the output type is whatever the rule builds (scalar/array/hash). Three verified
  input→output pairs.
- **§5.6 The Output Shape Is the Author's Choice** — the engine imposes **no output schema**.
  The `["?<rule>:", …]` tagged array is presented as an **optional, older convention** some
  specs use; the `"?...:"` tag is a plain string with no engine meaning, and authors are free
  to use any convention or none. (Reframed mid-leaf per user feedback that the tagged shape
  must not be shown as mandatory.)
- **§5.7 `return(...)` versus the accumulator** — the return value channel vs the implicit
  accumulator; a child's `return(...)` is consumed explicitly by the parent
  (`push_value(array(results), call(Child))`), not auto-appended to the parent accumulator.
- **§5.8 Backend Output Reconciliation** — the one-level wrap: the reference value is canonical;
  an accumulator-returning runtime (e.g. the Rust `execute`) wraps one level, and the oracle
  stores the reference value and compares a wrapping backend against `[reference]`.

**Verification (grounded, not guessed — the leaf required it).** The two literal examples are
frozen oracle-corpus fixtures
(`rust/linkedspec-runtime/tests/corpus/proof_edge_{scalar,array}_literal/expected.json`); the
tagged `["?pair:","key","val"]` example was produced by **running the Perl reference**
(`LinkedSpec::Get` on a `/(\w+)=(\w+)/` spec over input `key=val` — which also re-confirmed
`.2`'s `match_group(0)`=first-capture finding end-to-end); the tagged convention was confirmed by
grepping shipped specs (`ds_vhistory`/`portmap`/`vhdl`/`regdef`); and the wrap +
return-vs-accumulator contract is grounded in `docs/knowledge/rust-perl-output-oracle.md`. A
hand-built accumulator example that returned `[undef,undef,undef]` was **discarded** rather than
documented — repeated-rule accumulator mechanics are subtle, so only verified material was used.

**Validation:** `mdbook build` exit 0; `scripts/check_memory_architecture.sh` exit 0; KM gate OK.
Documentation-only — no code/spec change. Frontier → `SPEC-LANG-REFERENCE.4`.

## 2026-06-17 — SPEC-LANG-REFERENCE.2: regex as a first-class `.spec` concept (book) + capture-indexing drift fix

Closes the CRITICAL **GAP A** from the `.1` audit: regex was documented only at the syntax level
(`appendix/formal-grammar.md §3.1`) with no mental model, no worked examples, and no statement of
the regex feature set a backend must support.

**New chapter** `docs/linkedspec-book/src/user-model/regex-in-spec.md` (registered in `SUMMARY.md`
after *Rule Modes and Parse Modes*), variant-neutral, covering:
- the `/pattern/` literal — `/` delimiter, `\/` escaping, and **inline** flags via `(?i)`/`(?m)`/`(?s)`/`(?s:…)` modifier groups (no `.spec`-level flag layer);
- **regex slots / clusters** — multiple `/.../` per paragraph as ordered sequence (AND) vs alternatives (OR), `-> Rule[N]` slot targeting, and which-alternative branch tracking that drives dispatch;
- `seek` vs `consume` anchoring (cross-linked to the parse-modes chapter);
- **capture groups** — numbered `(...)` → `entry_group(N)`/`match_group(N)` (**0-based, captures-only — group 0 is the first capture, not the whole match — and the list is compacted so non-participating groups shift the indices after them**); named `(?<name>...)` → `entry_named(name)`/`match_named(name)`/`entry_has`/`entry_map`; the **compaction gotcha** with a worked `(\d+)?([a-z]+)` example + the named-group remedy; and the `entry_*` (entering match) vs `match_*` (local match) distinction;
- **"What a backend's regex engine must support"** — the verified, backend-neutral feature-set contract (position-tracked matching; `seek`/`consume` anchoring; N-way alternation + branch identification; numbered groups 0-based/captures-only/compacted; named groups), cross-linked to `appendix/backend-handoff.md`.

**`appendix/formal-grammar.md §3.1`** expanded with the capture-group contract (numbered + named, the
group-0/compaction clarification) and an inline-flags clarification.

**Verification (no guessing — the leaf required it).** Every engine fact was checked read-only against:
`perl/LinkedRE.pm` (`oredRE` joins slots with `|` + `(?{$pos=N})` branch tracking; `_build_match_info`
builds `match` = `${^MATCH}`, `match_list = [grep {defined} $1..$N]` (compacted), `match_hash = {%+}`);
the ActionIR lowering in `perl/LinkedSpec/ActionIR/Contracts.pm` (`entry_group(N)`→`$IMATCH_LIST[N]`,
`match_group(N)`→`$LMATCH_LIST[N]`, `entry_named`/`match_named`→`%IMATCH_HASH`/`%LMATCH_HASH`); the
`/pattern/` recognizer in `perl/LinkedSpec/BootstrapSpec/Core.pm` (`(?<!\\)\/.+?(?<!\\)\//`); and the
Rust runtime `rust/linkedspec-runtime/src/helpers.rs` (`CompiledAlternation` + rgx `matched_branch_number`
+ per-branch `group_offset` + named HashMap) — confirming backend parity. Cross-checked against shipped
specs (`lib_reader.spec`, `tablegrep.spec`, `spec.spec`) which all use `entry_group(0)` = first capture.

**Drift correction (correctness bug found during verification).** The book contradicted itself on
capture indexing: `appendix/helper-contract-catalog.md` stated `entry_group` index "0 is the full match",
while `user-model/worked-spec-walkthrough.md` (correctly) said index 0 is the first capture group. The
verified behavior is the latter. Corrected:
- `appendix/helper-contract-catalog.md` — rewrote the `entry_group(index)`/`entry_groups()` contract (0-based, captures-only, compacted; whole match via `entry_text()`);
- `overview/what-is-linkedspec.md` — `/(\w+)=(\w+)/` example used `entry_group(1)`/`entry_group(2)` (wrong 1-based) → `entry_group(0)`/`entry_group(1)`;
- `appendix/formal-grammar.md` — the `Child` demo rule `/hello[ \t]+(\w+)/` read `entry_group(1)` → `entry_group(0)`;
- `dsl/source-boundary-helper-reference.md` — added a captures-only/compacted clarifier next to the group-reader tables.

This closes the capture-group-mapping accuracy concern, so `.5` (helper-catalog completeness/neutrality
sweep) need not re-litigate the indexing contract.

**Validation:** `mdbook build` exit 0 (pre + post); whole-book grep confirms no remaining "index 0 = full
match" claims; `scripts/check_memory_architecture.sh` exit 0. Documentation-only — no code/spec change.
Frontier → `SPEC-LANG-REFERENCE.3`.

## 2026-06-17 — SPEC-LANG-REFERENCE.1: audit + decomposition for complete variant-agnostic `.spec` book coverage

Owns the user request: make the mdBook fully + variant-agnostically document the **entire `.spec`
language surface** with abundant examples, so the next backend (Julia/Dart/…) needs no archaeology;
add KM cards. New tree `docs/tasks/SPEC-LANG-REFERENCE.md` (created + registered in this commit,
ownership-first). This leaf is the **audit** (audit-only, no book change) — per the splitting
discipline, the audit is the decomposition.

Two read-only agents ran in parallel: (1) an authoritative `.spec` surface inventory from the code
(`BootstrapSpec/Core.pm`, `Validation.pm`, `ActionIR/Contracts.pm` (158 contracts), `specs/spec.spec`,
shipped specs); (2) a book coverage map over all `user-model`/`dsl`/`compiler`/`appendix` chapters,
scoring each surface area. Synthesis (recorded in the tree's "Audit Findings"):
- **8 of 10 surface areas already WELL-COVERED**: rule labels, rule modes, parse modes (seek/consume),
  edges, lifecycle markers, capture/marks, helper catalog, control flow.
- **2 binding gaps**: (A→`.2`, CRITICAL) regex is defined only at the syntax level
  (`appendix/formal-grammar.md:111-127`) with no mental model, no examples, and no statement of the
  regex feature set a backend must support; (B→`.3`, CRITICAL) the output/return-shape contract is
  undocumented — backends reverse-engineer the AST shape from `tests/corpus/`.
- Minor gaps: grouped shared-code targets `-> A | B { ... }` example (`.4`), entry-vs-local-match
  divergence example (`.4`), helper-catalog example density + Perl-note separation (`.5`), a
  capture/mark cross-example (`.6`); KM cards (`.7`); finalize (`.8`).

Decomposed into leaves `.2`–`.8` (see the tree). One inventory claim was **rejected on verification**:
the surface agent called lifecycle markers `E`/`IT` "deprecated", which contradicts the completed
`LIFECYCLE-FAMILY-AUDIT` (all 7 markers equivalent/supported) — not propagated. `scripts/check_memory_architecture.sh`
exit 0; KM gate green. No book content changed (audit only). Frontier → `.2`.

## 2026-06-17 — DOC-DRIFT-SYNC.2: fix transposed :& / :| rule-mode cells in formal-grammar.md (TREE COMPLETE)

Surgical correctness fix in `docs/linkedspec-book/src/appendix/formal-grammar.md` §2.2 (Rule
Modes). The `:&` and `:|` description cells were transposed, inverting their AND/OR sense
relative to the authoritative bootstrap mode map `perl/LinkedSpec/BootstrapSpec/Core.pm:347-348`
(`'&' => 'AND'`, `'|' => 'OR'`) and the dedicated chapter `user-model/rule-modes-and-parse-modes.md`:
- `:&` was "single-match choice (`:OR{1}`)" → now **"Ordered sequence (equivalent to `:AND`)."**
  (`:&` ≡ `:AND`; chapter §"Ordered sequence: `:&` and `:AND`", lines 35/97-99).
- `:|` was "Ordered sequence (equivalent to `:AND`)" → now **"Single choice — one successful
  alternative wins (`:OR{1}`)."** (`:|` is single-choice dispatch, explicitly NOT the
  repeated-choice family; chapter §"Single choice: `:|`", lines 42/137-139/159).

A grep confirmed no other `:&`/`:|`/"single-match" reference in `formal-grammar.md`; the §2.2
"Semantics" note (AND vs OR modes in general) was already correct. `mdbook build` exit 0;
`scripts/check_memory_architecture.sh` exit 0; KM gate green. No code change.

This closes the `DOC-DRIFT-SYNC` tree (both leaves done); it moves to Completed in
`docs/TASK_TREE.md`, leaving `RUST-PARITY` (frontier `.7.5.3`) the sole active tree.

## 2026-06-17 — DOC-DRIFT-SYNC.1: sync ROADMAP.md to ROADMAP_V2.md (Phase 8/9 + Overall done)

Zero-drift correction (doctrine: `docs/decisions/0001` §4; `ROADMAP_V2.md:425`). A bootstrap-
session audit found `ROADMAP.md` lagging its execution companion `ROADMAP_V2.md`: the Status
table marked Overall `mostly done` (scope "phases 0-7"), carried **no Phase 8 / Phase 9 rows**,
and never narrated Phases 8–9 in the long-form Work Phases section, while `ROADMAP_V2.md:56,66-67`
marks Overall `done` with Phase 8 (multi-backend handoff) and Phase 9 (Rust variant, v0.1
operational) both `done`. Verified directly against source before fixing.

Changes to `ROADMAP.md` (only):
- Added `## Phase 8: Multi-Backend Specification and Handoff Surface` and `## Phase 9: Rust
  Variant Implementation` long-form sections after Phase 7 / before the Backbone Refactor Track,
  mirroring the completed `PHASE8-MULTI-BACKEND-HANDOFF` / `PHASE9-RUST-VARIANT` trees. The Phase 9
  section points at the active `RUST-PARITY` follow-on (full Perl-reference parity), so the
  long-form roadmap does not over-claim Rust completeness.
- Inserted Phase 8 + Phase 9 rows in the Status table after the Phase 7 row.
- Flipped the Overall row `mostly done` → `done`, covers/remaining aligned to `ROADMAP_V2.md:56`
  (phases 0–9, mdBook variant-agnostic, full Rust parity tracked under `RUST-PARITY`).

`ROADMAP_V2.md` is the canonical high-level status tracker (per `docs/TASK_TREE.md` "Relationship
To Live Docs"), so the sync flows `ROADMAP_V2.md` → `ROADMAP.md`; V2 itself was already correct
and is unchanged. No code or book change. Dismissed non-drift from the same audit (recorded as a
Non-Goal in `docs/tasks/DOC-DRIFT-SYNC.md`): the "158 vs 146 helper contracts" flag — the book's
158 is reproducible (`grep -cE "\bid\b => '" ActionIR/Contracts.pm`); the 146 used a narrower grep.
Validation: `scripts/check_memory_architecture.sh` exit 0; KM gate green. Owning tree
`docs/tasks/DOC-DRIFT-SYNC.md` created in this same commit (ownership-first). Frontier → `.2`.

## 2026-06-17 — RUST-PARITY.7.5.1: fix the header-line-regex → 0-regex parser bug (Rust)

Fixed `rust/linkedspec-core/src/parser.rs:86`: the rule-header regex
`^(\w+)[ \t]*(::|:)[ \t]*(\S*)[ \t]*(.*)` used `(\S*)` for the mode-suffix group, which
greedily swallowed a `/…/` regex written on a rule's header line; `parse_mode_suffix("/;/")`
then returned `RuleMode::Default` and the regex was silently dropped (never reaching `rest`/the
body). So a single-regex header rule (`semi_colon : /;/`) registered 0 regexes — and a
`/open/ /close/` bracket pair registered only 1 (group 3 ate the open) — making every
`-> child[N]` dispatch edge "never fire". It bit `:` and `::` rules alike; the passing tests
and `::` top-rules only escaped it by putting the regex on a separate body line.

**Fix:** narrow group 3 to `([^\s/]*)` so a `/`-led regex falls through to group 4 (`rest`),
where `parse_inline_body` registers it. One char class; every real mode suffix
(`AND`/`OR+`/`&`/`*`/`?`/`AND{2,4}`) is slash-free, so behavior is identical for all non-regex
header content. The second header regex (`parser.rs:270`, in `collect_body`) is detection-only
with a trailing `*` group and was correctly left unchanged.

**Bracket pairs repaired (not just preserved):** `command_subst : /open/ /close/` now registers
`[open, close]` (entry idx 0 = open; the self-recursive `-> command_subst[1]` resolves to idx 1
= close via the self-recursive branch of `build_dependency_regex_map`) — the recursive bracket
matcher tclite/Lispish intend (before the fix `[1]` was out-of-bounds and entry matched the
*close*).

**Tests:** 4 new unit tests — `parser.rs`: `header_line_single_regex_is_registered`,
`header_line_bracket_pair_registers_open_then_close`,
`header_line_mode_suffix_still_parsed_without_regex`; `compiler.rs`:
`header_line_bracket_pair_self_recursive_close_edge_resolves`. `cargo test --manifest-path
rust/Cargo.toml` = **242 passed / 0 failed** (238 baseline + 4; `linkedspec_core` 90→94;
corpus_oracle stays 1 green proof). `cargo clippy -p linkedspec-core -p linkedspec-runtime
--tests` warning multiset = baseline (linkedspec-core 10 / linkedspec-runtime 13 /
validation.rs 4 — zero-new). (Pre-existing, unrelated: clippy `--tests` exits 101 on
`approx_constant` deny-errors in untouched test floats `expr.rs:687` / `types_test.rs:143`.)

**PNT split — the fix is necessary but NOT sufficient for tclite.** With the regexes now
registering, the oracle still showed tclite `[]` → `[]`: tclite accumulates via fluent
continuations on ACTION edges (`-> command_subst .push`, `-> command_subst[1] .return(...)`),
but the Rust parser attaches a `.method` fluent chain only to a BLIND edge (`=>`,
`parser.rs:443`); after a `->` edge the `.push`/`.return(...)` parses as a standalone
`FluentChain` element the compiler discards (`compiler.rs:171`). That independent gap is the
new leaf **`RUST-PARITY.7.5.3`** (action-edge fluent lowering — greens tclite); the tclite
oracle cases were re-deferred in `tools/gen_oracle_corpus.pl` (corpus back to 2 green proofs)
so `cargo test` stays green. Lispish is unaffected by `.7.5.3` (it uses `{ code }` blocks) —
its remaining blocker is `.7.5.2` (scalaref). Knowledge card
`docs/knowledge/rust-perl-output-oracle.md` corrected. `scripts/check_memory_architecture.sh`
exit 0. Frontier → `.7.5.3`.

## 2026-06-17 — RUST-PARITY.7.5: split into parser-header-regex (.7.5.1) + scalaref-hash-literal (.7.5.2)

Tree structuring only (no code). A read-only investigation + a direct read of
`rust/linkedspec-core/src/parser.rs:86` located the two independent root causes of the
`.7.1` oracle's shipped-spec divergence and confirmed they are separable (PNT rule 5):

- `.7.5.1` — header-line-regex → 0-regex parser bug. `parser.rs:86`'s header regex
  `^(\w+)[ \t]*(::|:)[ \t]*(\S*)[ \t]*(.*)` uses `(\S*)` for the mode suffix, which
  greedily swallows a `/…/` regex placed on the header line; `parse_mode_suffix("/;/")`
  falls to `RuleMode::Default` and the regex is discarded, so `-> child[0]` edges "never
  fire". It bites `:` and `::` rules alike — the passing tests/`::` top-rules dodge it
  only by putting the regex on a separate body line. Fix sketch `(\S*)`→`([^\s/]*)`.
  Foundational (every header) — the open/close-pair (`command_subst`/`parenthesis`/
  `curlyb`) semantics, the full suite, and the oracle (re-enable tclite) must be verified.
- `.7.5.2` — `expr.rs:299` has no `{` case, so `scalaref(retv, {content})` (Lispish)
  raises `unexpected character '{'`; needs a new `Expr` variant + parser + engine
  semantics. Larger; depends on `.7.5.1`.

`scripts/check_memory_architecture.sh` exit 0; no code touched. Frontier → `.7.5.1`.
A fresh session is recommended for the foundational parser fix.

## 2026-06-17 — RUST-PARITY.7.1: Perl↔Rust output-oracle mechanism + green first proof

Built the cross-variant output oracle (ADR 0006 §Phase 8.6) and proved it end-to-end.

New files:
- `tools/gen_oracle_corpus.pl` — a timeout-guarded (`alarm`, default 15s — RTLUtils-hang
  safe) Perl generator. For each `(spec, input)` case it runs the reference parser and
  writes one corpus directory per case: `rust/linkedspec-runtime/tests/corpus/<case>/`
  containing `input.spec` (the grammar, verbatim), `input.txt` (exact input bytes), and
  `expected.json` (the reference top-rule value, `JSON::PP->canonical(1)` so regeneration
  is byte-stable). A case is a shipped spec (`spec => 'tclite'`) or an authored inline
  grammar (`source => "..."`). This is exactly the per-entry corpus format the book's
  `appendix/backend-handoff.md` already documents — adopting it adds zero drift.
- `rust/linkedspec-runtime/tests/corpus_oracle.rs` — the fixture-runner. Enumerates the
  corpus, runs `parse_spec → validate → compile → Engine::new → execute(input.txt)`, and
  asserts `engine.execute(input) == json!([expected])`. Reports every entry (PASS/FAIL)
  and fails once at the end, so a single run surfaces all divergences.
- `rust/linkedspec-runtime/tests/corpus/README.md` — documents the format + the wrap rule.
- `docs/knowledge/rust-perl-output-oracle.md` — knowledge card (mechanism + findings).

Output-shape rule (reconciled + documented): the Perl reference returns the top rule's
value directly; the Rust engine wraps the accumulator one level (`engine.rs` `execute`
returns `Array(accumulator)`). So `expected.json` stores the backend-neutral reference
value and the runner wraps it: `execute(input) == [expected]`.

The oracle's first run disproved the `.7`-split assumption that the Perl↔Rust gap on the
named proof specs is only the wrap. Both shipped proof specs diverge in Rust:
- tclite on `[]` → `[]` (Perl: `["?tcl_script:",[["?command_subst:",[]]]]`).
- Lispish on `(x y)` → `exit_now(1)` (Perl: `["x",["y"]]`).
Shared root cause: a single-regex rule written `name : /re/` (single colon; incl. the
inline `name : /re/  I.return(...)` form) compiles in Rust as **0-regex**, so every
`-> child[0]` dispatch edge "never fires" (`::` single-regex rules are unaffected).
Lispish additionally needs the `scalaref(retv, {content})` hashref-field accessor parsed.
These are engine/parser surgery, not oracle-mechanism work, so they are deferred to the
new leaf `RUST-PARITY.7.5` (now first in the frontier, blocking `.7.2`/`.7.3`).

The mechanism is proven green on two controlled authored grammars (parent→child dispatch,
literal edge return, action-less child) that avoid every divergence source — scalar
`"scalar-ok"` → `["scalar-ok"]` and nested array `["?proof:","ok"]` → `[["?proof:","ok"]]`.

Validation: `perl -c tools/gen_oracle_corpus.pl` OK; `cargo test --manifest-path
rust/Cargo.toml` = **238 passed / 0 failed** (237 baseline + 1 `corpus_oracle`); `cargo
clippy -p linkedspec-core -p linkedspec-runtime --tests` = core 10 / runtime 13 /
validation.rs 4 = baseline (zero-new; `corpus_oracle.rs` clean);
`scripts/check_memory_architecture.sh` exit 0. No book change (corpus format already
matched; the wrap-rule book note is deferred to `.7.4`/`.9`).

## 2026-06-16 — RUST-PARITY.7: split into Perl↔Rust output-oracle sub-leaves (.7.1–.7.4)

Tree structuring only (no code). PNT reached the broad `.7` leaf ("all 20 shipped specs
exercised in Rust + corpus files + regression guard") and a two-agent read-only
investigation (Rust test/corpus infra + Perl reference output path) confirmed it must be
split (PNT splitting rules — bundles independently-reviewable work and discovers a
lower-level dependency to solve first).

Findings driving the split:
- No oracle mechanism and no canonical cross-variant output form exist yet (the Rust
  corpus is 4 inline tests; the Perl side has input fixtures for only ~3 specs).
- Output-shape reconciliation is required: the Perl reference returns the top rule's value
  **directly** (`tclite` `[]` → `["?tcl_script:",[["?command_subst:",[]]]]`; `Lispish`
  `(x y)` → `["x",["y"]]`), whereas the Rust engine returns the accumulator **wrapped one
  level** (`[<value>]`).
- ~16 of the 20 specs have no input fixtures (authored inputs required).
- The `RTLUtils` catastrophic-backtrack hang needs a hard-timeout guard in any
  Perl-over-corpus run.

Architecture (recorded as the split decision): the oracle is a **fixture generator**, not
a live cross-process comparison — a timeout-guarded Perl tool emits canonical-JSON
fixtures (`JSON::PP->canonical(1)`) into `rust/linkedspec-runtime/tests/corpus/`, and a
Rust fixture-runner integration test compares `engine.execute(input)` against the
checked-in fixtures. This keeps `cargo test` Perl-free and realizes ADR 0006 §Phase 8.6's
language-neutral corpus. Sub-leaves: `.7.1` mechanism + canonical form + first proof
(tclite/Lispish); `.7.2`/`.7.3` corpus batches; `.7.4` drift guard + finalize.

Validation: documentation/task-tree only — `scripts/check_memory_architecture.sh` gates;
no `cargo`/`prove` run warranted (no code touched). Frontier → `.7.1`.

## 2026-06-16 — RUST-PARITY.6: strict_syntax validation mode in the Rust variant

Closes the audit's Gap 4 — the Rust validator had 6 hard checks but no strict mode. Brings
`rust/linkedspec-core/src/validation.rs` to parity with the Perl reference
`Validation.pm validate_dsl_syntax(..., strict_syntax => 1)` (~705–741).

API:
- `validate(spec)` is now a thin non-strict wrapper (`= validate_with_options(spec, false)`),
  so all ~70 existing call sites are untouched.
- New `validate_with_options(spec, strict_syntax: bool)` runs the same 6 checks, plus
  `check_unused_rules` when strict.

Semantics (the Perl reference emits two reference *warnings*; strict promotes both to hard
errors, undefined first):
- **Unused** (`defined − used`, a rule referenced by no edge) → strict error via
  `check_unused_rules`. The **top rule is not exempt** — an unreferenced top rule is
  flagged. Verified empirically against the reference (`Top:: -> Child` strict → "Unused
  rule(s): Top").
- **Undefined** (`used − defined`) is already a hard error here in every mode
  (`check_edge_targets`), stricter than the reference's default (a warning). Left as-is (a
  pre-existing, recorded divergence; relaxing it would break a landed test). Because
  `check_edge_targets` runs before the strict check, the reference's undefined-before-unused
  order is preserved, so strict mode's only new observable behavior is the unused-rule
  rejection.

Validation: `cargo test --manifest-path rust/Cargo.toml` = 237 passed / 0 failed (233
baseline + 4 new `validation::tests::validate_strict_*`/`_nonstrict_*`). `cargo clippy
--manifest-path rust/Cargo.toml -p linkedspec-core --tests` validation.rs warnings 4 =
baseline 4 (pre-existing `collapsible_match`; zero new); `-p linkedspec-runtime --tests` 13
= baseline 13 (unchanged — the change is in `linkedspec-core`). No book change (the strict
contract is already documented in `compiler/pipeline-overview.md`; Rust now conforms — book
sync is `.9`). New knowledge card `docs/knowledge/rust-strict-syntax-validation.md`.

## 2026-06-16 — RUST-PARITY.5.5.4: anonymous capture-slice family in the Rust engine (+ catalog §7 entries)

Fourth and final child of the `.5.5` helper-gap split — this closes `.5.5` and `.5` (every
real Rust↔Perl parity-gap child from the audit is now done). Implemented the **anonymous**
capture-slice family (the counterpart of the `.5.5.3` named-mark family) and fixed the
pre-existing `capture_slice` / `capture_slice_len` endpoint. Authoritative contract:
`perl/LinkedSpec/ActionIR/Contracts.pm` ~366–656.

These readers operate on the single anonymous capture cursor `ctx.capture_start` (Perl
`$IPOS`, set by `start_capture_slice()` — normally from an `I`-block, which runs before the
rule's seek, so it records a position at/before the match start).

**Endpoint fix:** `capture_slice` / `capture_slice_len` read to `ctx.pos` (the cursor /
match-end); they now read to `ctx.match_start_byte` (match-start, Perl `$LSPOS - length
$LMATCH`) — the anonymous analog of the `.5.5.3` `capture_from` fix. The two landed tests
`helpers_5_2_capture_slice_basic` / `helpers_5_2_capture_slice_len` were updated to the
parity-correct values (`"hello"` → `""`, `>0` → `0`): capture started at the match start, so
nothing precedes the match.

New `call_helper` arms in `rust/linkedspec-runtime/src/engine.rs` (reusing the `.5.5.3`
guarded `span_text` / `span_char_len`):
- readers to **match-start**: `capture_take`, `capture_take_len` (read to match-start, then
  advance `capture_start` to the cursor);
- readers to the **cursor**: `capture_slice_until_cursor`, `capture_slice_until_cursor_len`,
  `capture_take_until_cursor`, `capture_take_until_cursor_len`;
- readers to **end-of-input**: `capture_rest`, `capture_rest_len`, `capture_take_rest`,
  `capture_take_rest_len`.

`_take_*` advance `capture_start` to the cursor (or end-of-input for the `_rest` forms),
mutating only on a valid span. Text readers return the raw slice; `_len` readers return the
**char** count (DSL lengths are char-based, `.5.3`); a reversed/out-of-range span → `undef`.

**Scope:** the leaf named 7 inventoried anonymous variants, but `Contracts.pm` showed the
`RUST-PARITY.1` inventory itself omitted the same-family `capture_rest` / `capture_rest_len` /
`capture_take`; all 10 missing anonymous helpers landed together so the family is complete.
The separately-discovered mark/match/entry-anchored helpers (`mark_match_*`, `mark_entry_*`,
`capture_take(mark)`, `capture_take_between`) stay a deferred follow-up.

**Book:** `docs/linkedspec-book/src/appendix/helper-contract-catalog.md` §7 — added the 10
anonymous-variant entries, extended the §7 intro endpoint list, and refined the destructive
`_take_*` note (the take readers advance to the cursor, not the read endpoint). The
`capture_slice` match-start contract was already documented (the `.5.5.3` gap, now closed by
the engine fix). Variant-agnostic, no-drift.

**Validation:** `cargo test --manifest-path rust/Cargo.toml` = 233 passed / 0 failed (223
baseline + 10 new `helpers_5_5_4_*`). `cargo clippy --manifest-path rust/Cargo.toml -p
linkedspec-runtime --tests` source warnings 13 = baseline 13 (11 engine.rs + 2 helpers.rs,
all pre-existing; vendored pgen/rgx-core ignored). `mdbook build` exit 0. New knowledge card
`docs/knowledge/rust-anonymous-capture-slice-family.md`.

## 2026-06-16 — RUST-PARITY.5.5.3: mark-based capture family in the Rust engine (+ catalog §7 fix)

Third child of the `.5.5` helper-gap split. Implemented the mark-based capture family the
audit's Gap 5 listed missing, and fixed the pre-existing `capture_from` endpoint to match the
Perl reference. Authoritative contract: `perl/LinkedSpec/ActionIR/Contracts.pm` ~690–1047.

**Open Question RESOLVED as option (a)** (user-confirmed): the non-cursor mark readers end at
the **start of the current local match** (`$LSPOS - length $LMATCH` = `ctx.match_start_byte`),
not the cursor. The landed `capture_from` arm read to `ctx.pos` (match-end); it now reads to
`ctx.match_start_byte`. The landed test `helpers_5_2_mark_and_capture_from` was updated from
asserting `"hello"` to `""` (mark 0, whole-input match → empty pre-match span).

New `call_helper` arms in `rust/linkedspec-runtime/src/engine.rs` (+ free helpers
`span_text`/`span_char_len`, guarded so a missing mark / reversed span yields `undef` instead
of panicking):
- readers to **match-start**: `capture_from` (fixed), `capture_len_from`, `capture_take_len_from`;
- readers to the **cursor**: `capture_until_cursor_from`, `capture_until_cursor_len_from`,
  `capture_take_until_cursor_from`, `capture_take_until_cursor_len_from`;
- readers to **end-of-input**: `capture_rest_from`, `capture_rest_len_from`,
  `capture_take_rest_from`, `capture_take_rest_len_from`;
- two-mark readers: `capture_between`, `capture_len_between`;
- setters: `mark_input_start` (→0), `mark_input_end` (→byte length), `mark_copy(target, source)`
  (**2-arg** — copy, or delete target when source unset).

`_take_` variants advance the named mark to the read's endpoint (cursor, or end-of-input for
`_rest_`). Text readers return the raw slice; `_len_` readers return the **char** count
(DSL lengths are char-based, `.5.3`).

**Book (catalog §7) corrected to the authoritative contract** (user-requested): `capture_from`
now documented as ending at the start of the current match (was "current position"); `mark_copy`
fixed to its 2-arg copy/delete form (was 1-arg); the `_until_cursor_`/`_take_` readers and the
anonymous `capture_slice`/`capture_slice_len` endpoint wording corrected; the missing
`capture_len_from`/`capture_len_between`/`_len_from` companions added. The catalog stays
variant-agnostic (describes the `.spec` contract).

**Discovered (recorded, out of scope):** the anonymous Rust `capture_slice`/`capture_slice_len`
arms still read to the cursor (a `.5.5.4` fix); `mark_match_start/end`, `mark_entry_start/end`,
`capture_take(mark)`, `capture_take_between(_len)` exist in `Contracts.pm` but are absent from
both Rust and the `RUST-PARITY.1` inventory (inventory gap, flagged for a follow-up leaf).

**Validation:** `cargo test --manifest-path rust/Cargo.toml` = **223 passed / 0 failed**
(207 baseline + 16 new `helpers_5_5_3_*` covering each helper + missing-mark/reversed-span undef,
`_take_` mutation, multibyte char-length, and the match-start vs cursor vs end-of-input endpoints).
`cargo clippy --manifest-path rust/Cargo.toml -p linkedspec-runtime --tests` = `linkedspec-runtime`
source warnings **13 = baseline 13** (11 engine.rs + 2 helpers.rs, all at pre-existing locations;
vendored pgen/rgx-core ignored). `mdbook build` exit 0; `scripts/check_memory_architecture.sh` exit 0.
New knowledge card `docs/knowledge/rust-mark-based-capture-family.md`. **Active frontier →
`RUST-PARITY.5.5.4`** (anonymous capture-slice variants).

## 2026-06-16 — ALIAS-RETIREMENT-DOC-SYNC.1: retire array-edge alias claims across book + roadmaps

Documentation-only zero-drift correction (new tree `ALIAS-RETIREMENT-DOC-SYNC`, 1 leaf, completed).
Driven by `RUST-PARITY.5.5.2`'s resolution that the array-edge aliases `tail` / `drop_last` /
`flatten` / `array_values` are **retired** (Perl reference no longer recognizes them; 0 shipped-spec
uses; 0 `t/` locks; "Retired" in the book Helper Contract Catalog), and by user direction that the
book/docs are the variant-agnostic universal-contract surface and must stay zero-drift — so this is
contract truth, not a "Perl-side" detail to defer.

Corrected 16 stale "remains/preserving … compatibility alias/syntax" claims to state retirement
(`COMPAT-ALIAS-RETIREMENT.1`), preserving each historical "Landed …" record:
- **book** `docs/linkedspec-book/src/appendix/formal-grammar.md:357` — `array_values(arr)` → "retired
  alias of array_copy"; the book is now internally consistent (its Helper Contract Catalog already
  marked these "Retired").
- **`ROADMAP_V2.md`** — line 182 (×3 claims + the follow-up-targets mention), 256, 257, 260, 262.
- **`ROADMAP.md`** — 735, 736, 993, 994, 997, 999, 1189, 1190, 1191, 1242.

Out of scope (Non-Goals): the capture aliases (`capture_slice_here`, `capture_from_rule_start`, …) and
the `entry_named_map`/`match_named_map` named-map aliases caught by the same grep — a different,
unverified alias category, left to a separate audit.

**Validation:** grep for remaining `tail`/`drop_last`/`flatten`/`array_values` retention claims = none;
`mdbook build` exit 0; `scripts/check_memory_architecture.sh` + `knowledge-map/scripts/check_knowledge_map.sh`
exit 0. No code change. Active Rust frontier unchanged → `RUST-PARITY.5.5.3`.

## 2026-06-16 — RUST-PARITY.5.5.2: input-boundary helpers + flat splice in the Rust engine

Rust engine code (`rust/linkedspec-runtime/src/engine.rs`). Second child of the `.5.5` helper-gap
split. Added 3 new `call_helper` arms and **resolved the leaf's parked alias-retirement Open
Question** against the Perl reference.

Helpers added (all to Helper Contract Catalog parity, §9 + §7):

- `input_end_line()` → `1 + (newline count over the whole input)` — parity with the Perl reference's
  `INPUT_END_LINE_READ` lowering (`Contracts.pm:1255`). Newline counts are byte/char identical, so a
  plain `'\n'` filter suffices.
- `input_end_col()` → char distance past the last newline, `+1` when the input has none — parity with
  `_build_column_read_expr(pos_expr => 'length($$STRING)')` (`Contracts.pm:111,1266`), modeled on the
  existing char-based `cursor_col` (`.5.3`) but at end-of-input; multibyte-correct.
- `flat(container)` → generic list-context splice (Perl `MethodLowering.pm:199`): an Array splices its
  elements, a Hash splices its key/value entries, any other value becomes a single-element list —
  consistent with the established `flat_array` (Array→Array) and `flat_hash` (Hash→Hash) representation,
  so a parent `array(...)`/`hash(...)` consumes it the same way.

**Open Question resolved (alias retirement, against the Perl reference):** the Perl reference does NOT
recognize `tail`/`drop_last`/`flatten`/`array_values` — they are absent from every helper-recognition
regex (`BootstrapSpec/Core.pm:82`, `FlowExpr.pm:81,270`, `MethodLowering.pm:1627,1635`), unused in all
20 shipped specs, and not regression-locked in `t/phase0_regression.t` (grep count 0). They were retired
in `COMPAT-ALIAS-RETIREMENT.1`; the book catalog §Compatibility-Aliases lists them "Retired". For
cross-variant **parity** the Rust variant must match the reference's recognized surface, so the three
retired aliases are deliberately NOT added (an explicit `engine.rs` comment records this) — only the
canonical `flat` was missing and is added. (`ROADMAP_V2.md` lines 256–262 still call `tail`/`drop_last`
"compatibility alias" — stale pre-retirement text flagged for a separate Perl-side doc-sync slice.)

**Validation:** `cargo test --manifest-path rust/Cargo.toml` = 207 passed / 0 failed (204 baseline + 3
new `helpers_5_5_2_*`: `input_end_line` newline-count, `input_end_col` char-based incl. multibyte +
trailing-newline, `flat` array + hash-into-parent splice). `cargo clippy --manifest-path rust/Cargo.toml
-p linkedspec-runtime --tests`: `linkedspec-runtime` lib = 13 warnings = stashed baseline 13 (zero new;
integration_test's lone `len_zero` at :199 pre-existing per MEMORY; vendored pgen/rgx-core ignored).
No book change (catalog §9 documents `input_end_line`/`input_end_col`, §Compatibility-Aliases marks the
three retired — Rust now conforms; book sync is `.9`). New knowledge card
`docs/knowledge/rust-retired-array-aliases-not-added.md`. **Active frontier → `RUST-PARITY.5.5.3`**
(mark-based capture family `capture_*_from`/`_between`, `mark_*`).

## 2026-06-16 — RUST-PARITY.5.5.1: named-group reader helpers in the Rust engine

Rust engine code (`rust/linkedspec-runtime/src/engine.rs`). First child of the `.5.5` helper-gap
split. Added the 8 named-capture reader helpers from the audit's Gap 5, to Helper Contract Catalog
§8 parity, as new arms in `call_helper`:

- `entry_named(name)` → the named entry-capture's value as a string, or undef if absent;
- `entry_has(name)` → boolean presence of the named entry-capture;
- `entry_map()` / `entry_named_map()` → all named entry-captures as a hash (`entry_named_map` is the
  retired alias of `entry_map`, accepted for legacy specs — identical behavior);
- `match_named(name)` / `match_has(name)` / `match_map()` / `match_named_map()` → the same four for
  the LOCAL match.

The entry readers read `ctx.entry_named`, the match readers read `ctx.match_named` — both already
exist on `RuntimeContext`, populate from the regex `MatchResult.named` (engine.rs:280/291), and
save/restore per invocation in `SavedMatchState`, so this is a purely additive 8-arm change with no
struct or population changes. The `entry_*` arms cluster after `entry_groups`; the `match_*` arms
after `match_groups`, mirroring the existing entry/match organization. A small free helper
`named_map_to_hash` materializes a named-capture map into a `RuntimeValue::Hash` with **keys sorted**
so the projection is deterministic (matching `sorted_keys`/`sorted_values`), independent of host
`HashMap` iteration order.

**Validation:** `cargo test --manifest-path rust/Cargo.toml` = 204 passed / 0 failed (198 baseline +
6 new `helpers_5_5_1_*`: entry_named present/absent, entry_has present/absent, entry_map + alias,
match_named present/absent, match_has present/absent, match_map + alias — exercised end-to-end with
`(?P<name>…)` named-group regexes). `cargo clippy --manifest-path rust/Cargo.toml -p
linkedspec-runtime --tests`: lint multiset byte-identical to the stashed HEAD baseline (13 = 13;
zero new warnings). No book change (the catalog §8 already documents these helpers; the Rust backend
now conforms — Rust-parity book sync stays `RUST-PARITY.9`). Frontier → `RUST-PARITY.5.5.2`.

## 2026-06-16 — RUST-PARITY.5.4: dedup shadowed match arms + fix REP zero-progress guard

Rust engine code (`rust/linkedspec-runtime/src/engine.rs`). Two audit MAJORs in one slice.

**Duplicate/unreachable match arms.** `call_helper` is a big `match` on the helper name, and it
contained three pairs of arms with the same pattern. Rust matches top-to-bottom, so the FIRST
(worse) arm won and the second (better) was dead code — 3 `unreachable_patterns` warnings, and the
audit's "the worse arm wins". Removed the first `print`, `hash`/`h`, and `hash_copy` arms so the
later, more complete ones are live: `hash`/`h` now merges Hash-valued args (the removed arm dropped
them), `hash_copy` resolves its target via `resolve_array_target` (raw-AST) instead of a bare
`to_str()`, and `print` is served by the consolidated `say | print | print_each` arm (identical
behavior for `print`). Discovered while here (flagged for a later leaf, not fixed in `.5.4`): there
is no clean DSL idiom to copy a *declared* hash by reference — `hash(name)` eagerly builds an empty
new hash and `resolve_array_target` only matches the `array(...)`/`a(...)` raw form — so
`hash_copy(hash(config))` returns `{}`.

**REP zero-progress guard.** The REP matching loop's guard read `matches > rep_min && matches > 100`
— an iteration cap that never inspected the cursor, so a zero-width REP match (e.g. `/x*/` matching
the empty string) ran ~100 iterations before the cap fired. Replaced with a real progress check: the
loop captures `pos_before` at the top of each iteration and breaks when `ctx.pos == pos_before`
(Perl `loop_end_pos == loop_start_pos`). A no-progress REP iteration now terminates immediately, and
the post-loop min-bound check fails the rule if it is still under `rep_min`.

**Validation:** `cargo test --manifest-path rust/Cargo.toml` = 198 passed / 0 failed (196 baseline +
2 new: `rep_5_4_zero_progress_guard_terminates`, `hash_5_4_better_hash_arm_merges_hash_args` — the
latter pins the better `hash` arm via its distinguishing Hash-arg-merge behavior). `cargo clippy
--manifest-path rust/Cargo.toml -p linkedspec-runtime --tests`: touched-file warnings 15 → 12
(removed 3 unreachable-pattern duplicates; zero new). No book change (internal dedup + REP
termination correctness, which already matches the documented Perl model — Rust-parity book sync stays
`RUST-PARITY.9`).

## 2026-06-16 — RUST-PARITY.5.3: char-based offsets/slicing in the Rust engine

Rust engine code (`rust/linkedspec-runtime/src/engine.rs`, `runtime.rs`). Closed the audit's
byte-indexing MAJOR: `substr`/`input_slice` byte-sliced their DSL char-offset arguments (panicking
on a multibyte UTF-8 boundary and diverging from Perl), cursor/capture lengths and columns were
byte counts, and `entry_start_pos`/`match_start_pos` were hardcoded `0.0`. The regex engine works
in byte offsets, but the Perl reference exposes char offsets (`pos()`/`length`/`substr` are
char-based). Fix — keep internal positions byte-based, char-convert at the DSL boundary:
- New `byte_to_char_offset(input, byte)` and `char_substr`/`char_substr_from` helpers.
- `substr`/`input_slice` now char-slice (never panic on a multibyte boundary).
- `cursor_pos`, `cursor_col` (char distance from last newline), `cursor_rest_len`, `input_len`,
  `input_end_pos`, `capture_slice_len`/`_pos`, `mark_pos`, `entry_*_pos`/`entry_len`,
  `match_*_pos`/`match_len`, and `length` now return char counts. Line numbers (newline counts)
  were already byte/char-identical; only columns needed char counting.
- `entry_start_pos`/`match_start_pos` are no longer hardcoded: `RuntimeContext` gains
  `entry_start_byte`/`entry_end_byte`/`match_start_byte`/`match_end_byte` span fields (recorded
  from the regex `m.start`/`m.end`), which join `SavedMatchState` so they save/restore per
  invocation exactly like the `.5.2` match groups, with the entry span seeded by the same
  dispatcher-vs-own-first-match rule.

Because byte == char for ASCII, the 189-test baseline is untouched. Out of scope: the `.5.2`
group-indexing item and the `entry_line`/`entry_col`/`match_line`/`match_col` arg-taking quirk
(only `cursor` line/col was named in this leaf).

**Validation:** `cargo test --manifest-path rust/Cargo.toml` = 196 passed / 0 failed (189 baseline
+ 7 new `chars_5_3_*` multibyte tests: substr no-panic, input_slice, cursor_pos, cursor_col,
match_start_pos, entry_start_pos, length). `cargo clippy --manifest-path rust/Cargo.toml -p
linkedspec-runtime --tests`: touched-file warning count identical to baseline (15) — zero new. New
knowledge card `docs/knowledge/rust-char-based-offsets.md`. No book change (positions/lengths/`substr`
are char-based in the documented `.spec` contract; Rust now conforms — Rust-parity book sync stays
`RUST-PARITY.9`).

## 2026-06-16 — RUST-PARITY.5.2: separate entry_* from match_* in the Rust engine

Rust engine code (`rust/linkedspec-runtime/src/engine.rs`). Closed the audit's match/entry-unification
MAJOR: the single match-set site assigned the rule's own regex match to BOTH the entry registers
(`entry_groups`/`entry_named`) and the local registers (`match_groups`/`match_named`), so `entry_*` and
`match_*` could never diverge and a dispatched child clobbered the parent's match. Root cause: the engine
shares one `RuntimeContext`, but the Perl reference keeps two *per-handler* `my` lexicals — `IMATCH` (the
entry match, set in the handler preamble from the match the dispatcher passed in: `IMATCH = $$info{match}`,
and a parent invokes a child with its own `$minfo`, `ActionIR/MethodLowering.pm:332`) and `LMATCH` (the
local match, the rule's own regex match: `_build_lmatch_extraction`). Fix: `execute_rule` now emulates
that lexical scoping with a `SavedMatchState` save/restore: (1) on entry it saves the caller's
`entry_*`/`match_*` and sets THIS invocation's entry match = the caller's local match (`$info = $minfo`),
starting the local match empty; (2) each own regex match updates only `match_*`, and seeds `entry_*` from
the first own match **only when entry is still empty** (the top-rule / dispatcher-less case — the framework
passes the top rule's own match as `$info`); (3) both the blind-call early return and the normal return
restore the caller's registers, so a child's matching is transparent to the parent. Net effect: a
dispatched child's `entry_*` reads the parent's match while its `match_*` reads its own (they diverge in
nested contexts), and the parent's `match_*` survives a child dispatch.

The runtime Perl oracle was inconclusive for minimal hand-authored inline specs (`.spec` top-rule/lifecycle
authoring friction returned empty/0), so the contract was taken directly from the authoritative Perl source
(the three sites above) and pinned by Rust tests — the leaf's parity gate is `cargo test` + `cargo clippy`.
Group **indexing** is unchanged and out of scope (`entry_group(0)` = full match in Rust vs Perl
`match_group(0)` = first capture — flagged as a later parity item).

**Validation:** `cargo test --manifest-path rust/Cargo.toml` = 189 passed / 0 failed (186 baseline + 3 new
`match_5_2_*`: child entry/local divergence, parent match survives child dispatch, top-rule entry==local).
`cargo clippy --manifest-path rust/Cargo.toml -p linkedspec-runtime --tests`: touched-file warning set
identical to baseline (14 `engine.rs` + 1 pre-existing `len_zero` at `integration_test.rs:199`), only
line-shifted — zero new warnings. New knowledge card `docs/knowledge/rust-entry-match-separation.md`. No
book change (the `.spec` `entry_*`/`match_*` contract is already documented; Rust now conforms — Rust-parity
book sync stays `RUST-PARITY.9`).

## 2026-06-16 — RUST-PARITY.5.1: fix child-return (retv) propagation in the Rust engine

Rust engine code (`rust/linkedspec-runtime/`). Closed the retv-propagation BLOCKER (the audit's
top-priority finding): after `->`/`=>` dispatch a parent could not read the child's `return(expr)`
value as `scalar(retv)` — it resolved to undef — so virtually every real grammar yielded null/wrong
output. Root cause: the engine shares one `RuntimeContext`, `execute_rule` returned `Result<(), String>`
(no value channel), `return(expr)` only pushed the single shared accumulator, and `set_retv` was dead
code. Fix: (1) `RuntimeContext` gains a per-invocation `return_value: Option<RuntimeValue>` channel
(`set_return_value`/`take_return_value`/`restore_return_value`); (2) `execute_rule` now returns
`Result<RuntimeValue, String>` — it clears the channel on entry (saving the caller's pending return) and
reads+restores it on exit, so each invocation reports its own last `return(...)` (Runtime Semantics §5.4)
and nested dispatch is transparent; (3) both acode (`->`) and bcode (`=>`) dispatch sites now call
`ctx.set_retv(child_retv)` after dispatching, so the parent's attached code / `LE` / `E` read the child
result as `scalar(retv)` (§3.3/§6.1); (4) `return(expr)` records the channel **and** still pushes the
accumulator, so `execute()`'s accumulator-return contract — and the 182-test baseline — is untouched. The
dead `set_retv` is now wired in (completed, not removed). Also fixed a latent `call(child)` bug: it
resolved the rule name from the *evaluated* arg, but a bare `call(RuleName)` evaluates to undef, so it
never resolved a bare rule — added `resolve_rule_name` (mirrors `resolve_array_target`) so `call(child)`
returns the child value, enabling the reference pattern `assign(s(retv), call(child))`
(`specs/tablegrep.spec`). 4 new integration tests cover retv across action edges (OR/default), blind-call
edges (AND), repetition (REP), and the `call` helper. Validation: `cargo test --manifest-path
rust/Cargo.toml` = 186 passed / 0 failed (182 baseline + 4 new); `cargo clippy` adds zero new
`linkedspec-runtime` warnings (lib stays at 16 pre-existing `doc_lazy_continuation` lints). No book change:
the documented `.spec` contract already specifies retv; the Rust backend now conforms (Rust-parity book
sync is `RUST-PARITY.9`). Active frontier → `RUST-PARITY.5.2` (separate `match_*` from `entry_*`).

## 2026-06-16 — MDBOOK-FORMAT-CORRECTNESS.3: finalize; close the format-correctness tree

Documentation only (no code). Closed the MDBOOK-FORMAT-CORRECTNESS tree. Added a DEVELOPMENT_NOTES
entry capturing the format rule (lifecycle markers are top-level paragraph members, siblings of the
edges — never nested in an edge `{ }`) and two reusable lessons (format-validity is a distinct audit
from variant-agnostic framing; verify embedded `.spec` snippets against the shipped specs). Net result
across the tree: all 3 malformed examples fixed (`runtime-semantics` §5.2/§5.3 + `formal-grammar`
§8.1/§12), whole-book re-scan clean, `mdbook build` exit 0. Tree moved to Completed in
`docs/TASK_TREE.md`. Active trees remaining: `RUST-PARITY` (`.5.1`, the retv-propagation fix — Rust
engine code).

## 2026-06-16 — MDBOOK-FORMAT-CORRECTNESS.2: full-book format sweep; fix formal-grammar §8.1/§12 lifecycle nesting

Book documentation only (no code). Full format-validity sweep of every `.spec` code fence across all 41
`docs/linkedspec-book/src/**.md` pages (read-only Explore audit) against the bootstrap grammar + shipped
specs, checking four violation classes: lifecycle-block-nested-in-edge-block, mixed `->`/`=>` in one rule,
rule-header-inside-open-block, and malformed edge/marker/header syntax. Result: the lifecycle-nesting bug
appeared in 2 MORE places — both in `appendix/formal-grammar.md` (§8.1 "Structured Block Form" and §12
"Complete Example") — and NONE of the other classes appeared anywhere. Each finding was verified against
the source before fixing (not trusted blindly). Fixes: §8.1 → `I {…}` sibling + `-> Child {push_value(array(results),
call(Child))}` + `LX {…}` sibling, with §8.2 realigned as the matched fluent form (`-> Child .push_value(…)`)
and an §8 intro note stating lifecycle blocks are siblings of the edges; §12 `DemoParser::` → full
tablegrep-style sibling layout (`I`/`LS` + `/pattern1/ -> Child {assign(scalar(retv), call(Child))}` +
`LE`/`E`). Whole-book re-scan after the fixes: zero genuine lifecycle-nesting remains (only correct sibling
false positives). `git diff --check` clean; `mdbook build` exit 0. Frontier → `.3` (finalize).

## 2026-06-16 — MDBOOK-FORMAT-CORRECTNESS.1: fix lifecycle-nesting bug in runtime-semantics §5.2/§5.3

Book documentation only (no code). A user caught a malformed `.spec` example: `appendix/runtime-semantics.md`
§5.2 and §5.3 showed lifecycle blocks (`I`/`LE`/`E`) nested **inside** an action-edge `-> Bar { … }`
block. That is structurally invalid — lifecycle markers (`I`/`LS`/`LE`/`E`/`EX`/`IT`/`LX`) are
**top-level rule-paragraph members, siblings of the `->`/`=>` edges** (they are `NON_ACTION_CODE_BLOCK`
tokens in `BootstrapSpec/Core.pm`, peers of the edge tokens; the recursive brace scanner would consume
a nested marker as edge-code text, not recognize it as a hook). Fixed both, grounded in the shipped
specs: §5.2 → `-> Bar {push(Bar)}` with a top-level `LX {return(array_copy(array(Foo)))}` (mirrors
`value-container-flow-helper-reference.md`'s implicit-accumulator form + `tablegrep.spec`'s LX return);
§5.3 → top-level `I {declare(array, results)}` + `-> Bar {push_value(array(results), call(Bar))}` +
top-level `E {return(...)}`. Added a clarifying note that lifecycle blocks are top-level siblings of
the edges. New owning tree `MDBOOK-FORMAT-CORRECTNESS` (3 leaves: fix / full-book format sweep /
finalize); a pre-audit grep isolated this nesting bug to §5.2/§5.3 (the `value-container` `LX` hits
were correct — false positives). This is a format-validity gap the earlier `MDBOOK-VARIANT-AGNOSTIC`
sweep did not cover (it audited variant-agnostic framing, not snippet syntax). Also reconciled a stale
`docs/TASK_TREE.md` index frontier (`RUST-PARITY.5`→`.5.1` after the split). `git diff --check` clean;
`mdbook build` exit 0. Frontier → `.2` (full-book format-validity sweep).

## 2026-06-16 — RUST-PARITY.5: split into .5.1–.5.5 (too broad; retv-first)

Task-tree structuring only (no code). PNT reached `RUST-PARITY.5` and found it too broad for one
signoff slice — it bundled six independently-reviewable audit findings. Per PNT rule 5, split it
before implementation into: `.5.1` child-return (`retv`) propagation BLOCKER fix, `.5.2` separate
`match_*` from `entry_*`, `.5.3` char-based (not byte) indexing + cursor line/col, `.5.4` de-duplicate
shadowed match arms + REP zero-progress guard, `.5.5` the ~30 missing capture/mark/entry/match/input
helpers (+ real `tail`/`drop_last`/`flatten` aliases). Sequenced retv-first because the audit shows it
gates correct output for nearly every grammar. The "0/20 runtime-tested corpus" gap stays in `.7`.
Corrected an earlier note that called `.5` "blocked": its formal Blockers section is "None" — `retv`
is the defect `.5` fixes, not a precondition. Rust baseline confirmed green before the split:
`cargo test --manifest-path rust/Cargo.toml` = **182 tests, 0 failed** (86 core + 8 types + 72 runtime
+ 16 integration). Frontier → `.5.1`. No source change in this slice.

## 2026-06-16 — SPEC-SPEC-SELFHOST.4: docs sync + finalize (close the self-hosting rewrite tree)

Documentation only (no code). Final leaf of the SPEC-SPEC-SELFHOST tree, syncing the live docs to the
`.2`/`.3` rewrite of `specs/spec.spec` (commit `4c667b7`) and closing the tree.

- DEVELOPMENT_NOTES.md: added a self-hosting status note superseding the MEDIUM-IMPACT.3.x dual-path
  entries — the rewritten spec.spec is a faithful, complete description of the format
  `BootstrapSpec/Core.pm` recognizes (13 rules; group-at-`rule_header`), compiles at ratio 1.0000
  (zero blocked / zero compatibility-surface), and the cross-check harness now reports full
  paragraph-count parity with the bootstrap oracle across all 20 shipped specs (was 2/20). The
  hardcoded bootstrap stays the oracle/primary; spec.spec remains the diagnostic side channel (Non-Goals).
- mdBook: `compiler/pipeline-overview.md`'s dual-path note now states that the self-hosted spec.spec
  reproduces the bootstrap's paragraph grouping across all shipped specs (bootstrap still primary).
- Extension-surface policy preserved: the PHASE7-SELF-HOSTED-SPEC.5 policy is carried verbatim in the
  new spec.spec header (EXTENSION-SURFACE POLICY block) and in DEVELOPMENT_NOTES.md.
- Task-tree bookkeeping: recorded the `.2` commit `4c667b7` in the SPEC-SPEC-SELFHOST commit log (was
  'pending'); `.4` marked done; tree closed and moved to Completed in `docs/TASK_TREE.md`.

Verification: `git diff --check` clean; `mdbook build` exit 0 (no warnings);
`scripts/check_memory_architecture.sh` exit 0. No phase0 run needed (docs-only; the spec.spec rewrite
itself was gated under `.3`). Active trees remaining: `RUST-PARITY` (`.5`, has a retv blocker).

## 2026-06-16 — MDBOOK-VARIANT-AGNOSTIC.7: final variant-agnostic consistency sweep; close the tree

Book documentation only (no code). Final leaf of the MDBOOK-VARIANT-AGNOSTIC tree. Ran a whole-book
cross-chapter consistency sweep over all 41 `src/**.md` pages: confirmed every page that carries
Perl-API blocks (`use LinkedSpec` / `LinkedSpec::Get` / `get_parser` / `$parser->(`) also carries a
backend frame, that `public-api/get-and-get-parser.md` correctly uses a single chapter-top frame per
the `.4` Option-A convention, and that no chapter presents Perl as the only backend (`compiler for
Perl` / `Perl parser generator` scan returns none). Applied one light consistency touch — the `ebnf`
walkthrough's descriptor block sits ~660 lines below its page frame, so its lead now reads "ask the
reference (Perl) backend for the descriptor instead of a parser". Confirmed
`user-model/spec-files-and-rule-paragraphs.md` carries no Perl-API invocation block (the sweep's
`api=1` was a project-name prose match, not a code block). Verification: `git diff --check` clean;
`mdbook build` exit 0 (no warnings); `scripts/check_memory_architecture.sh` exit 0.

**Tree complete (all 7 leaves).** The mdBook now documents the `.spec` file as the one universal
contract with Perl framed as the reference backend across every section — overview, user-model,
public-api, DSL, compiler, corpus walkthroughs, architecture, appendix, and development. Tree moved
to Completed in `docs/TASK_TREE.md`; `ROADMAP_V2.md` Overall-roadmap row notes the milestone. Active
trees remaining: `SPEC-SPEC-SELFHOST` (`.4`), `RUST-PARITY` (`.5`, has a retv blocker).

## 2026-06-16 — MDBOOK-VARIANT-AGNOSTIC.6: reframe appendix + corpus walkthroughs + development chapters as variant-agnostic

Book documentation only (no code). Remediated the remaining `.6` scope — the 4 appendix pages, the
6 corpus walkthroughs, and the 2 development pages — with the `.2`–`.5` "demote, don't delete"
convention, re-grepping all 12 in-scope pages for genuine Perl-API signals rather than trusting the
`.1` tags. **Appendix (3 edited, 1 CLEAN):** `appendix/formal-grammar.md` (`pos()` → "the cursor" so
the grammar appendix needs no Perl knowledge), `appendix/runtime-semantics.md` (added a
cursor-terminology note; demoted 9× `pos($input)` → "the cursor" across the §1 parse-mode and §4
BACKTRACK behavioral contracts; relabeled §8 `LinkedRE::or` and the §10.1
`LinkedSpec::generated_handler:<rule_label>` spelling as the Perl reference), `appendix/backend-handoff.md`
(HandlerIR diagram box `hashref AST` → `structured AST`, box alignment preserved);
`appendix/helper-contract-catalog.md` confirmed CLEAN (gold standard, 0 Perl signals). **Corpus
walkthroughs (6):** one shared backend-neutral driver-block frame across all six — "`X.spec` is the
backend-neutral contract; any LinkedSpec backend can run it. The reference (Perl) backend loads it by
spec name:" before the runnable `use LinkedSpec; … $parser->(\$input)` block. `lispish` also demoted
the `get_parser` bullet and labelled `perl/Lispish.pm` as a Perl reference-backend convenience module;
`tablegrep`/`portmap` got a value-rendering note ("shown in the Perl reference backend's value
rendering; another backend produces the equivalent structure"); `pplugin` got a `.plg`/`PPlugin`
"Perl reference implementation" banner while keeping its already well-framed `eval` compat-surface
explanation; `shipped-specs-and-corpora` got a Perl-reference banner over the long `plugin/`
package-owner migration narrative (kept per Non-Goals) plus a runnable-examples frame.
**Drift caught & fixed (beyond framing):** the `ebnf` walkthrough showed a stale **raw-Perl**
`semantic_annotation` action edge (`{BACKTRACK(); my $c = $CAPTURE; $c =~ s/…; return ['…', […]]}`)
that no longer matched the migrated shipped rule at `specs/ebnf.spec:187` — replaced with the actual
canonical helper-DSL rule (`declare(scalar, c=capture_slice()); substr(s(c), …); return(a("semantic_annotation", a(entry_group(0), s(c))))`),
which also reconciles the page with its own `semantic_annotation … ready=1` /
`compatibility_surface_rules=0` descriptor-readiness section. **Development (1 edited, 1 CLEAN):**
`development/local-ci-and-regression.md` got a "Perl reference implementation" frame (its
`perl -c` / `t/phase0_regression.t` / `run_ci_local.sh` references are legit per Non-Goals; a new
backend has its own gate but must pass the shared language-neutral corpus);
`development/documentation-workflow.md` confirmed CLEAN. Verification: `git diff --check` clean;
`mdbook build` exit 0 (no warnings); `scripts/check_memory_architecture.sh` exit 0. Frontier advanced
`.6`→`.7` (final build + cross-chapter consistency + docs sync).

## 2026-06-16 — MDBOOK-VARIANT-AGNOSTIC.5: reframe DSL + compiler/architecture chapters as variant-agnostic

Book documentation only (no code). Remediated the DSL + compiler/architecture mdBook chapters with
the `.2`/`.3`/`.4` "demote, don't delete" convention: lead with the backend-neutral concept, label
concrete Perl as the **Perl reference backend's** surface. Per the `MEMORY.md` directive, re-grepped
all 14 in-scope pages for genuine Perl-API signals instead of trusting the `.1` CLEAN tags — which
caught **3 leaks the `.1` audit mis-tagged CLEAN**: `dsl/fluent-and-block-forms.md` (`ControlFlow.pm`
+ generated-Perl `do { my $switch_var; my $hit_var; if … }`), `dsl/source-boundary-helper-reference.md`
BACKTRACK section (`pos($$STRING) = $LSPOS - length $LMATCH` mechanics), and a backend-specific
"current byte offset" in `dsl/action-model-and-helper-surface.md`. Changes: **Compiler (4)** —
`pipeline-overview.md` (frame: the 7 pipeline stages are backend-neutral; `LinkedSpec::Validation`,
`LinkedSpec::Get(...)`, `Runtime::run_get`, `pos($$input_ref)` are the Perl reference realization),
`compiled-state-model.md` (frame: the state records + field names are neutral; `sub { ... }` /
`qr/.../` are the Perl encoding), `generated-handlers-and-dispatch.md` (frame: the dispatch model +
the variant-builder→HandlerIR→backend-emitter seam are neutral — that seam is the multi-backend
decoupling point — while `LinkedRE::or`, `HandlerVariantEmitter.pm`, `JSON::PP`, `pos`, `$BACKEND`
are the Perl reference impl), `diagnostics.md` (frame: the structured `last_error` payload contract +
owner/stage families are neutral; the `Get(..., runtime_ctx_ref => \%ctx)` capture + the
`LinkedSpec::generated_handler:Top` label spelling are the Perl reference surface). **DSL (4)** —
`actionir-lowering-mental-model.md` (frame: scan→split→canonicalize→lower→emit is neutral;
`ActionIR::*` owner names/counts are the Perl reference; diagram `EmittedPerl`→`Emit`),
`fluent-and-block-forms.md`, `source-boundary-helper-reference.md`,
`action-model-and-helper-surface.md`. **Architecture (1)** — `owner-tree.md` got a "Perl reference
implementation" banner (LABEL; content kept per Non-Goals). 5 pages confirmed genuinely CLEAN
(`declaration-helper-reference` already frames raw Perl as the legacy form;
`capture-marks-and-source-locations`, `value-container-flow-helper-reference`,
`values-containers-and-flow-helpers`, `action-and-lifecycle-placement`). Also reconciled the stale
`docs/TASK_TREE.md` index row for this tree (`.2`→`.6`). Verification: `mdbook build` exit 0 (no
warnings); `scripts/check_memory_architecture.sh` exit 0. Frontier advanced `.5`→`.6` (appendix +
corpus walkthroughs).

## 2026-06-16 — MDBOOK-VARIANT-AGNOSTIC.4: reframe public-api chapters as variant-agnostic

Book documentation only (no code). Remediated the 4 mdBook public-api chapters with per-chapter
backend frames, resolving the tree's Open Question in favour of **Option A** (per-chapter
"reference backend" frame, not relocating the Perl API into a dedicated subsection — consistent
with `.2`/`.3`, one frame labels every Perl block, preserves each chapter's value as the Perl
reference API doc, avoids heading/anchor churn). Changes: (1) `get-and-get-parser.md` — added a
frame stating the two entry points (inline compile path / file-oriented path) and all options
(`top_rule`, `parse_mode`, `return_descriptor`, `runtime_ctx_ref`, `parse_only`, `generate_only`)
are backend-neutral roles while `LinkedSpec::Get`/`get_parser` + the coderef are the Perl reference
surface; "raw Perl error strings" → "raw host-language error strings". (2) `descriptor-introspection.md`
— framed the descriptor shape and field names (`spec`, `dependency_regex_map`, `meta`,
`dependency_refs`, …) as a backend-neutral contract while labelling the encoding (`sub { ... }`
handler, `qr/.../` compiled regex, coderef) as the Perl reference representation, with a follow-up
note under the example. (3) `trace-api.md` — framed the trace *model* (verbosity levels, enter/exit
scopes, decision events, console/file/mirror routing) as backend-neutral while labelling the
concrete function API, the `use LinkedSpec` constants, and the package-variable/typeglob state
surface as Perl-reference; `Data::Dumper` → "dumper-style debug output (e.g. Perl's `Data::Dumper`)".
(4) `plugin-registry.md` (LABEL) — added a "Perl reference backend, deprecated" banner clarifying
the registry / `.plg` / `PPlugin` machinery is not part of the `.spec` contract and a new backend
need not implement it. Verification: `mdbook build` exit 0 (no warnings);
`scripts/check_memory_architecture.sh` exit 0. Frontier advanced `.4`→`.5` (DSL + compiler/architecture chapters).

## 2026-06-16 — MDBOOK-VARIANT-AGNOSTIC.3: reframe user-model chapters as variant-agnostic

Book documentation only (no code). Applied the `.2` "demote, don't delete" convention to the
mdBook user-model chapters: each chapter now leads with the backend-neutral `.spec` concept and
labels its runnable blocks as the **Perl reference backend's** surface. Changes: (1)
`worked-spec-walkthrough.md` — added a global frame after the intro ("the `.spec` file … is
backend-neutral; the runnable snippets use the Perl reference backend"), retitled "Running it
inline with `Get(...)`" → "Running it inline" (concept first; `LinkedSpec::Get` demoted to the
reference example), reframed the `Data::Dumper` hash-order note, and changed "raw Perl payload" →
"raw host-language payload" (two bullets). (2) `runtime-context-and-tracing.md` — added a top frame
declaring the runtime-context object, `last_error` schema, owner/stage attribution, handler source
labels, trace levels, and trace modes to be **backend-neutral contracts**, while the passing
mechanics, the raw-error-string (`$@`), the trace API, and the `LINKEDSPEC_*` env vars are the Perl
reference surface; demoted "caller-provided hash" → "caller-provided object (a hash in the Perl
reference backend)", both `$@` mentions, and the "generated Perl source and `eval`" handler-label
line. (3) `spec-files-and-rule-paragraphs.md` — replaced the raw `return { kind => "top" }` payload
with helper-DSL `return(hash("kind", "top"))` and rewrote the note (dropped the "raw Perl label"
framing). (4) `rule-modes-and-parse-modes.md` — **audit refinement**: `.1` classified this page
CLEAN, but it carried a genuine Perl-API block ("## Public option shape", L468–494); reframed
`parse_mode` as a backend-neutral compile option with the Perl block labelled. Confirmed
`blind-calls-and-parser-orchestration.md` genuinely CLEAN (0 Perl-API signals). Verification:
`mdbook build` exit 0 (no warnings); `scripts/check_memory_architecture.sh` exit 0. Frontier
advanced `.3`→`.4` (public-api chapters).

## 2026-06-16 — MDBOOK-VARIANT-AGNOSTIC.2: reframe overview chapters as variant-agnostic

Book documentation only (no code). Remediated all 5 mdBook overview pages so the `.spec` file is
presented as the **one universal contract** and Perl as the **reference backend** (Rust = second
backend), matching the vocabulary already established in `appendix/backend-handoff.md` and ADR 0006.
Changes: (1) `index.md` — added a multi-backend framing paragraph on the landing page (`.spec` =
universal contract; Perl = reference backend; concrete API calls are the Perl reference surface
unless noted). (2) `overview/what-is-linkedspec.md` — reframed the three audit-flagged passages:
the opening "DSL and compiler for Perl" → "DSL … the `.spec` language is its universal contract …
Perl is the reference backend"; the "How it works" compiler line now reads "a backend's compiler …
returns a runnable parser" with `LinkedSpec::Get(\$spec)` demoted to a parenthetical Perl-reference
example; the "What comes out of it" outcome now says "a runnable parser (a coderef in the Perl
reference backend)". (3) `overview/design-rationale.md` — dropped the Perl-specific "`LinkedSpec.pm`
is 258 lines … `OwnerDispatch`" detail for the backend-neutral thin-facade *principle*, and updated
the backend-neutral-semantics section so Rust reads as a real second backend, not a "future" one.
(4) `overview/documentation-layers.md` — labelled the `USER_GUIDE.md` reference as the *Perl
reference backend's* emitted-code contracts. (5) `overview/project-status.md` — added a multi-backend
framing note, **fixed a phase drift** (page said "Phases 0–7 done"; the roadmap has 0–9 done — added
Phase 8 multi-backend handoff + Phase 9 Rust variant), and added "Variant-agnostic documentation"
and "Rust backend parity" rows under Ongoing. Verification: `mdbook build` exit 0 (no warnings);
`scripts/check_memory_architecture.sh` exit 0. Frontier advanced `.2`→`.3` (user-model chapters).

## 2026-06-16 — MDBOOK-VARIANT-AGNOSTIC.1: complete variant-agnostic audit of the mdBook

Documentation/audit only (no code, no book edits yet — remediation is `.2`–`.6`). Ran a
deterministic Perl-leakage scan over **all 41** `docs/linkedspec-book/src/**.md` pages, then
targeted reads to characterise each hit, and recorded a full per-file catalog in the
`MDBOOK-VARIANT-AGNOSTIC` task file under "## Audit Findings (.1)". Key finding: the high `::`/`:AND`
raw counts in the DSL/grammar chapters are `.spec` **rule-labels and rule-mode suffixes**
(`Token::AND`, `Top::`, `Next::`) — DSL syntax, not Perl — so those chapters are effectively CLEAN.
Genuine leakage (Perl API/syntax/modules presented as the primary surface) concentrates in the
overview (2 pages), two user-model pages (worked-spec-walkthrough, runtime-context-and-tracing),
all four public-api chapters, the compiler chapters, and the six corpus walkthroughs (which all
share one `use LinkedSpec; … $parser->(\$input)` driver block). Architecture/dev/appendix chapters
legitimately reference Perl (per the tree's Non-Goals) and are classified LABEL (keep, frame as
"Perl reference implementation"). Adopted a 3-way classification — CLEAN / REMEDIATE / LABEL —
and mapped every REMEDIATE/LABEL file to its remediation leaf (`.2`–`.6`). Corrected the leaf's
original "27 files" estimate to the actual 41. Frontier advanced `.1`→`.2`. Verification:
`scripts/check_memory_architecture.sh` exit 0.

## 2026-06-16 — TASK-TREE-INDEX-SYNC.1: reconcile stale frontier column in docs/TASK_TREE.md

Documentation/tracker only (no code). A fresh session-bootstrap pass found the `Active Task Trees`
table in `docs/TASK_TREE.md` had drifted from the authoritative per-tree `## Current Frontier`
sections: it listed `SPEC-SPEC-SELFHOST` frontier as `.2` (actually `.4` — `.2`+`.3` done) and
`RUST-PARITY` as `.1` (actually `.5` — `.1/.2/.3` done, `.4` superseded). Root cause: prior leaf
completions did not refresh the index row. Created a one-leaf owning tree
`docs/tasks/TASK-TREE-INDEX-SYNC.md` (modelled on the completed `PLUGIN-ACTION-MIGRATION-STALE-REFERENCES`
tree), fixed both frontier cells, and registered the tree in the `Completed Task Trees` table. The
`MDBOOK-VARIANT-AGNOSTIC` row (`.1`) was already correct and left unchanged. Verification: index rows
now match each tree's `## Current Frontier`; `scripts/check_memory_architecture.sh` exit 0.

## 2026-06-16 — SPEC-FORMAT-TERSE: formalize the .spec terse-format brainstorm into a proposed task tree

Documentation/task-tree only (no code). The 2026-06-15 `.spec` format-evolution brainstorm lived
only in the KM card `docs/knowledge/spec-format-brainstorm-rounds-1-3.md` (status `brainstorming`)
— not task-tree owned, not a decision record, not pivotable. Created `docs/tasks/SPEC-FORMAT-TERSE.md`
(status `proposed`, registered in `docs/TASK_TREE.md` Proposed table) that transcribes every Round 1–3
decision faithfully into pickable leaves (`.0` ratify+ADR, `.1.1`–`.1.6` vars/types/mutation/renames/
literals/array-methods, `.2.1`–`.2.3` control flow, `.3.1`–`.3.2` edges+arithmetic, `.4` resume Round 4+).
Goals recorded: terse + dynamic-feeling **but still readable**; **all variants at full feature parity**
(`.spec` is the universal contract — Perl reference first, then Rust/Julia/Dart in lockstep); the mdBook
stays **variant-neutral/agnostic** (cross-links `MDBOOK-VARIANT-AGNOSTIC` + the multi-backend vision ADR).
Parked: implementation deferred until the pre-existing `RTLUTILS-REGEX-HANG` is fixed (user directive).

## 2026-06-16 — RUST-PARITY.4 (superseded): WIP checkpoint of in-flight Rust exploration

Preserves the 4 in-flight Rust files from the prior session as a durable WIP checkpoint
(handoff decision) — NOT signoff work. They targeted Rust self-hosting on spec.spec, now
superseded (spec.spec is a Perl-side artifact; Rust parity = reproducing BootstrapSpec::Core
output). Files: `expr.rs` (skip trailing regex flags after a code-block `/.../`), `parser.rs`
(`parse_inline_body` for same-line rule bodies — audit: conditional capture-group bug),
`runtime.rs` (`set_retv` — audit: dead, no caller), `helpers.rs` (regex-engine test — audit:
leftover debug `eprintln!`). No behavior change (cargo test was 182/182). The real Rust
follow-on is the 3-agent parity audit recorded in `docs/tasks/RUST-PARITY.md` Decisions:
child-return (`retv`) propagation BLOCKER, `match_*`/`entry_*` split, byte-slice UTF-8 panics,
duplicate match arms, ~30 missing helpers, and 0/20 specs runtime-tested (need an output oracle).

## 2026-06-16 — SPEC-SPEC-SELFHOST.2+.3: rewrite spec.spec as a faithful self-hosting grammar

### Context
The shipped `specs/spec.spec` was unusable — it returned `[[]]` on real `.spec` input and did
not divide files into rule paragraphs. Rewritten from scratch, grounded in the authoritative
hardcoded grammar `perl/LinkedSpec/BootstrapSpec/Core.pm` (the primary `.spec` parser).

### Implementation
- New hierarchical grammar mirroring the bootstrap `SPEC_ROOT` driver: a top rule `spec_file::`
  owns two accumulators (`paragraphs`, `current`), dispatches via `->` action edges to 12
  per-token part rules (`rule_header`, `regex_anchor`, `action_block/_fluent/_bare`,
  `blind_block/_fluent/_bare`, `lifecycle_block/_fluent`, `split_marker`, `comment`), and starts
  a new paragraph at every `rule_header` (the SPEC_ROOT group-at-header rule). `LX` returns the
  array of paragraphs. 13 rules total.
- Each part rule is its own rule connected to `spec_file` by an edge; part rules read their match
  through `entry_*` helpers (they are entered by dispatch), `I.return(hash(...))` typed nodes.
- Block-bearing slots capture the full balanced, string-aware `{ ... }` with recursive named
  groups so the cursor advances past blocks and their interiors are not re-scanned.
- Fluent-chain joins use `\s*` (not `[ \t]*`) so multiline method chains are fully consumed,
  matching the bootstrap — this fixed an ebnf over-count (40→24) caused by spurious `Error:`
  headers leaking from `say("Error: ...")` inside multiline guard chains.
- Performance hardening: leading word and block/string/chain quantifiers are possessive
  (`\w++`, `*+`, `++`) so a failed match (e.g. an unclosed `{` block) fails in O(1) instead of
  backtracking to EOF. On an 8 KB unclosed-block input this dropped parse time 2.26s → 0.026s
  (~87x). Valid (balanced) specs were already fast; this guards the malformed/large-input path.

### Validation
- `LinkedSpec::Get(spec.spec, return_descriptor)`: `language_agnostic_ready_ratio == 1.0000`,
  blocked 0, compatibility-surface 0 (phase0 compile gate stays green).
- Paragraph-count fidelity vs the bootstrap oracle: 19/19 shipped specs match exactly.
- `tools/cross_check_spec_parsers.pl`: "ALL 20 specs match. spec.spec has proven output parity
  with BootstrapSpec" (was 2/20).
- Self-hosting: spec.spec divides itself into 13 paragraphs == its own 13 rules.

## 2026-06-16 — RUST-PARITY.3: BACKTRACK/IBACKTRACK cursor save/restore in Rust

### Implementation
- Added `backtrack_stack: Vec<usize>` to `RuntimeContext` with `push_backtrack()` and `pop_backtrack()` methods
- `BACKTRACK()` pushes current position onto stack; `IBACKTRACK()` pops and restores cursor
- Empty-stack `IBACKTRACK()` is a no-op (no crash)
- 4 new tests: save/restore, retry restore via LX, empty stack no-op, multiple push/pop
- 181/181 PASS (86 core + 8 types + 71 engine + 16 integration)

## 2026-06-16 — RUST-PARITY.2: Conditional flow — if/elseif/else/switch/case/default in Rust

### Implementation
- Added `if(cond, then)`, `if(cond, then, else)`, `if(cond, then, elseif(cond2, then2), else(fallback))` to Rust runtime
- Added `switch(expr, case(v1, b1), case(v2, b2), default(body))` to Rust runtime
- Added `elseif`, `else`, `endif`, `case`, `default`, `endswitch`, `endcase` standalone handlers
- **Lazy evaluation**: `eval_expr` intercepts conditional flow calls before eager arg evaluation; new `call_helper_lazy` method passes raw AST nodes to handlers
- Branch bodies evaluated only when their condition matches — prevents side effects from firing in non-taken branches
- 12 new integration tests: 4 if/elseif/else, 3 switch/case/default, 2 lazy evaluation, 2 no-op markers, 1 combined
- 177/177 PASS (86 core + 8 types + 67 engine + 16 integration), cargo clippy clean

## 2026-06-16 — RUST-PARITY.1: Gap inventory — Rust variant vs Perl reference
### Analysis
- Full audit of Rust variant (`engine.rs:1984`, `helpers.rs:470`, `compiler.rs`, `parser.rs`, `validation.rs`) against Perl reference lowering owners
- 6 gap categories identified:
  1. Conditional control flow (if/elseif/else/switch/case/default) — largest feature gap
  2. BACKTRACK/IBACKTRACK cursor save/restore
  3. Self-hosting (spec.spec) — Rust cannot parse itself
  4. strict_syntax validation mode
  5. ~27 remaining helpers (capture/mark extensions, entry/match named, input boundaries, compat aliases)
  6. Code-gen emitter (interpreter-only, no HandlerIR→Rust source)
- 84/100+ helpers already implemented in Rust
- New task trees RUST-PARITY (9 leaves) and MDBOOK-VARIANT-AGNOSTIC (7 leaves) created
- TASK_TREE.md duplicate header fixed

## 2026-06-16 — REPO-HYGIENE.1: .gitignore and untrack tool artifacts
### Repository maintenance
- Added `.gitignore` entries for `*.swp`, `.DS_Store`, `git_message_brief.txt`
- Untracked `perl/.PPlugin.pm.swp` (accidentally committed Vim swap file) and `git_message_brief.txt` (commit workflow scratch file) from git index
- MEMORY.md latest_commit updated to `1c72af4`

## 2026-06-15 — RUST-EDGE-SEMANTICS.3: Regression tests for edge dispatch
### Tests added
- 7 new integration tests: edge-only dispatch, mixed regex+edge, self-recursive compiler output, grouped targets, Child[N] entrypoint, lifecycle with edge-only, self-recursive edge-only
- Edge-only dispatch verified end-to-end: top rule with zero own regexes dispatches to Greeting/Farewell children correctly
- Self-recursive fix: `-> same_rule[N]` entries point to parent regex positions directly (no duplication)
- 166/166 PASS (86 core + 8 types + 56 engine + 16 integration)

## 2026-06-15 — RUST-EDGE-SEMANTICS.2: Compiler rewrite — build regex_patterns from child rule dependency refs
### Implementation
- Added `has_parent_regex: bool` to `AcodeEntry` (types.rs) with `#[serde(default)]` backward compat
- Phase 1: track same-line regex→edge adjacency via `element.line` comparison (not paragraph-level `last_was_regex`)
- Phase 2: `build_dependency_regex_map()` post-processing resolves edge-only entries by looking up child rules, extracting regex at `child_regex_idx`, appending to parent's `regex_patterns`, and updating `regex_idx`
- Parent regexes come first in the alternation; child-resolved regexes appended after
- Missing/OOB child regex indices produce `eprintln!` warnings and skip (matching Perl's commented-out `exit 1`)
- 8 new compiler tests: edge-only resolution, parent-first ordering, self-recursive, anchored flag, missing child warns, OOB warns, no-op
- 159/159 PASS (86 core + 8 types + 56 engine + 9 integration); cargo clippy clean; all 20 shipped specs compile

## 2026-06-15 — RUST-EDGE-SEMANTICS.1: Audit — Rust edge dispatch gap vs Perl dependency_regex_map
### Audit findings
- **Rust compiler.rs:52-55**: `regex_patterns` populated only from `BodyElementKind::Regex` — edge-only rules have empty alternation
- **Rust compiler.rs:57-91**: `AcodeEntry.regex_idx` set to `current_regex_idx - 1` (preceding parent regex) instead of child-regex alternation position
- **Rust engine.rs:77-81**: Empty alternation built for edge-only rules → never matches → no dispatch
- **Rust engine.rs:169-190**: ACODE dispatch compares `entry.regex_idx == m.index` — parent-regex index against alternation position (fundamentally wrong model)
- **Perl pipeline** traced end-to-end (6 steps): BootstrapSpec/Core.pm:129-157 → RuleIR.pm:231-236 → EmitContext.pm:517-529 → Compiler.pm:345-443 → HandlerVariantEmitter.pm:355-380
- **Root cause**: Perl builds `dependency_regex_map` from child rule regexes via `dependency_refs[{label, idx}]`; Rust uses only explicit parent `/regex/` entries with "preceding regex" association
- **Delta table**: 5 rows documented (regex source, alternation index semantics, `-> Child[N]` semantics, edge-only rules, mixed rules)
- Knowledge card `docs/knowledge/rust-edge-semantics-bug.md` pre-existing and aligned
- No code changes — audit/documentation only

## 2026-06-15 — RGX-BRANCH-TRACKING.1/.2: Combined regex + matched_branch_number
### Regex engine (.1/.2)
- Replaced manual alternative iteration with rgx's native branch tracking
- Patterns combined into single `(pat1)|(pat2)|(pat3)` regex — rgx's `MatchResult.matched_branch_number` identifies winning branch
- `CompiledAlternation` now holds one `Option<Regex>` + `Vec<AltInfo>` (group offsets + capture names per branch)
- `seek_match`: 1 `find_first` call instead of N; `consume_match`: 1 `find_first_at` call instead of N
- Capture extraction uses per-branch `group_offset` to isolate winning branch's groups
- Mirrors Perl's `LinkedRE::oredRE` single-regex approach, portable across all rgx backends
- 25 regex_engine tests pass; 2 test expectations adjusted for rgx ordered-alternation semantics

## 2026-06-15 — RUST-DIAGNOSTICS.1/.2: Runtime warnings for silent failures
### Diagnostics (.1/.2)
- Unknown helper calls now emit `eprintln!` warning with helper name and rule label (was silently returning `undef`)
- `filter_match` regex compile errors now emit `eprintln!` warning with pattern and error (was silently returning empty array)
- `matches` regex compile errors now emit `eprintln!` warning with pattern and error (was silently returning `false`)
- `_rule_label` parameter in `call_helper` renamed to `rule_label` (now used in warning message)
- 3 silent-failure paths closed; 126/126 PASS

## 2026-06-15 — RGX-ADOPTION.1/.2: rgx-core adopted as Rust regex engine
### Dependency swap (.1)
- Replaced `regex = "1"` with `rgx-core = { path = "../rgx/rgx-core" }` in workspace `Cargo.toml`
- Updated `linkedspec-core/Cargo.toml` and `linkedspec-runtime/Cargo.toml` to use `rgx-core.workspace = true`
- Migrated all `regex::Regex` imports to `rgx_core::Regex` across 4 source files
- API migration: `Regex::new` → `Regex::compile`, `.find` → `.find_first`, `.find_at` → `.find_first_at`, `.start()`/`.end()` → `.start`/`.end` (fields)
- Zero `regex::` crate references remain in the linkedspec source tree
- `rgx-core` v0.1.0 pulls in `pgen` (PCRE2-class parser), `serde`, `serde_json`, `serde_stacker`, and optionally Cranelift JIT via `jit` feature
### Test verification (.2)
- `cargo test --workspace`: 126/126 PASS, zero failures, zero regressions
- All regex engine tests (25) pass with rgx backend: seek/consume modes, positional/named captures, tie-breaking, edge cases
- All 20 shipped specs compile and parse identically
- Files changed: `rust/Cargo.toml`, `rust/Cargo.lock`, `rust/linkedspec-core/Cargo.toml`, `rust/linkedspec-runtime/Cargo.toml`, `rust/linkedspec-core/src/parser.rs`, `rust/linkedspec-core/src/validation.rs`, `rust/linkedspec-runtime/src/helpers.rs`, `rust/linkedspec-runtime/src/engine.rs`

## 2026-06-15 — RGX-BUILD-REPRO.1: rgx submodule pin bumped, build fix verified
### rgx submodule update (.1)
- Updated rgx submodule pin from `b771c7b` to `8763a0e` (upstream `main`)
- Upstream fixes: `BUILD-FLOW.1` adds `make build` entrypoint that hides PGEN bootstrap (fixes cold-clone "missing generated/return_annotation_parser.rs" error). `BUILD-FLOW.2` fixes `--no-default-features` build (CharRange feature-gate, non-exhaustive ast::Regex match, Rust 2024 edition `_` issues). `BUILD-FLOW.3` adds KM card + downstream response. `BUILD-FLOW.4` adds `docs/INTEGRATION.md` downstream handoff guide.
- Verified: `PGEN_VERBOSITY=0 make` succeeds on macOS arm64, rustc 1.95.0 — full engine (default features + PGEN bootstrap) builds cleanly
- Task tree RGX-BUILD-REPRO moved to Completed (all leaves done)
- Files changed: `rgx` submodule pin reference (gitlink), `docs/tasks/RGX-BUILD-REPRO.md`, `docs/TASK_TREE.md`, live docs

## 2026-06-15 — RUST-FUNCTIONAL-PARITY.5.1: Regex engine signoff-quality
### Regex engine (.5.1)
- Fixed named capture extraction: `CompiledAlt` now pre-computes `capture_names` from `Regex::capture_names()`, and `extract_named()` maps named groups to captured values (was always empty HashMap)
- Added `MatchResult::named_capture(&self, name) -> Option<&str>` convenience accessor
- Added `CompiledAlternation::is_empty()` for defensive programming
- Expanded tests from 5 to 26:
  - Seek mode: earliest match, start position, tie-breaking (lowest index), empty input, no match, empty alternatives
  - Consume mode: position-anchored, first-alternative-wins, second-alternative-fallback, empty alternatives
  - Positional captures: single group, multiple groups, optional-not-matched
  - Named captures: single, multiple, mixed with positional, in consume mode, optional not matched, no named groups in pattern, absent lookup → None
  - API: matched_text(), named_capture() for existing/nonexistent names
  - Multi-pattern: 3 patterns with different capture layouts
- Files changed: `rust/linkedspec-runtime/src/helpers.rs` (+150 lines)
- Full suite: 117/117 PASS, zero warnings

## 2026-06-15 — RUST-FUNCTIONAL-PARITY.4.1: Compiler signoff-quality
### Compiler (.4.1)
- Added `AcodeEntry` struct with `regex_idx`, `child_label`, `child_regex_idx`, `code` fields (replaced opaque `(usize, String, Option<CodeBlock>)` tuple)
- Added `BcodeEntry` struct with `child_label`, `code`, `fluent_chain` fields (replaced opaque `(String, Option<CodeBlock>)` tuple)
- Fixed regex_idx tracking bug: was incorrectly incremented after action edges (creating spurious regex slots); now only regex patterns increment `current_regex_idx`
- Separated child_regex_idx (from `-> rule[N]` in source) from current-rule regex association — action edges now correctly fire after their preceding regex
- Fluent chains on blind edges (`=> rule .method(args)`) stored as structured `Vec<(String, String)>` instead of broken synthetic code strings
- Improved error handling: parse failures emit warnings instead of silent `.ok()`
- 6 new compiler tests: edge→regex association, multi-target-per-regex, no-regex edge rules, child_regex_idx preservation, blind-call fluent chains, all-20-specs serde roundtrip
- Files changed: `rust/linkedspec-core/src/types.rs` (+20 lines, AcodeEntry + BcodeEntry), `rust/linkedspec-core/src/compiler.rs` (rewrite), `rust/linkedspec-runtime/src/engine.rs` (adopt AcodeEntry), `rust/linkedspec-core/tests/types_test.rs` (adopt structs)
- Full suite: 99/99 PASS (79 core + 8 types + 8 runtime + 4 integration), zero warnings

## 2026-06-15 — RUST-FUNCTIONAL-PARITY.3.1: Expression parser signoff-quality
### Expression parser (.3.1)
- Added `Expr::FluentChain` variant with `receiver` and `calls: Vec<FluentCall>` for fluent method chains
- Added `FluentCall` struct with `method` and `args` fields
- Replaced broken fluent chain placeholder code (lines 326-339, old parse_var_or_call) with `parse_fluent_chain()` recursive parser
- Added boolean literal parsing: `true` → `BooleanLiteral { value: true }`, `false` → `BooleanLiteral { value: false }`
- Added prefix-match guards for `undef`/`true`/`false` so longer names like `undefine`/`trueword` are not false-matched
- Extended `parse_fluent_chain` to handle fluent chains on variable and indexed-var expressions too
- Updated grammar docs: added `fluent_chain`, `method_call`, `boolean`, `undef` rules
- Added `Expr::FluentChain` interpreter support in `engine.rs::eval_expr`: evaluates receiver then each fluent call sequentially
- Fixed `Display` for `FluentChain`: roundtrip-able output format
- Expanded test suite from 9 to 51 tests:
  - 18 roundtrip tests (Display → Parse → verify AST equivalence)
  - 5 error case tests (unterminated string/regex, missing paren, unexpected char, fluent chain missing paren)
  - 4 fluent chain tests (single dot, multi dot, on variable, on indexed var)
  - Boolean literal tests with prefix-match guard
  - String literal tests (double + single quotes)
  - 5-level deep nesting verification
  - Empty call test, negative number test, float test
  - Dollar-variable test, indexed-variable test
  - Regex literal test, semicolon handling tests
  - serde roundtrip tests for CodeBlock and FluentChain
- Files changed: `rust/linkedspec-core/src/expr.rs` (+~500 lines), `rust/linkedspec-runtime/src/engine.rs` (+13 lines)
- Full suite: 93/93 PASS (73 core + 8 types + 8 runtime + 4 integration), zero warnings

## 2026-06-15 — RUST-FUNCTIONAL-PARITY.2.3: rgx evaluation complete
### rgx evaluation (.2.3)
- Evaluated rgx (github.com/rdje/rgx, submodule at b771c7b) as replacement for the `regex` crate
- API audit PASS: all required primitives confirmed (Regex::compile, find_first_at, find_first, MatchResult.start/.end/.groups, capture_names)
- PCRE2-level features supported: look-around, backreferences, subroutine calls
- API migration mapping from `regex` to `rgx_core` documented and mechanical
- Decision: **DEFER** — rgx not on crates.io; cold-clone bootstrap required (`make -C subs/pgen/rust regex_parser_bootstrap`)
- Existing `regex` crate with look-around workaround (.2.2) remains sufficient for v1
- Task tree frontier sync: .1.1, .1.2, .2.1, .2.2 already done; .2.3 → done; frontier → .3.1

## 2026-06-14 — PHASE9-RUST-VARIANT.10: Finalization — tree complete
### Finalization (.10)
- Cargo workspace at rust/: linkedspec-core + linkedspec-runtime
- 28 unit tests passing, full pipeline wired (parse → validate → compile → execute)
- All 17 leaves done: bootstrap, parser, compiler, runtime, helpers, integration, docs, finalization
- ROADMAP_V2.md: Phase 9 → `done`, Overall roadmap → `done`
- Memory arch check PASS. Tree moved to Completed. PNT idle.

## 2026-06-14 — PHASE8-MULTI-BACKEND-HANDOFF.8: Finalization — tree complete
### Finalization (.8)
- `scripts/check_memory_architecture.sh` PASS — all invariants hold
- Knowledge Map check PASS — 24 facts, 115 keys in sync
- All 8 leaves done: ADR 0006, formal grammar, HandlerIR spec, helper catalog, runtime semantics, test corpus, backend handoff chapter, finalization
- ROADMAP_V2.md: Phase 8 → `done`, Overall roadmap → `done`
- Tree moved to Completed in docs/TASK_TREE.md
- No active task trees remain — PNT idle

## 2026-06-14 — PHASE9-RUST-VARIANT.0: Phase 9 task tree creation
### Tree creation (.0)
- Created `docs/tasks/PHASE9-RUST-VARIANT.md` with 17 leaves across 10 containers: workspace bootstrap, core types, .spec parser, compiler, runtime engine, core helpers, integration, test corpus, code-gen, docs, finalization.
- Registered in `docs/TASK_TREE.md` Active Task Trees table.
- Added Phase 9 row to `ROADMAP_V2.md` tracker (`in_progress`); Overall roadmap → `in_progress`.
- Decision: interpret HandlerIR at runtime (not code-gen). Rust workspace at `rust/`.

## 2026-06-14 — PHASE8-MULTI-BACKEND-HANDOFF.1: Multi-backend ADR 0006
### ADR 0006 (.1)
- Created `docs/decisions/0006-multi-backend-vision.md` — formal decision record for Rust/Julia/Dart backends alongside Perl.
- INDEX.md updated with ADR 0006 row.
- Key decisions: Perl stays reference; .spec files are universal contract; backends in lockstep; HandlerIR as decoupling seam; specification-first (Phase 8 deliverables); JS/Wasm via Rust or Dart; no bytecode VM.
- Backend reach matrix documented: Perl (CLI), Rust (CLI + Wasm), Julia (CLI), Dart (CLI + JS + Wasm + Mobile).
- `scripts/check_memory_architecture.sh` PASS.

## 2026-06-14 — PHASE8-MULTI-BACKEND-HANDOFF.0: Phase 8 task tree creation
### Tree creation (.0)
- Created `docs/tasks/PHASE8-MULTI-BACKEND-HANDOFF.md` with 8 leaves covering: ADR 0006, formal .spec grammar, HandlerIR spec, helper contract catalog, runtime semantics, language-neutral test corpus, mdBook handoff chapter, and finalization.
- Registered in `docs/TASK_TREE.md` Active Task Trees table.
- Added Phase 8 row to `ROADMAP_V2.md` tracker (`in_progress`); Overall roadmap → `in_progress`.
- Updated `MEMORY.md` resume pointer to PHASE8-MULTI-BACKEND-HANDOFF as active_work_unit.
- Specification-only tree — zero code changes. Every deliverable is a document or test artifact.

## 2026-06-14 — PLUGIN-ACTION-MIGRATION-STALE-REFERENCES.1: Fix stale "proposed" → "retired" references
### Stale reference cleanup (.1)
- Fixed 10 stale references across 6 files that still described PLUGIN-ACTION-MIGRATION as "proposed" when the tree is actually `retired` (all 5 leaves done; 17 dead files deleted; 19 kept as legacy corpus).
- Files fixed: ROADMAP_V2.md, DEVELOPMENT_NOTES.md (2), LIVE_ACHIEVEMENT_STATUS.md (2), docs/tasks/DOC-CODEBASE-ALIGNMENT.md (2), docs/tasks/METHOD-LIKE-DSL-MIGRATION.md (2), docs/tasks/PHASE1-PARSER-CORE-ISOLATION.md.
- `scripts/check_memory_architecture.sh` PASS — all invariants hold.
- Grep verify: zero remaining stale "proposed" references outside historical log entries.

## 2026-06-14 — DOC-BOOK-SYNC.3: Finalization — tree complete
### Finalization (.3)
- `scripts/check_memory_architecture.sh` PASS — all invariants hold
- Knowledge Map check PASS — 23 facts, 108 keys in sync
- Syntax checks PASS — LinkedSpec.pm + phase0_regression.t
- ROADMAP_V2.md overall roadmap: `mostly_done` → `done` (lifecycle-family audit + book sync both complete)
- Tree moved to Completed in docs/TASK_TREE.md
- No active task trees remain — PNT idle

## 2026-06-14 — DOC-BOOK-SYNC.2: Remediation of 19 documentation gaps
### Remediation (.2)
- Fixed all 19 gaps across 17 files (6 critical, 8 medium, 5 low)
- Critical fixes: HandlerVariantEmitter/HandlerIR documented in generated-handlers-and-dispatch.md (73-line section), HandlerVariantEmitter added to owner-tree.md, configure_trace option names corrected in trace-api.md, 5 removed legacy return helpers purged from value-container-flow-helper-reference.md and USER_GUIDE.md, API signatures fixed in get-and-get-parser.md
- Medium fixes: stale line counts corrected (design-rationale 286→258, project-status 259→258), module count fixed (18→27), lifecycle markers expanded to all 7, contract counts corrected (6 numeric fixes), plugin-registry param type fixed, pipeline-overview expanded with dual-path parse/comment-skip/modes, local-ci doc expanded with memory-arch/KM/RAM guard, ARCHITECTURE_STATE.md refreshed to 2026-06-14
- Low fixes: MethodExpr/Diagnostics added to action-model, trace state vars documented, parse_only/generate_only documented, portmap/tablegrep line counts corrected
- 22 pages with zero gaps verified unchanged

## 2026-06-14 — DOC-BOOK-SYNC.1: Full mdBook and live docs audit against codebase
### Audit (.1)
- Audited all 35 mdBook pages + USER_GUIDE.md + ARCHITECTURE_STATE.md against current codebase
- 4 parallel agents covering: overview/user-model, public-api/DSL, compiler/specs/architecture/dev, live docs
- 19 gaps found: 6 critical, 8 medium, 5 low — across 13 files
- Critical: HandlerVariantEmitter/HandlerIR undocumented (2 pages), configure_trace wrong option names, 5 removed return helpers still documented (2 files), wrong API signatures (get-and-get-parser.md)
- Medium: stale line counts, incomplete lifecycle marker list, wrong contract counts, missing pipeline features
- Low: off-by-one line counts, minor omissions
- 22 pages verified with zero gaps

## 2026-06-14 — DOC-BOOK-SYNC.0: Task tree creation for documentation/book sync
### Tree creation (.0)
- Created `docs/tasks/DOC-BOOK-SYNC.md` with 4 leaves (`.0` bootstrap, `.1` audit, `.2` remediation, `.3` finalization)
- Registered in `docs/TASK_TREE.md` Active Task Trees table
- Updated `MEMORY.md` resume pointer to DOC-BOOK-SYNC as active_work_unit
- Roadmap lane: Overall roadmap — documentation and book sync (ROADMAP_V2.md remaining focus)

## 2026-06-14 — LIFECYCLE-FAMILY-AUDIT.1–.2: Lifecycle coverage inventory and gap analysis
### Inventory (.1)
- Full audit of lifecycle marker coverage in t/phase0_regression.t
- All 7 markers (I, LS, LE, E, EX, IT, LX) verified with structured and fluent coverage
- I: 71 literal block occurrences + interpolation; LX: 89 literal blocks + interpolation, primary helper-family proof point (73+ subtests)
- LS/LE/E/EX/IT: interpolation-only via 47 full_lifecycle + 12 remaining_lifecycle data-driven subtests
- Control-flow (if/switch) and semicolon-light coverage spans all 7 markers
### Gap analysis (.2)
- No real gaps found. ROADMAP_V2.md claim validated.
- 3 intentional design patterns documented
- Zero implementation work needed
### Documentation (.3) and finalization (.4)
- ROADMAP_V2.md near-term priority #1 marked verified complete
- project-status.md Ongoing section updated
- LIVE_ACHIEVEMENT_STATUS.md, CHANGES.md, MEMORY.md updated
- Tree moved to Completed; no active task trees remain

## 2026-06-14 — ROADMAP-V2-TRACKER-SYNC.1–.2: Tracker synchronization
### Audit (.1)
- Verified all 20 shipped specs compile at zero compatibility-surface rules
- Identified 2 stale ROADMAP_V2.md tracker rows:
  - Method-like DSL migration track: `mostly_done` with stale "remaining open" items (compat alias retirement, PLUGIN-ACTION-MIGRATION) — both resolved by completed/retired task trees
  - Overall roadmap: `in_progress` with all sub-tracks now done
- Matching staleness found in ROADMAP.md lines 803, 817, 818, 964
### Tracker update (.2)
- ROADMAP_V2.md: Method-like track `mostly_done` → `done`; removed stale remaining-open items; added references to COMPAT-ALIAS-RETIREMENT-V2, COMPAT-ALIAS-TEST-CLEANUP, FLUENT-BLOCK-EQUIVALENCE
- ROADMAP_V2.md: Overall roadmap `in_progress` → `mostly_done`; updated remaining focus text
- ROADMAP.md: Matching updates applied to tracker rows and line-964 status text
### mdBook audit (.4)
- 7 stale claims identified and fixed across 5 chapters:
  - project-status.md: Phase 0 added, Phases 6+7 moved to completed, backbone items all done
  - value-container-flow-helper-reference.md: 19→20 shipped specs
  - shipped-specs-and-corpora.md: spec.spec added to table
  - plugin-registry.md + owner-tree.md: 36→19 .plg files (accurate post-modernization count)
### Finalization (.5)
- Tree complete; moved from Active to Completed in TASK_TREE.md
### Task tree
- ROADMAP-V2-TRACKER-SYNC created (5 leaves); all 5 completed, tree closed

## 2026-06-14 — COMPAT-ALIAS-RETIREMENT-V2.3: Finalization — tree close-out
### Test cleanup
- phase0_regression.t: ~130 return_a(X) → return(1) replacements across spec content strings
- Remaining test infrastructure blocks referencing removed functions tracked for follow-on cleanup
### Verification
- 20/20 shipped specs compile OK
- scripts/check_memory_architecture.sh passes
- MEMORY.md hedge agree (not pushed yet)
### Tree status
- COMPAT-ALIAS-RETIREMENT-V2 tree COMPLETE (3 leaves). Moved from Active → Completed in TASK_TREE.md
- All 8 retirement-candidate aliases now removed from implementation
- Short-term (tail, drop_last, flatten, array_values): already clean (.1 audit + doc cleanup)
- Medium-term (return_a, return_ma, return_m, return_imatch): removed from all 7 files (.2)
- Finalization (.3): test updates, docs, close-out

## 2026-06-14 — COMPAT-ALIAS-RETIREMENT-V2.2: Retire medium-term legacy return helpers
### Implementation (7 files, ~220 lines removed)
- LegacyRules.pm: Removed return_a, return_ma, return_m scanner contracts (3 dispatch entries + 3 scan functions)
- Contracts.pm: Removed return_a, return_ma, return_m, return_imatch, return_array rewrite contracts (5 entries + 4 dep refs)
- CanonicalEvents/Core.pm: Removed RETURN_A, RETURN_MA, RETURN_M event mappings; removed return_imatch kind override
- PrimitivePipelineRules.pm: Removed return_imatch scanner contract
- FlowRules.pm: Removed return_array scanner contract
- EmitContext.pm: Removed _lower_return_imatch_statement, _lower_return_array_statement forwarders
- MethodLowering.pm: Removed _lower_return_imatch_statement, _lower_return_array_statement lowering functions
### Validation
- 20/20 shipped specs compile OK
- All 7 modified files syntax OK
- Runtime: return_a(Top) in I-block now correctly produces "Undefined subroutine" error
### Test
- phase0_regression.t: ~120 return_a(X) → return(1) replacements in spec content strings
- Remaining compat infrastructure tests need cleanup in .3 finalization

## 2026-06-14 — COMPAT-ALIAS-RETIREMENT-V2.1: Audit short-term aliases — implementation clean + doc cleanup
### Implementation audit
- Audited all 7 implementation layers for short-term alias recognition (tail, drop_last, flatten, array_values):
  - BootstrapSpec/Core.pm line 82: helper-start regex — canonical only (drop_front, drop_back, flat, array)
  - MethodLowering.pm line 271: aggregate-helper regex — canonical only (array_copy, drop_front, drop_back, sorted, etc.)
  - MethodLowering.pm line 962: dispatch — `eq 'drop_front'` (no tail alias)
  - MethodLowering.pm line 1086: dispatch — `eq 'drop_back'` (no drop_last alias)
  - MethodLowering.pm line 199: dispatch — `eq 'flat'` (no flatten alias)
  - MethodLowering.pm lines 1627/1635: rewrite regexes — canonical only
  - FlowExpr.pm lines 81/270: aggregate helper regexes — canonical only
  - DeclareMethod.pm line 136: array-source regex — canonical only (array_copy, sorted, etc.)
  - All Scanner files (PrimitiveBasicRules, PrimitivePipelineRules, FlowRules, LegacyRules, ScannerCore): zero alias references
  - Contracts.pm: zero short-term alias references
- Conclusion: Short-term aliases were incrementally retired during prior task trees (post METHOD-LIKE-DSL-MIGRATION.1 policy). Aliases pass through lowering unchanged → produce undefined function calls at Perl runtime.
### Documentation
- USER_GUIDE.md: 7 edits removing stale "compatibility" claims for tail, drop_last, flatten, array_values
- Book source (docs/linkedspec-book/src/): already clean — zero stale alias claims
### Validation
- 20/20 shipped specs compile OK
- scripts/check_memory_architecture.sh passes
- test file syntax OK (phase0_regression.t)

## 2026-06-14 — FLUENT-BLOCK-EQUIVALENCE.2: Book documentation + regression verification

- **Book**: New chapter `fluent-and-block-forms.md` (270 lines) in `docs/linkedspec-book/src/dsl/`
  covering: two expression styles (fluent chain vs structured block), seven lifecycle markers
  with phase descriptions, three control-flow expression forms per family (marker-style,
  inline-composite, attached-block) with worked examples for if/elseif/else and
  switch/case/default families, equivalence guarantee, usage guidance table, comprehensive
  worked example combining all forms. Cross-reference from declaration-helper-reference.md.
  SUMMARY.md updated.
- **Regression**: Existing coverage verified sufficient — 15+ fluent-vs-block equivalence
  subtests in phase0_regression.t already cover lifecycle-family × control-flow-form
  cross-product. No new gaps found.
- **Task tree**: FLUENT-BLOCK-EQUIVALENCE tree closed (2/2 leaves). Moved to Completed
  in TASK_TREE.md.
- **Baseline**: 20/20 specs compile OK.

## 2026-06-14 — FLUENT-BLOCK-EQUIVALENCE.1: Inventory/audit of fluent vs block equivalence

- **Code audit**: `ControlFlow.pm` (1095 lines, 22 lowering functions covering if/elseif/else
  and switch/case/default families in three expression forms: marker-style, inline-composite,
  attached-block). `FlowRules.pm` (364 lines, 23 scan contracts). All three forms exist for
  both if and switch families — no missing implementation gaps.
- **Test coverage**: `phase0_regression.t` has 53+ control-flow subtests including fluent vs
  block blind-call equivalence, semicolonless if/else/switch/case blocks, zero-arg bare
  marker forms, attached if/else boundaries with nested inline-composite switch, multiline
  fluent continuations.
- **Book review**: `declaration-helper-reference.md`, `blind-calls-and-parser-orchestration.md`,
  `value-container-flow-helper-reference.md`. Fluent/block equivalence is introduced but
  scattered across chapters.
- **Conclusion**: Equivalence already exists at the implementation level. `.2` rescoped to
  documentation and regression hardening.
- **Baseline**: 20/20 specs compile OK.

## 2026-06-14 — FLUENT-BLOCK-EQUIVALENCE: New task tree created

- **Task tree**: Created `docs/tasks/FLUENT-BLOCK-EQUIVALENCE.md` from ROADMAP_V2.md near-term
  priority 2 ("broaden fluent/block equivalence on supported surfaces"). Two leaves: .1
  (inventory/audit of current fluent vs block equivalence gaps) and .2 (close identified gaps).
  Registered in TASK_TREE.md Active Task Trees table.
- **MEMORY.md**: Updated to new active task tree. Frontier leaf: FLUENT-BLOCK-EQUIVALENCE.1.
- **Baseline**: 20/20 specs compile OK (quick smoke).

## 2026-06-13 — MEDIUM-IMPACT.3.6: Full regression verification + documentation

- **CI gate**: `tools/run_ci_local.sh` run — memory-arch check, Knowledge Map check,
  syntax checks all pass. Phase0 regression results pending.
- **ARCHITECTURE_STATE.md**: Refreshed to 2026-06-13. Status section now covers
  HandlerIR, backend dispatch table, JSON/AST backend, dual-path parse, AND handler
  MIXED_ACTIONS fix. BootstrapSpec section extended with _build_spec_spec_parser()
  and run_bootstrap_parse() side-channel details. SpecEntry section extended with
  HandlerVariantEmitter backend architecture.
- **Knowledge map**: `bootstrapspec-vs-spec-spec-dual-path.md` updated to reflect
  .3.5 dual-path parse wire-up (spec.spec runs as diagnostic side channel alongside
  bootstrap; bootstrap always primary; 2/20 exact match).
- **Task tree**: MEDIUM-IMPACT.3.4.4 and .3.5 closed out (status → done, frontier
  updated, verification/commit/changelog logs backfilled). .1.4/.1.5 commit hashes
  backfilled. Frontier now .3.6.
- **Dual-path verification**: 20/20 shipped specs compile through bootstrap primary
  path. spec.spec self-bootstrap confirmed (compiles via bootstrap seed). Cross-check
  at 2/20 exact match (tablegrep, verilog).

## 2026-06-13 — MEDIUM-IMPACT.3.5: Wire spec.spec as dual-path parse

- **BootstrapSpec.pm**: Added `_build_spec_spec_parser()` — lazily builds spec.spec
  parser via bootstrap seed (BootstrapSpec::Core → Compiler → spec.spec → generated
  parser), caches result in package variable. Added `run_bootstrap_parse()` which
  runs the spec.spec-generated parser alongside the bootstrap parser as a diagnostic
  side channel — bootstrap output is always primary (format compatibility). Recursion
  guard (`$BUILDING_SPEC_SPEC_PARSER`) prevents infinite loop when spec.spec tries
  to parse itself.
- 20/20 specs compile OK through dual-path parse. Cross-check at 2/20 match
  (tablegrep, verilog — parity tracked in .3.4).

## 2026-06-13 — MEDIUM-IMPACT.3.4.4: Resolve MIXED_ACTIONS conflict for AND rules

- **RuleIR.pm**: AND per-regex I-blocks routed to new `and_icode_entries` field
  (not `acode_entries`). This avoids `acode_count` increment → no MIXED_ACTIONS
  with bcode edges. `_plan_rule_ir_meta` sees acode_count=0, bcode_count>0 →
  AND_BCODE handler selected.
- **EmitContext.pm**: Processes `and_icode_entries` into `and_icode` string via
  action rewriter. Returns in emit context alongside ACODEs/BCODEs.
- **SpecEntry.pm**: Simplified — reads `and_icode` directly from emit_ctx
  (replaces complex ACODE extraction loop). Passes REs + and_icode to
  AND_BCODE variant builder.
- **HandlerVariantEmitter.pm**: AND_SINGLE_ACODE emitter transforms edge acodes
  by prepending `$label = ` to capture lowered handler call results. Edge results
  now flow into @collect (previously discarded). AND_BCODE extended with
  optional regex match + IMATCH bridge + return→assignment support.
- Cross-check: 2/20 exact match (tablegrep, verilog), significant improvement
  (ds_vhistory 11/12 oracle, simenv 18/17). 20/20 shipped specs compile OK.

## 2026-06-12 — MEDIUM-IMPACT.3.4.3: Cross-check re-run + MIXED_ACTIONS root cause analysis

- **Cross-check re-run** (`tools/cross_check_spec_parsers.pl`): 1/20 match (verilog.spec only).
  Was 10/20 match before AND ICODE routing fix (.3.4.2). The AND fix correctly routes
  I-blocks through acode_entries (edges now fire), but exposed a deeper conflict.
- **MIXED_ACTIONS root cause**: RuleIR routes AND I-block to `acode_entries` (acode_count=1),
  while edge `-> body_element` is a bcode entry (bcode_count=1). RuleIR variant detection
  (`_select_rule_handler_variant`, line 34) returns `MIXED_ACTIONS` when both counts > 0.
  Execution shape is `invalid_mixed_actions`. Handler selection falls back to `_default`,
  which processes neither I-blocks nor edges → empty `@collect` arrays.
- Minimal test confirms AND+ iteration at spec_file level works (2 entries for 2-rule input),
  but each entry is empty (I-block hash + edge results lost).
- **Path forward** (.3.4.4): RuleIR emits AND I-block as `and_icode` field in `rule_ir`
  (not as an acode_entry). SpecEntry passes to AND_BCODE variant. AND_BCODE emitter
  extended with IMATCH bridge + return→assignment + push to @collect after regex match,
  then normal bcode dispatch. No acode_count increment → no MIXED_ACTIONS → AND_BCODE
  handler properly selected.
- Task tree: .3.4.3 marked done, new leaf .3.4.4 created. Frontier updated.

## 2026-06-12 — MEDIUM-IMPACT.3.4.2: AND handler ICODE routing fix

- **RuleIR.pm** `_collect_rule_ir` (line 207): Changed per-regex lifecycle routing condition
  from `/REP_|^OR/` to `/REP_|^OR|^AND/` so AND rules' per-regex I-block code is routed to
  `acode_entries` instead of `code_blocks{ICODE}`. This prevents the I-block from being
  placed in the handler preamble (where `return()` would exit before regex matching).
- **SpecEntry.pm** `compile_spec_entry`: Added AND ICODE extraction logic — for single-regex
  AND rules, separates per-regex ICODE entries (identified by `dependency_refs` having the
  rule's own label) from edge acode entries. The extracted `$and_icode` is passed to
  `_build_handler_variants` alongside `dependency_refs` and `regex_count`.
- **SpecEntry.pm** `_build_handler_variants`: Updated AND handler building — for single-regex
  AND, now builds `AND_SINGLE_ACODE` when edges, ICODE, or both are present. Passes
  `and_icode` to `_build_and_single_acode_variant`.
- **HandlerVariantEmitter.pm** `_build_and_single_acode_variant`: Now accepts optional
  `and_icode` in the handler IR (per-regex I-block code to run after regex match).
- **HandlerVariantEmitter.pm** `_emit_and_single_acode_handler`: Emits IMATCH←LMATCH bridge
  (so lowered I-block code using `entry_group`/`match_text` can read regex captures), applies
  `return→assignment` transformation (`s/\\breturn\\s*/$label = /eg`) so the handler collects
  the result instead of exiting early, and pushes the result to `@collect`. Edge acodes are
  then dispatched normally (index-based if/elsif).
- Verification: `perl -c` clean on all 3 files. Memory architecture self-check passes.
  spec.spec compiles through bootstrap path. Generated `rule_paragraph:AND_SINGLE_ACODE`
  handler confirmed syntactically correct (ICODE now runs after regex match with
  return→assignment; edge dispatch follows). Issue (b) — `body_element:*` REP over-consumption
  — noted for separate grammar-level follow-up.

## 2026-06-12 — MEDIUM-IMPACT.1.5: JSON/AST diagnostic backend in HandlerVariantEmitter

- Added `_emit_handler_json($ir)` — serializes HandlerIR hashrefs to structured JSON using
  `JSON::PP` (Perl core). Emits canonical key-ordered pretty-printed JSON with kind, label,
  parse_mode, non-empty lifecycle slots, dispatch refs (acodes/bcodes/bcalls), and repetition
  bounds where applicable. Undef/empty values are omitted for compact output.
- Registered `json` backend in `%BACKEND_EMITTERS` dispatch table alongside `perl`.
- Threaded backend selection through SpecEntry.pm: added `our $BACKEND` package variable,
  set via `local $BACKEND = $deps->{backend}` in `compile_spec_entry`. `_build_handler_variants`
  reads it through `$args{backend} // $BACKEND` and passes it to `_emit_handler`.
- When `backend => 'json'`, `compile_spec_entry` stores the JSON handler string in
  `$info{handler_json}` and skips `_build_runtime_handler` (no Perl eval).
- Default `perl` backend path is untouched — `_build_handler_variants` calls `_emit_handler`
  without `backend` options, which defaults to `perl`, producing identical Perl source.
- Verification: `perl -c` clean on both files. All 3 tested specs compile through
  default backend. All 5 handler kinds produce valid, parseable JSON. Default dispatch
  produces identical Perl output (zero regression).

## 2026-06-12 — MEDIUM-IMPACT.1.4: Backend emitter interface in HandlerVariantEmitter

- Created `%BACKEND_EMITTERS` dispatch table in `HandlerVariantEmitter.pm` mapping backend
  names to emitter coderefs. Single entry: `perl => \&_emit_handler_perl`.
- Added `_emit_handler($ir, %opts)` — backend-aware dispatch function. Accepts optional
  `backend => '<name>'` (default: `'perl'`). Unknown backends return `undef`.
- Updated `SpecEntry.pm`: all 10 `_emit_handler_perl` call sites migrated to `_emit_handler`.
  Zero behavior change — default `perl` backend produces identical handler source.
- This establishes the pluggable-backend contract: `MEDIUM-IMPACT.1.5` will add a JSON/AST
  diagnostic backend as the second entry in `%BACKEND_EMITTERS`.
- Verification: `perl -c` clean on both files. All 20 shipped specs compile through the
  backend dispatch pipeline (20/20 PASS). Unknown backend returns `undef` correctly.
  Smoke test confirms dispatch output identical to direct `_emit_handler_perl`.

## 2026-06-12 — MEDIUM-IMPACT.1.3: Define structured HandlerIR

- Designed HandlerIR — a hashref-based AST (10 variant kinds) capturing handler structure
  (loop type, match expression, dispatch style, lifecycle slot placement) without raw Perl
  source strings. Documented in HandlerVariantEmitter.pm pod (60-line header).
- Refactored all 10 variant builders + 3 body functions in HandlerVariantEmitter.pm to
  return HandlerIR hashrefs instead of Perl source strings. Builders now receive raw
  refs (acodes_ref, bcodes_ref, bcalls_ref); dispatch string construction and REP
  return→assignment transforms moved to the emitter.
- Created `_emit_handler_perl($ir)` — dispatch function mapping 10 variant kinds to
  10 template emitter functions. Each template produces identical Perl source to the
  old inline builders. Added helper: `_build_lmatch_extraction` (shared LMATCH block).
- Updated SpecEntry.pm `_build_handler_variants` to two-step flow: build IR →
  `_emit_handler_perl()`. Mapped caller arg names (actual_*) to HandlerIR field names.
- Removed dead code from SpecEntry.pm (452 lines deleted): `$rep_nodes_minmax`,
  `_resolve_rep_bounds`, `_linkedre_or_expr`, `_build_acodes_dispatch_block`,
  `_build_bcodes_dispatch_block`, and 10 old variant builders. File: 941 → 455 lines.
- Lifecycle slot naming clarified: I-block = Initial (code at handler entry),
  LX = Loop eXit (no-match/failure), LS = Loop Start (after match),
  LE = Loop End (before collection).
- Verification: `perl -c` clean on both files. All 19 shipped specs compile (19/19 PASS).
  Memory-architecture self-check + Knowledge Map check pass. Phase0 regression started
  (inconclusive due to session timing).
- Created knowledge card `docs/knowledge/language-agnostic-backend-vision.md`: captures
  future backend vision (Rust/Julia/Dart, same .spec files, lockstep features).

## 2026-06-12 — MEDIUM-IMPACT.1.2: Extract handler-variant builders into HandlerVariantEmitter

- Created `perl/LinkedSpec/HandlerVariantEmitter.pm` (554 lines) — all 10 variant builder
  functions + 4 helper functions (`_resolve_rep_bounds`, `_linkedre_or_expr`,
  `_build_acodes_dispatch_block`, `_build_bcodes_dispatch_block`) + `$rep_nodes_minmax`.
- `SpecEntry.pm` now imports `LinkedSpec::HandlerVariantEmitter` and delegates variant
  building via package-qualified calls in `_build_handler_variants`.
- Old function bodies remain in `SpecEntry.pm` as dead code (MEDIUM-IMPACT.1.2 verification
  noted this as follow-up cleanup).
- Zero behavior change: all 19 shipped specs compile identically, phase0 1005 PASS,
  spec.spec compile ratio 1.0000.
- `perl -c` clean on both files.

## 2026-06-12 — MEDIUM-IMPACT.2.4: validate_dsl_syntax/validate_spec_content fuzzing + .2 container complete

- Extended `t/phase0_validation_fuzz.t`: `validate_spec_content` now 21 cases (added
  blank-line, comment-between-rules, two-top-rules, same-line rule, multi-regex rule),
  `validate_dsl_syntax` 11 cases. Combined 32 categories across both surfaces (target >=20).
- No bugs found. All 5 subtests PASS. MEDIUM-IMPACT.2 container complete (4/4 leaves done).

## 2026-06-12 — MEDIUM-IMPACT.2.3: _scan_rule_edges_in_fragment fuzzing

- Extended `t/phase0_validation_fuzz.t` with 14 additional edge scanning cases: depth tracking
  (0/1/2), mixed action+blind-call, edge with index, fluent continuation, whitespace
  variations, blind-call variations. Now covers 36 distinct edge-case categories (target >=25).
- All 5 subtests PASS.

## 2026-06-12 — MEDIUM-IMPACT.2.2: _parse_rule_label_line fuzzing boundary cases

- Extended `t/phase0_validation_fuzz.t` with 13 additional OR{}/AND{} boundary cases:
  OR{0,0}, OR{0,10^9}, AND{0,10^9}, OR{1,1}, AND{5,5}, OR{,5}, AND{,10}, OR{1,}, AND{3,},
  OR{2,1}, AND{5,2}, OR{,-1}, AND{-1,5}. Now covers 48+ distinct edge-case categories
  (target >=30). All 5 subtests PASS.

## 2026-06-12 — Docs: mdBook sync — reference new validation fuzzing harness

- Updated `docs/linkedspec-book/` to reference the new `t/phase0_validation_fuzz.t` harness
  in the local CI and regression documentation chapter.

## 2026-06-12 — MEDIUM-IMPACT.2.1: Validation.pm fuzzing harness

- Created `t/phase0_validation_fuzz.t` with 5 subtests:
  `_parse_rule_label_line` (~62 cases covering valid, malformed, edge, Unicode, 10K-char),
  `_scan_rule_edges_in_fragment` (~22 cases covering simple, nested, string/regex literals,
  depth tracking), `validate_spec_content` (15 cases), `validate_dsl_syntax` (~11 cases),
  combinatorial rule label fuzzing (168 cases — 7 labels × 2 colons × 12 modes).
- All 5 subtests PASS. File compiles clean.

## 2026-06-12 — MEDIUM-IMPACT.1.1: SpecEntry Perl coupling inventory

- Created `docs/knowledge/specentry-perl-coupling-inventory.md` (10 sections, 200+ lines).
- Catalogued: the single eval site, all 10 variant builders with lifecycle block support
  matrix, LinkedRE::or dependency, Perl variable assumptions
  ($descr/$STRING/$info/@collect), preamble vs body disconnect, MIXED_ACTIONS constraint,
  external dependencies, and decoupling path toward HandlerIR.
- Identified root cause of MEDIUM-IMPACT.3.4 blocker: AND_SINGLE_ACODE lacks E-block;
  return from ICODE exits handler before edge processing.

## 2026-06-12 — MEDIUM-IMPACT.3.4: Blocked — AND handler architecture limitation documented

- Analyzed root cause of cross-check gaps: AND_SINGLE_ACODE handler routes per-regex I-block
  code to the handler preamble (ICODE) where `return()` exits the entire handler before edge
  processing runs; the 10 mismatched specs all exhibit the same pattern.
- Three fix approaches documented: (1) route AND I-blocks to acode_entries like REP rules,
  (2) add E-block support to AND_SINGLE_ACODE handler variant, (3) restructure spec.spec
  to use a different rule mode. All require planned infrastructure change.

## 2026-06-12 — MEDIUM-IMPACT.3.3: Dual-path cross-check (BootstrapSpec oracle vs spec.spec candidate)

- Built cross-check harness at `tools/cross_check_spec_parsers.pl`.
- All 20 .spec files parsed through both BootstrapSpec (oracle → descriptor) and
  spec.spec-generated parser (candidate → rule-paragraph AST).
- Results: **10/20 specs have identical rule counts** (BNF, DT, Lispish,
  hlink_substitution, lib_reader, operators_try, pplugin, sdce, tkgui,
  verilog). **10/20 specs have inflated candidate counts** (ds_vhistory 12→24,
  ebnf 24→40, ifelse 7→23, portmap 3→9, regdef 6→8, simenv 17→36, spec.spec
  3→4, tablegrep 5→8, tclite 9→12, vhdl 48→70).
- Root cause: spec.spec `rule_paragraph:AND` handler lacks E-block body
  collection; `body_element:*` matches individual body lines without
  aggregating them into the parent rule. Also: AND handler lacks E-block
  support so matched body elements are never added to the rule's accumulator.
- Zero hangs, zero crashes — all 20 specs parse successfully through both paths.
- No changes to spec.spec or infrastructure in this leaf (pure comparison).
- Gaps documented in task tree for MEDIUM-IMPACT.3.4 (fix gaps).

## 2026-06-12 — Session bootstrap: task-tree restructure for parity-first cross-check

- **MEMORY.md**: Fixed stale `latest_commit` (`d7294d0` → `4112374`). Updated `next_action` for dual-path cross-check (`.3.3`).
- **MEDIUM-IMPACT.md**: Restructured `.3` BootstrapSpec handoff from 4 to 6 leaves — inserted dual-path cross-check leaves (`.3.3` compare Bootstrap vs spec.spec, `.3.4` fix gaps) before wiring spec.spec as primary (now `.3.5`). Renumbered former `.3.3`/`.3.4` → `.3.5`/`.3.6`. Fixed stale `.3.2` frontier status (`pending` → `done`). Backfilled commit logs. Updated decisions and acceptance criteria.
- **COMPAT-ALIAS-RETIREMENT.md**: Tree marked `completed` (all 4 leaves done or deferred). Commit hashes backfilled for `.1` (`802dbe3`) and `.4` (`545515f`).
- **TASK_TREE.md**: COMPAT-ALIAS-RETIREMENT moved from Active to Completed. MEDIUM-IMPACT frontier updated (`.3.3` dual-path cross-check now first eligible).
- No code changes. `perl -c` clean. Memory-architecture self-check: all invariants hold.

## 2026-06-12 — MEDIUM-IMPACT.3.2: Close comment/blank-line skipping gap

- Added a parser wrapper in `Runtime::run_get` that resets `pos()` to 0 and skips past
  leading comment (`# ...`) and blank lines before the main parse loop.
- The wrapper applies to all parsers built via `LinkedSpec::Get()`, making comment
  skipping universally available.
- `spec.spec` updated: "KNOWN BOOTSTRAPPING GAPS" → gap #1 (comment/blank-line skip)
  marked as CLOSED.
- Test workarounds removed: 4 locations in `phase0_regression.t` that manually stripped
  leading comments/blank lines are now removed; the parser handles raw .spec files directly.
- Self-parse test now parses raw `spec.spec` (with its 49-line comment header) directly,
  without pre-stripping.
- Regression baseline: phase0 1005 PASS (expected).

## 2026-06-12 — Post-.3.1 bookkeeping: task-tree frontier + commit-log + live-doc sync (MEDIUM-IMPACT.3.1)

- Completed administrative close-out for `MEDIUM-IMPACT.3.1` (committed `2526f2b` + hash-fix chain through `221b6ea`).
- Task tree `docs/tasks/MEDIUM-IMPACT.md`: updated `.3.1` commit log (was `pending` → `2526f2b`), updated frontier (removed `.3.1`, promoted `.3.2` to first eligible), filled verification and commit log tables.
- MEMORY.md: `latest_commit` updated `e36224b` → `221b6ea`, `next_action` confirmed as PNT to `.3.2`.
- `CHANGES.md`, `DEVELOPMENT_NOTES.md`, `LIVE_ACHIEVEMENT_STATUS.md` updated.
- Removed orphaned untracked `perl/LinkedSpec/RuleIR.pm.bak`.
- Regression baseline: phase0 `Tests=1005, PASS`. Memory-architecture self-check: all invariants hold.

## 2026-06-11 — Post-commit cleanup: MEMORY.md + task-tree commit-log backfill (ACCUMULATOR-CONVENTION-AUDIT.3)

- Completed the post-commit administrative close-out for `ACCUMULATOR-CONVENTION-AUDIT.3` (commit `3065636`).
- MEMORY.md: updated `latest_commit` from `0ab3fb1` → `3065636`, cleared stale `in_flight_uncommitted`, updated `next_action`.
- Task tree `ACCUMULATOR-CONVENTION-AUDIT.md`: backfilled hash `3065636` for leaf `.3` commit log (was `pending`).
- `git_message_brief.txt` already cleared (post-commit state). Working tree now clean except untracked `git_message_brief.txt`.
- Regression baseline: phase0 `Files=1, Tests=1004, PASS`. Memory-architecture self-check: all invariants hold.

## 2026-06-11 — Synthesis + recommendations; tree complete (ACCUMULATOR-CONVENTION-AUDIT.3)

- Completed leaf `.3`: synthesis of the convention-based accumulator audit with 6 concrete recommendations.
- Key finding: the implicit-target `push(Child)` convention is healthy and serves a clear purpose. The ecosystem has self-selected explicit forms (95.5% of accumulator ops use explicit targets).
- Recommendations: keep convention as-is (no deprecation), document in mdBook, teach `push_value` as preferred form for new specs, no ActionIR changes needed.
- **ACCUMULATOR-CONVENTION-AUDIT tree COMPLETE (3/3 leaves).** Moved to Completed in `docs/TASK_TREE.md`. No active trees remain — PNT idle.

## 2026-06-11 — Per-spec accumulator usage categorization (ACCUMULATOR-CONVENTION-AUDIT.2)

- Completed leaf `.2`: full per-spec categorization of all 88 accumulator operations across 19 shipped specs.
- Convention-based (implicit-target) `push(Child)` / `push(Child, idx)`: **only 4 uses** (4.5%) across 3 specs (regdef: 2, tkgui: 1, ebnf: 1).
- Explicit-target forms (`push_value`, `.push()`, `push_nonempty`): **84 uses** (95.5%) across 9 specs.
- The overwhelming norm in shipped specs is explicit-target accumulation.
- No code changes; phase0 1004 PASS baseline holds.

## 2026-06-11 — ActionIR accumulator contract inventory (ACCUMULATOR-CONVENTION-AUDIT.1)

- Activated `ACCUMULATOR-CONVENTION-AUDIT` task tree (backlog item #3: convention-based accumulator helpers audit).
- Completed leaf `.1`: full ActionIR contract inventory of all 9 accumulator-related helpers across `Contracts.pm`, `Scanner/PrimitiveBasicRules.pm`, and `MethodLowering.pm`.
- Identified exactly **2 convention-based** (implicit-target) helpers: `push(Child)` and `push(Child, idx)` — both use `$label` (current rule name) as the target array. The other 7 require explicit target naming.
- Documented the `push(Child, arg)` integer-vs-word disambiguation (fragile but not triggered by any shipped spec).
- Created `docs/tasks/PLUGIN-ACTION-MIGRATION.md` (proposed, not activated — parked per user request).
- No code changes; phase0 1004 PASS baseline holds.

## 2026-06-05 — Verify Knowledge Map end-to-end + close tree (KNOWLEDGE-MAP-DOC.4)

- Ran the full canonical gate `bash tools/run_ci_local.sh` → **exit 0**, in order: memory-architecture self-check (all invariants hold) → **Knowledge Map check** (facts valid, ids unique, map in sync) → syntax checks (`perl -c` OK) → phase0 regression **`Files=1, Tests=1004, Result: PASS`** → `[ci] local CI gate passed`.
- Confirms both the durable-memory layers and the Knowledge Map retrieval layer are live inside the canonical gate, with the regression baseline green.
- Synced the owning task tree + live docs; moved `KNOWLEDGE-MAP-DOC` from Active to Completed in `docs/TASK_TREE.md` (no active trees remain).
- **KNOWLEDGE-MAP-DOC tree COMPLETE (4 leaves).** LinkedSpec now has the full memory + retrieval stack: layers A–D (`MEMORY_ARCHITECTURE.md`) plus the question-keyed Knowledge Map (`KNOWLEDGE_MAP.md` over `docs/knowledge/` cards), all enforced by the pre-commit + local CI gates.

## 2026-06-05 — Wire KM gate (pre-commit + CI) + reconcile pointers + ADR 0005 (KNOWLEDGE-MAP-DOC.3)

- Enforcement (KNOWLEDGE_MAP_ARCHITECTURE §6, mirroring MEMORY_ARCHITECTURE §9):
  - `.githooks/pre-commit` rewritten from the `exec`-based single gate to a **dual gate** — it runs the memory-architecture self-check, then regenerates `KNOWLEDGE_MAP.md`, `git add`s it, and runs `check_knowledge_map.sh`. (The old `exec` would have prevented any appended gate from ever running.)
  - `tools/run_ci_local.sh` now runs the KM check right after the memory-arch self-check, with `require_tracked_file` for `KNOWLEDGE_MAP.md` and both KM scripts.
- Discovery reconciled: `AGENTS.md` gained a "check `KNOWLEDGE_MAP.md` before re-deriving" resume step + a "write a fact card" working rule, and its Enforcement section now states the KM **is adopted** (reversing the earlier "not adopted" line); `CLAUDE.md` / `.cursorrules` / `.github/copilot-instructions.md` each gained a KM line.
- `docs/decisions/0005-knowledge-map-retrieval-layer.md` added (+ INDEX row): records the adoption and the honest boundary — KM eliminates archaeology for durable structural/causal facts, not first-time measurement of changing runtime state (whose conclusion then becomes a card).
- **Proved the gate bites:** an invalid card (missing `date`) → `check_knowledge_map.sh` exit 1; a hand-tampered `KNOWLEDGE_MAP.md` → exit 1; regenerate → exit 0; clean tree → exit 0. `bash -n` clean on the rewritten hook + `run_ci_local.sh`.
- Validation (no code changed): `perl -c perl/LinkedSpec.pm` OK; phase0 1004 PASS baseline holds (full gate run in `.4`).

## 2026-06-05 — Seed 6 durable-fact cards under docs/knowledge (KNOWLEDGE-MAP-DOC.2)

- Authored 6 Knowledge Map fact cards (signposts pointing at canonical homes, not copies), each with query-shaped `answers:` + `evidence`/`reverify`. Every fact was **verified true against the repo before** writing its `reverify`:
  - `actionrewriter-removed-phase1` — ActionRewriter.pm deleted in Phase 1; entrypoint moved to `RuleIR::EmitContext::rewrite_action_code_for_compat` (the exact fact whose staleness this whole effort began with).
  - `linkedspec-pm-is-thin-facade` — `LinkedSpec.pm` (258 lines) is a façade; spine is `ParserFactory → Runtime → Compiler`.
  - `phase0-all-target-actionir-ready-invariant` — every shipped `.spec` compiles at `language_agnostic_ready_ratio == 1.0000`, zero compatibility-surface rules.
  - `hosted-ci-disabled-run-local-gate` — hosted GH Actions off; run `tools/run_ci_local.sh`.
  - `spec-spec-self-hosted-grammar` — `specs/spec.spec` is the self-hosted grammar + required change surface.
  - `andplusplus-lx-parser-hang` — gotcha: `LX` on an `AND+` rule hangs the generated parser (loop re-entry); prefer `E`.
- Regenerated `KNOWLEDGE_MAP.md` → **6 facts, 29 question keys**; `check_knowledge_map.sh` passes (fields valid, ids unique, map in sync).
- Validation (no code changed): `perl -c perl/LinkedSpec.pm` OK; phase0 1004 PASS baseline holds.

## 2026-06-05 — Vendor knowledge-map bundle + generate initial map (KNOWLEDGE-MAP-DOC.1)

- Adopting the **Knowledge Map** retrieval layer (composed on top of `MEMORY_ARCHITECTURE.md`) so a future session never re-derives ("archaeology") a structural/causal fact already logged once. New tree `KNOWLEDGE-MAP-DOC`. This reverses the deferral in `MEMORY-ARCHITECTURE-DOC`.
- Vendored the `knowledge-map/` bundle verbatim at the repo root (10 files; `diff -r` byte-identical to the cross-project source). Ran `knowledge-map/install.sh`, which created `docs/knowledge/` (fact-card dir) and generated `KNOWLEDGE_MAP.md` (derived, deterministic; 0 facts initially); `check_knowledge_map.sh` reports the map in sync.
- `README.md`: added a Knowledge Map bullet under "durable memory architecture" + path-map entries (`KNOWLEDGE_MAP.md`, `docs/knowledge/`, `knowledge-map/`).
- `MEMORY_ARCHITECTURE.md` §5: reconciled the earlier "Not adopted in this repository" note to "Adopted" (the KM is now present + gated); added a cross-ref to the completed `MEMORY-ARCHITECTURE-DOC` tree.
- Bundle knobs unchanged from the default (`KM_SCAN_DIRS=docs/knowledge docs/decisions`, `KM_OUTPUT=KNOWLEDGE_MAP.md`) — they already fit linkedspec; no repo-root override needed.
- Validation (no code changed): `perl -c perl/LinkedSpec.pm` OK; phase0 1004 PASS baseline holds. Enforcement wiring lands in `.3`.

## 2026-06-04 — Verify memory-architecture end-to-end + close tree (MEMORY-ARCHITECTURE-DOC.5)

- Ran the full canonical gate `bash tools/run_ci_local.sh` → **exit 0**, in the intended order: the memory-architecture self-check **first** (all six invariants hold) → syntax checks (`perl/LinkedSpec.pm` + `t/phase0_regression.t` OK) → phase0 regression **`Files=1, Tests=1004, Result: PASS`** → `[ci] local CI gate passed`.
- Confirms the §9 enforcement is live inside the canonical gate and the regression baseline is green with the memory architecture in place.
- Synced the owning task tree and live docs; moved `MEMORY-ARCHITECTURE-DOC` from Active to Completed in `docs/TASK_TREE.md` (no active trees remain).
- **MEMORY-ARCHITECTURE-DOC tree COMPLETE (5 leaves).** LinkedSpec now has durable, harness-agnostic agent memory: layer A (`MEMORY.md` resume pointer) · layer B (`docs/tasks/` task-trees) · layer C (`docs/decisions/`) · layer D (git), reachable from `AGENTS.md`/`README.md`/`MEMORY_ARCHITECTURE.md` and enforced by E1–E4.

## 2026-06-04 — Install memory-architecture enforcement kit (E1–E4) (MEMORY-ARCHITECTURE-DOC.4)

- Installed the `MEMORY_ARCHITECTURE.md` §9 enforcement so non-compliance fails fast and visibly:
  - **E2** — `scripts/check_memory_architecture.sh` (single source of truth for the invariants; knobs: line cap 60, `docs/tasks`, `docs/decisions`, bootstrap `AGENTS.md`+`CLAUDE.md`). Passes on the compliant tree.
  - **E3** — `.githooks/pre-commit` (execs the self-check) and `.githooks/commit-msg` (subject must carry a task-tree leaf id in the subject or first body line, OR a maintenance prefix like `Docs:`); both `chmod +x`; activated via `git config core.hooksPath .githooks`.
  - **E1** — bootstrap pointers `AGENTS.md` (canonical) + `CLAUDE.md` / `.cursorrules` / `.github/copilot-instructions.md` (one-line mirrors), all routing to `README.md` + `MEMORY_ARCHITECTURE.md` (no Knowledge Map references, since that layer is not adopted here).
  - **E4** — wired the self-check as the **first** gate in `tools/run_ci_local.sh` (before syntax/regression) and added `require_tracked_file` for it + `MEMORY_ARCHITECTURE.md`; `ci.yml` already delegates to that script.
- **Proved the gates bite:** self-check exits nonzero under `MEMORY_POINTER_LINE_CAP=10` (MEMORY.md is 25 lines); commit-msg rejects `"wip random stuff"` / `"random lowercase subject with no id"` and accepts unit-id subjects, `"Docs: …"`, `"chore(ci): …"`, `"Merge …"`, and a body-line unit id. Fixed a POSIX-ERE bug (bash `=~` has no `\b`) in the commit-msg pattern.
- This is the first commit to pass through the now-active pre-commit + commit-msg hooks.
- Validation (no code changed): all four shell files `bash -n` clean; self-check exit 0 on the tree; `perl -c perl/LinkedSpec.pm` OK; phase0 1004 PASS baseline holds (full gate run in `.5`).

## 2026-06-04 — Demote MEMORY.md to bounded resume pointer + reconcile COMMIT.md (MEMORY-ARCHITECTURE-DOC.3)

- `MEMORY.md` was a 5204-line cumulative log (memory anti-pattern #1). Rewrote it to the `MEMORY_ARCHITECTURE.md` §6 resume-pointer template — now **25 lines**: How-to-resume + an overwrite-only Current-state block (latest commit, active task-tree frontier leaf, single next action, regression baseline, in-flight, blockers).
- The prior 5204 lines are **not deleted** — `git show HEAD:MEMORY.md` confirms they remain in git history (layer D). We simply stop carrying them forward.
- Reconciled the doctrine conflict in `COMMIT.md`: the old rule "`MEMORY.md` ... cumulative and not reset" is replaced. The `### 4) MEMORY.md` section now defines it as the layer-A resume pointer (overwrite-only, ≤ ~60-line cap enforced by `scripts/check_memory_architecture.sh`), and workflow step 2 now says **overwrite** the MEMORY.md current-state block (not append) and route durable cross-cutting facts to `docs/decisions/`.
- `README.md` ramp-up item 9 reframed to match (bounded resume pointer, not cumulative state).
- Validation (no code changed): `wc -l MEMORY.md` = 25 (≤ cap 60); `perl -c perl/LinkedSpec.pm` OK; phase0 1004 PASS baseline holds.

## 2026-06-04 — Add docs/decisions/ layer C + 4 seed decision records (MEMORY-ARCHITECTURE-DOC.2)

- Created `docs/decisions/` (memory layer C) with `INDEX.md` and seeded it with four dated ADR-style records (`Context → Decision → Consequences → Links`), each pointing at the authoritative tracked docs rather than duplicating them:
  - `0001` — task-tree ownership before any change + strict `COMMIT.md` workflow + zero-drift doctrine. Migrated out of harness-home-directory memory (`~/.claude/.../memory/`), which a different tool can't see, into the tracked repo so it survives a harness/model switch.
  - `0002` — the all-target ActionIR-ready phase-0 invariant: every shipped `.spec` compiles at `language_agnostic_ready_ratio == 1.0000` with zero blocked/compatibility-surface rules.
  - `0003` — `.spec` authoring is permanently raw-Perl-free; raw Perl is migration debt.
  - `0004` — hosted GitHub Actions CI is disabled; `tools/run_ci_local.sh` is the source of truth.
- INDEX rows match the four record files exactly.
- Validation (no code changed): `perl -c perl/LinkedSpec.pm` OK; phase0 1004 PASS baseline holds.

## 2026-06-04 — Add MEMORY_ARCHITECTURE.md standard + README/bootstrap pointers (MEMORY-ARCHITECTURE-DOC.1)

- Adopting the portable, harness-agnostic durable-memory standard in this repo (new tree `MEMORY-ARCHITECTURE-DOC`, mirroring the sibling specforge adoption). This leaf lands layer-defining doc + discovery.
- Added `MEMORY_ARCHITECTURE.md` at the repo root — copied byte-identical (419 lines) from the cross-project standard, with one added note marking the optional composed "Knowledge Map" layer (§5) as **not adopted** in this repo (avoids a dangling reference; matches the tree's non-goals).
- `README.md`: new "durable memory architecture" + `docs/decisions/` bullet under Documentation Layers; `MEMORY.md` reframed as the bounded overwrite-only layer-A resume pointer; ramp-up map item 1 now routes to `MEMORY_ARCHITECTURE.md`; top-level docs path map lists `MEMORY_ARCHITECTURE.md`, `docs/decisions/`, and the `AGENTS.md` bootstrap mirrors.
- `SESSION_BOOTSTRAP.md`: now reads `MEMORY_ARCHITECTURE.md` first and references `docs/decisions/`.
- Validation (no code changed): `perl -c perl/LinkedSpec.pm` OK; phase0 1004 PASS baseline holds.

## 2026-06-04 — Sync ROADMAP.md status tracker with ROADMAP_V2/reality (DOC-CODEBASE-ALIGNMENT.5)

- `ROADMAP.md`'s live-status tracker table was frozen at an early state: Phase 1 and 1A `mostly done`, Phases 2–6 `in progress`, Phase 7 `not started`, Backbone refactor track + Item 3 `mostly done`, Method-like track + Plugin track `in progress` — all contradicting `ROADMAP_V2.md` and reality (every numbered phase `done`).
- Rewrote 13 stale tracker rows (line-number-keyed Perl splice, single-line→single-line so the 1248-line count stayed stable) to match `ROADMAP_V2.md`: Phases 1/1A/2/3/4/5/6/7 → `done`, Backbone refactor track + Item 3 → `done`, Method-like track → `mostly done`, Plugin track → `done`; Overall stays `in progress` with a refreshed focus note. Each "Remaining focus" cell was trimmed to a concise, task-tree-referenced completion note.
- Annotated the Phase 1A planning section (`perl/LinkedSpec/ActionRewriter.pm` bullet) that the module was extracted then deleted in Phase 1, covering the historical `RuleIR/ActionRewriter/Compiler` rollout-order mention too. All remaining `ActionRewriter` mentions in `ROADMAP.md` are now historical (deletion record, "Landed follow-up" changelog, or annotated plan).
- Cross-check: all 15 shared phase/track statuses now match between `ROADMAP.md` and `ROADMAP_V2.md`.
- **DOC-CODEBASE-ALIGNMENT tree complete (5 leaves).** No active trees remain.
- Validation (no code changed): `perl -c perl/LinkedSpec.pm` OK; phase0 1004 PASS baseline holds.

## 2026-06-04 — Reconcile ROADMAP_V2.md Phase 1A row: ActionRewriter historical (DOC-CODEBASE-ALIGNMENT.4)

- `ROADMAP_V2.md`'s Phase 1A row (line 59) still listed `ActionRewriter.pm` among the modules that "now share" the `LinkedSpec::OwnerDispatch` seam and said `ActionRewriter` "now also routes its `EmitContext` compatibility delegation directly" — presenting a module the same file's Phase 1 row (line 58) already records as deleted.
- Two surgical edits reframe both mentions as historical ("the then-present thin shim `ActionRewriter.pm` was later deleted in Phase 1" / "before being deleted in Phase 1"), keeping the OwnerDispatch-consolidation narrative intact. The Phase 1 deletion record is untouched.
- While starting this leaf, found that `ROADMAP.md`'s status-tracker table is frozen at an early state (Phases 1, 1A, 2, 3, 4, 5, 6, 7, and Backbone all stale vs `ROADMAP_V2.md`/reality). That broader drift was split into new leaf `DOC-CODEBASE-ALIGNMENT.5`.
- Validation (no code changed): `perl -c perl/LinkedSpec.pm` OK; phase0 1004 PASS baseline holds.

## 2026-06-04 — Scrub deleted-ActionRewriter live claims from USER_GUIDE.md (DOC-CODEBASE-ALIGNMENT.3)

- `USER_GUIDE.md` (the user-facing working reference) still presented `ActionRewriter.pm` as a live module "retained as compatibility wrapper surface for direct legacy callers," with current `$@`-preservation and lazy-loading behavior. The module was deleted in Phase 1 (`PHASE1-PARSER-CORE-ISOLATION.2`).
- Reworked all 7 references across two clusters (load-time-cleanup notes ~260–263 and compile-pipeline owner-path notes ~1209–1219): `ActionRewriter` is now described as a forwarding shim deleted in Phase 1, and the focused helper-rewrite entrypoint is identified as `LinkedSpec::RuleIR::EmitContext::rewrite_action_code_for_compat(...)` (façade: `LinkedSpec::call_spec_handler_subst(...)`). Dropped two now-misleading "ActionRewriter-facing default callback map" labels and clarified that `LinkedSpec::Deps` was removed entirely.
- Verified `docs/linkedspec-book/` was already free of `ActionRewriter` references (no edits needed). Re-grep confirms every remaining `USER_GUIDE.md` mention is framed "deleted in Phase 1."
- Validation (no code changed): `perl -c perl/LinkedSpec.pm` OK; phase0 1004 PASS baseline holds.

## 2026-06-04 — Refresh ARCHITECTURE_STATE.md: ActionRewriter.pm removed (DOC-CODEBASE-ALIGNMENT.2)

- `ARCHITECTURE_STATE.md` still described the deleted `perl/LinkedSpec/ActionRewriter.pm` module as a live owner-dispatch participant. That module was deleted in Phase 1 (`PHASE1-PARSER-CORE-ISOLATION.2`, commit `4f8e0b6`); `perl/` has zero references to it.
- Updated the Status block (`Last refreshed` → 2026-06-04 plus an explicit refresh note), rewrote the bullet that called the `ActionRewriter` compatibility surface "thinner now" to state it was deleted entirely, and removed `ActionRewriter.pm` from the "modules that now share the OwnerDispatch seam" list. The focused helper-rewrite compatibility entrypoint now lives solely in `LinkedSpec::RuleIR::EmitContext::rewrite_action_code_for_compat(...)`, reachable via `LinkedSpec::call_spec_handler_subst(...)`.
- All three remaining `ActionRewriter` mentions in the file are now framed as removed/historical.
- Validation (no code changed): `perl -c perl/LinkedSpec.pm` OK; phase0 1004 PASS baseline from DOC-CODEBASE-ALIGNMENT.1 still holds.

## 2026-06-04 — Reconcile task-tree index with task-file statuses (DOC-CODEBASE-ALIGNMENT.1)

- Session-bootstrap drift audit found `docs/TASK_TREE.md` out of sync with the actual `docs/tasks/*.md` files. New tree `DOC-CODEBASE-ALIGNMENT` created to own the alignment work.
- `docs/TASK_TREE.md`: Active Task Trees now lists only `DOC-CODEBASE-ALIGNMENT` (frontier `.1`); the stale `PHASE7-SELF-HOSTED-SPEC` "active" row (its tree file is `done`) was removed. Completed Task Trees gained four trees that were absent from the index entirely or mislabeled: `PHASE7-SELF-HOSTED-SPEC`, `PHASE1-PARSER-CORE-ISOLATION`, `METHOD-LIKE-DSL-MIGRATION`, `BOOK-DOCUMENTATION-SYNC`.
- Corrected a sub-drift: `PHASE3-EXECUTION-SEMANTICS`, `PHASE4-CAPTURE-MARK-API`, and `PHASE5-RUNTIME-DIAGNOSTICS` carried `Status: active` in their metadata while their top task-tree nodes already read `completed`; flipped the metadata to `completed` so each file is internally consistent.
- Cross-check: all 13 task-tree files now appear in the index under a table matching their own `Status` field; the only index entry without a file is the intentionally `proposed` `PLUGIN-ACTION-MIGRATION`.
- Validation (no code changed): `perl -c perl/LinkedSpec.pm` OK; `perl -c -Iperl t/phase0_regression.t` OK; `prove -Iperl t/phase0_regression.t` → Files=1, Tests=1004, Result: PASS.

## 2026-05-17 — Survey .spec language surface (PHASE7-SELF-HOSTED-SPEC.1)

- Completed comprehensive .spec language surface inventory. 37 syntax categories across 9 sections: rule label forms, rule modes (11 variants), body elements (12 recognized patterns), lifecycle markers (7), split/capture markers (4), action/helper DSL (~40+ helpers), block structure, and authoring styles.
- Audited: `_parse_rule_label_line`, `_looks_like_supported_rule_paragraph_member_line`, `_looks_like_supported_split_marker_start`, 19 shipped `.spec` files, 30 book chapters, 10 USER_GUIDE files.
- Created follow-on leaves .2–.5: structural grammar (.2), helper-DSL grammar (.3), regression (.4), extension-surface policy (.5).
- Full suite: 1007 PASS (audit-only leaf).

## 2026-05-17 — Evaluate PPlugin/PluginBridge retirement feasibility (PLUGIN-MODERNIZATION.5)

- Evaluated PPlugin.pm (288 lines) and PluginBridge.pm (199 lines) retirement feasibility. Cannot retire yet: 36 .plg files with ~1,200+ actions remain.
- Documented 5-step retirement path: (1) migrate .plg actions to package owners, (2) retire PPlugin, (3) reduce/delete PluginBridge, (4) remove deprecated facade methods, (5) migrate FSMGen::AUTOLOAD.
- PluginRegistry (130 lines) can survive independently as a general-purpose coderef registry.
- PLUGIN-MODERNIZATION tree COMPLETE (5 leaves). Proposed follow-on: `PLUGIN-ACTION-MIGRATION` tree.
- Full suite: 1007 PASS (evaluation-only — no code changes).

## 2026-05-17 — Deprecate all 7 legacy plugin facade methods (PLUGIN-MODERNIZATION.4)

- Marked all 7 legacy plugin methods in LinkedSpec.pm as DEPRECATED with retirement timeline tied to PLUGIN-MODERNIZATION.5 (PPlugin/PluginBridge retirement).
- register_plugin, register_plugins, clear_registered_plugins → PluginRegistry retirement.
- run_plugin, get_plugin, dispatch_plugin_autoload_name, AUTOLOAD → PluginBridge retirement.
- None can be removed yet: FSMGen::AUTOLOAD still depends on dispatch_plugin_autoload_name, tests still verify plugin infrastructure.
- Replaced verbose per-method comment blocks with compact DEPRECATED annotations under a single section header.
- Full suite: 1007 PASS.

## 2026-05-17 — De-scope FSMGen from LinkedSpec::get_plugin (PLUGIN-MODERNIZATION.3)

- Replaced `\&LinkedSpec::get_plugin` default with `sub {}` no-op in FSMGen::getop_plugin_list (FSMGen.pm line 68).
- Internal caller (line 3054) passes no explicit get_plugin but no .fsm files exist in repo to trigger +type=plugin syntax — dead code path.
- Tests always pass explicit get_plugin callback. Updated 2 regression assertions to match new no-op default.
- FSMGen.pm no longer has a hard dependency on LinkedSpec::get_plugin. Full suite: 1007 PASS.

## 2026-05-17 — Docs: codify task-tree-ownership doctrine in book and live docs

- Added "Task-tree ownership requirement" section to book chapter `development/local-ci-and-regression.md`. All code changes must be task-tree tracked or task-tree owned before implementation. Non-negotiable quality gate.
- Updated live docs (DEVELOPMENT_NOTES.md, MEMORY.md, LIVE_ACHIEVEMENT_STATUS.md) with new doctrine.

## 2026-05-17 — Remove dead .plg files (hutils.plg, quick_sdf_hack.plg)

- Removed plugin/hutils.plg (21 lines): all thin passthrough wrappers to HUtils:: methods. Zero external references — all callers use HUtils:: directly.
- Removed plugin/quick_sdf_hack.plg (31 lines): dead qsdf_hack action with zero external callers.
- 36 .plg files remain. Full suite: 1007 PASS.

## 2026-05-17 — Audit: inventory remaining plugin surface for PLUGIN-MODERNIZATION

- Audited all plugin-related surfaces: 38 .plg files, PPlugin.pm (288 lines), PluginBridge.pm (199 lines), PluginRegistry.pm (130 lines), LinkedSpec.pm facade (7 legacy methods), external callers, regression tests.
- Classified each .plg file: extracted (helpers moved, visible action remains), spec consumer (uses get_parser, not plugin), legacy action file.
- FSMGen.pm is the only external caller of get_plugin (optional default).
- Created follow-on leaves .2–.5: remove extracted wrappers, de-scope FSMGen, reduce public facade, evaluate PPlugin/PluginBridge retirement.

## 2026-05-17 — Audit: verify ActionIR owner surfaces clean (Backbone Item 3 close-out)

- Audited all 12 ActionIR owners + ScannerCore/StatementSplitCore/CanonicalEventsCore + EmitContext for OwnerDispatch hygiene and stale validators.
- All 12 owners use `OwnerDispatch` uniformly via `build_dep_map` in `default_deps_for_package`.
- Zero old-style top-level `_require_dep(...)` validator wrappers remain — all die messages are inline validation inside the actual work functions (the intended cleaned state).
- Scanner.pm (54 lines) is the cleanest — `require_pkg_cb` / `call_preserving_err` with zero inline dep checks.
- Backbone Item 3 ActionIR owner-contract cleanup is complete. BACKBONE-ACTION-IR-LOWERING tree done (1 leaf).

## 2026-05-17 — Docs: backfill per-spec walkthroughs for tablegrep, portmap, pplugin

- Created 3 new per-spec walkthrough chapters in the book's specs-and-corpora section:
  - tablegrep-spec-walkthrough.md: grep-like expression parser (5 rules, descriptor ratio 1.0000). Covers recursive grouping, operator detection in lifecycle hooks, I.return shorthand.
  - portmap-spec-walkthrough.md: VHDL/Verilog port-map parser (3 rules, descriptor ratio 1.0000). Covers single-regex multi-classification, tags as AST discriminators, flat arrays.
  - pplugin-spec-walkthrough.md: .plg plugin file parser (6 rules, descriptor ratio below 1.0000 due to eval). Covers recursive bracket-matching with string-literal awareness, named capture, next(), LX accumulator pattern.
- Updated SUMMARY.md with 3 new chapters under Shipped Material.
- Updated shipped-specs-and-corpora.md reading order to include walkthrough links for all 3 new chapters.
- PHASE6-DOCUMENTATION tree COMPLETE (8 leaves). All documentation gaps from .1 inventory now closed.

## 2026-05-17 — Docs: expand ActionIR lowering pipeline documentation

- Expanded actionir-lowering-mental-model.md (107→164 lines): added "The lowering pipeline" section covering all 6 pipeline stages (Scanner, StatementSplit, CanonicalEvents, RewritePipeline, lowering owners, Contracts catalog) with an 8-family contracts table.
- Expanded action-model-and-helper-surface.md (77→183 lines): expanded each helper family with purpose descriptions and representative helpers, added "How helpers reach emitted code" section tracing the full pipeline flow.
- Combined: 347 lines (above 300 threshold). ActionIR lowering pipeline now substantively documented.

## 2026-05-17 — Docs: expand overview chapters

- Expanded what-is-linkedspec.md (29→69 lines): added minimal .spec example, "where LinkedSpec fits" section, and detailed output description.
- Expanded design-rationale.md (50→80 lines): added 5th bet (state-first compiler), expanded each bet with concrete rationale.
- Expanded project-status.md (19→52 lines): added completed phases (1-5), active work (Phase 6), planned Phase 7, backbone items status, and project health summary.
- Expanded documentation-layers.md (55→74 lines): added reading-order guidance for new users and contributors.
- Total overview section: 153→275 lines.

## 2026-05-17 — Docs: bridge book and USER_GUIDE cross-linking

- Added "Deeper reference" cross-links to 5 book chapters (action-and-lifecycle-placement, capture-marks, source-boundary-helper-ref, declaration-helper-ref, actionir-lowering-mental-model) pointing to relevant USER_GUIDE files.
- Added book link to USER_GUIDE.md with reading-order guidance (book first for new users, USER_GUIDE files for deeper implementation detail).
- Combined with existing action-model-and-helper-surface links, 6 book chapters now cross-reference USER_GUIDE files.

## 2026-05-17 — Docs: complete public API documentation

- Created 2 new book chapters: trace-api.md (7 trace entry points, 6 verbosity levels, trace state variables, scope-chain diagram) and plugin-registry.md (3 registry methods, 4 legacy transition methods with status note).
- Updated get-and-get-parser.md with build_compiled_rule_table and call_spec_handler_subst documentation.
- Updated SUMMARY.md to add both new chapters. Book's Public API section now documents all 4 facade bands.

## 2026-05-17 — Docs: document Validation.pm DSL validation surface

- Expanded ARCHITECTURE_STATE.md Validation section from 4 bullets to 30-line entry covering all 5 public entry points (validate_spec_content, validate_dsl_syntax, validate_dependency_regex_references, validate_compiled_descriptor_state, validate_rule_definition), error reporting path, context helpers, rule-label parser, edge scanner, strict_syntax mode, and debugging guidance.
- Expanded book's pipeline-overview.md Stage 2 from 4-line paragraph to 16-line structured description covering the three validation layers (envelope, paragraph-level, cross-reference) with error payload routing.

## 2026-05-17 — Docs: document LinkedRE.pm regex composition utility

- Added 11-line LinkedRE section to ARCHITECTURE_STATE.md "What the Main Owners Do" covering or/oredRE API, position-tracking, seek vs consume modes, match-info return shape, three consumers (Compiler, SpecEntry, BootstrapSpec::Core), OwnerDispatch loading, and re 'eval' pragma.
- Added 3-line explanatory note to book's generated-handlers-and-dispatch.md clarifying what LinkedRE is and how it works in context.

## 2026-05-17 — Docs: inventory Phase 6 documentation surface

- Audited 30 mdBook chapters, 10 USER_GUIDE files (14,611 lines), 6 live docs, ARCHITECTURE_STATE.md, and README.md.
- All 30 book chapters are substantive (zero stubs); USER_GUIDE files provide 5x deeper ActionIR lowering detail than book DSL chapters.
- Found 7 doc gaps: LinkedRE.pm zero docs, Validation.pm thin (1 paragraph for 1,368 lines), public API incomplete (2/4 facade bands), book/USER_GUIDE silos (1 cross-link), overview chapters thin (153 lines), ActionIR lowering thin (171 lines), per-spec walkthroughs incomplete (2/14+).
- Created 7 follow-on leaves (.2–.8) ordered by impact-to-effort ratio.

## 2026-05-17 — Fix: route handler compile warnings through trace instead of stderr

- Replaced `warn $compile_warning` in SpecEntry.pm line 740 with `_trace_decision("rule_handler_compile:$label", 1, "compiled with warnings: $compile_warning", DUMP_NONE)`.
- Successful handler compilations with warnings (e.g., "use of uninitialized value" in generated handler code) no longer leak to stderr.
- Compile warnings are captured in the trace decision output at DUMP_NONE level.
- Handler compile failures continue through the structured `last_error` channel with warnings in the detail.
- PHASE5-RUNTIME-DIAGNOSTICS tree complete (2 leaves). Phase 5 `done` in ROADMAP_V2.md.

## 2026-05-17 — Docs: inventory Phase 5 runtime diagnostics surface

- Audited 5 structured error families (compiler_pipeline, parser_factory, runtime_owner, runtime_handler, runtime_parser) across 30+ call sites.
- Verified eval surface: 1 handler compile eval (minimum), 1 execution eval trap, zero in BootstrapSpec.
- Verified trace bridging: parser_invoke → rule_handler scope chain intact.
- Verified handler caching: eager compile, coderef reuse, no per-invocation eval.
- Found 1 stderr leak: SpecEntry.pm line 740 (`warn $compile_warning` on successful handler compilation).
- Created follow-on leaf .2.

## 2026-05-17 — Docs: finalize Phase 4 capture/mark API

- Verified all 7 compat alias pairs already documented as legacy in source-boundary-helper-reference.md.
- Verified all 14 mark helpers have documented entries (lines 156-169).
- Updated ROADMAP_V2.md Phase 4 status from `in progress` to `done`.
- PHASE4-CAPTURE-MARK-API tree complete (4 leaves).

## 2026-05-17 — Docs: inventory Phase 4 capture/mark API surface

- Audited 163 Contracts.pm entries (~100+ capture/mark/position helpers) across 6 families.
- Verified zero legacy usage in all 19 shipped `.spec` files (no `$CAPTURE`, no raw `pos()`, no `capture_slice`, no `@mark`).
- Reviewed 2 book chapters (594 lines): capture-marks-and-source-locations.md, source-boundary-helper-reference.md.
- Identified 12 compatibility alias pairs; 14 named mark helpers implemented.
- Two minor documentation gaps found: compat alias table completeness, mark-helper reference completeness.
- Created follow-on leaves .2, .3, .4.

## 2026-05-17 — Docs: finalize Phase 3 execution semantics

- Verified BACKTRACK+parse_mode interaction coverage already provided by .2 and cross-referenced in .3.
- Updated ROADMAP_V2.md Phase 3 status from `in progress` to `done`.
- PHASE3-EXECUTION-SEMANTICS tree complete (4 leaves).

## 2026-05-17 — Docs: add forward-moving non-backtracking model statement

- Added "Forward-moving, non-backtracking model" subsection (18 lines) to rule-modes-and-parse-modes.md.
- States that the LinkedSpec parser engine is forward-moving: regex matches advance or stay put, no search tree, no partial-match unwind, no systemic backtracking.
- BACKTRACK/IBACKTRACK are the sole explicit cursor-rewind mechanism and are local pos() manipulations.
- Includes cross-reference to source-boundary-helper-reference.md for BACKTRACK detail.

## 2026-05-17 — Docs: document BACKTRACK/IBACKTRACK local cursor-rewind contract

- Added "BACKTRACK and IBACKTRACK: local cursor rewind" subsection (22 lines) to source-boundary-helper-reference.md.
- Covers: concrete pos() assignments (BACKTRACK = `$LSPOS - length $LMATCH`, IBACKTRACK = `$IPOS - length $IMATCH`), parent-match vs inner-match rewind distinction, local cursor rewind vs systemic backtracking (LinkedSpec does not implement search-tree rollback), parse_mode interaction after rewind, label-argument compatibility note, and structural-alternative guidance.

## 2026-05-17 — Docs: inventory Phase 3 execution semantics surface

- Audited 8 implementation components (LinkedRE.pm, Compiler.pm, SpecEntry.pm, CompilerState.pm, Runtime.pm, ActionIR/Contracts.pm, ActionIR/Scanner/LegacyRules.pm, ActionIR/CanonicalEvents/Core.pm).
- Reviewed 5 book chapters covering seek/consume semantics, rule-mode orthogonality, public API shape, and BACKTRACK helpers.
- Analyzed test coverage: 4 dedicated parse-mode subtests (~30 assertions) plus ~40 consume-mode subtests.
- Found 3 documentation gaps: BACKTRACK/IBACKTRACK local-rewind contract not explicitly documented, no non-backtracking forward-moving model statement, BACKTRACK+parse_mode interaction undocumented.
- Created follow-on leaves .2, .3, .4 in the task tree.

- Validation: `prove -Iperl t/phase0_regression.t` → Files=1, Tests=1007, PASS.

## 2026-05-16 — Docs: finalize Phase 1A and Phase 2 status in ROADMAP_V2.md

- Updated ROADMAP_V2.md: Phase 1A `mostly done` → `done`, Phase 2 `in progress` → `done`, both with 2026-05-16 completion dates.
- Moved PHASE1A-CLOSE-OUT tree from active to completed in TASK_TREE.md.

## 2026-05-16 — Docs: inventory Phase 1A modularization close-out status

- Audited LinkedSpec.pm (286 lines, 20 subs) and all 18 extracted modules (~6,900 lines total).
- Verified uniform OwnerDispatch usage across all modules through 5 shared entry points.
- Confirmed no stale monolith-era `use re 'eval'` in facade, no dead pass-through wrappers, no circular coupling, no debt markers.
- Phase 1A modularization is complete — only ROADMAP_V2.md status flip remains.

- Validation: `prove -Iperl t/phase0_regression.t` → Files=1, Tests=1007, PASS.

## 2026-05-16 — Feat: add strict_syntax option to promote reference warnings to errors

- Added `strict_syntax` option to `validate_dsl_syntax` in `perl/LinkedSpec/Validation.pm`. When `strict_syntax => 1`, undefined rule references and unused rules are promoted from `_trace_log_output` warnings to `_report_dsl_validation_failure` hard errors.
- Default is off (backwards compatible) — shipped specs pass with default lax mode. All 19 shipped specs fail strict mode as expected (every top rule is unreferenced by convention, being the entry point).
- Added 3 regression subtests to `t/phase0_regression.t`: strict rejects undefined refs, strict rejects unused rules, strict accepts valid bidirectional spec.

- Validation: `prove -Iperl t/phase0_regression.t` → Files=1, Tests=1007, PASS.

## 2026-05-16 — Tests: expand extra-colon rule-label rejection regression coverage

- Expanded `validation_rejects_extra_colon_rule_labels` subtest from 1 case to 14 edge cases covering triple/quadruple colons, space variations, mode-suffix+colon combinations, bounded-OR+colon, and tab separators.
- Extra-colon rejection was already functional via `_parse_rule_label_line`'s `invalid_mode` flag; this commit adds comprehensive regression coverage.

- Validation: `prove -Iperl t/phase0_regression.t` → Files=1, Tests=1004, PASS.

## 2026-05-16 — Fix: reject rule-label lines inside open blocks in validate_dsl_syntax

- Added inside-block rule-label detection in `perl/LinkedSpec/Validation.pm` (after line 610): when `edge_scan_depth > 0`, calls `_parse_rule_label_line` on the line; if it matches, reports "Rule definition not allowed inside open block" with the owning rule label.
- Updated 2 existing tests to expect rejection instead of acceptance for rule-label lines inside open blocks.
- Added 5 new regression subtests to `t/phase0_regression.t`: bare rule labels inside blocks, top-rule labels inside blocks, mode-suffix labels (AND+/OR+/OR{2,4}) inside blocks, non-rule-label content acceptance inside blocks, and rule labels inside deeply nested blocks.
- Verified zero shipped specs contain rule-label-like lines inside open blocks.

- Validation: `prove -Iperl t/phase0_regression.t` → Files=1, Tests=1004, PASS.

## 2026-05-16 — Tests: regression-lock full fluent-continuation surface recognition

- Added 4 regression subtests (20 assertions) to `t/phase0_regression.t` covering all lifecycle-marker fluent chains, deeply nested 5+ call chains, quoted args with nested function calls in fluent chains, and empty-args fluent chains.
- Verified all 7 lifecycle markers (I, LS, LE, E, EX, IT, LX) with `.if(scalar(on)) { ... }` fluent chains pass both `validate_spec_content` and `validate_dsl_syntax`.
- Full regression suite: Files=1, Tests=999, PASS.

- Validation: `prove -Iperl t/phase0_regression.t`

## 2026-05-16 — Docs: add task-tree tracking workflow

- Added `docs/TASK_TREE_README.md` (portable setup guide), `docs/TASK_TREE.md` (local workflow spec and active-tree index), and `docs/tasks/TEMPLATE.md` (copyable tree skeleton).
- Created nine task-tree files covering all active roadmap phases: `PHASE2-DSL-FRONTEND`, `PHASE1A-CLOSE-OUT`, `PHASE3-EXECUTION-SEMANTICS`, `PHASE4-CAPTURE-MARK-API`, `PHASE5-RUNTIME-DIAGNOSTICS`, `PHASE6-DOCUMENTATION`, `PHASE7-SELF-HOSTED-SPEC` (proposed), `BACKBONE-ACTION-IR-LOWERING`, and `PLUGIN-MODERNIZATION`.
- Wired `README.md` (fast ramp-up order), `SESSION_BOOTSTRAP.md` (startup ritual with PNT instruction), `COMMIT.md` (leaf-ID traceability and one-commit-per-leaf rule), and `ROADMAP_V2.md` (active-lane task-tree links).
- Added PostCompact hook in `.claude/settings.json` to re-read live-docs, `docs/TASK_TREE.md`, and mdBook entry points after compaction.

- Validation: all edits are documentation-only; no code changes.

## 2026-05-11 - plugins: broaden .plg bridge-dispatch lock

- renamed the plugin-corpus regression to describe the package-owner destination rather than the older `LinkedSpec::get_plugin(...)` transition step,
- widened the `.plg` source scan so shipped plugin files reject direct `LinkedSpec::get_plugin(...)`, `LinkedSpec::run_plugin(...)`, and `LinkedSpec::dispatch_plugin_autoload_name(...)` calls,
- refreshed plugin modernization docs to describe direct public plugin-bridge dispatch from `.plg` files as compatibility debt.

- Validation:
  - `perl -c -Iperl t/phase0_regression.t`
  - `prove -Iperl t/phase0_regression.t`
  - `mdbook build docs/linkedspec-book`
  - `git diff --check`
  - `bash tools/run_ci_local.sh`

## 2026-05-11 - plugins: lock .plg files off direct get_plugin lookup

- removed the stale commented `LinkedSpec::get_plugin('setup_hold_tmax_tmin')` lookup from `plugin/stan_omap2430c_backend.plg`,
- extended plugin-corpus source coverage so shipped `.plg` files cannot reintroduce direct `LinkedSpec::get_plugin(...)` helper lookup calls,
- refreshed plugin modernization docs to describe package-owner calls as the current repo-owned `.plg` destination.

- Validation:
  - `perl -c -Iperl t/phase0_regression.t`
  - `prove -Iperl t/phase0_regression.t`
  - `mdbook build docs/linkedspec-book`
  - `git diff --check`
  - `bash tools/run_ci_local.sh`

## 2026-05-11 - compiler: remove unused final descriptor projection helper

- removed unused private `Compiler::_build_final_descriptor(...)`,
- kept the active pipeline on `_build_final_descriptor_state(...)` plus direct `CompilerState` projection,
- extended source-lock coverage so the unused legacy descriptor projection helper cannot silently return.

- Validation:
  - `perl -c perl/LinkedSpec/Compiler.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `prove -Iperl t/phase0_regression.t`
  - `mdbook build docs/linkedspec-book`
  - `git diff --check`
  - `bash tools/run_ci_local.sh`

## 2026-05-11 - compiler: finish final descriptor naming cleanup

- renamed active `Compiler.pm` `$final_descr_state` / `$final_descr` lexicals to `$final_descriptor_state` / `$final_descriptor`,
- renamed low-verbosity trace dump banners from `FINAL_DESCR` to `FINAL_DESCRIPTOR`,
- extended source-lock coverage so compressed `final_descr` naming cannot silently return on the active compiler path.

- Validation:
  - `perl -c perl/LinkedSpec/Compiler.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `prove -Iperl t/phase0_regression.t`
  - `mdbook build docs/linkedspec-book`
  - `git diff --check`
  - `bash tools/run_ci_local.sh`

## 2026-05-11 - tests: lock target spec ActionIR readiness

- added repo-wide phase0 coverage that compiles every target `.spec` as a descriptor,
- asserted each target spec reports `language_agnostic_ready_ratio == 1.0000`,
- asserted each target spec has zero language-agnostic blocker rules and zero compatibility-surface rules.

- Validation:
  - `perl -c -Iperl t/phase0_regression.t`
  - `prove -Iperl t/phase0_regression.t`
  - `mdbook build docs/linkedspec-book`
  - `git diff --check`
  - `bash tools/run_ci_local.sh`

## 2026-05-11 - compiler: inline compiled descriptor legacy projection

- removed `LinkedSpec::Compiler::_compiled_descriptor_state_to_legacy_descriptor(...)`,
- routed final descriptor projection directly through `_call_compiler_state('compiled_descriptor_state_to_legacy_descriptor', ...)`,
- updated projection-order regression coverage to trap the `CompilerState` owner seam directly,
- extended source-lock coverage so `Compiler.pm` cannot silently regain the compiled descriptor legacy projection pass-through wrapper.

- Validation:
  - `perl -c -Iperl perl/LinkedSpec/Compiler.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `prove -Iperl t/phase0_regression.t`
  - `mdbook build docs/linkedspec-book`
  - `git diff --check`
  - `bash tools/run_ci_local.sh`

## 2026-05-11 - compiler: inline compiled-spec legacy projection

- removed `LinkedSpec::Compiler::_compiled_spec_state_to_legacy_spec(...)`,
- routed legacy spec-hash projection directly through `_call_compiler_state('compiled_spec_state_to_legacy_spec', ...)`,
- extended source-lock coverage so `Compiler.pm` cannot silently regain the compiled-spec legacy projection pass-through wrapper.

- Validation:
  - `perl -c -Iperl perl/LinkedSpec/Compiler.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `prove -Iperl t/phase0_regression.t`
  - `mdbook build docs/linkedspec-book`
  - `git diff --check`
  - `bash tools/run_ci_local.sh`

## 2026-05-11 - compiler: remove unused compiled descriptor metadata wrapper

- removed unused `LinkedSpec::Compiler::_compiled_descriptor_state_meta(...)`,
- left compiled descriptor metadata reads owned by `LinkedSpec::CompilerState` instead of exposing a compiler-local pass-through,
- extended source-lock coverage so `Compiler.pm` cannot silently regain the descriptor metadata wrapper.

- Validation:
  - `perl -c -Iperl perl/LinkedSpec/Compiler.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `prove -Iperl t/phase0_regression.t`
  - `mdbook build docs/linkedspec-book`
  - `git diff --check`
  - `bash tools/run_ci_local.sh`

## 2026-05-11 - compiler: inline compiled descriptor state predicate

- removed `LinkedSpec::Compiler::_is_compiled_descriptor_state(...)`,
- routed final descriptor state shape checks directly through `_call_compiler_state('is_compiled_descriptor_state', ...)`,
- extended source-lock coverage so `Compiler.pm` cannot silently regain the compiled descriptor state predicate pass-through wrapper.

- Validation:
  - `perl -c -Iperl perl/LinkedSpec/Compiler.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `prove -Iperl t/phase0_regression.t`
  - `mdbook build docs/linkedspec-book`
  - `git diff --check`
  - `bash tools/run_ci_local.sh`

## 2026-05-11 - compiler: inline compiled descriptor state construction

- removed `LinkedSpec::Compiler::_new_compiled_descriptor_state(...)`,
- routed final descriptor state construction directly through `_call_compiler_state('new_compiled_descriptor_state', ...)`,
- extended source-lock coverage so `Compiler.pm` cannot silently regain the compiled descriptor state constructor pass-through wrapper.

- Validation:
  - `perl -c -Iperl perl/LinkedSpec/Compiler.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `prove -Iperl t/phase0_regression.t`
  - `mdbook build docs/linkedspec-book`
  - `git diff --check`
  - `bash tools/run_ci_local.sh`

## 2026-05-11 - compiler: inline dependency-regex state construction

- removed `LinkedSpec::Compiler::_new_compiled_dependency_regex_state(...)`,
- routed dependency-regex state construction directly through `_call_compiler_state('new_compiled_dependency_regex_state', ...)`,
- extended source-lock coverage so `Compiler.pm` cannot silently regain the compiled dependency-regex state constructor pass-through wrapper.

- Validation:
  - `perl -c -Iperl perl/LinkedSpec/Compiler.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `prove -Iperl t/phase0_regression.t`
  - `mdbook build docs/linkedspec-book`
  - `git diff --check`
  - `bash tools/run_ci_local.sh`

## 2026-05-11 - compiler: inline compiled descriptor metadata build

- removed `LinkedSpec::Compiler::_build_compiled_descriptor_meta(...)`,
- routed final-descriptor metadata assembly directly through `_call_compiler_state('build_compiled_descriptor_meta', ...)`,
- extended source-lock coverage so `Compiler.pm` cannot silently regain the compiled-descriptor metadata pass-through wrapper.

- Validation:
  - `perl -c -Iperl perl/LinkedSpec/Compiler.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `prove -Iperl t/phase0_regression.t`
  - `mdbook build docs/linkedspec-book`
  - `git diff --check`
  - `bash tools/run_ci_local.sh`

## 2026-05-11 - compiler: inline compiled-spec record-rule call

- removed `LinkedSpec::Compiler::_record_compiled_spec_rule(...)`,
- routed rule-table compiled-rule recording directly through `_call_compiler_state('record_compiled_spec_rule', ...)`,
- extended source-lock coverage so `Compiler.pm` cannot silently regain the compiled-spec record-rule pass-through wrapper.

- Validation:
  - `perl -c -Iperl perl/LinkedSpec/Compiler.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `prove -Iperl t/phase0_regression.t`
  - `mdbook build docs/linkedspec-book`
  - `git diff --check`
  - `bash tools/run_ci_local.sh`

## 2026-05-10 - compiler: remove unused compiled descriptor rules-by-label wrapper

- removed unused `LinkedSpec::Compiler::_compiled_descriptor_state_rules_by_label(...)`,
- left compiled descriptor rules-by-label access owned by `LinkedSpec::CompilerState` instead of exposing a compiler-local pass-through,
- extended source-lock coverage so `Compiler.pm` cannot silently regain the descriptor rules-by-label wrapper.

- Validation:
  - `perl -c -Iperl perl/LinkedSpec/Compiler.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `prove -Iperl t/phase0_regression.t`
  - `mdbook build docs/linkedspec-book`
  - `git diff --check`
  - `bash tools/run_ci_local.sh`

## 2026-05-10 - compiler: remove unused compiled descriptor dependency-regex by-label wrapper

- removed unused `LinkedSpec::Compiler::_compiled_descriptor_state_dependency_regex_by_label(...)`,
- left compiled descriptor dependency-regex by-label access owned by `LinkedSpec::CompilerState` instead of exposing a compiler-local pass-through,
- extended source-lock coverage so `Compiler.pm` cannot silently regain the descriptor dependency-regex by-label wrapper.

- Validation:
  - `perl -c -Iperl perl/LinkedSpec/Compiler.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `prove -Iperl t/phase0_regression.t`
  - `mdbook build docs/linkedspec-book`
  - `git diff --check`
  - `bash tools/run_ci_local.sh`

## 2026-05-10 - compiler: remove unused compiled descriptor dependency-regex-state wrapper

- removed unused `LinkedSpec::Compiler::_compiled_descriptor_state_dependency_regex_state(...)`,
- left compiled descriptor dependency-regex-state access owned by `LinkedSpec::CompilerState` instead of exposing a compiler-local pass-through,
- extended source-lock coverage so `Compiler.pm` cannot silently regain the descriptor dependency-regex-state wrapper.

- Validation:
  - `perl -c -Iperl perl/LinkedSpec/Compiler.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `prove -Iperl t/phase0_regression.t`
  - `mdbook build docs/linkedspec-book`
  - `git diff --check`
  - `bash tools/run_ci_local.sh`

## 2026-05-10 - compiler: remove unused compiled descriptor spec-state wrapper

- removed unused `LinkedSpec::Compiler::_compiled_descriptor_state_spec_state(...)`,
- left compiled descriptor spec-state access owned by `LinkedSpec::CompilerState` instead of exposing a compiler-local pass-through,
- extended source-lock coverage so `Compiler.pm` cannot silently regain the descriptor spec-state wrapper.

- Validation:
  - `perl -c -Iperl perl/LinkedSpec/Compiler.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `prove -Iperl t/phase0_regression.t`
  - `mdbook build docs/linkedspec-book`
  - `git diff --check`
  - `bash tools/run_ci_local.sh`

## 2026-05-10 - compiler: remove unused compiled dependency-regex map projection wrapper

- removed unused `LinkedSpec::Compiler::_compiled_dependency_regex_state_to_dependency_regex_map(...)`,
- left compiled dependency-regex legacy-map projection owned by `LinkedSpec::CompilerState` instead of exposing a compiler-local pass-through,
- extended source-lock coverage so `Compiler.pm` cannot silently regain the map projection wrapper.

- Validation:
  - `perl -c -Iperl perl/LinkedSpec/Compiler.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `prove -Iperl t/phase0_regression.t`
  - `mdbook build docs/linkedspec-book`
  - `git diff --check`
  - `bash tools/run_ci_local.sh`

## 2026-05-10 - compiler: remove unused compiled dependency-regex by-label wrapper

- removed unused `LinkedSpec::Compiler::_compiled_dependency_regex_state_regex_by_label(...)`,
- left compiled dependency-regex by-label access owned by `LinkedSpec::CompilerState` instead of exposing a compiler-local pass-through,
- extended source-lock coverage so `Compiler.pm` cannot silently regain the by-label wrapper.

- Validation:
  - `perl -c -Iperl perl/LinkedSpec/Compiler.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `prove -Iperl t/phase0_regression.t`
  - `mdbook build docs/linkedspec-book`
  - `git diff --check`
  - `bash tools/run_ci_local.sh`

## 2026-05-10 - compiler: remove unused compiled dependency-regex predicate wrapper

- removed unused `LinkedSpec::Compiler::_is_compiled_dependency_regex_state(...)`,
- left compiled dependency-regex state shape checks owned by `LinkedSpec::CompilerState` instead of exposing a compiler-local predicate pass-through,
- extended source-lock coverage so `Compiler.pm` cannot silently regain the predicate wrapper.

- Validation:
  - `perl -c -Iperl perl/LinkedSpec/Compiler.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `prove -Iperl t/phase0_regression.t`
  - `mdbook build docs/linkedspec-book`
  - `git diff --check`
  - `bash tools/run_ci_local.sh`

## 2026-05-10 - compiler: remove unused compiled-spec metadata wrapper

- removed unused `LinkedSpec::Compiler::_compiled_spec_state_meta(...)`,
- left compiled-spec metadata ownership solely with `LinkedSpec::CompilerState` instead of exposing a compiler-local pass-through,
- extended source-lock coverage so `Compiler.pm` cannot silently regain the metadata wrapper.

- Validation:
  - `perl -c -Iperl perl/LinkedSpec/Compiler.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `prove -Iperl t/phase0_regression.t`
  - `mdbook build docs/linkedspec-book`
  - `git diff --check`
  - `bash tools/run_ci_local.sh`

## 2026-05-10 - compiler: inline compiled-spec redefined-label lookup

- removed `LinkedSpec::Compiler::_compiled_spec_state_redefined_rule_labels(...)`,
- routed compiled-state trace reporting directly through `_call_compiler_state('compiled_spec_state_redefined_rule_labels', ...)`,
- extended shared source-lock coverage so `Compiler.pm` cannot silently regain the redefined-labels pass-through wrapper.

- Validation:
  - `perl -c -Iperl perl/LinkedSpec/Compiler.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `prove -Iperl t/phase0_regression.t`
  - `mdbook build docs/linkedspec-book`
  - `git diff --check`
  - `bash tools/run_ci_local.sh`

## 2026-05-10 - compiler: inline compiled-spec definition-order lookup

- removed `LinkedSpec::Compiler::_compiled_spec_state_definition_order(...)`,
- routed compiled-state trace output directly through `_call_compiler_state('compiled_spec_state_definition_order', ...)`,
- extended shared source-lock coverage so `Compiler.pm` cannot silently regain the definition-order pass-through wrapper.

- Validation:
  - `perl -c -Iperl perl/LinkedSpec/Compiler.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `prove -Iperl t/phase0_regression.t`
  - `mdbook build docs/linkedspec-book`
  - `git diff --check`
  - `bash tools/run_ci_local.sh`

## 2026-05-10 - compiler: inline compiled-spec rule-row iteration

- removed `LinkedSpec::Compiler::_compiled_spec_state_rule_rows(...)`,
- routed dependency-regex map iteration directly through `_call_compiler_state('compiled_spec_state_rule_rows', ...)`,
- extended shared source-lock coverage so `Compiler.pm` cannot silently regain the rule-rows pass-through wrapper.

- Validation:
  - `perl -c -Iperl perl/LinkedSpec/Compiler.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `prove -Iperl t/phase0_regression.t`
  - `mdbook build docs/linkedspec-book`
  - `git diff --check`
  - `bash tools/run_ci_local.sh`

## 2026-05-10 - compiler: remove unused compiled-rule-order wrapper

- removed unused `LinkedSpec::Compiler::_compiled_spec_state_compiled_rule_order(...)`,
- left compiled-rule order access owned by `LinkedSpec::CompilerState` instead of exposing a compiler-local pass-through,
- extended shared source-lock coverage so `Compiler.pm` cannot silently regain the compiled-rule-order wrapper.

- Validation:
  - `perl -c -Iperl perl/LinkedSpec/Compiler.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `prove -Iperl t/phase0_regression.t`
  - `mdbook build docs/linkedspec-book`
  - `git diff --check`
  - `bash tools/run_ci_local.sh`

## 2026-05-10 - compiler: inline compiled-spec rule-info lookup

- removed `LinkedSpec::Compiler::_compiled_spec_state_rule_info(...)`,
- routed dependency-regex referenced-rule metadata lookup directly through `_call_compiler_state('compiled_spec_state_rule_info', ...)`,
- extended shared source-lock coverage so `Compiler.pm` cannot silently regain the rule-info pass-through wrapper.

- Validation:
  - `perl -c -Iperl perl/LinkedSpec/Compiler.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `prove -Iperl t/phase0_regression.t`
  - `mdbook build docs/linkedspec-book`
  - `git diff --check`
  - `bash tools/run_ci_local.sh`

## 2026-05-10 - compiler: inline compiled-spec has-rule checks

- removed `LinkedSpec::Compiler::_compiled_spec_state_has_rule(...)`,
- routed dependency-regex referenced-rule existence checks directly through `_call_compiler_state('compiled_spec_state_has_rule', ...)`,
- extended shared source-lock coverage so `Compiler.pm` cannot silently regain the has-rule pass-through wrapper.

- Validation:
  - `perl -c -Iperl perl/LinkedSpec/Compiler.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `prove -Iperl t/phase0_regression.t`
  - `mdbook build docs/linkedspec-book`
  - `git diff --check`
  - `bash tools/run_ci_local.sh`

## 2026-05-10 - compiler: remove unused compiled-spec rules-by-label wrapper

- removed unused `LinkedSpec::Compiler::_compiled_spec_state_rules_by_label(...)`,
- left compiled-spec rules-by-label access owned by `LinkedSpec::CompilerState` instead of exposing a compiler-local pass-through,
- extended shared source-lock coverage so `Compiler.pm` cannot silently regain the rules-by-label wrapper.

- Validation:
  - `perl -c -Iperl perl/LinkedSpec/Compiler.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `prove -Iperl t/phase0_regression.t`
  - `mdbook build docs/linkedspec-book`
  - `git diff --check`
  - `bash tools/run_ci_local.sh`

## 2026-05-10 - compiler: inline compiled-spec rule count

- removed `LinkedSpec::Compiler::_compiled_spec_state_rule_count(...)`,
- routed rule-count reads directly through `_call_compiler_state('compiled_spec_state_rule_count', ...)` at trace and parser-generation boundaries,
- extended shared source-lock coverage so `Compiler.pm` cannot silently regain the pass-through rule-count wrapper.

- Validation:
  - `perl -c -Iperl perl/LinkedSpec/Compiler.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `prove -Iperl t/phase0_regression.t`
  - `mdbook build docs/linkedspec-book`
  - `git diff --check`
  - `bash tools/run_ci_local.sh`

## 2026-05-10 - compiler: inline compiled-spec state predicate

- removed `LinkedSpec::Compiler::_is_compiled_spec_state(...)`,
- routed compiled-spec state validation directly through `_call_compiler_state('is_compiled_spec_state', ...)` at the compiler pipeline boundary,
- extended shared source-lock coverage so `Compiler.pm` cannot silently regain the pass-through predicate wrapper.

- Validation:
  - `perl -c -Iperl perl/LinkedSpec/Compiler.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `prove -Iperl t/phase0_regression.t`
  - `mdbook build docs/linkedspec-book`
  - `git diff --check`
  - `bash tools/run_ci_local.sh`

## 2026-05-10 - compiler: inline compiled-spec state construction

- removed `LinkedSpec::Compiler::_new_compiled_spec_state(...)`,
- routed compiled-spec state construction directly through `_call_compiler_state('new_compiled_spec_state')` at the rule-table build boundary,
- extended shared source-lock coverage so `Compiler.pm` cannot silently regain the pass-through constructor wrapper.

- Validation:
  - `perl -c -Iperl perl/LinkedSpec/Compiler.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `prove -Iperl t/phase0_regression.t`
  - `mdbook build docs/linkedspec-book`
  - `git diff --check`
  - `bash tools/run_ci_local.sh`

## 2026-05-10 - compiler: inline dependency-regex dependency-re detail

- removed `LinkedSpec::Compiler::_describe_build_dependency_regex_map_dependency_re_result(...)`,
- built invalid referenced dependency regex-list diagnostics directly at the map validation boundary,
- extended shared source-lock coverage so `Compiler.pm` cannot silently regain the one-shot dependency regex-list describer wrapper.

- Validation:
  - `perl -c -Iperl perl/LinkedSpec/Compiler.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `prove -Iperl t/phase0_regression.t`
  - `mdbook build docs/linkedspec-book`
  - `git diff --check`
  - `bash tools/run_ci_local.sh`

## 2026-05-10 - compiler: inline dependency-regex dependency-rule-info detail

- removed `LinkedSpec::Compiler::_describe_build_dependency_regex_map_dependency_rule_info_result(...)`,
- built invalid referenced dependency-rule info diagnostics directly at the map validation boundary,
- extended shared source-lock coverage so `Compiler.pm` cannot silently regain the one-shot dependency-rule-info describer wrapper.

- Validation:
  - `perl -c -Iperl perl/LinkedSpec/Compiler.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `prove -Iperl t/phase0_regression.t`
  - `mdbook build docs/linkedspec-book`
  - `git diff --check`
  - `bash tools/run_ci_local.sh`

## 2026-05-10 - compiler: inline dependency-regex missing-rule detail

- removed `LinkedSpec::Compiler::_describe_build_dependency_regex_map_dependency_rule_missing(...)`,
- built missing dependency-rule diagnostics directly at the map validation boundary,
- extended shared source-lock coverage so `Compiler.pm` cannot silently regain the one-shot missing-rule describer wrapper.

- Validation:
  - `perl -c -Iperl perl/LinkedSpec/Compiler.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `prove -Iperl t/phase0_regression.t`
  - `mdbook build docs/linkedspec-book`
  - `git diff --check`
  - `bash tools/run_ci_local.sh`

## 2026-05-10 - compiler: inline dependency-regex dependency-index detail

- removed `LinkedSpec::Compiler::_describe_build_dependency_regex_map_dependency_index_result(...)`,
- built invalid dependency-index diagnostics directly at the map validation boundary,
- extended shared source-lock coverage so `Compiler.pm` cannot silently regain the one-shot dependency-index describer wrapper.

- Validation:
  - `perl -c -Iperl perl/LinkedSpec/Compiler.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `prove -Iperl t/phase0_regression.t`
  - `mdbook build docs/linkedspec-book`
  - `git diff --check`
  - `bash tools/run_ci_local.sh`

## 2026-05-10 - compiler: inline dependency-regex dependency-label detail

- removed `LinkedSpec::Compiler::_describe_build_dependency_regex_map_dependency_label_result(...)`,
- built invalid dependency-label diagnostics directly at the map validation boundary,
- extended shared source-lock coverage so `Compiler.pm` cannot silently regain the one-shot dependency-label describer wrapper.

- Validation:
  - `perl -c -Iperl perl/LinkedSpec/Compiler.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `prove -Iperl t/phase0_regression.t`
  - `mdbook build docs/linkedspec-book`
  - `git diff --check`
  - `bash tools/run_ci_local.sh`

## 2026-05-10 - compiler: inline dependency-regex dependency-ref detail

- removed `LinkedSpec::Compiler::_describe_build_dependency_regex_map_dependency_ref_result(...)`,
- built invalid dependency-ref diagnostics directly at the map validation boundary,
- extended shared source-lock coverage so `Compiler.pm` cannot silently regain the one-shot dependency-ref describer wrapper.

- Validation:
  - `perl -c -Iperl perl/LinkedSpec/Compiler.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `prove -Iperl t/phase0_regression.t`
  - `mdbook build docs/linkedspec-book`
  - `git diff --check`
  - `bash tools/run_ci_local.sh`

## 2026-05-10 - compiler: inline dependency-regex dependency_refs detail

- removed `LinkedSpec::Compiler::_describe_build_dependency_regex_map_rule_dependency_refs_result(...)`,
- built invalid dependency-regex `dependency_refs` diagnostics directly at the map validation boundary,
- extended shared source-lock coverage so `Compiler.pm` cannot silently regain the one-shot `dependency_refs` describer wrapper.

- Validation:
  - `perl -c -Iperl perl/LinkedSpec/Compiler.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `prove -Iperl t/phase0_regression.t`
  - `mdbook build docs/linkedspec-book`
  - `git diff --check`
  - `bash tools/run_ci_local.sh`

## 2026-05-10 - compiler: inline dependency-regex rule-info detail

- removed `LinkedSpec::Compiler::_describe_build_dependency_regex_map_rule_info_result(...)`,
- built invalid dependency-regex rule-info diagnostics directly at the map validation boundary,
- extended shared source-lock coverage so `Compiler.pm` cannot silently regain the one-shot rule-info describer wrapper.

- Validation:
  - `perl -c -Iperl perl/LinkedSpec/Compiler.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `prove -Iperl t/phase0_regression.t`
  - `mdbook build docs/linkedspec-book`
  - `git diff --check`
  - `bash tools/run_ci_local.sh`

## 2026-05-10 - compiler: inline dependency-regex map spec detail

