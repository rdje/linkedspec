---
id: inter-match-gap-lua-implementation-plan
title: Lua inter-match gap capture extends one dual-ABI recognition authority in five implementation leaves
answers:
  - "how will Lua implement inter match gap capture"
  - "how will LuaJIT implement inter match gap capture"
  - "which Lua task implements named regex slots and capture_gaps"
  - "does capture_gaps use Lua rule slot events"
  - "when must Lua select a match relative to LS for capture_gaps"
  - "where does Lua gap state belong"
  - "does Lua gap capture widen detached recognition frame state"
  - "how does Lua carry logical spec source identity"
  - "what carries Lua gap metadata through normalized reconstruction"
  - "does the Lua generated plan change for capture_gaps"
  - "which Lua descriptor fields will expose gap metadata"
  - "how will emitted Lua gap execution be proved"
  - "how many Lua temporary workspace owners are expected after emitted gap proof"
  - "which Lua primary command implements capture_gaps"
  - "what are the Lua gap admission roles"
  - "how does Lua gap admission change rollout and mutations"
  - "is Lua capture_gaps implemented now"
date: 2026-08-16
status: behavior-free implementation plan frozen; PUC Lua and LuaJIT remain pending at gap rollout 5 complete / 4 pending
tags: [lua, luajit, capture, segmentation, named-slots, recognition, source-location, generated-source, emitted-source, primary, plan]
evidence: "INTER-MATCH-GAP-CAPTURE.6.0 proves identical PUC-Lua/LuaJIT baselines: numeric Rule[0] works; named declarations/selectors and capture_gaps are raw invalid body syntax; entry_slot/gap_span/gap_text/gap_kind are unsupported runtime helpers; legacy rule-slot events fire after an accepted edge action and before LE; repeated execution performs LS before selection; normalized SpecFile JSON, descriptors, generated-v2 emission, recognition invocation/token state, immutable input SourceAuthority, primary CLI, and exact 18-owner dual-ABI storage are reusable. It freezes .6.1-.6.5 without changing Lua behavior, gap rollout 5/4/58, generated format 2, or outward surfaces."
reverify: "bash tools/run_lua_local.sh && bash tools/check_inter_match_gap_capture_six_runtime.sh && bash tools/run_python_project_data.sh tools/check_recognition_transaction_contract.py && bash tools/run_python_project_data.sh tools/check_duplicate_regex_slot_identity_contract.py && perl tools/check_generated_source_contract.pl && bash tools/test_lua_project_data_storage.sh"
---

# Lua inter-match gap implementation plan

`INTER-MATCH-GAP-CAPTURE.6.0` is behavior-free. Repository-routed probes produce the same result on PUC Lua and
LuaJIT: numeric `Rule[0]` selects normally, while named declarations, named selectors, and `@capture_gaps` remain
raw invalid body syntax. The four future accessors parse as ordinary action calls and fail at runtime as
unsupported helpers. The existing primary adapter reports parser compilation failure for the complete future
syntax.

The runtime ordering establishes one critical boundary. Existing anonymous split markers and named `@mark(...)`
compile as rule-slot events attached to the preceding regex index, then fire after its accepted action or target
and before `LE`. That timing is a compatibility contract and cannot expose the candidate during `LS`.
`@capture_gaps` is therefore a dedicated rule-level directive, not a new rule-slot event and not an alias for any
legacy marker. Capture-enabled rules alone preselect and install their candidate before `LS`; unflagged rules
retain their current `LS`-before-selection order.

## Five dependency-ordered leaves

1. `.6.1` adds authored/static/compiled identity and a dormant final consumer. `SpecFile` gains a defaulted
   logical `source_id`; named and anonymous declarations share one authored order through the generated pinned
   Unicode-17 rule-label scanner; ASCII-digit-only names are rejected; selector provenance and the dedicated
   directive survive compilation. The exact nine diagnostics become source-aware. The consumer lives at
   `lua/test/inter_match_gap_capture_contract_test.lua`, while ten checker-local mutations keep it absent from
   ordinary, canonical, and rooted execution on both ABIs.
