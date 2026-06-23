# SPEC-FORMAT-TERSE: Evolve the .spec DSL toward a terser, fully-composable format

## Metadata

- Tree ID: `SPEC-FORMAT-TERSE`
- Status: `active` (activated 2026-06-18 by user; ratified in ADR `0007`)
- Roadmap lane: `Overall roadmap — .spec language evolution (terse format)`
- Created: `2026-06-16`
- Last updated: `2026-06-24` (**`.1.1.1` DONE** — Perl auto-existing working variables landed:
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
   during migration.
3. Update the mdBook (the behavioral spec) and add regression coverage in `t/phase0_regression.t`.
4. Run the full gate; commit per `COMMIT.md`.

## Task Tree

- ID: `SPEC-FORMAT-TERSE`
  Status: `active`
  Goal: Evolve the `.spec` DSL toward a terser, fully-composable format (brainstorm Rounds 1–3 + resume 4+)
  Children: `.0` (done), `.1`, `.2`, `.3`, `.4`

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
  Commit: `SPEC-FORMAT-TERSE.0` (see Commit Log)

- ID: `SPEC-FORMAT-TERSE.1`
  Status: `proposed`
  Goal: Round 1 — variables, types, mutation, functions
  Children: `.1.1`, `.1.2`, `.1.3`, `.1.4`, `.1.5`, `.1.6`

- ID: `SPEC-FORMAT-TERSE.1.1`
  Status: `active` (`.1.1.1` Perl reference **done** 2026-06-24; `.1.1.2` Rust lockstep parity
    `pending` — container stays active until the parity child closes. Split 2026-06-23 — too broad
    for one signoff slice: Perl reference engine change + lockstep Rust parity are separable.)
  Goal: Auto-existing variables — remove the need for `declare(...)`; a working variable exists on
    first use within a rule scope (declare stays as a deprecated, still-working alias)
  Children: `.1.1.1` (Perl reference), `.1.1.2` (Rust lockstep parity)

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
  Commit: `SPEC-FORMAT-TERSE.1.1.1` (see Commit Log)

- ID: `SPEC-FORMAT-TERSE.1.1.2`
  Status: `pending`
  Goal: Rust lockstep parity — the Rust runtime auto-supplies the same per-invocation working-variable
    binding so a `.spec` using auto-existing variables compiles/runs identically on the Rust backend
    (cross-variant-output-parity; ADR 0006 lockstep obligation for the `.1.1.1` reference change).
  Acceptance: the Rust variant reproduces `.1.1.1`'s behavior on the same minimal specs (auto-exist works;
    declare-form unchanged); Rust test suite green; cross-check/oracle parity holds for any non-recursive
    auto-exist spec. (If the Rust runtime's working-variable model blocks this independently of the known
    recursive-grammar `RUST-PARITY` gap, record the blocker; otherwise implement.) Assess blocked-vs-doable
    when reached — the `.1.1.1` change is "landed against the universal contract" only once this closes.
  Verification: `pending`
  Commit: `pending`

- ID: `SPEC-FORMAT-TERSE.1.2`
  Status: `pending`
  Goal: Remove container wrappers + add type inference
  Acceptance: `scalar()/s()`, `array()/a()`, `hash()/h()` wrappers no longer required; bare words are
    variables or functions (never string literals). Type inferred from RHS shape (`[]`→array,
    `{}`→hash, number/string/call→scalar) and from helper arg position (`push(X,v)`→X array,
    `set(X,v)`→X scalar, `name[k]=v`→X hash).
  Verification: `pending`
  Commit: `pending`

- ID: `SPEC-FORMAT-TERSE.1.3`
  Status: `pending`
  Goal: Mutation surface — function + operator spellings
  Acceptance: Scalar assign `name = val` (op) or `set(name, val)` (function); array push `name += val`
    (op) or `push(name, val)` (function); hash set `name[k] = v` (op) or `set_key(name, k, v)`
    (function). Both spellings lower identically.
  Verification: `pending`
  Commit: `pending`

- ID: `SPEC-FORMAT-TERSE.1.4`
  Status: `pending`
  Goal: Helper renames — `assign`→`set`, `concat`→`cat`, `array_copy`/`hash_copy`→`copy`
  Acceptance: `set` replaces `assign`; `cat` replaces `concat`; one `copy(name)` covers arrays and
    hashes (replaces `array_copy`/`hash_copy`). Old names aliased during migration, then retired.
  Verification: `pending`
  Commit: `pending`

