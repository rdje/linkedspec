---
id: perl-slash-call-outer-block-validation
title: Perl final slash calls need full-source validation precedence
answers:
  - why does Perl division fail at the end of an action block
  - why does a final slash call report an unclosed rule block
  - which validation scans consume the brace after division
  - how does Perl preserve regex precedence without leaking retry errors
  - do Perl callable bodies support numeric helpers
  - why does parenthesized Perl arithmetic reach a host function
date: 2026-09-24
status: .86.5 verified including slot metadata; .86.3 canonical and .87.3/.87.4 remain
tags: [perl, validation, arithmetic, scanner, callable, source]
evidence: "At fe516141b, the fixed15-case .86.5-contexts checkpoint measures public Get/errors plus fragment slash classification, consumed offset, edge depth and lifecycle close. Bare/spaced EOF division consumes to fragment length, leaving depth1 and no lifecycle closer; semicolon/named/receiver controls return7 with depth0. Same-line following regex/quoted-slash cases also fail validation."
reverify: "bash tools/project_data_run.sh env PERL5LIB= prove -Iperl t/multiline_helper_pattern_validation.t t/generated_source_contract.t; bash tools/project_data_run.sh env PERL5LIB= perl -Iperl docs/checkpoints/SESSION-STARTUP-READING.86.5-contexts.pl; compare values/error owners and structural scans, not diagnostic exit status alone."
---

`MethodExpr::_looks_like_slash_symbol_call_at` deliberately excludes `}` as a
call boundary to preserve regex syntax. Keep that shared safeguard.
At clean `fe516141b`, `Validation::_consume_slash_construct` treats final `/(14,2)`
before an outer `}` as a regex opener. Both `_scan_rule_edges_in_fragment` and
`_lifecycle_block_close_offset` advance past the real closer. The same mechanism
can borrow a slash from a following rule regex or quoted value on that line.
The original action lowers correctly when isolated; `.86.5` owns outer-context
recognition without changing the accepted shared precedence.

The context probe also retains separate owners:

- A callable body using either `div(14,2)` or `/(14,2)` reports the typed
  `unknown_helper` detail through `rule_handler_eval`. `CodeblockRuntime::_eval_call`
  has no numeric-helper route and falls through to a caller binding. `.87.3`
  owns numeric dispatch/alias repair with the established numeric contract.
- Parenthesized `out=(div(14,2))` reaches an undefined host `div`; the symbol
  twin reports a compile-stage unterminated search pattern. `.87.4` owns
  grouping-contract reconciliation and repair of admitted shapes. These probes
  alone do not admit a new grouping grammar.
- Unescaped regex braces remain the existing bootstrap `.54.1` defect: the
  assigned pattern loses its result without `last_error`, and the helper twin
  reaches `rule_handler_compile`. The escaped-brace assignment control returns7.
  Structural validation succeeds for these cases, so an EOF fix cannot claim
  that bootstrap repair.

## Physical-line-ending repair (.86.5.1)

The outer scanners supply their structural depth. For a bare slash candidate
inside a block, `_slash_call_before_final_block_closers` removes only line-ending
spaces/tabs, optional CR and closing braces from a temporary classification copy.
The shared balanced-call helper must consume the entire remaining call. Source
bytes are never rewritten, and explicit host regex/substitution operators keep
their existing route. The helper-validation view, edge scan and lifecycle-close
scan share this candidate rule.

Full-source precedence requires at most two validation attempts. The established
regex interpretation runs first. Only failure with a recorded final-call
candidate enables the line-ending exception; a successful alternative is
selected, otherwise the original diagnostics win. Each attempt buffers failure
callbacks and trace events. Only the selected attempt publishes them, after
dynamic trial state is restored. Thus accepted multiline patterns retain their
interpretation and reentrant callbacks cannot inherit an unfinished trial.

The rejected physical-line-only candidate explains why this is necessary.
In `docs/checkpoints/SESSION-STARTUP-READING.86.5-multiline-closers.pl`, assigned
`/(14,2) }` followed by `text/; return(7)` on the next line is a complete multiline
regex. The line-only exception stole its literal brace and changed two accepted
parser/no-error outcomes into top-level-content validation failures. The baseline
null result belongs to `.54.1`; it is not permission to change classification.
That candidate's interrupted Phase0 was stopped, consumed and excluded.

