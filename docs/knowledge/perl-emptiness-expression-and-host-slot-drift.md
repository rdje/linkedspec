---
id: perl-emptiness-expression-and-host-slot-drift
title: "Perl emptiness lowering treats quoted zero differently from a bound value and reads host slots for literals"
answers:
  - "why does is_empty of a block yielding empty Array return false on Perl"
  - "why does is_empty quoted zero differ from a variable holding zero"
  - "why does is_empty numeric zero depend on the Perl program name"
  - "which repair owns Perl emptiness expression and host slot drift"
  - "why does a numeric literal lower to a Perl capture variable in emptiness checks"
date: 2026-10-26
status: bounded ordinary value/receiver repair checked; broader SESSION16 open
tags: [perl, actionir, emptiness, literals, host-state, diagnostics]
evidence: "Historical SESSION3.2.21 details at Gite449e4c233ab4df02aa3e002ac1ece5614c0bcad for this path; current TYPE23.2.8 native/fresh probe."
reverify: "bash tools/project_data_run.sh env PERL5LIB= prove -q -Iperl t/emptiness_result_receiver_contract.t t/emptiness_value_expression_contract.t"
---

Historical SESSION3.2.21 proves literal String0 versus binding drift and runtime host-$0 dependency for numeric0; exact inputs, seeded controls, generated source and prior commands remain in this path at Gite449e4c233ab4df02aa3e002ac1ece5614c0bcad. FlowExpr::_lower_is_empty_expr checks bound values by kind but uses host !($lowered) for general expressions; permissive scalar-name recognition also reads host literal slots. SESSION16.1/.16.2 retain full conditional/expression/literal-consumer ownership.

Current TYPE23.2.8 public native/fresh probes reproduce literal/bound0 nonempty0!/1! and empty-Array-yielding block wrong0!/SA, with later consumer appending x. MethodLowering repeats the host-truthiness fallback. Fluent predicates stop at terminal classification while nested basic Array/Hash values work. Bounded ordinary producer23.3.9.1.1 must precede flow1.2; full16 condition/global-selector repair is not inferred. Canonical emptiness skips undef/empty String/Array/Hash and preserves String0 as data.

TYPE23.3.9.1.1 repairs typed ordinary value calls in MethodLowering: complete operands before actual-kind emptiness emission, avoiding host truthiness/name lookup and raw function calls. Native/fresh tests pass after RED for literals/bindings/blocks/nested/functions, inverse helpers, empty/null values, String0/numeric0/false as data, two program-name states and1!/SA/one-call snapshots. FlowExpr conditions/global scalar-name recognition remain unchanged with SESSION16; receiver/result flow1.2 remains next.

TYPE23.3.9.1.2 shares _lower_emptiness_value_test across typed/legacy ordinary producers and adds scalar-result/zero-operand fluent dispatch. Generic sources avoid Array coercion and continue through scalar/default/Hash families; root calls retain typed context. Copy lookahead must not infer Hash from a generic predicate: bound Array copy gave1! versus0! until uncoerced routing. Native/fresh copied Array/Hash and result/producer fixtures pass after RED, with bridges/false retention/scalar nulls and1!/SA/once-only snapshots. Rust2/full admission and broader SESSION16 remain open.