- ID: `SPEC-FORMAT-TERSE.1.5`
  Status: `pending`
  Goal: Literals, nested access, call + semicolon rules
  Acceptance: Literals `"..."`, `'...'`, `42`, `3.14`, `true`, `false`, `undef`; nested access
    `foo["a"][9]['b'][z]` (any mix of string/numeric/variable indices, any depth); function calls
    always with `()` and a space before `()` allowed (`return (val)` == `return(val)`); semicolons
    required only when multiple statements share a line.
  Verification: `pending`
  Commit: `pending`

- ID: `SPEC-FORMAT-TERSE.1.6`
  Status: `pending`
  Goal: Array mutation methods — `.push_front(v)`, `.push_back(v)`, `.pop_front()`, `.pop_back()`
  Acceptance: The four array end-mutation methods are recognized and lower to ActionIR.
  Verification: `pending`
  Commit: `pending`

- ID: `SPEC-FORMAT-TERSE.2`
  Status: `proposed`
  Goal: Round 2 — control flow (everything is an expression)
  Children: `.2.1`, `.2.2`, `.2.3`

- ID: `SPEC-FORMAT-TERSE.2.1`
  Status: `pending`
  Goal: Expression-valued blocks — `{ ... }` returns its value (last statement or explicit `return()`)
  Acceptance: A block evaluates to its last statement's value or an explicit `return(...)`; blocks
    compose as expressions.
  Verification: `pending`
  Commit: `pending`

- ID: `SPEC-FORMAT-TERSE.2.2`
  Status: `pending`
  Goal: Control-flow keywords — `if/elseif/else`, `when`, `otherwise`, `default`, `while`, `switch`
  Acceptance: `if (cond) { ... } elseif (cond) { ... } else { ... }` — parens for conditions, blocks
    for bodies, blocks NEVER inside parens; `when (cond) { ... }` inline conditional; `otherwise { ... }`
    and `default { ... }` take no parens/args; `while (cond) { ... }`; `switch (expr) { case(v) { ... }
    default { ... } }`.
  Verification: `pending`
  Commit: `pending`

- ID: `SPEC-FORMAT-TERSE.2.3`
  Status: `pending`
  Goal: Fluent control-flow, lifecycle blocks, and full composability
  Acceptance: Fluent chains `.when (cond) { ... }.otherwise { ... }` (parens for condition, block after);
    lifecycle blocks `I { ... }`, `LS { ... }`, etc. take a block after the keyword and drop the value;
    Lisp-style composability everywhere (any function in any argument position at any depth); method
    chaining by return type (array→array, hash→hash, string→string, number→number).
  Verification: `pending`
  Commit: `pending`

- ID: `SPEC-FORMAT-TERSE.3`
  Status: `proposed`
  Goal: Round 3 — edge syntax (confirm) + arithmetic (functions-only)
  Children: `.3.1`, `.3.2`

- ID: `SPEC-FORMAT-TERSE.3.1`
  Status: `pending`
  Goal: Edge syntax — confirm and lock current behavior
  Acceptance: `->` action edges, `=>` blind-call edges kept as-is. Grouped targets `-> A | B { code }`
    factor a shared code block across child rules (each target dispatches independently; the pipe is
    purely syntactic factoring). The block-less form `-> A | B` (no `{...}`) stays INVALID. (No code
    change expected — documents the decided contract; pair with regression locks if not already present.)
  Verification: `pending`
  Commit: `pending`

- ID: `SPEC-FORMAT-TERSE.3.2`
  Status: `pending`
  Goal: Arithmetic + comparisons as composable functions (word + symbol spellings, no precedence)
  Acceptance: `add(a,b)` or `+(a,b)`, `sub(a,b)` or `-(a,b)`, etc.; comparisons `gt`/`>`, `lt`/`<`,
    `eq`/`==`, etc.; single-arg `abs`, `floor`, `ceil`, `round`; multi-arg `min`, `max`, `clamp(v,lo,hi)`;
    array reducers `sum`, `avg`, `median`, `range`. Two spellings per function (the parser treats `+`
    as a function name); NO operator precedence — deeply composable like any other call. (Maps onto the
    existing `num_*` family; this leaf adds the symbol spellings + the no-precedence composition model.)
  Verification: `pending`
  Commit: `pending`

