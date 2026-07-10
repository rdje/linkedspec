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
evidence: "JULIA-BACKEND-PARITY.7.3.2.2 replaces status/corpus primary dispatch with ADR 0023's exact option/preparation model, deterministic named resolution, and exact file/inline loading. .7.3.2.3 subsequently connects prepared requests to native execution and canonical JSON."
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
4. lexicographically traversed repository fallback for a bare name.

Explicit paths and explicit `.spec` names never use fallback. Repository
metadata and generated dependency/build trees are pruned, so generated artifacts
cannot unexpectedly win named resolution. `--spec-file` and `--input-file` load
exact string contents; inline source and literal input remain unchanged.

The typed preparation record retains the validated controls, source identity/path
and text, and input path/text for native execution. `.7.3.2.3` now consumes that
record through the native pipeline and emits canonical direct-value JSON; this
card remains the canonical home for the argument/loading half of that composition.

Related facts: [[user-observable-backend-cli-parity-contract]],
[[julia-primary-cli-mechanism-audit]], [[cross-backend-cli-contract-gap]],
[[native-in-memory-backend-contract]],
[[julia-primary-cli-native-execution-canonical-json]].
