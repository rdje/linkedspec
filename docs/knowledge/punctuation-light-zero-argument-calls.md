---
id: punctuation-light-zero-argument-calls
title: "ADR 0033 and FUTURE-PARITY-BACKLOG.16.0 — zero-argument punctuation-light syntax is a narrow alias contract, not a general parenthesis-free call grammar."
answers:
  - "can else endif default endcase endswitch omit parentheses"
  - "can next be written without parentheses"
  - "can a final zero argument receiver method omit parentheses"
  - "can an intermediate receiver method omit parentheses"
  - "can if and while conditions omit parentheses"
  - "which backends already parse bare control markers"
  - "what owns punctuation light zero argument calls"
date: 2026-07-13
status: confirmed
tags: [dsl, actionir, calls, control-flow, syntax, parity, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.16.0 read-only source audit and ADR 0033. All five rule-edge/lifecycle suffix parsers already record a missing argument list as zero arguments. On typed ActionIR paths, Perl/Dart/Julia normalize bare else/endif/default/endcase/endswitch; Rust leaves bare words as value reads outside attached-control synthesis; Lua normalizes only else/otherwise/default. No backend currently treats bare next as next(). Perl/Rust/Dart/Julia require parentheses on every ActionIR receiver segment, while Lua accepts a bare identifier in every segment. ADR 0033 adopts six standalone marker aliases and a generic bare final receiver segment, preserves normal arity validation and all parenthesized forms, and excludes intermediate generic bare calls, calls with arguments, arbitrary helper/user-function calls, attached final-codeblock calls, and parenthesis-free if/while condition headers. Implementation is owned by .16.1-.16.7."
reverify: "rg -n '_normalize_bare_zero_arg_flow_marker_expr|_normalizeControlHead|_action_normalize_control_head|parse_control|parse_fluent_chain|parse_fluent_call' perl/LinkedSpec rust/linkedspec-core/src dart/lib/src julia/src lua/src/linkedspec"
---

# Punctuation-light zero-argument calls

Parentheses remain LinkedSpec's general call grammar. ADR 0033 adds only a bounded alias surface:

- `else`, `endif`, `default`, `endcase`, `endswitch`, and `next` are intended to equal their zero-argument
  statement calls wherever those calls are valid;
- a final ActionIR receiver segment may use `.method` in place of `.method()` and still goes through ordinary
  zero-argument contract/arity validation;
- existing parenthesized forms remain valid.

This does not authorize parenthesis-free `if`/`while` conditions, general helper or user-function calls,
argument-bearing calls, attached final-codeblock calls, or intermediate generic receiver segments. Existing named
control-marker fluent suffixes remain their own established exception.

The audit found backend drift, so the target contract must not be described as fully implemented until
`FUTURE-PARITY-BACKLOG.16.2-.16.7` close.

## Links

- ADR: `docs/decisions/0033-punctuation-light-zero-argument-calls.md`
- Tree: `docs/tasks/FUTURE-PARITY-BACKLOG.md`, leaf `.16.0`
- Related: [[terse-call-spacing-contract]]
