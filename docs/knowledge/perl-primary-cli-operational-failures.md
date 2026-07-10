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
date: 2026-07-10
status: current
tags: [perl, cli, failures, diagnostics, stdout, trace, conformance, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.1.5.1.4 adds four exact operational cases, below-none untraced trace configuration, stable one-line stderr, and ambient trace isolation; all 33 cases pass in default/POSIX environments."
reverify: "perl -c bin/linkedspec && PERL5LIB= prove -v -Iperl t/cli_conformance_runner.t t/trace_cli.t && PERL5LIB= perl tools/run_cli_conformance.pl --display-command 'perl bin/linkedspec' -- perl -I{{REPO_ROOT}}/perl {{REPO_ROOT}}/bin/linkedspec"
---

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
file. Explicit CLI trace remains the diagnostic-detail channel and is owned by
`.1.5.1.5`.

The complete current Perl suite is 33 cases: two help, 20 usage, seven success,
and four operational failures. All pass with `POSIXLY_CORRECT` unset and set.

Related facts: [[perl-primary-cli-conformance-audit]],
[[neutral-cli-fixture-runner]], [[trace-cli-control]],
[[trace-verbosity-and-formatting]],
[[user-observable-backend-cli-parity-contract]],
[[cross-backend-cli-contract-gap]].
