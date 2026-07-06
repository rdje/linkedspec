---
id: terse-perl-colon-scalar-retired
title: "SPEC-FORMAT-TERSE.15.3 - Perl :name scalar-slot syntax is retired and emits a bare-read migration diagnostic sentinel"
answers:
  - "what happens to :name in Perl after SPEC-FORMAT-TERSE.15.3"
  - "is :name still supported on the Perl reference backend"
  - "what diagnostic does a retired colon scalar slot emit"
  - "what replaced scalar_slot_fallback"
  - "how should current specs read scalar working variables after colon slot removal"
  - "why does entry_text stay unresolved inside user functions after colon slot retirement"
date: 2026-07-06
status: current
tags: [spec-format-terse, scalar-slot, colon-slot, bare-read, perl, actionir, diagnostics]
evidence: "SPEC-FORMAT-TERSE.15.3 changed the Perl reference backend after `.15.2.4` migrated current sources to bare reads. `ActionIR::AST::Parser` classifies `:name` as retired `colon_scalar_slot_removed`; `MethodLowering`, `ValueExpr`, `FlowExpr`, `RewritePipeline`, and `RuleIR::EmitContext` route retired colon slots to `LINKEDSPEC_UNSUPPORTED_ACTIONIR_HELPER:colon_scalar_slot_use_bare_read`; `scalar_slot_fallback` declaration/trace behavior is gone. Active Perl tests and phase0 fixtures use bare reads. Focused ActionIR/trace tests pass, and full phase0 reaches plan `1..1022` with `PERL5LIB=` cleared."
reverify: "prove -q -Iperl t/actionir_ast_parser.t t/trace_emit_context_bridge.t t/trace_actionir_pipeline.t t/trace_actionir_compact_lowerers.t t/trace_actionir_method_lowering.t && env PERL5LIB= perl -Iperl t/phase0_regression.t"
---

# Perl Colon Scalar Slots Are Retired

Current Perl authoring reads working variables by bare name in value positions:

```text
return(name)
items += value
meta[key] = value
switch(kind) { case("ready") { return(value) } }
```

`:`-prefixed scalar-slot syntax is no longer a compatibility path on the Perl reference backend. A remaining
`return(:name)`, `set(:name, value)`, or similar form emits the retired-colon diagnostic sentinel:

```text
LINKEDSPEC_UNSUPPORTED_ACTIONIR_HELPER:colon_scalar_slot_use_bare_read
```

`entry_text()` and `match_text()` lower directly in ordinary value positions. Inside user-function bodies they
remain unresolved intentionally, because staged function-body parsing owns parser-state helper availability there.
