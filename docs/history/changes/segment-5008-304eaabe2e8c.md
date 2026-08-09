- Reworked inline composite switch branch lowering so branch actions now share one rewrite context across the whole branch body instead of lowering each branch argument in isolation.
  - This keeps nested flow state coherent within one branch body.
  - It also lets `{ ... }` branch bodies reuse the normal semicolon-light structured statement splitter instead of inventing a second parsing path.
- Added focused regressions for both action-edge and lifecycle surfaces:
  - canonical inline action-list branch bodies remain the baseline,
  - `case(value, { ... })` and `default({ ... })` now lower to identical `ACODE` or `LXCODE`,
  - canonical action-IR metadata stays aligned,
  - fallback stays at zero,
  - and language-agnostic readiness stays true.
- Tracker interpretation:
  - `Method-like DSL migration track` stays `in progress`,
  - because this slice deepens the supported structured control-flow surface without moving the overall track level.

## 2026-03-15 - Roadmap/Notes Slice: Log Deferred Rule-Grouping Exploration
## Summary
Logged a deferred future-enhancement note for richer rule-grouping ideas after the current default repeated-alternative rule model is considered solid. The note keeps the brainstorming outcome without turning it into an active implementation item.

## Changed Files
- Updated: `ROADMAP.md`
- Updated: `ROADMAP_V2.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`

## Technical Details
- Added a dedicated deferred roadmap note that:
  - keeps the current default rule body semantics as the active baseline,
  - records the rough `OR+`-like design shorthand only as a heuristic, not as a formal current-language claim,
  - and queues possible future grouped-rule work such as explicit `AND`, bounded `OR`, exact repetition, and related rule-strategy templates.
- Clarified the sequencing constraint:
  - this family stays deferred until the current repeated-alternative rule semantics are explicit and stable,
  - and until later execution-semantics work is better defined.
- Tracker interpretation:
  - no live-status row changes,
  - because this is a saved future-enhancement note rather than an active roadmap slice.

## 2026-03-15 - Method-Like DSL Slice: Lock Semicolonless Remaining Lifecycle Control-Flow Blocks
## Summary
Extended the semicolon-light structured control-flow regression coverage from `LX` to the remaining lifecycle families too. Structured `LS`, `LE`, `E`, `EX`, and `IT` `if/else/endif` and `switch/case/default/endswitch` blocks are now regression-locked in semicolonless form against their fluent baselines.

## Changed Files
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `ROADMAP_V2.md`
- Updated: `USER_GUIDE.md`
- Updated: `USER_GUIDE_ActionIR_ControlFlow.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`

## Technical Details
- Added focused semicolonless structured control-flow regressions for the remaining lifecycle families:
  - `LS`
  - `LE`
  - `E`
  - `EX`
  - `IT`
- Locked parity against the fluent lifecycle baselines on:
  - identical canonical action-IR node coverage,
  - identical canonical action-IR hit counts,
  - expected `IF` / `ELSE` / `ENDIF` helper coverage for marker-style `if(...)` blocks,
  - expected `SWITCH` / `CASE` / `DEFAULT` / `ENDSWITCH` helper coverage for marker-style switch blocks,
  - zero canonical fallback,
  - and language-agnostic readiness.
- Clarified in the roadmap and guides that semicolon-light marker-style lifecycle control-flow coverage now spans the full lifecycle family:
  - `I`
  - `LS`
  - `LE`
  - `E`
  - `EX`
  - `IT`
  - `LX`
- Tracker interpretation:
  - `Method-like DSL migration track` stays `in progress`,
  - because this slice broadens lifecycle-family control-flow coverage without changing the track level.

## 2026-03-15 - Method-Like DSL Slice: Lock Semicolonless Remaining Lifecycle Helper Blocks
## Summary
Extended the semicolon-light structured-block regression coverage from `I` and `LX` to the remaining lifecycle families too. Generic helper-only `LS`, `LE`, `E`, `EX`, and `IT` blocks are now regression-locked in semicolonless structured form against their fluent baselines.

## Changed Files
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `ROADMAP_V2.md`
- Updated: `USER_GUIDE.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`

## Technical Details
- Added focused semicolonless structured-block regressions for:
  - `LS`
  - `LE`
  - `E`
  - `EX`
  - `IT`
- Locked parity against the fluent lifecycle baselines on:
  - identical canonical action-IR node coverage,
  - identical canonical action-IR hit counts,
  - expected `DECLARE` / `ASSIGN` / `RETURN` / `RETURN_A` helper coverage,
  - zero canonical fallback,
  - and language-agnostic readiness.
- Clarified in the roadmap and user guide that generic helper-only semicolon-light lifecycle coverage now spans the full family:
  - `I`
  - `LS`
  - `LE`
  - `E`
  - `EX`
  - `IT`
  - `LX`
- Clarified the remaining narrower seam too: control-flow-heavy semicolon-light lifecycle coverage is still the more `LX`-anchored slice for now.
- Tracker interpretation:
  - `Method-like DSL migration track` stays `in progress`,
  - because this slice broadens lifecycle-family regression coverage without moving the track level.

## 2026-03-14 - Roadmap/Docs Slice: Add `ROADMAP_V2` and Name Full Lifecycle Family Contract
## Summary
Added `ROADMAP_V2.md` as a shorter execution-oriented companion to the primary roadmap, and tightened the semicolon-light lifecycle policy so it explicitly names the full lifecycle family instead of reading like an `I`/`LX`-only convention.

## Changed Files
- Updated: `ROADMAP.md`
- Added: `ROADMAP_V2.md`
- Updated: `USER_GUIDE.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`

## Technical Details
- Added `ROADMAP_V2.md` to keep:
  - the live four-level tracker,
  - execution-order rules,
  - raw-Perl-free `.spec` policy,
  - documentation contract,
  - and near-term priorities
  in one shorter operational document.
- Clarified that the semicolon-light structured lifecycle policy covers the full lifecycle family:
  - `I`
  - `LS`
  - `LE`
  - `E`
  - `EX`
  - `IT`
  - `LX`
- Clarified that `I { ... }` and `LX { ... }` are current regression anchors only, not the intended boundary of the lifecycle-wide policy.
- Tracker interpretation:
  - no live-status row changes,
  - because this slice improves roadmap/doc precision and execution tracking without changing current status levels.

## 2026-03-14 - Method-Like DSL Slice: Lock Semicolonless Generic `LX` Blocks
## Summary
Extended the semicolon-light structured-block work to generic non-control-flow `LX { ... }` blocks too. Structured `LX` helper sequences can now be authored without `;` separators between top-level method statements while preserving the same lifecycle lowering and migration metadata as the fluent baseline.

## Changed Files
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `USER_GUIDE.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`

## Technical Details
- Added a focused regression for semicolonless generic `LX { ... }` helper chains covering `declare(...)`, `assign(...)`, `call(...)`, and `return(...)` in the same lifecycle block.
- Locked parity against the fluent `LX.` baseline on:
  - identical `LXCODE` lowering,
  - zero raw-Perl fallback,
  - identical canonical action-IR node coverage,
  - and language-agnostic action-IR readiness.
- Clarified in the roadmap and top-level guide that the broader optional-semicolon rule is now explicitly regression-locked on generic `LX { ... }` structured blocks too, not only on `I { ... }` and control-flow `LX { ... }` forms.
- Clarified the broader policy too: if semicolon-light structured authoring applies to one lifecycle block family, it is intended to apply to the others too unless an explicit documented exception exists. `I { ... }` and `LX { ... }` are current regression locks for that broader lifecycle-wide direction.
- Tracker interpretation:
  - `Method-like DSL migration track` stays `in progress`,
  - because this slice broadens the supported semicolon-light lifecycle authoring surface without changing the track level.

## 2026-03-14 - Method-Like DSL Slice: Lock Semicolonless Generic Structured Blocks
## Summary
Extended the semicolon-light structured-block work beyond marker-style control flow. Generic helper-only structured action blocks and structured lifecycle blocks now have regression locks proving that top-level method statements can be authored without `;` separators while preserving the same lowering and migration metadata as the fluent baseline.

## Changed Files
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `USER_GUIDE.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`

## Technical Details
- Added focused regressions for semicolonless generic method-only structured blocks on:
  - action-edge `{ ... }` helper chains,
  - and lifecycle `I { ... }` helper chains.
- Locked parity against the fluent baseline on:
  - identical `ACODE` or `ICODE` lowering,
  - zero raw-Perl fallback,
  - zero unresolved-helper drift,
  - and language-agnostic action-IR readiness.
- Clarified in the top-level guide and roadmap that the optional-semicolon rule now has explicit regression coverage on generic helper-only structured blocks too, not only on marker-style control-flow blocks.
- Tracker interpretation:
  - `Method-like DSL migration track` stays `in progress`,
  - because this slice broadens the supported semicolon-light structured authoring surface without changing the track level.

## 2026-03-14 - Method-Like DSL Slice: Lock Semicolonless Structured Lifecycle Control-Flow Blocks
## Summary
Extended the semicolon-light structured control-flow work by regression-locking the same supported semicolonless marker-style forms on lifecycle surfaces too. Structured `LX { if(...) ... else() ... endif() }` and `LX { switch(...) ... case(...) ... default() ... endswitch() }` blocks now preserve the same lifecycle lowering and migration metadata as the fluent baseline without requiring `;` delimiters between top-level method statements.

## Changed Files
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `USER_GUIDE.md`
- Updated: `USER_GUIDE_ActionIR_ControlFlow.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`

## Technical Details
- Added focused lifecycle regressions for semicolonless structured `if/elseif/else/endif` and `switch/case/default/endswitch` blocks inside `LX { ... }`.
- Locked parity against the fluent lifecycle baseline on:
  - identical `LXCODE` lowering,
  - zero raw-Perl fallback,
  - zero unresolved-helper drift,
  - and language-agnostic action-IR readiness.
- Clarified in the guides that optional semicolons now apply on both action-edge structured blocks and lifecycle `LX { ... }` structured blocks for canonical method-only control-flow.
- Tracker interpretation:
  - `Method-like DSL migration track` stays `in progress`,
  - because this slice broadens the supported structured lifecycle authoring surface without changing the track level.

## 2026-03-14 - Method-Like DSL Slice: Accept Semicolonless Structured Control-Flow Blocks
## Summary
Extended the method-like DSL migration work by teaching structured helper-only blocks to split top-level control-flow statements without requiring `;` delimiters. Marker-style `if(...)` / `else()` / `endif()` and `switch(...)` / `case(...)` / `default()` / `endswitch()` blocks now compile cleanly in semicolonless structured form while preserving the same lowering and migration metadata as the existing fluent and semicolon-delimited structured surfaces.

## Changed Files
- Updated: `perl/LinkedSpec/ActionIR/StatementSplit/Core.pm`
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `USER_GUIDE.md`
- Updated: `USER_GUIDE_ActionIR_ControlFlow.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`

## Technical Details
- Extended `LinkedSpec::ActionIR::StatementSplit::Core::split_action_ir_statements(...)` so it can split adjacent top-level method-like statements even when no `;` is present between them.
- Kept semicolon-delimited blocks valid; this is an additive syntax relaxation for canonical method-only structured blocks.
- Added focused regressions for:
  - direct splitter handling of worst-case single-line semicolonless `if/else` and `switch/case` helper blocks,
  - and end-to-end semicolonless structured action-edge control-flow blocks lowering identically to the fluent baseline.
- Updated the control-flow guide to show semicolon-light structured examples and to state that semicolons remain accepted but no longer required in method-only structured blocks.
- Tracker interpretation:
  - `Method-like DSL migration track` stays `in progress`,
  - because this slice broadens the supported structured control-flow authoring surface without changing the track level.

## 2026-03-14 - Design Note: Lock Raw-Perl-Free `.spec` Policy
## Summary
Recorded an explicit project policy that `.spec` authoring is intended to become permanently raw-Perl-free. Raw Perl in `.spec` is now tracked as obsolete compatibility debt to reject and migrate away, and the semicolon-light control-flow design direction is explicitly scoped only to canonical method-like DSL blocks rather than to any mixed Perl/DSL model.

## Changed Files
- Updated: `ROADMAP.md`
- Updated: `USER_GUIDE.md`
- Updated: `USER_GUIDE_ActionIR_ControlFlow.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`

## Technical Details
- Strengthened the roadmap raw-Perl policy from gradual reduction language to an explicit raw-Perl-free `.spec` end-state.
- Clarified that remaining raw Perl in `.spec` should be:
  - flagged loudly,
  - treated as migration blockers,
  - and replaced with language-agnostic DSL equivalents.
- Clarified that structured `{...}` blocks remain supported only when they contain method-like DSL statements rather than embedded raw Perl.
- Clarified that semicolon-optional control-flow work is scoped to canonical DSL parsing only, not to preserving mixed raw-Perl authoring.
- Tracker interpretation:
  - no live-status row changes,
  - because this is a policy/design-note slice rather than a landed enforcement implementation.

## 2026-03-14 - Design Note: Track Composite Control-Flow Syntax Direction
## Summary
Recorded the agreed pre-implementation design direction for composite control-flow syntax. The roadmap and control-flow guide now distinguish clearly between currently supported syntax and the next intended control-flow forms, including the one-header / one-body-carrier rule, structured inline switch branch bodies, and staged inline composite `if(...)` exploration.

## Changed Files
- Updated: `ROADMAP.md`
- Updated: `USER_GUIDE_ActionIR_ControlFlow.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`

## Technical Details
- Explicitly kept current inline composite `switch(expr, case(...), default(...))` action-list syntax as the composite baseline.
- Explicitly ruled out chained branch-body forms like `case(value, m1(...).m2(...))`.
- Recorded the branch syntax contract:
  - one branch header,
  - one body carrier,
  - no mixed `default(actions...) { ... }` or equivalent mixed-body forms.
- Recorded the staged switch plan:
  - first prefer structured branch bodies like `case(value, { ... })`,
  - later consider attached-block sugar like `case(value) { ... }` and `default() { ... }`.
- Recorded the staged `if(...)` plan:
  - first prefer an argument-list composite form like `if(cond, ..., elseif(...), else(...))`,
  - later treat attached-block `if(cond) { ... }` ergonomics as a larger syntax pass.
- Tracker interpretation:
  - no live-status row changes,
  - because this is a design-note slice rather than a landed syntax implementation.

## 2026-03-14 - Docs Clarification: Track Control-Flow Syntax Revisit
## Summary
Recorded a design clarification that the currently documented `if(...)` / `else()` / `endif()` and `switch(...)` marker syntax is the current supported surface, but not the final ergonomics target. The roadmap now explicitly tracks a future control-flow syntax revisit to reduce punctuation friction and evaluate more natural block-style and inline-composite authoring forms.

## Changed Files
- Updated: `ROADMAP.md`
- Updated: `USER_GUIDE.md`
- Updated: `USER_GUIDE_ActionIR_ControlFlow.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`

## Technical Details
- Clarified in the roadmap that method-like DSL work still includes a planned control-flow concrete-syntax revisit.
- Explicitly called out likely exploration areas:
  - less punctuation-heavy marker forms,
  - brace-delimited branch syntax,
  - and inline composite `if(...)` forms analogous to inline composite `switch(...)`.
- Clarified in the guides that current examples document what is supported now, not what must remain the final UX forever.
- Tracker interpretation:
  - no live-status row changes,
  - because this is a design-direction clarification rather than a landed syntax implementation slice.

## 2026-03-14 - Method-Like DSL Slice: Lock Nested Accessor Payload Equivalence
## Summary
Extended the method-like DSL migration track by regression-locking nested accessor payload composition between fluent and structured authoring on both action-edge and lifecycle surfaces. Supported `scalaref(base, path)` plus indexed/keyed `scalar(...)` payload reads now preserve the same lowering and migration metadata across both concrete syntaxes.

## Changed Files
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `USER_GUIDE.md`
- Updated: `USER_GUIDE_ActionIR_MethodLowering.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`

## Technical Details
- Added focused fluent-versus-structured equivalence locks for supported nested accessor payload forms on:
  - action-edge method chains,
  - and lifecycle `LX` method chains.
- Locked parity on:
  - identical `ACODE` or `LXCODE`,
  - zero fallback,
  - zero unresolved helpers,
  - zero raw Perl dependency,
  - identical canonical action-IR node coverage,
  - and language-agnostic readiness metadata.
- Tracker interpretation:
  - `Method-like DSL migration track` stays `in progress`,
  - because this slice deepens supported nested value-composition coverage without changing the track level.

## 2026-03-14 - Method-Like DSL Slice: Lock Branch-Local Call-Value Equivalence
## Summary
Extended the method-like DSL migration track by regression-locking canonical call-result capture inside control-flow branch bodies. Supported `assign(scalar(retv), call(rule))` chains now preserve the same lowering and migration metadata across fluent and structured authoring for `if/elseif` and `switch/case` forms on both action-edge and lifecycle surfaces.

## Changed Files
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `USER_GUIDE.md`
- Updated: `USER_GUIDE_ActionIR_MethodLowering.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`

## Technical Details
- Added focused fluent-versus-structured equivalence locks for supported branch-local canonical call-value capture forms on:
  - action-edge `if(...)` / `elseif(...)` / `else()` / `endif()` bodies,
  - action-edge `switch(...)` / `case(...)` / `default()` / `endswitch()` bodies,
  - lifecycle `LX.if(...)` / `elseif(...)` / `else()` / `endif()` bodies,
  - and lifecycle `LX.switch(...)` / `case(...)` / `default()` / `endswitch()` bodies.
- Locked parity on:
  - identical `ACODE` or `LXCODE`,
  - zero fallback,
  - zero unresolved helpers,
  - zero raw Perl dependency,
  - identical canonical action-IR node coverage,
  - and language-agnostic readiness metadata.
- Tracker interpretation:
  - `Method-like DSL migration track` stays `in progress`,
  - because this slice deepens supported branch-local canonical call-value equivalence coverage without changing the track level.

## 2026-03-14 - Method-Like DSL Slice: Lock Call-Value Helper Equivalence
## Summary
Extended the method-like DSL migration track by regression-locking canonical call-value capture between fluent and structured authoring on both action-edge and lifecycle surfaces. Supported `assign(scalar(retv), call(rule))` forms now preserve the same lowering and migration metadata across both concrete syntaxes.

## Changed Files
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `USER_GUIDE.md`
- Updated: `USER_GUIDE_ActionIR_MethodLowering.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`

## Technical Details
- Added focused fluent-versus-structured equivalence locks for supported canonical call-value capture forms on:
  - action-edge method chains,
  - and lifecycle `LX` method chains.
- Locked parity on:
  - identical `ACODE` or `LXCODE`,
  - zero fallback,
  - zero unresolved helpers,
  - zero raw Perl dependency,
  - identical canonical action-IR node coverage,
  - and language-agnostic readiness metadata.
- Tracker interpretation:
  - `Method-like DSL migration track` stays `in progress`,
  - because this slice deepens supported fluent/block equivalence coverage for canonical call-result capture without changing the track level.

## 2026-03-14 - Docs Contract: Lock Readability and Non-Ambiguity Standard
## Summary
Recorded a project-level documentation quality contract so readability, non-ambiguity, direct explanations, and representative examples are treated as explicit goals rather than informal style preferences.

## Changed Files
- Updated: `ROADMAP.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`
- Updated: `CHANGES.md`

## Technical Details
- Added a strategic-principle level documentation contract in `ROADMAP.md`.
- Added the same expectation to Phase 6 so documentation/adoption work has an explicit readability goal.
- Mirrored the contract into `DEVELOPMENT_NOTES.md` and `MEMORY.md` so it persists across sessions and future refactor slices.
- Tracker interpretation:
  - no live-status row changes,
  - because this is a process/quality-contract clarification rather than a roadmap-level completion change.

## 2026-03-14 - Method-Like DSL Slice: Lock Branch-Local Flat-List Equivalence
## Summary
Extended the method-like DSL migration track by regression-locking list-context insertion helpers inside control-flow branch bodies. Supported `flat_array(...)` and `flat_hash(...)` return payloads now preserve the same lowering and migration metadata across fluent and structured authoring for `if/elseif` and `switch/case` forms on both action-edge and lifecycle surfaces.

## Changed Files
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `USER_GUIDE.md`
- Updated: `USER_GUIDE_ActionIR_MethodLowering.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`

## Technical Details
- Added focused fluent-versus-structured equivalence locks for supported branch-local `flat_array(...)` / `flat_hash(...)` helper forms on:
  - action-edge `if(...)` / `elseif(...)` / `else()` / `endif()` bodies,
  - action-edge `switch(...)` / `case(...)` / `default()` / `endswitch()` bodies,
  - lifecycle `LX.if(...)` / `elseif(...)` / `else()` / `endif()` bodies,
  - and lifecycle `LX.switch(...)` / `case(...)` / `default()` / `endswitch()` bodies.
- Locked parity on:
  - identical `ACODE` or `LXCODE`,
  - zero fallback,
  - zero unresolved helpers,
  - zero raw Perl dependency,
  - identical canonical action-IR node coverage,
  - and language-agnostic readiness metadata.
- Tracker interpretation:
  - `Method-like DSL migration track` stays `in progress`,
  - because this slice deepens supported fluent/block equivalence coverage inside active branch-local control-flow surfaces rather than changing the track level.

## 2026-03-14 - Method-Like DSL Slice: Lock Branch-Local Join-Values Equivalence
## Summary
Extended the method-like DSL migration track by regression-locking string-join payload helpers inside control-flow branch bodies. Supported `join_values(delimiter, array(...))` return payloads now preserve the same lowering and migration metadata across fluent and structured authoring for `if/elseif` and `switch/case` forms on both action-edge and lifecycle surfaces.

## Changed Files
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `USER_GUIDE.md`
- Updated: `USER_GUIDE_ActionIR_MethodLowering.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`

## Technical Details
- Added focused fluent-versus-structured equivalence locks for supported branch-local `join_values(delimiter, array(...))` helper forms on:
  - action-edge `if(...)` / `elseif(...)` / `else()` / `endif()` bodies,
  - action-edge `switch(...)` / `case(...)` / `default()` / `endswitch()` bodies,
  - lifecycle `LX.if(...)` / `elseif(...)` / `else()` / `endif()` bodies,
  - and lifecycle `LX.switch(...)` / `case(...)` / `default()` / `endswitch()` bodies.
- Locked parity on:
  - identical `ACODE` or `LXCODE`,
  - zero fallback,
  - zero unresolved helpers,
  - zero raw Perl dependency,
  - identical canonical action-IR node coverage,
  - and language-agnostic readiness metadata.
- Tracker interpretation:
  - `Method-like DSL migration track` stays `in progress`,
  - because this slice deepens supported fluent/block equivalence coverage inside active branch-local control-flow surfaces rather than changing the track level.

