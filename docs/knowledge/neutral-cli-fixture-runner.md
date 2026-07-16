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
date: 2026-07-15
status: current
tags: [cli, conformance, fixtures, runner, exact-bytes, backends, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.1.5.1.1 adds the arbitrary-command runner; .1.5.4.3 runs it unchanged across Perl/Rust/Dart/Julia at 4x2x61; LUA-BACKEND-PARITY.7.2 extends the same matrix to Lua at 5x2x61."
reverify: "perl -c tools/run_cli_conformance.pl && PERL5LIB= prove -v -Iperl t/cli_conformance_runner.t t/trace_cli.t && bash tools/run_primary_cli_matrix.sh"
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

For Rust, `tools/run_rust_local.sh` builds the command and invokes this same runner in default and POSIX option
environments. Perl, Rust, Dart, and Julia pass all 61 unchanged cases in both environments. `.1.5.4.3` now owns
the original warmed recurring four-command invocation of this unchanged contract; Lua `.7.2` extends that matrix
to five commands and 5x2x61 without changing the manifest or runner.

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
and canonical success cases. `.1.5.1.4` adds four exact phase-ordered operational
failures. `.1.5.1.5` adds 20 deterministic trace cases to this same manifest;
generated-file expectations support
routed trace bytes without a schema or runner fork.

ADR `0025` requires invalid UTF-8 source/input file cases. `.1.5.1.6.1` adds a
schema-v1-compatible explicit `bytes_hex` source for workspace files. It is
mutually exclusive with checked-in `source`, non-empty/lowercase/even-length,
and materialized as raw bytes. `.6.2` now uses that form for invalid bytes, source
BOM preservation, and exact Unicode input bytes; the current suite has 61 cases.

Related facts: [[user-observable-backend-cli-parity-contract]],
[[perl-primary-cli-conformance-audit]], [[cross-backend-cli-contract-gap]],
[[trace-cli-control]], [[julia-primary-cli-process-conformance]],
[[perl-primary-cli-strict-arguments]], [[perl-primary-cli-success-conformance]],
[[perl-primary-cli-operational-failures]], [[canonical-primary-cli-trace-protocol]],
[[primary-cli-utf8-process-boundary-gap]], [[primary-cli-strict-utf8-text-contract]],
[[rust-local-verification-gate]], [[dart-primary-cli-closeout]], [[julia-global-cli-61-audit]],
[[julia-canonical-primary-cli-trace]], [[primary-cli-four-backend-matrix]],
[[lua-primary-cli-recurring-admission]].
