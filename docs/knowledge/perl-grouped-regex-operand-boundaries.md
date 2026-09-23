---
id: perl-grouped-regex-operand-boundaries
title: Perl helper context protects grouped regex operands while preserving numeric calls
answers:
  - why does Perl reject a grouped regex followed by dot star
  - why does a comma inside a parenthesized regex become another helper argument
  - why does matches with a grouped pattern return undef in isolated lowering
  - which task repairs grouped regex operand punctuation
  - do string patterns avoid the grouped regex boundary failure
  - why cannot a complete slash token override numeric calls
  - is raw_perl AST fallback evidence that numeric syntax is invalid
  - how does Perl preserve grouped regex operand bytes and source spans
  - why does receiver filter_match need synthetic helper pattern context
  - why does a quoted regex payload need the return scanner structural view
  - can q m or qr variables contain grouped regex helper calls in an index
date: 2026-09-24
status: .86.4.8.2 repair verified; public recomposition .86.4.4.2 remains
tags: [perl, regex, scanner, validation, actionir, public-api]
evidence: ".86.4.8.2 passes focused187, exact four-example book21 and complete Phase0 1033/1033. Exact accepted-source replay fails only new group10; nine original numeric/error checkpoint records remain byte-identical. The original22 public cases now succeed; prior intake and rejected-lookahead observations below retain their dated baseline."
reverify: "bash tools/project_data_run.sh env PERL5LIB= perl -Iperl docs/checkpoints/SESSION-STARTUP-READING.86.4.4.1.pl; expect22 successful public cases; also run docs/checkpoints/SESSION-STARTUP-READING.86.4.8.1.pl through the same wrapper and inspect its12 public/AST/lowered records."
---


## Current repair (.86.4.8.2)

The accepted repair recognizes pattern positions in `matches`, `split`, `split_each`,
`filter_match`, and the existing `regex_subst`/`substr` substitution contract.
Receiver calls retain their argument role. Synthetic `__array_value_split_each`
and `__array_value_filter_match` calls retain that role during existing receiver
lowering. A closing slash and flags must satisfy the helper's remaining call
shape; the substitution route still requires its separate replacement and flags.

Numeric-call boundaries are derived by the unchanged parenthesis/quote scan.
A candidate pattern cannot borrow a slash beyond the caller or from a complete
quoted numeric argument. Tested q/qq pipe and brace payloads remain opaque to helper discovery. Square brackets remain DSL indexed reads, including q[index], m[index] and qr[index]; helper calls inside those indexes must remain visible. The parser
never executes authored text to select its interpretation, and assignment-position
precedence is unchanged.

`MethodExpr::_helper_pattern_view` preserves character offsets and every CR/LF
while masking recognized pattern bodies for structural parsing. CSV consumers
receive the method/receiver context and return slices from the original source.
AST arguments retain typed regex fields and original source spans rather than
being split into a numeric call or fluent dot segment. The return scanner uses
the same structural view; the return contract lowers a complete authored call
before its legacy text-substitution fallback. That last seam was necessary for
`return(matches('x,"', /(x),"/))`: a correct AST alone did not make its scanner
recognize the enclosing return.

Focused proof covers all22 original public cases, the permanent12-case numeric/
host diagnostic, literal/string/binding twins, LF/CRLF, flags, punctuation and
quoted payloads, nested helpers/control, substitution, receiver filtering and
independent generated continuation results. All nine numeric/error controls in
the12-case checkpoint retain their values and failure stages. The expanded
consumer has11 groups: exact accepted-source replay fails only group10; the
repair passes. Seven dependent files add176 passing tests (187 total across
8 files). All four complete mdBook examples pass21 live/generated assertions.
The first Phase0 run was stopped for the final indexed-variable correction and does not count. Fresh full Phase0 passes1033/1033 (Files=1, Tests=1033, 1423 wallclock secs ( 0.44 usr  0.10 sys + 1086.49 cusr 125.81 csys = 1212.84 CPU)), with the frozen source/test diff unchanged. Public loader/generated recomposition remains `.86.4.4.2`.

The original22-case checkpoint's `helper_arguments` field intentionally invokes
context-free CSV splitting. Actual method parsing now supplies the helper role;
use its public/typed/lowered results to verify the repair, not that isolated
context-free CSV field. The12-case diagnostic and permanent consumer preserve
exact numeric and raw-host counterexamples from the rejected lookahead below.

Inline comment text `# pattern/)` exposes a separate pre-existing structural
validation defect. Its fixed six-case diagnostic is
`docs/checkpoints/SESSION-STARTUP-READING.86.4.8.2-comments.pl`; existing `.34.1`
owns the repair with [[perl-comment-newline-lowering-drift]]. All lowered actions
return1; both inline public cases fail, while both no-comment and standalone
comment twins return1. This helper repair does not claim that comment gap fixed.

