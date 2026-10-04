---
id: perl-private-statement-frame-channel
title: Canonical Perl splitting publishes private source frames by returned-array identity and occurrence index
answers:
  - "how does the canonical splitter publish private original statement frames"
  - "does private statement framing change the five scanner callbacks"
  - "what happens to frames when a callback copies or changes the split array"
  - "can custom trim transformations receive invented source spans"
  - "does statement framing publish origins for the eleven basic events yet"
  - "how do nested private splitter collectors restore the outer invocation"
date: 2026-10-04
status: private splitter frame implementation verified under .1; eleven event hooks implemented under .2; statement-family acceptance .3 verified with canonical landing requirement
tags: [perl, actionir, statements, source-frame, identity, unicode]
evidence: "SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.1.1.1 retains exact28-group RED25/GREEN0,66 complete public/compiler before-after pairs,177 authored original scalar frames and source-fixed consumer/book proof."
reverify:
  - "bash tools/project_data_run.sh env PERL5LIB= prove -v -Iperl t/actionir_statement_source_frames.t"
  - "bash tools/run_python_project_data.sh docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.1.1.1-review.py"
---

# Private frames come from producer boundaries, not equal raw text

StatementSplit::Core::_split_with_source_frames calls the supplied dependency exactly
once with its existing arguments. Its invocation-local collector observes batches
published by the canonical splitter and selects the exact returned array by reference
identity. Source frames remain aligned by statement occurrence index. The wrapper
preserves opaque/scalar/reference returns; unknown or copied arrays gain no borrowed
frames. A changed returned entry receives undef rather than another entry's origin.

Core tracks each accumulated statement's original scalar start and next position.
Every existing flush site retains its original trim call and split behavior. Only
private collection invokes the source-frame builder. It derives edge whitespace bounds
from original accumulated text and validates the original source slice against the
actual trimmed value. It does not search for equal raw text. Custom interior changes
receive no invented frame for that entry; exact unchanged entries can still be mapped.
Non-scalar source inputs retain existing stringification without scalar origins.

Each frame contains the complete original source, raw statement and start/end span.
The returned array remains the original object. Nested private collection restores the
outer recorder; callback errors and argument order are retained. No long-lived global
cache is introduced. Normal splitting publishes no public fields or new dependencies.

The independent author builds original literal segments with cumulative Unicode scalar
offsets, distinguishing comments, quoted twins, repetitions, attached blocks, Unicode
whitespace, CRLF and nested comment newlines. All177 frames in66 case/seed comparisons
match those intervals; full public event/argument/substitution/diagnostic/parser-source
records stay identical. The unchanged28-group fixture fails25 before and passes28 after.
Initial executions retain their actual fixture/Core source identities separately from
final guarded/format-corrected runs. Same3766 supplied inputs/modes are checked before
and after each run; only Core's declared production overlay differs between phases.

The .2 producer hooks now connect the eleven basic statement event producers to these
original frames. Follow perl-basic-statement-event-source-provenance for their exact scope.
Child .3 independently accepts the family with exact staged canonical proof;
executable membership, comments and replacement remain subsequent work. Arbitrary host
syntax, malicious custom callback mutation and cross-host transcript identity are not
admitted by this bounded proof. All project bytes are parent-owned, with immutable Git
inputs and explicit overlays; submodules remain excluded black boxes.

Statement-family .3 repeats the complete immutable ab2c activation boundary:3864
regular inputs/no overlays, four fixtures80 groups,66 exact prior guarded compiler
recurrences,177 authored frames and111 exact original event origins. Three foreign-source
probes preserve events without origins. Fifteen reason-specific RED controls and five
render controls pass; final source-bound diagnostic repair and updated teaching follow below.
The original .2 claim freezes at ab2c after61 input hashes verify. Exact staged canonical
receipt is the family landing condition; twenty-contract composition remains .1.1.2.

The final .3 boundary additionally binds two failed reviewer replays to the exact
executed source: all six logical traceback frames match, and six controls reject both
original unbound contexts plus producer/channel/completeness corruptions. Original
uncached diagnostics disclose the unbound formatter input rather than claiming it
recovered. Final 58-input book renders five examples/two chapters with six controls.
The interrupted first canonical attempt is retained without a complete pass claim;
exact staged canonical CI repeats after repair. Follow python-replay-traceback-source-binding.
