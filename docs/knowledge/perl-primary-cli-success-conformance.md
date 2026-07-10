---
id: perl-primary-cli-success-conformance
title: Perl primary CLI success behavior is locked by seven neutral exact-byte cases
answers:
  - how is Perl CLI named spec resolution tested
  - does Perl CLI preserve input file newlines
  - does Perl CLI recursively sort nested JSON keys
  - how are spec file inline spec and named spec success tested
  - how are seek consume and top rule tested on the Perl CLI
  - how many neutral CLI cases pass on Perl after success fixtures
  - why do neutral success fixtures use action edges instead of direct E
  - what did FUTURE-PARITY-BACKLOG.1.5.1.3 implement
date: 2026-07-10
status: current
tags: [perl, cli, success, io, parser-controls, canonical-json, conformance, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.1.5.1.3 adds seven neutral success cases; all 29 help/usage/success cases pass exactly with POSIXLY_CORRECT unset and set. LinkedSpec toolbox probes establish resolution, exact bytes, action-edge returns, and the existing ADR-0020 direct-E caveat."
reverify: "PERL5LIB= perl tools/run_cli_conformance.pl --display-command 'perl bin/linkedspec' -- perl -I{{REPO_ROOT}}/perl {{REPO_ROOT}}/bin/linkedspec && POSIXLY_CORRECT=1 PERL5LIB= perl tools/run_cli_conformance.pl --display-command 'perl bin/linkedspec' -- perl -I{{REPO_ROOT}}/perl {{REPO_ROOT}}/bin/linkedspec"
---

Seven `success` cases in `cli_conformance/manifest.json` lock the Perl
reference command without backend-specific expected-output adaptation:

1. repository-named `Lispish` plus literal input from an isolated working directory;
2. file source plus file input returning a deliberately unsorted nested object;
3. inline source plus literal input;
4. explicit non-default top rule;
5. seek mode scanning forward to a match;
6. consume mode matching at the current cursor;
7. a newline-ended input file returned through `input_text()`.

The nested result is exactly `{"a":{"b":2,"d":4},"z":0}\n`. The exact-input
result contains JSON bytes `"x\n"` followed by the separate JSON-record newline.
Every success requires empty stderr, exit `0`, and no unexpected generated files.

`LinkedSpec::Get`, `LinkedSpec::get_parser`, generated-source, and debug-trace
probes were run before fixture authoring. They reverified ADR `0020`: Perl's
direct default-rule regex plus `E` handler shape can omit the regex/finalizer.
The neutral cases therefore use established action-edge returns already exercised
by the cross-variant corpus. This is fixture selection, not a waiver of future
lifecycle parity; the complete capability census remains responsible for that gap.

The complete current Perl suite is 29 cases: two help, 20 usage, and seven
success. All pass with `POSIXLY_CORRECT` both unset and set.

Related facts: [[neutral-cli-fixture-runner]],
[[perl-primary-cli-strict-arguments]],
[[user-observable-backend-cli-parity-contract]],
[[perl-lifecycle-final-value-e-drift]],
[[cross-backend-cli-contract-gap]].
