---
id: terse-perl-expression-valued-blocks
title: "SPEC-FORMAT-TERSE.2.1.2 - Perl reference accepts core expression-valued blocks."
answers:
  - "do Perl expression-valued blocks work"
  - "does return({ set(x,\"a\"); x }) work now"
  - "does return({ set(x,\"a\"); return(x) }) work now"
  - "does set(out, { set(x,\"a\"); x }) infer a hash target"
  - "are empty and keyed brace values still hash literals"
  - "does Rust support expression-valued blocks"
  - "what task owns Rust expression-valued block parity"
date: 2026-06-29
status: confirmed
tags: [dsl, blocks, expressions, actionir, perl, spec-format-terse, SPEC-FORMAT-TERSE]
evidence: "SPEC-FORMAT-TERSE.2.1.2 on 2026-06-29 added Perl-reference lowering for the core expression-valued block subset. In value-consuming sites, a non-empty brace payload without a top-level fat arrow lowers to a Perl do block; side-effect statements lower through the existing ActionIR statement lowerers, and the final expression becomes the block value. A final return(expr) is treated as a block-local payload for this final-only core subset. return({ set(x,\"a\"); x }) and return({ set(x,\"a\"); return(x) }) lower to return do { $x = \"a\"; $x }. set(out, { set(x,\"a\"); x }) lowers to scalar assignment instead of hash-target inference. {} and { key => value } still lower as hash shape literals, and final nested hash literals inside block values are emitted as hashrefs. Rust parity remains unimplemented and is owned by SPEC-FORMAT-TERSE.2.1.3; full early-return follow-through remains SPEC-FORMAT-TERSE.2.1.4 if needed."
reverify: "perl -Iperl -c perl/LinkedSpec/ActionIR/MethodLowering.pm && perl -Iperl -c perl/LinkedSpec/RuleIR/EmitContext.pm && perl -Iperl -c t/phase0_regression.t && prove -q -Iperl t/phase0_regression.t"
---

# Perl Core Expression-Valued Blocks

`SPEC-FORMAT-TERSE.2.1.2` lands the Perl-reference core for block values.

In value-consuming sites, a brace payload is a block value when it is non-empty and has no top-level `=>`.
The payload lowers to `do { ... }`: all but the final component are statement effects, and the final component
is the block value.

Examples now accepted by the Perl reference:

```text
return({ set(x, "a"); x })
return({ set(x, "a"); return(x) })
set(out, { set(x, "a"); x })
return(array({ set(x, "a"); x }, { set(key, "stage"); set(value, "ok"); { key => value } }))
```

Hash-shape precedence is unchanged:

```text
return({})               # empty hash shape
return({ key => value }) # keyed hash shape
```

Rust parity is still pending under `.2.1.3`, so no oracle fixture is added by this Perl-only slice. True
mid-block explicit-return follow-through, such as `return({ return("a"); "b" })`, remains owned separately by
`.2.1.4` if the final-only payload rule is insufficient.
