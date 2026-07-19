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
evidence: "JULIA-BACKEND-PARITY.7.3.2.0 splits five mechanisms. .7.3.2.1 through .5 close all five with nine process families, 1,017 assertions, 99/99, and runtime-corpus-primary-cli; .7.3.3 closes local no-drift."
evidence_update_2026_07_18_cursor_option_removal: "FUTURE-PARITY-BACKLOG.9.1.6.5 removes the later-retired global cursor option, adds the tenth process family, and reaches exact 65x2 shared primary conformance without changing the five original mechanism owners."
reverify: "rg -n 'JULIA-BACKEND-PARITY\\.7\\.3\\.2|status|corpus|parse_spec|parse_spec_with_staged|compile_spec|LinkedSpecRuntimeEngine|runtime_execute|LinkedSpecTraceConfig|JSON3\\.write' docs/tasks/JULIA-BACKEND-PARITY.md julia/src julia/test"
---

Julia already exposes native source parsing, staged top-level-function parsing,
compilation, runtime-engine construction, direct runtime execution, structured
runtime diagnostics, and trace configuration/sinks. These library seams can support
the ADR `0023` primary parser CLI without routing through a subprocess or temporary
file.

The audit found a rollout-era status/corpus dispatcher with none of the required
parser-option, resolution, execution, canonical JSON, or normalized diagnostic
mechanisms. `.7.3.2.1` through `.7.3.2.3` have since closed trace propagation,
argument/loading preparation, native execution/direct canonical JSON, and the
normalized diagnostic/exit plus complete trace-routing boundary, and direct-
process/public-status no-drift.

Runtime trace instrumentation already existed. `.7.3.2.1` now propagates that same
emitter through source parsing, validation, compilation, function-shell parsing,
and staged dispatch, so the future primary `--trace*` flags can have the complete
native-pipeline meaning required by ADR `0023`.

`JULIA-BACKEND-PARITY.7.3.2` is therefore a parent with five ordered mechanism groups:

1. `.7.3.2.1` — compile/parser/function-shell/staged trace coverage (done);
2. `.7.3.2.2` — exact arguments plus source/input loading and named resolution (done);
3. `.7.3.2.3` — native execution and canonical direct-value JSON (done);
4. `.7.3.2.4` — normalized failures, exits, and trace routing (done);
5. `.7.3.2.5` — unit/direct-process conformance and public no-drift (done).

Related facts: [[user-observable-backend-cli-parity-contract]],
[[julia-diagnostics-trace-boundary]], [[julia-mdbook-usage-status]],
[[native-in-memory-backend-contract]], [[julia-frontend-compiler-staged-trace-events]],
[[julia-primary-cli-arguments-resolution-loading]],
[[julia-primary-cli-native-execution-canonical-json]],
[[julia-primary-cli-failure-trace-routing]],
[[julia-primary-cli-process-conformance]], [[julia-global-cursor-option-removal]],
[[julia-scoped-parity-no-drift]].
