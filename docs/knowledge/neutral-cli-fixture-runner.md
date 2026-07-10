---
id: neutral-cli-fixture-runner
title: One strict manifest and arbitrary-command runner own primary CLI conformance
answers:
  - where are the LinkedSpec primary CLI conformance fixtures
  - how do I run primary CLI conformance
  - what does tools run_cli_conformance.pl do
  - how are CLI stdout stderr and exit status compared
  - how are routed trace files checked by CLI conformance
  - what placeholders does the CLI conformance runner support
  - what did FUTURE-PARITY-BACKLOG.1.5.1.1 implement
date: 2026-07-10
status: current
tags: [cli, conformance, fixtures, runner, exact-bytes, backends, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.1.5.1.1 adds cli_conformance/manifest.json, tools/run_cli_conformance.pl, exact help bytes, output-file support, and t/cli_conformance_runner.t; .1.5.1.2 expands to 22 help/usage cases and .1.5.1.3 expands to 29 with seven success cases."
reverify: "perl -c tools/run_cli_conformance.pl && PERL5LIB= prove -v -Iperl t/cli_conformance_runner.t t/trace_cli.t && PERL5LIB= perl tools/run_cli_conformance.pl --display-command 'perl bin/linkedspec' -- perl -I{{REPO_ROOT}}/perl {{REPO_ROOT}}/bin/linkedspec"
---

`cli_conformance/manifest.json` is the single backend-neutral primary-command
case inventory. `tools/run_cli_conformance.pl` accepts any backend launch array
after `--`; cases contain only shared arguments, files, and expected behavior.

For Perl:

```bash
PERL5LIB= perl tools/run_cli_conformance.pl \
  --display-command 'perl bin/linkedspec' \
  -- perl -I{{REPO_ROOT}}/perl {{REPO_ROOT}}/bin/linkedspec
```

Schema version 1 validates unique safe ids/paths, known keys, checked-in input
and expected files, argument arrays, channel definitions, generated-file
expectations, and exit statuses. Each case gets a canonical private workspace;
input files are copied as raw bytes. The runner drains stdout/stderr concurrently
as separate raw byte streams, then compares both channels, exit status, and any
expected workspace files exactly. A mismatch reports its first byte offset,
lengths, and escaped excerpts.

Explicit placeholders are `{{COMMAND}}`, `{{REPO_ROOT}}`, `{{WORKSPACE}}`, and
`{{CASE_ID}}`. `COMMAND` represents the only permitted user-interface variation:
the backend executable token or unavoidable host wrapper. Other placeholders
represent exact runner inputs and do not permit backend-specific expected output.

The first checked-in case locks complete backend-neutral help stdout, empty
stderr, and exit `0` on Perl. `.1.5.1.2` adds short help and 20 strict usage cases;
`.1.5.1.3` adds seven named/file/inline source, literal/file input, parser-control,
and canonical success cases. Later leaves add operational failure and deterministic
trace cases to this same manifest; generated-file expectations already support
routed trace bytes without a schema or runner fork.

Related facts: [[user-observable-backend-cli-parity-contract]],
[[perl-primary-cli-conformance-audit]], [[cross-backend-cli-contract-gap]],
[[trace-cli-control]], [[julia-primary-cli-process-conformance]],
[[perl-primary-cli-strict-arguments]], [[perl-primary-cli-success-conformance]].
