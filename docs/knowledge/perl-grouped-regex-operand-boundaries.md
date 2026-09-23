---
id: perl-grouped-regex-operand-boundaries
title: A group followed by dot or comma is misclassified as a numeric slash call in Perl regex operands
answers:
  - why does Perl reject a grouped regex followed by dot star
  - why does a comma inside a parenthesized regex become another helper argument
  - why does matches with a grouped pattern return undef in isolated lowering
  - which task repairs grouped regex operand punctuation
  - do string patterns avoid the grouped regex boundary failure
  - why cannot a complete slash token override numeric calls
  - is raw_perl AST fallback evidence that numeric syntax is invalid
date: 2026-09-24
status: confirmed; lookahead rejected under .86.4.8.1; required repair SESSION-STARTUP-READING.86.4.8.2
tags: [perl, regex, scanner, validation, actionir, public-api]
evidence: "SESSION-STARTUP-READING.86.4.4.1 public recomposition at committed9e2c26b1c measures22 fixed cases: four bare grouped-dot/comma failures and eighteen successful nearby/string/binding controls. All four public failures belong to validate_dsl_syntax. Production/tests remain unchanged. .86.4.8.1 rejects a complete-token lookahead using12 exact compatibility probes: accepted host-cos arithmetic changes [7,14] to [], and a numeric runtime error disappears. Required .86.4.8.2 precedes public closeout .86.4.4.2."
reverify: "bash tools/project_data_run.sh env PERL5LIB= perl -Iperl docs/checkpoints/SESSION-STARTUP-READING.86.4.4.1.pl; inspect all22 records; also run docs/checkpoints/SESSION-STARTUP-READING.86.4.8.1.pl through the same wrapper and inspect its12 public/AST/lowered records."
---

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
