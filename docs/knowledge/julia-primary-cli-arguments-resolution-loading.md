---
id: julia-primary-cli-arguments-resolution-loading
title: Julia primary CLI has exact arguments deterministic named resolution and exact loading
answers:
  - what options does the Julia primary CLI accept
  - does the Julia primary CLI accept status or corpus subcommands
  - does the Julia primary CLI accept positional arguments
  - how does Julia resolve --spec NAME
  - what is the Julia named spec resolution order
  - do Julia spec and input files preserve exact contents
  - can the Julia primary CLI execute a prepared request yet
  - what did JULIA-BACKEND-PARITY.7.3.2.2 implement
date: 2026-07-10
status: current
tags: [julia, cli, arguments, resolution, io, parity, JULIA-BACKEND-PARITY]
evidence: "JULIA-BACKEND-PARITY.7.3.2.2 adds the local option/preparation model; FUTURE-PARITY-BACKLOG.1.5.4.1 reads raw bytes, requires isvalid UTF-8, and proves exact shared help/loading behavior."
evidence_update_2026_07_11_native_resolution: "FUTURE-PARITY-BACKLOG.1.6.4.4 delegates named/file source loading and compilation to the public 14/9/4 native API and removes the recursive repository fallback; 61x2 canonical CLI remains exact."
reverify: "LINKEDSPEC_JULIA_CMD=/opt/homebrew/bin/julia LINKEDSPEC_JULIA_DEPOT_PATH=/private/tmp/linkedspec-julia-depot bash tools/run_julia_local.sh && rg -n '_parse_primary_cli_args|_prepare_primary_cli_request|_resolve_named_spec_path|unexpected positional|primary_status_code' julia/src/cli/LinkedSpecJuliaCli.jl julia/test/runtests.jl tools/run_julia_local.sh"
---

`JULIA-BACKEND-PARITY.7.3.2.2` replaces Julia's rollout-era primary
`status`/`corpus` dispatch. The primary module now accepts only ADR `0023`'s
source, input, parser, trace, and help options. `status`, `corpus`, every other
positional argument, unknown options, missing values, invalid selector counts,
and invalid modes/levels return usage exit `2`. Corpus execution remains in the
separate `julia/bin/corpus_runner.jl` developer adapter.

Named `--spec NAME` resolution is deterministic:

1. exact current path `NAME`;
2. current `NAME.spec`;
3. repository `specs/NAME.spec`;

No recursive repository fallback remains. Explicit paths and explicit `.spec` names never use fallback.
`--spec-file` and `--input-file` load
exact string contents; inline source and literal input remain unchanged. The
public CLI defers input-file loading until source compilation succeeds, preserving
the reference failure order.

Global correction: Julia `String` can carry invalid UTF-8, so the primary loader now reads raw bytes, constructs
the preserved string, and requires `isvalid` before returning it. `.1.5.4.1` proves malformed source/input fail in
their stable phases while valid BOM/newline/normalization and Unicode bytes remain unchanged. Its exact shared help
and loading/error repair advances the unchanged suite from 13 to 42/61 in default and POSIX environments.

The typed request retains the validated controls, source identity/path and text,
plus literal input or a deferred input path for native execution. `.7.3.2.3`
consumes it through the native pipeline, and `.7.3.2.4` locks deferred input IO;
this card remains the canonical home for the argument/loading half of that
composition.

Related facts: [[user-observable-backend-cli-parity-contract]],
[[julia-primary-cli-mechanism-audit]], [[cross-backend-cli-contract-gap]],
[[native-in-memory-backend-contract]],
[[julia-primary-cli-native-execution-canonical-json]],
[[julia-primary-cli-failure-trace-routing]], [[julia-global-cli-61-audit]].
