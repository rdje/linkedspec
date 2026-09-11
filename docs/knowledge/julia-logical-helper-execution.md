---
id: julia-logical-helper-execution
title: Julia consumes the typed eager logical-helper contract through one truth seam
answers:
  - does Julia support and or not helpers
  - are Julia LinkedSpec logical helpers short circuit
  - what arity do Julia and or not accept
  - do Julia logical arity failures run operands
  - what is Julia LinkedSpec truthiness
  - are Julia empty arrays and hashes truthful
  - do generated Julia logical helpers match native execution
  - which Julia test consumes the neutral logical helper contract
  - what does FUTURE-PARITY-BACKLOG.5.2.5 prove
  - which Julia portmap fixtures pass after logical helpers
  - why did Julia portmap_constant fail after its first logical implementation
date: 2026-07-17
status: current
tags: [julia, runtime, logical, truthiness, arity, generated-source, primary-cli, corpus, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.5.2.5 preserves Julia's _runtime_truthy helper/control seam and eager once-only left-to-right pure-helper evaluation, then adds direct pre-effect arity for one-plus and/or and exact-one not. The exact 177-assertion neutral consumer covers 17 typed truth rows, values, effects, receiver/lazy controls, four invalid calls, native, normalized, generated-plan, primary, and independently compiled emitted modules. Full package proof passes 1,671 assertions, primary and shared CLI conformance, and corpus 105/105; canonical local CI passes Phase 0 1..1031/607s plus the optional complete Julia gate. Generated/primary .5.2.7, recurring admission .5.2.8, and public no-drift .5.2.9 have since closed the shared ledger at 8 complete / 0 pending."
evidence_prior_2026_07_10: "JULIA-BACKEND-PARITY.6.2.4.2.1 first added eager and/or/not through _runtime_truthy with legacy empty false/false/true results. Four portmap/tablegrep fixtures passed; the remaining portmap_constant failure was separately root-caused to unsupported Regex flag o and later repaired."
reverify: "bash tools/run_julia_local.sh && bash tools/run_python_project_data.sh tools/check_logical_helper_contract.py"
---

Julia executes `and`, `or`, and `not` as ordinary eager boolean value helpers. `_runtime_truthy` is the single
typed policy used by those helpers and by lazy conditions:

- `nothing`, false, numeric zero, empty strings, empty arrays, and empty hashes are false;
- nonzero numbers, every nonempty string, and nonempty aggregates are true;
- an inert typed codeblock is true without invocation.

The original codeblock truthiness row was proven with a parsed `ActionBlock` at the runtime boundary. Julia now
also constructs exact inert callable-codeblock literals under `FUTURE-PARITY-BACKLOG.11.6.1`; construction did
not by itself imply dynamic invocation; the later `.11.6.2` implementation is now
current, with the separate callback-identity gap owned by Julia startup `.2.8`.

Direct call dispatch preserves static precedence by resolving registered user functions first. For built-in
logical calls it then validates one-plus positional `and`/`or` and exact-one positional `not` before evaluating
any operand. Invalid calls throw `helper_arity_mismatch` with optional structured `code`, `helper_name`,
`actual_arity`, and `expected_arity` fields. Valid operands retain the existing eager once-only left-to-right
collection and real boolean composition. `if`, `switch`, and `while` share truthiness but remain branch/body-lazy.

`julia/test/logical_helper_contract_test.jl` consumes the unchanged neutral JSON across native compiled,
emitted-payload reconstruction, generated-plan, primary, and independently compiled emitted-module roles.
Unrelated diagnostics, generated source attribution, trace, and primary failure text remain unchanged. Canonical
local CI passes reference CLI 62x2, Phase 0 `1..1031` in 607 seconds, and the optional complete Julia gate.
Generated/primary `.5.2.7`, recurring admission `.5.2.8`, and public no-drift `.5.2.9` make this role part of the
closed 8 complete / 0 pending shared proof.

The earlier Julia-local logical slice also closed `portmap_bare`, `portmap_bit`, `portmap_concatenation`, and
`tablegrep_simple_term`. Its `portmap_constant` residual was not logical evaluation: direct compiled capture and
trace probes isolated Perl's compile-once Regex flag `o`, which a later dedicated bridge normalized.

Related facts: [[logical-helper-neutral-contract]], [[logical-helper-five-backend-audit]],
[[cross-backend-condition-truthiness-drift]], [[julia-generated-source-scaffold]],
[[julia-helper-regex-flag-normalization]], [[julia-callable-codeblock-literal-state]].

## 2026-09-11 — current truth seam reading

Julia .1.18 reads _runtime_truthy: null, false, numeric zero and empty string/array/
hash are false; other values are true. Eager helper semantics remain separate from
lazy control selection. The current neutral consumer passes232 assertions;
neutral governance remains8/0 with26 drift mutations. Exact focused replay is in
[[julia-runtime-cursor-boundary-helpers]]. No logical contract change is made.

## 2026-09-11 — consumer prefix reading at Julia .1.35

Lines1-196 of `julia/test/logical_helper_contract_test.jl` are physically read:
196 fragments /7,009 baseline-identical bytes, raw SHA-256
cc7748291c7221d01794b9eeaba2268abce51c75d654f971ee22034ec6a6d19c.
Source after196 remains unread. This prefix loads the neutral authority, reconstructs
normalized SpecFile JSON from emitted payloads, maps typed truth values, checks exact
native/generated arity diagnostics, routes primary execution and prepares an offline
emitted host. Its codeblock truth row explicitly constructs an ActionBlock with a
failing body; it does not itself construct a callable literal. This is the historical
representation qualification already stated above, not a newly found runtime defect.

The complete consumer freshly passes232 assertions as focused compatibility proof;
execution of its suffix grants no physical reading credit. Together with the complete
gap consumer319, this slice passes551 assertions. Neutral logical governance remains
17 truth rows /10 helper rows /3 effect rows,8 complete /0 pending,19 public documents,
14 stale-current denials and26 mutations. No full backend/canonical gate or dependency
build runs. All prior repair owners and source contracts remain unchanged.

```bash
bash tools/run_julia_project_data.sh --project=julia --startup-file=no --history-file=no - <<'JULIA_GROUP35_EXISTING'
using LinkedSpecJulia,JSON3,Test
const REPO_ROOT=pwd()
include("julia/test/inter_match_gap_capture_contract_test.jl")
include("julia/test/logical_helper_contract_test.jl")
JULIA_GROUP35_EXISTING
bash tools/run_python_project_data.sh tools/check_inter_match_gap_capture_contract.py
bash tools/run_python_project_data.sh tools/check_logical_helper_contract.py
```

## 2026-09-11 — consumer completion at Julia .1.36

Logical-helper197-387 completes the source:191 fragments /6,927 baseline-identical
bytes, raw SHA75993c371ca6f55849683fed70613a84f135a65d017b9939b25be7e1f2d4da89.
Every invalid-arity row exercises native, normalized and generated direct/traced
routes with exact structured failure and pre-effect checks, plus primary exit/text.
The separate offline emitted host loads three positive modules and the not-many
negative module, checks direct/traced equality and positive source identities,
and verifies matching generated errors without operand effects. This is narrower
than claiming every invalid row has its own emitted module. The earlier ActionBlock
truth-row qualification remains. The complete group replay is in
[[julia-mcp-implementation-admission]]; no production or logical contract changes.