- ID: `SPEC-FORMAT-TERSE.4`
  Status: `pending`
  Goal: Round 4+ — resume brainstorming the remaining surfaces, then add leaves
  Acceptance: A converged direction is brainstormed for the surfaces NOT yet covered — capture/marks,
    rule modes, split markers, lifecycle semantics, etc. — recorded back into the KM card and this tree
    as new `.4.x` leaves. (Discovery leaf, not an implementation leaf.)
  Verification: `pending`
  Commit: `pending`

## Current Frontier

| Order | Leaf | Status | Why next |
| --- | --- | --- | --- |
| — | `SPEC-FORMAT-TERSE.0` | `done` | Ratified 2026-06-18 — ADR `0007` (direction Rounds 1–3 + gradual-alias migration + lockstep variants + reference-touching exception + regression gate). |
| — | ~~EXECUTION DECISION PENDING~~ | `resolved` 2026-06-22 | The "usable phase0" gate is **cleared** — `t/phase0_regression.t` 960/960 green + `tools/run_ci_local.sh` EXIT 0 (via `PHASE0-BACKHALF-TRIAGE`). Migration policy already resolved (gradual-alias, ADR `0007`). `.1.x`+ are now PNT-eligible. |
| — | `SPEC-FORMAT-TERSE.1.1.1` | `done` 2026-06-24 | Round 1 — auto-existing working variables (**Perl reference**): the engine now auto-supplies the per-invocation `my` lexical for wrapper-referenced vars; `declare(...)` is now optional. Collector in `RuleIR::EmitContext::_collect_auto_working_var_decls`, injection in `SpecEntry::compile_spec_entry`. 19/20 shipped specs byte-identical (only `tkgui` gains one legit `my`, behavior-preserved); +3 phase0 locks → 968 green; gate EXIT 0; book taught (declare optional). |
| 1 | `SPEC-FORMAT-TERSE.1.1.2` | `pending` (**now PNT-eligible to ASSESS**) | Rust lockstep parity for auto-existing variables — `.1.1.1` has landed, so this is now the next pick (ADR 0007: a reference change is not "landed against the universal contract" until the lockstep parity closes; ADR 0006). Assess blocked-vs-doable: the non-recursive auto-exist specs (the `.1.1.1` locks) should be reproducible on Rust independent of the known recursive-grammar `RUST-PARITY` gap. |
| 2 | `SPEC-FORMAT-TERSE.1.2` | `pending` (ungated) | Remove `scalar()/array()/hash()` wrappers + add type inference (RHS shape + arg position). |
| 3 | `SPEC-FORMAT-TERSE.1.4` | `pending` (ungated) | Helper renames `assign`→`set`, `concat`→`cat`, `array_copy`/`hash_copy`→`copy` (old names aliased). |
| … | `.1.3`,`.1.5`,`.1.6`,`.2.x`,`.3.x`,`.4` | `pending` (ungated) | Remaining Round 1–3 leaves + Round 4+ discovery, per the Task Tree. |

## Decisions

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
  **keep only what can be ported / have a Rust/Julia/Dart variant** — Perl-only non-portable legacy
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

