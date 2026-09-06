---
id: perl-actionir-nested-block-span-loss
title: Perl eager and attached blocks can reset nested ActionIR source offsets
answers:
  - "why does a nested Perl action diagnostic point near the start of its body"
  - "which Perl AST block parsers lose base_start"
  - "do Perl callable and receiver callback blocks preserve nested source offsets"
  - "where is nested Perl ActionIR span repair owned"
date: 2026-09-06
status: confirmed defect; SESSION-STARTUP-READING.15 owns repair after required reading
tags: [perl, actionir, ast, diagnostics, source-span, defect]
evidence: "SESSION-STARTUP-READING.3.2.16 read AST/Parser.pm 1–1498 at unchanged baeb984e. Seven ASCII and two Unicode direct AST controls isolate missing base_start in eager braces, attached function calls, and attached controls. Public Get logs the same inner-body offset and retains its blessed Diagnostic in last_error.detail. Existing parser/punctuation suites pass 30 top-level tests without detecting this gap."
reverify: "rg -n 'parse_action_block[(][$](attached|payload|body_source)' perl/LinkedSpec/ActionIR/AST/Parser.pm"
---

At base_start 100, an empty nested-write selector must retain its location in the containing expression.
All seven controls throw `nested_write_segment_empty`, stage `action_parse`, with an authored Unicode-scalar span:

| Expression | Expected span | Observed span |
| --- | --- | --- |
| `tree[] = 1` | 104–106 | 104–106 |
| `{ tree[] = 1 }` | 106–108 | 5–7 |
| `if(true) { tree[] = 1 }` | 115–117 | 5–7 |
| `f() { tree[] = 1 }` | 110–112 | 5–7 |
| `value.with() { tree[] = 1 }` | 119–121 | 119–121 |
| `{|| tree[] = 1 }` | 108–110 | 108–110 |
| `tree.map_leaves!() { tree[] = 1 }` | 125–127 | 125–127 |

The direct AST facade accepts `parse_action_expr($source, {base_start => 100})`; expected spans above are
`100 + index($source, '[]')` through two characters later. Inserting `note("é😀"); ` before the bad write
gives attached-if 17–19 instead of 127–129, while the receiver callback correctly gives 131–133.

The three recursive `parse_action_block` calls at AST/Parser.pm lines 367, 400, and 655 omit `base_start`.
That function defaults its base to zero. Callable literals (677), map_leaves! callbacks (1262), and receiver
trailing blocks (1430) explicitly propagate the body start. The parent block spans alone cannot repair the
already-created child nodes or a thrown diagnostic.

Public `Get` on `Top: /x/ -> Top { if(true) { tree[] = 1 } }` rejects compilation and logs span 5–7.
With the documented HASH `runtime_ctx_ref`, the complete typed object remains in `last_error.detail`; the
outer error is `compiler_pipeline`, stage `build_compiled_rule_table`. An initial scalar-context probe was
invalid for that API and supplies no context evidence. JSON encoding with `allow_blessed` rendered the detail
as null; explicitly projecting the blessed hash proved the object was retained. No diagnostic-erasure defect
is claimed. The public receiver-callback control logs its enclosing action offset 20–22 instead.

`t/actionir_ast_parser.t` and `t/punctuation_light_zero_arg_contract.t` pass 30 top-level tests. This is a new
coverage gap, not evidence that valid action execution changed. No source repair, independent loaded-source
failure, or other-backend failure was performed in the reading checkpoint.

Repair `.15` must propagate offsets through all affected nested paths and lock success nodes as well as
diagnostics, without altering valid syntax, rejection, or source units. Related: [[perl-actionir-ast-parser-seam]],
[[perl-callable-codeblock-literal-record]], [[write-vivification-neutral-contract]].
