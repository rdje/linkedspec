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
status: .86.5.1 verified; .86.5.2 and .87.3/.87.4 remain
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
