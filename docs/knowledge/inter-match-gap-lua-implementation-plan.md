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
status: authored/static/compiled metadata implemented under .6.1; live PUC Lua and LuaJIT rollout remains pending at 5 complete / 4 pending
tags: [lua, luajit, capture, segmentation, named-slots, recognition, source-location, generated-source, emitted-source, primary, plan]
evidence: "INTER-MATCH-GAP-CAPTURE.6.1 implements one shared PUC-Lua/LuaJIT authored/static/compiled path: SpecFile.source_id defaults to inline and retains path-opaque caller identity through direct/staged/loaded/normalized/emitted carriers; named/anonymous declarations reuse the pinned Unicode-17 scanner; selectors and the dedicated directive retain provenance; compiled JSON adds slot/directive/five-field identity while descriptors and legacy refs stay unchanged. The explicit dormant consumer passes 178 assertions per ABI and ten checker mutations keep ordinary/canonical/rooted execution absent. Complete Lua remains 177 tests per ABI, primary 66, corpus 105, storage 18 owners/three native modules; gap stays 5/4/58."
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

## Current `.6.1` boundary

The first implementation leaf is complete. `SpecFile.source_id` is the sole logical static-source carrier and
defaults to `inline` for legacy constructors/JSON. Direct parsing, both staged layers, normalized JSON, and the
effective spec embedded by source emission retain it. A relative loaded request retains caller spelling; an
absolute request reduces to its basename, so resolved repository or scratch paths cannot leak into compiled
provenance.

Named and anonymous regex declarations now share one authored order on both Lua ABIs. The parser retains
unindexed, numeric, named, and malformed selector authorship; validation resolves names exactly and reports the
neutral source-aware declaration, selector, directive, eligibility, and legacy-conflict boundaries. Compiled
rule JSON adds ordered slot rows and nullable directive evidence, while compiled edge JSON adds the five-field
selector identity. Descriptor action edges, `resolved_edges`, `{label,idx}` dependency refs, rule-slot events,
generated format 2, and `{label,family}` plans stay byte/shape compatible.

The final consumer exists at its permanent path and passes 178 assertions on both PUC Lua and LuaJIT when called
explicitly. Ten checker-local dormancy mutations require its identity and metadata boundaries while proving it is
absent from ordinary Lua discovery, canonical CI, both rooted runtime routes, and the public facade. Live gap
state and accessors remain unimplemented until `.6.2`; neither Lua rollout row is admitted.

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
