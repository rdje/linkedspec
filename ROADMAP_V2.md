# ROADMAP V2
Execution-oriented companion to `ROADMAP.md`.

This file exists to make the active plan easier to follow without replacing the fuller historical and architectural roadmap in `ROADMAP.md`.

## Purpose
- Keep a concise execution view of what we are doing now.
- Keep the live four-level tracker easy to inspect.
- Make the active policy contracts explicit enough that future slices do not drift.

## Operating Rules
- Status levels are limited to:
  - `done`
  - `mostly done`
  - `in progress`
  - `not started`
- Execution is dependency-first by default, not strict waterfall by phase number.
- If strict phase-by-phase execution is desired, it must be requested explicitly.
- Before every commit, update the tracker if the completed slice materially changes what is done, what is left, or which area is active.
- In commit close-outs:
  - show changed tracker rows when a level changes,
  - otherwise show only the tracker rows affected by the slice,
  - show the full tracker only when explicitly requested.

## Core Policy Contracts
- `.spec` authoring is intended to become permanently raw-Perl-free.
- Raw Perl inside `.spec` is obsolete compatibility debt, not an acceptable long-term authoring surface.
- Remaining raw Perl occurrences in `.spec` should be flagged loudly and migrated to canonical method-like DSL equivalents.
- Documentation is a product contract:
  - optimize for readability,
  - remove ambiguity directly,
  - explain semantics plainly,
  - use representative examples when they help,
  - add thorough worked examples for every newly landed user-facing surface,
  - treat documented examples as part of the end-user contract we should not casually weaken,
  - do not intentionally obfuscate behavior or tradeoffs.

## Lifecycle-Wide Structured DSL Contract
Semicolon-light structured authoring is intended to apply across the full lifecycle family:
- `I`
- `LS`
- `LE`
- `E`
- `EX`
- `IT`
- `LX`

Current regression anchors are `I { ... }` and `LX { ... }`, but those are only proof points. They are not the intended limit of the policy. If semicolon-light structured authoring applies to one lifecycle block family, it should apply to the others too unless an explicit documented exception is introduced.

## Current Live Tracker
| Area | Status | What it covers | Remaining focus |
| --- | --- | --- | --- |
| Overall roadmap | `in progress` | Whole-project delivery across parser core, semantics, runtime, docs, and future self-hosting. | Finish the remaining Backbone Item 3 cleanup, then drive the later semantic/runtime/self-hosting phases. |
| Phase 0 | `done` | Regression safety net, baseline compilation coverage, and corpus-level guardrails. | Keep the regression baseline green; `tclite.spec` remains the only explicitly deferred known issue. |
| Phase 1 | `mostly done` | Parser-core isolation and dependency-surface reduction for the active compile/runtime path. | Finish the last parser-core isolation cleanup around remaining compile-path compatibility seams. |
| Phase 1A | `mostly done` | Thin-façade modularization of `LinkedSpec.pm` into focused owner modules with stable public APIs. | Finish shrinking `LinkedSpec.pm` and the remaining thin compatibility wrappers down to stable owner paths. |
| Phase 2 | `not started` | DSL frontend hardening, stricter validation, and clearer token/error handling. | DSL frontend hardening still has not begun as a dedicated phase. |
| Phase 3 | `not started` | Formal parse-mode semantics, especially `seek` versus `consume` behavior. | Execution-semantics clarification work is still ahead. |
| Phase 4 | `not started` | Capture/mark API formalization and clearer staged-extraction authoring primitives. | Capture/mark API formalization is still ahead. |
| Phase 5 | `in progress` | Runtime modernization, diagnostics consistency, and reduced dynamic-eval fragility. | Runtime/diagnostic modernization has landed refactor groundwork, but the phase-level behavior work is not complete yet. |
| Phase 6 | `in progress` | User/developer documentation, architecture rationale, and live project-state upkeep. | Documentation is being maintained live, but adoption/consolidation work is still active. |
| Phase 7 | `not started` | Self-hosted `spec.spec` grammar and `.spec` evolution through the DSL itself. | Self-hosted `.spec` grammar work has not begun yet. |
| Backbone refactor track | `mostly done` | Cross-cutting structural cleanup needed to make LinkedSpec robust, modular, and extensible. | Item 3 remains active; Items 1 and 2 are already landed. |
| Backbone Item 1 | `done` | Declarative bootstrap grammar registry replacing positional bootstrap coupling. | Declarative bootstrap registry landed. |
| Backbone Item 2 | `done` | Staged `spec_entry()` compiler pipeline around RuleIR and explicit planning/validation phases. | Staged `spec_entry()` RuleIR pipeline landed. |
| Backbone Item 3 | `mostly done` | Structured ActionIR/rewrite/lowering pipeline replacing ad hoc helper regex-chain rewriting. | Finish the remaining ActionIR/EmitContext owner-contract cleanup and compatibility-surface reduction. |
| Method-like DSL migration track | `in progress` | Backend-neutral method-style `.spec` action syntax with equivalent fluent-chain and structured-block surfaces, plus unlimited nested method composition in arguments. Backbone Item 3 groundwork alone does not define this track. | Continue adding missing user-facing DSL features on top of the latest control-flow baseline; keep deeper cross-nesting parity expansion deferred unless a concrete feature or bug requires it. |
| Plugin/resource-resolution modernization track | `in progress` | Explicit plugin/runtime boundary and deterministic path/resource lookup. | Compatibility bridge work has started, but full runtime replacement and decoupling are still ahead. |