## 2026-03-14 - Method-Like DSL Slice: Lock Join-Values Helper Equivalence
## Summary
Extended the method-like DSL migration track by regression-locking string-join payload helpers between fluent and structured authoring on both action-edge and lifecycle surfaces. Supported `join_values(delimiter, array(...))` payload forms now preserve the same lowering and migration metadata across both concrete syntaxes.

## Changed Files
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `USER_GUIDE.md`
- Updated: `USER_GUIDE_ActionIR_MethodLowering.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`

## Technical Details
- Added focused fluent-versus-structured equivalence locks for supported `join_values(delimiter, array(...))` payload forms on:
  - action-edge method chains,
  - and lifecycle `LX` method chains.
- Locked parity on:
  - identical `ACODE` or `LXCODE`,
  - zero fallback,
  - zero unresolved helpers,
  - zero raw Perl dependency,
  - identical canonical action-IR node coverage,
  - and language-agnostic readiness metadata.
- Tracker interpretation:
  - `Method-like DSL migration track` stays `in progress`,
  - because this slice deepens supported fluent/block equivalence coverage for joined-string payload helpers without changing the track level.

## 2026-03-14 - Method-Like DSL Slice: Lock Branch-Local Array Snapshot Equivalence
## Summary
Extended the method-like DSL migration track by regression-locking snapshot payload helpers inside control-flow branch bodies. Supported `array_copy(...)` and compatibility `array_values(...)` return payloads now preserve the same lowering and migration metadata across fluent and structured authoring for `if/elseif` and `switch/case` forms on both action-edge and lifecycle surfaces.

## Changed Files
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `USER_GUIDE.md`
- Updated: `USER_GUIDE_ActionIR_MethodLowering.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`

## Technical Details
- Added focused fluent-versus-structured equivalence locks for supported branch-local array snapshot helper forms on:
  - action-edge `if(...)` / `elseif(...)` / `else()` / `endif()` bodies,
  - action-edge `switch(...)` / `case(...)` / `default()` / `endswitch()` bodies,
  - lifecycle `LX.if(...)` / `elseif(...)` / `else()` / `endif()` bodies,
  - and lifecycle `LX.switch(...)` / `case(...)` / `default()` / `endswitch()` bodies.
- The locked snapshot payload helper surface includes:
  - preferred `array_copy(...)`,
  - and compatibility `array_values(...)`.
- Locked parity on:
  - identical `ACODE` or `LXCODE`,
  - zero fallback,
  - zero unresolved helpers,
  - zero raw Perl dependency,
  - identical canonical action-IR node coverage,
  - and language-agnostic readiness metadata.
- Tracker interpretation:
  - `Method-like DSL migration track` stays `in progress`,
  - because this slice deepens supported fluent/block equivalence coverage inside active branch-local control-flow surfaces rather than changing the track level.

## 2026-03-14 - Method-Like DSL Slice: Lock Array Snapshot Helper Equivalence
## Summary
Extended the method-like DSL migration track by regression-locking snapshot payload helpers between fluent and structured authoring on both action-edge and lifecycle surfaces. Supported `array_copy(...)` and compatibility `array_values(...)` payload forms now preserve the same lowering and migration metadata across both concrete syntaxes.

## Changed Files
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `USER_GUIDE.md`
- Updated: `USER_GUIDE_ActionIR_MethodLowering.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`

## Technical Details
- Added focused fluent-versus-structured equivalence locks for supported array snapshot helper forms on:
  - action edges with `-> rule .return(...array_copy/array_values...)`,
  - and lifecycle sections with `LX.return(...array_copy/array_values...)`.
- The locked snapshot payload helper surface includes:
  - preferred `array_copy(...)`,
  - and compatibility `array_values(...)`.
- Locked parity on:
  - identical `ACODE` or `LXCODE`,
  - zero fallback,
  - zero unresolved helpers,
  - zero raw Perl dependency,
  - identical canonical action-IR node coverage,
  - and language-agnostic readiness metadata.
- Tracker interpretation:
  - `Method-like DSL migration track` stays `in progress`,
  - because this slice deepens supported fluent/block equivalence coverage inside the active track rather than changing the track level.

## 2026-03-14 - Method-Like DSL Slice: Lock Flat-List Helper Equivalence
## Summary
Extended the method-like DSL migration track by regression-locking list-context insertion helpers between fluent and structured authoring on both action-edge and lifecycle surfaces. Supported `flat_array(...)` and `flat_hash(...)` payload forms now preserve the same lowering and migration metadata across both concrete syntaxes.

## Changed Files
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `USER_GUIDE.md`
- Updated: `USER_GUIDE_ActionIR_MethodLowering.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`

## Technical Details
- Added focused fluent-versus-structured equivalence locks for supported flat-list insertion helper forms on:
  - action edges with `-> rule .return(...flat_*...)`,
  - and lifecycle sections with `LX.return(...flat_*...)`.
- The locked list-context insertion helper surface includes:
  - `flat_array(...)`,
  - and `flat_hash(...)`.
- Locked parity on:
  - identical `ACODE` or `LXCODE`,
  - zero fallback,
  - zero unresolved helpers,
  - zero raw Perl dependency,
  - identical canonical action-IR node coverage,
  - and language-agnostic readiness metadata.
- Tracker interpretation:
  - `Method-like DSL migration track` stays `in progress`,
  - because this slice deepens supported fluent/block equivalence coverage inside the active track rather than changing the track level.

## 2026-03-14 - Method-Like DSL Slice: Lock Inline Composite Switch Equivalence
## Summary
Extended the method-like DSL migration track by regression-locking inline composite `switch(..., case(...), default(...))` forms between fluent and structured authoring on both action-edge and lifecycle surfaces. Supported inline helper sequences inside `case(...)` and `default(...)` now preserve the same lowering and migration metadata across both concrete syntaxes.

## Changed Files
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `USER_GUIDE.md`
- Updated: `USER_GUIDE_ActionIR_ControlFlow.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`

## Technical Details
- Added focused fluent-versus-structured equivalence locks for inline composite switch forms on:
  - action edges with `-> rule .switch(..., case(...), default(...))`,
  - and lifecycle sections with `LX.switch(..., case(...), default(...))`.
- The locked inline branch action sequences include supported combinations of:
  - `declare(...)`,
  - `push_value(...)`,
  - `say(...)`,
  - and `return_*` helpers.
- Locked parity on:
  - identical `ACODE` or `LXCODE`,
  - zero fallback,
  - zero unresolved helpers,
  - zero raw Perl dependency,
  - identical canonical action-IR node coverage,
  - and language-agnostic readiness metadata.
- Tracker interpretation:
  - `Method-like DSL migration track` stays `in progress`,
  - because this slice deepens supported fluent/block equivalence coverage inside the active track rather than changing the track level.

## 2026-03-14 - Method-Like DSL Slice: Lock Multi-Step Lifecycle Branch Bodies
## Summary
Extended the method-like DSL migration track by regression-locking supported multi-step method sequences inside lifecycle control-flow bodies. Fluent and structured lifecycle forms now agree inside `if(...)` / `elseif(...)` and `switch(...)` / `case(...)` branch bodies when those bodies contain supported helper sequences rather than only a single payload-return call.

## Changed Files
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `USER_GUIDE.md`
- Updated: `USER_GUIDE_ActionIR_ControlFlow.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`

## Technical Details
- Added focused lifecycle equivalence locks for supported multi-step branch-local control-flow forms in:
  - `LX.if(...) ... elseif(...) ... else() ... endif()`,
  - and `LX.switch(...) ... case(...) ... default() ... endswitch()`.
- The locked branch-local helper sequences include supported combinations of:
  - `declare(...)`,
  - `push_value(...)`,
  - `say(...)`,
  - and `return_*` helpers.
- Locked parity on:
  - identical `LXCODE`,
  - zero fallback,
  - zero unresolved helpers,
  - zero raw Perl dependency,
  - identical canonical action-IR node coverage,
  - and language-agnostic readiness metadata.
- Tracker interpretation:
  - `Method-like DSL migration track` stays `in progress`,
  - because this slice broadens supported lifecycle branch-local equivalence coverage inside the active track rather than changing the track level.

## 2026-03-14 - Method-Like DSL Slice: Lock Multi-Step Action-Edge Branch Bodies
## Summary
Extended the method-like DSL migration track by regression-locking supported multi-step method sequences inside action-edge control-flow bodies. Fluent and structured forms now agree inside `if(...)` / `elseif(...)` and `switch(...)` / `case(...)` branch bodies even when those bodies contain supported helper sequences rather than only a single return payload call.

## Changed Files
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `USER_GUIDE.md`
- Updated: `USER_GUIDE_ActionIR_ControlFlow.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`

## Technical Details
- Added focused action-edge equivalence locks for supported multi-step branch-local control-flow forms in:
  - `if(...)` / `elseif(...)` / `else()` / `endif()` bodies,
  - and `switch(...)` / `case(...)` / `default()` / `endswitch()` bodies.
- The locked branch-local helper sequences include supported combinations of:
  - `declare(...)`,
  - `push_value(...)`,
  - `say(...)`,
  - and `return_*` helpers.
- Locked parity on:
  - identical `ACODE`,
  - zero fallback,
  - zero unresolved helpers,
  - zero raw Perl dependency,
  - identical canonical action-IR node coverage,
  - and language-agnostic readiness metadata.
- Tracker interpretation:
  - `Method-like DSL migration track` stays `in progress`,
  - because this slice broadens supported action-edge branch-local equivalence coverage inside the active track rather than changing the track level.

## 2026-03-14 - Method-Like DSL Slice: Lock Lifecycle Branch-Local Control-Flow Equivalence
## Summary
Extended the method-like DSL migration track by regression-locking the same supported branch-local fluent-versus-structured control-flow equivalence on lifecycle surfaces too. Supported `LX` `if(...)` / `elseif(...)` and `switch(...)` / `case(...)` forms now agree between fluent chains and structured lifecycle blocks on lowered lifecycle code and migration metadata.

## Changed Files
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `USER_GUIDE.md`
- Updated: `USER_GUIDE_ActionIR_ControlFlow.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`

## Technical Details
- Added focused lifecycle equivalence locks for supported branch-local control-flow forms in:
  - `LX.if(...) ... elseif(...) ... else() ... endif()`,
  - `LX.switch(...) ... case(...) ... default() ... endswitch()`,
  - and their structured lifecycle-block equivalents.
- Locked parity on:
  - identical `LXCODE`,
  - zero fallback,
  - zero unresolved helpers,
  - zero raw Perl dependency,
  - identical canonical action-IR node coverage,
  - and language-agnostic readiness metadata.
- Tracker interpretation:
  - `Method-like DSL migration track` stays `in progress`,
  - because this slice broadens supported lifecycle control-flow equivalence coverage inside the active track rather than changing the track level.

## 2026-03-14 - Method-Like DSL Slice: Fix Branch-Local Fluent Return Chains
## Summary
Fixed a real method-like DSL branch-local equivalence bug: fluent control-flow chains were being truncated at the first general `return(...)` payload inside `if(...)` / `elseif(...)` and `switch(...)` / `case(...)` branch bodies. Supported fluent and structured branch-local forms now stay aligned on canonical action-IR coverage and migration metadata.

## Changed Files
- Updated: `perl/LinkedSpec/BootstrapSpec/Core.pm`
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `USER_GUIDE.md`
- Updated: `USER_GUIDE_ActionIR_ControlFlow.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`

## Technical Details
- Fixed `LinkedSpec::BootstrapSpec::Core::_render_method_call_chain(...)` so a general-payload `return(...)` no longer aborts the rest of the fluent-chain render.
- Added focused regression locks for supported branch-local fluent-versus-structured equivalence in:
  - `if(...)` / `elseif(...)` / `else()` / `endif()` bodies,
  - and `switch(...)` / `case(...)` / `default()` / `endswitch()` bodies.
- Locked parity on:
  - zero fallback,
  - zero unresolved helpers,
  - zero raw Perl dependency,
  - identical canonical action-IR node coverage,
  - and language-agnostic readiness metadata.
- Tracker interpretation:
  - `Method-like DSL migration track` stays `in progress`,
  - because this slice fixes and locks another supported branch-local surface inside the active track rather than changing the track level.

## 2026-03-14 - Documentation Policy Slice: Clarify Branch-Local Fluent/Block Equivalence Scope
## Summary
Clarified the method-like DSL target surface so fluent-versus-structured equivalence is now stated explicitly for branch-local control-flow bodies too: `if(...)` / `elseif(...)` branches and `switch(...)` / `case(...)` action bodies are part of the same equivalence goal, not a separate exception surface.

## Changed Files
- Updated: `ROADMAP.md`
- Updated: `USER_GUIDE.md`
- Updated: `USER_GUIDE_ActionIR_ControlFlow.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`

## Technical Details
- Clarified the roadmap’s `Structured block equivalence` and `Unified lowering path` items so branch-local method sequences are explicitly in scope.
- Clarified the user guides so branch-local method bodies are treated as part of the same fluent-versus-structured equivalence target.
- Tracker interpretation:
  - `Method-like DSL migration track` stays `in progress`,
  - because this slice clarifies target scope only.

## 2026-03-14 - Method-Like DSL Slice: Lock Collection-Hash Action Forms
## Summary
Extended the dedicated method-like DSL migration track by regression-locking the supported collection-hash method shape on action-edge surfaces too: fluent `-> rule .m1(...).m2(...)` and structured `-> rule { m1(...); m2(...); }` forms now agree on compiled action output and migration metadata for that supported chain.

## Changed Files
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `USER_GUIDE.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`

## Technical Details
- Added a focused fluent-versus-structured action-edge equivalence regression for a supported collection-hash method chain combining:
  - `declare(hash, ...)`,
  - `declare(array, ...)`,
  - `push_value(array(...), hash(...))`,
  - and `return_array(..., hash(...))`.
- Locked equivalence on:
  - compiled `ACODE`,
  - canonical action-IR node coverage,
  - zero fallback,
  - zero unresolved helpers,
  - and language-agnostic readiness metadata.
- Tracker interpretation:
  - `Method-like DSL migration track` stays `in progress`,
  - because this slice broadens supported fluent/block equivalence coverage inside the active track rather than changing the track level.

## Validation
- Ran:
  - `perl -c -Iperl t/phase0_regression.t`
  - `prove -v -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
- Result:
  - PASS (`Files=1, Tests=251`)

## 2026-03-14 - Documentation Policy Slice: Clarify Unlimited Nested Composition Wording
## Summary
Clarified the roadmap and user-guide policy for method-like DSL nesting: unlimited nested method composition in method arguments is an explicit supported capability, but the docs should present that capability with representative examples rather than trying to enumerate every legal nesting form.

## Changed Files
- Updated: `ROADMAP.md`
- Updated: `USER_GUIDE.md`
- Updated: `USER_GUIDE_ActionIR_MethodLowering.md`
- Updated: `USER_GUIDE_ActionIR_ArrayPipeline.md`
- Updated: `USER_GUIDE_ActionIR_ValueExpr.md`
- Updated: `USER_GUIDE_ActionIR_DeclareMethod.md`
- Updated: `USER_GUIDE_ActionIR_EmittedPerlReference.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`

## Technical Details
- Removed the implication that the docs should spell out concrete nesting families in detail.
- Added explicit wording that:
  - unlimited nested method composition in arguments is supported,
  - focused guides should use representative examples only,
  - and the emitted-Perl reference is exhaustive over helper/lowering surfaces, not over every possible nesting arrangement.
- Tracker interpretation:
  - `Method-like DSL migration track` stays `in progress`,
  - because this slice clarifies documentation policy only.

## 2026-03-14 - Method-Like DSL Slice: Lock Collection-Hash Pipeline Forms
## Summary
Extended the dedicated method-like DSL migration track by regression-locking collection-valued nested array-pipeline composition on broader hash/object-oriented surfaces: `declare(hash, ...)`, `assign(hash(...), ...)`, `push_value(array(...), hash(...))`, and `return_array(..., hash(...))` now have explicit coverage, and fluent versus structured lifecycle surfaces agree on that metadata too.

## Changed Files
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `USER_GUIDE.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`

## Technical Details
- Added direct lowering regressions for:
  - `declare(hash, name=hash(... array(pipeline(...))))`,
  - `assign(hash(target), hash(... array(pipeline(...))))`,
  - `push_value(array(target), hash(... array(pipeline(...))))`,
  - and `return_array(tag, hash(... array(pipeline(...))))`.
- Added a fluent-versus-structured lifecycle equivalence regression for collection-valued nested array-pipeline composition inside hash/object-oriented method surfaces.
- Tracker interpretation:
  - `Method-like DSL migration track` stays `in progress`,
  - because this slice broadens supported collection-hash coverage inside the active track rather than changing the track level.

## Validation
- Ran:
  - `perl -c -Iperl t/phase0_regression.t`
  - `prove -v -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
- Result:
  - PASS (`Files=1, Tests=250`)

## 2026-03-14 - Method-Like DSL Slice: Lock Collection-Value Pipeline Forms
## Summary
Extended the dedicated method-like DSL migration track by regression-locking collection-valued nested array-pipeline composition on supported surfaces: `declare(array, ...)`, `assign(array(...), ...)`, and nested hash/array payload values now have explicit coverage, and fluent versus structured lifecycle surfaces agree on that metadata too.

## Changed Files
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `USER_GUIDE.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`

## Technical Details
- Added direct lowering regressions for:
  - `declare(array, name=pipeline(...))`,
  - `assign(array(target), pipeline(...))`,
  - nested hash payload values using `array(pipeline(...))`,
  - and nested array payload values using `array(pipeline(...))`.
- Added a fluent-versus-structured lifecycle equivalence regression for collection-valued nested array-pipeline composition inside `declare(array, ...)` and `assign(array(...), ...)`.
- Tracker interpretation:
  - `Method-like DSL migration track` stays `in progress`,
  - because this slice broadens supported collection-value coverage inside the active track rather than changing the track level.

## Validation
- Ran:
  - `perl -c -Iperl t/phase0_regression.t`
  - `prove -v -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
- Result:
  - PASS (`Files=1, Tests=249`)

## 2026-03-14 - Method-Like DSL Slice: Lower Nested Return-Payload Pipelines
## Summary
Extended the dedicated method-like DSL migration track on a second supported surface: helper-only nested array-pipeline composition inside `return(array(...))` now lowers cleanly, and fluent versus structured method surfaces now report matching zero-unresolved / zero-fallback migration metadata for that return-payload shape.

## Changed Files
- Updated: `perl/LinkedSpec/ActionIR/MethodLowering.pm`
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `USER_GUIDE.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`

## Technical Details
- `LinkedSpec::ActionIR::MethodLowering` now pulls the existing `_lower_array_pipeline_expr(...)` owner callback into its default dependency map.
- Nested method value lowering now recognizes array-pipeline composition when that composition appears as a value inside supported payload contexts such as `return(array(filter_match(...)))`.
- Added regression coverage for:
  - direct lowering of nested array-pipeline composition inside generalized `return(array(...))`,
  - and fluent-versus-structured metadata equivalence for that same supported return-payload shape.
- Tracker interpretation:
  - `Method-like DSL migration track` stays `in progress`,
  - because this slice expands supported coverage inside the same active track rather than moving it to a new level.

## Validation
- Ran:
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/MethodLowering.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `prove -v -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
- Result:
  - PASS (`Files=1, Tests=248`)

## 2026-03-14 - Method-Like DSL Slice: Lock Fluent/Structured Equivalence For Helper-Only Forms
## Summary
Started the dedicated method-like DSL migration track by locking a concrete user-facing contract on supported surfaces: helper-only fluent action chains and structured `{...}` action blocks now have explicit regression coverage proving identical action lowering, and helper-only lifecycle chains with nested composed arguments now have explicit regression coverage proving identical lifecycle lowering.

## Changed Files
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `USER_GUIDE.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`

## Technical Details
- Added a dedicated method-like migration regression:
  - `method_like_fluent_and_structured_blocks_lower_equivalently`
  - compares fluent and structured authoring surfaces directly on two supported surfaces,
  - asserts identical lowered `ACODE` for helper-only action chains and identical lowered `ICODE` for lifecycle chains with nested composed arguments,
  - asserts zero raw-Perl dependency / zero unresolved helpers / zero fallback for both,
  - and asserts identical canonical action-IR node coverage for the helper-only action-chain surface.
- Updated roadmap interpretation:
  - the method-like DSL migration track now moves to `in progress`,
  - because dedicated user-facing migration work has landed,
  - while still keeping Backbone Item 3 prerequisite work conceptually separate.
- Updated the guide to say this equivalence is now an explicit locked contract on supported surfaces, not a blanket claim for every nested return-payload shape yet.

