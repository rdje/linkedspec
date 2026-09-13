---
id: terse-primitive-literal-parity
title: "Typed primitive literal contract; Perl dynamic codeblock boolean coverage remains incomplete"
answers:
  - "how do true and false lower in terse .spec actions"
  - "are true and false returned as strings or booleans"
  - "which primitive literals are typed value expressions in terse actions"
  - "do trueword and undefine count as primitive literals"
  - "does push(items,false) append false or call a child rule"
  - "does items += false work as an explicit append value"
  - "can meta[true] = false use primitive literals as key and value"
  - "why does Rust need statement-form if(false) gating"
  - "what owns SPEC-FORMAT-TERSE.1.5.2 primitive literal parity"
date: 2026-09-06
status: qualified
tags: [dsl, literals, booleans, actionir, rust, parity, spec-format-terse, SPEC-FORMAT-TERSE]
evidence: "SPEC-FORMAT-TERSE.1.5.2, 2026-06-29. Perl `ValueExpr::_lower_primitive_literal_expr` lowers exact string, numeric, `undef`, `true`, and `false` literals; `true`/`false` lower to `JSON::PP::true` / `JSON::PP::false`, not bareword strings. The helper is wired through return/value lowering, flow expressions, scalar/hash access keys, mutation RHS guards, scanner contracts, and legacy `push(...)` disambiguation, so `push(items,false)` is an explicit value append while `push(items,trueword)` keeps the old child-call interpretation. Rust already parsed BooleanLiteral/Undef/Number/String values; this slice added statement-form `if(cond); elseif(cond); else(); endif()` execution gating so `if(false)` skips the then branch instead of evaluating both statement returns. Locked by phase0 subtest `spec_format_terse_1_5_2_primitive_literal_parity`, Rust integration tests `terse_1_5_2_*`, and oracle corpus fixtures `terse_1_5_2_primitive_literals` + `terse_1_5_2_boolean_mutation_flow`."
reverify: "perl -Iperl -MLinkedSpec -MJSON::PP -e 'my $s=qq{Top::\\n /x/ -> Done { return(array(true, false, \"s\", 42, 3.14, undef)) }\\n\\nDone::\\n /[a-z]+/\\n}; my $p=LinkedSpec::Get(\\$s); print JSON::PP->new->canonical(1)->allow_nonref(1)->encode($p->(\"xhello\")),\"\\n\"' && cargo test --manifest-path rust/linkedspec-runtime/Cargo.toml terse_1_5_2"
---

# Primitive Literal Parity

Primitive literals are exact value-expression tokens in the terse DSL:

- quoted strings (`"..."`, `'...'`) stay strings;
- integer and float literals stay numeric;
- `undef` becomes the undefined/null value;
- `true` and `false` become typed booleans, not strings.

The matching is exact. Prefix identifiers such as `trueword` and `undefine` do not enter the literal path;
they keep the existing identifier/legacy dispatch behavior.

## Perl Reference

The Perl reference lowers exact primitive literals through `LinkedSpec::ActionIR::ValueExpr` and wires that
lowering into value positions used by returns, assignments, appends, hash-index keys and values, and flow
conditions. `true` and `false` use `JSON::PP::true` and `JSON::PP::false` so the public JSON value shape is
typed boolean. The scanner and legacy `push(...)` guards consult the same literal predicate so
`push(items,false)` is an explicit append value. The all-bare `push(items,trueword)` form uses a registered
static handler first and otherwise appends to the binding, as confirmed by `.3.2.31` and
[[perl-uniform-binding-runtime]]; the dated evidence above describes the historical interpretation.

## Rust Parity

Rust already had typed `BooleanLiteral`, `NumberLiteral`, string, and `Undef` expression values. The parity
gap this slice exposed was statement-form flow: `if(false); return("bad"); else(); return("good"); endif()`
must gate statements, not execute both branches. The runtime now keeps a statement-form conditional stack for
one-arg `if`/`elseif` and zero-arg `else`/`endif`; multi-arg `if(cond, then, else)` remains the existing lazy
value helper.

## September 6 dynamic-codeblock qualification

The ordinary action controls still return typed JSON true/false. The dynamic CodeblockRuntime evaluator
instead returns numeric 1/0 for its boolean literal AST nodes, including nested array elements; a passed-in
boolean remains typed. [[perl-codeblock-boolean-literal-kind-drift]] preserves six public controls and the
emitted-record root cause. `SESSION-STARTUP-READING.35` owns repair without changing this typed-literal contract.
Rust and other runtime behavior were not remeasured by this reading checkpoint.

## Links

- Tree: [[SPEC-FORMAT-TERSE]] leaf `.1.5.2`.
- Related ground truth: [[terse-literals-calls-separators-access-ground-truth]].
- Mutation boundary: [[terse-mutation-surface-ground-truth]].

## September 13 string-literal fidelity qualification

A primary Perl double-quoted `"@capture_gaps"` action literal returns empty while
its single-quoted twin retains the text. Primitive literal lowering passes the
quoted token into generated Perl unchanged, exposing host interpolation.
[[self-hosted-grammar-ast-drift]] records exact controls and the affected directive
AST. `SUPPORTING-SOURCE-READING.2.4` owns general literal repair and verification;
the string contract and existing boolean repair remain unchanged.