## Intake baseline (9e2c26b1c; retained history)

`return(matches("xy", /(x).*y/))` and its assignment-plus-continuation twin
fail public validation, as do the corresponding `/(x),y/` cases on `x,y`.
The following `Done:` rule is reported as inside an open block. A grouped
pattern followed by `#` or space, and the ungrouped `/x.*y/`, work. Quoted
string and string-binding twins of the dot/comma patterns also work, both as
direct returns and before `note = 7; return(array(hit, note))`.

`MethodExpr::_looks_like_slash_symbol_call_at` returns true when the first
balanced parenthesis is followed by comma, semicolon, dot, `)` or `]`, or the
fragment ends. In these bare operands the dot/comma belongs to the regex body.
The predicate is shared by `Validation::_consume_slash_construct`,
`StatementSplit::Core`, `MethodExpr::_split_top_level_csv` and AST regex
recognition. The quote protections in `.86.4.3/.86.4.6/.86.4.7` deliberately
preserve that predicate, so they do not resolve this classification error.

The tracked diagnostic exposes the intermediate behavior:

- The dot direct-return action lowers and independently returns1 even though
  whole-source validation rejects it.
- The comma direct-return action lowers to the existing unsupported-`matches`
  marker and undef; CSV segmentation sees the regex comma as another argument.
- Both continuation actions remain one joined StatementSplit fragment. Their
  lowered code leaves the helper unlowered and fails independent compilation.
- Public string and binding twins return1, or `[1,7]` with continuation.

`.86.4.8` must reconcile operand boundaries across these consumers, retaining
existing successful numeric calls and malformed diagnostics. Do not apply an
unqualified full-source regex preference: the earlier rejected candidates changed
accepted division results. See [[perl-multiline-regex-scanner-boundaries]] and
[[action-regex-operands-and-runtime-kinds]]. No regex runtime type is introduced.
Public recomposition `.86.4.4.2` waits for the repair; this is not a parked finding
or a whole helper-family acceptance claim.

## Rejected complete-token lookahead (.86.4.8.1)

A candidate recognizes a first unescaped closing slash plus flags and an operand
boundary, excludes assignment-position context, and avoids borrowing delimiters
from complete quoted numeric arguments or an outer argument list. It fixes all22
original diagnostic cases, but remains incompatible. The exact patch is retained
at `docs/checkpoints/SESSION-STARTUP-READING.86.4.8.1.patch`; it is rejected evidence,
not an implementation to apply. Its base is `f3f9fc74db17286b5d5d0913bdb55d5e135fe8ad`.

The fixed12-case checkpoint records both AST and public execution. Three decisive
comparisons are:

| Authored action | Accepted source | Rejected lookahead |
| --- | --- | --- |
| `return(array(/(14,2), 14/cos))` | `[7,14]`, no error | `[]`, no error |
| `i = 2; return(array(/(14,2), 14/i))` | `rule_handler_eval`, illegal division by zero | `[]`, no error |
| `return(matches('x,"', /(x),"/))` | `validate_dsl_syntax` failure | `rule_handler_eval` failure |

The first accepted AST contains a numeric `/` call and a `raw_perl` expression
`14/cos`. The candidate merges both arguments into a regex node with body
`(14,2), 14` and flags `cos`. Therefore a `raw_perl` AST node is not evidence that
the numeric interpretation is invalid. The experiment executes only these fixed
fixtures; a future discriminator must not eval arbitrary authored text to choose
its grammar, since compilation may have effects.

The quote/receiver controls stay `[7,"a/)"]`, `[7,1]` and `[8,"a/)"]`; an outside
comment retains8. A comment inside the argument list changes failure ownership
from `rule_handler_compile` to `validate_dsl_syntax`. The wrong-arity quoted
follower remains `[undef,"a/)"]`. A flagged grouped-comma pattern improves from
validation failure to1; the numeric-looking grouped-dot pattern remains1.
These selective improvements do not excuse the changed numeric outcomes.

`.86.4.8.2` owns consistent grammar/context recognition and quoted-pattern call
parsing before public closeout. The existing numeric compatibility constraint
continues to apply; no precedence change, host-compatibility removal or regex
runtime type is authorized. Production and tests are restored exactly to the base;
the existing nine-group consumer is the focused restoration proof. The patch hash
is `cdd1804d64b52f19dc45325ff1fef03090b985ee9e36d7396e4eaa7245692d71`;
reconstructed candidate MethodExpr is `47ee2cff2a8d401b3e9892574cd2e868ad70a889b24d1c08cc46669f315dd3a2`,
and restored MethodExpr is `544e019b0db592ac65a2c7a19c5eb5d8f86b6e8883f78a84739dd65bccd9884d`.