## Validation
- Ran:
  - `perl -c -Iperl t/phase0_regression.t`
  - `prove -v -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
- Result:
  - PASS (`Files=1, Tests=247`)

## 2026-03-14 - Process Slice: Clarify Backend-Neutral Method DSL Goal
## Summary
Corrected the roadmap and guide language so the backend-neutral goal is no longer framed as removing `{...}` blocks entirely. The clarified target is to remove raw Perl dependence while supporting two equivalent structured DSL surfaces: fluent method chains and structured `{...}` method blocks, both with unlimited nested method composition in arguments.

## Changed Files
- Updated: `ROADMAP.md`
- Updated: `USER_GUIDE.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`

## Technical Details
- Rewrote the method-like DSL roadmap language:
  - replaced blanket `{...}` deprecation wording,
  - added explicit equivalence between fluent chains and structured method blocks,
  - added unlimited nested method-composition support as a first-class long-term goal,
  - narrowed deprecation language to raw Perl dependence only.
- Updated the top-level user guide to explain:
  - fluent chains and structured `{...}` blocks are intended to be equivalent semantic surfaces when they contain method-like DSL statements,
  - nested method composition inside arguments is part of the backend-neutral target surface too.

## Validation
- Ran:
  - `git diff --stat -- ROADMAP.md USER_GUIDE.md CHANGES.md DEVELOPMENT_NOTES.md MEMORY.md`
  - `git status --short`
- Result:
  - Doc-only clarification slice reviewed; no code paths changed.

## 2026-03-14 - Process Slice: Clarify Method-Like DSL Track Status Interpretation
## Summary
Removed an ambiguity in the roadmap by stating explicitly that Backbone Item 3 groundwork does not count as the method-like DSL migration track having started. That row remains `not started` until dedicated migration work lands for that track itself.

## Changed Files
- Updated: `ROADMAP.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`

## Technical Details
- Added an explicit interpretation note to the `Method-Like DSL Migration Track` section.
- Tightened the dashboard row wording for `Method-like DSL migration track` so it now states:
  - groundwork under Backbone Item 3 is prerequisite work,
  - but it does not move the migration-track status by itself.
- Added a matching clarification under the Backbone Item 3 detailed notes so the relationship between the two tracks is explicit in both directions.

## Validation
- Ran:
  - `git diff --stat -- ROADMAP.md CHANGES.md DEVELOPMENT_NOTES.md MEMORY.md`
  - `git status --short`
- Result:
  - Doc-only clarification slice reviewed; no code paths changed.

## 2026-03-14 - Process Slice: Show Only Affected Live-Tracker Rows By Default
## Summary
Adjusted the roadmap close-out workflow so commit summaries no longer print the entire live tracker by default. They now show only the rows affected by the current task unless a full tracker dump is explicitly requested.

## Changed Files
- Updated: `ROADMAP.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`

## Technical Details
- Replaced the previous default full-tracker display rule with a narrower default:
  - show changed or directly impacted tracker rows in normal commit close-outs,
  - show the full tracker only when the user explicitly asks for it.
- Kept the richer row format:
  - whenever a row is shown, it still includes the brief `What it covers` scope description.
- Mirrored the workflow change into interruption-safe notes so the smaller default display survives session loss.

## Validation
- Ran:
  - `git diff --stat -- ROADMAP.md CHANGES.md DEVELOPMENT_NOTES.md MEMORY.md`
  - `git status --short`
- Result:
  - Doc-only process slice reviewed; no code paths changed.

## 2026-03-14 - Process Slice: Add Scope Descriptions To The Live-Status Tracker
## Summary
Expanded the canonical roadmap dashboard so every live-status row now includes a brief scope description, and tightened the workflow so displayed tracker snapshots must include that description instead of only showing raw status labels.

## Changed Files
- Updated: `ROADMAP.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`

## Technical Details
- Strengthened the tracker-display contract:
  - every close-out tracker snapshot must show what each row actually covers,
  - not just the area name and current level.
- Expanded the canonical `ROADMAP.md` dashboard:
  - added a `What it covers` column,
  - filled every tracked area with a short scope description,
  - kept the four-level status vocabulary unchanged.
- Mirrored the workflow rule into interruption-safe notes so future sessions keep the richer tracker display.

## Validation
- Ran:
  - `git diff --stat -- ROADMAP.md CHANGES.md DEVELOPMENT_NOTES.md MEMORY.md`
  - `git status --short`
- Result:
  - Doc-only process slice reviewed; no code paths changed.

## 2026-03-14 - Backbone Item 3 Slice: Collapse `ActionRewriter` Compatibility Wrappers Through A Shared `EmitContext` Delegator
## Summary
Collapsed the remaining `LinkedSpec::ActionRewriter` compatibility-wrapper wall into one shared `EmitContext` delegator, while preserving the legacy two-argument rewrite-helper call shape through the active `EmitContext` owner path.

## Changed Files
- Updated: `perl/LinkedSpec/ActionRewriter.pm`
- Updated: `perl/LinkedSpec/RuleIR/EmitContext.pm`
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `USER_GUIDE.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`

## Technical Details
- Replaced the long manual `LinkedSpec::ActionRewriter` wrapper wall with:
  - a shared `_delegate_emit_context_call(...)` helper,
  - generated wrapper installation for the remaining compatibility entrypoints,
  - and a focused direct `call_spec_handler_subst(...)` handoff to `EmitContext::rewrite_action_code_for_compat(...)`.
- Preserved compatibility semantics:
  - the legacy ActionRewriter helper surface still exists,
  - helper families still lazy-load `LinkedSpec::RuleIR::EmitContext` on demand,
  - and `LinkedSpec::RuleIR::EmitContext::_rewrite_action_code_with_diagnostics(...)` now explicitly threads the optional rewrite-rules argument so the historical two-argument `ActionRewriter` rewrite-helper entrypoint continues to work.
- Added focused seam coverage:
  - `action_rewriter_compat_wrappers_share_emit_context_delegator`
    to lock representative helper families to the shared delegator path.

## Validation
- Ran:
  - `perl -Iperl -c perl/LinkedSpec/ActionRewriter.pm`
  - `perl -Iperl -c perl/LinkedSpec/RuleIR/EmitContext.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `prove -v -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
- Result:
  - PASS (`Files=1, Tests=246`)

## 2026-03-14 - Process Slice: Document Dependency-First Roadmap Execution
## Summary
Made the roadmap execution policy explicit: phase numbering is a tracking/progression aid, but default execution is dependency-first rather than strict phase-by-phase waterfall ordering.

## Changed Files
- Updated: `ROADMAP.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`

## Technical Details
- Clarified the canonical roadmap contract:
  - phase numbers define objective groupings and intended broad progression,
  - execution defaults to bounded dependency-ordered slices,
  - strict sequential phase execution applies only when explicitly requested.
- Mirrored the same rule into interruption-safe notes so the execution policy stays explicit across session loss.

## Validation
- Ran:
  - `git diff --stat -- ROADMAP.md CHANGES.md DEVELOPMENT_NOTES.md MEMORY.md`
  - `git status --short`
- Result:
  - Doc-only process slice reviewed; no code paths changed.

## 2026-03-14 - Process Slice: Display Current Live-Status Tracker On Every Commit Close-Out
## Summary
Tightened the roadmap workflow so every commit close-out must now include the current live-status tracker snapshot, making it explicit whether the completed slice changed the dashboard or left it unchanged.

## Changed Files
- Updated: `ROADMAP.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`

## Technical Details
- Strengthened the canonical roadmap workflow:
  - `ROADMAP.md` remains the live status source,
  - dashboard rows must still be updated before commits when status materially changes,
  - changed rows must still be displayed/logged when levels move,
  - and now every commit close-out must also display the current live-status tracker snapshot.
- Mirrored the same rule into the interruption-safe notes so the workflow survives session loss.

## Validation
- Ran:
  - `git diff --stat -- ROADMAP.md CHANGES.md DEVELOPMENT_NOTES.md MEMORY.md`
  - `git status --short`
- Result:
  - Doc-only process slice reviewed; no code paths changed.

## 2026-03-14 - Backbone Item 3 Slice: Route `EmitContext` RewritePipeline Deps Through Owner Map
## Summary
Made the remaining emit-context rewrite-pipeline dependency seam explicit by locking `LinkedSpec::RuleIR::EmitContext` to `LinkedSpec::ActionIR::RewritePipeline::default_deps_for_package(__PACKAGE__)`, so the extracted rewrite-pipeline owner defines that callback contract in one place too.

## Changed Files
- Updated: `perl/LinkedSpec/RuleIR/EmitContext.pm`
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `USER_GUIDE.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`

## Technical Details
- Tightened the emit-context owner-map seam:
  - moved `LinkedSpec::RuleIR::EmitContext::_rewrite_pipeline_deps()` up into the grouped owner-dependency section so the remaining callback-map owners stay clustered together,
  - added focused regression coverage that locks `_build_action_rewrite_rules(...)` to `LinkedSpec::ActionIR::RewritePipeline::default_deps_for_package(__PACKAGE__)`.
- Preserved behavior:
  - `EmitContext` still rewrites helper code through `LinkedSpec::ActionIR::RewritePipeline`,
  - caller `$@` is still preserved on successful rewrite-pipeline owner delegation,
  - require-only consumers still keep `RewritePipeline.pm` unloaded until rewrite helpers are actually exercised.
- Updated focused regression coverage:
  - added `emit_context_rewrite_pipeline_deps_route_through_owner_default_map` to lock that `EmitContext` now asks `RewritePipeline` for the callback map owned by `LinkedSpec::RuleIR::EmitContext`.

## Validation
- Ran:
  - `perl -Iperl -c perl/LinkedSpec/RuleIR/EmitContext.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `prove -v -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
- Result:
  - PASS (`Files=1, Tests=245`)

## 2026-03-14 - Backbone Item 3 Slice: Route `EmitContext` Action-Contract Deps Through Owner Map
## Summary
Moved `LinkedSpec::RuleIR::EmitContext` off its hand-built action-contract callback map and onto `LinkedSpec::ActionIR::Contracts::default_deps_for_package(__PACKAGE__)`, so the extracted contracts owner now defines that dependency contract in one place.

## Changed Files
- Updated: `perl/LinkedSpec/RuleIR/EmitContext.pm`
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `USER_GUIDE.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`

## Technical Details
- Refactored owner dependency resolution:
  - changed `LinkedSpec::RuleIR::EmitContext::_action_contract_deps()` to delegate to `LinkedSpec::ActionIR::Contracts::default_deps_for_package(__PACKAGE__)`,
  - stopped hand-building the local Contracts callback map in `EmitContext`.
- Preserved behavior:
  - `EmitContext` still builds lowering contracts through `LinkedSpec::ActionIR::Contracts`,
  - caller `$@` is still preserved on successful contract-helper delegation,
  - require-only consumers still keep `Contracts.pm` unloaded until the contract-helper path is actually exercised.
- Updated focused regression coverage:
  - added `emit_context_action_contract_deps_route_through_owner_default_map` to lock that `EmitContext` now asks `Contracts` for the callback map owned by `LinkedSpec::RuleIR::EmitContext`.

## Validation
- Ran:
  - `perl -Iperl -c perl/LinkedSpec/RuleIR/EmitContext.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `prove -v -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
- Result:
  - PASS (`Files=1, Tests=244`)

## 2026-03-14 - Process Slice: Require Status-Change Display Plus Roadmap Logging
## Summary
Tightened the live-status workflow so any dashboard level change must now be surfaced in the task close-out and logged in the canonical roadmap dashboard source.

## Changed Files
- Updated: `ROADMAP.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`

## Technical Details
- Strengthened the roadmap tracking rule:
  - `ROADMAP.md` remains the canonical live-status source,
  - any dashboard row whose level changes must now be displayed in the user-facing task close-out,
  - and the same level change must be recorded in `ROADMAP.md`.
- Mirrored the rule into the interruption-safe notes files so the workflow survives session loss.

## Validation
- Ran:
  - `git diff --stat -- ROADMAP.md CHANGES.md DEVELOPMENT_NOTES.md MEMORY.md`
  - `git status --short`
- Result:
  - Doc-only process slice reviewed; no code paths changed.

## 2026-03-14 - Backbone Item 3 Slice: Route `EmitContext` Scanner Deps Through Owner Map
## Summary
Moved `LinkedSpec::RuleIR::EmitContext` off its hand-built scanner callback map and onto `LinkedSpec::ActionIR::Scanner::default_deps_for_package(__PACKAGE__)`, so the extracted scanner owner now defines that dependency contract in one place.

## Changed Files
- Updated: `perl/LinkedSpec/RuleIR/EmitContext.pm`
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `USER_GUIDE.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`

## Technical Details
- Refactored owner dependency resolution:
  - changed `LinkedSpec::RuleIR::EmitContext::_scan_contract_ir_event_deps()` to delegate to `LinkedSpec::ActionIR::Scanner::default_deps_for_package(__PACKAGE__)`,
  - stopped hand-building the local Scanner callback map in `EmitContext`.
- Preserved behavior:
  - `EmitContext` still scans action/helper contract events through `LinkedSpec::ActionIR::Scanner`,
  - caller `$@` is still preserved on successful scanner-helper delegation,
  - require-only consumers still keep `Scanner.pm` unloaded until the scanner helper path is actually exercised.
- Updated focused regression coverage:
  - added `emit_context_scanner_deps_route_through_owner_default_map` to lock that `EmitContext` now asks `Scanner` for the callback map owned by `LinkedSpec::RuleIR::EmitContext`.

## Validation
- Ran:
  - `perl -Iperl -c perl/LinkedSpec/RuleIR/EmitContext.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `prove -v -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
- Result:
  - PASS (`Files=1, Tests=243`)

## 2026-03-14 - Backbone Item 3 Slice: Route `EmitContext` DeclareMethod Deps Through Owner Map
## Summary
Moved `LinkedSpec::RuleIR::EmitContext` off its hand-built declare-method callback map and onto `LinkedSpec::ActionIR::DeclareMethod::default_deps_for_package(__PACKAGE__)`, so the extracted declare-method owner now defines that dependency contract in one place.

## Changed Files
- Updated: `perl/LinkedSpec/RuleIR/EmitContext.pm`
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `USER_GUIDE.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`

## Technical Details
- Refactored owner dependency resolution:
  - changed `LinkedSpec::RuleIR::EmitContext::_declare_method_deps()` to delegate to `LinkedSpec::ActionIR::DeclareMethod::default_deps_for_package(__PACKAGE__)`,
  - stopped hand-building the local DeclareMethod callback map in `EmitContext`.
- Preserved behavior:
  - `EmitContext` still lowers declare/assign helper expressions through `LinkedSpec::ActionIR::DeclareMethod`,
  - caller `$@` is still preserved on successful declare-method helper delegation,
  - require-only consumers still keep `DeclareMethod.pm` unloaded until the declare-method helper path is actually exercised.
- Updated focused regression coverage:
  - added `emit_context_declare_method_deps_route_through_owner_default_map` to lock that `EmitContext` now asks `DeclareMethod` for the callback map owned by `LinkedSpec::RuleIR::EmitContext`.

## Validation
- Ran:
  - `perl -Iperl -c perl/LinkedSpec/RuleIR/EmitContext.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `prove -v -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
- Result:
  - PASS (`Files=1, Tests=242`)

## 2026-03-14 - Process Slice: Add Live Four-Level Roadmap Status Dashboard
## Summary
Added a canonical four-level roadmap status dashboard so progress can be tracked precisely as `done`, `mostly done`, `in progress`, or `not started`, with the dashboard explicitly marked as a live source that must be updated before commits when a slice materially changes project status.

## Changed Files
- Updated: `ROADMAP.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`

## Technical Details
- Added a canonical live progress dashboard to `ROADMAP.md`:
  - defined the four allowed achievement levels,
  - added explicit current classifications for the roadmap phases and major refactor tracks,
  - recorded remaining focus for each area so "what is left" stays visible.
- Tightened the process contract:
  - documented that the dashboard is the canonical live status source,
  - documented that it must be updated before commits whenever a slice materially changes the status picture,
  - mirrored that workflow rule into the interruption-safe notes documents.

## Validation
- Ran:
  - `git diff --stat -- ROADMAP.md CHANGES.md DEVELOPMENT_NOTES.md MEMORY.md`
  - `git status --short`
- Result:
  - Doc-only process slice reviewed; no code paths changed.

## 2026-03-14 - Backbone Item 3 Slice: Route `EmitContext` MethodLowering Deps Through Owner Map
## Summary
Moved `LinkedSpec::RuleIR::EmitContext` off its hand-built method-lowering callback map and onto `LinkedSpec::ActionIR::MethodLowering::default_deps_for_package(__PACKAGE__)`, so the extracted method-lowering owner now defines that dependency contract in one place.

## Changed Files
- Updated: `perl/LinkedSpec/RuleIR/EmitContext.pm`
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `USER_GUIDE.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`

## Technical Details
- Refactored owner dependency resolution:
  - changed `LinkedSpec::RuleIR::EmitContext::_method_lowering_deps()` to delegate to `LinkedSpec::ActionIR::MethodLowering::default_deps_for_package(__PACKAGE__)`,
  - stopped hand-building the local MethodLowering callback map in `EmitContext`.
- Preserved behavior:
  - `EmitContext` still lowers method/value/assignment/return expressions through `LinkedSpec::ActionIR::MethodLowering`,
  - caller `$@` is still preserved on successful method-lowering helper delegation,
  - require-only consumers still keep `MethodLowering.pm` unloaded until the method-lowering helper path is actually exercised.
- Updated focused regression coverage:
  - added `emit_context_method_lowering_deps_route_through_owner_default_map` to lock that `EmitContext` now asks `MethodLowering` for the callback map owned by `LinkedSpec::RuleIR::EmitContext`.

## Validation
- Ran:
  - `perl -Iperl -c perl/LinkedSpec/RuleIR/EmitContext.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `prove -v -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
- Result:
  - PASS (`Files=1, Tests=241`)

## 2026-03-14 - Backbone Item 3 Slice: Route `EmitContext` ArrayPipeline Deps Through Owner Map
## Summary
Moved `LinkedSpec::RuleIR::EmitContext` off its hand-built array-pipeline callback map and onto `LinkedSpec::ActionIR::ArrayPipeline::default_deps_for_package(__PACKAGE__)`, so the extracted array-pipeline owner now defines that dependency contract in one place.

## Changed Files
- Updated: `perl/LinkedSpec/RuleIR/EmitContext.pm`
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `USER_GUIDE.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`

## Technical Details
- Refactored owner dependency resolution:
  - changed `LinkedSpec::RuleIR::EmitContext::_array_pipeline_deps()` to delegate to `LinkedSpec::ActionIR::ArrayPipeline::default_deps_for_package(__PACKAGE__)`,
  - stopped hand-building the local ArrayPipeline callback map in `EmitContext`.
- Preserved behavior:
  - `EmitContext` still lowers array-pipeline expressions through `LinkedSpec::ActionIR::ArrayPipeline`,
  - caller `$@` is still preserved on successful array-pipeline helper delegation,
  - require-only consumers still keep `ArrayPipeline.pm` unloaded until the array-pipeline helper path is actually exercised.
- Updated focused regression coverage:
  - added `emit_context_array_pipeline_deps_route_through_owner_default_map` to lock that `EmitContext` now asks `ArrayPipeline` for the callback map owned by `LinkedSpec::RuleIR::EmitContext`.

## Validation
- Ran:
  - `perl -Iperl -c perl/LinkedSpec/RuleIR/EmitContext.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `prove -v -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
- Result:
  - PASS (`Files=1, Tests=240`)

## 2026-03-14 - Backbone Item 3 Slice: Route `EmitContext` ValueExpr Deps Through Owner Map
## Summary
Moved `LinkedSpec::RuleIR::EmitContext` off its hand-built value-expression callback map and onto `LinkedSpec::ActionIR::ValueExpr::default_deps_for_package(__PACKAGE__)`, so the extracted value-expression owner now defines that dependency contract in one place.

## Changed Files
- Updated: `perl/LinkedSpec/RuleIR/EmitContext.pm`
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `USER_GUIDE.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`

## Technical Details
- Refactored owner dependency resolution:
  - changed `LinkedSpec::RuleIR::EmitContext::_value_expr_deps()` to delegate to `LinkedSpec::ActionIR::ValueExpr::default_deps_for_package(__PACKAGE__)`,
  - stopped hand-building the local ValueExpr callback map in `EmitContext`.
- Preserved behavior:
  - `EmitContext` still lowers scalar-access and scalaref expressions through `LinkedSpec::ActionIR::ValueExpr`,
  - caller `$@` is still preserved on successful value-expression helper delegation,
  - require-only consumers still keep `ValueExpr.pm` unloaded until the value-expression helper path is actually exercised.
- Updated focused regression coverage:
  - added `emit_context_value_expr_deps_route_through_owner_default_map` to lock that `EmitContext` now asks `ValueExpr` for the callback map owned by `LinkedSpec::RuleIR::EmitContext`.

## Validation
- Ran:
  - `perl -Iperl -c perl/LinkedSpec/RuleIR/EmitContext.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `prove -v -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
- Result:
  - PASS (`Files=1, Tests=239`)

## 2026-03-14 - Backbone Item 3 Slice: Route `EmitContext` FlowExpr Deps Through Owner Map
## Summary
Moved `LinkedSpec::RuleIR::EmitContext` off its hand-built flow-expression callback map and onto `LinkedSpec::ActionIR::FlowExpr::default_deps_for_package(__PACKAGE__)`, so the extracted flow-expression owner now defines that dependency contract in one place.

## Changed Files
- Updated: `perl/LinkedSpec/RuleIR/EmitContext.pm`
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `USER_GUIDE.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`

## Technical Details
- Refactored owner dependency resolution:
  - changed `LinkedSpec::RuleIR::EmitContext::_flow_expr_deps()` to delegate to `LinkedSpec::ActionIR::FlowExpr::default_deps_for_package(__PACKAGE__)`,
  - stopped hand-building the local FlowExpr callback map in `EmitContext`.
- Preserved behavior:
  - `EmitContext` still lowers flow-composite expressions through `LinkedSpec::ActionIR::FlowExpr`,
  - caller `$@` is still preserved on successful flow-expression helper delegation,
  - require-only consumers still keep `FlowExpr.pm` unloaded until the flow-expression helper path is actually exercised.
- Updated focused regression coverage:
  - added `emit_context_flow_expr_deps_route_through_owner_default_map` to lock that `EmitContext` now asks `FlowExpr` for the callback map owned by `LinkedSpec::RuleIR::EmitContext`.

## Validation
- Ran:
  - `perl -Iperl -c perl/LinkedSpec/RuleIR/EmitContext.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `prove -v -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
- Result:
  - PASS (`Files=1, Tests=238`)

## 2026-03-14 - Backbone Item 3 Slice: Route `EmitContext` StatementSplit Deps Through Owner Map
## Summary
Moved `LinkedSpec::RuleIR::EmitContext` off its hand-built statement-split callback map and onto `LinkedSpec::ActionIR::StatementSplit::default_deps_for_package(__PACKAGE__)`, so the extracted statement-split owner now defines that dependency contract in one place.

## Changed Files
- Updated: `perl/LinkedSpec/RuleIR/EmitContext.pm`
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `USER_GUIDE.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`

## Technical Details
- Refactored owner dependency resolution:
  - changed `LinkedSpec::RuleIR::EmitContext::_statement_split_deps()` to delegate to `LinkedSpec::ActionIR::StatementSplit::default_deps_for_package(__PACKAGE__)`,
  - stopped hand-building the local StatementSplit callback map in `EmitContext`.
- Preserved behavior:
  - `EmitContext` still splits action statements through `LinkedSpec::ActionIR::StatementSplit`,
  - caller `$@` is still preserved on successful statement-split helper delegation,
  - require-only consumers still keep `StatementSplit.pm` unloaded until the statement-split helper path is actually exercised.
- Updated focused regression coverage:
  - added `emit_context_statement_split_deps_route_through_owner_default_map` to lock that `EmitContext` now asks `StatementSplit` for the callback map owned by `LinkedSpec::RuleIR::EmitContext`.

## Validation
- Ran:
  - `perl -Iperl -c perl/LinkedSpec/RuleIR/EmitContext.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `prove -v -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
- Result:
  - PASS (`Files=1, Tests=237`)

## 2026-03-14 - Backbone Item 3 Slice: Route `EmitContext` Canonical-Event Deps Through Owner Map
## Summary
Moved `LinkedSpec::RuleIR::EmitContext` off its hand-built canonical-event callback map and onto `LinkedSpec::ActionIR::CanonicalEvents::default_deps_for_package(__PACKAGE__)`, so the extracted canonical-events owner now defines that dependency contract in one place.

## Changed Files
- Updated: `perl/LinkedSpec/RuleIR/EmitContext.pm`
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `USER_GUIDE.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`

## Technical Details
- Refactored owner dependency resolution:
  - changed `LinkedSpec::RuleIR::EmitContext::_canonical_event_deps()` to delegate to `LinkedSpec::ActionIR::CanonicalEvents::default_deps_for_package(__PACKAGE__)`,
  - stopped hand-building the local canonical-event callback map in `EmitContext`.
- Preserved behavior:
  - `EmitContext` still canonicalizes helper-event scans through `LinkedSpec::ActionIR::CanonicalEvents`,
  - caller `$@` is still preserved on successful canonical-event helper delegation,
  - require-only consumers still keep `CanonicalEvents.pm` unloaded until the canonical-event helper path is actually exercised.
- Updated focused regression coverage:
  - added `emit_context_canonical_event_deps_route_through_owner_default_map` to lock that `EmitContext` now asks `CanonicalEvents` for the callback map owned by `LinkedSpec::RuleIR::EmitContext`.

## Validation
- Ran:
  - `perl -Iperl -c perl/LinkedSpec/RuleIR/EmitContext.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `prove -v -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
- Result:
  - PASS (`Files=1, Tests=236`)

## 2026-03-14 - Backbone Item 3 Slice: Route `EmitContext` Diagnostics Deps Through Owner Map
## Summary
Moved `LinkedSpec::RuleIR::EmitContext` off its hand-built Diagnostics callback map and onto `LinkedSpec::ActionIR::Diagnostics::default_deps_for_package(__PACKAGE__)`, so the extracted diagnostics owner now defines that dependency contract in one place.

## Changed Files
- Updated: `perl/LinkedSpec/RuleIR/EmitContext.pm`
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `USER_GUIDE.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`

## Technical Details
- Refactored owner dependency resolution:
  - changed `LinkedSpec::RuleIR::EmitContext::_diagnostics_deps()` to delegate to `LinkedSpec::ActionIR::Diagnostics::default_deps_for_package(__PACKAGE__)`,
  - stopped hand-building the local Diagnostics callback map in `EmitContext`.
- Preserved behavior:
  - `EmitContext` still runs unresolved-helper scans and helper-event collection through `LinkedSpec::ActionIR::Diagnostics`,
  - caller `$@` is still preserved on successful diagnostics helper delegation,
  - require-only consumers still keep `Diagnostics.pm` unloaded until the diagnostics helper path is actually exercised.
- Updated focused regression coverage:
  - added `emit_context_diagnostics_deps_route_through_owner_default_map` to lock that `EmitContext` now asks `Diagnostics` for the callback map owned by `LinkedSpec::RuleIR::EmitContext`.

## Validation
- Ran:
  - `perl -Iperl -c perl/LinkedSpec/RuleIR/EmitContext.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `prove -v -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
- Result:
  - PASS (`Files=1, Tests=235`)

## 2026-03-14 - Backbone Item 3 Slice: Route `EmitContext` ControlFlow Deps Through Owner Map
## Summary
Moved `LinkedSpec::RuleIR::EmitContext` off its hand-built ControlFlow callback map and onto `LinkedSpec::ActionIR::ControlFlow::default_deps_for_package(__PACKAGE__)`, so the extracted control-flow owner now defines that dependency contract in one place.

## Changed Files
- Updated: `perl/LinkedSpec/RuleIR/EmitContext.pm`
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `USER_GUIDE.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`

## Technical Details
- Refactored owner dependency resolution:
  - changed `LinkedSpec::RuleIR::EmitContext::_control_flow_deps()` to delegate to `LinkedSpec::ActionIR::ControlFlow::default_deps_for_package(__PACKAGE__)`,
  - stopped hand-building the local ControlFlow callback map in `EmitContext`.
- Preserved behavior:
  - `EmitContext` still lowers `if(...)`, switch markers, `say(...)`, and `print(...)` through `LinkedSpec::ActionIR::ControlFlow`,
  - caller `$@` is still preserved on successful control-flow helper delegation,
  - require-only consumers still keep `ControlFlow.pm` unloaded until the control-flow helper path is actually exercised.
- Updated focused regression coverage:
  - added `emit_context_control_flow_deps_route_through_owner_default_map` to lock that `EmitContext` now asks `ControlFlow` for the callback map owned by `LinkedSpec::RuleIR::EmitContext`.

## Validation
- Ran:
  - `perl -Iperl -c perl/LinkedSpec/RuleIR/EmitContext.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `prove -v -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
- Result:
  - PASS (`Files=1, Tests=233`)

## 2026-03-14 - Backbone Item 3 Slice: Drop Dead `ActionRewriter` Trim Helper
## Summary
Removed the stale local `LinkedSpec::ActionRewriter::_trim_action_ir_value(...)` helper now that trimming already lives on `LinkedSpec::RuleIR::EmitContext` and the extracted `ActionIR::*` owners.

## Changed Files
- Updated: `perl/LinkedSpec/ActionRewriter.pm`
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `USER_GUIDE.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`

## Technical Details
- Removed dead compatibility scaffolding:
  - deleted the unused local `LinkedSpec::ActionRewriter::_trim_action_ir_value(...)` helper,
  - kept the active trim path on `LinkedSpec::RuleIR::EmitContext::_trim_action_ir_value(...)` and the extracted `ActionIR::*` owners that already consume trim callbacks there.
- Preserved behavior:
  - direct legacy `ActionRewriter` compatibility wrappers still route through `LinkedSpec::RuleIR::EmitContext`,
  - helper rewrite behavior is unchanged because the removed trim helper was no longer referenced on the active compatibility path.
- Updated focused regression coverage:
  - added `action_rewriter_drops_dead_trim_helper` to lock that `ActionRewriter` no longer exposes the dead local trim helper while `EmitContext` still owns the active one.

## Validation
- Ran:
  - `perl -Iperl -c perl/LinkedSpec/ActionRewriter.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `prove -v -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
- Result:
  - PASS (`Files=1, Tests=233`)

## 2026-03-13 - Backbone Item 3 Slice: Route Remaining ControlFlow Compatibility Helpers Through `EmitContext`
## Summary
Finished the ControlFlow compatibility-owner handoff by moving the remaining direct ControlFlow wrappers off `LinkedSpec::ActionRewriter` and onto `LinkedSpec::RuleIR::EmitContext`.

## Changed Files
- Updated: `perl/LinkedSpec/ActionRewriter.pm`
- Updated: `perl/LinkedSpec/RuleIR/EmitContext.pm`
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `USER_GUIDE.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`

## Technical Details
- Refactored compatibility-helper ownership:
  - changed `LinkedSpec::ActionRewriter::_lower_if_flow_statement(...)`,
    `_lower_elseif_flow_statement(...)`,
    `_lower_else_flow_statement(...)`,
    `_lower_endif_flow_statement(...)`,
    `_lower_switch_flow_statement(...)`,
    `_lower_case_flow_statement(...)`,
    `_lower_default_flow_statement(...)`,
    `_lower_endcase_flow_statement(...)`,
    `_lower_endswitch_flow_statement(...)`,
    `_lower_say_statement(...)`, and
    `_lower_print_statement(...)`
    to delegate to `LinkedSpec::RuleIR::EmitContext`,
  - added the matching direct owner entrypoints in `LinkedSpec::RuleIR::EmitContext`,
  - removed the final direct `ControlFlow` package loader and local ControlFlow dep-map builder from `LinkedSpec::ActionRewriter`.
- Preserved behavior:
  - direct legacy callers still get the same `if(...)`, switch-marker, `say(...)`, and `print(...)` lowering outputs,
  - require-only consumers of `ActionRewriter.pm` keep both `EmitContext.pm` and `ControlFlow.pm` unloaded until the control-helper path is actually exercised,
  - normal compile-time emit-context assembly remains on the same extracted owner path.
- Updated focused regression coverage:
  - strengthened `action_rewriter_require_avoids_control_flow_load_until_control_helper` so it now locks the `EmitContext` lazy-load seam too,
  - expanded `action_rewriter_owner_wrappers_preserve_eval_error_state` so the remaining ControlFlow helper family is explicitly locked to the `EmitContext` owner path.

## Validation
- Ran:
  - `perl -Iperl -c perl/LinkedSpec/ActionRewriter.pm`
  - `perl -Iperl -c perl/LinkedSpec/RuleIR/EmitContext.pm`
  - `prove -v -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
