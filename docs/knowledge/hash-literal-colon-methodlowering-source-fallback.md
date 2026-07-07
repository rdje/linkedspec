---
id: hash-literal-colon-methodlowering-source-fallback
title: "Perl MethodLowering source fallback scans both : and => hash-pair separators."
answers:
  - "why did colon hash literal inside expression-valued block receiver fail"
  - "where does Perl MethodLowering scan hash pair separators"
  - "does block-valued receiver chaining lower nested colon hash literals"
  - "what fixed SPEC-FORMAT-TERSE.9.4 MethodLowering fallback"
date: 2026-07-07
status: current
tags: [spec-format-terse, hash-literal, colon-association, method-lowering, expression-valued-blocks, perl, SPEC-FORMAT-TERSE]
evidence: "SPEC-FORMAT-TERSE.9.4 migrated current block-valued receiver-chain fixtures from `{ { \"b\" => 2, \"a\" => 1 } }.sorted_keys().join_values(\",\")` to `{ { \"b\" : 2, \"a\" : 1 } }.sorted_keys().join_values(\",\")`. That exposed a Perl reference fallback seam in `perl/LinkedSpec/ActionIR/MethodLowering.pm`: the source scanners used by `_has_top_level_fat_arrow` and `_lower_method_value_expr` recognized only top-level `=>`, so a nested colon hash literal inside an expression-valued block could be classified/lowered incorrectly and return null. The fix keeps the scanner source-level and migration-scoped: it accepts top-level `:` as a hash-pair separator alongside old `=>`, skips `::`, and preserves generated Perl host `=>` output. Phase0 subtest `spec_format_terse_2_3_5_5_block_valued_receiver_chains` locks the current colon source and returns `\"a,b\"`; the Rust oracle fixture `terse_2_3_5_5_block_valued_receiver_chains` uses the same colon source."
reverify: "perl -Iperl -MLinkedSpec -e 'print LinkedSpec::call_spec_handler_subst(\"Top\", q{return({ { \"b\" : 2, \"a\" : 1 } }.sorted_keys().join_values(\",\"))}), \"\\n\"' && prove -q -Iperl t/actionir_ast_parser.t && prove -q -Iperl t/phase0_regression.t"
---

# Hash-Literal Colon MethodLowering Source Fallback

`SPEC-FORMAT-TERSE.9.4` exposed a Perl lowering fallback that was still
fat-arrow-only. The affected current source shape is a colon hash literal yielded
from an expression-valued block and then used as a receiver:

```spec
{ { "b" : 2, "a" : 1 } }.sorted_keys().join_values(",")
```

`MethodLowering.pm` now treats top-level `:` as a hash-pair separator wherever
that fallback already scanned for `=>`, while skipping `::`. Generated Perl host
hashrefs still emit `=>`; that is implementation output, not current `.spec`
authoring syntax.
