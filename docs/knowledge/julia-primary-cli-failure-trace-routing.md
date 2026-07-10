---
id: julia-primary-cli-failure-trace-routing
title: Julia primary CLI has stable operational failures and complete trace routing controls
answers:
  - what stderr headings does the Julia primary CLI use
  - what exit code does Julia CLI use for compilation input and invocation failures
  - does Julia compile before loading an input file
  - what runtime diagnostic fields does the Julia CLI print
  - how do stdout route and mirror work in the Julia CLI
  - does Julia trace reset work with stdout mode or quiet tracing
  - what emoji does Julia trace use for each level
  - does Julia swallow interrupt out of memory or stack overflow errors
  - what did JULIA-BACKEND-PARITY.7.3.2.4 implement
date: 2026-07-10
status: current
tags: [julia, cli, diagnostics, trace, routing, exit-status, parity, JULIA-BACKEND-PARITY]
evidence: "JULIA-BACKEND-PARITY.7.3.2.4 adds phase-ordered failure normalization and complete sink/file/reset/emoji behavior. Seventy-five focused assertions, the 1,017-assertion suite, and 99/99 corpus gate pass."
reverify: "LINKEDSPEC_JULIA_CMD=/opt/homebrew/bin/julia LINKEDSPEC_JULIA_DEPOT_PATH=/private/tmp/linkedspec-julia-depot bash tools/run_julia_local.sh && rg -n '_print_primary_cli_runtime_error|_load_primary_cli_request_input|_primary_cli_fatal_error|_trace_emoji_prefix|Primary CLI failures and trace routing' julia/src julia/test/runtests.jl"
---

Julia's primary CLI reports operational failure with one stable heading:
`parser compilation failed`, `input load failed`, or `parser invocation failed`.
Each exits `1`; usage remains a separate exit `2`. Runtime failures print the
available `owner_stage`, `summary`, `detail`, `spec_name`, `spec_path`,
`top_rule`, and `rule_label` fields in that order, followed by raw `error:` text.
Interrupt, out-of-memory, and stack-overflow errors rethrow instead of being
misclassified as parser failures.

The CLI phase order matches the reference architecture: source resolution and
compilation complete before an input file is read. An invalid spec therefore
wins over a simultaneously missing input file. Literal input needs no later IO.

Trace routing composes independently from canonical JSON:

- no file defaults to stdout; a file defaults to route;
- stdout interleaves trace before JSON and does not append a selected file;
- route keeps JSON machine-readable and writes only a selected file;
- mirror writes the same trace bytes to stdout and file before JSON;
- route without a file discards trace; mirror without a file uses stdout;
- an empty file option behaves like no file;
- reset truncates a selected file even in stdout mode or at trace level none;
- without reset, stdout mode leaves a selected file unchanged.

Emoji rendering is owned by the shared emitter, not the CLI adapter. The level
threshold prefixes are `🛑`, `ℹ️`, `🔎`, `🧭`, `🐞`, and `🔥` from none through
debug. A disabled level still emits nothing.

This is Julia-local completion. Direct-process no-drift remains `.7.3.2.5`, and
the cross-backend language-neutral fixture comparison/wording convergence
remains `FUTURE-PARITY-BACKLOG.1.5`.

Related facts: [[julia-primary-cli-native-execution-canonical-json]],
[[julia-primary-cli-arguments-resolution-loading]], [[julia-trace-controls-sinks]],
[[julia-runtime-structured-diagnostics]], [[user-observable-backend-cli-parity-contract]].