- Result:
  - PASS (`Files=1, Tests=232`)

## 2026-03-13 - Backbone Item 3 Slice: Route Remaining DeclareMethod Compatibility Helpers Through `EmitContext`
## Summary
Finished the DeclareMethod compatibility-owner handoff by moving the remaining direct DeclareMethod wrappers off `LinkedSpec::ActionRewriter` and onto `LinkedSpec::RuleIR::EmitContext`.

## Changed Files
- Updated: `perl/LinkedSpec/ActionRewriter.pm`
- Updated: `perl/LinkedSpec/RuleIR/EmitContext.pm`
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `USER_GUIDE.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`

## Technical Details
- Refactored compatibility-helper ownership:
  - changed `LinkedSpec::ActionRewriter::_split_declare_symbol_names(...)`,
    `_parse_declare_binding_entry(...)`,
    `_lower_declare_value_expr(...)`,
    `_lower_declare_initializer_expr(...)`,
    `_extract_declare_statement_from_method_expr(...)`,
    `_lower_declare_method_statement(...)`, and
    `_lower_assign_method_statement(...)`
    to delegate to `LinkedSpec::RuleIR::EmitContext`,
  - added the missing direct owner entrypoints in `LinkedSpec::RuleIR::EmitContext`,
  - removed the final direct `DeclareMethod` package loader and local DeclareMethod dep-map builder from `LinkedSpec::ActionRewriter`.
- Preserved behavior:
  - direct legacy callers still get the same declare-symbol, binding, initializer, declare-method, and assign-method lowering outputs,
  - require-only consumers of `ActionRewriter.pm` keep both `EmitContext.pm` and `DeclareMethod.pm` unloaded until the declare-helper path is actually exercised,
  - normal compile-time emit-context assembly remains on the same extracted owner path.
- Updated focused regression coverage:
  - strengthened `action_rewriter_require_avoids_declare_method_load_until_declare_helper` so it now locks the `EmitContext` lazy-load seam too,
  - expanded `action_rewriter_owner_wrappers_preserve_eval_error_state` so the remaining DeclareMethod helper family is explicitly locked to the `EmitContext` owner path.

## Validation
- Ran:
  - `perl -Iperl -c perl/LinkedSpec/ActionRewriter.pm`
  - `perl -Iperl -c perl/LinkedSpec/RuleIR/EmitContext.pm`
  - `prove -v -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=232`)

## 2026-03-13 - Backbone Item 3 Slice: Route Remaining MethodLowering Compatibility Helpers Through `EmitContext`
## Summary
Finished the MethodLowering compatibility-owner handoff by moving the remaining broad MethodLowering wrappers off `LinkedSpec::ActionRewriter` and onto `LinkedSpec::RuleIR::EmitContext`.

## Changed Files
- Updated: `perl/LinkedSpec/ActionRewriter.pm`
- Updated: `perl/LinkedSpec/RuleIR/EmitContext.pm`
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `USER_GUIDE.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`

## Technical Details
- Refactored compatibility-helper ownership:
  - changed `LinkedSpec::ActionRewriter::_lower_return_general_statement(...)`,
    `_lower_return_imatch_statement(...)`,
    `_lower_push_value_statement(...)`,
    `_lower_regex_subst_statement(...)`,
    `_lower_return_undef_statement(...)`, and
    `_lower_return_array_statement(...)`
    to delegate to `LinkedSpec::RuleIR::EmitContext`,
  - added the matching owner entrypoints in `LinkedSpec::RuleIR::EmitContext`,
  - removed the final direct `MethodLowering` package loader and local MethodLowering dep-map builder from `LinkedSpec::ActionRewriter`.
- Preserved behavior:
  - direct legacy callers still get the same return/push/regex MethodLowering outputs,
  - require-only consumers of `ActionRewriter.pm` keep both `EmitContext.pm` and `MethodLowering.pm` unloaded until the method-helper path is actually exercised,
  - normal compile-time emit-context assembly remains on the same extracted owner path.
- Updated focused regression coverage:
  - strengthened `action_rewriter_require_avoids_method_lowering_load_until_method_helper` so it now exercises the migrated broad MethodLowering wrapper path through `EmitContext`,
  - expanded `action_rewriter_owner_wrappers_preserve_eval_error_state` so the remaining MethodLowering helper family is explicitly locked to the `EmitContext` owner path.

## Validation
- Ran:
  - `perl -Iperl -c perl/LinkedSpec/ActionRewriter.pm`
  - `perl -Iperl -c perl/LinkedSpec/RuleIR/EmitContext.pm`
  - `prove -v -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=232`)

## 2026-03-13 - Backbone Item 3 Slice: Route MethodLowering Compatibility Helpers Through `EmitContext`
## Summary
Reduced the `LinkedSpec::ActionRewriter` compatibility surface again by moving a focused MethodLowering helper subset onto `LinkedSpec::RuleIR::EmitContext`, which already owns that lowering support for the live compile path.

## Changed Files
- Updated: `perl/LinkedSpec/ActionRewriter.pm`
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `USER_GUIDE.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`

## Technical Details
- Refactored compatibility-helper ownership:
  - changed `LinkedSpec::ActionRewriter::_declare_alias_to_type(...)`,
    `_lower_typed_declare_statement(...)`,
    `_normalize_method_tag_expr(...)`,
    `_lower_method_value_expr(...)`, and
    `_lower_assign_statement(...)`
    to delegate to `LinkedSpec::RuleIR::EmitContext`,
  - kept the broader MethodLowering statement helpers (`_lower_return_general_statement(...)`, `_lower_return_imatch_statement(...)`, `_lower_push_value_statement(...)`, `_lower_regex_subst_statement(...)`, `_lower_return_undef_statement(...)`, `_lower_return_array_statement(...)`) on `ActionRewriter` for now,
  - kept downstream helper behavior stable because `EmitContext` already owns the same MethodLowering helper logic for the active rewrite path.
- Preserved behavior:
  - direct legacy callers still get the same alias/typed-declare/tag/method-value/assign lowering outputs,
  - require-only consumers of `ActionRewriter.pm` keep both `EmitContext.pm` and `MethodLowering.pm` unloaded until the method-helper path is actually exercised,
  - extracted owner dep builders continue to lazy-load callback owners on demand.
- Updated focused regression coverage:
  - strengthened `action_rewriter_require_avoids_method_lowering_load_until_method_helper` so it now locks the `EmitContext` lazy-load seam too,
  - expanded `action_rewriter_owner_wrappers_preserve_eval_error_state` so the migrated MethodLowering helper subset is explicitly locked to the `EmitContext` owner path.

## Validation
- Ran:
  - `perl -Iperl -c perl/LinkedSpec/ActionRewriter.pm`
  - `prove -v -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=232`)

## 2026-03-13 - Backbone Item 3 Slice: Route ArrayPipeline Compatibility Helpers Through `EmitContext`
## Summary
Reduced the `LinkedSpec::ActionRewriter` compatibility surface again by moving its remaining direct ArrayPipeline helper wrappers onto `LinkedSpec::RuleIR::EmitContext`, which already owns that array-planning/lowering support for the live compile path.

## Changed Files
- Updated: `perl/LinkedSpec/ActionRewriter.pm`
- Updated: `perl/LinkedSpec/RuleIR/EmitContext.pm`
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `USER_GUIDE.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`

## Technical Details
- Refactored compatibility-helper ownership:
  - changed `LinkedSpec::ActionRewriter::_build_array_pipeline_plan_from_expr(...)` and `_lower_array_pipeline_expr(...)` to delegate to `LinkedSpec::RuleIR::EmitContext`,
  - added the missing direct owner entrypoint `LinkedSpec::RuleIR::EmitContext::_lower_array_pipeline_expr(...)`,
  - removed the now-dead direct `ActionRewriter` ArrayPipeline package loader and local ArrayPipeline dep-map builder,
  - kept downstream helper behavior stable because `EmitContext` already owns the same ArrayPipeline helper logic for the active rewrite path.
- Preserved behavior:
  - direct legacy callers still get the same array-pipeline planning and lowering outputs,
  - require-only consumers of `ActionRewriter.pm` keep both `EmitContext.pm` and `ArrayPipeline.pm` unloaded until the array-helper path is actually exercised,
  - extracted owner dep builders continue to lazy-load callback owners on demand.
- Updated focused regression coverage:
  - strengthened `action_rewriter_require_avoids_array_pipeline_load_until_array_helper` so it now locks the `EmitContext` lazy-load seam too,
  - expanded `action_rewriter_owner_wrappers_preserve_eval_error_state` so the remaining ActionRewriter array-pipeline helpers are explicitly locked to the `EmitContext` owner path.

## Validation
- Ran:
  - `perl -Iperl -c perl/LinkedSpec/ActionRewriter.pm`
  - `prove -v -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=232`)

## 2026-03-13 - Backbone Item 3 Slice: Route FlowExpr Compatibility Helper Through `EmitContext`
## Summary
Reduced the `LinkedSpec::ActionRewriter` compatibility surface again by moving its remaining direct FlowExpr helper wrapper onto `LinkedSpec::RuleIR::EmitContext`, which already owns that flow-lowering support for the live compile path.

## Changed Files
- Updated: `perl/LinkedSpec/ActionRewriter.pm`
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `USER_GUIDE.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`

## Technical Details
- Refactored compatibility-helper ownership:
  - changed `LinkedSpec::ActionRewriter::_lower_flow_composite_expr(...)` to delegate to `LinkedSpec::RuleIR::EmitContext`,
  - removed the now-dead direct `ActionRewriter` FlowExpr package loader and local FlowExpr dep-map builder,
  - kept downstream helper behavior stable because `EmitContext` already owns the same FlowExpr helper logic for the active rewrite path.
- Preserved behavior:
  - direct legacy callers still get the same boolean/comparison flow lowering output,
  - require-only consumers of `ActionRewriter.pm` keep both `EmitContext.pm` and `FlowExpr.pm` unloaded until the flow-helper path is actually exercised,
  - extracted owner dep builders continue to lazy-load callback owners on demand.
- Updated focused regression coverage:
  - strengthened `action_rewriter_require_avoids_flow_expr_load_until_flow_helper` so it now locks the `EmitContext` lazy-load seam too,
  - updated `action_rewriter_owner_wrappers_preserve_eval_error_state` so the remaining ActionRewriter flow helper is explicitly locked to the `EmitContext` owner path.

## Validation
- Ran:
  - `perl -Iperl -c perl/LinkedSpec/ActionRewriter.pm`
  - `prove -v -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=232`)

## 2026-03-13 - Backbone Item 3 Slice: Route ValueExpr Compatibility Helpers Through `EmitContext`
## Summary
Reduced the `LinkedSpec::ActionRewriter` compatibility surface again by moving its remaining direct ValueExpr helper wrappers onto `LinkedSpec::RuleIR::EmitContext`, which already owns that value-lowering support for the live compile path.

## Changed Files
- Updated: `perl/LinkedSpec/ActionRewriter.pm`
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `USER_GUIDE.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`

## Technical Details
- Refactored compatibility-helper ownership:
  - changed `LinkedSpec::ActionRewriter::_extract_scalar_symbol_name(...)`,
    `_extract_array_symbol_name(...)`,
    `_extract_hash_symbol_name(...)`,
    `_lower_scalar_access_key_expr(...)`,
    `_lower_scalaref_value_expr(...)`,
    `_infer_scalar_container_kind(...)`,
    `_lower_assignment_source_expr(...)`, and
    `_strip_literal_delimiters(...)`
    to delegate to `LinkedSpec::RuleIR::EmitContext`,
  - removed the now-dead direct `ActionRewriter` ValueExpr package loader and local ValueExpr dep-map builder,
  - kept downstream helper behavior stable because `EmitContext` already owns the same ValueExpr helper logic for the active rewrite path.
- Preserved behavior:
  - direct legacy callers still get the same scalar/hash/array symbol extraction and value-lowering outputs,
  - require-only consumers of `ActionRewriter.pm` keep both `EmitContext.pm` and `ValueExpr.pm` unloaded until the value-helper path is actually exercised,
  - extracted owner dep builders continue to lazy-load callback owners on demand.
- Updated focused regression coverage:
  - strengthened `action_rewriter_require_avoids_value_expr_load_until_value_helper` so it now locks the `EmitContext` lazy-load seam too,
  - expanded `action_rewriter_owner_wrappers_preserve_eval_error_state` so the full ValueExpr helper family is explicitly locked to the `EmitContext` owner path.

## Validation
- Ran:
  - `perl -Iperl -c perl/LinkedSpec/ActionRewriter.pm`
  - `prove -v -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=232`)

## 2026-03-13 - Backbone Item 3 Slice: Route MethodExpr Compatibility Helpers Through `EmitContext`
## Summary
Reduced the `LinkedSpec::ActionRewriter` compatibility surface again by moving its remaining direct MethodExpr helper wrappers onto `LinkedSpec::RuleIR::EmitContext`, which already owns that parsing support for the live compile path.

## Changed Files
- Updated: `perl/LinkedSpec/ActionRewriter.pm`
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `USER_GUIDE.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`

## Technical Details
- Refactored compatibility-helper ownership:
  - changed `LinkedSpec::ActionRewriter::_parse_method_function_expr(...)`,
    `_is_bare_method_scope_token(...)`,
    `_normalize_method_args_with_optional_scope(...)`, and
    `_split_top_level_csv(...)`
    to delegate to `LinkedSpec::RuleIR::EmitContext`,
  - removed the now-dead direct `ActionRewriter` MethodExpr package loader,
  - kept downstream helper families behavior-stable because `EmitContext` already owns the same MethodExpr helper logic.
- Preserved behavior:
  - direct legacy callers still get the same parsed method-expression structures and normalization behavior,
  - require-only consumers of `ActionRewriter.pm` keep both `EmitContext.pm` and `MethodExpr.pm` unloaded until the method-expression helper path is actually exercised,
  - extracted `ActionIR::*` owner dep builders continue to lazy-load callback owners on demand.
- Updated focused regression coverage:
  - strengthened `action_rewriter_require_avoids_method_expr_load_until_parse_helper` so it now locks the `EmitContext` lazy-load seam as well,
  - expanded `action_rewriter_owner_wrappers_preserve_eval_error_state` so the full MethodExpr helper family is explicitly locked to the `EmitContext` owner path.

## Validation
- Ran:
  - `perl -Iperl -c perl/LinkedSpec/ActionRewriter.pm`
  - `prove -v -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=232`)

