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
evidence: "JULIA-BACKEND-PARITY.7.3.2.4 adds native phase/trace controls; FUTURE-PARITY-BACKLOG.1.5.4.1 narrows primary stderr to one phase heading while native structured exceptions remain available."
evidence_update_2026_07_18_cursor_option_removal: "FUTURE-PARITY-BACKLOG.9.1.6.5 removes parse_mode from canonical request trace and returns the retired --parse-mode migration message as usage exit 2 before operational phases."
reverify: "bash tools/run_julia_local.sh && rg -n '_print_primary_cli_runtime_error|_load_primary_cli_request_input|_primary_cli_fatal_error|_trace_emoji_prefix|Primary CLI failures and trace routing' julia/src julia/test/runtests.jl"
---

Julia's primary CLI reports operational failure with one stable heading:
`parser compilation failed`, `input load failed`, or `parser invocation failed`.
Each exits `1`; usage remains a separate exit `2`. `.1.5.4.1` makes that heading
the complete primary stderr payload so every backend command is byte-identical.
The underlying `RuntimeInterpreterException` still carries `owner_stage`,
`summary`, `detail`, source identity, top rule, and rule label for native API
consumers. Interrupt, out-of-memory, and stack-overflow errors rethrow instead
of being misclassified as parser failures.

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

Canonical request trace identifies source, input, and requested top rule only.
It contains no global cursor field; entered-rule trace below the primary adapter
continues to report each rule's derived family policy.

This began as Julia-local completion. `.1.5.4.1` locks phase-only primary stderr and exact shared help. `.1.5.4.2`
now projects canonical phase trace through the primary command while preserving rich native exceptions/trace below
the adapter. Julia passes 61/61 default/POSIX.

Related facts: [[julia-primary-cli-native-execution-canonical-json]],
[[julia-primary-cli-arguments-resolution-loading]], [[julia-trace-controls-sinks]],
[[julia-runtime-structured-diagnostics]], [[user-observable-backend-cli-parity-contract]],
[[julia-global-cli-61-audit]], [[julia-canonical-primary-cli-trace]],
[[julia-global-cursor-option-removal]].
See also [[julia-primary-cli-process-conformance]].
