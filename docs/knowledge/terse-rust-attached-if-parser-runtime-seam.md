---
id: terse-rust-attached-if-parser-runtime-seam
title: Rust attached-block if parity is a parser normalization seam over existing statement if runtime gating
answers:
  - "what does SPEC-FORMAT-TERSE.2.2.3 own"
  - "where should Rust attached if be implemented"
  - "does Rust runtime already have branch gating for if elseif else"
  - "does Rust CodeBlock parse attached if branch blocks"
date: 2026-06-30
status: current
tags: [spec-format-terse, rust-parity, control-flow, parser, runtime]
evidence: "SPEC-FORMAT-TERSE.2.2.3 ownership code-read. `rust/linkedspec-core/src/expr.rs` `CodeBlock::parse` parses semicolon/newline-separated statement expressions and expression-valued `{ ... }` blocks, but has no attached statement-block representation for `if(...) { ... } elseif(...) { ... } else { ... }`. `rust/linkedspec-runtime/src/engine.rs` already gates marker-form branch statements in `execute_block()` and `eval_block_value()` via `handle_statement_if_control`, which handles one-arg `if`/`elseif` and zero-arg `else`/`endif`. Therefore Rust attached-if parity should parse/normalize attached branch syntax into that existing statement-control model rather than add a second branch runtime. Focused existing parser smoke `cargo test --quiet --manifest-path rust/Cargo.toml -p linkedspec-core parse_lifecycle_block_content` passed with known nested `rgx` warning noise."
reverify: "rg -n 'fn parse_block|fn parse_statement_expr|fn parse_brace_expr|handle_statement_if_control|execute_block\\(|eval_block_value' rust/linkedspec-core/src/expr.rs rust/linkedspec-runtime/src/engine.rs && cargo test --quiet --manifest-path rust/Cargo.toml -p linkedspec-core parse_lifecycle_block_content"
---

Rust parity for Perl `.2.2.2` attached-block `if/elseif/else` is not primarily a new runtime feature.
The runtime already has branch gating for the marker sequence:

```text
if(cond);
...
elseif(cond2);
...
else();
...
endif()
```

The missing seam is parsing attached branch bodies inside `CodeBlock::parse`:

```text
if(cond) { ... } elseif(cond2) { ... } else { ... }
```

The implementation should preserve the existing lazy inline-composite `if(...)` helper and marker-form
`if(...); ... endif()` behavior, while normalizing attached branch bodies into a statement sequence the current
runtime can execute.
