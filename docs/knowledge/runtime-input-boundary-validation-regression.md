---
id: runtime-input-boundary-validation-regression
title: The Runtime.pm comment-skip wrapper derefs input before the SCALAR-ref guard, so invalid top-level parser input dies with a raw error instead of the friendly boundary message
answers:
  - "why does parser_invalid_input die with a raw 'Not a SCALAR reference' error"
  - "why is runtime_ctx last_error empty on invalid input ref"
  - "where is the top-level parser input-boundary validation regression"
  - "why does get_parser runtime_ctx_ref not record invalid input ref"
date: 2026-06-19
status: resolved
tags: [runtime, input-validation, diagnostics, regression, phase0]
evidence: "PHASE0-BACKHALF-TRIAGE.1 (2026-06-19): 2 of 173 back-half failures; agent-identified Runtime.pm:~126 + commit d7294d0. FIXED by PHASE0-BACKHALF-TRIAGE.4 (2026-06-21): wrapper now gates its pos()/skip block behind `ref($input_ref) eq 'SCALAR'` and always delegates to the inner parser; invalid input now yields the friendly boundary error + populated last_error."
reverify: "perl -Iperl -e 'require LinkedSpec; my $s=\"Top:: /foo/ -> Top { return(1) }\\n\"; my %c; my $p=LinkedSpec::Get(\\$s,top_rule=>q{Top},runtime_ctx_ref=>\\%c); my @bad=(1,2); my $r=eval { $p->(\\@bad) }; print qq{err=$@\\n}; print q{last_error=}, ($c{last_error}{detail}//q{<none>}), qq{\\n}'  # now: err + last_error = 'Top-level parser expects a SCALAR reference input; got ARRAY'"
---

> **RESOLVED 2026-06-21 (`PHASE0-BACKHALF-TRIAGE.4`, authorized by ADR `0008`).** The
> `perl/LinkedSpec/Runtime.pm` comment-skip wrapper now runs `pos($$input_ref) = 0;` and the
> leading-comment/blank-line skip **only** when `ref($input_ref) eq 'SCALAR'` (mirroring the inner
> guard's exact acceptance at `Compiler.pm:1109`, `ref ne 'SCALAR'`), and always delegates to
> `$original_parser->($input_ref)`. For non-SCALAR-ref input the wrapper no longer derefs, so the
> documented inner guard fires: invalid input returns `Top-level parser expects a SCALAR reference
> input; got ARRAY` with a populated `runtime_ctx->{last_error}` (`type => 'runtime_parser'`). Valid
> scalar-ref input keeps the comment-skip behavior. The card below is the original (regression-present)
> reading, kept for history.

Established by `PHASE0-BACKHALF-TRIAGE.1` (read-only triage, 2026-06-19). A pre-existing
**reference-engine validation regression** surfaced when the phase0 back half stopped being masked.
Accounts for **2 of the 173** back-half failures (`parser_invalid_input_fails_at_runtime_parser_boundary`,
`get_parser_runtime_ctx_ref_records_invalid_input_ref_with_spec_identity`).

**Defect:** `perl/LinkedSpec/Runtime.pm` (~line 126) — the comment/blank-line-skip wrapper added by
`MEDIUM-IMPACT.3.2` (commit `d7294d0`) runs `pos($$input_ref) = 0;` (an unguarded deref) **before**
delegating to the inner parser that holds the documented input-boundary guard
(`perl/LinkedSpec/Compiler.pm` ~line 1113). For non-`SCALAR`-ref input the wrapper dies first with a raw
`Not a SCALAR reference at … Runtime.pm line 126`, instead of the contracted friendly message
`Top-level parser expects a SCALAR reference input; got ARRAY`. Because the die happens in the wrapper,
`runtime_ctx->{last_error}` is never populated (the tests see `got: undef`).

**Fix direction:** guard the wrapper's deref (validate the input is a `SCALAR` ref, or run the documented
boundary validation, *before* `pos($$input_ref) = 0`), so invalid input yields the friendly boundary
error + a populated structured `last_error`. Line numbers are agent-identified — confirm exactly at fix
time.

Tracked as `PHASE0-BACKHALF-TRIAGE.4` (blocked on user authorization to touch the reference engine).
Related: [[and-return-edge-codegen-defect]].