## 2026-03-13 - Backbone Item 3 Slice: Route Remaining Generic Rewrite Helpers Through `EmitContext`
## Summary
Completed another compatibility-surface cleanup in `LinkedSpec::*` by moving the remaining generic split/canonical/rewrite helper wrappers in `LinkedSpec::ActionRewriter` onto the extracted `LinkedSpec::RuleIR::EmitContext` owner.

## Changed Files
- Updated: `perl/LinkedSpec/ActionRewriter.pm`
- Updated: `perl/LinkedSpec/RuleIR/EmitContext.pm`
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `USER_GUIDE.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`

## Technical Details
- Refactored compatibility-helper ownership:
  - added `LinkedSpec::RuleIR::EmitContext` owner entrypoints for `_canonicalize_helper_action_ir_event(...)` and `_lower_action_code_from_canonical_ir(...)`,
  - changed `LinkedSpec::ActionRewriter::_canonicalize_helper_action_ir_event(...)`,
    `_split_action_ir_statements(...)`,
    `_lower_action_code_from_canonical_ir(...)`,
    `_accumulate_action_rewrite_diagnostics(...)`, and
    `_build_action_rewrite_rules(...)`
    to delegate to `EmitContext`,
  - removed the now-dead direct canonical-events / statement-split / diagnostics / rewrite-pipeline dep-builder scaffolding from `ActionRewriter`.
- Preserved behavior:
  - direct legacy callers still receive the same split/canonical/rewrite outputs,
  - normal compile-time helper rewriting remains on `EmitContext` plus extracted `ActionIR::*` owners,
  - `ActionRewriter` keeps only the lower-level direct lowering helpers and compatibility wrapper surface that still need to stay there.
- Updated focused regression coverage:
  - expanded `action_rewriter_owner_wrappers_preserve_eval_error_state` so the remaining generic split/canonical/rewrite helpers are explicitly locked to the `EmitContext` owner path,
  - revalidated the full phase-0 suite and local CI gate against the new owner layout.

## Validation
- Ran:
  - `perl -Iperl -c perl/LinkedSpec/ActionRewriter.pm`
  - `perl -Iperl -c perl/LinkedSpec/RuleIR/EmitContext.pm`
  - `prove -v -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=232`)

## 2026-03-13 - Backbone Item 3 Slice: Route `ActionRewriter` Generic Rewrite Wrappers Through `EmitContext`
## Summary
Reduced another compatibility-only `ActionRewriter` surface by moving its remaining generic rewrite-orchestration wrappers onto the extracted `LinkedSpec::RuleIR::EmitContext` owner that already backs the live compile-path rewrite flow.

## Changed Files
- Updated: `perl/LinkedSpec/ActionRewriter.pm`
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `USER_GUIDE.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`

## Technical Details
- Refactored compatibility-helper ownership:
  - changed `LinkedSpec::ActionRewriter::_build_action_lowering_contracts(...)`,
    `_scan_contract_ir_events(...)`,
    `_find_unresolved_action_helpers(...)`,
    `_collect_action_helper_ir_nodes(...)`,
    `_build_canonical_action_ir_events(...)`, and
    `_rewrite_action_code_with_diagnostics(...)`
    to lazy-load `LinkedSpec::RuleIR::EmitContext` and delegate to that extracted owner,
  - removed the now-dead local `ActionRewriter` scaffolding for direct scanner/contracts dep-map assembly on that generic rewrite path,
  - kept lower-level direct lowering helpers in `ActionRewriter` unchanged, so legacy helper-family entrypoints still behave the same.
- Preserved behavior:
  - rewrite output and canonical diagnostics are unchanged,
  - direct legacy callers of `LinkedSpec::ActionRewriter` still get the same helper/rewrite results,
  - the active compile-time helper rewrite path remains centered on `RuleIR::EmitContext` plus extracted `ActionIR::*` owners.
- Updated focused regression coverage:
  - expanded `action_rewriter_owner_wrappers_preserve_eval_error_state` so the generic rewrite wrappers are explicitly locked to the `EmitContext` owner,
  - kept the broader rewrite/lazy-load regression suite green under the new owner path.

## Validation
- Ran:
  - `perl -Iperl -c perl/LinkedSpec/ActionRewriter.pm`
  - `prove -v -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=232`)

## 2026-03-13 - Phase 1A Slice: Route Facade Rewrite Shim Through `EmitContext`
## Summary
Reduced another compatibility-only `ActionRewriter` dependency by moving the public `LinkedSpec::call_spec_handler_subst(...)` façade entrypoint onto the `LinkedSpec::RuleIR::EmitContext` owner that already holds the extracted rewrite callback bundle.

## Changed Files
- Updated: `perl/LinkedSpec.pm`
- Updated: `perl/LinkedSpec/ActionRewriter.pm`
- Updated: `perl/LinkedSpec/RuleIR/EmitContext.pm`
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `USER_GUIDE.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`

## Technical Details
- Refactored compatibility-helper ownership:
  - added `LinkedSpec::RuleIR::EmitContext::rewrite_action_code_for_compat(...)` as the extracted owner entrypoint for focused helper-rewrite inspection,
  - changed `LinkedSpec::call_spec_handler_subst(...)` to lazy-load `RuleIR::EmitContext` instead of `ActionRewriter`,
  - changed `LinkedSpec::ActionRewriter::call_spec_handler_subst(...)` into a backward-compatible wrapper around the same `EmitContext` owner.
- Preserved behavior:
  - focused helper rewrites still return the same rewritten code strings,
  - direct `LinkedSpec::ActionRewriter` helper/lowering wrappers remain available for legacy tests and callers,
  - normal `Get(...)`/`compile_spec_entry(...)` compilation remains on the extracted `ActionIR::*` + `EmitContext` owner path.
- Updated focused regression coverage:
  - strengthened `linkedspec_require_avoids_action_rewriter_load_until_compat_helper` so the façade shim now keeps `ActionRewriter` unloaded and lazy-loads `EmitContext` instead,
  - updated `linkedspec_public_facade_wrappers_preserve_eval_error_state` to lock the new `EmitContext` compatibility-owner seam,
  - updated `action_rewriter_owner_wrappers_preserve_eval_error_state` so the legacy `ActionRewriter::call_spec_handler_subst(...)` wrapper is explicitly locked to the new `EmitContext` owner.

## Validation
- Ran:
  - `perl -Iperl -c perl/LinkedSpec.pm`
  - `perl -Iperl -c perl/LinkedSpec/ActionRewriter.pm`
  - `perl -Iperl -c perl/LinkedSpec/RuleIR/EmitContext.pm`
  - `prove -v -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=232`)

## 2026-03-13 - Backbone Item 3 Slice: Move EmitContext Rewrite Callback Bundle Off `ActionRewriter`
## Summary
Stabilized the remaining live compile-path `ActionRewriter` coupling inside `LinkedSpec::*` by making `LinkedSpec::RuleIR::EmitContext` assemble its rewrite callback bundle from the extracted `ActionIR::*` owners directly.

## Changed Files
- Updated: `perl/LinkedSpec/RuleIR/EmitContext.pm`
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `USER_GUIDE.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`

## Technical Details
- Refactored emit-context rewrite dependency ownership:
  - replaced `LinkedSpec::ActionIR::RewritePipeline::default_deps_for_package('LinkedSpec::ActionRewriter')` with an `EmitContext`-owned callback bundle,
  - added local owner-direct dep builders for `Contracts`, `Diagnostics`, `CanonicalEvents`, `Scanner`, `StatementSplit`, `FlowExpr`, `ValueExpr`, `ArrayPipeline`, `ControlFlow`, `MethodLowering`, and `DeclareMethod`,
  - kept the active rewrite path on extracted `ActionIR::*` owners while removing the last indirect compile-time `ActionRewriter` load from normal emit-context builds.
- Preserved behavior:
  - `build_rule_ir_emit_context(...)` still returns the same rewritten ACODE/BCODE/lifecycle payloads and action-rewriter metadata,
  - `LinkedSpec::Get(...)` still returns parser coderefs through the same compile path,
  - `LinkedSpec::call_spec_handler_subst(...)` remains the compatibility-only entrypoint that lazy-loads `ActionRewriter` on demand.
- Updated focused regression coverage:
  - strengthened `linkedspec_require_avoids_compile_pipeline_load_until_get` so the normal compile path now keeps `ActionRewriter` unloaded,
  - strengthened `emit_context_require_avoids_action_rewriter_load_until_emit_context_build` so emit-context builds now keep `ActionRewriter` unloaded too,
  - added `emit_context_avoids_action_rewriter_owner_bundle` to trap the removed `ActionRewriter` owner callbacks directly.

## Validation
- Ran:
  - `perl -Iperl -c perl/LinkedSpec/RuleIR/EmitContext.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=232`)

## 2026-03-13 - Phase 1A Slice: Route SpecEntry Emit-Context Build Through Owner Module
## Summary
Stabilized another no-behavior-change `LinkedSpec::*` seam by removing the dead `RuleIR` emit-context delegate layer and making `LinkedSpec::SpecEntry` call the `LinkedSpec::RuleIR::EmitContext` owner directly.

## Changed Files
- Updated: `perl/LinkedSpec/SpecEntry.pm`
- Updated: `perl/LinkedSpec/RuleIR.pm`
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `USER_GUIDE.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`

## Technical Details
- Refactored emit-context ownership:
  - added `LinkedSpec::SpecEntry::_require_emit_context_pkg(...)`,
  - changed `compile_spec_entry(...)` to call `LinkedSpec::RuleIR::EmitContext::build_rule_ir_emit_context(...)` directly,
  - removed the now-dead `LinkedSpec::RuleIR::_require_emit_context_pkg(...)`, `_normalize_rule_code_chunks(...)`, and `_build_rule_ir_emit_context(...)` delegate block.
- Preserved behavior:
  - `compile_spec_entry(...)` still returns the same compiled rule info and action-rewriter metadata payload,
  - `RuleIR` still owns collection/planning/validation, while `EmitContext` stays the sole owner of emit-context assembly,
  - `SpecEntry` now lazy-loads `EmitContext` on demand at the actual compile stage instead of depending on a compatibility hop through `RuleIR`.
- Updated focused regression coverage:
  - strengthened `spec_entry_require_avoids_ruleir_load_until_compile_spec_entry` to lock lazy `EmitContext` loading too,
  - added `spec_entry_avoids_removed_ruleir_emit_context_delegates`,
  - removed the obsolete `RuleIR`-delegate expectations from `extracted_wrapper_helpers_preserve_eval_error_state`.

## Validation
- Ran:
  - `perl -Iperl -c perl/LinkedSpec/RuleIR.pm`
  - `perl -Iperl -c perl/LinkedSpec/SpecEntry.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=231`)

## 2026-03-13 - Backbone Item 3 Slice: Route EmitContext Rewrite/Diagnostics Through Extracted Owners
## Summary
Stabilized another no-behavior-change `LinkedSpec::*` seam by making `LinkedSpec::RuleIR::EmitContext` call the extracted rewrite-pipeline and diagnostics owners directly instead of routing that orchestration through thin `LinkedSpec::ActionRewriter` compatibility wrappers.

## Changed Files
- Updated: `perl/LinkedSpec/RuleIR/EmitContext.pm`
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `USER_GUIDE.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`

## Technical Details
- Refactored emit-context rewrite/diagnostic ownership:
  - replaced the direct `LinkedSpec::ActionRewriter` helper calls in `LinkedSpec::RuleIR::EmitContext` with owner-direct calls into `LinkedSpec::ActionIR::RewritePipeline` and `LinkedSpec::ActionIR::Diagnostics`,
  - added local package-loading helpers plus `_rewrite_pipeline_deps(...)` so `EmitContext` resolves rewrite-pipeline callback maps from the extracted owner path instead of through the compatibility wrapper layer,
  - localized `_trim_action_ir_value(...)` inside `EmitContext`, since that helper is only whitespace trimming and does not need to stay behind a rewrite-owner wrapper.
- Preserved behavior:
  - `build_rule_ir_emit_context(...)` still produces the same rewritten ACODE/BCODE/lifecycle payloads and action-rewriter metadata,
  - `LinkedSpec::ActionRewriter` is still lazy-loaded when the rewrite-pipeline dep map resolves lowering callbacks, but `EmitContext` no longer depends on the thin `ActionRewriter` wrapper methods themselves,
  - caller `$@` preservation remains intact across successful `EmitContext` rewrite-helper delegation.
- Updated focused regression coverage:
  - strengthened `emit_context_require_avoids_action_rewriter_load_until_emit_context_build` to lock lazy `RewritePipeline` loading alongside the still-indirect lazy `ActionRewriter` load,
  - updated `extracted_wrapper_helpers_preserve_eval_error_state` so the `EmitContext` rewrite helper is regression-locked to `LinkedSpec::ActionIR::RewritePipeline` instead of the compatibility wrapper layer.

## Validation
- Ran:
  - `perl -Iperl -c perl/LinkedSpec/RuleIR/EmitContext.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=231`)

## 2026-03-13 - Backbone Item 3 Slice: Lazy-Load ActionIR Callback Owners Inside Dep Builders
## Summary
Stabilized another no-behavior-change `LinkedSpec::*` seam by making the remaining extracted `ActionIR` dep-builder owners lazy-load their callback-owner packages on demand, instead of assuming those owner packages were already loaded by the caller.

## Changed Files
- Updated: `perl/LinkedSpec/ActionIR/ControlFlow.pm`
- Updated: `perl/LinkedSpec/ActionIR/Diagnostics.pm`
- Updated: `perl/LinkedSpec/ActionIR/RewritePipeline.pm`
- Updated: `perl/LinkedSpec/ActionIR/Contracts.pm`
- Updated: `perl/LinkedSpec/ActionIR/ValueExpr.pm`
- Updated: `perl/LinkedSpec/ActionIR/ArrayPipeline.pm`
- Updated: `perl/LinkedSpec/ActionIR/FlowExpr.pm`
- Updated: `perl/LinkedSpec/ActionIR/MethodLowering.pm`
- Updated: `perl/LinkedSpec/ActionIR/StatementSplit.pm`
- Updated: `perl/LinkedSpec/ActionIR/CanonicalEvents.pm`
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `USER_GUIDE.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`

## Technical Details
- Refactored extracted ActionIR dep-builder owner loading:
  - added local `_require_pkg(...)` helpers to the remaining dep-builder owners that still lacked one,
  - updated `_require_pkg_cb(...)` in `ControlFlow`, `Diagnostics`, `RewritePipeline`, `Contracts`, `ValueExpr`, `ArrayPipeline`, `FlowExpr`, and `MethodLowering` to load callback-owner packages before resolving `can(...)`,
  - updated the existing `_require_pkg_cb(...)` helpers in `StatementSplit` and `CanonicalEvents` to do the same before symbol-table callback lookup,
  - kept the returned callback maps unchanged while removing the hidden assumption that callback-owner packages were already present in memory.
- Preserved behavior:
  - extracted ActionIR dep builders still return the same dependency keys and callback coderefs,
  - no lowering, scanning, canonical-event, or diagnostics behavior changed,
  - missing callback-owner packages still fail through the existing require/die surfaces.
- Updated focused regression coverage:
  - added `actionir_dep_builders_lazy_load_callback_owner_packages`.

## Validation
- Ran:
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/ControlFlow.pm`
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/Diagnostics.pm`
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/RewritePipeline.pm`
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/Contracts.pm`
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/ValueExpr.pm`
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/ArrayPipeline.pm`
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/FlowExpr.pm`
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/MethodLowering.pm`
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/StatementSplit.pm`
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/CanonicalEvents.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=231`)

## 2026-03-13 - Backbone Item 3 Slice: Move MethodExpr Dep Loading into DeclareMethod/Scanner Owners
## Summary
Stabilized another no-behavior-change `LinkedSpec::*` seam by making the `DeclareMethod` and `Scanner` owner dep-builders lazy-load `MethodExpr` themselves, so `ActionRewriter` no longer has to prefetch `MethodExpr` just to assemble those callback maps.

## Changed Files
- Updated: `perl/LinkedSpec/ActionRewriter.pm`
- Updated: `perl/LinkedSpec/ActionIR/DeclareMethod.pm`
- Updated: `perl/LinkedSpec/ActionIR/Scanner.pm`
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `USER_GUIDE.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`

## Technical Details
- Refactored ActionIR dep-loading ownership:
  - removed the redundant `MethodExpr` prefetch from `LinkedSpec::ActionRewriter::_declare_method_deps(...)`,
  - removed the redundant `MethodExpr` prefetch from `LinkedSpec::ActionRewriter::_scan_contract_ir_event_deps(...)`,
  - added package-level lazy callback-owner loading in `LinkedSpec::ActionIR::DeclareMethod::_require_pkg_cb(...)`,
  - added the same lazy callback-owner loading in `LinkedSpec::ActionIR::Scanner::_require_pkg_cb(...)`.
- Preserved behavior:
  - declare-method lowering still parses helper expressions through the same `MethodExpr` owner,
  - scanner dep resolution still exposes the same `parse_method_function_expr(...)` and `normalize_method_args_with_optional_scope(...)` callbacks,
  - `ActionRewriter` direct method-expression helper wrappers are unchanged and still lazy-load `MethodExpr` on demand.
- Updated focused regression coverage:
  - added `action_rewriter_dep_builders_avoid_method_expr_prefetch`.

## Validation
- Ran:
  - `perl -Iperl -c perl/LinkedSpec/ActionRewriter.pm`
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/DeclareMethod.pm`
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/Scanner.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=230`)

## 2026-03-13 - Backbone Item 3 Slice: Preserve Caller `$@` Across ActionIR Dep-Builder Callback Lookup
## Summary
Stabilized another no-behavior-change `LinkedSpec::*` seam by making the remaining extracted `ActionIR` dep-builder owners preserve caller `$@` across successful callback-map lookup and construction.

## Changed Files
- Updated: `perl/LinkedSpec/ActionIR/Diagnostics.pm`
- Updated: `perl/LinkedSpec/ActionIR/Contracts.pm`
- Updated: `perl/LinkedSpec/ActionIR/DeclareMethod.pm`
- Updated: `perl/LinkedSpec/ActionIR/ControlFlow.pm`
- Updated: `perl/LinkedSpec/ActionIR/ArrayPipeline.pm`
- Updated: `perl/LinkedSpec/ActionIR/RewritePipeline.pm`
- Updated: `perl/LinkedSpec/ActionIR/FlowExpr.pm`
- Updated: `perl/LinkedSpec/ActionIR/MethodLowering.pm`
- Updated: `perl/LinkedSpec/ActionIR/ValueExpr.pm`
- Updated: `perl/LinkedSpec/ActionIR/Scanner.pm`
- Updated: `perl/LinkedSpec/ActionIR/StatementSplit.pm`
- Updated: `perl/LinkedSpec/ActionIR/CanonicalEvents.pm`
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `USER_GUIDE.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`

## Technical Details
- Refactored extracted ActionIR dep-builder owner behavior:
  - added `::_call_preserving_err(...)` to the remaining dep-builder-only ActionIR owners that still lacked it,
  - routed `_require_pkg_cb(...)` and `default_deps_for_package(...)` through that helper across `Diagnostics`, `Contracts`, `DeclareMethod`, `ControlFlow`, `ArrayPipeline`, `RewritePipeline`, `FlowExpr`, `MethodLowering`, and `ValueExpr`,
  - routed the same dep-builder surfaces through the existing helper in `Scanner`, `StatementSplit`, and `CanonicalEvents`,
  - preserved the same callback-map payloads while restoring caller `$@` after successful dep lookup/build paths.
- Preserved behavior:
  - ActionIR owner modules still resolve the same callback names into the same dep maps,
  - no lowering, scanning, canonical-event, or diagnostics behavior changes,
  - exception behavior is unchanged when required owner callbacks are missing.
- Updated focused regression coverage:
  - added `actionir_dep_builders_preserve_eval_error_state`.

## Validation
- Ran:
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/Diagnostics.pm`
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/Contracts.pm`
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/DeclareMethod.pm`
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/ControlFlow.pm`
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/ArrayPipeline.pm`
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/RewritePipeline.pm`
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/FlowExpr.pm`
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/MethodLowering.pm`
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/ValueExpr.pm`
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/Scanner.pm`
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/StatementSplit.pm`
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/CanonicalEvents.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=229`)

## 2026-03-13 - Phase 1A Slice: Preserve Caller `$@` Across `ParserFactory` Lazy Owner Lookup
## Summary
Stabilized another no-behavior-change `LinkedSpec::*` seam by making `LinkedSpec::ParserFactory` preserve caller `$@` across successful lazy owner lookup and public parser-factory orchestration.

## Changed Files
- Updated: `perl/LinkedSpec/ParserFactory.pm`
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `USER_GUIDE.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`

## Technical Details
- Refactored `ParserFactory` owner lookup/orchestration behavior:
  - added `LinkedSpec::ParserFactory::_call_preserving_err(...)`,
  - routed `_require_pkg(...)`, `_require_pkg_cb(...)`, `_require_pkg_value(...)`, and `run_get_parser(...)` through that helper,
  - preserved existing lazy package callback/value resolution and parser-factory flow while restoring caller `$@` after successful delegation.
- Preserved behavior:
  - `ParserFactory` still lazy-loads owner packages on demand,
  - public parser-factory orchestration still traces, resolves, loads, and compiles through the same dependency contract,
  - exception behavior is unchanged when package load, callback lookup, or parser compilation dies.
- Updated focused regression coverage:
  - added `parser_factory_wrappers_preserve_eval_error_state`.

## Validation
- Ran:
  - `perl -Iperl -c perl/LinkedSpec/ParserFactory.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=228`)

## 2026-03-13 - Phase 1A Slice: Preserve Caller `$@` Across `PluginBridge` Legacy Runtime Delegation
## Summary
Stabilized another no-behavior-change `LinkedSpec::*` helper seam by making `LinkedSpec::PluginBridge` preserve caller `$@` across successful legacy runtime load and exec delegation.

## Changed Files
- Updated: `perl/LinkedSpec/PluginBridge.pm`
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `USER_GUIDE.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`

## Technical Details
- Refactored `PluginBridge` owner delegation behavior:
  - added `LinkedSpec::PluginBridge::_call_preserving_err(...)`,
  - routed `_load_legacy_plugin_runtime(...)`, `_exec_legacy_plugin(...)`, and `_dispatch_plugin_name(...)` through that helper,
  - preserved normalized plugin-name dispatch payloads while restoring caller `$@`
    after successful legacy-runtime load/exec delegation.
- Preserved behavior:
  - `PluginBridge` still lazy-loads `PPlugin` for the legacy runtime path,
  - explicit-name and autoload dispatch still preserve the same normalized
    plugin-name payloads,
  - exception behavior is unchanged when runtime load or exec dies.
- Updated focused regression coverage:
  - added `plugin_bridge_owner_wrappers_preserve_eval_error_state`.

