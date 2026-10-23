---
id: perl-primary-cli-operational-failures
title: Perl primary CLI operational failures have stable phase ordered channels
answers:
  - what exact stderr does the Perl CLI print for compilation failure
  - what exact stderr does the Perl CLI print for input load failure
  - what exact stderr does the Perl CLI print for invocation failure
  - does Perl CLI compile before loading an input file
  - is Perl CLI failure stdout empty
  - does ambient LINKEDSPEC trace configuration affect the primary CLI
  - why did Perl CLI failure stdout contain timestamps
  - how many neutral CLI cases pass after operational failures
  - what did FUTURE-PARITY-BACKLOG.1.5.1.4 implement
  - "why does Perl CLI print null for a typed invalid write"
  - "which task repairs Perl CLI context-only runtime failures"
date: "2026-10-23"
status: "context-reported primary CLI failures repaired; original rollout/intake remain historical"
tags: [perl, cli, failures, diagnostics, stdout, trace, conformance, FUTURE-PARITY-BACKLOG]
evidence: "TYPE-REFERENCE-BOOK.1.2.17.8 retains11 source/input cases (10 source texts),22 quiet/routed CLI observations, Get/fresh proof and actual permanent source-inverse/restoration. Original intake and wrong no-match target remain exact and separately qualified; canonical proof governs admission."
reverify: "Current CLI consumer: bash tools/project_data_run.sh prove -Iperl t/trace_cli.t; dated source-bound proof: bash tools/run_python_project_data.sh docs/checkpoints/type-cli-runtime-errors/publish.py"
---

# Context-reported handler failures (October23)

The invocation boundary checks both saved `$@` and `runtime_ctx.last_error`.
An invalid fractional write, including a callable write, now exits1 with empty
stdout and `linkedspec: parser invocation failed` plus LF on stderr. Routed
trace ends in `invoke:error`; existing thrown errors keep the same protocol.
Null, false, zero, initializer return and real self-edge matched/no-match
results remain successful when both error channels are clear.

The prior CLI's exit0/null observations remain in signed intake17.0. Repair17.8
preserves every original control and qualifies its mistaken I-return target;
canonical lifecycle semantics and real self-edge twins distinguish no-match.
No library, selector or trace-protocol change is implied.

# Original operational rollout (July10)

The Perl reference primary CLI has three exact operational stderr records:

```text
linkedspec: parser compilation failed
linkedspec: input load failed
linkedspec: parser invocation failed
```

Each record ends in one newline and exits `1`. Without an explicit CLI trace
option, stdout is empty and no output file is created. Backend owner/stage fields,
host paths, OS `$!` wording, raw exceptions, source locations, and timestamps are
deliberately absent from the identical cross-backend command contract.

Four neutral cases cover invalid inline source with a simultaneously missing
input file, missing spec file, missing input after valid compilation, and missing
explicit top rule at invocation. The combined invalid-source/missing-input case
proves compilation precedes deferred input-file loading.

The general `LinkedSpec::Trace` embedding contract is unchanged. Its level-zero
diagnostics are intentionally visible at ordinary `none` verbosity. When the
primary command has no trace option, the adapter clears backend-specific trace
environment inputs and configures an internal level below `none` with an empty
route sink. A focused regression wraps the compilation failure in ambient
debug/file/reset/emoji state and proves exact stderr, empty stdout, and no trace
file. `.1.5.1.5` later makes explicit primary trace a canonical portable phase
channel under ADR `0024`; rich backend diagnostics remain in native embedding.

At the `.1.5.1.4` boundary, the complete Perl suite was 33 cases: two help, 20 usage,
seven success, and four operational failures. All passed with `POSIXLY_CORRECT` unset and set.
The following explicit-trace slice extends the current suite to 53 cases.

Related facts: [[perl-primary-cli-conformance-audit]],
[[neutral-cli-fixture-runner]], [[trace-cli-control]],
[[trace-verbosity-and-formatting]],
[[user-observable-backend-cli-parity-contract]],
[[cross-backend-cli-contract-gap]], [[canonical-primary-cli-trace-protocol]].
