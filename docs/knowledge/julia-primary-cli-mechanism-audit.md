---
id: julia-primary-cli-mechanism-audit
title: Julia primary CLI alignment is split into five implementation mechanisms
answers:
  - what does the current Julia primary CLI implement
  - what Julia library seams can the primary parser CLI reuse
  - what is missing from the Julia primary parser CLI
  - why must Julia parser and compiler trace coverage precede CLI trace options
  - how is JULIA-BACKEND-PARITY.7.3.2 split
  - what is the next Julia primary CLI task
date: 2026-07-10
status: current
tags: [julia, cli, trace, parser, compiler, parity, JULIA-BACKEND-PARITY]
evidence: "JULIA-BACKEND-PARITY.7.3.2.0 audits and splits five mechanisms. .7.3.2.1 now closes frontend/compiler/function-shell/staged trace propagation with 868 assertions and 99/99 green; .7.3.2.2 is active for exact arguments plus source/input resolution and loading."
reverify: "rg -n 'JULIA-BACKEND-PARITY\\.7\\.3\\.2|status|corpus|parse_spec|parse_spec_with_staged|compile_spec|LinkedSpecRuntimeEngine|runtime_execute|LinkedSpecTraceConfig|JSON3\\.write' docs/tasks/JULIA-BACKEND-PARITY.md julia/src julia/test"
---

Julia already exposes native source parsing, staged top-level-function parsing,
compilation, runtime-engine construction, direct runtime execution, structured
runtime diagnostics, and trace configuration/sinks. These library seams can support
the ADR `0023` primary parser CLI without routing through a subprocess or temporary
file.

The existing primary CLI is still the rollout-era status/corpus dispatcher. It has no
ADR `0023` parser-option model, named/current/repository spec resolution, input loader,
native parser execution, canonical nested key-sorted JSON writer, or normalized
diagnostic/exit boundary. Corpus `JSON3.write(...)` usage does not prove the canonical
ordering required for primary CLI output.

Runtime trace instrumentation already existed. `.7.3.2.1` now propagates that same
emitter through source parsing, validation, compilation, function-shell parsing,
and staged dispatch, so the future primary `--trace*` flags can have the complete
native-pipeline meaning required by ADR `0023`.

`JULIA-BACKEND-PARITY.7.3.2` is therefore a parent with five ordered mechanism groups:

1. `.7.3.2.1` — compile/parser/function-shell/staged trace coverage (done);
2. `.7.3.2.2` — exact arguments plus source/input loading and named resolution (active);
3. `.7.3.2.3` — native execution and canonical direct-value JSON;
4. `.7.3.2.4` — normalized failures, exits, and trace routing;
5. `.7.3.2.5` — unit/direct-process conformance and public no-drift.

Related facts: [[user-observable-backend-cli-parity-contract]],
[[julia-diagnostics-trace-boundary]], [[julia-mdbook-usage-status]],
[[native-in-memory-backend-contract]], [[julia-frontend-compiler-staged-trace-events]].
