# SPEC-FORMAT-TERSE: Evolve the .spec DSL toward a terser, fully-composable format

## Metadata

- Tree ID: `SPEC-FORMAT-TERSE`
- Status: `proposed`
- Roadmap lane: `Overall roadmap — .spec language evolution (terse format)`
- Created: `2026-06-16`
- Last updated: `2026-06-16`
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

- **Proposed / parked.** Not PNT-eligible until explicitly activated.
- Per the user (2026-06-16): implementing these is a **next action AFTER** the pre-existing
  `RTLUTILS-REGEX-HANG` (the `RTLUtils::add_header_n_context_clause` catastrophic-regex phase0
  hang) is fixed and the regression gate is usable again.
- On activation, start with `.0` (ratify direction + ADR), since the brainstorm is tentative
  ("no decisions finalized"); then pick any round/leaf.

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
  Status: `proposed`
  Goal: Evolve the `.spec` DSL toward a terser, fully-composable format (brainstorm Rounds 1–3 + resume 4+)
  Children: `.0`, `.1`, `.2`, `.3`, `.4`

- ID: `SPEC-FORMAT-TERSE.0`
  Status: `pending`
  Goal: Ratify the adopted direction and record it as an ADR (the brainstorm is tentative)
  Acceptance: A `docs/decisions/000N-spec-format-terse-direction.md` ADR captures which rounds/changes
    are adopted, the migration policy (canonical-new + aliased-old vs hard rename), and the
    backward-compatibility stance for the 20 shipped specs. First leaf on activation.
  Verification: `pending`
  Commit: `pending`

- ID: `SPEC-FORMAT-TERSE.1`
  Status: `proposed`
  Goal: Round 1 — variables, types, mutation, functions
  Children: `.1.1`, `.1.2`, `.1.3`, `.1.4`, `.1.5`, `.1.6`

- ID: `SPEC-FORMAT-TERSE.1.1`
  Status: `pending`
  Goal: Auto-existing variables — remove `declare(...)`; a variable exists on first use within a rule scope
  Acceptance: `.spec` action code uses bare names that auto-exist; `declare(scalar|array|hash, ...)`
    becomes unnecessary (kept as deprecated alias during migration). Scope is the rule invocation.
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
| — | *(tree is `proposed` — not PNT-eligible)* | `proposed` | Activate AFTER `RTLUTILS-REGEX-HANG`. On activation: `.0` (ratify + ADR) first, then any round. |

## Decisions

- `2026-06-16`: Created tree to formalize the 2026-06-15 brainstorm so the direction is owned and
  pivotable, not just a KM memo. Status `proposed`; implementation deferred until after the RTLUtils
  hang fix (user directive 2026-06-16).
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

- Migration policy per change: canonical-new-form + deprecated-old-alias (gradual) vs hard rename
  (one-shot). Resolve in `.0` ADR. Affects whether the 20 shipped specs must be migrated in lockstep.
- Operator forms (`=`, `+=`, `name[k]=v`, `+`/`-`/`>` as function names) interact with the current
  raw-Perl-free / ActionIR-ready invariant — confirm the lowering keeps ratio 1.0000.
- Backward compatibility: do the existing helper names (`assign`, `concat`, `array_copy`, `declare`,
  `scalar()/array()/hash()`) remain as permanent aliases or get retired (and when)?

## Blockers

- Not started by design (proposed). Implementation blocked behind `RTLUTILS-REGEX-HANG` per user directive.

## Verification Log

| Date | Leaf | Checks | Result |
| --- | --- | --- | --- |
| `2026-06-16` | `SPEC-FORMAT-TERSE` | Transcription faithful to `docs/knowledge/spec-format-brainstorm-rounds-1-3.md` | Done — all Rounds 1–3 captured as leaves; Round 4+ as a discovery leaf |

## Commit Log

| Leaf | Commit subject or reference | Notes |
| --- | --- | --- |
| `SPEC-FORMAT-TERSE` (creation) | `pending` | `pending` |

## Changelog

- `2026-06-16`: Created tree; transcribed the 2026-06-15 brainstorm (Rounds 1–3) into pickable leaves;
  parked as `proposed` pending the RTLUtils hang fix.