## Validation
- Ran:
  - `perl -Iperl -c perl/LinkedSpec/PluginBridge.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=227`)

## 2026-03-13 - Phase 1A Slice: Preserve Caller `$@` During `Trace` Ref Stringification
## Summary
Stabilized another no-behavior-change `LinkedSpec::*` helper seam by making `LinkedSpec::Trace::_trace_stringify(...)` preserve caller `$@` across successful reference formatting through `Data::Dumper`.

## Changed Files
- Updated: `perl/LinkedSpec/Trace.pm`
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `USER_GUIDE.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`

## Technical Details
- Refactored `Trace` dump-formatting behavior:
  - added `LinkedSpec::Trace::_call_preserving_err(...)`,
  - routed the reference-formatting branch of `_trace_stringify(...)` through that helper,
  - preserved scalar passthrough and formatted dump output while restoring caller `$@`
    after successful `Data::Dumper` formatting.
- Preserved behavior:
  - `Trace` still lazy-loads and formats refs through `Data::Dumper`,
  - scalar values still pass through unchanged,
  - exception behavior is unchanged when dump formatting dies.
- Updated focused regression coverage:
  - added `trace_stringify_preserves_eval_error_state`.

## Validation
- Ran:
  - `perl -Iperl -c perl/LinkedSpec/Trace.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=226`)

## 2026-03-13 - Phase 1A Slice: Preserve Caller `$@` Across `BootstrapSpec::Core` Regex Helper Delegation
## Summary
Stabilized another no-behavior-change `LinkedSpec::*` helper seam by making `LinkedSpec::BootstrapSpec::Core` preserve caller `$@` across successful `LinkedRE` helper delegation.

## Changed Files
- Updated: `perl/LinkedSpec/BootstrapSpec/Core.pm`
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `USER_GUIDE.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`

## Technical Details
- Refactored `BootstrapSpec::Core` regex-helper delegation behavior:
  - added `LinkedSpec::BootstrapSpec::Core::_call_preserving_err(...)`,
  - routed `_linkedre_or(...)` and `_linkedre_ored_re(...)` through that helper,
  - preserved regex-helper return values while restoring caller `$@` after
    successful owner-path delegation.
- Preserved behavior:
  - `BootstrapSpec::Core` still delegates to the same `LinkedRE` owner,
  - bootstrap registry construction and bootstrap scanner helper behavior are unchanged,
  - exception behavior is unchanged when the regex-helper owner path dies.
- Updated focused regression coverage:
  - added `bootstrap_spec_core_linkedre_wrappers_preserve_eval_error_state`.

## Validation
- Ran:
  - `perl -Iperl -c perl/LinkedSpec/BootstrapSpec/Core.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=225`)

## 2026-03-13 - Phase 1A Slice: Preserve Caller `$@` Across Public Trace Wrapper Delegation
## Summary
Stabilized another no-behavior-change `LinkedSpec.pm` seam by making the public trace wrapper API preserve caller `$@` across successful delegation to `LinkedSpec::Trace`.

## Changed Files
- Updated: `perl/LinkedSpec.pm`
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `USER_GUIDE.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`

## Technical Details
- Refactored public trace wrapper delegation behavior:
  - routed `configure_trace(...)`, `trace_enter(...)`, `trace_exit(...)`,
    `trace_decision(...)`, `log_output(...)`, `log_dump(...)`, and
    `should_dump(...)` through `LinkedSpec::_call_preserving_err(...)`,
  - preserved scalar and scope-hash return values while restoring caller `$@`
    after successful owner-path delegation.
- Preserved behavior:
  - the public trace API still lazy-loads and delegates to `LinkedSpec::Trace`,
  - successful trace wrapper calls keep their existing return payloads,
  - exception behavior is unchanged when the trace owner path dies.
- Updated focused regression coverage:
  - added `linkedspec_trace_wrappers_preserve_eval_error_state`.

## Validation
- Ran:
  - `perl -c perl/LinkedSpec.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=224`)

## 2026-03-13 - Phase 1A Slice: Preserve Caller `$@` Across `Compiler` Helper Delegation
## Summary
Stabilized another no-behavior-change `LinkedSpec::*` helper seam by making `LinkedSpec::Compiler` preserve caller `$@` across successful trace, dump, and regex helper delegation.

## Changed Files
- Updated: `perl/LinkedSpec/Compiler.pm`
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `USER_GUIDE.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`

## Technical Details
- Refactored `Compiler` helper delegation behavior:
  - added `LinkedSpec::Compiler::_call_preserving_err(...)`,
  - routed `_dump_value(...)`, `_ored_re(...)`, `_trace_log_output(...)`,
    `_trace_log_dump(...)`, `_trace_should_dump(...)`, `_trace_enter(...)`,
    `_trace_exit(...)`, `_trace_decision(...)`,
    `_trace_apply_trace_options(...)`, and
    `_trace_level_name_for_current_verbosity(...)` through that helper,
  - preserved scalar return values and existing wrapper behavior while restoring
    caller `$@` after successful owner-path delegation.
- Preserved behavior:
  - `Compiler` still delegates to the same `Trace`, `Data::Dumper`, and
    `LinkedRE` owners,
  - successful helper calls keep their existing return payloads,
  - exception behavior is unchanged when an owner path dies.
- Updated focused regression coverage:
  - added `compiler_helper_wrappers_preserve_eval_error_state`.

## Validation
- Ran:
  - `perl -Iperl -c perl/LinkedSpec/Compiler.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=223`)

## 2026-03-13 - Phase 1A Slice: Preserve Caller `$@` Across `SpecEntry` Helper Delegation
## Summary
Stabilized another no-behavior-change `LinkedSpec::*` helper seam by making `LinkedSpec::SpecEntry` preserve caller `$@` across successful trace and dump helper delegation.

## Changed Files
- Updated: `perl/LinkedSpec/SpecEntry.pm`
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `USER_GUIDE.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`

## Technical Details
- Refactored `SpecEntry` helper delegation behavior:
  - added `LinkedSpec::SpecEntry::_call_preserving_err(...)`,
  - routed `_trace_enter(...)`, `_trace_exit(...)`, `_trace_decision(...)`,
    `_trace_log_dump(...)`, `_trace_should_dump(...)`, and `_dump_value(...)`
    through that helper,
  - preserved scalar return values and trace helper behavior while restoring
    caller `$@` after successful owner-path delegation.
- Preserved behavior:
  - `SpecEntry` still delegates to the same `Trace` and `Data::Dumper` owners,
  - successful trace/dump helper calls keep their existing return payloads,
  - exception behavior is unchanged when an owner path dies.
- Updated focused regression coverage:
  - added `spec_entry_helper_wrappers_preserve_eval_error_state`.

## Validation
- Ran:
  - `perl -Iperl -c perl/LinkedSpec/SpecEntry.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=222`)

## 2026-03-12 - Phase 1A Slice: Preserve Caller `$@` Across ActionRewriter Owner Delegation
## Summary
Stabilized the remaining `LinkedSpec::ActionRewriter` compatibility/helper seam by making its successful owner delegation preserve caller `$@` across deps, helper parsing, lowering, scanner, canonical, diagnostics, and rewrite-pipeline wrappers.

## Changed Files
- Updated: `perl/LinkedSpec/ActionRewriter.pm`
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `USER_GUIDE.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`

## Technical Details
- Refactored `ActionRewriter` delegation behavior:
  - added `LinkedSpec::ActionRewriter::_call_preserving_err(...)`,
  - routed the owner-delegate dep builders and helper wrappers through that helper,
  - covered representative MethodExpr/FlowExpr/Contracts/Scanner/CanonicalEvents/RewritePipeline paths plus `call_spec_handler_subst(...)`,
  - preserved scalar and list-context return payloads while restoring caller `$@` after successful owner-path delegation.
- Preserved behavior:
  - `ActionRewriter` still delegates to the same extracted ActionIR owners,
  - successful lowering/rewrite helper calls keep their existing return payloads,
  - exception behavior is unchanged when an owner path dies.
- Updated focused regression coverage:
  - added `action_rewriter_owner_wrappers_preserve_eval_error_state`.

## Validation
- Ran:
  - `perl -Iperl -c perl/LinkedSpec/ActionRewriter.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=221`)

## 2026-03-12 - Phase 1A Slice: Preserve Caller `$@` Across Remaining Thin Owner Delegates
## Summary
Finished the current `$@`-preservation cleanup track by making the remaining thin owner delegates in `BootstrapSpec`, `Runtime`, `ActionIR::Scanner`, `ActionIR::StatementSplit`, and `ActionIR::CanonicalEvents` preserve caller `$@` across successful owner delegation.

## Changed Files
- Updated: `perl/LinkedSpec/BootstrapSpec.pm`
- Updated: `perl/LinkedSpec/Runtime.pm`
- Updated: `perl/LinkedSpec/ActionIR/Scanner.pm`
- Updated: `perl/LinkedSpec/ActionIR/StatementSplit.pm`
- Updated: `perl/LinkedSpec/ActionIR/CanonicalEvents.pm`
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `USER_GUIDE.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`

## Technical Details
- Refactored remaining thin owner delegates:
  - added `_call_preserving_err(...)` to `BootstrapSpec`, `Runtime`,
    `ActionIR::Scanner`, `ActionIR::StatementSplit`, and
    `ActionIR::CanonicalEvents`,
  - routed `build_bootstrap_spec(...)`, `run_get(...)`,
    `scan_contract_ir_events(...)`, `_split_action_ir_statements(...)`, and
    `_canonicalize_helper_action_ir_event(...)` through that helper,
  - preserved scalar and list-context return payloads while restoring caller
    `$@` after successful owner-path delegation.
- Preserved behavior:
  - these wrappers still delegate to the same owner modules,
  - runtime context injection and canonical helper payloads stay unchanged,
  - exception behavior is unchanged when an owner path dies.
- Updated focused regression coverage:
  - added `remaining_owner_wrappers_preserve_eval_error_state`.

