# SPEC-FORMAT-TERSE: Evolve the .spec DSL toward a terser, fully-composable format

## Metadata

- Tree ID: `SPEC-FORMAT-TERSE`
- Status: `active` (activated 2026-06-18 by user; ratified in ADR `0007`)
- Roadmap lane: `Overall roadmap — .spec language evolution (terse format)`
- Created: `2026-06-16`
- Last updated: `2026-07-01` (**`.2.3.5.6` DONE; frontier `.2.3.5.5`** — typed wrapper quoted-name
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
  receivers, `sorted_keys`/`sorted_values` bridge into array receiver chains, receiver-dot `scalaref(key)` reads
  a field from the current hash value, and statement-level `set_key(meta, ...)` / `meta[key] = value` remain the
  mutating forms. Rust `merge_hash` now matches the documented later-argument override contract. Prior
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
  not claimed, `scalaref(...)` compatibility is unchanged, and RHS-shape inference stays later. Phase0 is
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
  Commit: `SPEC-FORMAT-TERSE.1.2.1` (see Commit Log)

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
  Commit: `SPEC-FORMAT-TERSE.1.2.2` (see Commit Log)

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
  Commit: `SPEC-FORMAT-TERSE.1.2.3 — split Channel 2 value reads by aggregate/scalar surfaces` (see Commit Log)

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
  Commit: `SPEC-FORMAT-TERSE.1.2.3.1 — auto-exist aggregate bare value reads` (see Commit Log)

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
  Commit: `SPEC-FORMAT-TERSE.1.2.3.2 — add Rust aggregate bare-read parity` (see Commit Log)

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
  Commit: `SPEC-FORMAT-TERSE.1.2.3.3 — split scalar bare reads by lowering seam` (see Commit Log)

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
  Commit: `SPEC-FORMAT-TERSE.1.2.3.3.1 — implement scalar source-slot bare reads` (see Commit Log)

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
  Commit: `SPEC-FORMAT-TERSE.1.2.3.3.2 — implement scalar mutation-slot bare reads` (see Commit Log)

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
  Commit: `SPEC-FORMAT-TERSE.1.2.3.3.3 — implement direct-access bare path atoms` (see Commit Log)

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
  Commit: `SPEC-FORMAT-TERSE.1.2.3.4 — add Rust scalar bare-read parity` (see Commit Log)

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
  Commit: `SPEC-FORMAT-TERSE.1.2.3.5 — split RHS-shape inference by mechanism` (see Commit Log)

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
  Commit: `SPEC-FORMAT-TERSE.1.2.3.5.1 — implement Perl shape-literal values` (see Commit Log)

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
  Commit: `SPEC-FORMAT-TERSE.1.2.3.5.2 — infer Perl RHS shape target kind` (see Commit Log)

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
  Commit: `SPEC-FORMAT-TERSE.1.2.3.5.3 — implement Rust shape-literal values` (see Commit Log)

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
  Commit: `SPEC-FORMAT-TERSE.1.2.3.5.4 — implement Rust RHS shape target kind` (see Commit Log)

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
  Commit: `SPEC-FORMAT-TERSE.1.3` (see Commit Log)

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
  Commit: `SPEC-FORMAT-TERSE.1.3.2` (see Commit Log)

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
  Commit: `SPEC-FORMAT-TERSE.1.3.3` (see Commit Log)

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
  Commit: `SPEC-FORMAT-TERSE.1.3.4` (see Commit Log)

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
  Commit: `SPEC-FORMAT-TERSE.1.3.4.1` (see Commit Log)

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
  Commit: `SPEC-FORMAT-TERSE.1.3.4.2` (see Commit Log)

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
  Commit: `SPEC-FORMAT-TERSE.1.3.4.3` (see Commit Log)

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
  Commit: `SPEC-FORMAT-TERSE.1.4.1` (see Commit Log)

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
  Status: `active` (2026-06-29 — split by literal/call/separator/access surface)
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
  Commit: `SPEC-FORMAT-TERSE.1.5.2 — implement primitive literal parity` (see Commit Log)

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
  Commit: `SPEC-FORMAT-TERSE.1.5.3 — lock call spacing and mandatory parentheses` (see Commit Log)

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
  Commit: `SPEC-FORMAT-TERSE.1.5.4 — lock statement separators` (see Commit Log)

- ID: `SPEC-FORMAT-TERSE.1.5.5`
  Status: `done` (2026-06-29 — split before code)
  Goal: Direct nested access surface.
  Children: `.1.5.5.1` (explicit segment expressions), `.1.5.5.2` (bare path-segment / Channel 2
    coordination)
  Acceptance: Any-depth mixed access `foo["a"][9]['b'][z]` is designed and implemented on both variants, or
    split before code if the Channel 2 dependency is still too broad. The result must define base/value/index
    semantics explicitly, coordinate with `.1.2.3` value-position bare-word reads, and preserve the existing
    `scalaref(base, path)` behavior until the direct syntax fully supersedes it.
  Verification: **SPLIT 2026-06-29.** KM retrieval first (`terse-literals-calls-separators-access-ground-truth`,
    `terse-bare-working-vars-engine-gaps`), then TOOLBOX probes and code-read. Direct
    `return(foo["a"][9]["b"][scalar(z)])` currently rewrites to invalid Perl-shaped
    `return foo["a"][9]["b"][$z]`, and a generated-source/runtime probe fails handler compilation near `][`.
    The existing explicit helper `return(scalaref(foo,{"a"}[9]{"b"}[scalar(z)]))` lowers correctly to
    `$foo->{"a"}->[9]->{"b"}->[$z]`. Bare segment `z` remains a bare atom in both direct and `scalaref`
    probes, matching the open Channel 2 value-position-read gap. Rust code-read shows only single-level
    `IndexedVar { name, index }` parsing/evaluation today. Therefore `.1.5.5` becomes a container before any
    implementation code. No engine/book behavior change in this split slice.
  Commit: `SPEC-FORMAT-TERSE.1.5.5 — split direct access by Channel 2 boundary` (see Commit Log)

- ID: `SPEC-FORMAT-TERSE.1.5.5.1`
  Status: `done` (2026-06-29)
  Goal: Direct nested access with explicit path segments.
  Acceptance: Perl and Rust accept any-depth mixed direct bracket access with explicit segment expressions,
    e.g. `foo["a"][9]["b"][scalar(z)]`, while preserving `scalaref(base,path)` as an accepted explicit helper.
    Segment kind semantics are documented and locked conservatively: quoted string segments are hash keys,
    numeric segments are array indexes, and helper/value expressions in brackets are explicit index
    expressions unless later Channel 2 work deliberately broadens them. Bare path segments such as `[z]` remain
    out of scope for this leaf.
  Verification: **DONE 2026-06-29.** Perl now lowers direct nested access in value positions through
    `ActionIR::ValueExpr::_lower_direct_nested_access_value_expr`, reusing the existing `scalaref(...)`
    segment splitter/lowerer so explicit paths produce the same dereference chain:
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
  Commit: `SPEC-FORMAT-TERSE.1.5.5.1 — implement direct nested access explicit segments` (see Commit Log)

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
  Commit: `SPEC-FORMAT-TERSE.1.5.5.2 — merge bare direct access into Channel 2` (see Commit Log)

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
  Commit: `SPEC-FORMAT-TERSE.1.6 — implement array end-mutation methods` (see Commit Log)

- ID: `SPEC-FORMAT-TERSE.2`
  Status: `active` (Round 2 expression-valued block leaf `.2.1` done; frontier `.2.2`)
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
  Commit: `pending`

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
  Commit: `SPEC-FORMAT-TERSE.2.1.2 — implement Perl expression-valued blocks`

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
  Commit: `SPEC-FORMAT-TERSE.2.1.3 — own Rust expression-valued blocks`; implementation commit pending.

- ID: `SPEC-FORMAT-TERSE.2.1.4`
  Status: `done` (2026-06-30)
  Goal: Block-local explicit return semantics and composition follow-through
  Acceptance: True block-local early-return semantics are implemented without leaking into the surrounding
    rule return channel; nested composition is locked and the book is updated.
  Verification: Perl syntax checks; TOOLBOX lowering/runtime probes; focused Rust `.2.1.4` runtime locks;
    oracle corpus regenerated to **35 fixtures** and corpus oracle PASS; phase0 PASS (**991 tests**);
    mdBook/KM/memory/doctrine/diff checks PASS; full local CI PASS.
  Commit: `SPEC-FORMAT-TERSE.2.1.4 — implement block-local return`

- ID: `SPEC-FORMAT-TERSE.2.2`
  Status: `active` (split 2026-06-30 by `.2.2.1`; `.2.2.6.2` done, frontier `.2.3`)
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
  Commit: `SPEC-FORMAT-TERSE.2.2.1 - split control-flow keyword surface`

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
  Commit: `SPEC-FORMAT-TERSE.2.2.2 - implement Perl attached if blocks`

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
  Commit: `SPEC-FORMAT-TERSE.2.2.3 - own Rust attached if blocks`;
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
  Commit: `SPEC-FORMAT-TERSE.2.2.4 - own when otherwise aliases`;
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
  Commit: `SPEC-FORMAT-TERSE.2.2.5 - split attached switch surface`;
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
  Commit: `SPEC-FORMAT-TERSE.2.2.5.1 - implement Perl attached switch separator lock`

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
  Commit: `SPEC-FORMAT-TERSE.2.2.5.2 - implement Rust attached switch blocks`

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
  Commit: `SPEC-FORMAT-TERSE.2.2.6 - split while loop surface`

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
  Commit: `SPEC-FORMAT-TERSE.2.2.6.1 - implement Perl attached while safety`

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
  Commit: `SPEC-FORMAT-TERSE.2.2.6.2 - implement Rust attached while safety`

- ID: `SPEC-FORMAT-TERSE.2.3`
  Status: `active` (2026-06-30 — SPLIT/OWNED before code; container)
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
  Commit: `SPEC-FORMAT-TERSE.2.3 - split fluent lifecycle composability surface`

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
  Commit: `SPEC-FORMAT-TERSE.2.3.1 - lock Perl fluent when otherwise blocks`

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
  Commit: `SPEC-FORMAT-TERSE.2.3.2 - lock lifecycle value drop return channel`

- ID: `SPEC-FORMAT-TERSE.2.3.3`
  Status: `active` (2026-06-30 — SPLIT/OWNED before code; container)
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
  Commit: `SPEC-FORMAT-TERSE.2.3.3.1 - implement Rust action-edge fluent continuations` (see Commit Log)

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
  Commit: `SPEC-FORMAT-TERSE.2.3.3.2 - implement Rust attached fluent block payloads` (see Commit Log)

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
  Commit: `SPEC-FORMAT-TERSE.2.3.3.3 - split remaining Rust fluent continuations` (see Commit Log)

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
  Commit: `SPEC-FORMAT-TERSE.2.3.3.3.1 - implement Rust compact lifecycle fluent chains` (see Commit Log)

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
  Commit: `SPEC-FORMAT-TERSE.2.3.3.3.2 - implement Rust action-edge fluent flow chains` (see Commit Log)

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
  Commit: `SPEC-FORMAT-TERSE.2.3.3.3.3 - split Rust tclite repetition parity` (see Commit Log)

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
  Commit: `SPEC-FORMAT-TERSE.2.3.3.3.3.1 - implement Rust tclite default repetition` (see Commit Log)

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
  Commit: `pending` (split/audit slice)

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
  Commit: `SPEC-FORMAT-TERSE.2.3.4.1 - implement Rust bare aggregate helper args`

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
  Commit: `SPEC-FORMAT-TERSE.2.3.4.2 - implement Perl inline value controls`

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
  Commit: `SPEC-FORMAT-TERSE.2.3.5 - split return-type method chaining`

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
  Commit: `SPEC-FORMAT-TERSE.2.3.5.1 - implement array receiver value chains`

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
  Commit: `SPEC-FORMAT-TERSE.2.3.5.2 - implement hash receiver value chains`

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
  Commit: `SPEC-FORMAT-TERSE.2.3.5.3 - implement string receiver value chains`

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
    Array reducers (`num_sum`, `num_avg`, `num_median`, `num_range`, and array-form `num_min`/`num_max`) remain
    explicit array-consuming helpers with no scalar-to-array receiver bridge. Added Perl phase0 locks, Rust
    parser/runtime locks, oracle fixture `terse_2_3_5_4_number_receiver_value_chains` (corpus **50 fixtures**),
    mdBook examples, and KM fact `terse-number-receiver-value-chains`.
  Commit: `SPEC-FORMAT-TERSE.2.3.5.4 - implement number receiver value chains`

- ID: `SPEC-FORMAT-TERSE.2.3.5.5`
  Status: `pending`
  Goal: Block-valued receiver-dot chaining audit/parity
  Acceptance: Verify and, only if needed, implement receiver-dot chaining from expression-valued blocks by the
    runtime type yielded by the block. A block that yields a string, number, array, or hash must be able to
    continue through the compatible receiver-family chain already owned by `.2.3.5.1` through `.2.3.5.4`, with
    no special block-only helper semantics. The slice must add Perl phase0 locks, Rust parser/runtime locks,
    oracle fixtures where JSON-stable, and mdBook examples. If the existing expression-valued block + receiver
    family machinery already satisfies the contract, this leaf closes as a verification/documentation slice
    with explicit evidence.
  Verification: `pending`
  Commit: `pending`

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
  Commit: `SPEC-FORMAT-TERSE.2.3.5.6 - lock aggregate wrapper quoting boundaries`

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
| — | `SPEC-FORMAT-TERSE.1.1.2` | `done` 2026-06-24 | Rust lockstep parity for auto-existing variables — assessed **DOABLE, no engine change**: the Rust interpreter's per-parse `RuntimeContext` HashMaps already auto-vivify working vars (no `declare` needed) and are fresh per `execute` (no leak), so auto-existence is inherent (no Perl-style leaky-global hazard to fix). Locked with 5 oracle fixtures (`autoexist_*`, Rust==Perl reference) + 4 integration tests (value anchors, declare/no-declare convergence, per-parse no-leak); cargo 244→248 green; phase0 968 green (Perl untouched). Recursive/REP idiom deferred to `RUST-PARITY` (separate gap, not auto-existence). `.1.1` container now done; `.1.1.1` change is now landed against the universal contract. |
| — | `SPEC-FORMAT-TERSE.1.2` | `active` (SPLIT 2026-06-24) | Too broad for one slice → split by inference channel (Perl-first + Rust parity) after a `dump_parser_source` ground-truth pass. KM [[terse-bare-working-vars-engine-gaps]]. |
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
| — | `SPEC-FORMAT-TERSE.2.3` | `active` 2026-06-30 | Split/owned before code: fluent block chains, lifecycle value/drop semantics, Rust parity, full composability, and return-type method chaining are separate leaves. |
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
| 1 | `SPEC-FORMAT-TERSE.2.3.5.5` | `pending` | Block-valued receiver-dot chaining by yielded runtime type; audit first, implement only if existing block value + receiver-family machinery does not already satisfy it. |
| … | `.3.x`, `.4` | `pending` | Remaining Round 3 leaves + Round 4+ discovery, per the Task Tree. |

## Decisions

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
  boolean values and invalid continuations return `undef`/`null`. Array reducers remain explicit
  array-consuming helpers; no scalar-to-array receiver bridge was added.

- `2026-07-01` (**`.2.3.5.6` typed wrapper quoted-name boundary landed**). The aggregate typed wrappers are
  name-reference forms only when called with exactly one bare name token: `array(foo)` / `a(foo)` read the
  array/list working variable `foo`, and `hash(bar)` / `h(bar)` read the hash/associative-array working
  variable `bar`. Quoted arguments are not aliases for those reads: they stay literal constructor payloads
  under the existing constructor rules. The terse constructor surface is the direct shape syntax (`[...]` and
  `{...}`), which should be preferred in new examples. Runtime scalar-indirect lookup and postfix typed-view
  adapters such as `foo.array()` are explicitly out of scope.

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
  dereference semantics as `scalaref(foo,{"a"}[9]{"b"}[scalar(z)])`, and Rust models the same mixed path with
  `Expr::NestedAccess`. A single one-level non-key `foo[index]` remains the legacy indexed-variable form.
  Bare path atoms remain reserved for `.1.5.5.2` / Channel 2 so this leaf does not pre-empt the global
  bare-value-read model.

- `2026-06-29` (**`.1.5.5` direct nested access split** — explicit segment expressions before bare
  Channel 2 segments). TOOLBOX probes show direct `foo["a"][9]["b"][scalar(z)]` is not a valid lowered value
  expression today: it passes through as `foo["a"][9]["b"][$z]` and generated handler compilation fails near
  `][`. The existing `scalaref(foo,{"a"}[9]{"b"}[scalar(z)])` path remains the working explicit syntax and
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
| `2026-07-01` | `SPEC-FORMAT-TERSE.2.3.5` | KM retrieval; full bootstrap/roadmap/mdBook/core-code read; TOOLBOX `call_spec_handler_subst` probes for statement receiver-dot mutations, value-position receiver-dot forms, and function-style pure helper composition; mdBook stale inline-control wording audit | Return-type method chaining split before code. Current ground truth: statement-only `.1.6` receiver-dot mutations lower/run, value-position/chained receiver-dot forms remain unsupported, Rust parses `Expr::FluentChain` but only executes single-call array end mutations as statement side effects. Child leaves `.2.3.5.1`–`.2.3.5.4` now own array/hash/string/number receiver-chain implementation. |
| `2026-07-01` | `SPEC-FORMAT-TERSE.2.3.5.1` | Perl syntax checks and receiver-chain probes; `prove -q -Iperl t/phase0_regression.t`; focused Rust parser/runtime tests (`parse_array_receiver_value_chain`, `terse_2_3_5_1`); `perl -Iperl tools/gen_oracle_corpus.pl`; Rust `corpus_oracle`; mdBook build; memory/doctrine/KM/diff checks | Array receiver-dot value chains landed. Pure array links compose through array-returning helpers, terminals return documented values, receiver-dot `join_values` preserves delimiter-first helper semantics, `split_each` flattens with the supplied delimiter on Rust, and `.1.6` end mutations remain statement-only. Phase0 PASS (996 tests); oracle corpus PASS over 47 fixtures. |
| `2026-07-01` | `SPEC-FORMAT-TERSE.2.3.5.2` | Perl syntax checks and hash receiver-chain probes; focused Rust parser/runtime tests (`parse_hash_receiver_value_chain`, `terse_2_3_5_2`); `perl -Iperl tools/gen_oracle_corpus.pl`; Rust `corpus_oracle`; mdBook build; memory/doctrine/KM/diff checks | Hash receiver-dot value chains landed. Hash-returning links compose through hash helpers, `sorted_keys`/`sorted_values` bridge into array receiver chains, receiver-dot `scalaref` reads hash fields, statement hash mutations stay statement-only, and Rust `merge_hash` later-argument override parity is fixed. Phase0 PASS (997 tests); oracle corpus PASS over 48 fixtures. |
| `2026-07-01` | `SPEC-FORMAT-TERSE.2.3.5.3` | Perl syntax checks for `MethodLowering.pm`, `t/phase0_regression.t`, and oracle generator; focused lowering/runtime/source probes; focused Rust parser/runtime tests (`parse_string`, `terse_2_3_5_3`); `perl -Iperl tools/gen_oracle_corpus.pl`; Rust `corpus_oracle`; phase0 (`prove -q -Iperl t/phase0_regression.t`) | String receiver-dot value chains landed. String-returning links compose from bare scalar, explicit scalar, capture, and string-literal receivers; `split(delim)` bridges into array receiver chains; terminal string methods end the chain with `undef`/`null` on invalid continuations; value-form `split(...)` and `substr(...)` lower as portable helper payloads. Phase0 PASS (998 tests); oracle corpus PASS over 49 fixtures. |
| `2026-07-01` | `SPEC-FORMAT-TERSE.2.3.5.4` | Perl syntax checks for `MethodLowering.pm`, `t/phase0_regression.t`, and oracle generator; focused lowering/runtime/source probes; focused Rust parser/runtime tests (`parse_number_receiver`, `parse_decimal_number_receiver`, `terse_2_3_5_4`); `perl -Iperl tools/gen_oracle_corpus.pl`; Rust `corpus_oracle`; phase0 (`prove -q -Iperl t/phase0_regression.t`) | Number receiver-dot value chains landed. Numeric links compose through `num_*` helpers, integer/decimal literal receivers parse, comparison methods are terminal, value-form numeric comparisons lower on Perl, Rust `num_add`/`num_mul` consume all operands, and statement/lifecycle methods such as `declare(...)` remain outside terse receiver methods. Phase0 PASS (999 tests); oracle corpus PASS over 50 fixtures. |
| `2026-07-01` | `SPEC-FORMAT-TERSE.2.3.5.6` | Perl syntax checks for `MethodLowering.pm`, `ValueExpr.pm`, `t/phase0_regression.t`, and oracle generator; focused lowering/runtime/source probes for bare vs quoted aggregate wrappers and direct shapes; full phase0 (`prove -q -Iperl t/phase0_regression.t`); focused Rust `.2.3.5.6` integration tests; `perl -Iperl tools/gen_oracle_corpus.pl`; Rust `corpus_oracle`; `mdbook build docs/linkedspec-book`; Knowledge Map/memory/doctrine/diff/local CI gates | Typed wrapper quoted-name boundaries landed. Bare `array(foo)` / `a(foo)` and `hash(bar)` / `h(bar)` are explicit aggregate working-variable reads; quoted wrapper arguments remain literal constructor payloads and are not scalar-indirect aliases; direct `[...]` and `{...}` shapes are the preferred terse constructors. Perl generic value-expression lowering now recognizes direct shape literals in helper composition and avoids reserving primitive literals or inappropriate engine locals as aggregate symbols. Phase0 PASS (1000 tests); oracle corpus PASS over 51 fixtures. |
| `2026-06-16` | `SPEC-FORMAT-TERSE` | Transcription faithful to `docs/knowledge/spec-format-brainstorm-rounds-1-3.md` | Done — all Rounds 1–3 captured as leaves; Round 4+ as a discovery leaf |
| `2026-06-18` | `SPEC-FORMAT-TERSE.0` | ADR `0007` written + indexed; cross-checked Rounds 1–3 vs the user's 2026-06-18 clarifications (all consistent); `scripts/check_memory_architecture.sh`; KM gate | self-check + KM gate pass. Direction ratified; migration policy = gradual alias; tree `proposed`→`active`. Design-only — regression gate N/A to `.0`. No engine/book change |
| `2026-06-23` | `SPEC-FORMAT-TERSE.1.1` (split) | `dump_parser_source` ground-truth probes (scratchpad `probe_autovar*.pl`, dump-don't-transcribe) establishing the one-scope / non-strict / preamble-`my` model; `grep -c 'use strict' perl/LinkedSpec/SpecEntry.pm` = 0; baseline `scripts/check_memory_architecture.sh`, `scripts/check_doctrines.sh` (2/2), KM gate all EXIT 0 | Split `.1.1` → `.1.1.1`+`.1.1.2`; design recorded; KM card [[working-vars-no-strict-need-my-lexical]] added (map regenerated). Docs/tree/KM-only — no engine/book change, so phase0 N/A to the split slice |
| `2026-06-24` | `SPEC-FORMAT-TERSE.1.1.1` | `dump_parser_source` ground truth (no-declare leaky-global → injected `my`); all-20-specs generated-source diff (mine vs git-stashed code files); `tkgui` parse-output before/after incl. a 2nd same-process parse; `perl -c`; +3 phase0 locks; `bash tools/run_ci_local.sh`; `mdbook build` | **19/20 specs byte-identical**; only `tkgui` differs (+1 legit `my $subgui_name;`, parse output identical before/after); Lispish `a(undef)`→`my @undef` false-positive caught by the diff + fixed (reserved-literal exclusion); **phase0 965→968 green**; gate **EXIT 0** ("Result: PASS", 968); `mdbook build` EXIT 0; ratio 1.0000 preserved (phase0 all-target guard green) |
| `2026-06-24` | `SPEC-FORMAT-TERSE.1.1.2` | Throwaway Rust + Perl `LinkedSpec::Get` probes (dump-don't-guess) on the same minimal grammars; read `runtime.rs`/`engine.rs` variable model; `tools/gen_oracle_corpus.pl` (5 new `autoexist_*` fixtures, existing 2 byte-identical); `cargo test`; `cargo clippy`; `perl -c` generator; `bash tools/run_ci_local.sh`; `mdbook build` | **Assessed DOABLE, no engine change** — Rust HashMaps auto-vivify + fresh ctx per parse ⇒ auto-existence inherent, no leaky-global hazard. Cross-variant proof: scalar no-declare Perl `"ok"`/Rust `["ok"]`; array no-declare Perl `["a","b"]`/Rust `[["a","b"]]`; declare twins identical; `array(undef)` Perl `[null]`/Rust `[[null]]` (= Perl reference wrapped one level). **cargo 244→248 green**; all **7 oracle fixtures PASS**; clippy zero-new (engine.rs 11 = baseline; test files add 0); `perl -c` OK; **phase0 968 green** (Perl untouched), gate **EXIT 0**; `mdbook build` EXIT 0. Recursive/REP idiom deferred to `RUST-PARITY` (separate gap). |
| `2026-06-24` | `SPEC-FORMAT-TERSE.1.2` (split) | `dump_parser_source` ground-truth probes (`perl -Iperl -MLinkedSpec`, `generate_only`+`runtime_ctx_ref`; scratchpad `probe_terse_1_2.pl` + isolated one-liners, dump-don't-guess); confirmed `perl -Iperl` loads `perl/LinkedSpec.pm` (stale `PERL5LIB` present); `perl -c` on `ValueExpr.pm`/`MethodLowering.pm`/`EmitContext.pm`; `grep` wrapper-usage census across `specs/*.spec`; baseline `scripts/check_memory_architecture.sh` + `scripts/check_doctrines.sh` + KM gate | Split `.1.2` → `.1.2.1` (Perl, Channel 1) + `.1.2.2` (Rust parity); Channel 2 (`.1.2.3`+) recorded as a follow-on (not pre-published). Ground truth: bare arg-position var lowers right but no auto-`my` (leaky global); bare value-position word is not a var read (`return count`); wrapped path auto-exists (`.1.1.1`). KM card [[terse-bare-working-vars-engine-gaps]] added (map regenerated). DOCS/TREE/KM only — no engine/book change, so phase0 N/A to the split slice |
| `2026-06-24` | `SPEC-FORMAT-TERSE.1.2.1` | `dump_parser_source` ground truth (scratchpad `probe_terse_1_2_1.pl`, isolated bare forms, dump-don't-guess); all-20-specs generated-source diff (mine vs git-stashed `EmitContext.pm`); `perl -c` on `EmitContext.pm`/`LinkedSpec.pm` + `t/phase0_regression.t`; +3 phase0 locks; `bash tools/run_ci_local.sh`; `mdbook build` | Collector extended (bare arg-position pass; `assign`→`$`, `push_value`/`push_nonempty`→`@`; `\s*,` guard keeps wrapped on the wrapped path; shared `$record` dedup). **All 20 specs byte-identical (0 diff)**; bare forms now emit the preamble `my` (incl. `assign(pair, set_key(hash(pair),…))` → both `my %pair` + `my $pair`); **phase0 968→971 green**; gate **EXIT 0** ("[ci] local CI gate passed", 971); ratio 1.0000; `mdbook build` EXIT 0. Book (3 pages) taught bare arg-position auto-existence + corrected the outdated "arg-position is later" note. Child-append/`.push` target + bare hash deferred to Channel 2. |
| `2026-06-24` | `SPEC-FORMAT-TERSE.1.2.2` | Throwaway Rust integration probe (bare vs wrapped, dump-don't-guess); read `engine.rs` resolvers; `tools/gen_oracle_corpus.pl` +2 fixtures (regenerated, existing 7 byte-identical); `cargo test`; `cargo clippy`; `perl -c gen_oracle_corpus.pl`; `bash tools/run_ci_local.sh` | **REQUIRED a Rust engine change** (contrast `.1.1.2`): bare `Expr::Variable` target fell through to `val.to_str()` → probe `[null]`/`[[]]`. Added bare-target acceptance to `resolve_scalar_target` + `resolve_array_target` (`allow_bare` gate; push targets true, array_copy/hash_copy false) → probe now `["ok"]`/`[["a","b"]]` (= wrapped = Perl reference). 2 oracle fixtures (`autoexist_{scalar,array}_bare_arg`) + 4 `terse_1_2_2_*` integration tests; **cargo 248→252 green**, 9/9 oracle PASS, clippy zero-new (engine.rs 11 baseline; flattened my `if allow_bare` nest to a tuple `if let`), `perl -c` OK; **phase0 971 green** (Perl untouched), gate **EXIT 0**; no book change (variant-agnostic). Channel 1 complete on both variants. |
| `2026-06-24` | `SPEC-FORMAT-TERSE.1.4` (split) | TOOLBOX `call_spec_handler_subst` ground-truth probes (`perl -Iperl -MLinkedSpec`, dump-don't-guess; `perl -Iperl` confirmed `perl/LinkedSpec.pm` over the stale `PERL5LIB`); read the alias seam `ActionIR/MethodExpr.pm` + the `assign`/`concat`/`array_copy`/`hash_copy` lowering sites; Rust mapping of `Engine::call_helper()`; baseline `scripts/check_doctrines.sh` (MEMORY-ARCH + KNOWLEDGE-MAP) + KM regenerate | Split `.1.4` → `.1.4.1` (Perl) + `.1.4.2` (Rust parity). Ground truth: `set`/`cat`/`copy` all currently UNRECOGNIZED (`set`→passthrough vs `assign`→`$x = 1`; `cat`→passthrough vs `concat`→do-block; `copy(a(x))`→`copy([items])` partial / `copy(h(x))`→passthrough vs `array_copy`→`[@items]` / `hash_copy`→`{%m}`). Three shapes: `cat`=pure rename (`_normalize_method_name`); `set`=statement-level (`Contracts.pm`/`DeclareMethod` — not reached by normalization); `copy`=unified array-vs-hash dispatch (`MethodLowering`). KM card [[terse-helper-rename-lowering-sites]] added (map regenerated). DOCS/TREE/KM only — no engine/book change, so phase0 N/A to the split slice |
| `2026-06-24` | `SPEC-FORMAT-TERSE.1.4.1` | TOOLBOX-first `call_spec_handler_subst` parity sweep (4 headline + 11 composed forms, dump-don't-guess); `return_descriptor` ASSIGN-node parity for `set`; end-to-end `LinkedSpec::Get` run of a terse spec vs its canonical twin; all-20-specs generated-source baseline-vs-mine diff (STDOUT capture via `dump_parser_source`); `perl -c` on all 8 edited modules; +4 phase0 locks; `bash tools/run_ci_local.sh`; `mdbook build`; doctrine driver + KM regenerate | Aliases recognized at **every** site each canonical name is (normalize seam + 3 raw-text `set` scanners + `copy` dispatch + declare-init/return-payload/FlowExpr-source/type-inference recognizers). **All 4 headline + 11 composed forms byte-equal to canonical**; `set`==`assign` ASSIGN node; terse spec runs == canonical twin (`["a!","b!","c!"]`, stable on re-run). **All 20 specs byte-identical (0 diff)** — every alias add is new-spelling-guarded. **phase0 971→975 green**; gate **EXIT 0** ("Result: PASS", 975); ratio 1.0000; `mdbook build` EXIT 0. Book (3 pages) taught the renames as canonical + old names as deprecated (not-retired) aliases. KM [[terse-helper-rename-lowering-sites]] updated (landed; reverify proves parity). |
| `2026-06-29` | `SPEC-FORMAT-TERSE.1.4.2` | Rust code-read + implementation in `Engine::call_helper()`; `perl -c tools/gen_oracle_corpus.pl`; `perl -Iperl tools/gen_oracle_corpus.pl`; focused `cargo test --manifest-path rust/linkedspec-runtime/Cargo.toml terse_1_4_2 -- --nocapture`; `cargo test --manifest-path rust/linkedspec-runtime/Cargo.toml --test corpus_oracle -- --nocapture`; full `cargo test --manifest-path rust/linkedspec-runtime/Cargo.toml`; `cargo clippy --manifest-path rust/linkedspec-runtime/Cargo.toml`; `perl -Iperl t/phase0_regression.t`; `bash tools/run_ci_local.sh`; doctrine + KM gates | Rust now recognizes `set`/`cat` via canonical match arms and unified `copy` via a dedicated array/hash value-copy arm. Added `resolve_hash_target` and one-bare-variable `hash`/`h` reference handling so `copy(h(m))` converges with `hash_copy(h(m))`; bare value-position reads remain deferred. 2 new oracle fixtures (`terse_1_4_2_set_cat_copy_array`, `terse_1_4_2_copy_hash_symbol_empty`) + 3 integration tests. Focused Rust tests PASS; corpus oracle PASS over 11 fixtures; full runtime suite PASS (116 unit + corpus-oracle harness + 36 integration tests); clippy EXIT 0 with existing 13-warning baseline only; phase0 stays **975 green**; full local gate EXIT 0. No book change; `.1.4` container done. |
| `2026-06-29` | `SPEC-FORMAT-TERSE.1.3` (split) | Knowledge Map retrieval first; read `.1.3` acceptance + relevant mdBook/helper cards; TOOLBOX `call_spec_handler_subst` probe over function/operator forms; minimal `LinkedSpec::Get` runtime probes; Rust `expr.rs`/`engine.rs` code-read; KM regenerate | Split `.1.3` by mechanism. `set(name,val)` already lowers/runs like `assign(name,val)` and is locked by `.1.4`; `push_value(name,val)` lowers/runs but requested `push(name,val)` passes through Perl as raw child-call-shaped `push(...)` and fails handler compilation, while conflicting with existing `push(Rule,target)` convention; `set_key(name,k,v)` works as a Perl pure hash value in return/source paths but not as a standalone mutation statement, and Rust only updates if arg0 is already a hash; operators `name = val`, `items += val`, `name["k"] = val` pass through as raw/invalid Perl and Rust has no assignment AST. `.1.3.1` audit done; next `.1.3.2`. No engine/book change, so phase0/cargo N/A to split slice beyond doctrine/KM checks. |
| `2026-06-29` | `SPEC-FORMAT-TERSE.1.3.2` | TOOLBOX `call_spec_handler_subst` lowerings for explicit append vs child-call forms; descriptor/runtime probe; `dump_parser_source` lock for nested/comma value; `perl -c` edited Perl modules + test/generator; `prove -q -Iperl t/phase0_regression.t`; `perl -Iperl tools/gen_oracle_corpus.pl`; focused Rust integration test; Rust corpus oracle; `mdbook build`; Knowledge Map gate; `scripts/check_memory_architecture.sh`; `bash tools/run_ci_local.sh` | Perl recognizes `push(target,value)` as explicit-value append for unambiguous/non-all-bare value expressions while preserving all-bare child-call precedence. `push(items,"a")`, `push(items, scalar(retv))`, `push(array(items), scalar(retv))`, `push(items, call(Leaf))`, and `push(items, cat("a","b"))` lower like `push_value`; `push(items, value)`, `push(Leaf, items)`, and indexed child-call forms stay child calls. Descriptor/runtime probe has zero fallback/unresolved and returns `["a","b"]`; nested/comma source dump has exactly one `my @items`; phase0 PASS (975); focused Rust test PASS; corpus oracle PASS over 12 fixtures; mdBook build EXIT 0; Knowledge Map and memory-architecture checks OK; full local gate EXIT 0. |
| `2026-06-29` | `SPEC-FORMAT-TERSE.1.3.3` | TOOLBOX `call_spec_handler_subst` lowerings for mutation vs pure value form; descriptor/runtime/source-dump probes; `perl -c` edited Perl modules + test/generator; `prove -q -Iperl t/phase0_regression.t`; `perl -Iperl tools/gen_oracle_corpus.pl`; focused Rust `terse_1_3_3`; Rust corpus oracle; `mdbook build`; Knowledge Map gate; `scripts/check_memory_architecture.sh`; `scripts/check_doctrines.sh`; `bash tools/run_ci_local.sh` | Perl recognizes `set_key(name,key,value)` as a statement-level named-hash mutation and emits `my %name` for a bare hash target. Nested `set_key(hash_expr,key,value)` remains pure/copy-valued. Rust mirrors statement mutation in `Engine::execute_block()` and keeps value helper behavior in `call_helper()`. Phase0 PASS (976); focused Rust tests PASS; corpus oracle PASS over 13 fixtures; mdBook build EXIT 0; Knowledge Map, memory-architecture, doctrine checks, and full local gate OK. |
| `2026-06-29` | `SPEC-FORMAT-TERSE.1.3.4` (split) | KM retrieval; TOOLBOX `call_spec_handler_subst` for operator forms vs settled function forms; `return_descriptor` on a spec containing all three operators; Rust `expr.rs` + `engine.rs` code-read | Split `.1.3.4` into `.1.3.4.1` scalar assignment, `.1.3.4.2` array append, `.1.3.4.3` hash-index assignment. Perl reports `name = "ok"`, `items += "a"`, and `name["k"] = "v"` as three RAW_PERL/language-agnostic blockers while settled function forms lower. Rust lifecycle code is expression-statement-only (`Stmt { expr }`) and has no assignment/append/hash-set statement variants. No engine/book behavior change; split slice owns sequencing and frontier only. |
| `2026-06-29` | `SPEC-FORMAT-TERSE.1.3.4.1` | TOOLBOX lowerings for scalar operator vs `set(...)`; descriptor/source/runtime probes; `perl -c` edited Perl modules + test/generator; `prove -q -Iperl t/phase0_regression.t`; `perl -Iperl tools/gen_oracle_corpus.pl`; focused Rust core `scalar_assignment`; focused Rust runtime `terse_1_3_4_1`; full Rust runtime suite; `mdbook build`; Knowledge Map, memory-architecture, doctrine, and full local CI gates | Perl recognizes top-level `NAME = RHS` as an ASSIGN statement and auto-declares the scalar target; Rust parses and executes statement-only `AssignScalar`. `name = cat(...)` lowers identically to `set(name, cat(...))`; `name == ...`, `items += ...`, `name[key] = ...`, and keyword-arg `name=...` remain out of scope. Phase0 PASS (`1..977`); oracle corpus regenerated with 14 fixtures; focused Rust tests PASS; full runtime suite PASS (116 unit + corpus-oracle harness + 41 integration tests); public book and KM updated. |
| `2026-06-29` | `SPEC-FORMAT-TERSE.1.3.4.2` | TOOLBOX lowerings for array operator vs `push(...)` / `push_value(...)`; descriptor/source/runtime probes; `perl -c` edited Perl modules + test/generator; `prove -q -Iperl t/phase0_regression.t`; `perl -Iperl tools/gen_oracle_corpus.pl`; focused Rust core `array_append`; focused Rust core `scalar_assignment`; focused Rust runtime `terse_1_3_4_2`; Rust corpus oracle; full Rust runtime suite; `mdbook build`; Knowledge Map, memory-architecture, doctrine, and full local CI gates | Perl recognizes top-level `NAME += RHS` as a PUSH statement and auto-declares the array target; Rust parses and executes statement-only `AssignArrayAppend`. `items += "a"`, `items += cat(...)`, and `items += scalar(value)` lower/run like explicit append forms; `items += value`, `items ++`, scalar assignment, and hash-index assignment stay separate. Phase0 PASS (`1..978`); oracle corpus regenerated with 15 fixtures; focused Rust tests PASS; full Rust runtime suite PASS (116 unit + corpus-oracle harness + 43 integration tests); public book and KM updated. |
| `2026-06-29` | `SPEC-FORMAT-TERSE.1.3.4.3` | TOOLBOX lowerings for hash-index operator vs `set_key(...)`; `perl -c` edited Perl modules + test/generator; `prove -q -Iperl t/phase0_regression.t`; `perl -Iperl tools/gen_oracle_corpus.pl`; focused Rust core `hash_index`; focused Rust core `scalar_assignment`; focused Rust core `array_append`; focused Rust runtime `terse_1_3_4_3`; Rust corpus oracle; full Rust runtime suite; `mdbook build`; Knowledge Map, memory-architecture, doctrine, and full local CI gates | Perl recognizes top-level `NAME[KEY] = RHS` as an ASSIGN statement and auto-declares the hash target; Rust parses and executes statement-only `AssignHashIndex`. `meta["stage"] = "v"`, `meta[cat("s","tage")] = cat("v","!")`, and `meta[scalar(key)] = scalar(value)` lower/run like `set_key(...)`; bare key/RHS forms remain deferred to Channel 2. Phase0 PASS (`1..979`); oracle corpus regenerated with 16 fixtures; focused Rust tests PASS; full Rust runtime suite PASS; public book and KM updated. |
| `2026-06-29` | `SPEC-FORMAT-TERSE.1.5.1` (split) | KM retrieval first; TOOLBOX `call_spec_handler_subst` probes for literals, call spacing, direct nested access, and `scalaref(...)`; `LinkedSpec::Get` runtime probes for literal values and separator behavior; `StatementSplit` probes; Perl/Rust code-read (`StatementSplit`, `MethodExpr`, `ValueExpr`, `MethodLowering`, Rust `expr.rs`/`engine.rs`); focused Rust parser tests (`parse_`, `hash_index`); `knowledge-map/scripts/check_knowledge_map.sh`; `scripts/check_memory_architecture.sh`; `scripts/check_doctrines.sh`; `git diff --check` | Split `.1.5` into `.1.5.2` literal parity, `.1.5.3` call-spacing locks, `.1.5.4` separator semantics, and `.1.5.5` direct nested access. Ground truth: Perl strings/numbers/`undef` run, but `true`/`false` are strings; call spacing works at supported helper/value sites; newline-separated lowered statements fail on Perl without `;`; direct nested access is not lowered and Rust only has single array-index `IndexedVar`. KM card [[terse-literals-calls-separators-access-ground-truth]] added. DOCS/TREE/KM only — no engine/book behavior change, so phase0 N/A to split slice. |
| `2026-06-29` | `SPEC-FORMAT-TERSE.1.5.2` | Syntax checks on edited Perl ActionIR modules/test/generator; `env PERL5LIB= prove -q -Iperl t/phase0_regression.t`; `perl -Iperl tools/gen_oracle_corpus.pl`; focused Rust `.1.5.2` integration tests; Rust corpus oracle; full Rust runtime suite; `mdbook build docs/linkedspec-book`; Knowledge Map regenerate/check; memory/doctrine checks; `git diff --check`; `bash tools/run_ci_local.sh` | Perl now lowers exact primitive literals through a shared helper, with `true`/`false` as `JSON::PP` booleans and exact-prefix boundaries preserved. Scanner/lowerer guards treat primitive literals as explicit values in `push`, `+=`, and hash-index assignment. Rust statement-form `if/elseif/else/endif` now gates lifecycle statements so `if(false)` selects the `else` branch. Phase0 PASS (`1..980`); oracle corpus regenerated with 18 fixtures; focused Rust tests PASS (2); corpus oracle PASS over 18 fixtures; full runtime/mdBook/KM/memory/doctrine/local gates green. |
| `2026-06-29` | `SPEC-FORMAT-TERSE.1.5.3` | Syntax checks on edited Perl test/generator; focused Rust parser `.1.5.3` tests; focused Rust runtime `.1.5.3` integration test; `perl -Iperl tools/gen_oracle_corpus.pl`; Rust corpus oracle; `env PERL5LIB= prove -q -Iperl t/phase0_regression.t`; `mdbook build docs/linkedspec-book`; Knowledge Map regenerate/check; memory/doctrine checks; `git diff --check`; `bash tools/run_ci_local.sh` | Helper calls keep mandatory `callee(args)` parentheses while optional whitespace before `(` is accepted at supported statement/value sites. Perl locks spaced-vs-tight equality for `return`, `set`, nested helpers, operator RHS calls, and hash-index key/RHS calls; no-parenthesis spellings stay raw/out of helper recognition. Rust parser/runtime/oracle locks prove the same contract. Phase0 PASS (`1..981`); oracle corpus regenerated with 19 fixtures; focused Rust tests PASS; corpus oracle PASS over 19 fixtures; full runtime/mdBook/KM/memory/doctrine/local gates green. |
| `2026-06-29` | `SPEC-FORMAT-TERSE.1.5.4` | Syntax checks on edited Perl modules/test/generator; TOOLBOX lowerings and runtime probes for newline/semicolon/same-line cases; `env PERL5LIB= prove -q -Iperl t/phase0_regression.t`; `perl -Iperl tools/gen_oracle_corpus.pl`; focused Rust core separator tests; focused Rust runtime `.1.5.4` integration test; Rust corpus oracle; full Rust runtime suite; `mdbook build docs/linkedspec-book`; Knowledge Map regenerate/check; memory/doctrine checks; `git diff --check`; `bash tools/run_ci_local.sh` | Newline and semicolon are the statement separators; same-line whitespace is not. Perl `StatementSplit` only implicit-splits across line breaks, `RewritePipeline` emits generated Perl terminators for newline-separated canonical statements, and Bootstrap normalizes fluent attached-control tails with internal newlines. Rust parser/runtime locks enforce the same contract. Phase0 PASS (`1..982`); oracle corpus regenerated with 20 fixtures; focused Rust tests PASS; corpus oracle PASS over 20 fixtures; full runtime/mdBook/KM/memory/doctrine/local gates green. |
| `2026-06-29` | `SPEC-FORMAT-TERSE.1.5.5` (split) | KM retrieval; TOOLBOX `call_spec_handler_subst` probes comparing direct bracket access against `scalaref(...)`; `LinkedSpec::Get` generated-source/runtime probe for direct access; Perl code-read (`ValueExpr`, `MethodLowering`); Rust code-read (`expr.rs`, `engine.rs`); Knowledge Map regenerate/check; memory/doctrine checks; `git diff --check` | Split `.1.5.5` into `.1.5.5.1` explicit-segment direct access and `.1.5.5.2` bare path-segment / Channel 2 coordination. Direct `foo["a"][9]["b"][scalar(z)]` currently emits invalid Perl-shaped `foo["a"][9]["b"][$z]`, while `scalaref(foo,{"a"}[9]{"b"}[scalar(z)])` lowers correctly. Bare segment `z` remains a Channel 2 value-position read problem. No engine/book behavior change, so phase0/cargo/local CI are N/A to the split slice beyond doctrine/memory/KM checks. |
| `2026-06-29` | `SPEC-FORMAT-TERSE.1.5.5.1` | TOOLBOX lowerings for direct access vs `scalaref(...)`; generated-source/runtime probe; Perl syntax checks (`ValueExpr.pm`, `MethodLowering.pm`, `EmitContext.pm`, phase0, oracle generator); focused Rust parser/runtime tests; oracle regeneration; Rust corpus oracle; full phase0; full Rust runtime suite; `mdbook build docs/linkedspec-book`; Knowledge Map regenerate/check; memory/doctrine checks; `git diff --check`; `bash tools/run_ci_local.sh` | Direct nested access with explicit path segments landed. Perl lowers `foo["a"][9]["b"][scalar(z)]` to `$foo->{"a"}->[9]->{"b"}->[$z]` and leaves bare `[z]` outside canonical lowering. Rust parses mixed/multi-segment explicit paths as `NestedAccess`, preserves one-level `name[index]` as `IndexedVar`, rejects bare nested path atoms as Channel 2-reserved, and evaluates mixed hash/array paths from the scalar-held base value. Phase0/Rust/oracle/book/KM/memory/doctrine/local gates green. |
| `2026-06-29` | `SPEC-FORMAT-TERSE.1.5.5.2` | KM retrieval; TOOLBOX `call_spec_handler_subst` reverify for explicit direct access, bare direct access, `scalaref(...)`, and `return(z)`; Rust focused parser rejection lock `parse_direct_nested_access_rejects_bare_segments`; memory/doctrine/KM checks; `git diff --check` | `.1.5.5.2` is superseded into `.1.2.3`. Reverify shows `foo["a"][9]["b"][z]` and `return(z)` still share the same bare value-position-read gap, while explicit `[scalar(z)]` works. No engine/book behavior changed; the next executable frontier is `.1.2.3`, which owns the global Channel 2 design/split. |
| `2026-06-29` | `SPEC-FORMAT-TERSE.1.2.3` (split) | KM retrieval; TOOLBOX `call_spec_handler_subst` probes for scalar-like bare reads, aggregate bare reads, direct bare access, and mutation RHS/key blockers; `dump_parser_source` probes for aggregate bare reads; Perl code-read (`ValueExpr`, `MethodLowering`); Rust code-read (`expr.rs`, `engine.rs` resolver/eval paths); Knowledge Map regenerate/check; memory/doctrine checks; `git diff --check` | Split Channel 2 into aggregate and scalar value-read surfaces. Perl aggregate bare reads lower but lack auto-`my`; Rust aggregate-copy value-read resolvers keep bare reads out; Perl scalar-like reads remain bareword/raw while Rust variables already evaluate as scalar reads. No engine/book behavior change. Frontier becomes `.1.2.3.1`. |
| `2026-06-29` | `SPEC-FORMAT-TERSE.1.2.3.1` | Perl syntax checks (`EmitContext.pm`, `phase0_regression.t`); focused generated-source/runtime/no-leak probe for `array_copy(items)`, `hash_copy(meta)`, `copy(items)`; `prove -q -Iperl t/phase0_regression.t`; `mdbook build docs/linkedspec-book`; Knowledge Map regenerate/check; memory/doctrine/diff checks; `bash tools/run_ci_local.sh` | Perl aggregate bare value reads now auto-exist safely. `_collect_auto_working_var_decls` collects `array_copy(NAME)` and `copy(NAME)` as array reads and `hash_copy(NAME)` as hash reads, deduping with wrapped/declared/mutation paths and skipping reserved literals. Phase0 PASS (`1..984`, including the new 17-assertion subtest with same-parser array/hash reruns); mdBook/KM/local CI PASS. Frontier becomes `.1.2.3.2` for Rust parity. |
| `2026-06-29` | `SPEC-FORMAT-TERSE.1.2.3.2` | `cargo fmt --manifest-path rust/linkedspec-runtime/Cargo.toml`; `perl -c tools/gen_oracle_corpus.pl`; focused Rust runtime `terse_1_2_3_2`; focused Rust core `parse_direct_nested_access_rejects_bare_segments`; `perl -Iperl tools/gen_oracle_corpus.pl`; Rust corpus oracle; full Rust runtime suite; `cargo clippy --manifest-path rust/linkedspec-runtime/Cargo.toml`; phase0; mdBook; KM/memory/doctrine/diff checks; full local CI | Rust aggregate bare value reads now match the Perl reference. `array_copy(NAME)` / `copy(NAME)` resolve bare names as array working vars, `hash_copy(NAME)` resolves bare names as hash working vars, and `copy(hash(NAME))` stays the explicit hash path. Added 4 integration locks + 4 oracle fixtures; corpus oracle PASS over 25 fixtures; full runtime PASS (116 unit tests, 25 oracle fixtures, 54 integration tests); clippy EXIT 0 with existing warnings only. Scalar bare reads and bare direct-access path atoms remain deferred to `.1.2.3.3`. |
| `2026-06-29` | `SPEC-FORMAT-TERSE.1.2.3.3` (split) | KM retrieval; TOOLBOX `call_spec_handler_subst` probes for return/assignment bare reads, named hash mutation key/value slots, array append and hash-index operator blockers, direct-access path atoms, `scalaref(...)`, `scalar(container,key)`, and all-bare `push(A,B)`; Perl code-read (`ValueExpr`, `MethodLowering`, scanner, auto-var collector); Knowledge Map regenerate/check; memory/doctrine checks; `git diff --check` | Split Perl scalar bare reads by lowering seam before code. Return/assignment-like source slots remain raw barewords; mutation key/RHS forms are split because named `set_key` already lowers bare keys but not values while operator forms reject bare key/RHS tokens before lowering; direct access keeps a separate bare-segment guard and needs the scalar-index rule stated explicitly. No engine/book behavior changed. Frontier becomes `.1.2.3.3.1`. |
| `2026-06-29` | `SPEC-FORMAT-TERSE.1.2.3.3.1` | Perl syntax checks (`ValueExpr.pm`, `MethodLowering.pm`, `EmitContext.pm`, `phase0_regression.t`); TOOLBOX lowering probes; focused generated-source/runtime/no-leak probe; `prove -q -Iperl t/phase0_regression.t`; `mdbook build docs/linkedspec-book`; Knowledge Map/memory/doctrine/diff checks; full local CI | Perl scalar source-slot bare reads landed. `return(NAME)`, `set/assign(out, NAME)`, and `out = NAME` now lower to `$NAME` and auto-supply a per-invocation scalar lexical; primitive literals remain exact; deferred mutation/direct/child-call boundaries are locked. Phase0 PASS (`1..985`, 24 new assertions); mdBook updated. Frontier becomes `.1.2.3.3.2`. |
| `2026-06-29` | `SPEC-FORMAT-TERSE.1.2.3.3.2` | Perl syntax checks (`MethodLowering.pm`, `PrimitivePipelineRules.pm`, `EmitContext.pm`, `phase0_regression.t`); TOOLBOX lowering probes; `prove -q -Iperl t/phase0_regression.t`; `mdbook build docs/linkedspec-book`; Knowledge Map/memory/doctrine/diff checks; full local CI | Perl scalar mutation-slot bare reads landed. `items += VALUE`, `set_key(meta, KEY, VALUE)`, and `meta[KEY] = VALUE` now lower non-reserved bare key/RHS identifiers to `$KEY` / `$VALUE` and auto-supply per-invocation scalar lexicals, while target inference, literals, reserved engine locals, direct `[z]`, and all-bare `push(...)` child-call routing remain unchanged. Phase0 PASS (`1..986`, 29 new assertions); mdBook/KM/local CI PASS. Frontier becomes `.1.2.3.3.3`. |
| `2026-06-29` | `SPEC-FORMAT-TERSE.1.2.3.3.3` | Perl syntax checks (`ValueExpr.pm`, `EmitContext.pm`, `phase0_regression.t`); TOOLBOX lowering probes; `prove -q -Iperl t/phase0_regression.t`; `mdbook build docs/linkedspec-book`; Knowledge Map/memory/doctrine/diff checks; full local CI | Perl direct-access bare path atoms landed. `foo["a"][z]` now lowers like `foo["a"][scalar(z)]` to `$foo->{"a"}->[$z]` and auto-supplies a per-invocation scalar lexical for `z`; quoted path segments remain hash keys, numeric/helper segments remain array indexes, reserved atoms remain unclaimed, and `scalaref(...)` compatibility is unchanged. Phase0 PASS (`1..987`, 18 new assertions); mdBook/KM/memory/doctrine/local CI PASS. Frontier becomes `.1.2.3.4`. |
| `2026-06-29` | `SPEC-FORMAT-TERSE.1.2.3.4` | Focused Rust core parser tests (`parse_scalar_bare_reads_in_mutation_slots`, `parse_direct_nested_access_accepts_bare_segments`); focused Rust runtime `terse_1_2_3_4`; `perl -Iperl tools/gen_oracle_corpus.pl`; Rust corpus oracle; `mdbook build docs/linkedspec-book`; Knowledge Map/memory/doctrine/diff checks; full local CI | Rust scalar bare-read parity landed. The parser now accepts bare scalar variables in source slots, mutation key/RHS slots, and multi-segment direct-access path atoms; runtime behavior uses the existing `Expr::Variable` scalar read path. Added 2 integration locks + 3 oracle fixtures; corpus oracle PASS over 28 fixtures; mdBook/KM/memory/doctrine/local CI PASS. Frontier becomes `.1.2.3.5` for RHS-shape/type-inference split. |
| `2026-06-29` | `SPEC-FORMAT-TERSE.1.2.3.5` | Knowledge Map retrieval; TOOLBOX `call_spec_handler_subst` probes for empty and non-empty `[]`/`{}` forms; `LinkedSpec::Get` runtime/source dumps for scalar-vs-aggregate slot separation; Rust `expr.rs` code-read; Knowledge Map/memory/doctrine/diff checks | Split RHS-shape/type-inference into concrete children before code. Perl raw empty shapes work as scalar value expressions but do not initialize aggregate working variables; non-empty shapes currently need expression-aware lowering; Rust cannot parse bracket/brace value expressions. No engine/book behavior changed. Frontier becomes `.1.2.3.5.1`. |
| `2026-06-29` | `SPEC-FORMAT-TERSE.1.2.3.5.1` | Perl syntax checks (`MethodLowering.pm`, `EmitContext.pm`, `phase0_regression.t`); TOOLBOX lowering probes; generated-source/runtime shape-literal probe; `prove -q -Iperl t/phase0_regression.t`; `mdbook build docs/linkedspec-book`; Knowledge Map/memory/doctrine/diff checks | Perl shape-literal value expressions landed. `[]` / `{}` now lower as DSL values; direct shape elements, keys, and values compose with primitive literals, helper calls, direct access, nested shapes, and scalar bare reads. `{ key => value }` lowers to `{$key => $value}`, so fixed field names must be quoted. Target-kind inference was deferred to `.1.2.3.5.2`. Phase0 PASS (`988` tests); mdBook/KM/live docs updated. Frontier becomes `.1.2.3.5.2`. |
| `2026-06-29` | `SPEC-FORMAT-TERSE.1.2.3.5.2` | Perl syntax checks (`MethodLowering.pm`, `DeclareMethod.pm`, `EmitContext.pm`, `phase0_regression.t`); TOOLBOX lowering probes; generated-source/runtime array/hash/scalar-boundary probes; `prove -q -Iperl t/phase0_regression.t`; `mdbook build docs/linkedspec-book`; Knowledge Map/memory/doctrine/diff checks; full local CI | Perl RHS shape target-kind inference landed. Bare assignment targets now infer aggregate kind from direct RHS shapes: `name = [value]` / `set(name, [])` assign `@name`, and `name = { key => value }` / `assign(name, {})` assign `%name`; explicit `scalar(name)` keeps scalar payload assignment. Declaration initializer shapes now lower direct members before unwrapping. Phase0 PASS (`989` tests); full local CI PASS. Frontier becomes `.1.2.3.5.3`. |
| `2026-06-29` | `SPEC-FORMAT-TERSE.1.2.3.5.3` | Focused Rust core parser tests (`cargo test --quiet --manifest-path rust/Cargo.toml -p linkedspec-core shape_literal`); focused Rust runtime tests (`cargo test --quiet --manifest-path rust/Cargo.toml -p linkedspec-runtime terse_1_2_3_5_3`); `perl -Iperl tools/gen_oracle_corpus.pl`; Rust corpus oracle (`cargo test --quiet --manifest-path rust/Cargo.toml -p linkedspec-runtime oracle_corpus_matches_perl_reference`); mdBook build; Knowledge Map regenerate/check; memory/doctrine/diff checks; full local CI | Rust shape-literal value parity landed. `Expr::ArrayLiteral` / `Expr::HashLiteral` parse direct `[]` / `{}` values recursively, and `Engine::eval_expr` evaluates members through the normal expression path into `RuntimeValue::Array` / `RuntimeValue::Hash`. Added parser/runtime boundary locks plus two oracle fixtures, bringing the corpus oracle to 30 fixtures. `name = [value]` still parses/evaluates as scalar payload assignment until `.1.2.3.5.4` implements Rust target-kind inference. Frontier becomes `.1.2.3.5.4`. |
| `2026-06-29` | `SPEC-FORMAT-TERSE.1.2.3.5.4` | Focused Rust runtime tests (`cargo test --quiet --manifest-path rust/Cargo.toml -p linkedspec-runtime terse_1_2_3_5_4`); `perl -Iperl tools/gen_oracle_corpus.pl`; Rust corpus oracle (`cargo test --quiet --manifest-path rust/Cargo.toml -p linkedspec-runtime oracle_corpus_matches_perl_reference`); mdBook build; Knowledge Map regenerate/check; memory/doctrine/diff checks; full local CI | Rust RHS shape target-kind inference parity landed. Direct array/hash RHS literals now replace the runtime aggregate slot for bare or matching typed aggregate targets (`items = [value]`, `set(array(items), [value])`, `meta = { key => value }`, `set(hash(meta), { key => value })`), while explicit `scalar(payload)` keeps scalar-held shape payload assignment. Added 3 integration locks + 2 oracle fixtures, bringing the corpus oracle to 32 fixtures. Frontier becomes `.1.6`. |
| `2026-06-29` | `SPEC-FORMAT-TERSE.1.6` | Perl syntax checks (`MethodLowering.pm`, `Contracts.pm`, `Scanner/PrimitivePipelineRules.pm`, `RuleIR/EmitContext.pm`); TOOLBOX lowering/runtime/source probes; focused Rust core parser test (`parse_array_end_mutation_fluent_receivers`); focused Rust runtime tests (`cargo test --quiet --manifest-path rust/Cargo.toml -p linkedspec-runtime terse_1_6`); `perl -Iperl tools/gen_oracle_corpus.pl`; Rust corpus oracle (`cargo test --quiet --manifest-path rust/Cargo.toml -p linkedspec-runtime oracle_corpus_matches_perl_reference`); `prove -q -Iperl t/phase0_regression.t` | Array end-mutation methods landed. Perl lowers statement-level `push_back`/`push_front`/`pop_back`/`pop_front` receiver-dot calls to array working-variable mutations, records canonical `ARRAY_MUTATE`, and auto-supplies the receiver array plus push-value scalar reads. Rust executes the same statement forms in `Engine::execute_block`; pop methods discard the removed value. Oracle corpus regenerated to 33 fixtures; phase0 PASS (`990` tests). Round 1 is closed and the frontier becomes `.2.1`. |
| `2026-06-29` | `SPEC-FORMAT-TERSE.2.1.1` (split) | KM retrieval (`spec-format-brainstorm-rounds-1-3`, `terse-statement-separator-contract`, `terse-array-end-mutation-methods`, `rust-retv-propagation`, `actionir-lowering-stack`); TOOLBOX `call_spec_handler_subst` probes for `{}` / `{ key => value }` / block-shaped values; `LinkedSpec::Get` runtime and generated-source probes; Perl code-read (`MethodLowering`, `EmitContext`); Rust code-read (`expr.rs`, `engine.rs`); Knowledge Map regenerate/check; memory/doctrine/diff checks | Split `.2.1` before code. Current Perl supports hash shape literals but block-shaped values lower into invalid hash/block Perl (`return { $x = "a"; x }`) or aggregate target inference (`%out = (...)`); Rust has statement `CodeBlock` and hash/array literal values but no block-expression AST/runtime. Frontier becomes `.2.1.2` for the Perl reference core; Rust parity and full block-local early return stay split. |
| `2026-06-29` | `SPEC-FORMAT-TERSE.2.1.2` | Perl syntax checks (`MethodLowering.pm`, `RuleIR/EmitContext.pm`, `phase0_regression.t`); TOOLBOX lowering/runtime probes; `prove -q -Iperl t/phase0_regression.t`; mdBook build; Knowledge Map regenerate/check; memory/doctrine/diff checks; `tools/run_ci_local.sh` | Perl-reference core expression-valued blocks landed. Non-empty non-hash brace payloads lower as `do { ... }` values in return payloads, assignment sources, and nested value payloads; final `return(expr)` inside the block is block-local for this core subset. `{}` and `{ key => value }` remain hash literals, and hash literal final expressions are forced as scalar hashrefs inside block values. Phase0 PASS (`991` tests). Full local CI PASS. Frontier becomes `.2.1.3` Rust parity. |
| `2026-06-29` | `SPEC-FORMAT-TERSE.2.1.3` (ownership) | KM retrieval (`terse-expression-valued-blocks-ground-truth`, `terse-perl-expression-valued-blocks`); Rust code-read (`Expr`, `parse_expr()`, `parse_hash_literal()`, `execute_block()`, `eval_expr()`); mdBook build; Knowledge Map regenerate/check; memory/doctrine/diff checks | Rust expression-valued block parity owned before code. Rust currently has statement-only `CodeBlock`, hash/array value expressions, and no block-value `Expr` or evaluator. `{}` and keyed `=>` hash literals must keep precedence; non-empty non-fat-arrow braces become block values in the implementation slice. Frontier remains `.2.1.3` implementation. |
| `2026-06-29` | `SPEC-FORMAT-TERSE.2.1.3` | Focused Rust core parser tests (`cargo test --quiet --manifest-path rust/Cargo.toml -p linkedspec-core expression_valued_block`); focused Rust runtime tests (`cargo test --quiet --manifest-path rust/Cargo.toml -p linkedspec-runtime terse_2_1_3`); `perl -Iperl tools/gen_oracle_corpus.pl`; Rust corpus oracle (`cargo test --quiet --manifest-path rust/Cargo.toml -p linkedspec-runtime oracle_corpus_matches_perl_reference`); full Rust core package; full Rust runtime package; `mdbook build docs/linkedspec-book`; Knowledge Map regenerate/check; memory/doctrine/diff checks; `bash tools/run_ci_local.sh` | Rust expression-valued block parity landed. `Expr::BlockValue` plus `parse_brace_expr()` preserve hash literals and parse non-empty non-fat-arrow braces as block values; runtime `eval_block_value()` returns the final expression or final `return(expr)` payload. Added `terse_2_1_3_expression_valued_blocks`, bringing the oracle corpus to **34 fixtures**. Full local CI PASS (`991` phase0 tests). Frontier becomes `.2.1.4`. |
| `2026-06-30` | `SPEC-FORMAT-TERSE.2.1.4` | Perl syntax checks (`MethodLowering.pm`, phase0, oracle generator); TOOLBOX lowering/runtime probes for non-final `return(expr)` block values; focused Rust runtime tests (`cargo test --quiet --manifest-path rust/Cargo.toml -p linkedspec-runtime terse_2_1_4_expression_valued_block`); `perl -Iperl tools/gen_oracle_corpus.pl`; Rust corpus oracle; phase0; mdBook build; Knowledge Map regenerate/check; memory/doctrine/diff checks; full local CI | Block-local early `return(expr)` landed for expression-valued blocks on Perl and Rust. Perl emits a guarded `do { ... }` value wrapper for blocks with a non-final return and keeps compact output for existing core forms. Rust `eval_block_value()` now returns an active `return(expr)` payload immediately without setting the rule return channel. Added `terse_2_1_4_expression_valued_block_early_return`, bringing the oracle corpus to **35 fixtures**. Frontier becomes `.2.2`. |
| `2026-06-30` | `SPEC-FORMAT-TERSE.2.2.1` (split) | KM retrieval (`spec-format-brainstorm-rounds-1-3`, `terse-statement-separator-contract`, `terse-primitive-literal-parity`, `scanner-rule-family-architecture`); TOOLBOX `call_spec_handler_subst` probes for attached `if`, `when`/`otherwise`, `while`, and attached `switch`; `LinkedSpec::Get(..., return_descriptor => 1)` metadata probes for ActionIR readiness/raw fallback; Perl code-read (`ControlFlow.pm`, `FlowExpr.pm`, `Scanner/FlowRules.pm`); Rust code-read (`expr.rs`, `engine.rs`); focused Rust parser test `parse_lifecycle_block_content` | Split `.2.2` before code. At split time, the contract was believed to be statement-marker `if(cond); ... elseif(cond); else(); ... endif()` plus inline-composite lazy `if`/`switch`; `.2.3.4` later corrected the inline value-control portability boundary and split Perl value lowering to `.2.3.4.2`. Perl attached `if`, `when`/`otherwise`, and `while` were not ActionIR-ready; Rust had no attached statement-block parser/runtime for the new keyword surface. mdBook/KM/live docs aligned; frontier became `.2.2.2`. |
| `2026-06-30` | `SPEC-FORMAT-TERSE.2.2.2` | Perl syntax checks; TOOLBOX compact attached-if lowering/metadata/runtime probes; phase0 (`prove -q -Iperl t/phase0_regression.t`); mdBook build; Knowledge Map regenerate/check; memory/doctrine/diff checks; full local CI | Perl attached-block `if/elseif/else` landed. `StatementSplit::Core` splits compact same-line `} elseif/else {` branch continuations so the existing ActionIR control-flow lowering can emit the selected branch without raw fallback. Frontier becomes `.2.2.3` Rust parity. |
| `2026-06-30` | `SPEC-FORMAT-TERSE.2.2.3` | Focused Rust core parser tests (`cargo test --quiet --manifest-path rust/Cargo.toml -p linkedspec-core attached_if`); focused Rust runtime tests (`cargo test --quiet --manifest-path rust/Cargo.toml -p linkedspec-runtime terse_2_2_3`); `perl tools/gen_oracle_corpus.pl`; Rust corpus oracle; mdBook build; Knowledge Map regenerate/check; memory/doctrine/diff checks | Rust attached-block `if/elseif/else` parity landed. `CodeBlock::parse` normalizes attached branch bodies into the existing marker-control sequence and reuses `handle_statement_if_control` at runtime. Added oracle fixture `terse_2_2_3_attached_if_blocks`, bringing the corpus to **36 fixtures**. Attached `if` is now portable on Perl and Rust; frontier becomes `.2.2.4` for `when/otherwise`. |
| `2026-06-30` | `SPEC-FORMAT-TERSE.2.2.4` (ownership) | KM retrieval (`terse-control-flow-keyword-surface-ground-truth`, `spec-format-brainstorm-rounds-1-3`); TOOLBOX lowering/descriptor/runtime/generated-source probes for `when/otherwise`; Perl flow code-read (`StatementSplit::Core`, `Scanner::FlowRules`, `Contracts`, `ControlFlow`); Rust code-read (`expr.rs`, `engine.rs`) | Owned `when/otherwise` before code. Current Perl leaves the combined form raw, warns via host experimental `when`, and returns the wrong branch for the true-condition probe. Implementation should normalize `when(cond)` to attached `if(cond)` and `otherwise` to attached `else`, reusing existing Perl control-flow lowering and Rust marker-gating runtime. Frontier remains `.2.2.4` implementation. |
| `2026-06-30` | `SPEC-FORMAT-TERSE.2.2.4` | Perl syntax checks; TOOLBOX lowering/descriptor/runtime/generated-source probe; focused Rust core parser test (`cargo test --quiet --manifest-path rust/Cargo.toml -p linkedspec-core when_otherwise`); focused Rust runtime test (`cargo test --quiet --manifest-path rust/Cargo.toml -p linkedspec-runtime terse_2_2_4`); `perl -Iperl tools/gen_oracle_corpus.pl`; Rust corpus oracle; `prove -q -Iperl t/phase0_regression.t`; mdBook build; Knowledge Map/memory/doctrine/diff checks; full local CI | `when/otherwise` aliases landed. Perl recognizes the aliases in statement splitting, scanner/contract matching, and `ControlFlow` lowering, while avoiding host Perl `when`. Rust parser normalizes attached `when` / `otherwise` branches to existing `if` / `else` / `endif` statements and reuses the runtime branch engine. Oracle corpus now has **37 fixtures**. Phase0 PASS (`Files=1, Tests=991`); full local CI PASS. Frontier becomes `.2.2.5`. |
| `2026-06-30` | `SPEC-FORMAT-TERSE.2.2.5` (split/ownership) | KM retrieval (`terse-control-flow-keyword-surface-ground-truth`, `terse-statement-separator-contract`, `spec-format-brainstorm-rounds-1-3`); TOOLBOX descriptor/lowering/runtime probes for attached `switch/case/default`; Perl code-read (`ControlFlow.pm`, `StatementSplit::Core`); Rust code-read (`expr.rs`, `engine.rs`); focused Rust value-form switch tests | Split and owned attached `switch/case/default` before code. Perl has partial attached-switch machinery, but adjacent branch blocks without explicit separators can leave unresolved `case` residue or host-like `default` labels in generated source. Rust has lazy value-form `switch` runtime support but no attached `switch/case/default` statement parser. Frontier becomes `.2.2.5.1` for the Perl separator/source lock, then `.2.2.5.2` Rust parity. |
| `2026-06-30` | `SPEC-FORMAT-TERSE.2.2.5.1` | Perl syntax checks; TOOLBOX descriptor/lowering/runtime/generated-source probes for compact attached switch; `prove -q -Iperl t/phase0_regression.t`; mdBook build; Knowledge Map regenerate/check; memory/doctrine/diff checks; full local CI | Perl attached `switch/case/default` separator/source lock landed. `StatementSplit::Core` now splits adjacent attached `case/default` branches so descriptor metadata reports `ready=1 raw=0 unresolved=0`, generated handlers have no host-shaped branch residue, runtime selects first/later/default branches correctly, and a same-line statement after the final switch still requires `;`. Phase0 PASS (`Files=1, Tests=991`); full local CI PASS. Frontier becomes `.2.2.5.2` Rust parity. |
| `2026-06-30` | `SPEC-FORMAT-TERSE.2.2.5.2` | Perl syntax checks; phase0 (`prove -q -Iperl t/phase0_regression.t`); focused Rust core parser tests (`cargo test -p linkedspec-core attached_switch -- --nocapture` from `rust/`); focused Rust runtime tests (`cargo test -p linkedspec-runtime terse_2_2_5_2 -- --nocapture` from `rust/`); lazy value-form switch regression (`cargo test -p linkedspec-runtime cond_switch -- --nocapture` from `rust/`); `perl -Iperl tools/gen_oracle_corpus.pl`; Rust corpus oracle; mdBook build; Knowledge Map regenerate/check; memory/doctrine/diff checks; full local CI | Rust attached `switch/case/default` parity landed. `CodeBlock::parse` normalizes attached switch branch bodies to statement controls, `Engine` gates them with a switch stack beside statement-if gating, inactive branch side effects are skipped, lazy value-form switch remains intact, and the oracle corpus now has **38 fixtures**. Phase0 PASS (`Files=1, Tests=991`); full local CI PASS. Frontier becomes `.2.2.6` (`while`). |
| `2026-06-30` | `SPEC-FORMAT-TERSE.2.2.6` (split/ownership) | KM retrieval (`terse-control-flow-keyword-surface-ground-truth`, `spec-format-brainstorm-rounds-1-3`, `top-rule-recursion-forward-progress-guard`); TOOLBOX lowering/descriptor probes for `while(false) { ... }` and `while(true) { ... }`; Perl code-read (`ControlFlow.pm`, `Contracts.pm`, `Scanner/FlowRules.pm`, `StatementSplit::Core`); Rust code-read (`expr.rs`, `engine.rs`) | Split and owned attached `while(cond) { ... }` before code. Perl currently lowers the attached form as raw host code (`ready=0 raw=1 fallback=1 unresolved=0`), while Rust has no attached statement-loop parser/runtime. Frontier becomes `.2.2.6.1` for the Perl reference loop/safety contract; `.2.2.6.2` will provide Rust parity. |
| `2026-06-30` | `SPEC-FORMAT-TERSE.2.2.6.1` | Perl syntax checks; TOOLBOX lowering/descriptor/runtime/generated-source probes; `prove -q -Iperl t/phase0_regression.t`; mdBook build; Knowledge Map regenerate/check; memory/doctrine/diff checks; full local CI | Perl attached `while(cond) { ... }` loop/safety landed. `ControlFlow` lowers attached while through ActionIR as a guarded host loop, scanner/contract/canonical metadata report `WHILE`, counted loops re-evaluate conditions, `return(expr)` keeps rule/action return semantics, and non-terminating loops hit the deterministic 10000-iteration guard. Phase0 PASS (`Files=1, Tests=992`); full local CI PASS. Frontier becomes `.2.2.6.2` Rust parity. |
| `2026-06-30` | `SPEC-FORMAT-TERSE.2.2.6.2` | Focused Rust core parser tests (`cargo test --quiet --manifest-path rust/linkedspec-core/Cargo.toml attached_while`); focused Rust runtime tests (`cargo test --quiet --manifest-path rust/linkedspec-runtime/Cargo.toml terse_2_2_6_2`); full Rust core/runtime package tests; oracle generator syntax/regeneration; Rust corpus oracle; mdBook build; Knowledge Map regenerate/check; memory/doctrine/diff checks; full local CI | Rust attached `while(cond) { ... }` parity landed. `expr.rs` parses attached while as a lazy loop over a parsed body block, `engine.rs` re-evaluates conditions and executes bodies with normal statement semantics, expression-valued blocks keep block-local `return(expr)`, and non-terminating loops use the same 10000-iteration safety diagnostic as Perl. Added oracle fixture `terse_2_2_6_2_attached_while_blocks`, bringing the corpus to **39 fixtures**. Frontier becomes `.2.3`. |
| `2026-06-30` | `SPEC-FORMAT-TERSE.2.3` (split/ownership) | KM retrieval (`spec-format-brainstorm-rounds-1-3`, `terse-control-flow-keyword-surface-ground-truth`, `method-like-dsl-migration-status`, `terse-array-end-mutation-methods`, `rust-perl-output-oracle`); TOOLBOX descriptor/runtime probes for exact action and lifecycle `.when(cond) { ... }.otherwise { ... }`; lifecycle block value/return probes; nested-helper and receiver-dot value-method probes; Perl code-read (`BootstrapSpec::Core`, `ActionIR::ControlFlow`); Rust code-read (`expr.rs`, `parser.rs`, `compiler.rs`, `engine.rs`) | Split and owned `.2.3` before code. Perl already accepts exact fluent block-chain forms on action and lifecycle surfaces with `ready=1 raw=0 fallback=0 unresolved=0`; Rust attached statement blocks are portable, but fluent attached-block payloads/action-edge continuations are not. Lifecycle blocks need a separate value-drop/return-channel lock. Full composability and return-type method chaining are separate surfaces; array end mutations remain statement-only. Frontier becomes `.2.3.1`. |
| `2026-06-30` | `SPEC-FORMAT-TERSE.2.3.1` | TOOLBOX false-branch reverify for dotted and no-dot fluent `otherwise`; Perl syntax checks (`perl -c perl/LinkedSpec/BootstrapSpec/Core.pm`, `perl -c t/phase0_regression.t`); phase0 (`prove -q -Iperl t/phase0_regression.t`); mdBook build; Knowledge Map regenerate/check; memory/doctrine/diff checks | Perl reference fluent `when/otherwise` block chains landed. The bootstrap parser now preserves attached fallback tails after `.when(...) { ... }`, with or without the dot before `otherwise`. New phase0 locks prove action-edge and lifecycle false-branch fallback execution, descriptor cleanliness (`ready=1 fallback=0 raw=0 unresolved=0`), and no generated host `when`/`otherwise` residue. Phase0 PASS (`Files=1, Tests=993`). Frontier becomes `.2.3.2`. |
| `2026-06-30` | `SPEC-FORMAT-TERSE.2.3.2` | Perl syntax check (`perl -c t/phase0_regression.t`); phase0 (`prove -q -Iperl t/phase0_regression.t`); focused Rust runtime (`cargo test --quiet --manifest-path rust/linkedspec-runtime/Cargo.toml terse_2_3_2`); mdBook build; Knowledge Map regenerate/check; memory/doctrine/diff checks; full local CI | Lifecycle block value/drop semantics are locked. Phase0 source-locks all seven lifecycle markers and runtime-locks final ordinary statement discard, top-level Perl lifecycle return-channel behavior, and expression-valued block-local return contrast. Rust focused tests lock statement-value discard, top-level lifecycle return-event recording, and expression-block local return. Phase0 PASS (`Files=1, Tests=994`); full local CI PASS. Frontier becomes `.2.3.3`. |
| `2026-06-30` | `SPEC-FORMAT-TERSE.2.3.3.1` | Focused Rust core (`cargo test --quiet --manifest-path rust/linkedspec-core/Cargo.toml fluent_chain`); focused Rust runtime (`cargo test --quiet --manifest-path rust/linkedspec-runtime/Cargo.toml terse_2_3_3_1 -- --nocapture`); full Rust core/runtime package tests; `perl -c tools/gen_oracle_corpus.pl`; mdBook build; Knowledge Map regenerate/check; memory/doctrine/diff checks; full local CI | Rust action-edge fluent continuations landed. `ActionEdge` / `AcodeEntry` now carry fluent-chain metadata and runtime dispatch executes no-arg `.push`, `.return(expr)`, and `.return_undef` with parent-visible return-channel semantics. Focused locks cover child return capture, child return-event suppression, close-edge return without recursive child redispatch, and `.return_undef` without an accumulator event. Full local CI PASS (`Files=1, Tests=994`). `tclite` oracle remains deferred behind compact lifecycle/body fluent forms and default-mode repetition parity. Frontier becomes `.2.3.3.2`. |
| `2026-06-30` | `SPEC-FORMAT-TERSE.2.3.3.2` | Focused Rust core (`cargo test --quiet --manifest-path rust/linkedspec-core/Cargo.toml attached_fluent -- --nocapture`); focused Rust runtime (`cargo test --quiet --manifest-path rust/linkedspec-runtime/Cargo.toml terse_2_3_3_2 -- --nocapture`); full Rust core/runtime package tests; mdBook build; Knowledge Map regenerate/check; memory/doctrine/diff checks; full local CI | Rust attached fluent block payloads landed. The Rust body parser now normalizes action-edge and lifecycle `.when(cond) { ... }` receiver-fluent block chains to existing attached statement blocks, accepts dotted and no-dot `otherwise` fallback tails, and preserves multiline fallback payloads after `}.otherwise {`. Focused runtime locks cover both fallback spellings on both action-edge and lifecycle surfaces. Full local CI PASS (`Files=1, Tests=994`). Frontier becomes `.2.3.3.3`. |
| `2026-06-30` | `SPEC-FORMAT-TERSE.2.3.3.3` | KM retrieval; Perl reference probes for compact lifecycle and action-edge fluent forms; shipped-spec/code search (`I.return`, `I.declare(...).return(...)`, action-edge `.push(...)`); Rust parser/compiler/runtime code-read; focused Rust `.2.3.3.2` regression test | Split remaining Rust fluent continuation work before code. Lifecycle/body receiver chains are dropped through standalone `BodyElementKind::FluentChain`; action-edge metadata exists but only no-arg `.push` / `.return(expr)` / `.return_undef` execute; `tclite` re-enable waits until those fluent children land and then gets its own default-mode repetition audit if still divergent. Frontier becomes `.2.3.3.3.1`. |
| `2026-06-30` | `SPEC-FORMAT-TERSE.2.3.3.3.1` | Focused Rust core (`cargo test --quiet --manifest-path rust/linkedspec-core/Cargo.toml lifecycle_compact -- --nocapture`); focused Rust runtime (`cargo test --quiet --manifest-path rust/linkedspec-runtime/Cargo.toml terse_2_3_3_3_1 -- --nocapture`); full Rust core/runtime package tests; mdBook build; oracle generator syntax; Knowledge Map regenerate/check; memory/doctrine/diff checks; full local CI; rustfmt on touched Rust files | Rust compact lifecycle/body receiver chains landed. The Rust parser now normalizes lifecycle-marker receiver chains such as `I.return(...)` and `I.declare(...).set(...).return(...)` into lifecycle `CodeBlock` statement strings instead of leaving a dropped standalone `FluentChain`. Parser locks cover multiline body and regex-first header-line inline placement with no surviving lifecycle-surface `FluentChain`; compiler locks prove compact `I`/`E` chains populate lifecycle code slots; runtime locks prove return-channel behavior and ordered declaration/mutation execution. Full local CI PASS. Frontier becomes `.2.3.3.3.2`. |
| `2026-06-30` | `SPEC-FORMAT-TERSE.2.3.3.3.2` | Perl reference probes for shipped `ebnf.spec` action-edge fluent forms; focused Rust core parser (`cargo test --quiet --manifest-path rust/linkedspec-core/Cargo.toml parse_action_edge_multiline_fluent_flow_chain -- --nocapture`) and compiler (`cargo test --quiet --manifest-path rust/linkedspec-core/Cargo.toml compile_multiline_action_edge_fluent_flow_chain -- --nocapture`); focused Rust runtime (`cargo test --quiet --manifest-path rust/linkedspec-runtime/Cargo.toml terse_2_3_3_3_2 -- --nocapture`); no-arg action-edge regression (`cargo test --quiet --manifest-path rust/linkedspec-runtime/Cargo.toml terse_2_3_3_1_action_edge_fluent_push_appends_child_return -- --nocapture`); full Rust core/runtime package tests; mdBook build; oracle generator syntax; Knowledge Map regenerate/check; memory/doctrine/diff checks; full local CI | Rust action-edge explicit/flow fluent chains landed. The Rust parser now keeps multiline dotted action-edge continuations on the preceding edge; the runtime executes `.push(target)`, `.push(child,target)`, `.if/.else/.endif` gating, `.say(...)`, `.return(expr)`, and `.return_undef()` with parent-visible child return-channel semantics. Full local CI PASS. Frontier becomes `.2.3.3.3.3`. |
| `2026-06-30` | `SPEC-FORMAT-TERSE.2.3.3.3.3` | Perl reference probes for `tclite` inputs `[]` and `""`; temporary `tools/gen_oracle_corpus.pl` re-enable of `tclite_command_subst` and `tclite_double_quote`; diagnostic Rust corpus oracle run (`cargo test --quiet --manifest-path rust/linkedspec-runtime/Cargo.toml --test corpus_oracle -- --nocapture`); committed green-corpus restoration; oracle generator syntax/regeneration; Rust corpus oracle; mdBook build; Knowledge Map regenerate/check; memory/doctrine/diff checks; full local CI | Rust `tclite` retry after fluent parity split to implementation. Perl returns tagged `tcl_script` values for both inputs, but Rust still returns `[]` for the two temporarily re-enabled fixtures while the other 39 fixtures pass. The remaining blocker is default-mode recursive repetition/top-level default-rule dispatch parity, not fluent-continuation support. Failing fixtures stay out of the committed corpus until `.2.3.3.3.3.1`; frontier becomes `.2.3.3.3.3.1`. |
| `2026-06-30` | `SPEC-FORMAT-TERSE.2.3.3.3.3.1` | KM/toolbox probes for Perl `tclite` and minimal edge-only grammars; focused Rust core (`cargo test --quiet --manifest-path rust/linkedspec-core/Cargo.toml compile_default_mode_is_zero_min_repeated_choice -- --nocapture`); focused Rust runtime (`cargo test --quiet --manifest-path rust/linkedspec-runtime/Cargo.toml default_mode_repeats_action_edge_choices_and_allows_zero_matches -- --nocapture`); lifecycle expectation locks (`terse_2_3_2_lifecycle_return_records_surrounding_rule_return`, `terse_2_3_3_3_1`); capture-helper regression families (`helpers_5_5_3`, `helpers_5_5_4`); `perl -c tools/gen_oracle_corpus.pl`; `perl -Iperl tools/gen_oracle_corpus.pl`; Rust corpus oracle; mdBook build; Knowledge Map regenerate/check; memory/doctrine/diff checks; full local CI | Rust default-mode recursive repetition parity landed. `RuleMode::Default` now compiles as zero-min repeated choice, and Rust exits immediately after an `I`/preamble return before local entry-regex re-matching. One-match capture-helper/lifecycle-order tests now spell `OR{1,1}` explicitly; `tclite_command_subst` and `tclite_double_quote` are active oracle fixtures; corpus oracle PASS over 41 fixtures. Frontier becomes `.2.3.4`. |
| `2026-06-30` | `SPEC-FORMAT-TERSE.2.3.4` | KM retrieval; TOOLBOX lowering/runtime/generated-source probes for deep pure helpers, bare aggregate helper arguments, inline value `if`/`switch`, and receiver-dot method value/chaining; Rust parser/runtime code-read; diagnostic Rust corpus oracle with bare `merge_hash(..., overlay)`; final `perl -Iperl tools/gen_oracle_corpus.pl`; final Rust corpus oracle (`cargo test --quiet --manifest-path rust/linkedspec-runtime/Cargo.toml --test corpus_oracle -- --nocapture`) | Full composability audit split unsupported surfaces before code. Pure helper nesting is portable with explicit aggregate wrappers and is now locked by `terse_2_3_4_deep_pure_helper_composition`; final corpus oracle PASS over 42 fixtures. Diagnostic bare `overlay` in `merge_hash(hash_copy(base), overlay)` returned Perl `2` but Rust `1`, so `.2.3.4.1` owns Rust helper-context aggregate bare reads. Perl generated-source probes for inline value `if`/`switch` show selected branch values are not returned and nested helper forms can fail handler compilation, so `.2.3.4.2` owns that reference fix. Frontier becomes `.2.3.4.1`. |
| `2026-06-30` | `SPEC-FORMAT-TERSE.2.3.4.1` | Focused Rust runtime (`cargo test --quiet --manifest-path rust/linkedspec-runtime/Cargo.toml terse_2_3_4_1 -- --nocapture`); oracle generator (`perl -Iperl tools/gen_oracle_corpus.pl`); Rust corpus oracle (`cargo test --quiet --manifest-path rust/linkedspec-runtime/Cargo.toml --test corpus_oracle -- --nocapture`) | Rust helper-context bare aggregate arguments landed. `hash_consuming_arg(...)` and `array_consuming_arg(...)` promote bare names to aggregate snapshots only in helper slots whose callee contract implies that aggregate kind; `merge_hash(hash_copy(base), overlay)` now matches the explicit `hash(overlay)` wrapper, and `count(drop_front(sorted(items)))` matches the Perl oracle. Added `terse_2_3_4_1_bare_hash_helper_arg_composition` and `terse_2_3_4_1_bare_array_helper_arg_composition`; corpus oracle PASS over 44 fixtures. Frontier becomes `.2.3.4.2`. |
| `2026-06-30` | `SPEC-FORMAT-TERSE.2.3.4.2` | Perl syntax checks for changed ActionIR modules and oracle generator; focused Perl lowering/runtime probes for inline `if`/`switch` return, assignment RHS, nested predicates, expression-valued block branches, and fluent `.return(...)`; phase0 (`prove -q -Iperl t/phase0_regression.t`); oracle generator (`perl -Iperl tools/gen_oracle_corpus.pl`); Rust corpus oracle (`cargo test --quiet --manifest-path rust/linkedspec-runtime/Cargo.toml --test corpus_oracle -- --nocapture`) | Perl inline value-control lowering landed. `if(...)` and `switch(...)` now return selected branch payloads in supported value positions; inline branch payloads compose with helpers and expression-valued blocks; fluent checks assert payload values without requiring a specific compatibility tag string. Added `terse_2_3_4_2_inline_if_value_control` and `terse_2_3_4_2_inline_switch_value_control`; phase0 PASS with 995 tests and corpus oracle PASS over 46 fixtures. Frontier becomes `.2.3.5`. |

## Commit Log

| Leaf | Commit subject or reference | Notes |
| --- | --- | --- |
| `SPEC-FORMAT-TERSE.2.3.5` | `SPEC-FORMAT-TERSE.2.3.5 - split return-type method chaining` | Return-type method chaining specified before code and split into array/hash/string/number receiver-family leaves. No runtime behavior changed; first implementation frontier is `.2.3.5.1` array receiver-dot value chains. |
| `SPEC-FORMAT-TERSE.2.3.5.1` | `SPEC-FORMAT-TERSE.2.3.5.1 - implement array receiver value chains` | Array receiver-dot value chains landed on Perl/Rust with phase0, focused Rust tests, oracle corpus, mdBook, and KM locks. Frontier becomes `.2.3.5.2`. |
| `SPEC-FORMAT-TERSE.2.3.5.2` | `SPEC-FORMAT-TERSE.2.3.5.2 - implement hash receiver value chains` | Hash receiver-dot value chains landed on Perl/Rust with focused tests, oracle corpus, mdBook, and KM locks. Frontier becomes `.2.3.5.3`. |
| `SPEC-FORMAT-TERSE.2.3.5.3` | `SPEC-FORMAT-TERSE.2.3.5.3 - implement string receiver value chains` | String receiver-dot value chains landed on Perl/Rust with phase0, focused Rust tests, oracle corpus, mdBook, and KM locks. Frontier becomes `.2.3.5.4`. |
| `SPEC-FORMAT-TERSE.2.3.5.4` | `SPEC-FORMAT-TERSE.2.3.5.4 - implement number receiver value chains` | Number receiver-dot value chains landed on Perl/Rust with phase0, focused Rust tests, oracle corpus, mdBook, and KM locks. `declare(...)` and other statement/lifecycle methods stay outside receiver methods. Frontier becomes `.2.3.5.5`. |
| `SPEC-FORMAT-TERSE.2.3.5.6` | `SPEC-FORMAT-TERSE.2.3.5.6 - lock aggregate wrapper quoting boundaries` | Bare aggregate wrapper arguments remain typed working-variable reads; quoted wrapper arguments remain constructor payloads; direct `[...]` / `{...}` shapes are the preferred terse constructors. Phase0 1000 green; oracle corpus 51 fixtures; frontier returns to `.2.3.5.5`. |
| `SPEC-FORMAT-TERSE` (creation) | (in the `SPEC-FORMAT-TERSE.0` activation commit) | Tree was created `proposed` in an earlier session; first commit lands with `.0`. |
| `SPEC-FORMAT-TERSE.0` | `SPEC-FORMAT-TERSE.0 — activate + ratify the terse .spec format direction (ADR 0007)` | Tree `proposed`→`active`; ADR `0007` + INDEX row; migration policy = gradual alias; reference-touching exception; implementation gated by `RTLUTILS-REGEX-HANG`. No engine/book change. |
| `SPEC-FORMAT-TERSE.1.1` (split) | `SPEC-FORMAT-TERSE.1.1 — split into .1.1.1 (Perl) + .1.1.2 (Rust parity); record auto-existing-variable design + KM card` | `.1.1` → container; first frontier child `.1.1.1`. Design grounded by `dump_parser_source` probes; KM [[working-vars-no-strict-need-my-lexical]]. Docs/tree/KM-only — no engine/book change. |
| `SPEC-FORMAT-TERSE.1.1.1` | `SPEC-FORMAT-TERSE.1.1.1 — Perl auto-existing working variables (engine + book + 3 phase0 locks)` | Collector `_collect_auto_working_var_decls` in `RuleIR/EmitContext.pm` (+ `_mask_action_code_literals`) → `auto_var_decls`; preamble injection in `SpecEntry::compile_spec_entry`. 19/20 specs byte-identical (tkgui +1 legit `my`, behavior-preserved); +3 phase0 locks → 968; gate EXIT 0; book taught (declare optional). |
| `SPEC-FORMAT-TERSE.1.1.2` | `SPEC-FORMAT-TERSE.1.1.2 — Rust lockstep parity for auto-existing variables (oracle + integration locks; no engine change)` | Assessed DOABLE: Rust interpreter's per-parse `RuntimeContext` HashMaps already auto-vivify working vars (no `declare` needed) and are fresh per `execute` (no leak) — no Perl-style leaky-global hazard, so no engine code change. Locked with 5 `autoexist_*` oracle fixtures (`tools/gen_oracle_corpus.pl`) + 4 `terse_1_1_2_*` integration tests; cargo 244→248 green, 7/7 oracle fixtures PASS, clippy zero-new, phase0 968 green (Perl untouched), gate EXIT 0. `.1.1` container done. Recursive/REP idiom deferred to `RUST-PARITY`. KM card [[rust-working-vars-auto-vivify]]. |
| `SPEC-FORMAT-TERSE.1.2` (split) | `SPEC-FORMAT-TERSE.1.2 — split into .1.2.1 (Perl, Channel 1) + .1.2.2 (Rust parity); record bare-working-var ground truth + KM card` | `.1.2` → container after a `dump_parser_source` ground-truth pass: a bare working var has two inference channels — arg-position (lowers right but leaks; no auto-`my`) and value-position bare-word reads + RHS-shape (`return(count)`→bareword). `.1.2.1` (Perl arg-position auto-existence) is the first frontier child; `.1.2.2` is its Rust parity; Channel 2 leaves added later. KM [[terse-bare-working-vars-engine-gaps]]. DOCS/TREE/KM only — no engine/book change. |
| `SPEC-FORMAT-TERSE.1.2.1` | `SPEC-FORMAT-TERSE.1.2.1 — Perl arg-position bare working-variable auto-existence (Channel 1; engine + book + 3 phase0 locks)` | Extended `_collect_auto_working_var_decls` (`RuleIR/EmitContext.pm`) with a bare arg-position pass: `assign(NAME,…)`→`my $NAME`, `push_value`/`push_nonempty(NAME,…)`→`my @NAME`; wrapped targets stay on the `.1.1.1` wrapped path (the `\s*,` guard); shared `$record` dedup → all 20 specs byte-identical; +3 phase0 subtests → 971 green; gate EXIT 0; ratio 1.0000; book (3 pages) taught wrapper-optional-in-arg-position. Child-append `push(Rule[,target])`/`.push` target + bare hash deferred to Channel 2. KM [[terse-bare-working-vars-engine-gaps]] (Channel 1 closed). |
| `SPEC-FORMAT-TERSE.1.2.2` | `SPEC-FORMAT-TERSE.1.2.2 — Rust lockstep parity for arg-position bare working-variable auto-existence (engine + oracle + 4 integration locks)` | Bare `Expr::Variable` target now mapped to the working var in `resolve_scalar_target` + `resolve_array_target` (`allow_bare` gate: push targets true, value-reads false), mirroring Perl's `^\w+$` fallback; per-parse HashMap auto-vivifies. **Required an engine change** (unlike `.1.1.2`). 2 oracle fixtures + 4 `terse_1_2_2_*` tests; cargo 248→252; clippy zero-new; phase0 971 (Perl untouched); gate EXIT 0; no book change. Channel 1 complete on both variants; `.1.2.1` now landed against the universal contract. |
| `SPEC-FORMAT-TERSE.1.4` (split) | `SPEC-FORMAT-TERSE.1.4 — split into .1.4.1 (Perl reference) + .1.4.2 (Rust parity); record helper-rename lowering-site ground truth + KM card` | `.1.4` → container after a TOOLBOX-first `call_spec_handler_subst` ground-truth pass: the three terse spellings `set`/`cat`/`copy` are currently unrecognized, and the change spans separable Perl + Rust ownership areas (ADR 0006 lockstep). `.1.4.1` (Perl: `cat`=normalize, `set`=statement-level, `copy`=unified array/hash dispatch) is the first frontier child; `.1.4.2` is its Rust parity. KM [[terse-helper-rename-lowering-sites]]. DOCS/TREE/KM only — no engine/book change. |
| `SPEC-FORMAT-TERSE.1.4.1` | `SPEC-FORMAT-TERSE.1.4.1 — Perl recognize terse renames set/cat/copy lowering identically to assign/concat/array_copy+hash_copy (engine + book + 4 phase0 locks)` | Recognized the aliases at every site each canonical name is (normalize seam for `cat`/`set`; 3 raw-text `set` scanners; dedicated array-then-hash `copy` dispatch; declare-init / return-payload / FlowExpr-source / type-inference recognizers). 4 headline + 11 composed forms byte-equal to canonical; `set`==`assign` ASSIGN node; terse spec runs == canonical twin end-to-end; **all 20 specs byte-identical**; +4 phase0 locks → **975 green**; gate EXIT 0; ratio 1.0000; book taught (3 pages, renames canonical + old names deprecated-not-retired). `.1.4.1` landed on the Perl reference; `.1.4.2` (Rust parity) is next. |
| `SPEC-FORMAT-TERSE.1.4.2` | `SPEC-FORMAT-TERSE.1.4.2 — Rust recognize terse helper renames (engine + oracle + integration locks)` | Rust `Engine::call_helper()` now treats `set` as `assign`, `cat` as `concat`, and `copy` as unified array/hash copy; `hash`/`h` one-bare-variable references align `copy(h(m))` with `hash_copy(h(m))`. 2 oracle fixtures + 3 integration locks; cargo suite green; clippy zero-new; phase0 975 untouched; full gate EXIT 0; no book change. `.1.4` container done; next frontier `.1.3`. |
| `SPEC-FORMAT-TERSE.1.3` (split) | `SPEC-FORMAT-TERSE.1.3 — split mutation surface by mechanism; record push/operator ground truth` | `.1.3` → container after TOOLBOX-first probes: scalar `set(name,val)` already done; array explicit-value append spelling must resolve `push(name,value)` vs existing child-call `push(rule,target)`; hash `set_key(name,k,v)` needs a mutation statement contract distinct from pure `set_key(hash_expr,...)`; operators require new statement syntax on Perl + Rust. `.1.3.1` audit done; `.1.3.2` is next. KM [[terse-mutation-surface-ground-truth]]. DOCS/TREE/KM only — no engine/book change. |
| `SPEC-FORMAT-TERSE.1.3.2` | `SPEC-FORMAT-TERSE.1.3.2 — recognize push(target,value) explicit append while preserving child-call push` | Perl `ActionIR` now treats `push(target,value)` as a `push_value` alias only for unambiguous/non-all-bare value expressions; all-bare `push(A,B)` remains child-call. Added Perl phase0 locks, Rust oracle fixture + integration lock, and book/KM/live-doc updates. |
| `SPEC-FORMAT-TERSE.1.3.3` | `SPEC-FORMAT-TERSE.1.3.3 — implement set_key(name,key,value) hash mutation statement` | Perl `ActionIR` now treats top-level `set_key(name,key,value)` as an ASSIGN mutation statement and auto-declares bare hash targets. Rust executes top-level `set_key(...)` statements by mutating the named hash while keeping nested value-form `set_key(hash_expr,...)` pure. Added phase0 locks, Rust integration locks, oracle fixture, and book/KM/live-doc updates. |
| `SPEC-FORMAT-TERSE.1.3.4` | `SPEC-FORMAT-TERSE.1.3.4 — split operator syntax family into scalar, array, and hash leaves` | Docs/tree/KM/live-doc split slice only. Operator forms are currently RAW_PERL blockers on Perl and unsupported by Rust's expression-statement-only lifecycle AST. Frontier becomes `.1.3.4.1` scalar assignment operator. |
| `SPEC-FORMAT-TERSE.1.3.4.1` | `SPEC-FORMAT-TERSE.1.3.4.1 — implement scalar assignment operator name = value` | Perl and Rust now support statement-level scalar `name = value` as equivalent to `set(name,value)` / `assign(name,value)`, with focused locks proving the narrow boundary and no Channel 2 broadening. Frontier becomes `.1.3.4.2` array append operator. |
| `SPEC-FORMAT-TERSE.1.3.4.2` | `SPEC-FORMAT-TERSE.1.3.4.2 — implement array append operator items += value` | Perl and Rust now support statement-level array `items += value` as equivalent to explicit append forms for explicit RHS expressions, with locks proving bare RHS remains deferred to Channel 2. Frontier becomes `.1.3.4.3` hash-index assignment operator. |
| `SPEC-FORMAT-TERSE.1.3.4.3` | `SPEC-FORMAT-TERSE.1.3.4.3 — implement hash-index assignment operator name[key] = value` | Perl and Rust now support statement-level hash-index `name[key] = value` as equivalent to `set_key(name,key,value)` for explicit key/value expressions, with locks proving bare key/RHS remain deferred to Channel 2. `.1.3.4` and `.1.3` close; frontier becomes `.1.5`. |
| `SPEC-FORMAT-TERSE.1.5.1` (split) | `SPEC-FORMAT-TERSE.1.5 — split literals/access/call/separator surface` | `.1.5` is now an active container. `.1.5.1` closed the audit/split: primitive literal parity, call-spacing locks, separator semantics, and direct nested access are separate leaves. KM [[terse-literals-calls-separators-access-ground-truth]]. DOCS/TREE/KM only — no engine/book behavior change. |
| `SPEC-FORMAT-TERSE.1.5.2` | `SPEC-FORMAT-TERSE.1.5.2 — implement primitive literal parity` | Primitive literals are typed values on Perl/Rust; Perl booleans now lower through `JSON::PP`, exact matching preserves identifier prefixes, `push(items,false)` is a value append, and Rust statement-form `if(false)` gates inactive branches. Frontier becomes `.1.5.3`. |
| `SPEC-FORMAT-TERSE.1.5.3` | `SPEC-FORMAT-TERSE.1.5.3 — lock call spacing and mandatory parentheses` | Optional whitespace before `(` is locked at supported helper/value sites on Perl and Rust, while no-parenthesis helper spellings remain outside call recognition. Frontier becomes `.1.5.4`. |
| `SPEC-FORMAT-TERSE.1.5.4` | `SPEC-FORMAT-TERSE.1.5.4 — lock statement separators` | Newline-or-semicolon statement separation is locked on Perl and Rust. Same-line multiple statements require `;`; nested semicolons stay protected; fluent attached-control tails keep working through Bootstrap newline normalization. Frontier becomes `.1.5.5`. |
| `SPEC-FORMAT-TERSE.1.5.5` | `SPEC-FORMAT-TERSE.1.5.5 — split direct access by Channel 2 boundary` | `.1.5.5` is now a container. `.1.5.5.1` owns direct nested access with explicit path segments; `.1.5.5.2` owns the bare path-segment / Channel 2 value-position-read coordination. Frontier becomes `.1.5.5.1`. |
| `SPEC-FORMAT-TERSE.1.5.5.1` | `SPEC-FORMAT-TERSE.1.5.5.1 — implement direct nested access explicit segments` | Perl and Rust now accept explicit mixed direct access such as `foo["a"][9]["b"][scalar(z)]`; `scalaref(...)` remains accepted; bare path atoms stay deferred to `.1.5.5.2` / Channel 2. Frontier becomes `.1.5.5.2`. |
| `SPEC-FORMAT-TERSE.1.5.5.2` | `SPEC-FORMAT-TERSE.1.5.5.2 — merge bare direct access into Channel 2` | No engine/book behavior change. `.1.5.5.2` is superseded into new `.1.2.3` because bare direct-access path atoms share the global value-position bare-word-read model. Frontier becomes `.1.2.3`. |
| `SPEC-FORMAT-TERSE.1.2.3` | `SPEC-FORMAT-TERSE.1.2.3 — split Channel 2 value reads by aggregate/scalar surfaces` | No engine/book behavior change. Channel 2 is now an active container with aggregate bare value reads first (`.1.2.3.1` Perl, `.1.2.3.2` Rust), followed by scalar bare reads (`.1.2.3.3` Perl, `.1.2.3.4` Rust). Frontier becomes `.1.2.3.1`. |
| `SPEC-FORMAT-TERSE.1.2.3.1` | `SPEC-FORMAT-TERSE.1.2.3.1 — auto-exist aggregate bare value reads` | Perl aggregate bare value reads now auto-declare per-invocation lexicals: `array_copy(NAME)` / `copy(NAME)` -> `my @NAME`; `hash_copy(NAME)` -> `my %NAME`. Wrapped/declared paths dedup unchanged; scalar bare reads and bare key/RHS/direct path atoms remain deferred. Frontier becomes `.1.2.3.2`. |
| `SPEC-FORMAT-TERSE.1.2.3.2` | `SPEC-FORMAT-TERSE.1.2.3.2 — add Rust aggregate bare-read parity` | Rust aggregate bare reads now match the Perl reference at the aggregate-copy helper call sites. `array_copy(NAME)` and array-first `copy(NAME)` read arrays, `hash_copy(NAME)` reads hashes, and `copy(hash(NAME))` keeps the explicit hash form. 4 oracle fixtures + 4 integration locks; full runtime suite green; scalar Channel 2 remains next. |
| `SPEC-FORMAT-TERSE.1.2.3.3` | `SPEC-FORMAT-TERSE.1.2.3.3 — split scalar bare reads by lowering seam` | No engine/book behavior change. Perl scalar bare reads are split into return/assignment source slots (`.1.2.3.3.1`), mutation key/RHS slots (`.1.2.3.3.2`), and direct-access bare path atoms (`.1.2.3.3.3`). Frontier becomes `.1.2.3.3.1`. |
| `SPEC-FORMAT-TERSE.1.2.3.3.1` | `SPEC-FORMAT-TERSE.1.2.3.3.1 — implement scalar source-slot bare reads` | Perl source-slot bare reads now work for return and scalar assignment-like sources with matching scalar auto-existence. mdBook/KM/live docs updated; phase0 985 green. Frontier becomes `.1.2.3.3.2`. |
| `SPEC-FORMAT-TERSE.1.2.3.3.2` | `SPEC-FORMAT-TERSE.1.2.3.3.2 — implement scalar mutation-slot bare reads` | Perl mutation-slot bare reads now work for array append RHS, statement-level `set_key` key/RHS, and hash-index operator key/RHS, with matching scalar auto-existence. mdBook/KM/live docs updated; phase0 986 green. Frontier becomes `.1.2.3.3.3`. |
| `SPEC-FORMAT-TERSE.1.2.3.3.3` | `SPEC-FORMAT-TERSE.1.2.3.3.3 — implement direct-access bare path atoms` | Perl direct-access bare path atoms now work as scalar array indexes with matching scalar auto-existence. mdBook/KM/live docs updated; phase0 987 green. `.1.2.3.3` closes; frontier becomes `.1.2.3.4`. |
| `SPEC-FORMAT-TERSE.1.2.3.4` | `SPEC-FORMAT-TERSE.1.2.3.4 — add Rust scalar bare-read parity` | Rust now accepts the Perl scalar bare-read contract in source slots, mutation key/RHS slots, and direct-access bare path atoms through the existing `Expr::Variable` scalar read path. 3 oracle fixtures added; frontier becomes `.1.2.3.5` RHS-shape/type-inference split. |
| `SPEC-FORMAT-TERSE.1.2.3.5` | `SPEC-FORMAT-TERSE.1.2.3.5 — split RHS-shape inference by mechanism` | No engine/book behavior change. RHS-shape/type inference is split into Perl shape-literal value expressions (`.1.2.3.5.1`), Perl RHS target-kind inference (`.1.2.3.5.2`), and Rust parity for each (`.1.2.3.5.3`/`.1.2.3.5.4`). Frontier becomes `.1.2.3.5.1`. |
| `SPEC-FORMAT-TERSE.1.2.3.5.1` | `SPEC-FORMAT-TERSE.1.2.3.5.1 — implement Perl shape-literal values` | Perl now lowers accepted `[]` / `{}` shape literals as DSL value expressions, with scalar bare reads inside direct elements, keys, and values plus auto-`my` declarations. Fixed hash fields require quoted keys. Target-kind inference stays deferred to `.1.2.3.5.2`; Rust parity stays `.1.2.3.5.3`. |
| `SPEC-FORMAT-TERSE.1.2.3.5.2` | `SPEC-FORMAT-TERSE.1.2.3.5.2 — infer Perl RHS shape target kind` | Perl now uses direct RHS shape literals to infer aggregate bare assignment targets: arrays for `[]` / `[value]`, hashes for `{}` / `{ key => value }`; explicit `scalar(...)` keeps scalar-held payload assignment. Declaration initializer direct shapes unwrap lowered members. Frontier becomes `.1.2.3.5.3`. |
| `SPEC-FORMAT-TERSE.1.2.3.5.3` | `SPEC-FORMAT-TERSE.1.2.3.5.3 — implement Rust shape-literal values` | Rust parses/evaluates direct shape literals as value expressions with parser/runtime/oracle locks, while leaving Rust RHS target-kind inference to `.1.2.3.5.4`. |
| `SPEC-FORMAT-TERSE.1.2.3.5.4` | `SPEC-FORMAT-TERSE.1.2.3.5.4 — implement Rust RHS shape target kind` | Rust now uses direct RHS shape literals to infer aggregate bare or matching typed aggregate assignment targets, while explicit `scalar(...)` keeps scalar-held payload assignment. Added integration/oracle locks; frontier becomes `.1.6`. |
| `SPEC-FORMAT-TERSE.1.6` | `SPEC-FORMAT-TERSE.1.6 — implement array end-mutation methods` | Perl and Rust now support statement-level `items.push_back(value)`, `items.push_front(value)`, `items.pop_back()`, and `items.pop_front()` over named working arrays. Added phase0/Rust/oracle/book/KM locks; Round 1 closes and frontier becomes `.2.1`. |
| `SPEC-FORMAT-TERSE.2.1.1` | `SPEC-FORMAT-TERSE.2.1.1 — split expression-valued blocks` | No engine/book behavior change. `.2.1` is split into Perl-reference core block values (`.2.1.2`), Rust parity (`.2.1.3`), and explicit block-local early-return follow-through (`.2.1.4`). Frontier becomes `.2.1.2`. |
| `SPEC-FORMAT-TERSE.2.1.2` | `SPEC-FORMAT-TERSE.2.1.2 — implement Perl expression-valued blocks` | Perl reference now accepts the core block-value subset in value-consuming sites, preserving hash-literal precedence. Rust parity remains `.2.1.3`; full block-local early return remains `.2.1.4`. |
| `SPEC-FORMAT-TERSE.2.1.3` | `SPEC-FORMAT-TERSE.2.1.3 — own Rust expression-valued blocks` | No engine/book behavior change. Rust parser/runtime seams are recorded before code; frontier remains `.2.1.3` implementation. |
| `SPEC-FORMAT-TERSE.2.1.3` | `SPEC-FORMAT-TERSE.2.1.3 — implement Rust expression-valued blocks` | Rust parser/runtime parity for the core block-value subset landed with oracle fixture; frontier becomes `.2.1.4`. |
| `SPEC-FORMAT-TERSE.2.1.4` | `SPEC-FORMAT-TERSE.2.1.4 — implement block-local return` | Expression-valued blocks now support block-local early `return(expr)` on Perl and Rust without leaking into the surrounding rule return channel. Added Perl/Rust/oracle/book/KM locks; `.2.1` closes and frontier becomes `.2.2`. |
| `SPEC-FORMAT-TERSE.2.2.1` | `SPEC-FORMAT-TERSE.2.2.1 — split control-flow keyword surface` | No engine behavior change. `.2.2` is split by current support seams: Perl attached-if first, Rust attached-if parity next, then `when`/`otherwise`, attached switch/default, and while. Frontier becomes `.2.2.2`. |
| `SPEC-FORMAT-TERSE.2.2.2` | `SPEC-FORMAT-TERSE.2.2.2 — own Perl attached if blocks` | No engine behavior change. Perl attached-block if ownership narrowed the implementation to the same-line branch-continuation splitter: newline-separated `if { ... }` / `elseif { ... }` / `else { ... }` clauses are already ActionIR-ready, while compact `} elseif/else {` chains remain raw. Frontier remains `.2.2.2` implementation. |
| `SPEC-FORMAT-TERSE.2.2.2` | `SPEC-FORMAT-TERSE.2.2.2 — implement Perl attached if blocks` | Perl compact attached-block `if/elseif/else` now splits, lowers, and runs without raw fallback. Marker-form and inline-composite `if` behavior is unchanged. Frontier becomes `.2.2.3` for Rust parity. |
| `SPEC-FORMAT-TERSE.2.2.3` | `SPEC-FORMAT-TERSE.2.2.3 — own Rust attached if blocks` | No engine behavior change. Rust parity is owned before code: parse attached `if`/`elseif`/`else` branch bodies into the existing statement-control model, reusing `handle_statement_if_control` rather than adding a second branch runtime. Frontier remains `.2.2.3` implementation. |
| `SPEC-FORMAT-TERSE.2.2.3` | `SPEC-FORMAT-TERSE.2.2.3 — implement Rust attached if blocks` | Rust `CodeBlock::parse` now normalizes attached `if/elseif/else` branch bodies to the existing marker-control sequence; runtime branch gating is reused unchanged. Added parser/runtime/oracle locks; attached `if` is now portable on Perl and Rust. Frontier becomes `.2.2.4`. |
| `SPEC-FORMAT-TERSE.2.2.4` | `SPEC-FORMAT-TERSE.2.2.4 — own when otherwise aliases` | No engine behavior change. `when/otherwise` is owned as an alias-normalization leaf over attached `if/else`, not host Perl `when`; implementation should reuse existing control-flow lowerers and Rust marker runtime. Frontier remains `.2.2.4` implementation. |
| `SPEC-FORMAT-TERSE.2.2.4` | `SPEC-FORMAT-TERSE.2.2.4 — implement when otherwise aliases` | Perl and Rust now normalize attached `when(cond) { ... } otherwise { ... }` to the existing attached `if/else` control-flow contract. Oracle corpus 37 fixtures. Frontier becomes `.2.2.5`. |
| `SPEC-FORMAT-TERSE.2.2.5` | `SPEC-FORMAT-TERSE.2.2.5 — split attached switch surface` | No engine behavior change. Attached `switch/case/default` is split before code into `.2.2.5.1` Perl separator/source lock and `.2.2.5.2` Rust parity. Frontier becomes `.2.2.5.1`. |
| `SPEC-FORMAT-TERSE.2.2.5.1` | `SPEC-FORMAT-TERSE.2.2.5.1 — implement Perl attached switch separator lock` | Perl compact attached `switch/case/default` now splits adjacent branch bodies, lowers without host branch residue, and preserves the semicolon requirement before any following same-line ordinary statement. Frontier becomes `.2.2.5.2` Rust parity. |
| `SPEC-FORMAT-TERSE.2.2.5.2` | `SPEC-FORMAT-TERSE.2.2.5.2 — implement Rust attached switch blocks` | Rust attached `switch/case/default` now parses and executes with first-match/default statement gating and oracle parity. Lazy value-form switch remains unchanged. Frontier becomes `.2.2.6` (`while`). |
| `SPEC-FORMAT-TERSE.2.2.6` | `SPEC-FORMAT-TERSE.2.2.6 — split while loop surface` | No engine behavior change. Attached `while(cond) { ... }` is split before code into `.2.2.6.1` Perl reference loop/safety and `.2.2.6.2` Rust parity. Frontier becomes `.2.2.6.1`. |
| `SPEC-FORMAT-TERSE.2.2.6.1` | `SPEC-FORMAT-TERSE.2.2.6.1 — implement Perl attached while safety` | Perl attached `while(cond) { ... }` now lowers through ActionIR with condition re-evaluation and deterministic iteration safety. Frontier becomes `.2.2.6.2` Rust parity. |
| `SPEC-FORMAT-TERSE.2.2.6.2` | `SPEC-FORMAT-TERSE.2.2.6.2 — implement Rust attached while safety` | Rust attached `while(cond) { ... }` now parses and executes with the accepted Perl loop/safety contract, expression-block composition, numeric comparison helper parity, and a 39-fixture oracle corpus. Frontier becomes `.2.3`. |
| `SPEC-FORMAT-TERSE.2.3` | `SPEC-FORMAT-TERSE.2.3 - split fluent lifecycle composability surface` | No engine behavior change. `.2.3` is split into Perl fluent block-chain locking, lifecycle value/drop semantics, Rust fluent-block/action-edge parity, full composability audit, and return-type method chaining design. Frontier becomes `.2.3.1`. |
| `SPEC-FORMAT-TERSE.2.3.1` | `SPEC-FORMAT-TERSE.2.3.1 - lock Perl fluent when otherwise blocks` | Perl reference fluent `.when(cond) { ... }.otherwise { ... }` and no-dot `otherwise { ... }` fallback continuations now execute correctly on action-edge and lifecycle surfaces, with phase0 locks. Frontier becomes `.2.3.2`. |
| `SPEC-FORMAT-TERSE.2.3.2` | `SPEC-FORMAT-TERSE.2.3.2 - lock lifecycle value drop return channel` | Lifecycle blocks are locked as statement blocks: final ordinary statement values are discarded, top-level `return(expr)` writes the surrounding rule/action channel, and expression-valued block-local return stays separate. Phase0 994 green; frontier becomes `.2.3.3`. |
| `SPEC-FORMAT-TERSE.2.3.3.1` | `SPEC-FORMAT-TERSE.2.3.3.1 - implement Rust action-edge fluent continuations` | Rust action-edge fluent no-arg `.push`, `.return(expr)`, and `.return_undef` now execute through structured action-edge metadata; `tclite` remains deferred behind compact lifecycle/body fluent and default-mode repetition gaps. Frontier becomes `.2.3.3.2`. |
| `SPEC-FORMAT-TERSE.2.3.3.2` | `SPEC-FORMAT-TERSE.2.3.3.2 - implement Rust attached fluent block payloads` | Rust action-edge/lifecycle `.when(cond) { ... }` fluent block chains now execute through normalized attached statement blocks with dotted or no-dot fallback tails. Frontier becomes `.2.3.3.3`. |
| `SPEC-FORMAT-TERSE.2.3.3.3` | `SPEC-FORMAT-TERSE.2.3.3.3 - split remaining Rust fluent continuations` | Remaining Rust fluent parity split into compact lifecycle/body receiver chains, action-edge explicit/flow chains, and `tclite`/default-mode repetition re-enable audit. Frontier becomes `.2.3.3.3.1`. |
| `SPEC-FORMAT-TERSE.2.3.3.3.1` | `SPEC-FORMAT-TERSE.2.3.3.3.1 - implement Rust compact lifecycle fluent chains` | Rust compact lifecycle/body receiver chains now execute as lifecycle `CodeBlock` statements; frontier becomes `.2.3.3.3.2`. |
| `SPEC-FORMAT-TERSE.2.3.3.3.2` | `SPEC-FORMAT-TERSE.2.3.3.3.2 - implement Rust action-edge fluent flow chains` | Rust action-edge explicit/flow fluent chains now execute with explicit-target child return appends and statement-control gating; frontier becomes `.2.3.3.3.3`. |
| `SPEC-FORMAT-TERSE.2.3.3.3.3` | `SPEC-FORMAT-TERSE.2.3.3.3.3 - split Rust tclite repetition parity` | `tclite` oracle retry after fluent parity still returned Rust `[]` for `[]` and `""` at that split point; default-mode recursive repetition parity split to `.2.3.3.3.3.1`, which later landed the fixtures. |
| `SPEC-FORMAT-TERSE.2.3.3.3.3.1` | `SPEC-FORMAT-TERSE.2.3.3.3.3.1 - implement Rust tclite default repetition` | Rust default-mode recursive repetition parity landed; `tclite_command_subst` and `tclite_double_quote` are active oracle fixtures, corpus 41 passes, and frontier becomes `.2.3.4`. |
| `SPEC-FORMAT-TERSE.2.3.4` | `SPEC-FORMAT-TERSE.2.3.4 - split composability boundaries` | Full composability audit split Rust helper-context aggregate bare reads to `.2.3.4.1` and Perl inline value-control lowering to `.2.3.4.2`; added a green deep pure-helper oracle fixture and frontier becomes `.2.3.4.1`. |
| `SPEC-FORMAT-TERSE.2.3.4.1` | `SPEC-FORMAT-TERSE.2.3.4.1 - implement Rust bare aggregate helper args` | Rust helper-context bare aggregate arguments landed for hash- and array-consuming helper slots; corpus 44 passes and frontier becomes `.2.3.4.2`. |
| `SPEC-FORMAT-TERSE.2.3.4.2` | `SPEC-FORMAT-TERSE.2.3.4.2 - implement Perl inline value controls` | Perl inline value-control lowering landed for `if`/`switch` in supported value positions; corpus 46 passes and frontier becomes `.2.3.5`. |

## Changelog

- `2026-07-01`: **`.2.3.5.6` LANDED — aggregate wrapper quoted-name boundaries.**
  Bare aggregate wrappers remain typed working-variable reads: `array(foo)` / `a(foo)` read `@foo`, and
  `hash(bar)` / `h(bar)` read `%bar`. Quoted wrapper arguments are not aliases and are not scalar-indirect
  lookups: `array("foo")` / `array('foo')` are literal constructor payloads, while quoted hash arguments are
  fixed-key constructor payloads under the existing arity rules. The mdBook now prefers direct terse shape
  constructors (`[...]`, `{...}`, `[]`, `{}`) for new array/hash construction examples, and postfix
  `foo.array()`-style typed-view adapters remain out of scope. Phase0 is 1000 green, the Rust oracle corpus is
  51 fixtures, and the frontier returns to `.2.3.5.5`.

- `2026-07-01`: **`.2.3.5.4` LANDED — number receiver-dot value chains.**
  Number receiver-dot chains now compose through the existing `num_*` helper family on Perl and Rust:
  `score.abs().ceil().add(2, 3).mul(2).sub(1).div(2).clamp(0, 20).max(5).min(12)`,
  `5.mod(2)`, and `3.5.floor().add(1)` are locked. Comparison methods such as `gt`/`le` are terminal values;
  invalid later receiver calls return `undef`/`null`. Numeric array reducers remain explicit array-consuming
  helpers, and statement/lifecycle calls such as `declare(...)` are not receiver methods. Phase0 is 999 green,
  the Rust oracle corpus is 50 fixtures, and the frontier moves to `.2.3.5.5`.

- `2026-06-30`: **`.2.3.4.2` LANDED — Perl inline value-control lowering.**
  Inline-composite `if(...)` and `switch(...)` now return selected branch payloads on the Perl reference in
  `return(...)`, assignment RHS, and fluent `.return(...)` value positions. Branch payloads compose with nested
  helpers and expression-valued blocks; fluent/action-edge checks assert payload values without making any
  `?...:` compatibility tag spelling mandatory. The new
  `terse_2_3_4_2_inline_if_value_control` and
  `terse_2_3_4_2_inline_switch_value_control` oracle fixtures bring `corpus_oracle` to 46 passing fixtures.
  Frontier moves to `.2.3.5`.

- `2026-06-30`: **`.2.3.4.1` LANDED — Rust helper-context bare aggregate arguments.**
  Rust now snapshots bare working-variable names only in hash- or array-consuming helper argument slots, so
  `merge_hash(hash_copy(base), overlay)` and `count(drop_front(sorted(items)))` match Perl without changing
  ordinary bare scalar reads. Focused runtime locks cover the merge case, the broader hash/object helper family,
  and the array helper family; the new `terse_2_3_4_1_bare_hash_helper_arg_composition` and
  `terse_2_3_4_1_bare_array_helper_arg_composition` oracle fixtures bring `corpus_oracle` to 44 passing
  fixtures. Frontier moves to `.2.3.4.2`.

- `2026-06-30`: **`.2.3.4` AUDIT/SPLIT — full composability boundaries.** Pure helper nesting is portable
  with explicit aggregate wrappers and is locked by a new oracle fixture
  `terse_2_3_4_deep_pure_helper_composition`; the Rust corpus now passes with 42 fixtures. Unsupported sites
  are split before code: `.2.3.4.1` owns Rust helper-context aggregate bare reads such as
  `merge_hash(hash_copy(base), overlay)`, and `.2.3.4.2` owns Perl inline-composite value-control lowering for
  `return(if(...))` / `return(switch(...))`. Receiver-dot value/chaining remains `.2.3.5`. Frontier moves to
  `.2.3.4.1`.

- `2026-06-30`: **`.2.3.3.3.3.1` LANDED — Rust `tclite` default-mode repetition parity.**
  Rust now treats bare default rules as zero-min repeated-choice loops and honors child-rule `I.return(...)`
  before local entry-regex re-matching. The shipped `tclite_command_subst` (`[]`) and `tclite_double_quote`
  (`""`) oracle cases are active again; `corpus_oracle` passes with 41 fixtures. Frontier moves to `.2.3.4`.

- `2026-06-30`: **`.2.3.3.3.3` AUDIT/SPLIT — Rust `tclite` retry after fluent parity.**
  Perl reference probes show `tclite` returns `["?tcl_script:",[["?command_subst:",[]]]]` for `[]` and
  `["?tcl_script:",[["?double_quote:",[]]]]` for `""`. Temporarily re-enabling those oracle fixtures made the
  Rust corpus oracle fail exactly those two cases: expected the wrapped Perl values, actual `[]` for both,
  while the other 39 fixtures passed. The failing fixtures were not committed in the split slice; `.2.3.3.3.3.1`
  later landed default-mode recursive repetition parity and re-enabled them. Frontier moved to `.2.3.3.3.3.1`.

- `2026-06-30`: **`.2.3.3.3.2` LANDED — Rust action-edge explicit/flow fluent chains.**
  Rust now keeps multiline dotted continuations after an action edge attached to that edge and executes
  explicit/flow continuations beyond the earlier no-arg subset. `.push(target)` and `.push(child,target)`
  dispatch the child and append its return to the explicit target accumulator; `.if/.else/.endif` gates later
  fluent calls; branch-local helpers such as `.say(...)` use normal helper evaluation; and
  `.return_undef()` keeps the action-edge return path. The next frontier is `.2.3.3.3.3`, the `tclite`
  oracle/default-mode repetition audit.

- `2026-06-30`: **`.2.3.3.3.1` LANDED — Rust compact lifecycle fluent chains.**
  Rust now parses accepted lifecycle-marker receiver chains such as `I.return(...)` and
  `I.declare(...).set(...).return(...)` into executable lifecycle `CodeBlock` statements rather than leaving a
  standalone `FluentChain` for the compiler to drop. Focused parser/compiler/runtime locks pass, mdBook/KM/live
  docs are updated, and the next frontier is `.2.3.3.3.2` action-edge explicit/flow fluent chains.

- `2026-06-30`: **`.2.3.3.3` SPLIT — remaining Rust fluent continuations.**
  The leaf was too broad for one signoff implementation slice. Rust lifecycle/body compact chains such as
  `I.return(...)` currently parse as a lifecycle marker plus standalone `FluentChain` and are dropped by the
  compiler; action-edge explicit/flow chains need separate runtime semantics beyond the no-arg subset; `tclite`
  re-enable waits until those fluent children land, then gets a focused default-mode repetition audit if still
  divergent. Frontier moves to `.2.3.3.3.1`.

- `2026-06-30`: **`.2.3.3.2` LANDED — Rust attached fluent block payloads.**
  Rust now parses action-edge and lifecycle-marker `.when(cond) { ... }` receiver-fluent block chains and
  normalizes them to existing attached `when/otherwise` statement blocks. Dotted `.otherwise { ... }` and
  no-dot `otherwise { ... }` fallback tails execute on both surfaces, including multiline `}.otherwise {`
  placement. Focused Rust parser/runtime locks PASS. Frontier moves to `.2.3.3.3`.

- `2026-06-30`: **`.2.3.3.1` LANDED — Rust action-edge fluent continuations.**
  Rust now carries fluent chains on `->` action edges through AST, compiled `AcodeEntry`, and runtime dispatch.
  No-arg `.push` captures the child rule return, suppresses child return-event leakage, and appends to the
  current rule accumulator. `.return(expr)` / `.return_undef` return through the current rule/action channel
  without redispatching the close-edge child; `.return_undef` stays accumulator-silent. Full local CI PASS
  (`Files=1, Tests=994`). `tclite` remains deferred behind compact lifecycle/body fluent forms and default-mode
  repetition parity. Frontier moves to `.2.3.3.2`.

- `2026-06-30`: **`.2.3.2` LANDED — lifecycle value/drop return-channel lock.**
  Lifecycle blocks are statement blocks: final ordinary statement values are discarded, top-level
  `return(expr)` writes the surrounding return channel, and expression-valued block-local return stays local.
  Phase0 source-locks all seven lifecycle markers and runtime-locks the value/drop distinction. Phase0 is
  **994 green**. Frontier moves to `.2.3.3`.

- `2026-06-30`: **`.2.3.1` LANDED — Perl fluent `when/otherwise` block-chain contract.**
  Bootstrap now keeps attached fallback tails after fluent `.when(...) { ... }` chains, including both dotted
  `.otherwise { ... }` and no-dot `otherwise { ... }` continuations. Phase0 locks cover action-edge and
  lifecycle false-branch fallback execution, descriptor cleanliness, and generated-source residue. Phase0 is
  **993 green**. Frontier moves to `.2.3.2`.

- `2026-06-30`: **`.2.3` SPLIT/OWNED BEFORE CODE — fluent control-flow, lifecycle blocks, full
  composability, and method chaining.** Perl reference already accepts exact action/lifecycle
  `.when(cond) { ... }.otherwise { ... }` fluent block chains, but Rust does not yet support the same fluent
  attached-block/action-edge surface and lifecycle value-drop semantics need a separate lock. Full
  composability and return-type method chaining are split into their own leaves rather than treated as one
  parser/runtime change. Frontier moves to `.2.3.1`.

- `2026-06-30`: **`.2.2.6` SPLIT/OWNED BEFORE CODE — attached `while(cond) { ... }`.**
  Current Perl lowers attached while as raw host code, and Rust has no attached statement-loop parser/runtime.
  Split into `.2.2.6.1` Perl reference loop/safety and `.2.2.6.2` Rust parity. The loop safety rule is part of
  the contract: a non-terminating loop must hit a deterministic iteration guard instead of hanging. Frontier
  moves to `.2.2.6.1`.

- `2026-06-30`: **`.2.2.6.1` LANDED — Perl attached `while(cond) { ... }` loop/safety.**
  Perl lowers attached while through ActionIR without raw fallback or unresolved helper residue. The accepted
  contract includes pre-iteration condition evaluation, ordinary body statement execution, surrounding-rule
  `return(expr)` semantics, and the deterministic 10000-iteration guard. Frontier moves to `.2.2.6.2`.

- `2026-06-30`: **`.2.2.6.2` LANDED — Rust attached `while(cond) { ... }` parity.**
  Rust parses attached while as a lazy loop over a parsed body block and executes it with condition
  re-evaluation, normal statement-body semantics, expression-valued block-local `return(expr)`, and the same
  10000-iteration safety diagnostic as Perl. Numeric comparison helper parity closes the documented counter
  loop pattern. Oracle corpus now has **39 fixtures**. Frontier moves to `.2.3`.

- `2026-06-30`: **`.2.2.5.2` LANDED — Rust attached `switch/case/default` parity.**
  `CodeBlock::parse` now lowers attached switch branch blocks into `switch` / `case` / `default` /
  `endswitch` statement controls, and `Engine` gates those controls with a switch stack in lifecycle and
  expression-valued blocks. Focused parser/runtime/lazy-switch checks pass; oracle corpus now has **38
  fixtures**. Frontier moves to `.2.2.6` (`while`).

- `2026-06-30`: **`.2.2.5.1` LANDED — Perl attached `switch/case/default` separator/source lock.**
  `StatementSplit::Core` now splits adjacent attached `case(...) { ... }` and `default { ... }` branch bodies
  before same-line branch continuations. Compact attached switch lowers with `ready=1 raw=0 unresolved=0`, no
  host-shaped branch residue, and first/later/default runtime selection locked. The `.1.5.4` separator rule
  remains: a following same-line ordinary statement needs `;`. Frontier moves to `.2.2.5.2` Rust parity.

- `2026-06-30`: **`.2.2.5` SPLIT/OWNED BEFORE CODE — attached `switch/case/default`.**
  TOOLBOX probes show this surface is not one safe implementation leaf: Perl has partial attached-switch
  lowering but adjacent branch blocks without explicit separators can leave unresolved `case` or host-like
  `default` residue, while Rust only has the lazy value-form `switch(...)` helper and no attached statement
  parser. Split `.2.2.5` into `.2.2.5.1` Perl separator/source lock and `.2.2.5.2` Rust parity. Frontier moves
  to `.2.2.5.1`.

- `2026-06-30`: **`.2.2.4` LANDED — `when/otherwise` conditional aliases.**
  Perl now recognizes attached `when(cond) { ... } otherwise { ... }` at the existing splitter,
  scanner/contract, and `ControlFlow` seams, lowers it as canonical `if/else`, and no longer leaks host Perl
  `when` into generated handlers. Rust normalizes the same attached form in `CodeBlock::parse` to existing
  `if`/`else`/`endif` statement controls. Added focused Perl/Rust locks plus oracle fixture
  `terse_2_2_4_when_otherwise_aliases` (corpus **37 fixtures**). Frontier moves to `.2.2.5` attached
  `switch/case/default`.

- `2026-06-30`: **`.2.2.4` OWNED BEFORE CODE — `when/otherwise` aliases.**
  TOOLBOX probes show the current combined `when(true) { ... } otherwise { ... }` form is raw
  (`ready=0 raw=1 unresolved=2`), emits Perl's host `when is experimental` warning in generated handlers, and
  returns the wrong branch in the true-condition runtime probe. The accepted implementation boundary is alias
  normalization: `when(cond) { ... }` maps to attached `if(cond) { ... }`, and `otherwise { ... }` maps to
  attached `else { ... }`. Perl changes should live in the existing statement-split/scanner/contract/control-flow
  seams; Rust should normalize in `CodeBlock::parse` and reuse `handle_statement_if_control`. No behavior
  changed in this ownership slice.

- `2026-06-30`: **`.2.2.3` LANDED — Rust attached-block if parity.**
  Rust now parses attached `if(cond) { ... } elseif(cond2) { ... } else { ... }` statement chains in
  `CodeBlock::parse` and normalizes them to the existing `if` / `elseif` / `else` / `endif` marker-control
  sequence. Runtime branch gating reuses `Engine::handle_statement_if_control`; no second branch runtime was
  added. Focused parser/runtime locks and the new `terse_2_2_3_attached_if_blocks` oracle fixture keep
  marker-form `if(cond); ... endif()` and inline-composite `if(...)` behavior unchanged. Attached-block `if`
  is now portable on Perl and Rust; frontier moves to `.2.2.4` (`when/otherwise`).

- `2026-06-30`: **`.2.2.3` OWNED BEFORE CODE — Rust attached-block if parity.**
  Code-read narrowed the Rust parity slice. `CodeBlock::parse` has expression-valued blocks and
  semicolon/newline statement separation, but no attached statement-block parser for
  `if(...) { ... } elseif(...) { ... } else { ... }`. Runtime already gates statement-marker branches in both
  lifecycle blocks and expression-valued block evaluation through `handle_statement_if_control`, so the Rust
  implementation should parse attached branch bodies into that existing model. Focused parser smoke passed.

- `2026-06-30`: **`.2.2.2` DONE — Perl attached-block if/elseif/else landed.**
  `StatementSplit::Core` now splits a complete attached `if`/`elseif` branch body before same-line attached
  `elseif(...) { ... }` and bare `else { ... }` continuations. Compact
  `if(cond) { ... } elseif(cond2) { ... } else { ... }` now lowers through ActionIR with no raw fallback and
  executes only the selected branch. Existing marker-form `if(cond); ... endif()` and inline-composite
  `if(...)` behavior is unchanged. Frontier moves to `.2.2.3` for Rust parity.

- `2026-06-30`: **`.2.2.2` OWNED BEFORE CODE — Perl attached-block if/elseif/else.**
  TOOLBOX probes and code-read narrowed the Perl reference implementation seam. Newline-separated attached
  branches already lower without raw fallback:
  `if(cond) { ... }\nelseif(cond2) { ... }\nelse { ... }`. Compact same-line chains such as
  `if(cond) { ... } elseif(cond2) { ... } else { ... }` still remain one raw statement because
  `StatementSplit::Core` does not split a complete attached branch before a same-line `elseif`/`else`
  continuation. Scanner/ControlFlow/RewritePipeline already support the individual branch statements; the
  implementation slice must preserve marker-form and inline-composite `if` behavior.

- `2026-06-30`: **`.2.2.1` DONE / `.2.2.2` OWNED NEXT — control-flow keyword surface split.**
  `.2.2` became an active container with concrete implementation leaves. At split time, portable support was the
  statement-marker `if(cond); ... else(); ... endif()` family and inline-composite lazy `if`/`switch`.
  Attached-block `if`, `when`/`otherwise`, statement-level switch blocks, and `while` still needed
  implementation work. The next leaf was `.2.2.2`, the Perl reference attached-block `if/elseif/else` path.

- `2026-06-30`: **`.2.1.4` DONE — expression-valued block early return landed.**
  Perl and Rust now support `return(expr)` anywhere inside an expression-valued block. The block-local return
  yields `expr`, skips later statements in the block, and does not set the surrounding rule return channel.
  Oracle corpus is **35 fixtures**; `.2.1` is closed and frontier moves to `.2.2`.

- `2026-06-30`: **`.2.1.4` OWNED BEFORE CODE — block-local explicit-return follow-through.**
  The leaf now owns the investigation/implementation of true mid-block `return(expr)` inside expression-valued
  blocks, preserving block-local semantics without leaking into the surrounding rule return channel.

- `2026-06-29`: **`.2.1.3` DONE — Rust expression-valued block parity landed.**
  Rust now parses and evaluates core expression-valued blocks with `Expr::BlockValue`, while preserving empty
  and keyed hash literals. Final expressions and final `return(expr)` yield block values; non-final
  `return(expr)` remains deferred to `.2.1.4`. Oracle corpus is **34 fixtures**.

- `2026-06-29`: **`.2.1.3` OWNED BEFORE CODE — Rust expression-valued block parity.**
  Rust parser/runtime seams are recorded before implementation. The leaf owns adding a block-value `Expr` path
  while preserving `{}` / keyed `=>` hash literals, evaluating side-effect statements, and returning the final
  expression or final `return(expr)` payload. True mid-block early return remains `.2.1.4`.

- `2026-06-29`: **`.2.1.2` DONE — Perl-reference core expression-valued blocks landed.**
  Non-empty brace payloads without a top-level `=>` now lower as value blocks in Perl reference return
  payloads, assignment sources, and nested value payloads. The block returns its final expression, or a final
  `return(expr)` payload. `{}` and `{ key => value }` remain hash shape literals; Rust parity remains `.2.1.3`.

- `2026-06-29`: **`.2.1.1` DONE / `.2.1.2` OWNED BEFORE CODE — expression-valued blocks split.**
  KM and TOOLBOX ground truth showed expression-valued blocks are a multi-seam feature, not one safe slice.
  `{}` and `{ key => value }` stay hash shape literals; non-empty brace payloads without top-level `=>` need
  distinct block-expression lowering/evaluation. `.2.1.2` now owns the Perl reference core; Rust parity and
  full block-local early return remain separate children.

- `2026-06-29`: **`.2.1` PICKED / OWNED BEFORE CODE — expression-valued blocks.**
  PNT moved to Round 2 after `.1.6` closed Round 1. This ownership slice records `.2.1` as the active leaf
  before implementation; the next action is KM retrieval plus TOOLBOX/code-read ground truth and a split
  decision if expression-valued blocks are broader than one signoff slice.

- `2026-06-29`: **`.1.6` DONE — array end-mutation methods landed and Round 1 closed.**
  Perl and Rust now accept the statement-level receiver-dot methods `items.push_back(value)`,
  `items.push_front(value)`, `items.pop_back()`, and `items.pop_front()` over named working arrays, including
  `array(items)` / `a(items)` receiver aliases. Push values use mutation-slot value semantics, so bare values
  read scalar working variables; pop methods discard the removed value. Perl reports canonical `ARRAY_MUTATE`
  with zero fallback, Rust executes the same statement forms, phase0 PASS (`990` tests), and the oracle corpus
  is now **33 fixtures**. Frontier -> `.2.1`.

- `2026-06-29`: **`.1.2.3.5.4` DONE — Rust RHS shape target-kind inference parity landed.**
  Rust now mirrors the accepted Perl aggregate target-kind contract for direct RHS shape literals. `items =
  [value]`, `set(items, [value])`, and `set(array(items), [value])` replace the runtime array working variable;
  `meta = { key => value }`, `assign(meta, { key => value })`, and `set(hash(meta), { key => value })` replace
  the runtime hash working variable. Explicit `scalar(payload)` keeps scalar-held shape payload assignment, so
  `set(scalar(payload), [value])` does not initialize array working variable `payload`. Added Rust runtime locks
  and two Perl-oracle fixtures, bringing the corpus oracle to 32 fixtures. Frontier -> `.1.6`.

- `2026-06-29`: **`.1.2.3.5.3` DONE — Rust shape-literal value parity landed.**
  Rust now parses direct array/hash shape literals as value expressions and evaluates them through normal
  expression recursion. Direct shape elements, keys, and values compose with scalar bare reads, primitive
  literals, helper calls, direct access, and nested shapes; quoted hash keys remain fixed field names. Added Rust
  parser/runtime locks and two Perl-oracle fixtures, bringing the corpus oracle to 30 fixtures. This leaf
  deliberately preserves the `.1.2.3.5.4` boundary: `name = [value]` on Rust remains scalar-held shape payload
  assignment until Rust mirrors the Perl aggregate target-kind inference contract. Frontier -> `.1.2.3.5.4`.

- `2026-06-29`: **`.1.2.3.5.2` DONE — Perl RHS shape target-kind inference landed.**
  Direct RHS shape literals infer aggregate targets when the assignment target is bare: `items = [value]` /
  `set(items, [])` assign array working variable `@items`, and `meta = { key => value }` / `set(meta, {})`
  assign hash working variable `%meta`. Non-shape RHS values remain scalar assignment, and explicit
  `scalar(name)` targets preserve scalar-held array/hash payload assignment. Direct shape initializers in
  `declare(array, ...)` and `declare(hash, ...)` now unwrap lowered shape members instead of raw payload text.
  Phase0 PASS (`989` tests); mdBook/KM/live docs updated; full local CI PASS. Frontier -> `.1.2.3.5.3`.

- `2026-06-29`: **`.1.2.3.5.1` DONE — Perl shape-literal value expressions landed.**
  Direct `[]` / `{}` shapes now lower as DSL value expressions on the Perl reference. Non-empty shapes lower
  through accepted value-expression rules, so `[value]` and `{ key => value }` read scalar working variables
  and auto-supply `my $value` / `my $key`; fixed hash field names must be quoted. Target inference was deferred
  to `.1.2.3.5.2`. Phase0 PASS (`988` tests); mdBook updated. Frontier -> `.1.2.3.5.2`.

- `2026-06-29`: **`.1.2.3.5` DONE/SPLIT — RHS-shape/type inference split by mechanism.**
  Ground truth shows raw empty `[]`/`{}` already pass through Perl as scalar value expressions, but do not
  initialize aggregate working variables; non-empty shapes need expression-aware lowering before settled scalar
  reads compose inside shapes; Rust has no bracket/brace value-expression parser. The next children are
  `.1.2.3.5.1` Perl shape-literal values, `.1.2.3.5.2` Perl target-kind inference, then `.1.2.3.5.3` /
  `.1.2.3.5.4` Rust parity. No engine/book behavior changed. Frontier -> `.1.2.3.5.1`.

- `2026-06-29`: **`.1.2.3.4` DONE — Rust scalar bare-read parity landed.**
  Rust now accepts bare scalar working-variable reads in the accepted scalar slots: `return(value)`,
  `set(out, value)`, `name = value`, `items += value`, `meta[key] = value`, and `foo["a"][idx]`. Runtime
  evaluation already read `Expr::Variable` from the scalar working map, so the slice removes parser
  reservations and locks the behavior with Rust parser/runtime tests plus three new oracle fixtures. RHS-shape
  inference stays later and is now tracked as `.1.2.3.5`. Oracle corpus PASS over 28 fixtures; mdBook/KM/local
  gates PASS. Frontier -> `.1.2.3.5`.

- `2026-06-29`: **`.1.2.3.3.3` DONE — Perl direct-access bare path atoms landed.**
  `foo["a"][z]` now lowers like `foo["a"][scalar(z)]` to `$foo->{"a"}->[$z]` and auto-supplies one
  `my $z` per rule when needed. Quoted path segments remain hash keys, numeric/helper segments remain array
  indexes, primitive literals and engine locals are not claimed, `scalaref(...)` keeps its historical path
  semantics, and RHS-shape inference is still later. Phase0 PASS (`1..987`); mdBook updated. Frontier ->
  `.1.2.3.4`.

- `2026-06-29`: **`.1.2.3.3.2` DONE — Perl scalar mutation-slot bare reads landed.**
  `items += VALUE`, `set_key(meta, KEY, VALUE)`, and `meta[KEY] = VALUE` now lower non-reserved bare
  key/RHS identifiers to scalar working-variable reads and auto-supply one `my $NAME` per rule when needed.
  Target inference is unchanged (`@items` / `%meta`), primitive literals stay exact, reserved engine locals
  are not claimed, direct path atoms remain deferred, and all-bare `push(A,B)` remains child-call syntax.
  Phase0 PASS (`1..986`); mdBook updated. Frontier -> `.1.2.3.3.3`.

- `2026-06-29`: **`.1.2.3.3.1` DONE — Perl scalar source-slot bare reads landed.**
  `return(NAME)`, `set(out, NAME)` / `assign(out, NAME)`, and scalar operator `out = NAME` now lower to
  scalar working-variable reads and auto-supply one `my $NAME` per rule when needed. Primitive literals remain
  exact; `trueword` / `undefine` are scalar identifiers in these source slots. Mutation key/RHS slots, direct
  path atoms, generic helper arguments, and all-bare `push(A,B)` remain outside this leaf. Phase0 PASS
  (`1..985`); mdBook updated. Frontier -> `.1.2.3.3.2`.

- `2026-06-29`: **`.1.2.3.3` SPLIT — Perl scalar bare reads divided by lowering seam.**
  TOOLBOX probes and code-read show the remaining scalar Channel 2 work is not one safe code change:
  return/assignment source slots still emit raw barewords; mutation key/RHS slots cross scanner/lowerer guards;
  direct-access bare path atoms have an explicit rejection and need the scalar-index rule stated. Added
  `.1.2.3.3.1` (return/assignment source slots), `.1.2.3.3.2` (mutation key/RHS slots), and `.1.2.3.3.3`
  (direct-access bare path atoms). No engine/book behavior change. Frontier -> `.1.2.3.3.1`.

- `2026-06-29`: **`.1.2.3.2` DONE — Rust aggregate bare value-read parity landed.**
  `array_copy`, `hash_copy`, and `copy` now pass bare aggregate names through the same target resolvers used by
  mutation/typed-wrapper paths, with `copy(NAME)` preserving the array-first rule and `copy(hash(NAME))`
  preserving the explicit hash form. Added 4 Rust integration locks and 4 Perl-oracle fixtures; corpus oracle
  PASS over 25 fixtures; full Rust runtime suite PASS (116 unit tests, 25 oracle fixtures, 54 integration
  tests); clippy EXIT 0 with existing warning baseline. Scalar bare reads, bare key/RHS forms, and bare direct
  access remain deferred. Frontier -> `.1.2.3.3`.

- `2026-06-29`: **`.1.2.3.1` DONE — Perl aggregate bare value-read auto-existence landed.**
  `_collect_auto_working_var_decls` now collects aggregate bare snapshot reads that already lower to sigiled
  aggregate variables: `array_copy(NAME)` and `copy(NAME)` auto-supply `my @NAME`, while `hash_copy(NAME)`
  auto-supplies `my %NAME`. The collector remains literal-masked, reserved-name guarded, and deduped against
  wrapped/declared/mutation paths. Scalar bare reads (`return(NAME)`), bare RHS/key forms, and bare direct-access
  path atoms remain deferred to the scalar Channel 2 leaves. Focused source/runtime/no-leak probe PASS; phase0
  PASS (`1..984`, 17 assertions in the new subtest). Book/KM/live docs updated. Frontier -> `.1.2.3.2`.

- `2026-06-29`: **`.1.2.3` SPLIT — Channel 2 divided by aggregate vs scalar value-read surfaces.**
  TOOLBOX/code-read ground truth shows aggregate bare value reads already lower on Perl but lack safe
  auto-existence, Rust keeps those bare reads out of aggregate-copy resolvers, and scalar-like value reads are
  still a separate Perl bareword/raw-code problem. Added `.1.2.3.1` (Perl aggregate auto-existence),
  `.1.2.3.2` (Rust aggregate parity), `.1.2.3.3` (Perl scalar bare reads), and `.1.2.3.4` (Rust scalar
  parity). No engine/book behavior change. Frontier -> `.1.2.3.1`.

- `2026-06-29`: **`.1.5.5.2` SUPERSEDED/MERGED — bare direct-access path atoms now owned by `.1.2.3`.**
  KM + TOOLBOX reverify after `.1.5.5.1` confirmed `foo["a"][9]["b"][z]` remains raw while
  `return(z)` remains a bareword; Rust keeps the parser rejection lock. Implementing `[z]` locally would
  smuggle Channel 2 into direct access, so the coherent owner is new `.1.2.3` (value-position bare-word reads
  + RHS-shape/type inference). No engine/book behavior change. Frontier -> `.1.2.3`.

- `2026-06-29`: **`.1.5.5.1` DONE — direct nested access with explicit path segments landed.**
  Perl lowers direct mixed access through the same dereference semantics as `scalaref(...)`: quoted string
  segments become hash keys and numeric/helper segments become array indexes. Rust now has a `NestedAccess`
  expression with key/index segments and evaluates it from the scalar-held base payload. One-level
  `name[index]` stays the legacy indexed-variable form, and bare path atoms such as `[z]` remain deferred to
  `.1.5.5.2` / Channel 2. Phase0/Rust/oracle/book/KM/local gates green. Frontier -> `.1.5.5.2`.

- `2026-06-29`: **`.1.5.5` SPLIT — direct nested access divided by the Channel 2 boundary.**
  TOOLBOX probes show direct `foo["a"][9]["b"][scalar(z)]` is not yet a valid lowered value expression:
  it passes through as `foo["a"][9]["b"][$z]` and generated handler compilation fails near `][`.
  Existing `scalaref(foo,{"a"}[9]{"b"}[scalar(z)])` remains the working explicit form and lowers to
  `$foo->{"a"}->[9]->{"b"}->[$z]`. Bare segment `z` is still not a variable read, so the full brainstorm
  spelling `foo["a"][9]["b"][z]` is deferred to Channel 2. `.1.5.5.1` now owns explicit-segment direct
  access; `.1.5.5.2` owns bare-segment/Channel-2 coordination. No engine/book behavior change in this split
  slice. Frontier -> `.1.5.5.1`.

- `2026-06-29`: **`.1.5.4` DONE — statement separator contract landed.**
  Newline and semicolon are now the only top-level canonical DSL statement separators. Perl emits generated
  terminators for newline-separated lowered statements, so `set(name,"a")` followed by
  `return(scalar(name))` compiles and runs; semicolon-separated statements preserve the author semicolon.
  Plain same-line whitespace is not a separator: adjacent helper statements on one physical line require `;`
  and otherwise remain explicit blockers, matching Rust parser rejection. Nested semicolons inside expression
  payloads remain protected, and Bootstrap keeps fluent attached-control tails working by inserting internal
  newlines. Verification: phase0 PASS (`1..982`), oracle corpus 20 fixtures, focused Rust parser/runtime tests
  PASS, Rust corpus oracle PASS, full Rust runtime PASS, mdBook/KM updated, and final gates green. Frontier ->
  `.1.5.5`.

- `2026-06-29`: **`.1.5.3` DONE — function-call spacing and mandatory-call-parentheses locks landed.**
  Helper calls keep the uniform `callee(args)` shape. Optional whitespace before `(` is accepted at supported
  statement/value sites including `return (value)`, `set (name,value)`, `cat ("a","b")`, `scalar (name)`,
  operator RHS calls, and hash-index key/RHS calls. No-parenthesis helper spellings remain out of scope:
  `set name,"v"`, `return scalar name`, and `return(cat "a","b")` are not helper calls. Verification: phase0
  PASS (`1..981`), oracle corpus 19 fixtures, focused Rust parser/runtime tests PASS, Rust corpus oracle PASS,
  book/KM updated, and final gates green. Frontier -> `.1.5.4`.

- `2026-06-29`: **`.1.5.2` DONE — primitive literal parity landed on Perl and Rust.**
  Exact primitive literals (`"..."`, `'...'`, numbers, `undef`, `true`, `false`) are now typed value
  expressions in return payloads, mutation RHS positions, hash-index keys/values, and flow predicates.
  Perl lowers `true`/`false` to `JSON::PP` booleans instead of strings, and exact matching keeps
  `trueword`/`undefine` outside the literal path. Scanner/lowerer/legacy child-call guards agree that
  `push(items,false)` is an explicit append while non-literal all-bare forms keep their old child-call
  meaning. Rust gained statement-form `if/elseif/else/endif` gating so `if(false)` skips inactive branch
  statements; the lazy value-form `if(cond,then,else)` helper is unchanged. Verification: phase0 PASS
  (`1..980`), oracle corpus 18 fixtures, focused Rust `.1.5.2` tests PASS, Rust corpus oracle PASS, book/KM
  updated, and final gates green. Frontier -> `.1.5.3`.

- `2026-06-29`: **`.1.5` SPLIT — literal/nested-access/call/semicolon surface decomposed before code.**
  KM retrieval plus TOOLBOX/code-read showed the original leaf crossed four independent seams. Primitive
  literals need parity work because Perl currently returns `true`/`false` as strings while Rust has typed
  booleans. Optional whitespace before `(` works at supported call sites and needs focused locks. Statement
  separators need a dedicated parity leaf: `StatementSplit` detects adjacent newline statements, but Perl
  lowering emits invalid generated code without `;`, while Rust accepts broader whitespace-separated
  statements. Direct any-depth nested access remains open and must coordinate with Channel 2 bare
  value-position reads. `.1.5.1` audit/split is done; frontier -> `.1.5.2`.

- `2026-06-29`: **`.1.3.4.3` DONE — hash-index assignment operator `name[key] = value` landed on Perl and
  Rust.** Top-level `NAME[KEY] = RHS` now lowers/runs like `set_key(NAME, KEY, RHS)` for explicit key/value
  expressions, and bare hash targets auto-exist as per-invocation lexicals on the Perl reference. Rust gained a
  statement-only `AssignHashIndex` AST/execution path and rejects that form in nested value evaluation. The
  accepted boundary is narrow by design: `meta["stage"] = "v"`, `meta[cat("s","tage")] = cat("v","!")`, and
  `meta[scalar(key)] = scalar(value)` work; bare key/RHS identifiers remain pending behind Channel 2; pure
  value-form `set_key(hash_expr, key, value)` remains copy-valued. Verification: TOOLBOX parity probes, phase0
  PASS (`1..979`), oracle corpus regenerated with 16 fixtures, focused Rust core/runtime tests PASS, Rust
  corpus oracle PASS, mdBook/KM updated, and final gates green. `.1.3.4` and `.1.3` are now closed. Frontier →
  `.1.5`.

- `2026-06-29`: **`.1.3.4.2` DONE — array append operator `items += value` landed on Perl and Rust.**
  Top-level `NAME += RHS` now lowers/runs like explicit append forms for explicit RHS expressions, and bare
  array targets auto-exist as per-invocation lexicals on the Perl reference. Rust gained a statement-only
  `AssignArrayAppend` AST/execution path and rejects that form in nested value evaluation. The accepted
  boundary is narrow by design: `items += scalar(value)` works, while `items += value` remains pending behind
  Channel 2; child-call `push(A,B)`, increment-like syntax, scalar assignment, and hash-index assignment remain
  separate. Verification: TOOLBOX parity probes, descriptor/source/runtime probes, phase0 PASS (`1..978`),
  oracle corpus regenerated with 15 fixtures, focused Rust core/runtime tests PASS, Rust corpus oracle PASS,
  mdBook/KM updated, and final gates green. Frontier → `.1.3.4.3`.

- `2026-06-29`: **`.1.3.4.1` DONE — scalar assignment operator `name = value` landed on Perl and Rust.**
  Top-level `NAME = RHS` now lowers/runs like `set(NAME,RHS)` / `assign(NAME,RHS)`, and bare scalar targets
  auto-exist as per-invocation lexicals on the Perl reference. Rust gained a statement-only `AssignScalar`
  AST/execution path and rejects that form in nested value evaluation. The accepted boundary is narrow by
  design: equality, append, hash-index assignment, helper keyword args, nested assignments, and Channel 2
  bare value-position reads remain pending. Verification: TOOLBOX parity probes, descriptor/source/runtime
  probes, phase0 PASS (`1..977`), oracle corpus regenerated with 14 fixtures, focused Rust core/runtime tests
  PASS, full Rust runtime suite PASS, mdBook/KM updated, and final gates green. Frontier → `.1.3.4.2`.

- `2026-06-29`: **`.1.3.4` SPLIT — operator syntax family decomposed into scalar, array, and hash
  implementation leaves.** KM retrieval plus TOOLBOX probes confirmed `name = "ok"`, `items += "a"`, and
  `name["k"] = "v"` still pass through as RAW_PERL blockers on Perl, while the settled function forms
  (`set(...)`, `push(...)` for unambiguous value expressions, `set_key(...)`) lower correctly. A descriptor
  probe on a spec containing all three operators reports three `RAW_PERL` fallback events and three
  language-agnostic blocker statements. Rust code-read shows lifecycle code is parsed as `Stmt { expr }`, with
  no assignment/append/hash-set statement variants, so all operators also need parser/AST/runtime support
  before execution. `.1.3.4` is now a container: `.1.3.4.1` scalar `name = value`, `.1.3.4.2` array
  `items += value`, `.1.3.4.3` hash `name[key] = value`. No engine/book behavior change in this split slice;
  frontier → `.1.3.4.1`.

- `2026-06-29`: **`.1.3.3` DONE — hash function mutation statement `set_key(name,key,value)` landed while
  preserving pure `set_key(hash_expr,key,value)`.** Perl now recognizes top-level `set_key(...)` as an ASSIGN
  statement when the first argument names a hash target, lowering it to direct `$name{key} = value` mutation
  and auto-supplying exactly one preamble `my %name` for bare targets. Rust mirrors this in
  `Engine::execute_block()` by recognizing top-level `set_key(...)` before normal expression evaluation and
  calling `RuntimeContext::set_hash_entry`. Nested/value-form `set_key(hash(...), key, value)` remains the
  pure copy-valued helper and is locked not to mutate the source hash. Added +1 phase0 subtest, 2 Rust
  integration tests, and oracle fixture `terse_1_3_3_set_key_statement_hash`; book + KM updated. Verification:
  phase0 PASS (976); focused Rust `terse_1_3_3` PASS; corpus oracle PASS over 13 fixtures; mdBook build EXIT
  0; Knowledge Map + memory-architecture + doctrine checks OK. Frontier → `.1.3.4` (operator syntax family).

- `2026-06-29`: **`.1.3.2` DONE — array function spelling `push(target,value)` landed without breaking
  child-call `push(...)`.** Selected disambiguation: `push(target,value)` is an explicit-value append when the
  value expression is unambiguous/non-all-bare (`"literal"`, `scalar(value)`, `array(target)` + wrapped value,
  helper values like `cat(...)`, or `call(Child)`). All-bare two-identifier `push(A,B)` keeps the child-call
  meaning (`A` rule into `B` accumulator); append a working-variable value as `push(items, scalar(value))`
  or `push_value(items, scalar(value))` until Channel 2 bare value-position reads land. Perl recognition extended in
  the `push_value` contract/scanner/lowering path, and the auto-array collector now uses a balanced parser scan
  for `push(...)` so nested comma values such as `cat("a","b")` declare exactly one target array. Rust already
  had the `"push_value" | "push"` runtime alias; this slice locks it with a Perl-oracle fixture and integration
  test. Verification: TOOLBOX lowerings prove explicit append vs child-call precedence; descriptor/runtime probe
  returns `["a","b"]` with zero fallback/unresolved; source dump for nested/comma value has one `my @items`;
  phase0 PASS (975); focused Rust test PASS; corpus oracle PASS over 12 fixtures; mdBook build EXIT 0;
  Knowledge Map + memory-architecture checks OK; full local gate EXIT 0. Book/KM/live docs updated. Frontier →
  `.1.3.3` (hash function mutation semantics).

- `2026-06-29`: **`.1.3` SPLIT — mutation surface separated by mechanism; `.1.3.1` scalar function
  audit done; frontier → `.1.3.2`.** Knowledge Map retrieval first found the `.1.2` bare-target and
  accumulator-convention constraints. TOOLBOX probes then showed the leaf cannot be one implementation slice:
  `set(name,"ok")` already equals `assign(name,"ok")` and runs; `push_value(items,"a")` lowers/runs, but
  requested `push(items,"a")` passes through as raw Perl and conflicts with the existing
  `push(Rule[,target[,index]])` child-call convention; `return(set_key(name,"k","v"))` works as a pure Perl
  hash value but `set_key(name,...)` is not a standalone mutation statement and Rust only updates when arg0 is
  already a hash; `name = "ok"`, `items += "a"`, and `name["k"] = "v"` pass through as invalid/raw Perl, and
  Rust has no assignment statement AST. Created KM [[terse-mutation-surface-ground-truth]]; no engine/book
  change.

- `2026-06-29`: **`.1.4.2` DONE — Rust lockstep parity for terse helper renames.** `Engine::call_helper()`
  now recognizes `set` through the `assign` arm and `cat` through the `concat` arm, and adds a dedicated
  `copy` arm that clones array/hash values or resolves wrapped array/hash targets by kind. Added
  `resolve_hash_target` and one-bare-variable `hash`/`h` target reads so `copy(h(m))` matches
  `hash_copy(h(m))` without broadening deferred Channel 2 bare value-position reads. Locked with 2 Perl-oracle
  fixtures (`terse_1_4_2_set_cat_copy_array`, `terse_1_4_2_copy_hash_symbol_empty`) and 3 integration tests
  (`set`+`cat`+`copy(array)`, hash target/hash value copy, per-parse bare `set` target). Verification:
  generator `perl -c` OK; oracle regeneration OK; focused `terse_1_4_2` PASS; corpus oracle PASS (11
  fixtures); full Rust runtime suite PASS (116 unit + 36 integration + oracle harness); `cargo clippy` zero-new
  against the existing 13-warning baseline; phase0 **975 green**; full local gate EXIT 0. No book change
  because `.1.4.1` already documented the variant-neutral helper contract. **`.1.4` container done; next
  frontier: `.1.3`** (mutation surface, scope/split first).

- `2026-06-24`: **`.1.4.1` DONE — Perl reference: terse helper renames `set`/`cat`/`copy` lower
  identically to `assign`/`concat`/`array_copy`+`hash_copy`.** PNT (user-directed loop, fresh session)
  implemented the first `.1.4` child. **TOOLBOX-first** `call_spec_handler_subst` ground truth
  (dump-don't-guess; `perl -Iperl` confirmed `perl/LinkedSpec.pm`) re-verified the gap, then implemented the
  three shapes the split pass prescribed **plus every other site each canonical name is recognized**, so the
  aliases are true byte-identical aliases everywhere: (i) `cat`→`concat` + `set`→`assign` in
  `_normalize_method_name` (`ActionIR/MethodExpr.pm`); (ii) `set` statement-level recognition extended
  (`\bassign\s*\(`→`\b(?:assign|set)\s*\(`) at the `assign_value` contract (`Contracts.pm`), its IR-event
  scanner (`Scanner/PrimitivePipelineRules.pm`), and the bare-arg auto-`my` collector (`RuleIR/EmitContext.pm`,
  so bare `set` auto-exists like `assign` — `.1.2.1` parity); (iii) a dedicated array-then-hash `copy` dispatch
  in `MethodLowering._lower_method_value_expr`, plus `copy` added to the declare-init recognizers
  (`DeclareMethod` 136/163), the return-payload guard+rewriter lists (`MethodLowering` 1650/1658), the FlowExpr
  value-expr prefix list (assignment-source path), the bootstrap general-payload gate (`Core.pm`, `cat`), and
  the four `looks_like_{array,hash}_value_expr` recognizers (so `copy` stays first-class in numeric-reducer /
  `coalesce` array-vs-hash type inference, resolving kind array-first). **Proof:** `call_spec_handler_subst`
  byte-equal for the 4 headline + 11 composed forms (assignment source scalar/array/hash, push value, nested
  return payload, `num_sum`/`num_avg`/`coalesce` over `copy`); `set` produces the same `ASSIGN` canonical
  ActionIR node as `assign`; a real terse spec (`set`+`cat`+`copy`) runs end-to-end **byte-identical** to its
  canonical twin (`["a!","b!","c!"]`, stable on re-run); **all 20 shipped specs byte-identical (0 diff)** — every
  alias add is guarded by the new spelling, which no shipped spec uses. **+4 phase0 subtests / 31 assertions**
  (`spec_format_terse_1_4_1_*`): **phase0 971→975 green**; `bash tools/run_ci_local.sh` **EXIT 0** ("Result:
  PASS", 975); ratio 1.0000; `perl -c` clean on all 8 edited modules; `mdbook build` EXIT 0. **Book (3):**
  `appendix/helper-contract-catalog.md` (per-helper Terse-spelling lines + a new "Terse Helper Renames"
  subsection), `dsl/value-container-flow-helper-reference.md`, `dsl/declaration-helper-reference.md` — taught
  the renames as canonical with the old names as deprecated (not-yet-retired) aliases. KM card
  [[terse-helper-rename-lowering-sites]] updated (`.1.4.1` landed; full site list; reverify now proves parity;
  map regenerated). Frontier → `.1.4.2` (Rust `Engine::call_helper()` lockstep parity). The `.1.4.1` change is
  "landed against the universal contract" only once `.1.4.2` closes.
- `2026-06-24`: **`.1.4` SPLIT → `.1.4.1` (Perl reference) + `.1.4.2` (Rust parity).** PNT (user-directed
  loop, fresh session) picked `.1.4` (helper renames `assign`→`set`, `concat`→`cat`,
  `array_copy`/`hash_copy`→`copy`, the next terse-format implementation leaf) and, instead of coding, split
  it after a **TOOLBOX-first `call_spec_handler_subst` ground-truth pass** (dump-don't-guess; `perl -Iperl`
  confirmed it loads `perl/LinkedSpec.pm` over the stale `PERL5LIB`). The probes proved the three terse
  spellings are all currently **UNRECOGNIZED**: `set(scalar(x),1)`→`set(scalar(x), 1)` (vs `assign`→`$x = 1`),
  `cat("a","b")`→`cat("a","b")` (vs `concat`→the concat do-block), `copy(a(items))`→`copy([items])` partial /
  `copy(h(m))`→`copy(h(m))` (vs `array_copy`→`[@items]` / `hash_copy`→`{%m}`). The change has **three distinct
  implementation shapes** spanning **two variants with separable ownership** (Perl `ActionIR/*` + phase0 +
  book vs Rust `engine.rs` + oracle + cargo — COMMIT.md forbids bundling), so per the splitting rule
  (mirroring `.1.1`→`.1.1.1`/`.1.1.2` and `.1.2`→`.1.2.1`/`.1.2.2`, ADR 0006) `.1.4` became a container with
  `.1.4.1` (Perl reference) + `.1.4.2` (Rust lockstep parity). **Ground truth (own probes + code read):**
  `cat`→`concat` is a pure rename → `_normalize_method_name` (`ActionIR/MethodExpr.pm:19-26`, applied
  pre-lowering, same seam as `s`/`a`/`h`); `set`→`assign` is **statement-level** (`ActionIR/Contracts.pm:1749/1753`
  `\bassign\s*\(` + `DeclareMethod` + `MethodLowering._lower_assign_statement`) and is NOT reached by
  `_normalize_method_name` alone (so `.1.4.1` extends the statement-level recognition); `copy` is **not** a
  pure rename — it unifies `array_copy`/`hash_copy` and needs a dedicated dispatch in
  `MethodLowering._lower_method_value_expr` resolving array-then-hash symbol kind (`[@name]` else `{%name}`).
  Rust: all four canonical helpers live in one `Engine::call_helper()` match
  (`rust/linkedspec-runtime/src/engine.rs`: `assign`@711, `array_copy`@735, `concat`@820, `hash_copy`@1833;
  aliases = pipe arms); `.1.4.2` pipes `set`/`cat` and adds a separate value-type-dispatching `"copy"` arm.
  Direction per ADR 0007: new terse names canonical, old names deprecated aliases that lower identically
  (retirement is a later explicit leaf); the 20 shipped specs (old names) must stay byte-identical. Recorded
  the ground truth in Decisions + KM card [[terse-helper-rename-lowering-sites]] (map regenerated). Frontier
  → `.1.4.1`. **DOCS/TREE/KM only — no engine or book change** in this split slice; baseline doctrine + KM
  gates green. Next PNT: implement `.1.4.1` (Perl reference — `cat`/`set`/`copy` recognition; signoff-critical
  codegen; dump-don't-guess, all-20-specs byte-identical proof).
- `2026-06-24`: **`.1.2.2` DONE — Rust lockstep parity for `.1.2.1`; it REQUIRED a Rust engine change
  (unlike `.1.1.2`).** PNT (user-directed, single-leaf cadence). **TOOLBOX-first** throwaway Rust integration
  probe (parse→validate→compile→execute, dump-don't-guess) on bare-vs-wrapped specs: although the
  interpreter's per-parse `RuntimeContext` HashMaps auto-vivify (the `.1.1.2` finding), a **bare** arg-position
  target was NOT reaching the working var — `resolve_scalar_target`/`resolve_array_target`
  (`rust/linkedspec-runtime/src/engine.rs`) only extracted the name from a WRAPPED `scalar(VAR)`/`array(VAR)`
  Call; a bare `Expr::Variable` fell through to `val.to_str()` (evaluated value → `""`). Probe BEFORE: bare
  `assign(v,"ok")`→`[null]`, bare `push_value(items,..)`→`[[]]` vs wrapped `["ok"]`/`[["a","b"]]` — a genuine
  divergence from the Perl `.1.2.1` reference. **Fix:** both resolvers now also accept a bare `Expr::Variable`
  target and return its name (mirroring Perl's `^(\w+)$` fallback in `ValueExpr::_extract_*_symbol_name`); the
  HashMap then auto-vivifies it (no `declare`; fresh ctx per `execute` ⇒ no leak). Scoped to Channel-1 target
  positions via an `allow_bare` flag — `true` for `push_value`/`push_nonempty`, `false` for the value-position
  reads `array_copy`/`hash_copy` (bare value-position reads are Channel 2, not this leaf). Probe AFTER: bare ==
  wrapped (`["ok"]`, `[["a","b"]]`). **Locked:** 2 oracle fixtures `autoexist_{scalar,array}_bare_arg`
  (`tools/gen_oracle_corpus.pl`, regenerated — existing 7 byte-identical; `corpus_oracle` checks Rust == the
  Perl reference) + 4 `terse_1_2_2_*` integration tests (scalar/array/push_nonempty value anchors,
  bare==wrapped==declare convergence, per-parse no-leak via same-engine re-run). **cargo 248→252 green**, 9/9
  oracle PASS, `cargo clippy` zero-new (engine.rs 11 baseline — my added `if allow_bare` nest flattened to a
  tuple `if let`; test file adds 0), `perl -c gen_oracle_corpus.pl` OK; **phase0 971 green** (Perl untouched),
  `bash tools/run_ci_local.sh` **EXIT 0**; no book change (variant-agnostic — `.1.2.1` already taught the
  contract; Rust now conforms). KM card [[terse-bare-working-vars-engine-gaps]] updated (Rust parity + the
  engine-change contrast with `.1.1.2`). **`.1.2` Channel 1 complete on BOTH variants;** `.1.2` stays `active`
  (Channel 2 `.1.2.3`+ pending, added once `.1.5` is designed). Frontier → `.1.4` (helper renames). Recursive/REP
  idiom stays deferred to `RUST-PARITY`.
- `2026-06-24`: **`.1.2.1` DONE — Perl arg-position bare working-variable auto-existence (Channel 1).**
  PNT (user-directed, fresh session) implemented the first `.1.2` child. **TOOLBOX-first
  `dump_parser_source` ground truth** (scratchpad `probe_terse_1_2_1.pl`, isolated bare forms,
  dump-don't-guess; `perl -Iperl` confirmed `perl/LinkedSpec.pm` loads over the stale `PERL5LIB`) proved a
  bare `assign(count,…)` lowers to `$count = …` and a bare `push_value(items,…)`/`push_nonempty` to
  `push @items` (`_lower_assign_statement` extracts scalar first; the push family is array) — each via the
  `^(\w+)$` fallback in `ValueExpr::_extract_*_symbol_name` — but neither got a preamble `my` (the `.1.1.1`
  collector matched only WRAPPED forms), leaving a leaky package global. **Fix:** extended
  `RuleIR::EmitContext::_collect_auto_working_var_decls` with a second collection pass (refactored the
  per-ref add into a shared `$record` closure) that scans the literal-masked RAW blocks for a bare working
  var in a type-implying *first-arg* position and records it with the **position-implied** sigil —
  `assign`→`$`, `push_value`/`push_nonempty`→`@`. The `\s*,` after the bare name means a WRAPPED target
  (name then `(`) is NOT matched by the bare pattern — it stays on the wrapped path; both dedup (by
  sigil+name, vs the `@<label>` accumulator + any same-sigil `my`) to one `my`. **Proof:** generated source
  for all 20 shipped specs, mine-vs-stashed, diffed = **0 diff** (the corpus has no un-wrapped arg-position
  targets — cleaner than `.1.1.1`); isolated bare probes now emit the `my` (and
  `assign(pair, set_key(hash(pair),…))` correctly declares BOTH `my %pair` (wrapped) and `my $pair` (the
  bare assign target — a separate scalar holding the hashref, previously leaky)). **+3 phase0 subtests /
  17 assertions** (`spec_format_terse_1_2_1_*`: bare scalar+array+push_nonempty auto-exist with the `my` in
  the preamble before `while(1)`; deferred `.push(target)` boundary; dedup vs wrapped/declare = single `my`;
  integrated per-invocation no-leak run-twice): **phase0 968→971 green**; `bash tools/run_ci_local.sh`
  **EXIT 0** ("[ci] local CI gate passed", 971); ratio 1.0000; `mdbook build` EXIT 0. **Book (3):**
  `dsl/declaration-helper-reference.md` (taught wrapper-optional-in-arg-position + corrected the outdated
  "argument position is a later step" note), `appendix/helper-contract-catalog.md` §1 + the
  `assign`/`push_value`/`push_nonempty` entries, and `dsl/value-container-flow-helper-reference.md`.
  **Scope (signoff):** Channel 1 covers the unambiguous first-arg value-helper positions only; the
  child-append `push(Rule[, target])` / fluent `.push(target)` target (first arg is a rule name —
  ambiguous) and the bare HASH target (no clean arg-position trigger — `set_key(name,…)` is a value-position
  read) are Channel 2, explicitly deferred. KM [[terse-bare-working-vars-engine-gaps]] updated (Channel 1
  closed). Frontier → `.1.2.2` (Rust lockstep parity — likely holds by architecture; assess + lock next).
- `2026-06-24`: **`.1.2` SPLIT → `.1.2.1` (Perl, Channel 1) + `.1.2.2` (Rust parity).** PNT (user-directed
  loop, fresh session) picked `.1.2` (remove container wrappers + type inference, the next terse-format
  implementation leaf) and, instead of coding, split it after a **TOOLBOX-first `dump_parser_source`
  ground-truth pass** (dump-don't-guess; `perl -Iperl` confirmed it loads `perl/LinkedSpec.pm` over the
  stale `PERL5LIB`). The dumps proved a **bare** (un-wrapped) working variable has two distinct,
  separately-sized behaviors → two inference channels: **Channel 1 (arg position)** — a bare name already
  lowers to the correctly-sigil'd variable (`assign(count,v)`→`$count = v`; `push_value(items,..)`→
  `push @items, ..`) BUT gets **no auto-`my`** (the `.1.1.1` collector matches only WRAPPED
  `scalar/array/hash(NAME)`), so it is a **leaky package global** — the exact `.1.1.1` hazard, still open
  for bare forms; and **Channel 2 (value position)** — a bare word is **not** recognized as a variable
  read (`return(count)`→ bareword `return count ;`, not `$count`), which plus RHS-shape inference
  (`[]`→array, `{}`→hash) needs var/call/literal disambiguation and couples with `.1.5` literals.
  Per the splitting rule (Perl reference + lockstep Rust parity are separable, ADR 0006 — mirroring
  `.1.1`→`.1.1.1`/`.1.1.2`), made `.1.2` a container and added `.1.2.1` (Perl, Channel 1: arg-position
  bare working-var auto-existence — the self-contained, lowest-risk first slice that directly extends the
  `.1.1.1` collector and closes the leaky-global gap) + `.1.2.2` (Rust parity). Channel 2 leaves
  (`.1.2.3`+) are **not** pre-published — they are added once `.1.2.1` lands and `.1.5` literal syntax is
  designed (avoiding vague placeholders). Wrappers stay accepted aliases during migration (gradual, ADR
  0007); the shipped corpus uses them pervasively (declare 87 / assign 103 / scalar 133 / array 134 / hash
  36), so they must keep compiling byte-identically. Recorded the ground truth in Decisions + KM card
  [[terse-bare-working-vars-engine-gaps]] (map regenerated). Frontier → `.1.2.1`. **DOCS/TREE/KM only —
  no engine or book change** in this split slice; baseline gates green. Next PNT: implement `.1.2.1`
  (signoff-critical Perl codegen — a fresh session is reasonable; bootstrap, dump-don't-guess).
- `2026-06-24`: **`.1.1.2` DONE — Rust lockstep parity for auto-existing variables (no engine change).**
  PNT (user-directed loop, fresh session) assessed the Rust parity for `.1.1.1` per the leaf's
  blocked-vs-doable instruction. **TOOLBOX-first ground truth** (throwaway Rust integration probe +
  `perl -Iperl` `LinkedSpec::Get` probe on the same minimal grammars; read `rust/linkedspec-runtime/src/
  {runtime,engine}.rs`): the Rust variant is an **interpreter** (no codegen/`eval`), so working variables
  live in per-parse `RuntimeContext` HashMaps (`scalars`/`arrays`/`hashes`) that **auto-vivify** on write
  and read as `Undef`/empty when absent, and `Engine::execute` builds a **fresh `RuntimeContext` per
  call**. So working variables **already auto-exist** with no `declare`, and a value cannot leak across
  parses — the leaky-package-global hazard the Perl `.1.1.1` change fixed (non-strict generated handlers)
  simply does not exist in Rust. **Outcome: DOABLE, no engine change** — parity holds by architecture; the
  leaf lands as lockstep regression tests + docs. **Cross-variant proof** (divergence-free edge-action
  form = the `.7.1` oracle proof class; recursive/REP forms are blocked by the separate `RUST-PARITY` gap,
  verified returning `[null]`/`[[]]`): scalar no-declare Perl `"ok"`/Rust `["ok"]`; array no-declare Perl
  `["a","b"]`/Rust `[["a","b"]]`; declare twins identical; `array(undef)` Perl `[null]`/Rust `[[null]]` —
  Rust == Perl reference wrapped one level. **Locked:** 5 oracle fixtures `autoexist_{scalar,array}_
  {no_declare,declare}` + `autoexist_undef_literal` (added to `tools/gen_oracle_corpus.pl`, regenerated;
  existing 2 byte-identical) + 4 `terse_1_1_2_*` integration tests (value anchors, declare/no-declare
  convergence, per-parse no-leak via same-engine re-run). **cargo test 244→248 green**; all **7 oracle
  fixtures PASS**; `cargo clippy` zero-new source/test warnings; `perl -c tools/gen_oracle_corpus.pl` OK;
  **phase0 968 green** (Perl untouched), `bash tools/run_ci_local.sh` **EXIT 0**; `mdbook build` EXIT 0
  (no book change — variant-agnostic, `.1.1.1` already taught the contract; Rust now conforms). KM card
  [[rust-working-vars-auto-vivify]] (map regenerated). **`.1.1` container done; `.1.1.1` is now landed
  against the universal contract (ADR 0006/0007). Next: `.1.2`** (remove wrappers + type inference).
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
