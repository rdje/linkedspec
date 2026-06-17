# 0007 — Ratify the terse `.spec` format direction (SPEC-FORMAT-TERSE activated)

- Date: 2026-06-18
- Status: accepted
- Tags: dsl, language-evolution, spec-format, roadmap, doctrine
- Owning tree: [`docs/tasks/SPEC-FORMAT-TERSE.md`](../tasks/SPEC-FORMAT-TERSE.md) (leaf `SPEC-FORMAT-TERSE.0`)

## Context

The `.spec` DSL today is the "raw-Perl-free helper DSL": ceremony wrappers (`declare(...)`,
`scalar()/s()`, `array()/a()`, `hash()/h()`), function-only mutation (`assign`, `push`,
`set_key`), and verbose helper names (`concat`, `array_copy`, `hash_copy`). On 2026-06-15 a
three-round brainstorm converged a terser, fully-composable, Lisp-style direction (recorded in
the KM card [[spec-format-brainstorm-rounds-1-3]]). On 2026-06-16 that direction was transcribed
into the `SPEC-FORMAT-TERSE` task-tree and **parked as `proposed`** ("no decisions finalized";
implementation deferred behind the `RTLUTILS-REGEX-HANG` fix).

On **2026-06-18 the user ratified and activated the direction** (via an AskUserQuestion choice
"Activate SPEC-FORMAT-TERSE now", reached while fixing a book example that used the to-be-retired
`declare()`/`assign()`), and reinforced the key semantics in their own words:

- `assign(x, v)` becomes the operator `x = v` (or the function `set(x, v)`).
- **No sigils** — variables are bare typed identifiers; the `scalar()/array()/hash()` wrappers go.
- Variable **types are inferred** at initialization or by argument position.
- `copy()` is unified — it applies to both arrays/lists and hashes/associative arrays
  (replacing `array_copy`/`hash_copy`).
- arrays, hashes, numbers, and strings have **methods** (method chaining by return type).
- **Everything is an expression** and therefore has a (typed) value — including control-flow
  constructs and `{ ... }` code blocks.

These match the brainstorm card and the tree's Round 1–3 transcription exactly. The brainstorm
being tentative, the tree specifies `.0` (ratify + this ADR) as the first leaf on activation.

## Decision

1. **Adopt the terse direction, Rounds 1–3, as transcribed** in `SPEC-FORMAT-TERSE` and
   [[spec-format-brainstorm-rounds-1-3]]:
   - **Round 1 (vars/types/mutation/functions):** auto-existing variables (no `declare`); no
     `scalar()/array()/hash()` wrappers (bare words are variables or functions, never string
     literals); type inference (RHS shape `[]`/`{}`/scalar + helper arg position); literals
     `"…"`/`'…'`/`42`/`3.14`/`true`/`false`/`undef`; operator **and** function mutation spellings
     (`name = val` / `set`; `name += val` / `push`; `name[k] = v` / `set_key`); `copy()` unifies
     `array_copy`/`hash_copy`; `cat()` replaces `concat`; nested access `foo["a"][9]['b'][z]`;
     calls always `()` with optional space before `()`; semicolons only for same-line statements;
     array end-methods `.push_front/.push_back/.pop_front/.pop_back`.
   - **Round 2 (control flow):** everything is an expression; blocks return their value;
     `if/elseif/else` (parens-cond, block-body, blocks never inside parens); `when`, `otherwise`,
     `default`, `while`, `switch(expr){ case(v){} default{} }`; fluent `.when(cond){}.otherwise{}`;
     lifecycle blocks (`I`/`LS`/… `{ … }`) take a block and drop the value; Lisp-style
     composability everywhere; method chaining by return type (array→array, hash→hash,
     string→string, number→number).
   - **Round 3 (edges + arithmetic):** `->`/`=>` edges kept; grouped `-> A | B { code }` factoring
     (block-less `-> A | B` stays invalid); arithmetic/comparisons as composable functions with
     word **and** symbol spellings (`add`/`+`, `gt`/`>`, …), single/multi-arg helpers, reducers;
     **no operator precedence** — deeply composable like any other call.
   - **Round 4+** (capture/marks, rule modes, split markers, lifecycle semantics) remains a future
     discovery leaf (`SPEC-FORMAT-TERSE.4`), not adopted here.