- **CALL SYNTAX for operator/comparison functions — design input (user, 2026-06-18; for `.3.2`).**
  The user proposes a Lisp-style *callee-inside-paren* prefix form alongside the card's
  callee-before-paren form, and asked for a recommendation. Four candidate spellings of "a ≥ b":
  `>=(a, b)` (symbol callee + `()`), `(>= a, b)` (Lisp prefix, symbol), `ge(a, b)` (word callee +
  `()`), `(ge a, b)` (Lisp prefix, word). **Recommendation (to ratify in `.3.2`):** keep **one**
  uniform `callee(args)` call grammar with **both word and symbol callee spellings** — `ge(a, b)`
  canonical (most readable), `>=(a, b)` an accepted alias — and do **not** add the `(op a, b)`
  callee-inside-paren form. Rationale: (i) the card already standardized on `callee(args)` ("calls
  always with `()`"); (ii) full Lisp *composability* (any call nests at any depth) is already
  achieved by `add(mul(a,b), c)` — it doesn't require the `(op …)` *surface syntax*; (iii) a second
  call grammar costs readability (the stated guiding principle) and risks ambiguity with plain
  `(expr)` grouping. Operator-functions return a **typed value** with methods, chainable, and the
  type may change along the chain (consistent with `.2.3`). **User's call — it's their language.**
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

## Verification Log

| Date | Leaf | Checks | Result |
| --- | --- | --- | --- |
| `2026-06-16` | `SPEC-FORMAT-TERSE` | Transcription faithful to `docs/knowledge/spec-format-brainstorm-rounds-1-3.md` | Done — all Rounds 1–3 captured as leaves; Round 4+ as a discovery leaf |
| `2026-06-18` | `SPEC-FORMAT-TERSE.0` | ADR `0007` written + indexed; cross-checked Rounds 1–3 vs the user's 2026-06-18 clarifications (all consistent); `scripts/check_memory_architecture.sh`; KM gate | self-check + KM gate pass. Direction ratified; migration policy = gradual alias; tree `proposed`→`active`. Design-only — regression gate N/A to `.0`. No engine/book change |
| `2026-06-23` | `SPEC-FORMAT-TERSE.1.1` (split) | `dump_parser_source` ground-truth probes (scratchpad `probe_autovar*.pl`, dump-don't-transcribe) establishing the one-scope / non-strict / preamble-`my` model; `grep -c 'use strict' perl/LinkedSpec/SpecEntry.pm` = 0; baseline `scripts/check_memory_architecture.sh`, `scripts/check_doctrines.sh` (2/2), KM gate all EXIT 0 | Split `.1.1` → `.1.1.1`+`.1.1.2`; design recorded; KM card [[working-vars-no-strict-need-my-lexical]] added (map regenerated). Docs/tree/KM-only — no engine/book change, so phase0 N/A to the split slice |
| `2026-06-24` | `SPEC-FORMAT-TERSE.1.1.1` | `dump_parser_source` ground truth (no-declare leaky-global → injected `my`); all-20-specs generated-source diff (mine vs git-stashed code files); `tkgui` parse-output before/after incl. a 2nd same-process parse; `perl -c`; +3 phase0 locks; `bash tools/run_ci_local.sh`; `mdbook build` | **19/20 specs byte-identical**; only `tkgui` differs (+1 legit `my $subgui_name;`, parse output identical before/after); Lispish `a(undef)`→`my @undef` false-positive caught by the diff + fixed (reserved-literal exclusion); **phase0 965→968 green**; gate **EXIT 0** ("Result: PASS", 968); `mdbook build` EXIT 0; ratio 1.0000 preserved (phase0 all-target guard green) |

## Commit Log

| Leaf | Commit subject or reference | Notes |
| --- | --- | --- |
| `SPEC-FORMAT-TERSE` (creation) | (in the `SPEC-FORMAT-TERSE.0` activation commit) | Tree was created `proposed` in an earlier session; first commit lands with `.0`. |
| `SPEC-FORMAT-TERSE.0` | `SPEC-FORMAT-TERSE.0 — activate + ratify the terse .spec format direction (ADR 0007)` | Tree `proposed`→`active`; ADR `0007` + INDEX row; migration policy = gradual alias; reference-touching exception; implementation gated by `RTLUTILS-REGEX-HANG`. No engine/book change. |
| `SPEC-FORMAT-TERSE.1.1` (split) | `SPEC-FORMAT-TERSE.1.1 — split into .1.1.1 (Perl) + .1.1.2 (Rust parity); record auto-existing-variable design + KM card` | `.1.1` → container; first frontier child `.1.1.1`. Design grounded by `dump_parser_source` probes; KM [[working-vars-no-strict-need-my-lexical]]. Docs/tree/KM-only — no engine/book change. |
| `SPEC-FORMAT-TERSE.1.1.1` | `SPEC-FORMAT-TERSE.1.1.1 — Perl auto-existing working variables (engine + book + 3 phase0 locks)` | Collector `_collect_auto_working_var_decls` in `RuleIR/EmitContext.pm` (+ `_mask_action_code_literals`) → `auto_var_decls`; preamble injection in `SpecEntry::compile_spec_entry`. 19/20 specs byte-identical (tkgui +1 legit `my`, behavior-preserved); +3 phase0 locks → 968; gate EXIT 0; book taught (declare optional). |

## Changelog

- `2026-06-24`: **`.1.1.1` DONE — Perl auto-existing working variables.** PNT (user-directed loop start)
  implemented the first terse-format engine leaf. TOOLBOX-first `dump_parser_source` ground truth confirmed
  the no-declare hazard (bare leaky-global `$count`/`@items`) and the fix shape. Added a rule-level
  collector `RuleIR::EmitContext::_collect_auto_working_var_decls` (+ literal-masker
  `_mask_action_code_literals`): scans the RAW pre-lowering blocks (NOT regex slots) for
  single-bare-identifier typed-wrapper refs, sigil-from-wrapper, dedup vs `@<label>` accumulator + any
  same-sigil `my` already in the lowered code, excludes DSL literals (`undef`/`true`/`false`) + engine
  handler locals; returned as `auto_var_decls`, injected into the preamble by
  `SpecEntry::compile_spec_entry` (empty ⇒ byte-identical). **Proof:** all-20-specs source diff (mine vs
  git-stashed) = **19/20 byte-identical**; only `tkgui` differs (+1 legit `my $subgui_name;` for its genuinely
  undeclared working scalar) with **identical parse output before/after** (incl. a 2nd same-process parse — no
  leak). A Lispish `a(undef)` false positive was caught by the diff and fixed (reserved-literal exclusion).
  **+3 phase0 locks** (no-declare scalar+array work + no cross-parse leak; declare-path single-`my`;
  reserved-literal not auto-declared): **phase0 965→968 green**; `bash tools/run_ci_local.sh` **EXIT 0**;
  ratio 1.0000; `mdbook build` EXIT 0. Book taught auto-existence (declare optional) in 3 pages; examples not
  re-authored (later gradual leaf). KM card [[working-vars-no-strict-need-my-lexical]] updated to
  status-implemented. **Next: `.1.1.2`** (Rust lockstep parity — now PNT-eligible to assess; ADR 0007/0006).
- `2026-06-23`: **`.1.1` SPLIT → `.1.1.1` (Perl reference) + `.1.1.2` (Rust lockstep parity).** PNT picked
  `.1.1` (auto-existing variables, first terse-format implementation leaf) and a `dump_parser_source`
  ground-truth pass (TOOLBOX-first; scratchpad `probe_autovar*.pl`) showed it is too broad for one signoff
  slice: it is a multi-module Perl reference-engine change (a rule-level variable-collection pass feeding the
  handler preamble) **plus** a lockstep Rust parity obligation (ADR `0006`). Per the PNT splitting rule, split
  `.1.1` into `.1.1.1` (Perl) + `.1.1.2` (Rust), made `.1.1` a container, moved the frontier to `.1.1.1`, and
  recorded the verified design (one-scope handler / non-strict-handler leaky-global hazard / preamble-`my`
  injection / wrapper→sigil / dedup vs accumulator+declare / ratio-1.0000) in Decisions + KM card
  [[working-vars-no-strict-need-my-lexical]] (map regenerated). Docs/tree/KM-only — **no engine or book change**
  in this slice. Next PNT: implement `.1.1.1`.
- `2026-06-22`: **Implementation gate CLEARED — `.1.x`+ now PNT-eligible.** The usable-`t/phase0_regression.t`
  gate on the implementation leaves is satisfied: `LEGACY-VHDL-RETIRE` cleared `RTLUTILS-REGEX-HANG`,
  `NONCORE-QUARANTINE` relocated the rest of the domain island (excising the second back-half hang's smoke),
  and `PHASE0-BACKHALF-TRIAGE` resolved the 173 back-half failures + the corpus/dark-tail tail → phase0 is
  **960/960 green** and `bash tools/run_ci_local.sh` exits **0**. Migration policy was already resolved
  (gradual-alias, ADR `0007`), so no remaining decision blocks `.1.1`. Status reconciliation recorded
  cross-tree in `PHASE0-BACKHALF-TRIAGE.5.3.2.1`; this tree's design + leaves are unchanged (no engine/book
  change here — the implementation leaves are a future PNT selection).
- `2026-06-18`: **Activated + ratified (`.0` done).** The user activated the tree during
  `SPEC-LANG-REFERENCE.10.5.4` (AskUserQuestion: "Activate SPEC-FORMAT-TERSE now") and reinforced the
  terse semantics over several messages (`assign`→`=`/`set`; no-sigil typed bare identifiers; type
  inference at init / by arg position; `copy()` unifies array+hash; arrays/hashes/numbers/strings have
  methods; everything-is-an-expression). Wrote ADR `0007` ratifying Rounds 1–3 + the gradual-alias
  migration policy + lockstep-all-variants + the user-sanctioned reference-touching exception + the
  regression-gate requirement; indexed it. Status `proposed`→`active`. The `SPEC-LANG-REFERENCE` book
  scorch is paused for this pivot. Implementation leaves `.1.x`+ remain gated by `RTLUTILS-REGEX-HANG`
  + a user confirmation of the migration policy — both surfaced to the user. No engine/book change.
- `2026-06-16`: Created tree; transcribed the 2026-06-15 brainstorm (Rounds 1–3) into pickable leaves;
  parked as `proposed` pending the RTLUtils hang fix.