## Validation
- Ran:
  - `perl -Iperl -c perl/LinkedSpec/BootstrapSpec.pm`
  - `perl -Iperl -c perl/LinkedSpec/Runtime.pm`
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/Scanner.pm`
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/StatementSplit.pm`
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/CanonicalEvents.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=220`)

## 2026-03-12 - Phase 1A Slice: Preserve Caller `$@` Across Extracted Wrapper Delegation
## Summary
Stabilized another no-behavior-change Phase 1A seam by making the thin extracted helper wrappers in `Validation`, `Resolver`, `RuleIR`, and `RuleIR::EmitContext` preserve caller `$@` across successful owner delegation.

## Changed Files
- Updated: `perl/LinkedSpec/Validation.pm`
- Updated: `perl/LinkedSpec/Resolver.pm`
- Updated: `perl/LinkedSpec/RuleIR.pm`
- Updated: `perl/LinkedSpec/RuleIR/EmitContext.pm`
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `USER_GUIDE.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`

## Technical Details
- Refactored extracted helper delegation behavior:
  - added `_call_preserving_err(...)` to `Validation`, `Resolver`, `RuleIR`, and `RuleIR::EmitContext`,
  - routed successful trace, emit-context, dump, and action-rewrite owner calls through that helper,
  - preserved return-value context while restoring caller `$@` after successful owner-path delegation.
- Preserved behavior:
  - the extracted wrappers still delegate to the same owner modules,
  - successful scalar and list-context helper calls keep their existing return payloads,
  - exception behavior is unchanged when an owner path dies.
- Updated focused regression coverage:
  - added `extracted_wrapper_helpers_preserve_eval_error_state`.

## Validation
- Ran:
  - `perl -Iperl -c perl/LinkedSpec/Validation.pm`
  - `perl -Iperl -c perl/LinkedSpec/Resolver.pm`
  - `perl -Iperl -c perl/LinkedSpec/RuleIR.pm`
  - `perl -Iperl -c perl/LinkedSpec/RuleIR/EmitContext.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=219`)

## 2026-03-12 - Phase 1A Slice: Preserve Caller `$@` Across Public Facade Delegation
## Summary
Stabilized the public `LinkedSpec.pm` façade by making successful owner delegation preserve caller `$@`, so eval-based callers do not lose prior error state when using the thin compatibility entrypoints.

## Changed Files
- Updated: `perl/LinkedSpec.pm`
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `USER_GUIDE.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`

## Technical Details
- Refactored façade delegation behavior:
  - added `LinkedSpec::_call_preserving_err(...)`,
  - routed `Get(...)`, `spec_descr(...)`, `call_spec_handler_subst(...)`,
    `get_parser(...)`, and `AUTOLOAD` through that helper,
  - preserved return-value context while restoring caller `$@` after successful
    owner-path delegation.
- Preserved behavior:
  - the façade still delegates to the same owner modules,
  - successful public entrypoints keep their existing return payloads,
  - exception behavior is unchanged when an owner path dies.
- Updated focused regression coverage:
  - added `linkedspec_public_facade_wrappers_preserve_eval_error_state`.

## Validation
- Ran:
  - `perl -c perl/LinkedSpec.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=218`)

## 2026-03-12 - Phase 1A Slice: Lazy-Load `LinkedRE` Through `BootstrapSpec::Core`
## Summary
Reduced the last eager `LinkedRE` owner inside `LinkedSpec::*` by making `LinkedSpec::BootstrapSpec::Core` load the regex helper only when bootstrap registry construction or bootstrap scanning actually needs it.

## Changed Files
- Updated: `perl/LinkedSpec/BootstrapSpec/Core.pm`
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `USER_GUIDE.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`

## Technical Details
- Refactored BootstrapSpec::Core regex-helper ownership:
  - removed eager `use LinkedRE ();`,
  - added `LinkedSpec::BootstrapSpec::Core::_require_linkedre_pkg(...)`,
  - added `LinkedSpec::BootstrapSpec::Core::_linkedre_or(...)`,
  - added `LinkedSpec::BootstrapSpec::Core::_linkedre_ored_re(...)`,
  - updated bootstrap registry construction and bootstrap scanner handlers to lazy-load
    `LinkedRE` only when they actually build or consume bootstrap regex dispatch state.
- Preserved behavior:
  - require-only `BootstrapSpec::Core` paths still keep `LinkedRE` unloaded,
  - `build_bootstrap_spec(...)` still returns the same descriptor/rule-index/gdata shape,
  - bootstrap parsing continues to use the same regex dispatch helper once loaded.
- Updated focused regression coverage:
  - added `bootstrap_spec_core_require_avoids_linkedre_load_until_bootstrap_spec_build`.

## Validation
- Ran:
  - `perl -Iperl -c perl/LinkedSpec/BootstrapSpec/Core.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=217`)

## 2026-03-12 - Phase 1A Slice: Lazy-Load `LinkedRE` Through `Compiler`
## Summary
Reduced another staged-compile load-time dependency by making `LinkedSpec::Compiler` load `LinkedRE` only when regex gdata assembly actually needs it.

## Changed Files
- Updated: `perl/LinkedSpec/Compiler.pm`
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `USER_GUIDE.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`

## Technical Details
- Refactored Compiler regex-helper ownership:
  - removed eager `use LinkedRE;`,
  - added `LinkedSpec::Compiler::_require_linkedre_pkg(...)`,
  - added `LinkedSpec::Compiler::_ored_re(...)`,
  - updated `spec_gdata(...)` to lazy-load `LinkedRE` only when it actually builds
    combined regex dependencies.
- Preserved behavior:
  - require-only compiler paths still keep `LinkedRE` unloaded,
  - `run_get_pipeline(...)` still returns the same descriptor hash shape,
  - generated gdata regex composition stays owned by `Compiler.pm`.
- Updated focused regression coverage:
  - added `compiler_require_avoids_linkedre_load_until_run_get_pipeline`.

## Validation
- Ran:
  - `perl -Iperl -c perl/LinkedSpec/Compiler.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=216`)

## 2026-03-12 - Phase 1A Slice: Remove Dead `LinkedRE` Import from `LinkedSpec.pm`
## Summary
Reduced the façade load-time surface again by removing a dead `LinkedRE` import from `LinkedSpec.pm`, so plain `require LinkedSpec` no longer pulls the regex helper in up front.

## Changed Files
- Updated: `perl/LinkedSpec.pm`
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `USER_GUIDE.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`

## Technical Details
- Refactored façade load-time ownership:
  - removed unused `use LinkedRE;` from `LinkedSpec.pm`,
  - added a focused require-only/lazy-compile regression to prove `require LinkedSpec`
    now keeps `LinkedRE` unloaded until the compile path actually needs it.
- Preserved behavior:
  - public façade APIs are unchanged,
  - `Get(...)` still compiles and returns a parser coderef,
  - `LinkedRE` still loads on demand through the existing compile path.
- Updated focused regression coverage:
  - added `linkedspec_require_avoids_linkedre_load_until_get`.

## Validation
- Ran:
  - `perl -c perl/LinkedSpec.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=215`)

## 2026-03-12 - Phase 1A Slice: Lazy-Load `Data::Dumper` Through `Compiler`
## Summary
Reduced another staged-compile load-time dependency by making `LinkedSpec::Compiler` load `Data::Dumper` only when traced compiler dumps actually need structured formatting.

## Changed Files
- Updated: `perl/LinkedSpec/Compiler.pm`
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `USER_GUIDE.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`

## Technical Details
- Refactored Compiler dump ownership:
  - removed eager `use Data::Dumper;`,
  - added `LinkedSpec::Compiler::_require_data_dumper_pkg(...)`,
  - added `LinkedSpec::Compiler::_dump_value(...)`,
  - updated compiler dump sites to lazy-load `Data::Dumper` only for traced summary,
    parsed-spec, gdata, and final-descriptor dump paths.
- Preserved behavior:
  - require-only or non-debug compiler paths still keep `Data::Dumper` unloaded,
  - `run_get_pipeline(...)`, `spec_descr(...)`, and `spec_gdata(...)` behavior is unchanged,
  - traced compiler dump payloads still emit the same structured content.
- Updated focused regression coverage:
  - added `compiler_require_avoids_data_dumper_load_until_debug_pipeline_dump`.

## Validation
- Ran:
  - `perl -Iperl -c perl/LinkedSpec/Compiler.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=214`)

## 2026-03-12 - Phase 1A Slice: Lazy-Load `Data::Dumper` Through `SpecEntry`
## Summary
Reduced another staged-compile load-time dependency by making `LinkedSpec::SpecEntry` load `Data::Dumper` only when high-verbosity rule-entry debug dumps actually need structured formatting.

## Changed Files
- Updated: `perl/LinkedSpec/SpecEntry.pm`
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `USER_GUIDE.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`

## Technical Details
- Refactored SpecEntry dump ownership:
  - removed eager `use Data::Dumper;`,
  - added `LinkedSpec::SpecEntry::_require_data_dumper_pkg(...)`,
  - added `LinkedSpec::SpecEntry::_dump_value(...)`,
  - updated `compile_spec_entry(...)` to lazy-load `Data::Dumper` only for the
    high-verbosity `SPEC ENTRY DUMP` and `RULE INFO DUMP` trace paths.
- Preserved behavior:
  - require-only or non-debug SpecEntry paths still keep `Data::Dumper` unloaded,
  - rule-entry compilation and handler generation are unchanged,
  - high-verbosity debug dumps still emit the same structured payloads.
- Updated focused regression coverage:
  - added `spec_entry_require_avoids_data_dumper_load_until_debug_compile_dump`.

## Validation
- Ran:
  - `perl -Iperl -c perl/LinkedSpec/SpecEntry.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=213`)

## 2026-03-12 - Phase 1A Slice: Remove Dead `Data::Dumper` Import from `LinkedSpec.pm`
## Summary
Reduced the façade load-time surface again by removing a dead `Data::Dumper` import from `LinkedSpec.pm`, so plain `require LinkedSpec` no longer pulls that dump helper in up front.

## Changed Files
- Updated: `perl/LinkedSpec.pm`
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `USER_GUIDE.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`

## Technical Details
- Refactored façade load-time ownership:
  - removed unused `use Data::Dumper;` from `LinkedSpec.pm`,
  - added a focused require-only regression to prove `require LinkedSpec` now keeps
    `Data::Dumper` unloaded.
- Preserved behavior:
  - public façade APIs are unchanged,
  - trace, parser-factory, compiler, runtime, and plugin lazy-load behavior is unchanged,
  - structured dump formatting remains owned by extracted modules that still need it.
- Updated focused regression coverage:
  - added `linkedspec_require_avoids_data_dumper_load`.

## Validation
- Ran:
  - `perl -c perl/LinkedSpec.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=212`)

## 2026-03-12 - Phase 1A Slice: Lazy-Load `Data::Dumper` Through `RuleIR`
## Summary
Reduced another internal load-time dependency by making `LinkedSpec::RuleIR` load `Data::Dumper` only when debug execution-meta dumps actually need structured formatting.

## Changed Files
- Updated: `perl/LinkedSpec/RuleIR.pm`
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `USER_GUIDE.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`

## Technical Details
- Refactored RuleIR dump ownership:
  - removed eager `use Data::Dumper;`,
  - added `LinkedSpec::RuleIR::_require_data_dumper_pkg(...)`,
  - added `LinkedSpec::RuleIR::_dump_value(...)`,
  - updated `_build_rule_execution_meta(...)` to lazy-load `Data::Dumper` only when
    the debug-only `Rule meta` trace path runs.
- Preserved behavior:
  - normal require-only or non-debug RuleIR paths still keep `Data::Dumper` unloaded,
  - debug execution-meta dumps still emit the same `Rule meta` trace label and structured payload,
  - handler-variant selection and action-mode metadata stay unchanged.
- Updated focused regression coverage:
  - added `ruleir_require_avoids_data_dumper_load_until_debug_meta_dump`.

## Validation
- Ran:
  - `perl -Iperl -c perl/LinkedSpec/RuleIR.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=211`)

## 2026-03-12 - Phase 1A Slice: Lazy-Load `Data::Dumper` Through `Trace`
## Summary
Reduced another core load-time dependency by making `LinkedSpec::Trace` load `Data::Dumper` only when referenced values actually need structured dump formatting.

## Changed Files
- Updated: `perl/LinkedSpec/Trace.pm`
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `USER_GUIDE.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`

## Technical Details
- Refactored Trace dump ownership:
  - removed eager `use Data::Dumper;`,
  - added `LinkedSpec::Trace::_require_data_dumper_pkg(...)`,
  - updated `_trace_stringify(...)` to lazy-load `Data::Dumper` and call
    `Data::Dumper::Dumper(...)` only for referenced values.
- Preserved behavior:
  - scalar trace context values still pass through unchanged,
  - referenced values still use terse, single-line, sorted-key dump formatting,
  - public trace APIs still format structured context payloads the same way.
- Updated focused regression coverage:
  - added `trace_require_avoids_data_dumper_load_until_stringify_ref`.

## Validation
- Ran:
  - `perl -Iperl -c perl/LinkedSpec/Trace.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=210`)

## 2026-03-12 - Phase 1A Slice: Lazy-Load `ActionRewriter` Through `RuleIR::EmitContext`
## Summary
Reduced the last direct modularized owner import inside `LinkedSpec::*` by making `LinkedSpec::RuleIR::EmitContext` load `LinkedSpec::ActionRewriter` only when emit-context build paths actually need rewrite helpers.

## Changed Files
- Updated: `perl/LinkedSpec/RuleIR/EmitContext.pm`
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `USER_GUIDE.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`

## Technical Details
- Refactored EmitContext action-rewriter ownership:
  - removed eager `use LinkedSpec::ActionRewriter ();`,
  - added `LinkedSpec::RuleIR::EmitContext::_require_action_rewriter_pkg(...)`,
  - updated `_trim_action_ir_value(...)`, `_rewrite_action_code_with_diagnostics(...)`,
    `_accumulate_action_rewrite_diagnostics(...)`, and `_build_action_rewrite_rules(...)`
    to lazy-load `ActionRewriter.pm` before delegating.
- Preserved behavior:
  - `build_rule_ir_emit_context(...)` still rewrites ACODE/BCODE blocks through the same
    ActionRewriter-owned helpers,
  - unresolved-helper and canonical-action metadata stays unchanged,
  - the previously landed removed-facade seam stays on `LinkedSpec::ActionRewriter`, not
    the old `LinkedSpec.pm` compatibility surface.
- Updated focused regression coverage:
  - added `emit_context_require_avoids_action_rewriter_load_until_emit_context_build`.

## Validation
- Ran:
  - `perl -Iperl -c perl/LinkedSpec/RuleIR/EmitContext.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=209`)

## 2026-03-12 - Phase 1A Slice: Lazy-Load `Trace` Through the Facade
## Summary
Reduced the final façade-level trace load-time coupling by making `LinkedSpec.pm` load `LinkedSpec::Trace` only when the public trace API is actually used, so plain `require LinkedSpec` no longer imports `Trace.pm` up front.

## Changed Files
- Updated: `perl/LinkedSpec.pm`
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `USER_GUIDE.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`

## Technical Details
- Refactored façade trace ownership:
  - removed eager `use LinkedSpec::Trace ();`,
  - added `LinkedSpec::_require_trace_pkg(...)`,
  - updated `configure_trace(...)`, `trace_enter(...)`, `trace_exit(...)`, `trace_decision(...)`,
    `log_output(...)`, `log_dump(...)`, and `should_dump(...)` to lazy-load `Trace.pm`
    before delegating,
  - preserved `$@` across those façade wrappers so lazy trace loading does not clobber
    eval error state,
  - kept the existing façade trace-state aliases (`$LinkedSpec::DUMP_VERBOSITY`,
    `$LinkedSpec::TRACE_LOG_FILE`, and related variables) as the public compatibility surface.
- Updated regression assumptions:
  - parser-factory option-normalization tests now explicitly `require LinkedSpec::Trace`
    when they intentionally localize internal trace state, so plain `require LinkedSpec`
    can stay lazy.
- Updated focused regression coverage:
  - added `linkedspec_require_avoids_trace_load_until_public_trace_api`.

## Validation
- Ran:
  - `perl -c perl/LinkedSpec.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=208`)
## 2026-03-12 - Phase 1A Slice: Lazy-Load `Trace` Through `Compiler`
## Summary
Reduced internal compile-pipeline load-time coupling again by making `LinkedSpec::Compiler` load `LinkedSpec::Trace` only when compiler tracing actually starts, so require-only consumers of `Compiler.pm` no longer import the trace owner up front.

## Changed Files
- Updated: `perl/LinkedSpec/Compiler.pm`
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `USER_GUIDE.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`

## Technical Details
- Refactored Compiler trace ownership:
  - removed eager `use LinkedSpec::Trace ();`,
  - replaced Compiler-local dump constants with stable numeric values matching `Trace.pm`,
  - added `LinkedSpec::Compiler::_require_trace_pkg(...)`,
  - added `LinkedSpec::Compiler::_trace_log_output(...)`,
  - added `LinkedSpec::Compiler::_trace_log_dump(...)`,
  - added `LinkedSpec::Compiler::_trace_should_dump(...)`,
  - added `LinkedSpec::Compiler::_trace_enter(...)`,
  - added `LinkedSpec::Compiler::_trace_exit(...)`,
  - added `LinkedSpec::Compiler::_trace_decision(...)`,
  - added `LinkedSpec::Compiler::_trace_apply_trace_options(...)`,
  - added `LinkedSpec::Compiler::_trace_level_name_for_current_verbosity(...)`,
  - updated `spec_descr(...)`, `spec_gdata(...)`, `_build_action_rewriter_migration_summary(...)`,
    and `run_get_pipeline(...)` to route trace work through those owner helpers.
- Preserved behavior:
  - `run_get_pipeline(...)` still returns descriptors and parser coderefs the same way,
  - compiler validation and parse failure diagnostics still route through `LinkedSpec::Trace`,
  - trace-level naming and option parsing stay on the extracted `Trace.pm` owner.
- Updated focused regression coverage:
  - added `compiler_require_avoids_trace_load_until_run_get_pipeline`.

## Validation
- Ran:
  - `perl -Iperl -c perl/LinkedSpec/Compiler.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=207`)
## 2026-03-12 - Phase 1A Slice: Lazy-Load `Trace` Through `SpecEntry`
## Summary
Reduced internal staged-rule-compilation load-time coupling again by making `LinkedSpec::SpecEntry` load `LinkedSpec::Trace` only when `compile_spec_entry(...)` actually starts traced rule compilation, so require-only consumers of `SpecEntry.pm` no longer import the trace owner up front.

## Changed Files
- Updated: `perl/LinkedSpec/SpecEntry.pm`
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `USER_GUIDE.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`

## Technical Details
- Refactored SpecEntry trace ownership:
  - removed eager `use LinkedSpec::Trace ();`,
  - replaced SpecEntry-local dump constants with stable numeric values matching `Trace.pm`,
  - added `LinkedSpec::SpecEntry::_require_trace_pkg(...)`,
  - added `LinkedSpec::SpecEntry::_trace_enter(...)`,
  - added `LinkedSpec::SpecEntry::_trace_exit(...)`,
  - added `LinkedSpec::SpecEntry::_trace_decision(...)`,
  - added `LinkedSpec::SpecEntry::_trace_log_dump(...)`,
  - added `LinkedSpec::SpecEntry::_trace_should_dump(...)`,
  - updated `compile_spec_entry(...)` and runtime handler construction to route trace work through those owner helpers.
- Preserved behavior:
  - `compile_spec_entry(...)` still returns the same compiled rule info and `top_rule`,
  - runtime handler eval tracing still records success/error plus exit metadata,
  - high-verbosity rule-info and handler dumps remain unchanged.
- Updated focused regression coverage:
  - added `spec_entry_require_avoids_trace_load_until_compile_spec_entry`.

## Validation
- Ran:
  - `perl -Iperl -c perl/LinkedSpec/SpecEntry.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=206`)
## 2026-03-12 - Phase 1A Slice: Lazy-Load `Trace` Through `RuleIR`
## Summary
Reduced internal staged-rule-compilation load-time coupling again by making `LinkedSpec::RuleIR` load `LinkedSpec::Trace` only when RuleIR diagnostics actually need to emit output, so require-only consumers of `RuleIR.pm` no longer import the trace owner up front.

## Changed Files
- Updated: `perl/LinkedSpec/RuleIR.pm`
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `USER_GUIDE.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`

## Technical Details
- Refactored RuleIR trace ownership:
  - removed eager `use LinkedSpec::Trace ();`,
  - replaced RuleIR-local dump constants with stable numeric values matching `Trace.pm`,
  - added `LinkedSpec::RuleIR::_require_trace_pkg(...)`,
  - added `LinkedSpec::RuleIR::_trace_should_dump(...)`,
  - added `LinkedSpec::RuleIR::_trace_log_output(...)`,
  - added `LinkedSpec::RuleIR::_trace_decision(...)`,
  - updated execution-meta debug dumping to stay lazy when `Trace.pm` has not been loaded,
  - updated mixed-action validation diagnostics to lazy-load `Trace.pm` only when the error path actually emits output.
- Preserved behavior:
  - `_build_rule_execution_meta(...)` still returns the same handler-variant metadata,
  - `_validate_rule_ir_or_exit(...)` still rejects mixed ACTION/BLIND CALL rules,
  - the existing mixed-action diagnostic text remains unchanged.
- Updated focused regression coverage:
  - added `ruleir_require_avoids_trace_load_until_mixed_action_error`.

## Validation
- Ran:
  - `perl -Iperl -c perl/LinkedSpec/RuleIR.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=205`)
## 2026-03-12 - Phase 1A Slice: Lazy-Load `Trace` Through `RuleIR::EmitContext`
## Summary
Reduced internal staged-rule-compilation load-time coupling again by making `LinkedSpec::RuleIR::EmitContext` load `LinkedSpec::Trace` only when unresolved-helper diagnostics actually need to emit output, so require-only consumers of `EmitContext.pm` no longer import the trace owner up front.

## Changed Files
- Updated: `perl/LinkedSpec/RuleIR/EmitContext.pm`
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `USER_GUIDE.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`

## Technical Details
- Refactored EmitContext trace ownership:
  - removed eager `use LinkedSpec::Trace ();`,
  - replaced the EmitContext-local `DUMP_LOW` constant with the stable numeric value matching `Trace.pm`,
  - added `LinkedSpec::RuleIR::EmitContext::_require_trace_pkg(...)`,
  - added `LinkedSpec::RuleIR::EmitContext::_trace_log_output(...)`,
  - updated unresolved-helper diagnostic logging in `_build_action_rewriter_meta(...)`
    to lazy-load `Trace.pm` only when that diagnostic path actually runs.
- Preserved behavior:
  - action-rewriter metadata assembly still returns the same unresolved-helper counts, names, and raw statements,
  - no trace work occurs on require-only or zero-unresolved-helper paths,
  - unresolved-helper diagnostics still route through `LinkedSpec::Trace::log_output(...)`.
- Updated focused regression coverage:
  - added `emit_context_require_avoids_trace_load_until_unresolved_helper_diag`.

## Validation
- Ran:
  - `perl -Iperl -c perl/LinkedSpec/RuleIR/EmitContext.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=204`)
## 2026-03-12 - Phase 1A Slice: Lazy-Load `Trace` Through `Resolver`
## Summary
Reduced internal load-time coupling again by making `LinkedSpec::Resolver` load `LinkedSpec::Trace` only when invalid-spec or spec-resolution trace/error paths actually need to emit output, so require-only consumers of `Resolver.pm` no longer import the trace owner up front.

## Changed Files
- Updated: `perl/LinkedSpec/Resolver.pm`
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `USER_GUIDE.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`

## Technical Details
- Refactored Resolver trace ownership:
  - removed eager `use LinkedSpec::Trace ();`,
  - replaced Resolver-local dump constants with stable numeric values matching `Trace.pm`,
  - added `LinkedSpec::Resolver::_require_trace_pkg(...)`,
  - added `LinkedSpec::Resolver::_trace_log_output(...)`,
  - added `LinkedSpec::Resolver::_trace_exit(...)`,
  - added `LinkedSpec::Resolver::_trace_decision(...)`,
  - updated invalid-spec, path-resolution, and file-open reporting paths to lazy-load `Trace.pm`
    only when they actually emit trace output.
- Preserved behavior:
  - valid local/module-relative resolution behavior stays unchanged,
  - invalid spec-name and missing-path diagnostics still route through `LinkedSpec::Trace`,
  - `PathSearch` fallback behavior is unchanged.
- Updated focused regression coverage:
  - added `resolver_require_avoids_trace_load_until_invalid_spec_error`.

## Validation
- Ran:
  - `perl -Iperl -c perl/LinkedSpec/Resolver.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=203`)
## 2026-03-12 - Phase 1A Slice: Lazy-Load `Trace` Through `Validation`
## Summary
Reduced internal load-time coupling again by making `LinkedSpec::Validation` load `LinkedSpec::Trace` only when validation errors or warnings actually need to emit trace output, so require-only consumers of `Validation.pm` no longer import the trace owner up front.

## Changed Files
- Updated: `perl/LinkedSpec/Validation.pm`
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `USER_GUIDE.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`

## Technical Details
- Refactored Validation trace ownership:
  - removed eager `use LinkedSpec::Trace ();`,
  - replaced Validation-local dump constants with stable numeric values matching `Trace.pm`,
  - added `LinkedSpec::Validation::_require_trace_pkg(...)`,
  - added `LinkedSpec::Validation::_trace_log_output(...)`,
  - updated all Validation error/warning reporting paths to lazy-load `Trace.pm`
    only when they actually emit log output.
- Preserved behavior:
  - validation success paths still avoid trace work,
  - malformed-spec diagnostics still include DSL line context,
  - warning/error routing still goes through `LinkedSpec::Trace::log_output(...)`.
- Updated focused regression coverage:
  - added `validation_require_avoids_trace_load_until_error_report`.

## Validation
- Ran:
  - `perl -Iperl -c perl/LinkedSpec/Validation.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=202`)
## 2026-03-12 - Phase 1A Slice: Lazy-Load `DeclareMethod` Through `ActionRewriter`
## Summary
Reduced internal ActionIR load-time coupling again by making `LinkedSpec::ActionRewriter` load `ActionIR::DeclareMethod` only when declare-method helper paths actually run, so require-only consumers of `ActionRewriter.pm` no longer import the declare-method owner up front.

## Changed Files
- Updated: `perl/LinkedSpec/ActionRewriter.pm`
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `USER_GUIDE.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`

## Technical Details
- Refactored ActionRewriter owner loading:
  - removed eager `use LinkedSpec::ActionIR::DeclareMethod ();`,
  - added `LinkedSpec::ActionRewriter::_require_declare_method_pkg(...)`,
  - updated `_declare_method_deps(...)`, `_split_declare_symbol_names(...)`,
    `_parse_declare_binding_entry(...)`, `_lower_declare_value_expr(...)`,
    `_lower_declare_initializer_expr(...)`, `_extract_declare_statement_from_method_expr(...)`,
    `_lower_declare_method_statement(...)`, and `_lower_assign_method_statement(...)`
    to lazy-load `DeclareMethod.pm` before resolving default deps or delegating
    into declare-method helpers.
- Preserved behavior:
  - declare-method lowering still routes through `LinkedSpec::ActionIR::DeclareMethod`,
  - the existing declare-method default dep map remains intact,
  - `declare(array, items)` and `assign(retv, scalar(foo))` still lower the same way.
- Updated focused regression coverage:
  - added `action_rewriter_require_avoids_declare_method_load_until_declare_helper`.

## Validation
- Ran:
  - `perl -Iperl -c perl/LinkedSpec/ActionRewriter.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=201`)
## 2026-03-12 - Phase 1A Slice: Lazy-Load `MethodLowering` Through `ActionRewriter`
## Summary
Reduced internal ActionIR load-time coupling again by making `LinkedSpec::ActionRewriter` load `ActionIR::MethodLowering` only when method-lowering helper paths actually run, so require-only consumers of `ActionRewriter.pm` no longer import the method-lowering owner up front.

## Changed Files
- Updated: `perl/LinkedSpec/ActionRewriter.pm`
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `USER_GUIDE.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`

## Technical Details
- Refactored ActionRewriter owner loading:
  - removed eager `use LinkedSpec::ActionIR::MethodLowering ();`,
  - added `LinkedSpec::ActionRewriter::_require_method_lowering_pkg(...)`,
  - updated `_method_lowering_deps(...)`, `_declare_alias_to_type(...)`,
    `_lower_typed_declare_statement(...)`, `_normalize_method_tag_expr(...)`,
    `_lower_method_value_expr(...)`, `_lower_return_general_statement(...)`,
    `_lower_return_imatch_statement(...)`, `_lower_assign_statement(...)`,
    `_lower_push_value_statement(...)`, `_lower_regex_subst_statement(...)`,
    `_lower_return_undef_statement(...)`, and `_lower_return_array_statement(...)`
    to lazy-load `MethodLowering.pm` before resolving default deps or delegating
    into method-lowering helpers.
- Preserved behavior:
  - method-lowering still routes through `LinkedSpec::ActionIR::MethodLowering`,
  - the existing method-lowering default dep map remains intact,
  - alias resolution and assign lowering outputs stay unchanged.
- Updated focused regression coverage:
  - added `action_rewriter_require_avoids_method_lowering_load_until_method_helper`.

## Validation
- Ran:
  - `perl -Iperl -c perl/LinkedSpec/ActionRewriter.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=200`)
## 2026-03-12 - Phase 1A Slice: Lazy-Load `ControlFlow` Through `ActionRewriter`
## Summary
Reduced internal ActionIR load-time coupling again by making `LinkedSpec::ActionRewriter` load `ActionIR::ControlFlow` only when flow-statement helper paths actually run, so require-only consumers of `ActionRewriter.pm` no longer import the control-flow owner up front.

## Changed Files
- Updated: `perl/LinkedSpec/ActionRewriter.pm`
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `USER_GUIDE.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`

## Technical Details
- Refactored ActionRewriter owner loading:
  - removed eager `use LinkedSpec::ActionIR::ControlFlow ();`,
  - added `LinkedSpec::ActionRewriter::_require_control_flow_pkg(...)`,
  - updated `_control_flow_deps(...)`, `_lower_if_flow_statement(...)`,
    `_lower_elseif_flow_statement(...)`, `_lower_else_flow_statement(...)`,
    `_lower_endif_flow_statement(...)`, `_lower_switch_flow_statement(...)`,
    `_lower_case_flow_statement(...)`, `_lower_default_flow_statement(...)`,
    `_lower_endcase_flow_statement(...)`, `_lower_endswitch_flow_statement(...)`,
    `_lower_say_statement(...)`, and `_lower_print_statement(...)`
    to lazy-load `ControlFlow.pm` before resolving default deps or delegating
    into control-flow helpers.
- Preserved behavior:
  - control-flow lowering still routes through `LinkedSpec::ActionIR::ControlFlow`,
  - the existing control-flow default dep map remains intact,
  - `if(is_empty(array(items)))` and `print(scalar(foo))` still lower the same way.
- Updated focused regression coverage:
  - added `action_rewriter_require_avoids_control_flow_load_until_control_helper`.

## Validation
- Ran:
  - `perl -Iperl -c perl/LinkedSpec/ActionRewriter.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=199`)
## 2026-03-12 - Phase 1A Slice: Lazy-Load `ValueExpr` Through `ActionRewriter`
## Summary
Reduced internal ActionIR load-time coupling again by making `LinkedSpec::ActionRewriter` load `ActionIR::ValueExpr` only when value helper paths actually run, so require-only consumers of `ActionRewriter.pm` no longer import the value-expression owner up front.

## Changed Files
- Updated: `perl/LinkedSpec/ActionRewriter.pm`
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `USER_GUIDE.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`

## Technical Details
- Refactored ActionRewriter owner loading:
  - removed eager `use LinkedSpec::ActionIR::ValueExpr ();`,
  - added `LinkedSpec::ActionRewriter::_require_value_expr_pkg(...)`,
  - updated `_value_expr_deps(...)`, `_extract_scalar_symbol_name(...)`,
    `_extract_array_symbol_name(...)`, `_extract_hash_symbol_name(...)`,
    `_lower_scalar_access_key_expr(...)`, `_lower_scalaref_value_expr(...)`,
    `_infer_scalar_container_kind(...)`, `_lower_assignment_source_expr(...)`,
    and `_strip_literal_delimiters(...)` to lazy-load `ValueExpr.pm`
    before resolving default deps or delegating into value-expression helpers.
- Preserved behavior:
  - value-expression lowering still routes through `LinkedSpec::ActionIR::ValueExpr`,
  - the existing value-expression default dep map remains intact,
  - scalar-access and scalaref lowering outputs stay unchanged.
- Updated focused regression coverage:
  - added `action_rewriter_require_avoids_value_expr_load_until_value_helper`.

## Validation
- Ran:
  - `perl -Iperl -c perl/LinkedSpec/ActionRewriter.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=198`)
## 2026-03-12 - Phase 1A Slice: Lazy-Load `ArrayPipeline` Through `ActionRewriter`
## Summary
Reduced internal ActionIR load-time coupling again by making `LinkedSpec::ActionRewriter` load `ActionIR::ArrayPipeline` only when array helper paths actually run, so require-only consumers of `ActionRewriter.pm` no longer import the array-pipeline owner up front.

## Changed Files
- Updated: `perl/LinkedSpec/ActionRewriter.pm`
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `USER_GUIDE.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`

## Technical Details
- Refactored ActionRewriter owner loading:
  - removed eager `use LinkedSpec::ActionIR::ArrayPipeline ();`,
  - added `LinkedSpec::ActionRewriter::_require_array_pipeline_pkg(...)`,
  - updated `_array_pipeline_deps(...)`, `_build_array_pipeline_plan_from_expr(...)`,
    and `_lower_array_pipeline_expr(...)` to lazy-load `ArrayPipeline.pm`
    before resolving default deps or delegating into array-pipeline helpers.
- Preserved behavior:
  - array-pipeline planning and lowering still route through `LinkedSpec::ActionIR::ArrayPipeline`,
  - the existing array-pipeline default dep map remains intact,
  - `filter_nonempty(array(items))` still plans and lowers the same way.
- Updated focused regression coverage:
  - added `action_rewriter_require_avoids_array_pipeline_load_until_array_helper`.

## Validation
- Ran:
  - `perl -Iperl -c perl/LinkedSpec/ActionRewriter.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=197`)
## 2026-03-12 - Phase 1A Slice: Lazy-Load `FlowExpr` Through `ActionRewriter`
## Summary
Reduced internal ActionIR load-time coupling again by making `LinkedSpec::ActionRewriter` load `ActionIR::FlowExpr` only when flow helper paths actually run, so require-only consumers of `ActionRewriter.pm` no longer import the flow-expression owner up front.

## Changed Files
- Updated: `perl/LinkedSpec/ActionRewriter.pm`
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `USER_GUIDE.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`

## Technical Details
- Refactored ActionRewriter owner loading:
  - removed eager `use LinkedSpec::ActionIR::FlowExpr ();`,
  - added `LinkedSpec::ActionRewriter::_require_flow_expr_pkg(...)`,
  - updated `_flow_expr_deps(...)` and `_lower_flow_composite_expr(...)`
    to lazy-load `FlowExpr.pm` before resolving default deps or delegating into the flow-expression owner path.
- Preserved behavior:
  - flow lowering still routes through `LinkedSpec::ActionIR::FlowExpr::_lower_flow_composite_expr(...)`,
  - the existing flow-expression default dep map remains intact,
  - `is_empty(array(items))` still lowers to `(!@items)`.
- Updated focused regression coverage:
  - added `action_rewriter_require_avoids_flow_expr_load_until_flow_helper`.

## Validation
- Ran:
  - `perl -Iperl -c perl/LinkedSpec/ActionRewriter.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=196`)
## 2026-03-12 - Phase 1A Slice: Lazy-Load `RewritePipeline` Through `ActionRewriter`
## Summary
Reduced internal ActionIR load-time coupling again by making `LinkedSpec::ActionRewriter` load `ActionIR::RewritePipeline` only when rewrite helper paths actually run, so require-only consumers of `ActionRewriter.pm` no longer import the rewrite-pipeline owner up front.

## Changed Files
- Updated: `perl/LinkedSpec/ActionRewriter.pm`
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `USER_GUIDE.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`

## Technical Details
- Refactored ActionRewriter owner loading:
  - removed eager `use LinkedSpec::ActionIR::RewritePipeline ();`,
  - added `LinkedSpec::ActionRewriter::_require_rewrite_pipeline_pkg(...)`,
  - updated `_rewrite_pipeline_deps(...)`, `_lower_action_code_from_canonical_ir(...)`,
    `_rewrite_action_code_with_diagnostics(...)`, and `_build_action_rewrite_rules(...)`
    to lazy-load `RewritePipeline.pm` before resolving default deps or delegating into rewrite helpers.
- Preserved behavior:
  - rewrite orchestration still routes through `LinkedSpec::ActionIR::RewritePipeline`,
  - the existing rewrite-pipeline default dep map remains intact,
  - `return_a(Top)` still rewrites to `return ['?Top:', \@Top]` with canonical `RETURN_A` diagnostics.
- Updated focused regression coverage:
  - added `action_rewriter_require_avoids_rewrite_pipeline_load_until_rewrite_helper`.

## Validation
- Ran:
  - `perl -Iperl -c perl/LinkedSpec/ActionRewriter.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=195`)
## 2026-03-12 - Phase 1A Slice: Lazy-Load `Contracts` Through `ActionRewriter`
## Summary
Reduced internal ActionIR load-time coupling again by making `LinkedSpec::ActionRewriter` load `ActionIR::Contracts` only when lowering-contract helper paths actually run, so require-only consumers of `ActionRewriter.pm` no longer import the lowering-contract owner up front.

## Changed Files
- Updated: `perl/LinkedSpec/ActionRewriter.pm`
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `USER_GUIDE.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`

## Technical Details
- Refactored ActionRewriter owner loading:
  - removed eager `use LinkedSpec::ActionIR::Contracts ();`,
  - added `LinkedSpec::ActionRewriter::_require_contracts_pkg(...)`,
  - updated `_action_contract_deps(...)` and `_build_action_lowering_contracts(...)`
    to lazy-load `Contracts.pm` before resolving default deps or delegating into the owner path.
- Preserved behavior:
  - action-lowering contracts still route through `LinkedSpec::ActionIR::Contracts::build_action_lowering_contracts(...)`,
  - the existing contract default dep map remains intact,
  - the `declare_typed` lowering contract still lowers `declare(array, items)` to `my @items`.
- Updated focused regression coverage:
  - added `action_rewriter_require_avoids_contracts_load_until_contract_helper`.

## Validation
- Ran:
  - `perl -Iperl -c perl/LinkedSpec/ActionRewriter.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=194`)
## 2026-03-12 - Phase 1A Slice: Lazy-Load `StatementSplit` Through `ActionRewriter`
## Summary
Reduced internal ActionIR load-time coupling again by making `LinkedSpec::ActionRewriter` load `ActionIR::StatementSplit` only when split helper paths actually run, so require-only consumers of `ActionRewriter.pm` no longer import the statement-splitting owner up front.

## Changed Files
- Updated: `perl/LinkedSpec/ActionRewriter.pm`
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `USER_GUIDE.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`

## Technical Details
- Refactored ActionRewriter owner loading:
  - removed eager `use LinkedSpec::ActionIR::StatementSplit ();`,
  - added `LinkedSpec::ActionRewriter::_require_statement_split_pkg(...)`,
  - updated `_statement_split_deps(...)` and `_split_action_ir_statements(...)`
    to lazy-load `StatementSplit.pm` before resolving default deps or delegating into the owner path.
- Preserved behavior:
  - statement splitting still routes through `LinkedSpec::ActionIR::StatementSplit::_split_action_ir_statements(...)`,
  - the existing statement-split default dep map remains intact,
  - split output for `return foo; exit` stays unchanged after the owner-module lazy load.
- Updated focused regression coverage:
  - added `action_rewriter_require_avoids_statement_split_load_until_split_helper`.

## Validation
- Ran:
  - `perl -Iperl -c perl/LinkedSpec/ActionRewriter.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=193`)
## 2026-03-12 - Phase 1A Slice: Lazy-Load `Scanner` Through `ActionRewriter`
## Summary
Reduced internal ActionIR load-time coupling again by making `LinkedSpec::ActionRewriter` load `ActionIR::Scanner` only when scanner helper paths actually run, so require-only consumers of `ActionRewriter.pm` no longer import the contract scanner owner up front.

## Changed Files
- Updated: `perl/LinkedSpec/ActionRewriter.pm`
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `USER_GUIDE.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`

## Technical Details
- Refactored ActionRewriter owner loading:
  - removed eager `use LinkedSpec::ActionIR::Scanner ();`,
  - added `LinkedSpec::ActionRewriter::_require_scanner_pkg(...)`,
  - updated `_scan_contract_ir_event_deps(...)` and `_scan_contract_ir_events(...)`
    to lazy-load `Scanner.pm` before resolving default deps or delegating into the scanner owner path.
- Preserved behavior:
  - contract scanning still routes through `LinkedSpec::ActionIR::Scanner::scan_contract_ir_events(...)`,
  - the existing scanner default dep map remains intact,
  - return-bare helper extraction stays unchanged after the owner-module lazy load.
- Updated focused regression coverage:
  - added `action_rewriter_require_avoids_scanner_load_until_scan_helper`.

## Validation
- Ran:
  - `perl -Iperl -c perl/LinkedSpec/ActionRewriter.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=192`)
## 2026-03-12 - Phase 1A Slice: Lazy-Load `Diagnostics` Through `ActionRewriter`
## Summary
Reduced internal ActionIR load-time coupling again by making `LinkedSpec::ActionRewriter` load `ActionIR::Diagnostics` only when diagnostics helpers actually run, so require-only consumers of `ActionRewriter.pm` no longer import the diagnostics collector up front.

## Changed Files
- Updated: `perl/LinkedSpec/ActionRewriter.pm`
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `USER_GUIDE.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`

## Technical Details
- Refactored ActionRewriter owner loading:
  - removed eager `use LinkedSpec::ActionIR::Diagnostics ();`,
  - added `LinkedSpec::ActionRewriter::_require_diagnostics_pkg(...)`,
  - updated `_diagnostics_deps(...)`, `_find_unresolved_action_helpers(...)`,
    `_collect_action_helper_ir_nodes(...)`, and `_accumulate_action_rewrite_diagnostics(...)`
    to lazy-load `Diagnostics.pm` before delegating into diagnostics helpers.
- Preserved behavior:
  - unresolved-helper counting and helper-IR collection are unchanged,
  - downstream rewrite-pipeline and canonical-event accumulation paths still receive the same diagnostics payloads,
  - require-only ActionRewriter consumers keep a narrower owner-module surface.
- Updated focused regression coverage:
  - added `action_rewriter_require_avoids_diagnostics_load_until_diag_helper`.

## Validation
- Ran:
  - `perl -Iperl -c perl/LinkedSpec/ActionRewriter.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=191`)
## 2026-03-12 - Phase 1A Slice: Lazy-Load `CanonicalEvents` Through `ActionRewriter`
## Summary
Reduced internal ActionIR load-time coupling again by making `LinkedSpec::ActionRewriter` load `ActionIR::CanonicalEvents` only when canonical-event helpers actually run, so require-only consumers of `ActionRewriter.pm` no longer import that owner module up front.

## Changed Files
- Updated: `perl/LinkedSpec/ActionRewriter.pm`
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `USER_GUIDE.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`

## Technical Details
- Refactored ActionRewriter owner loading:
  - removed eager `use LinkedSpec::ActionIR::CanonicalEvents ();`,
  - added `LinkedSpec::ActionRewriter::_require_canonical_events_pkg(...)`,
  - updated `_canonical_event_deps(...)`, `_canonicalize_helper_action_ir_event(...)`,
    and `_build_canonical_action_ir_events(...)` to lazy-load `CanonicalEvents.pm`
    before delegating into canonical-event helpers.
- Preserved behavior:
  - canonical-event classification and fallback counting are unchanged,
  - downstream rewrite-pipeline and diagnostics paths still receive the same canonical-event payloads,
  - require-only ActionRewriter consumers keep a narrower owner-module surface.
- Updated focused regression coverage:
  - added `action_rewriter_require_avoids_canonical_events_load_until_canonical_build`.

## Validation
- Ran:
  - `perl -Iperl -c perl/LinkedSpec/ActionRewriter.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=190`)
## 2026-03-12 - Phase 1A Slice: Lazy-Load `MethodExpr` Through `ActionRewriter`
## Summary
Reduced internal ActionIR load-time coupling again by making `LinkedSpec::ActionRewriter` load `ActionIR::MethodExpr` only when method-expression helpers actually run, so require-only consumers of `ActionRewriter.pm` no longer import the method-expression parser up front.

## Changed Files
- Updated: `perl/LinkedSpec/ActionRewriter.pm`
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `USER_GUIDE.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`

## Technical Details
- Refactored ActionRewriter owner loading:
  - removed eager `use LinkedSpec::ActionIR::MethodExpr ();`,
  - added `LinkedSpec::ActionRewriter::_require_pkg(...)`,
  - added `LinkedSpec::ActionRewriter::_require_method_expr_pkg(...)`,
  - updated `_parse_method_function_expr(...)`, `_is_bare_method_scope_token(...)`,
    `_normalize_method_args_with_optional_scope(...)`, and `_split_top_level_csv(...)`
    to lazy-load `MethodExpr.pm` before delegating,
  - updated `_scan_contract_ir_event_deps(...)` so scanner dep resolution also loads
    `MethodExpr.pm` before `ActionIR::Scanner` resolves its direct method-expression callbacks.
- Preserved behavior:
  - method-expression parsing and arity normalization are unchanged,
  - downstream lowering that relies on method-expression helpers still receives the same parsed method/arg structures,
  - `LinkedSpec::Deps` remains unloaded for require-only ActionRewriter consumers.
- Updated focused regression coverage:
  - updated `action_rewriter_require_avoids_linkedspec_deps_load`,
  - added `action_rewriter_require_avoids_method_expr_load_until_parse_helper`.

## Validation
- Ran:
  - `perl -Iperl -c perl/LinkedSpec/ActionRewriter.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=189`)
## 2026-03-12 - Phase 1A Slice: Lazy-Load Scanner Rule Packages Through `ActionIR::ScannerCore`
## Summary
Reduced internal ActionIR load-time coupling again by making `LinkedSpec::ActionIR::ScannerCore` load its scanner rule packages only when contract scanning actually runs, so require-only consumers of `ActionIR::ScannerCore.pm` no longer import the rule tables up front.

## Changed Files
- Updated: `perl/LinkedSpec/ActionIR/ScannerCore.pm`
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `USER_GUIDE.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`

## Technical Details
- Refactored scanner-core owner loading:
  - removed eager imports of `LinkedSpec::ActionIR::Scanner::PrimitiveBasicRules`,
    `PrimitivePipelineRules`, `FlowRules`, and `LegacyRules`,
  - added `LinkedSpec::ActionIR::ScannerCore::_require_pkg(...)`,
  - updated `_scanner_dispatchers(...)` to lazy-load the scanner rule packages before returning dispatcher coderefs.
- Preserved behavior:
  - scanner-core dependency rebinding still routes through the same owner helper,
  - rule dispatch order is unchanged,
  - scanned helper payload extraction is unchanged for existing contracts.
- Updated focused regression coverage:
  - added `actionir_scannercore_require_avoids_scanner_rule_load_until_scan`.

## Validation
- Ran:
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/ScannerCore.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=188`)
## 2026-03-12 - Phase 1A Slice: Lazy-Load `StatementSplit::Mode` Through `ActionIR::StatementSplit::Core`
## Summary
Reduced internal ActionIR load-time coupling again by making `LinkedSpec::ActionIR::StatementSplit::Core` load `StatementSplit::Mode` only when statement splitting actually runs, so require-only consumers of `ActionIR::StatementSplit::Core.pm` no longer import the quote/comment mode-state engine up front.

