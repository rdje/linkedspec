---
id: perl-multiline-helper-pattern-validation
title: Perl structural validation protects multiline helper patterns without rewriting compiled source
answers:
  - how does Perl validate a multiline regex helper operand
  - can rule like text inside a helper pattern become a rule or capture directive
  - does Perl preserve CRLF in an action regex pattern
  - why can multiline regex substitution still fail after validation succeeds
  - which task fixes multiline matches followed by a newline statement
date: 2026-09-23
status: validator repaired; statement lowering remains owned by .86.4.6
tags: [perl, validation, regex, source, diagnostics]
evidence: "SESSION-STARTUP-READING.86.4.3 replays six regression groups on accepted fd3a2444e source and the candidate. Accepted source fails groups1/2/3/5/6; the candidate passes all six. Validation fuzz, gap/slot and action-AST targets pass (six files/173 top-level tests); complete Phase0 passes1033/1033 in1211 seconds and includes the same consumer. No cross-backend or whole helper-family closeout follows."
reverify: "bash tools/project_data_run.sh env PERL5LIB= prove -Iperl t/multiline_helper_pattern_validation.t t/phase0_validation_fuzz.t t/inter_match_gap_capture_perl_contract.t t/duplicate_regex_slot_identity_perl_contract.t t/sparse_and_action_slots_perl_regression.t t/actionir_ast_parser.t"
---

The original public `matches` example in
`docs/checkpoints/SESSION-STARTUP-READING.86.4.2.4.pl` lowered and independently
executed to1 while whole-spec validation rejected the following rule. Physical
line scans discarded lexical state, and the closing `y/` became a translation
opener that swallowed structural closers.

`Validation::_helper_pattern_validation_view` recognizes complete slash tokens
at parenthesized argument boundaries with the existing slash-call discriminator.
It masks only multiline tokens, retaining every character position and CR/LF.
Metadata, rule/edge and leading-regex validation use that same structural view;
compiler input and diagnostic source remain original. Diagnostics use cumulative
physical line offsets, so repeated text inside a pattern cannot steal attribution
from a later real error. Assignment-position slash calls retain their existing line-based interpretation. No runtime value kind,
MethodExpr precedence or action-lowering behavior changes.

The regression consumer covers LF/CRLF exact subjects, public values and following
descriptors, structural-looking pattern payloads, real malformed following syntax,
division and isolated host quote controls, split/filter helpers, escaped slashes,
line-separated arguments, lifecycle placement, and original diagnostic lines.
CRLF is not silently normalized to LF. The consumer recurs from Phase0.

The expanded public matrix exposed three later failures, owned by `.86.4.6`:

- `text = "x\ny"; regex_subst(text, /x` + LF + `y/, "ok", g); return(text)`
  remains an unlowered host call and fails `runtime_handler:rule_handler_eval`.
- `hit = matches("x\ny", /x` + LF + `y/)` + LF +
  `note = 7; return(array(hit, note))` loses statement lowering and fails
  `runtime_handler:rule_handler_compile`.
- `if(true); hit = matches("x\ny", /x` + LF + `y/); endif` in an `I` block
  leaves an unlowered `matches` call and fails handler execution.

The three StatementSplit probes join the helper with its following statement or
`endif`. `StatementSplit::Mode::maybe_enter_slash_quote` recognizes host quote
operators and match operators, but no naked helper operand. Its closing `y/`
opens a two-segment translation and consumes real separators. `.86.4.6` must
repair argument context without reintroducing the rejected assignment-precedence
expansion. The existing AST/lowering owners can only lower the fragments the
splitter actually supplies.

Place an action in `Top::` / ` -> Done { ACTION }` / `Done:` / ` /x/`, or put
the conditional in `I { ACTION }` before ` -> Done { return(hit) }`. Use public
`Get` with `runtime_ctx_ref`, execute on `x`, and inspect both errors and
`call_spec_handler_subst("Top", ACTION)`. These are supported-helper defects,
not evidence for a regex-variable feature. `.86.4.4` requires their repair before
public recomposition; `.87.1/.87.2` retain the independent helper owners.

Startup rechecked the three director-supplied policy donor files read-only.
Their SHA-256 values match the September11 record in the startup task; no donor
update or new policy adoption was inferred. `.5/.29` retain adoption ownership.
