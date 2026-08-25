---
id: progressive-span-dispatch-recurring-gate
title: Progressive span dispatch recurrence binds five sources to six private runtime routes
answers:
  - "which command runs progressive span dispatch on all six runtimes"
  - "what does LINKEDSPEC_RUN_PROGRESSIVE_SPAN_MATRIX run"
  - "how do five progressive dispatch sources map to six runtimes"
  - "which support ledgers follow progressive dispatch recurrence"
  - "what does FUTURE-PARITY-BACKLOG.14.6.7 promote"
  - "what is the typed source rollout after progressive recurrence"
  - "does progressive recurrence change public dispatch behavior"
  - "why did the capability guide still say progressive dispatch was 2 of 9"
  - "which commit introduced the stale Perl-only progressive guide paragraph"
date: 2026-08-25
status: current typed recurrence; behavioral recurrence and progressive public no-drift closed by FUTURE-PARITY-BACKLOG.14.6.8
tags: [progressive-parsing, recurring-gate, source-location, perl, rust, dart, julia, lua, luajit, conformance, local-ci]
evidence: "FUTURE-PARITY-BACKLOG.14.6.7 adds tools/check_progressive_span_dispatch_six_runtime.sh. The repository-routed fail-fast driver runs the neutral checker, Perl, cfg-enabled Rust, Dart, Julia, PUC Lua, and LuaJIT in exact order, then typed-source, generated-source, capability, and language ledgers. Five immutable backend source groups form six runtime routes because one shared Lua source executes independently on both ABIs. Twelve topology/storage/rollout mutations plus two stale-projection mutations advance typed governance from 11/3/152 to 12/2/170 and promote only progressive_span_dispatch. Behavioral governance remains 7/9/112; no runtime, consumer, generated format, facade, schema, semantic/MCP, CLI, README, or public behavior moves. Canonical CI requires, audits, and syntax-checks the driver and executes it only when LINKEDSPEC_RUN_PROGRESSIVE_SPAN_MATRIX=1."
root_cause: "git blame assigns the stale capability_conformance/README.md 2/9 and typed-row-pending paragraph to Perl admission commit 78bc66e10066d27ffb93197b8b88e3e9af1d4aa4. Later Rust, Dart, Julia, and Lua admissions updated executable governance but omitted that current guide projection. The typed checker now rejects both stale claims explicitly, preventing the omission from recurring without rewriting dated admission evidence."
evidence_update_2026_08_25_public_closeout: "FUTURE-PARITY-BACKLOG.14.6.8 checker-first proof catches that this committed driver passed while its separately defined behavioral recurring row remained pending. Public closeout binds the unchanged driver to that row, promotes public_no_drift, and closes progressive governance at 9/9/116 plus public 6/12/10/60. Typed truth remains 12/2/170 and all outward/API boundaries remain absent."
last_verified: 2026-08-25
reverify:
  - "bash tools/check_progressive_span_dispatch_six_runtime.sh"
  - "bash tools/run_python_project_data.sh tools/check_typed_source_location_contract.py"
  - "git blame -L 320,327 -- capability_conformance/README.md"
---

# Progressive span-dispatch recurring gate

This layer is orchestration over already-admitted private behavior. It creates no new parser authority or syntax.
The five consumer source groups are Perl, Rust, Dart, Julia, and shared Lua; PUC Lua and LuaJIT execute the same
Lua source independently, producing six ordered runtime routes.

The driver fails fast after neutral, every runtime route, and four surrounding ledgers. Canonical CI keeps the
expensive matrix explicitly opt-in while always requiring, repository-path auditing, and syntax-checking its
tracked driver. Project-data initialization keeps every cache, build, and test artifact on the repository volume.

The original recurrence leaf promoted only typed `progressive_span_dispatch`. Public closeout `.14.6.8` then
corrected the committed driver's stale behavioral recurring row and completed progressive public no-drift,
producing 9/9/116 plus public 6/12/10/60 without runtime or outward movement. Staged dispatch stays `.14.7`-owned,
and combined program-wide public no-drift stays `.14.8`-owned.

Related: [[progressive-span-dispatch-audit-plan]], [[typed-source-location-recurring-gate]],
[[typed-source-location-cursor-algebra-direction]], and ADR `0080`.
