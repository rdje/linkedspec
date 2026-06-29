---
id: terse-expression-valued-blocks-ground-truth
title: "SPEC-FORMAT-TERSE.2.1.1 - Expression-valued blocks were split before code; split-time braces were hash literals or invalid block-shaped values."
answers:
  - "did expression-valued blocks work before SPEC-FORMAT-TERSE.2.1.2"
  - "why was SPEC-FORMAT-TERSE.2.1 split"
  - "how were braces disambiguated before expression-valued blocks landed"
  - "did return({ set(x,\"a\"); x }) work before SPEC-FORMAT-TERSE.2.1.2"
  - "did Rust have a block-expression AST before SPEC-FORMAT-TERSE.2.1.3"
  - "what is the next leaf after SPEC-FORMAT-TERSE.2.1.1"
date: 2026-06-29
status: confirmed
tags: [dsl, blocks, expressions, actionir, rust, spec-format-terse, SPEC-FORMAT-TERSE]
evidence: "SPEC-FORMAT-TERSE.2.1.1 ground truth on 2026-06-29 used KM retrieval, TOOLBOX call_spec_handler_subst probes, LinkedSpec::Get runtime/source dumps, and Perl/Rust code-read. Current Perl lowers return({}) to return {}, and return({ key => value }) to return {$key => $value}, preserving hash shape literals. But return({ set(x,\"a\"); x }) lowers to invalid generated Perl shaped like return { $x = \"a\"; x }, and set(out, { set(x,\"a\"); return(x) }) follows hash target inference and emits malformed %out assignment. Rust has statement CodeBlock parsing and Expr::ArrayLiteral / Expr::HashLiteral, but no block-expression Expr variant or runtime evaluator. Therefore .2.1 split into .2.1.2 Perl-reference core block values, .2.1.3 Rust parity, and .2.1.4 block-local explicit-return follow-through if needed."
reverify: "perl -Iperl -MLinkedSpec -e 'for my $stmt (q{return({})}, q{return({ key => value })}, q{return({ set(x,\"a\"); x })}, q{set(out, { set(x,\"a\"); return(x) })}) { my $out=LinkedSpec::call_spec_handler_subst(\"Top\",$stmt); $out =~ s/\\n/\\\\n/g; print \"$stmt => $out\\n\" }' && rg -n 'Block|HashLiteral|ArrayLiteral|parse_hash_literal|execute_block|eval_expr' rust/linkedspec-core/src/expr.rs rust/linkedspec-runtime/src/engine.rs"
---

# Expression-Valued Blocks Ground Truth

`SPEC-FORMAT-TERSE.2.1` was not one implementation slice.

At split time, the accepted future contract said `{ ... }` should be a value expression whose value is the
last statement or an explicit block-local `return(expr)`. The implementation did not have that contract yet.

## Split-Time Perl Behavior

Hash shape literals already own brace value syntax:

```text
return({})                 -> return {}
return({ key => value })   -> return {$key => $value}
```

Block-shaped values are not accepted as block expressions today:

```text
return({ set(x,"a"); x })                  -> return { $x = "a"; x }
set(out, { set(x,"a"); return(x) })        -> %out = ( set(x,"a"); return $x )
```

The first form emits invalid generated Perl because the braces are treated like a Perl anonymous-hash/block
payload rather than a DSL value block. The second form takes the direct hash-shape target-inference path and
emits malformed aggregate assignment.

## Split-Time Rust Behavior

Rust has:

- statement-only `CodeBlock { statements }`;
- value expressions for `Expr::ArrayLiteral` and `Expr::HashLiteral`;
- no block-expression `Expr` variant;
- no runtime evaluator that returns a block's last value.

## Split

- `.2.1.2`: Perl reference core block values. Preserve `{}` and `{ key => value }` as hash literals, and treat
  non-empty brace payloads without a top-level `=>` as block values in value-consuming slots.
- `.2.1.3`: Rust parity for the accepted Perl reference core.
- `.2.1.4`: true block-local explicit-return semantics if final-only `return(expr)` is insufficient.