## Near-Term Execution Priorities
1. Finish the lifecycle-family follow-through for semicolon-light structured authoring:
   - generic helper-only regression coverage now spans `I`, `LS`, `LE`, `E`, `EX`, `IT`, and `LX`,
   - marker-style semicolon-light control-flow coverage now spans that same full lifecycle family too,
   - keep extending any remaining narrower lifecycle-specific semantics only when a real gap or exception is found.
2. Continue the method-like DSL migration track:
   - priority shift is now active: continue missing user-facing DSL features first, and return to deeper marker `if(...)` / marker `switch(...)` cross-nesting parity expansion only when a concrete feature or bug requires it,
   - design direction is now explicit: scalar and aggregate helper growth should follow a disciplined functional-expression style with unlimited composition, clear helper signatures, and parser-oriented semantics, while explicitly avoiding scope creep into lambdas, closures, currying, or a general-purpose FP sublanguage,
   - landed punctuation-reduction follow-up: structured marker-style zero-arg terminators now accept bare keyword form (`else`, `endif`, `default`, `endcase`, `endswitch`) in addition to the older `...()` spellings, and attached branch blocks now also accept `else { ... }` / `default { ... }` alongside `else() { ... }` / `default() { ... }`,
   - landed documentation follow-up: a dedicated scalar-and-aggregate composition guide now teaches string, integer, float-like, array, and hash helper usage with many worked examples and explicit no-fixed-depth composition guidance instead of scattering that story only across module-owner references,
   - landed helper-contract follow-up: parser-oriented `coalesce(...)` fallback chains are now explicitly regression-locked between fluent and structured authoring on both action-edge and lifecycle surfaces, covering assignment sources, return payloads, and comparison inputs,
   - landed helper-contract follow-up: parser-oriented `is_defined(...)` / `is_undefined(...)` flow helpers are now explicitly regression-locked between fluent and structured authoring on both action-edge and lifecycle surfaces, so `.spec` rules can distinguish “missing” from “empty” without dropping back to ad hoc truthiness,
   - landed helper-contract follow-up: parser-oriented scalar normalization helpers `trim(...)`, `lowercase(...)`, and `uppercase(...)` are now explicitly regression-locked between fluent and structured authoring on both action-edge and lifecycle surfaces, covering assignment sources, return payloads, and comparison inputs,
   - landed helper-contract follow-up: parser-oriented array-size reducer `count(...)` is now explicitly regression-locked between fluent and structured authoring on both action-edge and lifecycle surfaces, covering assignment sources, return payloads, and numeric comparison inputs,
   - landed helper-contract follow-up: parser-oriented hash/object-size reducer `count_keys(...)` is now explicitly regression-locked between fluent and structured authoring on both action-edge and lifecycle surfaces, covering assignment sources, return payloads, and numeric comparison inputs,
   - landed helper-contract follow-up: parser-oriented hash/object key-presence helper `has_key(...)` is now explicitly regression-locked between fluent and structured authoring on both action-edge and lifecycle surfaces, covering assignment sources, return payloads, and flow conditions,
   - landed helper-contract follow-up: parser-oriented pure hash/object layering helper `merge_hash(...)` is now explicitly regression-locked between fluent and structured authoring on both action-edge and lifecycle surfaces, covering assignment sources, return payloads, and flow-helper composition without mutating source hashes,
   - landed helper-contract follow-up: parser-oriented pure hash/object cleanup helper `drop_keys(...)` is now explicitly regression-locked between fluent and structured authoring on both action-edge and lifecycle surfaces, covering assignment sources, return payloads, and flow-helper composition without mutating source hashes,
   - landed helper-contract follow-up: representative array-normalization pipelines using `split(...)`, `split_each(...)`, `trim_each(...)`, `filter_nonempty(...)`, and `return(array_copy(...))` are now explicitly regression-locked between fluent and structured authoring on both action-edge and lifecycle surfaces,
   - landed helper-contract follow-up: representative case-normalization/filter pipelines using `assign(array(...), filter_match(uniq(uppercase_each(array(...))), /.../))`, `lowercase_each(...)`, and `return(array_copy(...))` are now explicitly regression-locked between fluent and structured authoring on both action-edge and lifecycle surfaces,
   - landed control-flow follow-up: the outer attached-block switch family now explicitly supports mixed per-branch carriers such as `case("A") { ... } case("B") ... default { ... }` on both structured and final-call fluent surfaces,
   - broaden fluent/block equivalence on supported surfaces,
   - keep both supported inline-switch structured branch-body surfaces in sync:
     - `case(value, { ... })` / `default({ ... })`,
     - `case(value) { ... }` / `default() { ... }`,
   - keep the newly landed block-bodied outer switch surface in sync too:
     - `switch(expr) { case(value) { ... } default { ... } }`,
     - lowering equivalently to the inline composite switch attached-branch-block surface on action-edge and lifecycle blocks,
     - and now also supporting plain marker branches such as `case(value) ... default ...` inside the outer block, not only per-branch attached blocks,
     - and now also available as the final call on fluent action-edge and lifecycle chains, not only inside structured outer blocks,
   - keep attached-block switch branch bodies fully aligned with structured-block-context flow semantics, including nested marker flow such as `if(...) ... endif()` inside those branch bodies,
   - keep attached-block switch branch bodies fully aligned with nested marker-style switch flow semantics too, not only nested marker-style `if(...) ... endif()` flow,
   - keep attached-block switch branch bodies aligned for the broader multi-`case(...)` nested marker-style `switch(...) ... endswitch()` shape too, not only the simpler single-`case(...)` marker-switch shape,
   - keep the two supported inline-switch structured branch-body carriers aligned for that broader multi-`case(...)` nested marker-style `switch(...) ... endswitch()` shape too, not only for flat helper-only branch bodies,
   - keep those same two inline-switch structured branch-body carriers aligned for nested composite `if(...)` / `elseif(...)` flow too, not only for nested switch-only shapes,
   - keep those same two inline-switch structured branch-body carriers aligned for nested composite `if(...)` / `elseif(...)` flow carrying the deeper alternating marker `if(...) ... switch(...) ... endif()` nesting contract too, not only for the plain nested composite-if surface or the switch-only deep-marker surface,
   - keep those same two inline-switch structured branch-body carriers aligned for the broader multi-`case(...)` nested marker-style `switch(...) ... endswitch()` shape inside nested composite `if(...)` / `elseif(...)` flow too, not only for the plain nested composite-if shape,
   - keep those same two inline-switch structured branch-body carriers aligned for the broader multi-`case(...)` nested inline-composite `switch(...)` shape inside nested composite `if(...)` / `elseif(...)` flow too, not only across attached switch branch blocks,
   - keep those same two inline-switch structured branch-body carriers aligned for the deeper alternating marker `if(...) ... switch(...) ... endif()` nesting contract too, across action-edge and the full lifecycle family,
   - keep the marker-style outer switch structured branch-body surfaces aligned for that same deeper alternating marker `if(...) ... switch(...) ... endif()` nesting contract too, across the plain branch-marker form and attached-block branch sugar,
   - keep those same marker-style outer switch structured branch-body surfaces aligned for nested composite `if(...)` / `elseif(...)` flow too, not only for nested switch-only shapes or the deeper alternating marker chain,
   - keep those same marker-style outer switch structured branch-body surfaces aligned for nested composite `if(...)` / `elseif(...)` flow carrying that same deeper alternating marker `if(...) ... switch(...) ... endif()` nesting contract too, not only for the plain nested composite-if surface or the switch-only deep-marker surface,
   - keep those same marker-style outer switch structured branch-body surfaces aligned for the broader multi-`case(...)` nested marker-style `switch(...) ... endswitch()` shape inside nested composite `if(...)` / `elseif(...)` flow too, not only for the plain nested composite-if shape,
   - keep those same marker-style outer switch structured branch-body surfaces aligned for that same broader multi-`case(...)` nested inline-composite `switch(...)` shape inside nested composite `if(...)` / `elseif(...)` flow too, not only across attached switch branch blocks,
   - keep attached switch branch blocks aligned across the two outer switch families themselves for that same deeper alternating marker `if(...) ... switch(...) ... endif()` nesting contract too, not only within each outer switch family,
   - keep the structured marker-style outer switch surface aligned across its plain branch-marker form and attached-block switch branch sugar for that broader multi-`case(...)` nested marker-style `switch(...) ... endswitch()` shape too, not only for flat helper-only branch bodies,
   - keep attached switch branch blocks aligned across the two outer switch families themselves for that broader multi-`case(...)` nested marker-style `switch(...) ... endswitch()` shape too, not only for the deeper alternating marker nesting contract,
   - keep attached switch branch blocks aligned across the two outer switch families themselves for the broader multi-`case(...)` nested inline-composite `switch(...)` shape too, not only for the marker-style nested switch shapes,
   - keep attached switch branch blocks aligned across the two outer switch families themselves for nested composite `if(...)` / `elseif(...)` flow too, not only for bare nested switch forms,
   - keep that same outer-switch-family attached-branch parity aligned for nested composite `if(...)` / `elseif(...)` flow carrying the deeper alternating marker `if(...) ... switch(...) ... endif()` nesting contract too, not only for the plain nested composite-if surface or the switch-only deep-marker surface,
   - keep attached-block switch branch bodies aligned for nested composite `if(...)` forms too, including both inline composite and attached-block inner `if` surfaces, on both inline composite and marker-style outer switch surfaces,
   - keep attached-block switch branch bodies aligned for parity between structured inline composite `if(...)` branch blocks and attached-block composite `if(...)` branch bodies too, even when those deeper `if/elseif/else` branches themselves carry nested inline-composite `switch(...)` flow,
   - keep that same attached-switch parity aligned for nested marker-style `switch(...) ... endswitch()` flow inside those deeper `if/elseif/else` branches too, not only nested inline-composite `switch(...)` flow,
   - keep that attached-switch parity aligned for the broader multi-`case(...)` nested inline-composite `switch(...)` shape inside those deeper `if/elseif/else` branches too, not only the simpler single-`case(...)` nested inline-switch shape,
   - keep that broader multi-`case(...)` nested inline-switch parity aligned across both inline composite and marker-style outer switch families too, not only the inline composite outer switch family,
   - keep the same deeper attached-switch parity aligned for the broader multi-`case(...)` nested marker-style `switch(...) ... endswitch()` shape too, across both inline composite and marker-style outer switch families, not only the simpler single-`case(...)` marker-switch shape,
   - keep attached switch branch blocks directly aligned across the two outer switch families for the broader multi-`case(...)` nested inline-composite `switch(...)` shape inside nested composite `if(...)` / `elseif(...)` flow too, not only within each outer family or through the inner composite-if parity checks,
   - keep attached switch branch blocks directly aligned across the two outer switch families for that same broader multi-`case(...)` nested marker-style `switch(...) ... endswitch()` shape inside nested composite `if(...)` / `elseif(...)` flow too, not only within each outer family or through the inner composite-if parity checks,
   - keep attached-block switch branch bodies aligned for nested inline-composite `switch(...)` forms too, on both inline composite and marker-style outer switch surfaces,
   - keep the attached-switch nested composite-`if(...)` contract aligned for the deeper `elseif(...)` branch shape too, not only the simple `if/else` shape,
   - keep the attached-switch nested inline-composite `switch(...)` contract aligned for broader multi-`case(...)` shapes too, not only the simpler single-`case(...)` shape,
   - keep composite `if(...)` branch bodies aligned for broader nested multi-`case(...)` marker-style `switch(...) ... endswitch()` flow too, across both structured inline branch-block and attached-block `if(...)` forms,
   - keep composite `if(...)` branch bodies aligned for the deeper `if/elseif/else` branch shape with nested marker-style `switch(...) ... endswitch()` flow too, not only the simpler `if/else` shape,
   - keep those same deeper composite `if/elseif/else` branch bodies aligned for nested inline-composite `switch(...)` flow too, not only nested marker-style `switch(...) ... endswitch()` flow,
   - keep that same deeper composite `if/elseif/else` branch shape aligned for the broader multi-`case(...)` nested inline-composite `switch(...)` shape too, not only the simpler single-`case(...)` nested inline-switch shape,
   - keep that same deeper composite `if/elseif/else` branch shape aligned for the broader multi-`case(...)` nested marker-style `switch(...) ... endswitch()` shape too, not only the simpler single-`case(...)` marker-switch shape,
   - keep marker-style `if(...) ... endif()` and marker-style `switch(...) ... endswitch()` mutually nestable without a DSL-fixed depth cap in structured block contexts, including attached switch branch blocks plus structured inline and attached-block composite `if(...)` branch bodies, with practical limits coming only from normal recursion/resource ceilings,
   - keep the newly landed inline composite `if(cond, ..., elseif(...), else(...))` form plus its structured branch-body extension `if(cond, { ... }, elseif(..., { ... }), else({ ... }))` aligned with the now-landed attached-block composite form `if(cond) { ... } elseif(cond2) { ... } else() { ... }`, including its lower-friction `else { ... }` alias and its new final-call fluent action-edge/lifecycle surface,
   - keep that same attached-block composite `if(...)` family friendly to mixed per-branch carriers too, so attached branch blocks and lighter plain marker bodies can coexist across one `if/elseif/else` chain on both structured and final-call fluent surfaces,
   - keep zero-arg fluent control-flow markers punctuation-light too, so `.else`, `.endif`, `.default`, `.endcase`, and `.endswitch` stay aligned with the older parenthesized fluent forms,
   - keep structured inline and attached composite `if(...)` branch bodies aligned for nested marker-style `switch(...) ... endswitch()` flow too, not only for flat helper sequences or nested marker-style `if(...) ... endif()` flow,
   - keep those same composite-`if(...)` branch bodies aligned for nested inline-composite `switch(...)` forms too, including attached switch-branch sugar such as `case(value) { ... }` / `default() { ... }`,
   - keep that nested inline-composite `switch(...)` contract inside composite-`if(...)` branch bodies aligned for broader multi-`case(...)` shapes too, not only the simpler single-`case(...)` shape,
   - keep those inline composite control-flow surfaces lifecycle-wide across `I`, `LS`, `LE`, `E`, `EX`, `IT`, and `LX`, not only on the earlier `LX` proof point,
   - treat marker-style `if(...) ... endif()` and `switch(...) ... endswitch()` as structured-block-context syntax rather than as a free-standing fluent surface, including nested structured branch bodies when those land as supported contexts,
   - keep unlimited nested composition canonical and backend-neutral,
   - keep raw-Perl-free `.spec` authoring as the target.
3. Finish the remaining Backbone Item 3 cleanup:
   - reduce leftover compatibility seams,
   - keep `EmitContext` and extracted ActionIR owners as the stable lowering surface.
4. Keep documentation synchronized with every meaningful slice:
   - roadmap,
   - execution notes,
   - user guide,
   - session memory.

## Deferred Future Note
- A possible later enhancement is explicit rule-grouping beyond today’s default repeated-alternative rule model:
  - explicit `AND`,
  - bounded or exact `OR`,
  - bounded or exact `AND`,
  - and related grouped rule strategies.
- This is intentionally deferred until the current default rule semantics are considered solid.

## Relationship to ROADMAP.md
- `ROADMAP.md` remains the primary long-form roadmap and historical planning document.
- `ROADMAP_V2.md` is the shorter execution-focused companion.
- If the two ever drift, update both in the same slice.
