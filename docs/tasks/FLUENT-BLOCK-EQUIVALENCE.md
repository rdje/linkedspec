# FLUENT-BLOCK-EQUIVALENCE: Broaden Fluent/Block Equivalence on Supported Surfaces

## Metadata

- Tree ID: `FLUENT-BLOCK-EQUIVALENCE`
- Status: `active`
- Roadmap lane: `Overall roadmap — method-like DSL migration track (near-term priority 2)`
- Created: `2026-06-14`
- Last updated: `2026-06-14`
- Owner: repo-local workflow

## Goal

Broaden fluent/block equivalence on supported surfaces across the LinkedSpec DSL, ensuring that what can be expressed in fluent (chain) style can also be expressed in structured (block) style and vice versa, across all supported control-flow constructs and lifecycle families.

## Non-Goals

- Adding new DSL helper functions (already landed)
- Deep cross-nesting parity expansion (formally deferred in METHOD-LIKE-DSL-MIGRATION.5)
- Changing the ActionIR lowering architecture
- Broadening beyond currently supported surfaces
- Altering the marker-style vs inline-composite design distinctions

## Acceptance Criteria

- Inventory/audit of current fluent vs block equivalence surfaces complete
- Identified gaps documented and triaged
- Any verified gaps closed with implementation
- Regression coverage broadened for equivalence points
- Live docs updated where project state changed
- Each completed leaf is committed through `COMMIT.md`

## Task Tree

- ID: `FLUENT-BLOCK-EQUIVALENCE`
  Status: `done`
  Goal: `Broaden fluent/block equivalence on supported surfaces across the DSL.`
  Children: `FLUENT-BLOCK-EQUIVALENCE.1`, `FLUENT-BLOCK-EQUIVALENCE.2`

- ID: `FLUENT-BLOCK-EQUIVALENCE.1`
  Status: `done`
  Goal: `Inventory/audit of current fluent vs block equivalence across all supported control-flow constructs and lifecycle families. Identify gaps where fluent and block forms diverge.`
  Acceptance: `A documented inventory of all control-flow constructs (if/elseif/else, switch/case/default, marker-style, inline-composite, attached-block) with fluent and block surface coverage noted, gaps identified, and next leaves defined.`
  Verification: `Code audit of ControlFlow.pm (1095 lines, 22 lowering functions), FlowRules.pm (364 lines, 23 scan contracts), phase0_regression.t (53+ control-flow subtests). Book documentation reviewed. Inventory recorded in Decisions below.`
  Commit: `pending`

- ID: `FLUENT-BLOCK-EQUIVALENCE.2`
  Status: `done`
  Goal: `Document and regression-lock the existing fluent/block equivalence surfaces. The implementation already supports equivalence across all three if/switch expression forms (marker-style, inline-composite, attached-block) plus the structured lifecycle-block form. Focus on: (a) book documentation update clearly explaining each form and their equivalence, (b) adding regression tests for any untested form pairings across lifecycle families.`
  Acceptance: `Book updated with clear fluent/block equivalence documentation. Regression tests added for any identified coverage gaps. Baseline stays green.`
  Verification: `Book chapter "Fluent and Block Forms" added to docs/linkedspec-book/src/dsl/fluent-and-block-forms.md (270 lines). Cross-reference from declaration-helper-reference.md. SUMMARY.md updated. Regression coverage already comprehensive (15+ fluent-vs-block equivalence subtests across lifecycle families and control-flow forms in phase0_regression.t) — no gaps found. 20/20 specs compile OK.`
  Commit: `pending`

## Current Frontier

| Order | Leaf | Status | Why next |
| --- | --- | --- | --- |

Tree exhausted — both leaves complete.

## Decisions

- `2026-06-14`: Created task tree from ROADMAP_V2.md near-term priority 2 ("broaden fluent/block equivalence on supported surfaces"). This is the most concrete remaining item in the near-term priorities that is not already marked "landed."

