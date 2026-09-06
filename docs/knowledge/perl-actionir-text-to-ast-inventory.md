---
id: perl-actionir-text-to-ast-inventory
title: Perl ActionIR text-to-AST migration inventory
answers:
  - "where is Perl ActionIR text-to-text lowering"
  - "what replaces Perl RewritePipeline source span rewriting"
  - "which Perl modules scan ActionIR source text"
  - "what is the Perl ActionIR AST node set"
  - "how should Perl ActionIR migrate to AST"
date: 2026-07-01
status: current
tags: [actionir, ast, perl-reference, lowering, migration]
evidence: "PERL-ACTIONIR-AST-MIGRATION.1 inventoried StatementSplit/MethodExpr/Scanner/CanonicalEvents/RewritePipeline/MethodLowering/RuleIR::EmitContext and defined a Rust-aligned AST node set plus replacement order. RewritePipeline::_lower_action_code_from_canonical_ir currently finds raw source spans and substr-replaces them with lowered Perl; MethodLowering::_lower_method_value_expr now consumes AST for value/call/chain nodes, _lower_return_payload_expr now consumes AST for typed return payloads before raw fallback, assignment/mutation operator statements now consume AST fields, helper-call statements/returns now consume AST call/fluent-chain fields, and block-value internals now consume AST block/statement fields. The AST parser now also represents structured-control statement syntax as typed control nodes; if-family controls lower from typed condition/body nodes, switch/case/default controls lower from typed source/match/body/default/end nodes, and attached while controls lower from typed condition/body nodes. RuleIR::EmitContext still applies the rewrite to lifecycle/action blocks and auto-working-var discovery scans raw code."
last_verified: 2026-09-06
reverify: "rg -n '_lower_action_code_from_canonical_ir|_find_source_stmt_span|_lower_method_value_expr|_lower_return_payload_expr|_collect_auto_working_var_decls|split_action_ir_statements|_parse_method_function_expr' perl/LinkedSpec/ActionIR perl/LinkedSpec/RuleIR/EmitContext.pm"
---

The current Perl ActionIR path still lowers supported helper/action surfaces through raw
text in several places:

- `StatementSplit` and `StatementSplit::Core` split raw action code into source strings.
- `MethodExpr` recognizes method-call shape and returns raw argument strings.
- `Scanner`/`ScannerCore` and scanner rule families find helper-like surfaces in raw code.
- `Contracts` contains legacy lowering callbacks that transform source text.
- `CanonicalEvents` emits `RAW_PERL` fallback for unrecognized source statements.
- `RewritePipeline` matches canonical events back into the original source and replaces
  those spans with lowered Perl strings.
- `MethodLowering` now consumes AST for supported value/call/receiver-chain nodes, typed
  return payloads, assignment/mutation operator statements, and helper-call
  statements/returns. Expression-valued block side effects, block-local returns, and
  final expressions now consume AST block/statement fields. The parser seam now covers
  typed structured-control statement nodes. `if`/`when`/`otherwise` controls lower from
  typed condition/body nodes, and `switch`/`case`/`default` controls lower from typed
  source/match/body/default/end nodes. Attached `while` controls lower from typed
  condition/body nodes. Raw fallback remains for untyped compatibility payloads and
  the compatibility boundaries audited by completed `.5` work; see
  [[perl-actionir-fallback-boundary-audit]].
- `RuleIR::EmitContext` applies the rewrite to action/lifecycle blocks and still scans raw
  pre-lowered code for automatic working-variable declarations.

The migration target is a Rust-aligned typed AST: `ActionBlock`/`ActionStmt`, `Call`,
`FluentChain` or `ReceiverChain`, typed value/literal/access nodes, assignment/mutation
nodes, typed control nodes, and return/print nodes with source spans. Standalone
expression statements drop their value silently.

The historical replacement order was parser seam, value/receiver lowering, statement/
control lowering, and supported-surface fallback audit. Registered function calls now
execute through AST call nodes; [[terse-user-function-value-call-execution]] and
[[terse-user-function-standalone-discard-hardening]] own value and statement execution.
This does not remove the current source-span rewrite orchestration.
