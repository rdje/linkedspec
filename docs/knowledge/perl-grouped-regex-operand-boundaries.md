---
id: perl-grouped-regex-operand-boundaries
title: A group followed by dot or comma is misclassified as a numeric slash call in Perl regex operands
answers:
  - why does Perl reject a grouped regex followed by dot star
  - why does a comma inside a parenthesized regex become another helper argument
  - why does matches with a grouped pattern return undef in isolated lowering
  - which task repairs grouped regex operand punctuation
  - do string patterns avoid the grouped regex boundary failure
date: 2026-09-24
status: confirmed; required repair SESSION-STARTUP-READING.86.4.8
tags: [perl, regex, scanner, validation, actionir, public-api]
evidence: "SESSION-STARTUP-READING.86.4.4.1 public recomposition at committed9e2c26b1c measures22 fixed cases: four bare grouped-dot/comma failures and eighteen successful nearby/string/binding controls. All four public failures belong to validate_dsl_syntax. Production and tests are unchanged in this intake; .86.4.8 is required before public closeout .86.4.4.2."
reverify: "bash tools/project_data_run.sh env PERL5LIB= perl -Iperl docs/checkpoints/SESSION-STARTUP-READING.86.4.4.1.pl; inspect all22 JSON records, public/lowered values, helper arguments, statement parts and structured errors."
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
