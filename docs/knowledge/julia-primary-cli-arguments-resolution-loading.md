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
evidence: "JULIA-BACKEND-PARITY.7.3.2.2 adds the local option/preparation model; FUTURE-PARITY-BACKLOG.1.5.4.0 later proves read(path, String) accepts malformed UTF-8 and routes strict repair to active .1.5.4.1."
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
exact string contents; inline source and literal input remain unchanged. The
public CLI defers input-file loading until source compilation succeeds, preserving
the reference failure order.

Global audit correction: Julia `String` can carry invalid UTF-8, so `read(path, String)` preserves bytes but does
not enforce ADR `0025` strict text. `.1.5.4.0` proves malformed source/input are currently accepted; active
`.1.5.4.1` must add `isvalid` rejection while preserving valid BOM/newline/normalization data.

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