2. **Migration policy: canonical-new-form + deprecated-old-alias (gradual), then explicit
   retirement.** Each leaf introduces the terse form as canonical while keeping the current
   verbose form as a **deprecated alias that lowers to identical ActionIR**, so the 20 shipped
   `specs/*.spec` and the mdBook keep compiling/running throughout the migration. Old names are
   retired only in a later, explicit leaf, after the shipped corpus + book have been re-authored
   to the terse forms. This preserves the all-target **ActionIR-ready invariant** (ratio 1.0000,
   zero compatibility-surface — ADR [0002](0002-all-target-actionir-ready-invariant.md)) at every
   step. *(Open to user override toward a one-shot hard rename; this ADR is superseded/amended if
   so — see Consequences.)*

3. **`.spec` stays the single universal contract; all variants move in lockstep.** Per ADR
   [0006](0006-multi-backend-vision.md) and the cross-variant-output-parity doctrine, the terse
   format is defined and proven on the **Perl reference first**, then rolled out to **every backend
   (Rust, Julia, Dart) in lockstep** — no per-variant `.spec` dialects, no variant ahead of the
   contract. Each adopted Perl-reference change carries a follow-on parity obligation (e.g.
   `RUST-PARITY`). The mdBook stays the **variant-agnostic** behavioral spec and is updated per
   change — but only **after** the engine implements a form (the book must never demonstrate a
   form the live engine cannot run).

4. **This evolution is a sanctioned exception to the "do not fix the reference engine" default**
   ([[feedback_do-not-fix-reference-engine]]). That default governs *docs-vs-reference
   disagreements* (fix the docs, not the engine). SPEC-FORMAT-TERSE is *intentional language
   evolution*, explicitly user-authorized (2026-06-18) and scoped by this tree to change the Perl
   reference first. The reference is still authoritative; it is being deliberately advanced, not
   "fixed" to match drifted docs.

5. **Implementation leaves are gated by a usable regression suite.** Per-leaf acceptance requires
   the full `t/phase0_regression.t` gate. That gate is currently **hung by the pre-existing
   `RTLUTILS-REGEX-HANG`** (the `RTLUtils::add_header_n_context_clause` catastrophic regex), and
   the tree's own recorded user directive (2026-06-16) was to implement **after** that hang is
   fixed. Therefore: leaf `.0` (this ratification ADR) is design-only and **not** gated; the
   implementation leaves (`.1.x`+) need the gate restored first. The execution-order choice — fix
   `RTLUTILS-REGEX-HANG` first vs proceed with a scoped check — is the immediate next decision and
   is surfaced to the user, not pre-decided here.

## Consequences

- `SPEC-FORMAT-TERSE` moves `proposed` → `active`; `.0` is `done` (this ADR). It becomes the
  active work unit; the `SPEC-LANG-REFERENCE` whole-book scorch is **paused after `.10.5.4`** (the
  terse migration will re-sweep every book example in lockstep with the engine, so finishing the
  2-rule scorch first would duplicate work).
- Each Round-1–3 change is a pickable implementation leaf following the extension-surface order
  (`specs/spec.spec` first → bootstrap-grammar + ActionIR lowering → mdBook + `t/phase0_regression.t`
  → full gate → commit), with the gradual-alias policy above.
- The 20 shipped specs and the book keep working during migration (aliases); a dedicated
  re-authoring + old-name-retirement leaf closes each family.
- Every Perl-reference change owes a lockstep parity change in each other variant before that
  change is considered landed against the universal contract.
- **Open execution decisions surfaced to the user** (gate `.1.x`): (i) confirm the gradual-alias
  migration policy vs a one-shot hard rename; (ii) the `RTLUTILS-REGEX-HANG`-first sequencing vs a
  scoped check for terse implementation leaves. If the migration policy changes, this ADR is
  amended or superseded (layer-C discipline — never silently rewritten).

## Links

- Owning tree: [`SPEC-FORMAT-TERSE`](../tasks/SPEC-FORMAT-TERSE.md) (leaf `.0`).
- Source of record (brainstorm): [[spec-format-brainstorm-rounds-1-3]]
  (`docs/knowledge/spec-format-brainstorm-rounds-1-3.md`).
- Constraints: ADR [0002](0002-all-target-actionir-ready-invariant.md) (ActionIR-ready invariant),
  ADR [0003](0003-raw-perl-free-spec-authoring.md) (raw-Perl-free authoring),
  ADR [0006](0006-multi-backend-vision.md) (multi-backend lockstep).
- Standing default this consciously excepts: [[feedback_do-not-fix-reference-engine]].
- Pivot context: `SPEC-LANG-REFERENCE.10.5.4` (the book leaf where the pivot surfaced).
