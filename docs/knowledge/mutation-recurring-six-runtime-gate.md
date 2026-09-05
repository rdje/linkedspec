---
id: mutation-recurring-six-runtime-gate
title: "One governed driver recurs both mutation authorities across six runtime routes"
answers:
  - "what is the recurring proof for write vivification and map_leaves bang"
  - "which command runs the mutation six runtime matrix"
  - "which runtime order does the mutation recurring gate use"
  - "how is the mutation matrix registered in canonical CI"
  - "what pins mutation authority digests and route topology"
  - "why does the mutation matrix refresh Dart metadata offline"
date: 2026-09-05
status: recurring six-runtime proof complete under FUTURE-PARITY-BACKLOG.19.8; public closeout remains .19.9
tags: [mutation, autovivification, map-leaves, composition, recurrence, verification, governance, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.19.8 adds executable tools/check_mutation_six_runtime.sh. It enters repository-managed project data; runs the unchanged write authority and bang/composition authority; executes Perl, Rust, Dart, Julia, PUC Lua, and LuaJIT consumers in fixed order; and then validates generated-source, capability, and language-coverage ledgers. tools/check_capability_conformance.pl binds owner, driver, LINKEDSPEC_RUN_MUTATION_MATRIX switch, storage initializer, three historical authority IDs/statuses/canonical JSON digests, exact commands and order, executable path state, and exact-one tools/run_ci_local.sh registration. Seventeen recurring mutations reject authority, route, support, storage, owner, driver, CI, and live-artifact drift. The complete route passes write 5/7/11/16/3/3 plus 8 compositions and 105 mutations; bang 4/14/5/10/8 plus 6 callback and 1 continuation compositions, 167 base and 592 composition mutations; Perl 19; Rust 5+9; Dart 9+11; Julia 406+496; PUC Lua and LuaJIT 438+530 each; generated source 100/0/0; capability 20/100/0/0; and language coverage 250/105+1/126. Canonical CI requires and syntax-checks the driver always and executes it exactly once when the opt-in switch is 1. No production behavior, frozen artifact bytes, public-current content, or parent status changes."
reverify: "bash tools/check_mutation_six_runtime.sh && perl tools/check_capability_conformance.pl && rg -n 'LINKEDSPEC_RUN_MUTATION_MATRIX|check_mutation_six_runtime' tools/run_ci_local.sh"
---

# Recurring mutation proof

Run the complete fail-fast proof from the repository root:

```bash
bash tools/check_mutation_six_runtime.sh
```

The order is part of the contract: both neutral authorities first; Perl; Rust; Dart; Julia; PUC Lua; LuaJIT;
then generated-source, capability, and language-coverage ledgers. The three frozen JSON files retain their original
historical status strings and bytes; later capability and recurrence truth is external and digest-bound.

Canonical CI tracks and syntax-checks the driver on every run. Set `LINKEDSPEC_RUN_MUTATION_MATRIX=1` to execute
it exactly once inside that gate. The driver enters the repository-managed project-data environment before any
toolchain command. Its Dart leg also runs locked `pub get --offline` through the project-data wrapper so ignored
compiler/test metadata agrees with the active SDK without consulting the network or an off-volume cache.

Related: [[mutation-capability-admission]], [[write-vivification-neutral-contract]],
[[map-leaves-mutation-neutral-contract]], [[write-map-leaves-neutral-composition]], and
[[dart-sdk-local-metadata-refresh]].
