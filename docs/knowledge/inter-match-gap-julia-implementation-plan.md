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
  - "do Julia private gap helpers widen the supported ActionIR call inventory"
  - "how does loaded source identity affect Julia descriptor equality"
  - "which Julia descriptor tests changed for gap metadata"
date: 2026-08-16
status: Julia private gap path admitted through exact nine-role primary composition at gap rollout 5 complete / 4 pending; Lua and public rows remain pending
tags: [julia, capture, segmentation, named-slots, recognition, source-location, generated-source, emitted-source, primary, plan]
evidence: "INTER-MATCH-GAP-CAPTURE.5.1-.5.5 implement and privately admit logical source identity and exact authored/static/compiled provenance; existing-recognition-authority native state/accessors/lifecycle; normalized SpecFile JSON reconstruction; compatible detached descriptors; same-runtime generated-v2 execution; independently loaded emitted direct/traced proof; and the existing primary CLI adapter. The permanent consumer retains 105 metadata + 33 native + 46 carrier + 105 emitted assertions and adds 30 exact admission assertions. Its nine declared roles execute once in order and register once in ordinary Julia discovery, canonical CI, and the rooted route after Dart. Julia alone advances to rollout 5/4/58; ten dormancy mutations become ten admission mutations. Storage stays 20 owners / 5 packages, ActionIR stays 246, and generated format 2 ordered {label,family} remains exact."
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

The final consumer is permanent and admitted. Its retained stages pass 105 metadata, 33 native, 46 carrier, and
105 emitted assertions; its final role ledger adds 30 admission assertions. Ordinary package discovery includes it
once, canonical CI executes it once explicitly, and the rooted recurring driver runs it once after Dart. The Julia
facade still gains no gap token. Ten reason-checked mutations independently reject consumer identity, role-ledger
order, ordinary/canonical/rooted omission or duplication, primary ownership, later-runtime skips, and facade drift.
`.5.4` advanced storage from the pre-emitted 19-owner boundary to exactly 20 temporary-workspace owners while
retaining five package trees; `.5.5` adds no new storage owner.

## Implemented `.5.2` native boundary

The existing recognition invocation/token now owns capture activation, immutable input and invocation identity,
detached selected-entry identity, committed gap cursor, accepted-edge count, and current candidate or tail. Its
existing transaction snapshot restores every mutable gap field on rollback. Detached `RecognitionFrameState`
remains exactly cursor/boundary/marks, so Julia gains no parallel stack, cursor, token, or observed-frame field.

Capture-enabled repetitions alone preselect and install the candidate before `LS`. That candidate remains visible
through the edge action, child target, and `LE`; the child-extended post-`LE` cursor commits before `IT`. Successful
terminal tails are installed before `LX`, `EX`, or `E`. The permanent consumer proves prefix/interstitial/tail and
empty gaps, Unicode scalar spans, falsey and whole-rule results, child cursor extension, entry identity, nesting,
rollback, terminal modes, failed minimums, direct entry, and unchanged legacy behavior.

`entry_slot()`, `gap_span()`, `gap_text()`, and `gap_kind()` are private zero-argument runtime helpers. They are
accepted by the resolver through a dedicated private family and are deliberately absent from the supported
ActionIR call-name inventory. The duplicate-slot matrix caught the first implementation widening that inventory;
the corrected boundary keeps it exactly 246 while retaining exact arity, unavailable-context, and cursor-
regression diagnostics. UTF-8 code-unit registers cross the existing immutable `SourceAuthority` only when a
detached zero-based Unicode-scalar span or text value is requested.

## Implemented `.5.3` carrier boundary

Normalized `SpecFile` JSON is the sole reconstruction carrier and recompiles through the ordinary compiler. Rule
descriptor metadata now returns fresh detached `regex_slots`, nullable `capture_gaps`, and five-field
`resolved_slot_edges` projections. The pre-existing `resolved_edges` shape and `{label,idx}` dependency references
remain byte-for-byte compatible; mutating a returned projection cannot alter compiled state or a later descriptor.

Direct and trace-disabled generated-v2 entrypoints receive that reconstructed `CompiledSpec`, build the unchanged
ordered `{label,family}` plan, and spend the same runtime authority as native execution. The permanent proof covers
values, child-extended cursors, nesting, rollback, unavailable-context and cursor-regression failures, and exact
generated source identity while retaining source format 2.

Descriptor provenance is deliberately logical-source-sensitive. A source parsed inline projects `inline`; the same
text loaded as `descriptor.spec`, `marked.spec`, or `markerless.spec` projects that basename. Complete package proof
therefore corrected two direct dependents: exact rule-meta key inventories now require the three additive fields,
and loaded-vs-inline comparisons rewrite only expected logical source IDs instead of erasing provenance. Runtime
semantics, generated plans, and all legacy descriptor rows remain identical.

