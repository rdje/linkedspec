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
  - "how does Julia keep loaded gap metadata from leaking absolute paths"
date: 2026-08-15
status: authored/static/compiled Julia metadata implemented behind dormancy; Julia runtime remains pending at gap rollout 4 complete / 5 pending
tags: [julia, capture, segmentation, named-slots, recognition, source-location, generated-source, emitted-source, primary, plan]
evidence: "INTER-MATCH-GAP-CAPTURE.5.1 implements defaulted SpecFile.source_id through ordinary/staged/loaded/JSON/private-primary parsing; pinned-Unicode named/anonymous declarations; unindexed/numeric/named selector authorship; dedicated capture_gaps syntax and exact static diagnostics; compiled slot/directive/five-field edge provenance; legacy descriptor non-widening; and a 105-assertion permanent consumer guarded by ten Julia dormancy mutations. The complete Julia package is green, storage remains exactly 19 temp owners / 5 packages, and absolute loaded requests reduce to relocatable logical basenames. Runtime/accessors, rollout 4/5/57, generated format 2, and outward surfaces remain unchanged."
reverify: "bash tools/run_julia_project_data.sh --project=julia --startup-file=no --history-file=no -e 'include(\"julia/test/inter_match_gap_capture_contract_test.jl\")' && bash tools/run_python_project_data.sh tools/check_inter_match_gap_capture_contract.py && bash tools/check_inter_match_gap_capture_six_runtime.sh && bash tools/run_julia_local.sh"
---

# Julia inter-match gap implementation plan

`INTER-MATCH-GAP-CAPTURE.5.0` is behavior-free. It confirms that Julia currently accepts numeric selectors but
treats named declarations, named selectors, and `@capture_gaps` as raw invalid rule-body syntax. The four future
accessors parse as ordinary action calls and fail at runtime with structured `unknown_helper` diagnostics. A
legacy `@move_pos` member survives as a split-marker body element but has no compiled metadata or native execution
effect. The existing primary adapter likewise reports parser compilation failure for the complete future syntax.

## Implemented `.5.1` metadata boundary

Julia now accepts spacing-insensitive named regex declarations beside anonymous declarations in one authored
order. Slot identity reuses the generated pinned Unicode-17 scanner without normalization or case folding;
ASCII-digit-only names remain reserved for numeric selectors. Action-edge AST and compiled state preserve
unindexed, numeric, named, and malformed authored selectors, while compilation resolves the exact target index
and nullable stable name. A dedicated directive body kind retains `@capture_gaps` and validates duplicate,
ineligible ownership/mode, and anonymous legacy-marker boundaries before generic mixed-edge diagnostics.

`SpecFile.source_id` is the single logical static-source carrier. It defaults to `inline` for legacy constructors
and JSON, survives both staged layers and private primary parsing, and supplies every slot/directive/edge row and
portable diagnostic. Loaded relative requests retain their caller spelling; absolute host requests reduce to the
basename. The complete Julia gate exposed the otherwise-hidden risk that compiled metadata would persist a
scratch absolute path; the corrected production loader now keeps the established compiled/descriptor path-opacity
contract while retaining logical source provenance.

The final consumer is permanent but mechanically dormant. Explicit execution passes 105 assertions. It is not
included by ordinary package discovery, canonical CI, or the rooted recurring driver, and the Julia facade gains
no gap token. Ten reason-checked mutations independently reject consumer identity, metadata role, contract source,
parse/validation/compiler seam, diagnostic, discovery, rooted-execution, and facade drift. Storage stays at the
pre-emitted boundary of 19 temporary-workspace owners and five locked package trees; `.5.4` still exclusively owns
the planned 19→20 transition.

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
