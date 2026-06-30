---
id: terse-rust-attached-if-parser-runtime-seam
title: Rust attached-block if parity landed as parser normalization over existing statement if runtime gating
answers:
  - "what does SPEC-FORMAT-TERSE.2.2.3 own"
  - "where should Rust attached if be implemented"
  - "does Rust runtime already have branch gating for if elseif else"
  - "does Rust CodeBlock parse attached if branch blocks"
date: 2026-06-30
status: current
tags: [spec-format-terse, rust-parity, control-flow, parser, runtime]
evidence: "SPEC-FORMAT-TERSE.2.2.3 implementation. `rust/linkedspec-core/src/expr.rs` now parses attached statement branches `if(...) { ... } elseif(...) { ... } else { ... }` before ordinary statement-expression parsing, normalizes them to existing `if`/`elseif`/`else`/`endif` call statements, and preserves the separator contract after the final attached block. `rust/linkedspec-runtime/src/engine.rs` needed no new branch runtime because marker-form branch statements are already gated in `execute_block()` and `eval_block_value()` via `handle_statement_if_control`. Focused parser/runtime/oracle checks passed: core `attached_if`, runtime `terse_2_2_3`, and corpus oracle with fixture `terse_2_2_3_attached_if_blocks`."
reverify: "cargo test --quiet --manifest-path rust/Cargo.toml -p linkedspec-core attached_if && cargo test --quiet --manifest-path rust/Cargo.toml -p linkedspec-runtime terse_2_2_3 && cargo test --quiet --manifest-path rust/Cargo.toml -p linkedspec-runtime oracle_corpus_matches_perl_reference"
---

Rust parity for Perl `.2.2.2` attached-block `if/elseif/else` landed without adding a second runtime branch
engine. The runtime already had branch gating for the marker sequence:

```text
if(cond);
...
elseif(cond2);
...
else();
...
endif()
```

The implementation seam was parsing attached branch bodies inside `CodeBlock::parse`:

```text
if(cond) { ... } elseif(cond2) { ... } else { ... }
```

The parser now preserves the existing lazy inline-composite `if(...)` helper and marker-form
`if(...); ... endif()` behavior, while normalizing attached branch bodies into the statement sequence the
current runtime already executes.