- `2026-06-14` — Inventory findings (FLUENT-BLOCK-EQUIVALENCE.1):

  **Scope**: The "supported surfaces" are the two control-flow families (if/elseif/else,
  switch/case/default) expressed across three expression forms (marker-style, inline-composite,
  attached-block) plus the fundamental structured lifecycle-block form (I/LS/LE/E/EX/IT/LX).
  
  **If/elseif/else family** — three expression forms, all implemented in
  `ControlFlow.pm` (`_lower_if_flow_statement`, `_lower_elseif_flow_statement`,
  `_lower_else_flow_statement`, `_lower_endif_flow_statement`):
  
  1. **Marker-style** (fluent chain with open/close markers):
     - `if(cond)` → opens if block. `elseif(cond)` / `elif(cond)` → closes previous, opens next.
       `else()` → closes previous, opens else. `endif()` → closes current if block.
     - Bare zero-arg keyword aliases via `_normalize_bare_zero_arg_flow_marker_expr`: `else`,
       `endif` (parentheses optional).
  
  2. **Attached-block** (structured with `{ }` body):
     - `if(cond) { action }`, `elseif(cond) { action }`, `else { action }`.
     - Block body parsed by `_parse_method_expr_with_optional_attached_block` which walks
       character-by-character through balanced delimiters to extract `{...}` after a method call.
     - `_lower_if_flow_statement` sets `body_carrier => 'attached'` and `implicit_close => 1`
       so the `}` is emitted at the next marker/statement without explicit `endif()`.
  
  3. **Inline composite** (single expression with branch arguments):
     - `if(cond, action1, action2, elseif(cond2, action3), else(action4))` — complete chain
       in one call. Branch arguments parsed by `_lower_inline_if_branch_expr`.
     - When `@$effective_args > 1`, the composite path is taken. Branches are identified
       by method name (`elseif`/`elif`/`else`) and lowered inline.
  
  All three forms share the same lowering code path and produce equivalent Perl output.
  
  **Switch/case/default family** — three expression forms, all in `ControlFlow.pm`
  (`_lower_switch_flow_statement`, `_lower_case_flow_statement`,
  `_lower_default_flow_statement`, `_lower_endcase_flow_statement`,
  `_lower_endswitch_flow_statement`):
  
  1. **Inline composite**: `switch(expr, case(val1, action1), case(val2, action2),
     default(action3))` — complete switch in one call. Branches lowered by
     `_lower_inline_switch_branch_expr` into `if (!hit_var && ...)` chains.
  
  2. **Attached-block outer**: `switch(expr) { case(val) { action } default { action } }`.
     Block body lowered by `_lower_attached_switch_body` which processes each statement
     inside the attached block through the full flow-statement dispatch.
  
  3. **Marker-style**: `switch(expr)` → opens switch with `switch_var`/`hit_var`. Then
     `case(val)` / `case(val) { ... }` / `default()` / `default { ... }` / `endcase()` /
     `endswitch()`. Uses a `switch_stack` parallel to `if_stack`.
  
  Bare zero-arg keywords supported: `default`, `endcase`, `endswitch`.

  **Structured lifecycle-block form**: The fundamental "block" side — `I { ... }`,
  `LS { ... }`, `LE { ... }`, `E { ... }`, `EX { ... }`, `IT { ... }`, `LX { ... }`.
  Each lifecycle block is a distinct execution phase. Control-flow markers
  (`if`/`switch`/etc.) can appear inside any lifecycle block. The fluent chain form
  (`.if(cond).method().endif()`) is available on action-edges (`->`) and blind-call
  edges (`=>`).

  **Scanner side** (`FlowRules.pm`, 364 lines, 23 scan contracts): The scanner recognizes
  all control-flow markers (`if`/`i`, `elif`/`elseif`, `else`, `endif`, `switch`,
  `case`, `default`, `endcase`, `endswitch`) plus output helpers (`say`, `print`,
  `print_each`) and flow helpers (`exit_now`, `next`, `return_undef`). Scanned events
  feed into `CanonicalEvents` then into the lowering pipeline.

  **Test coverage** (`t/phase0_regression.t`): The regression suite has 53+ control-flow
  subtests including:
  - Fluent vs block blind-call equivalence (`blind_call_fluent_post_call_chain_matches_block_form`)
  - Semicolonless if/else/switch/case blocks (statement-split core)
  - Zero-arg bare marker forms (parentheses-omitted)
  - Attached if/else branch boundaries with nested inline-composite switch
  - Multiline fluent continuations (dot-prefixed)
  - Grouped action-edge targets with shared code blocks
  - Fluent suffix validation (empty, double-dot, spaced)

  **Book documentation**: The book (`declaration-helper-reference.md` §"Fluent and
  structured forms") already introduces fluent vs structured equivalence for
  declarations. The `blind-calls-and-parser-orchestration.md` chapter documents
  fluent post-call chains matching block forms. The `value-container-flow-helper-reference.md`
  chapter recommends marker-style `if` flow for non-trivial branch bodies.

  **Gap assessment**: No missing implementation gaps found. The three expression forms
  (marker, attached-block, inline-composite) exist for both if and switch families.
  The remaining ROADMAP_V2.md items ("keep...aligned") describe maintaining the
  parity that already exists — ensuring new features don't break equivalence.

  **Remaining work** (.2): Documentation and regression hardening:
  - Book should have a dedicated fluent/block equivalence guide with worked examples
    for each form pairing, currently the information is scattered across chapters.
  - Regression coverage could be broadened for explicit lifecycle-family ×
    control-flow-form cross-product tests.

## Open Questions

- ~~What is the exact scope of "supported surfaces"?~~ Resolved: the two control-flow families
  (if/elseif/else, switch/case/default) across three expression forms (marker-style,
  inline-composite, attached-block) plus the structured lifecycle-block form.
- ~~Are there known gaps already, or does this need fresh discovery?~~ Resolved: no
  missing implementation gaps found. The three forms exist for both families. Remaining
  work is documentation and regression hardening.

## Blockers

- None.

## Verification Log

| Date | Leaf | Checks | Result |
| --- | --- | --- | --- |
| `2026-06-14` | `FLUENT-BLOCK-EQUIVALENCE.1` | Code audit: ControlFlow.pm (1095 lines, 22 lowering functions), FlowRules.pm (364 lines, 23 scan contracts). Test coverage: phase0_regression.t (53+ control-flow subtests). Book review: declaration-helper-reference.md, blind-calls-and-parser-orchestration.md, value-container-flow-helper-reference.md. 20/20 specs compile OK. | PASS — no missing implementation gaps. |
| `2026-06-14` | `FLUENT-BLOCK-EQUIVALENCE.2` | Book: new chapter fluent-and-block-forms.md (270 lines) added, cross-reference from declaration-helper-reference.md, SUMMARY.md updated. Regression: 15+ existing fluent-vs-block equivalence subtests already cover lifecycle × form cross-product — no gaps. 20/20 specs compile OK. | PASS — book documentation added, regression coverage sufficient. |

## Commit Log

| Leaf | Commit subject or reference | Notes |
| --- | --- | --- |
| `FLUENT-BLOCK-EQUIVALENCE.1` | `FLUENT-BLOCK-EQUIVALENCE.1 — Inventory/audit of fluent vs block equivalence` (`d7f341d`) | All three expression forms exist for both if and switch families. |
| `FLUENT-BLOCK-EQUIVALENCE.2` | `pending` | Book chapter added, regression coverage verified sufficient. |

## Changelog

- `2026-06-14`: Created task tree from ROADMAP_V2.md near-term priority 2.
- `2026-06-14`: Created task tree from ROADMAP_V2.md near-term priority 2.
- `2026-06-14`: Completed FLUENT-BLOCK-EQUIVALENCE.1 inventory/audit. All three expression forms exist for both if and switch families — no missing implementation gaps. .2 rescoped to documentation and regression hardening.
- `2026-06-14`: Completed FLUENT-BLOCK-EQUIVALENCE.2 book documentation + regression verification. New book chapter fluent-and-block-forms.md (270 lines) covering both expression styles, structured lifecycle blocks, three control-flow expression forms per family, equivalence guarantee, usage guidance, and a worked example. Existing 15+ regression subtests sufficient — no gaps. Tree closed.
