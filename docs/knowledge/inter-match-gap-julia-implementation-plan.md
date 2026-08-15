---
id: inter-match-gap-julia-implementation-plan
title: Julia inter-match gap capture extends existing recognition and source authorities in five implementation leaves
answers:
  - "how will Julia implement inter match gap capture"
  - "which Julia task implements named regex slots and capture_gaps"
  - "where does Julia gap state belong"
  - "does Julia gap capture widen RecognitionFrameState"
  - "when must Julia select a match relative to LS for capture_gaps"
  - "how does Julia convert UTF-8 code unit registers to gap scalar spans"
  - "what carries Julia gap metadata through reconstruction"
  - "does the Julia generated plan change for capture_gaps"
  - "which Julia descriptor fields will expose gap metadata"
  - "how will emitted Julia gap execution be proved"
  - "how many Julia temporary workspace owners are expected after emitted gap proof"
  - "which Julia primary command implements capture_gaps"
  - "what are the Julia gap admission roles"
  - "how does Julia gap admission change rollout and mutations"
  - "is Julia capture_gaps implemented now"
date: 2026-08-15
status: behavior-free implementation plan frozen; Julia runtime remains pending at gap rollout 4 complete / 5 pending
tags: [julia, capture, segmentation, named-slots, recognition, source-location, generated-source, emitted-source, primary, plan]
evidence: "INTER-MATCH-GAP-CAPTURE.5.0 probes current Julia numeric selector success; raw-invalid named declarations/selectors and capture_gaps; unknown-helper entry_slot/gap_span/gap_text/gap_kind failures; LS-before-selection repeated execution; normalized SpecFile JSON, descriptor and generated-v2 seams; the existing recognition invocation/token and immutable SourceAuthority; the existing primary adapter; and repository storage at 19 temp owners / 5 packages. It freezes .5.1-.5.5 without changing code, runtime, rollout 4/5/57, generated format 2, or outward surfaces."
reverify: "bash tools/run_python_project_data.sh tools/check_inter_match_gap_capture_contract.py && bash tools/check_inter_match_gap_capture_six_runtime.sh && bash tools/run_julia_project_data.sh --project=julia -e 'using LinkedSpecJulia, JSON3, Test; const REPO_ROOT=pwd(); include(\"julia/test/duplicate_regex_slot_identity_contract_test.jl\"); include(\"julia/test/rule_local_cursor_contract_test.jl\"); include(\"julia/test/recognition_transaction_contract_test.jl\"); include(\"julia/test/typed_source_location_contract_test.jl\"); include(\"julia/test/source_emitter_test.jl\")' && bash tools/check_julia_primary_cli.sh && bash tools/test_julia_project_data_storage.sh"
---

# Julia inter-match gap implementation plan

`INTER-MATCH-GAP-CAPTURE.5.0` is behavior-free. It confirms that Julia currently accepts numeric selectors but
treats named declarations, named selectors, and `@capture_gaps` as raw invalid rule-body syntax. The four future
accessors parse as ordinary action calls and fail at runtime with structured `unknown_helper` diagnostics. A
legacy `@move_pos` member survives as a split-marker body element but has no compiled metadata or native execution
effect. The existing primary adapter likewise reports parser compilation failure for the complete future syntax.

The repeated-rule trace establishes the lifecycle constraint: Julia currently runs enclosing `LS` before it
selects the next candidate. Capture-enabled rules alone must preselect and install their candidate before `LS` so
that gap context is visible there; unflagged rules retain their current ordering.

## Five dependency-ordered leaves

1. `.5.1` adds authored/static/compiled identity. `SpecFile` gains a defaulted logical `source_id`; named and
   anonymous regex declarations share one order through the pinned Unicode-17 label scanner; all-digit names are
   rejected; unindexed/numeric/named selector provenance and the dedicated directive survive compilation. The
   exact nine static diagnostics are source-aware. The permanent final consumer is created at
   `julia/test/inter_match_gap_capture_contract_test.jl` but ten checker-local mutations keep it absent from
   ordinary, canonical, and rooted execution.
2. `.5.2` extends only the private recognition authority. The existing invocation/token owns activation,
   immutable input and invocation identity, detached entry identity, committed gap cursor, accepted-edge count,
   and current gap. Token rollback restores mutable gap state. Detached `RecognitionFrameState` remains exactly
   cursor, boundary, and marks; there is no second stack, cursor, or token family. Private zero-argument
   `entry_slot()`, `gap_span()`, `gap_text()`, and `gap_kind()` use existing action dispatch and retain exact
   unavailable-context and cursor-regression diagnostics.
3. `.5.3` uses normalized `SpecFile` JSON as the sole reconstruction carrier and recompiles normally. Descriptor
   rule metadata adds separate fresh `regex_slots`, `capture_gaps`, and five-field `resolved_slot_edges` values,
   preserving legacy `resolved_edges` and `{label,idx}` references. Direct and traced generated execution spend
   the same runtime; source format 2 and ordered `{label,family}` plan rows remain exact.
4. `.5.4` calls `emit_julia_source_v2` and independently loads ten value plus two typed-error modules from one
   repository-routed offline host project. A private writable depot is layered only over the retained repository
   depot and Julia system depots. This exact consumer is expected to advance the Julia temporary-workspace oracle
   from 19 to 20 owners while keeping the five locked package trees and proving complete cleanup.
5. `.5.5` reuses the existing primary CLI adapter, removes dormancy, and executes the nine contract roles exactly
   once: `native_execution`, `ordinary_reconstruction`, `descriptor`, `generated_plan`, `emitted_source`,
   `target_lifecycle`, `recursion_and_rollback`, `portable_diagnostics`, and `primary_command`. Ordinary,
   canonical, and rooted registration are each exact once. Only `julia_runtime` advances, from 4/5/57 to
   5/4/58 by appending `julia_runtime_regression`; ten dormancy mutations become ten admission mutations.

## Existing authorities to preserve

The runtime already owns a private recognition transaction with per-invocation state and token snapshots. Gap
state attaches there, not to a second stack and not to detached observed frame state. Candidate context remains
visible through action, target entry, and enclosing `LE`; an accepted child-extended post-`LE` cursor commits
before `IT`. Successful terminal tails are installed before existing `LX`, `EX`, or `E`; falsey accepted results,
whole-rule returns, failed minimums, rollback, nesting, direct entry, and legacy marker behavior retain their
neutral meanings.

Runtime registers are zero-based UTF-8 code-unit offsets. The current immutable input `SourceAuthority` is the
only permitted bridge to detached Unicode-scalar gap spans and exact text. Static provenance uses the separate
logical spec identity. Generated, descriptor, primary, semantic/MCP, capability, facade/schema/README, public
helper, and typed-source outward surfaces do not gain authority during the private rollout.

## Links

- Neutral contract and current rollout: [[inter-match-gap-executable-contract-plan]]
- Existing Julia transaction authority: [[julia-recognition-transaction-integration]]
- Existing Julia source authority: [[julia-runtime-matching-state]]
- Existing Julia generated-source authority: [[julia-generated-source-v2-rule-local-cursor]]
- Existing Julia storage boundary: [[julia-project-data-ssd-storage]]
- Decision: ADR `0045`
- Task owner: `docs/tasks/INTER-MATCH-GAP-CAPTURE.md`
