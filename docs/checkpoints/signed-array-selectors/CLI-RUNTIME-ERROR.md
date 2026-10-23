# Owned defect: Perl CLI loses non-throwing runtime failures

Intake owner: TYPE-REFERENCE-BOOK.1.2.17.0.
Repair owner: TYPE-REFERENCE-BOOK.1.2.17.8, priority P1; register that child in the
canonical tree when the current unchanged-input survey completes, then repair at
the first clean boundary after this intake, before neutral-contract child17.1.
The present native survey remains a before-image; no runtime code is changed.

Reproduction from the exact retained32-source grid:

```text
Top: /x/
 I { items=[10,20,30]; items[1.5]=99; return(items) }
```

`perl -Iperl bin/linkedspec --inline-spec SOURCE --input x` exits0, emits
`null` plus a newline on stdout and leaves stderr empty. `write-last` and ten
other invalid-write cases have the same CLI success classification. Public Get
with `runtime_ctx_ref` reports the actual typed nested-write failure; independent
emitted execution rejects it. The original complete channels and source epochs
remain in perl-baseline.json.gz and native-perl.json.gz.

The CLI's invocation boundary in bin/linkedspec checks only the exception in
`$@`; library handler failures can return undef and populate `last_error` instead.
The primary-command contract promises invocation failures on stderr with exit1.
Printing a success null hides failure and prevents scripts from detecting invalid
input. This is separate from requested negative-index support: the fractional
selector is already invalid under the frozen v1 authority.

Required repair: observe the documented runtime context alongside exceptions,
preserve successful null/false values and ordinary no-match results, emit the
existing stable invocation-failure heading/exit and error trace, and add a
permanent distinguishing primary-command regression. Verify the other runtime
CLI observations before selecting shared cases. Use canonical admission because
public command behavior changes. Retain actual baseline/repaired/source-inverse
channels, source and fixture identities; update the book and current Knowledge
within the existing containment budgets. No other repository is writable.