## Implemented `.5.4` emitted boundary

The dormant consumer calls `emit_julia_source_v2` without changing production emission. One caller-owned host is
created under the repository-routed temporary root; its private writable depot is layered before the retained
repository depot and Julia system depots, package access is offline, and compiled modules are disabled. Ten value
modules and two typed-error modules are each included into their own fresh host module, then executed through both
direct and traced entrypoints against the native result or diagnostic authority.

The value matrix covers Unicode and empty spans, falsey accepted child payloads, child cursor extension, detached
entry identity, nesting, rollback, exact lifecycle order, terminal/no-match behavior, failed minimum, direct entry,
and unflagged legacy behavior. The error modules retain generated execute stage/code, their emitted source identity,
and the exact native unavailable-context or cursor-regression marker. All twelve trace files retain generated rule
entry and source identity. Recursive cleanup removes the host, private depot, modules, manifest, runner, and traces;
the storage oracle rejects the unregistered owner at 19→20 before accepting this exact twentieth path.

## Implemented `.5.5` primary and admission boundary

The admitted consumer reads Julia's nine-role array from the neutral contract, requires exact declared order and
unique identity, dispatches each role once, and requires the completed set to equal the declared map. The primary
role reuses `run_cli` with the ordinary `--inline-spec` and `--input` options. Input
`alpha, beta | gamma\n- delta` returns four recognized words paired with exact separators `""`, `", "`,
`" | "`, and `"\n- "`; no new command or secondary execution path exists.

Ordinary `julia/test/runtests.jl`, canonical `tools/run_ci_local.sh`, and the rooted recurring driver each register
the consumer exactly once. The rooted order is neutral, Perl, Rust, Dart, Julia, then explicit PUC Lua and LuaJIT
skips. Only `julia_runtime` becomes complete. The semantic ledger appends only
`julia_runtime_regression`, reaching 58; ten Julia admission mutations replace the former ten dormancy mutations.
All facade, schema, semantic/MCP, capability, CLI-manifest, README, later-runtime, and public rows remain unchanged.

## Five dependency-ordered leaves

1. `.5.1` adds authored/static/compiled identity. `SpecFile` gains a defaulted logical `source_id`; named and
   anonymous regex declarations share one order through the pinned Unicode-17 label scanner; all-digit names are
   rejected; unindexed/numeric/named selector provenance and the dedicated directive survive compilation. The
   exact nine static diagnostics are source-aware. The permanent final consumer is created at
   `julia/test/inter_match_gap_capture_contract_test.jl` but ten checker-local mutations keep it absent from
   ordinary, canonical, and rooted execution.
2. `.5.2` extends only the private recognition authority. The existing invocation/token now owns activation,
   immutable input and invocation identity, detached entry identity, committed gap cursor, accepted-edge count,
   and current gap. Token rollback restores mutable gap state. Detached `RecognitionFrameState` remains exactly
   cursor, boundary, and marks; there is no second stack, cursor, or token family. Private zero-argument
   `entry_slot()`, `gap_span()`, `gap_text()`, and `gap_kind()` use existing action dispatch, remain outside the
   supported ActionIR inventory, and retain exact arity, unavailable-context, and cursor-regression diagnostics.
3. `.5.3` uses normalized `SpecFile` JSON as the sole reconstruction carrier and recompiles normally. Descriptor
   rule metadata adds separate fresh `regex_slots`, `capture_gaps`, and five-field `resolved_slot_edges` values,
   preserving legacy `resolved_edges` and `{label,idx}` references. Direct and traced generated execution spend
   the same runtime; source format 2 and ordered `{label,family}` plan rows remain exact. This leaf is complete.
4. `.5.4` calls `emit_julia_source_v2` and independently loads ten value plus two typed-error modules from one
   repository-routed offline host project. A private writable depot is layered only over the retained repository
   depot and Julia system depots. This exact consumer is expected to advance the Julia temporary-workspace oracle
   from 19 to 20 owners while keeping the five locked package trees and proving complete cleanup. This leaf is complete.
5. `.5.5` reuses the existing primary CLI adapter, removes dormancy, and executes the nine contract roles exactly
   once: `native_execution`, `ordinary_reconstruction`, `descriptor`, `generated_plan`, `emitted_source`,
   `target_lifecycle`, `recursion_and_rollback`, `portable_diagnostics`, and `primary_command`. Ordinary,
   canonical, and rooted registration are each exact once. Only `julia_runtime` advances, from 4/5/57 to
   5/4/58 by appending `julia_runtime_regression`; ten dormancy mutations become ten admission mutations. This
   leaf is complete.

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