2. `.6.2` extends only `recognition_transaction_runtime.lua`. Its existing invocation frame owns activation,
   immutable input and invocation identity, detached entry-slot identity, committed gap cursor, accepted-edge
   count, and current gap. Existing token records snapshot the mutable gap members for rollback; the underlying
   detached transaction state remains exactly cursor, boundary, and marks. Private accessors use ordinary action
   dispatch without enlarging the 246-name supported ActionIR inventory. Candidate context spans action/target
   execution and `LE`; child-extended cursor state commits before `IT`; successful tails precede `LX`, `EX`, or
   `E`. There is no second stack, cursor, token family, or ABI-specific path.
3. `.6.3` keeps normalized `SpecFile` JSON as the sole reconstruction carrier and recompiles normally. Descriptor
   rule metadata adds fresh detached `regex_slots`, `capture_gaps`, and five-field `resolved_slot_edges` values,
   preserving legacy `resolved_edges` and `{label,idx}` references. Direct and traced generated execution spend
   the same interpreter; source format 2 and ordered `{label,family}` plan rows remain exact.
4. `.6.4` calls `emit_lua_source_v2` unchanged and independently loads ten value plus two typed-error modules in
   fresh PUC-Lua and LuaJIT child processes. All modules, runners, traces, and cleanup stay below the existing
   repository-routed `TMPDIR`. The exact Lua workspace oracle advances from 18 to 19 owners while its three
   dual-ABI native modules remain exact.
5. `.6.5` reuses the existing primary CLI adapter, removes dormancy, and executes the nine roles exactly once on
   each ABI: `native_execution`, `ordinary_reconstruction`, `descriptor`, `generated_plan`, `emitted_source`,
   `target_lifecycle`, `recursion_and_rollback`, `portable_diagnostics`, and `primary_command`. Ordinary,
   canonical, and rooted registration are each exact once per ABI. Only `puc_lua_runtime` and `luajit_runtime`
   advance, taking governance from 5/4/58 to 7/2/60 by appending their two runtime regressions. Ten dormancy
   mutations become sixteen admission mutations; recurring and public rows remain pending for `.7`.

## Existing authorities to preserve

The current recognition frame/token stack is the sole live-state owner. Nested calls naturally hide the parent
candidate and exact rollback restores the committed cursor, accepted count, and current gap alongside ordinary
cursor/boundary/marks state. Entry-slot identity is passed directly into a child invocation; direct entry uses
`nil`. The immutable input `SourceAuthority` remains the only bridge from zero-based UTF-8 byte registers to
detached Unicode-scalar spans and exact text. Runtime spans retain input source id `input`; static provenance uses
the separate logical spec identity, where inline parsing is `inline` and loaded requests retain a caller-logical,
path-opaque identity.

The emitted module already embeds normalized `SpecFile` JSON as ASCII hex, reconstructs it, recompiles it, and
uses the shared interpreter for direct and traced entrypoints. Gap support therefore needs no production emitter
fork, plan field, ABI branch, or generated-format revision. Facade/schema/MCP/capability/CLI/README surfaces do
not gain gap authority during the private rollout.

## Links

- Neutral contract and current rollout: [[inter-match-gap-executable-contract-plan]]
- Existing Lua rule-slot timing: [[lua-rule-slot-marker-execution]]
- Existing Lua transaction authority: [[lua-recognition-transaction-integration]]
- Existing Lua source authority: [[lua-runtime-matching-state]]
- Existing Lua generated-source authority: [[lua-generated-source-v2-rule-local-cursor]]
- Existing Lua storage boundary: [[lua-project-data-ssd-storage]]
- Decision: ADR `0045`
- Task owner: `docs/tasks/INTER-MATCH-GAP-CAPTURE.md`
