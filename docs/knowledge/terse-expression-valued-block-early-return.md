---
id: terse-expression-valued-block-early-return
title: "SPEC-FORMAT-TERSE.2.1.4 - Expression-valued blocks support block-local early return."
answers:
  - "do expression-valued blocks support early return"
  - "does return({ return(\"a\"); \"b\" }) work now"
  - "does return(expr) inside a block value leak to the surrounding rule"
  - "where is block-local early return implemented"
  - "what did SPEC-FORMAT-TERSE.2.1.4 land"
  - "how do Perl and Rust skip later block statements after return(expr)"
date: 2026-06-30
status: confirmed
tags: [dsl, blocks, expressions, actionir, perl, rust, runtime, spec-format-terse, SPEC-FORMAT-TERSE]
evidence: "SPEC-FORMAT-TERSE.2.1.4 on 2026-06-30 closed the early-return boundary for expression-valued blocks. Perl lowering in perl/LinkedSpec/ActionIR/MethodLowering.pm detects return(expr) inside non-empty non-fat-arrow brace value blocks and emits a guarded do-block with $__ls_block_done / $__ls_block_value, so return(expr) yields the block value and skips later statements without emitting a nested Perl handler return. Rust runtime eval_block_value() in rust/linkedspec-runtime/src/engine.rs now checks return_call_payload() for each active block statement before final-expression handling, evaluates the payload, and returns it from the block without setting the rule return channel. Locks: phase0 spec_format_terse_2_1_2_perl_expression_valued_blocks expanded to early-return cases, Rust terse_2_1_4 integration tests, and the Perl-oracle fixture terse_2_1_4_expression_valued_block_early_return."
reverify: "perl -Iperl -MLinkedSpec -e 'print LinkedSpec::call_spec_handler_subst(q{Top}, q{return({ return(\"a\"); \"b\" })}), qq{\\n}' && cargo test --quiet --manifest-path rust/Cargo.toml -p linkedspec-runtime terse_2_1_4_expression_valued_block && cargo test --quiet --manifest-path rust/Cargo.toml -p linkedspec-runtime oracle_corpus_matches_perl_reference"
---

# Expression-Valued Block Early Return

`SPEC-FORMAT-TERSE.2.1.4` makes `return(expr)` block-local inside expression-valued blocks on both the Perl
reference and Rust backend.

The current contract:

- `{}` and top-level-fat-arrow `{ key => value }` remain hash literals.
- A non-empty brace payload without top-level `=>` is an expression-valued block.
- If execution reaches `return(expr)` inside that block, the block value is `expr`.
- Later statements in the same expression-valued block are skipped.
- The surrounding rule return channel is not set by the block-local return.

Examples:

```text
return({ return("a"); "b" })                                  # "a"
set(out, { set(x, "a"); return(x); set(x, "b"); x }); return(out)  # "a"
return(array({ return("a"); "b" }, { set(x, "c"); return({ "k" => x }); "bad" }))
```

The implementation remains value-specific. Lifecycle blocks still execute through their statement block path;
rule-level `return(payload)` is still an explicit helper call in the surrounding action.