The revised candidate preserves all five multiline-closer records exactly.
The 15-context replay changes only bare/spaced division: both return `7` with
no error, depth zero and a lifecycle closer. Its context-free lexical field
intentionally calls without depth and remains unchanged. The original 12-case
replay changes only `slash_eof`/`slash_eof_space` to `7`; helper 13 plus its full
syntax record, grouped 22 and numeric 12 remain exact against the baseline.

Nine focused files pass 206 tests (eight files/190 plus diagnostic-output/16).
Consumer group 12 covers 11 action forms under LF/CRLF, live/emitted values and
source identity, plus five malformed/host-quote rejections. Group 13 adds 68
assertions for multiline-regex precedence, isolated diagnostics and callback
reentry. Clean-baseline replay completes all 13 groups and fails only 12/13.
The five exact book sources pass 82 public/fresh-generated assertions; the book
renders. Final source/test diff SHA-256:
`91821cd09b9991ce975862b4c83a62b0c899badb8c02fd62a8ed9dd8f89188d5`.
Full Phase0 passes 1033/1033. Same-line members remain `.86.5.2`-owned.


## Return-carrier qualification (.86.5.2.1)

The validation repair above remains verified. Its original numeric `7` checks
with I/regex/E did not independently prove the E path: [[perl-lifecycle-final-value-e-drift]]
records the existing `.27` omission and I value leakage. The corrected final-call
consumer and fifth exact book example use an explicit action edge, return `8`
after division assigns `7`, and reject mismatching input with `undef`. Focused
five files/31 and exact book/84 pass; the isolated old-example mutation fails
only book group7. Production matches `917b4a42a`; no new full Phase0 is claimed.
The permanent 30-case same-line intake is
`docs/checkpoints/SESSION-STARTUP-READING.86.5.2.pl`; interpret its no-edge values
with `.27` in mind. Same-line repair proceeds under `.86.5.2.2`.

## Same-line member repair (.86.5.2.2)

The candidate now uses the balanced-call end offset in the original fragment
and requires optional horizontal space followed by a closing brace. Other
members may follow that brace. Full-source regex-first trial selection and
explicit host quote exclusions remain unchanged; the shared MethodExpr
closing-brace safeguard is still intact.

The 30-case intake changes exactly eight bare-slash rows to their named-control
outcomes. The other 22 records are exact. Eleven explicit-edge shapes under
LF/CRLF prove live/emitted results, mismatching-input rejection and source
identity; consumer group14 passes and fails alone against clean `fb955602e`.
Nine focused files pass207 tests; five exact book examples pass84 assertions
and the rendered book uses a same-line edge for the fifth example.

Original12, helper13 plus syntax, grouped22, numeric12 and multiline-closer5
records remain exact against `.86.5.1`. In context15, only `next_member` and
`slash_in_quote` change their public outcome to successful division. Private
fragment-only fields also change for `next_named_slot` and two complete brace
patterns: without a full-source trial these probes apply the final-call
candidate directly. Those fields do not represent the selected full-source
interpretation. All production callers of these scans run inside the validation
trial; public regex outcomes and their error owners remain unchanged.

The named-div slot5 replay is unchanged and exposes independent metadata loss,
owned by required `.86.5.3`; see [[perl-same-line-regex-slot-metadata]]. This
repair does not claim lifecycle `.27`, bootstrap-brace `.54.1`, grouping or
callable support. Full Phase0 passes1033/1033 for frozen source/test diff
`86881406bf815024ee8c7cf00482ce547ebae315a6165fd350cfe9d258b05a92`.

The required `.86.5.3` slot follow-up is now verified; see
[[perl-same-line-regex-slot-metadata]]. Its final slot5 changes only the four
known failures to ready/value8 with correct identities; the separate-line control
is exact. The30 same-line replay changes only the three named-slot spellings,
and context15 changes only `next_named_slot` publicly. The earlier original,
helper, grouped, numeric and multiline-closer records remain exact.
