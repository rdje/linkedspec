---
id: perl-multiline-helper-pattern-validation
title: Perl helper patterns retain structure and statement boundaries through validation and lowering
answers:
  - how does Perl validate a multiline regex helper operand
  - can rule like text inside a helper pattern become a rule or capture directive
  - does Perl preserve CRLF in an action regex pattern
  - why did multiline regex substitution fail after validation succeeded
  - which task fixes multiline matches followed by a newline statement
  - why does a quoted multiline regex subject fail validation
  - why does closing y slash swallow the next action statement
date: 2026-09-23
status: validator and helper statement splitting repaired; quoted subject validation remains .86.4.7
tags: [perl, validation, regex, source, diagnostics]
evidence: "SESSION-STARTUP-READING.86.4.3 passes six regression groups, focused173 and complete Phase0 1033/1033. .86.4.6 expands the consumer to seven groups: isolated committed d2af200325 fails groups5/7; candidate focused action suite passes52 top-level tests across four files. Both retained division controls independently/publicly return7; complete Phase0 passes1033/1033 in1545 seconds with the seven-group consumer. Both complete mdBook examples pass11 directly extracted live/generated assertions and rendering succeeds. No cross-backend or whole helper-family closeout follows."
reverify: "bash tools/project_data_run.sh env PERL5LIB= prove -Iperl t/multiline_helper_pattern_validation.t t/actionir_ast_parser.t t/uniform_binding_contract.t t/callable_codeblock_literal_contract.t"
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
MethodExpr precedence changes in the validator repair.

The regression consumer covers LF/CRLF exact subjects, public values and following
descriptors, structural-looking pattern payloads, real malformed following syntax,
division and isolated host quote controls, split/filter helpers, escaped slashes,
line-separated arguments, lifecycle placement, and original diagnostic lines.
CRLF is not silently normalized to LF. The consumer recurs from Phase0.

The expanded public matrix exposed three later failures, repaired by `.86.4.6`:

- `text = "x\ny"; regex_subst(text, /x` + LF + `y/, "ok", g); return(text)`
  was an unlowered host call and failed `runtime_handler:rule_handler_eval`.
- `hit = matches("x\ny", /x` + LF + `y/)` + LF +
  `note = 7; return(array(hit, note))` lost statement lowering and failed
  `runtime_handler:rule_handler_compile`.
- `if(true); hit = matches("x\ny", /x` + LF + `y/); endif` in an `I` block
  left an unlowered `matches` call and failed handler execution.

The three original StatementSplit probes joined the helper with its following
statement or `endif`. `StatementSplit::Mode::maybe_enter_slash_quote` recognized
host quote/match operators, but no naked helper operand. A closing `y/` opened a
two-segment translation and consumed real separators, even for single-line `/y/`.
Core now recognizes an argument-start slash in parentheses and applies the
existing MethodExpr numeric-call discriminator before entering one-segment quote
state. Original bytes flow to the existing AST/lowering owners; assignment
precedence stays unchanged. Permanent coverage includes LF/CRLF, eight
host-operator-like suffixes, punctuation, once-only mutation, nested numeric
operands, following statements/conditional terminators and independently emitted
execution for all three line-ending families.

Place an action in `Top::` / ` -> Done { ACTION }` / `Done:` / ` /x/`, or put
the conditional in `I { ACTION }` before ` -> Done { return(hit) }`. Use public
`Get` with `runtime_ctx_ref`, execute on `x`, and inspect both errors and
`call_spec_handler_subst("Top", ACTION)`. These are supported-helper defects,
not evidence for a regex-variable feature. `.87.1/.87.2` retain the independent
helper owners.

The repaired substitution regression obtains the exact subject through
`match_text()`. Expanded fixtures exposed two separate string defects; changing
that fixture does not resolve them. `docs/checkpoints/SESSION-STARTUP-READING.86.4.6.pl`
is the permanent public/lowered diagnostic:

- With physical LF in both an assigned quoted subject and its regex, isolated
  lowering returns `ok`, but public validation reports an unexpected `}` at line4.
  The helper view skips the quoted token, leaving its bytes in the structural
  view. `_scan_rule_edges_in_fragment` resets quote state on each line: the
  second-line closing quote is read as an opener, swallowing the helper's open
  parenthesis while its later close decrements real block depth. `.86.4.7` owns
  the repair and is required before `.86.4.4` public recomposition.
- Textual `\n` survives assignment/return/cat-assignment lowering as literal
  backslash-plus-`n`, but decodes to LF in the inline matches/cat subject route.
  This is additional evidence for existing string-fidelity owner
  `SUPPORTING-SOURCE-READING.2.4`; see [[single-quoted-action-strings-variant-contract]].
  This regex repair does not choose new escape semantics.

Startup rechecked the three director-supplied policy donor files read-only.
Their SHA-256 values match the September11 record in the startup task; no donor
update or new policy adoption was inferred. `.5/.29` retain adoption ownership.
