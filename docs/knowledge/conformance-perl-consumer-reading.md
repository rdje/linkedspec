---
id: conformance-perl-consumer-reading
title: Perl conformance consumers distinguish fixture adaptation and in-process generated loading
answers:
  - which Perl contract consumers load generated source in the same process
  - does the diagnostic-output Perl consumer execute the neutral source unchanged
  - what does the CLI runner test prove about fixture bytes
  - what Perl conformance reading and focused proof completed in group 34
date: 2026-09-13
status: group 34 physically read; five focused Perl targets pass; later generated-source test body unread
tags: [conformance, perl, reading, diagnostics, generated-source]
evidence: "CONFORMANCE-SOURCE-READING.1.34 at activation d10305097eb502c0fe29309ec230437396e26d82; eleven complete windows, 1500 fragments, 56255 bytes, ordered window SHA-256 db04deab6c0365f8bc454e2695d410324a120104a232c213346f2b23ad16aef3. Five managed Perl targets pass43 top-level tests; neutral named marks3, diagnostics20 and duplicate-slot59 mutations pass."
reverify: "bash tools/project_data_run.sh env PERL5LIB= prove -Iperl t/cli_conformance_runner.t t/complete_named_mark_contract.t t/diagnostic_output_perl_contract.t t/duplicate_regex_slot_identity_perl_contract.t t/generated_source_contract.t; bash tools/run_python_project_data.sh tools/check_complete_named_mark_contract.py; bash tools/run_python_project_data.sh tools/check_diagnostic_output_contract.py; bash tools/run_python_project_data.sh tools/check_duplicate_regex_slot_identity_contract.py"
---

The exact task scope finishes callable literals and reads the complete CLI runner,
named-mark, diagnostic-output and duplicate-slot Perl consumers. Generated-source
contract reading covers only lines 1-153; group35 owns the opened family fixture.
Whole-target execution does not grant source-reading credit for its unread suffix.

Callable suffix tests inspect final-codeblock function version3 metadata, preserve
parameter kinds in all three carriers, and compare normalized attached versus
parenthesized AST payloads. Helper, receiver, explicit-literal and user-function
forms execute. Invalid declaration diagnostics distinguish a malformed header
from a colon appearing only in its body. An harray in the final codeblock slot
fails with its actual kind preserved; it is not promoted into a callback.
The unchanged complete callable target10 and neutral23-mutation proof are retained
from group33. Existing startup19 receiver and startup35 boolean defects remain.

The CLI runner test concurrently drains child stdout/stderr as raw bytes and
checks a real help fixture, schema-before-launch, workspace/template substitution,
expected artifact bytes, non-text hexadecimal materialization, six invalid hex
source shapes, and the exact first differing byte in a channel mismatch. All
temporary data for the fresh run inherits the managed repository-local root.
This target is not a new full66-case CLI matrix; group32 retains that separate proof.

The named-mark test checks seven symbolic bare-name lowerings and the exact
Unicode Top/Child fixture. Different labels do not establish same-label recursive
isolation. The diagnostic-output consumer explicitly rewrites each neutral E block
to an action edge, adds a Done rule and appends x to the input. Its result/event
comparisons therefore validate this adapted Perl fixture, not byte-identical
neutral-source execution. It checks ordered eager effects, quiet default output,
caller exception identity, typed exit, arity before effects, generated sink
propagation and primary-command normalization of exit status23 to failure1.

Duplicate-slot coverage has twelve roles over five neutral fixtures. Ordered
matching reaches each required structural slot; choice retains first-authored
priority; repetition resets its sequence. Loaded and descriptor routes preserve
target/index identity, and generated plans stay exact label/family rows. Trace
and invalid/lost identity diagnostics are checked with capture snapshots.

These consumers load emitted Perl through eval into distinct packages in the
same test process. That is generated execution with package isolation; none of
those loaders alone demonstrates a fresh process or an independently deployed
artifact. The generated-source prefix also checks five seek/five consume family
policies and removed cursor-option precedence over invalid source parsing.

Related facts: [[perl-callable-codeblock-literal-record]], [[neutral-cli-fixture-runner]],
[[complete-named-mark-perl-rust-parity]], [[perl-diagnostic-output-events]],
[[perl-duplicate-regex-slot-identity-admission]], [[perl-generated-source-contract-v2]].