## Changed Files
- Updated: `perl/LinkedSpec/ActionIR/StatementSplit/Core.pm`
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `USER_GUIDE.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`

## Technical Details
- Refactored statement-split core owner loading:
  - removed eager `use LinkedSpec::ActionIR::StatementSplit::Mode ();`,
  - added `LinkedSpec::ActionIR::StatementSplit::Core::_require_pkg(...)`,
  - added `LinkedSpec::ActionIR::StatementSplit::Core::_require_statement_split_mode_pkg(...)`,
  - updated `split_action_ir_statements(...)` to lazy-load `StatementSplit::Mode.pm` before delegating into the quote/comment mode helpers.
- Preserved behavior:
  - statement splitting still preserves current balanced-delimiter and quote/comment handling,
  - split output for canonical semicolon-delimited statements is unchanged,
  - downstream `StatementSplit` and `ActionRewriter` usage inherit the narrower load surface automatically.
- Updated focused regression coverage:
  - added `actionir_statement_split_core_require_avoids_mode_load_until_split`.

## Validation
- Ran:
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/StatementSplit/Core.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=187`)
## 2026-03-12 - Phase 1A Slice: Lazy-Load `CanonicalEvents::Core` Through `ActionIR::CanonicalEvents`
## Summary
Reduced internal ActionIR load-time coupling again by making `LinkedSpec::ActionIR::CanonicalEvents` load `CanonicalEvents::Core` only when canonical-event building actually runs, so require-only consumers of `ActionIR::CanonicalEvents.pm` no longer import the canonical-event classification engine up front.

## Changed Files
- Updated: `perl/LinkedSpec/ActionIR/CanonicalEvents.pm`
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `USER_GUIDE.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`

## Technical Details
- Refactored canonical-event owner loading:
  - removed eager `use LinkedSpec::ActionIR::CanonicalEvents::Core ();`,
  - added `LinkedSpec::ActionIR::CanonicalEvents::_require_pkg(...)`,
  - added `LinkedSpec::ActionIR::CanonicalEvents::_require_canonical_events_core_pkg(...)`,
  - updated `_canonicalize_helper_action_ir_event(...)` to lazy-load `CanonicalEvents::Core.pm` before delegating.
- Preserved behavior:
  - canonical-event normalization still classifies helper contracts the same way,
  - fallback raw-statement handling remains unchanged,
  - downstream `ActionRewriter` usage inherits the narrower load surface automatically.
- Updated focused regression coverage:
  - added `actionir_canonical_events_require_avoids_core_load_until_build`.

## Validation
- Ran:
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/CanonicalEvents.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=186`)
## 2026-03-12 - Phase 1A Slice: Lazy-Load `StatementSplit::Core` Through `ActionIR::StatementSplit`
## Summary
Reduced internal ActionIR load-time coupling again by making `LinkedSpec::ActionIR::StatementSplit` load `StatementSplit::Core` only when statement splitting actually runs, so require-only consumers of `ActionIR::StatementSplit.pm` no longer import the statement-splitting engine up front.

## Changed Files
- Updated: `perl/LinkedSpec/ActionIR/StatementSplit.pm`
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `USER_GUIDE.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`

## Technical Details
- Refactored statement-split owner loading:
  - removed eager `use LinkedSpec::ActionIR::StatementSplit::Core ();`,
  - added `LinkedSpec::ActionIR::StatementSplit::_require_pkg(...)`,
  - added `LinkedSpec::ActionIR::StatementSplit::_require_statement_split_core_pkg(...)`,
  - updated `_split_action_ir_statements(...)` to lazy-load `StatementSplit::Core.pm` before delegating.
- Preserved behavior:
  - statement splitting still uses the same injected trim callback,
  - split output remains unchanged for canonical semicolon-delimited statements,
  - downstream `ActionRewriter` usage inherits the narrower load surface automatically.
- Updated focused regression coverage:
  - added `actionir_statement_split_require_avoids_core_load_until_split`.

## Validation
- Ran:
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/StatementSplit.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=185`)
## 2026-03-12 - Phase 1A Slice: Lazy-Load `ScannerCore` Through `ActionIR::Scanner`
## Summary
Reduced internal ActionIR load-time coupling again by making `LinkedSpec::ActionIR::Scanner` load `ScannerCore` only when contract scanning actually runs, so require-only consumers of `ActionIR::Scanner.pm` no longer import the scanner-core rule dispatcher up front.

## Changed Files
- Updated: `perl/LinkedSpec/ActionIR/Scanner.pm`
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `USER_GUIDE.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`

## Technical Details
- Refactored scanner owner loading:
  - removed eager `use LinkedSpec::ActionIR::ScannerCore ();`,
  - added `LinkedSpec::ActionIR::Scanner::_require_pkg(...)`,
  - added `LinkedSpec::ActionIR::Scanner::_require_scanner_core_pkg(...)`,
  - updated `scan_contract_ir_events(...)` to lazy-load `ScannerCore.pm` before delegating.
- Preserved behavior:
  - injected scanner deps are unchanged,
  - scanner event extraction still returns the same event payloads,
  - downstream `ActionRewriter` usage inherits the narrower load surface automatically.
- Updated focused regression coverage:
  - added `actionir_scanner_require_avoids_scannercore_load_until_scan`.

## Validation
- Ran:
  - `perl -Iperl -c perl/LinkedSpec/ActionIR/Scanner.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=184`)
## 2026-03-12 - Phase 1A Slice: Lazy-Load `BootstrapSpec::Core` Through `BootstrapSpec`
## Summary
Reduced internal bootstrap-grammar load-time coupling again by making `LinkedSpec::BootstrapSpec` load `BootstrapSpec::Core` only when bootstrap grammar state is actually requested, so require-only consumers of `BootstrapSpec.pm` no longer import the hardcoded grammar builder up front.

## Changed Files
- Updated: `perl/LinkedSpec/BootstrapSpec.pm`
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `USER_GUIDE.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`

## Technical Details
- Refactored bootstrap owner loading:
  - removed eager `use LinkedSpec::BootstrapSpec::Core ();`,
  - added `LinkedSpec::BootstrapSpec::_require_pkg(...)`,
  - added `LinkedSpec::BootstrapSpec::_require_bootstrap_core_pkg(...)`,
  - updated `build_bootstrap_spec(...)` to lazy-load `BootstrapSpec::Core` before delegating into the hardcoded grammar builder.
- Preserved behavior:
  - cached bootstrap state still builds once and remains shared,
  - `run_bootstrap_parse(...)` still succeeds with the same default bootstrap state path,
  - downstream compiler/runtime entrypoints inherit the narrower bootstrap load surface automatically.
- Updated focused regression coverage:
  - added `bootstrap_spec_require_avoids_core_load_until_bootstrap_state_build`.

## Validation
- Ran:
  - `perl -Iperl -c perl/LinkedSpec/BootstrapSpec.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=183`)
## 2026-03-12 - Phase 1A Slice: Lazy-Load `EmitContext` Through `RuleIR`
## Summary
Reduced internal staged-rule-compilation load-time coupling again by making `LinkedSpec::RuleIR` load `RuleIR::EmitContext` only when rule-IR normalization or emit-context assembly actually runs, so require-only consumers of `RuleIR.pm` no longer import the emit-context stage up front.

## Changed Files
- Updated: `perl/LinkedSpec/RuleIR.pm`
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `USER_GUIDE.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`

## Technical Details
- Refactored RuleIR owner loading:
  - removed eager `use LinkedSpec::RuleIR::EmitContext ();`,
  - added `LinkedSpec::RuleIR::_require_pkg(...)`,
  - added `LinkedSpec::RuleIR::_require_emit_context_pkg(...)`,
  - updated `_normalize_rule_code_chunks(...)` and `_build_rule_ir_emit_context(...)` to lazy-load `EmitContext.pm` before delegating.
- Preserved behavior:
  - rule-IR validation and metadata planning stay unchanged,
  - emit-context assembly still returns the same normalized ACODE/GDATA/action-rewriter metadata payloads,
  - downstream `SpecEntry` compilation inherits the narrower load surface automatically.
- Updated focused regression coverage:
  - added `ruleir_require_avoids_emit_context_load_until_emit_context_build`.

## Validation
- Ran:
  - `perl -Iperl -c perl/LinkedSpec/RuleIR.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
- Result:
  - syntax OK
  - PASS (`Files=1, Tests=182`)
## 2026-03-12 - Phase 1A Slice: Lazy-Load `RuleIR` Through `SpecEntry`
## Summary
Reduced internal rule-compilation load-time coupling again by making `LinkedSpec::SpecEntry` load `RuleIR` only when `compile_spec_entry(...)` actually runs, so require-only consumers of `SpecEntry.pm` no longer import the staged rule-IR pipeline up front.

## Changed Files
- Updated: `perl/LinkedSpec/SpecEntry.pm`
- Updated: `t/phase0_regression.t`
- Updated: `ROADMAP.md`
- Updated: `USER_GUIDE.md`
- Updated: `CHANGES.md`
- Updated: `DEVELOPMENT_NOTES.md`
- Updated: `MEMORY.md`

## Technical Details
- Refactored spec-entry owner loading:
  - removed eager `use LinkedSpec::RuleIR ();`,
  - added `LinkedSpec::SpecEntry::_require_pkg(...)`,
  - added `LinkedSpec::SpecEntry::_require_rule_ir_pkg(...)`,
  - updated `compile_spec_entry(...)` to lazy-load `RuleIR.pm` before staged rule-IR collection/planning/validation/emission.
- Preserved behavior:
  - `compile_spec_entry(...)` still returns the same `(label, rule_info)` output,
  - injected runtime-context handling is unchanged,
  - downstream compiler/runtime entrypoints inherit the narrower load surface automatically.
- Updated focused regression coverage:
  - added `spec_entry_require_avoids_ruleir_load_until_compile_spec_entry`.

## Validation
- Ran:
  - `perl -Iperl -c perl/LinkedSpec/SpecEntry.pm`
  - `perl -c -Iperl t/phase0_regression.t`
  - `bash tools/run_ci_local.sh`
