---
id: perl-actionir-ast-block-value-lowering
title: Perl block values consume ActionIR AST block/statement nodes
answers:
  - "are Perl expression-valued block statements lowered from AST"
  - "does block-local return lowering consume AST"
  - "does _lower_block_value_expr still split source text first"
  - "which leaf moved block-value statements to AST"
  - "how are block-value side effects lowered in Perl ActionIR"
date: 2026-07-01
status: current
tags: [actionir, ast, perl-reference, method-lowering, block-values]
evidence: "PERL-ACTIONIR-AST-MIGRATION.4.3 changed MethodLowering so parsed block_value nodes route through the AST value path before the legacy block splitter. Inside AST block values, non-final side-effect statements lower from action_stmt.expr nodes, block-local return payloads lower from typed return call arguments, and final block expressions lower from typed statement expressions. The existing guarded $__ls_block_done / $__ls_block_value early-return shape and legacy fallback remain stable. Focused t/actionir_ast_parser.t coverage poisons original block text and every AST source field to prove the output comes from typed block/statement fields."
reverify: "prove -Iperl t/actionir_ast_parser.t && prove -q -Iperl t/phase0_regression.t"
---

# Perl ActionIR Block-Value AST Lowering

`PERL-ACTIONIR-AST-MIGRATION.4.3` moves expression-valued block internals from source-text splitting toward
typed AST traversal.

The relevant nodes are:

- `block_value`
- `action_block`
- `action_stmt`

For a block such as:

```text
{ set(x, "a"); return(value); set(y, "b"); y }
```

the Perl lowering path now consumes the parsed statement expressions:

- `set(x, "a")` from the first statement's typed call node;
- `return(value)` as a block-local return payload from the typed return call argument;
- `set(y, "b")` as a guarded post-return side-effect statement;
- `y` as the final block expression.

The generated Perl shape is intentionally unchanged for non-final block-local returns:
it still uses the `__ls_block_done` / `__ls_block_value` guard wrapper so later block
statements are skipped at runtime after a block-local return. Legacy source splitting is
still retained as fallback for compatibility surfaces that the typed AST path cannot
materialize yet.
