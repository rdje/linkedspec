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
status: "stable phase protocol; context-only handler failure reporting is owned P1 child17.8"
tags: [perl, cli, failures, diagnostics, stdout, trace, conformance, FUTURE-PARITY-BACKLOG]
evidence: "Original operational rollout remains historical below. Intake17.0 retains twelve library write failures reported by Perl CLI as exit0/null; other five native routes exit1. A two-case established-protocol oracle is RED on Perl and GREEN on the other five. Child17.8 owns repair before signed contract17.1."
reverify: "Dated source-bound intake: bash tools/run_python_project_data.sh docs/checkpoints/signed-array-selectors/review.py. No current signed-policy admission."
---

# Context-only handler failures (October23)

`items=[10,20,30]; items[1.5]=99; return(items)` reports a typed error through public Get/runtime_ctx_ref and independently emitted execution. The primary command emits `null` plus LF, empty stderr and exit0. Its runtime context is already wired, but the invocation boundary checks only `$@`. This conceals failure from scripts. P1 TYPE-REFERENCE-BOOK.1.2.17.8 repairs both failure channels while preserving successful null/false/no-match results. Current evidence is a dated baseline, not a repaired-command claim.

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
