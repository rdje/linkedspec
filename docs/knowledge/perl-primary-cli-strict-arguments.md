---
id: perl-primary-cli-strict-arguments
title: Perl primary arguments are explicit exact and environment independent
answers:
  - does the Perl primary CLI still use Getopt Long
  - does the Perl CLI reject positional arguments and subcommands
  - are Perl CLI options case sensitive now
  - does the Perl CLI reject abbreviated and negated options
  - is Perl CLI behavior independent of POSIXLY_CORRECT
  - how many neutral CLI usage cases pass on Perl
  - what did FUTURE-PARITY-BACKLOG.1.5.1.2 implement
date: 2026-07-10
status: current
tags: [perl, cli, arguments, usage, conformance, exact-bytes, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.1.5.1.2 replaces ambient Getopt::Long parsing with one explicit ADR-0023 parser; 2 help plus 20 usage cases pass exactly with POSIXLY_CORRECT unset and set."
reverify: "perl -c bin/linkedspec && PERL5LIB= perl tools/run_cli_conformance.pl --display-command 'perl bin/linkedspec' -- perl -I{{REPO_ROOT}}/perl {{REPO_ROOT}}/bin/linkedspec && PERL5LIB= POSIXLY_CORRECT=1 perl tools/run_cli_conformance.pl --display-command 'perl bin/linkedspec' -- perl -I{{REPO_ROOT}}/perl {{REPO_ROOT}}/bin/linkedspec"
---

`bin/linkedspec` parses its public arguments explicitly instead of inheriting
`Getopt::Long` defaults. It accepts only ADR `0023`'s exact case-sensitive long
options and `-h`. Value options support separate and `--option=value` forms;
repeated values are last-wins. Lexical errors are accumulated in argument order
before source/input cardinality and parser/trace value validation.

The command rejects:

- `status`, `corpus`, and every other positional;
- literal `--`;
- unknown, uppercase, and abbreviated long options;
- undocumented `--no-trace-reset` / `--no-trace-emoji` aliases;
- inline values on help/boolean flags and missing value-option arguments;
- source/input selector conflicts;
- unsupported parse modes, trace levels, and trace modes.

`cli_conformance/manifest.json` contains two exact help and 20 exact usage
cases. One shared error-plus-help template uses manifest-owned `{{ERROR}}`
channel data; custom variables may not override runner placeholders. Every
usage failure requires empty stdout, exact stderr, no generated files, and exit
`2`. All 22 cases pass with `POSIXLY_CORRECT` both unset and set, proving ambient
host option policy no longer changes user behavior.

Related facts: [[neutral-cli-fixture-runner]],
[[perl-primary-cli-conformance-audit]],
[[user-observable-backend-cli-parity-contract]],
[[cross-backend-cli-contract-gap]].
