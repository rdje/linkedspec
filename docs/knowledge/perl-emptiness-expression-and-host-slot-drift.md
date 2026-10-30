---
id: perl-emptiness-expression-and-host-slot-drift
title: "Perl emptiness lowering treats quoted zero differently from a bound value and reads host slots for literals"
answers:
  - "why does is_empty of a block yielding empty Array return false on Perl"
  - "why does is_empty quoted zero differ from a variable holding zero"
  - "why does is_empty numeric zero depend on the Perl program name"
  - "which repair owns Perl emptiness expression and host slot drift"
  - "why does a numeric literal lower to a Perl capture variable in emptiness checks"
date: 2026-10-30
status: bounded ordinary value/receiver repair checked; broader SESSION16 open
tags: [perl, actionir, emptiness, literals, host-state, diagnostics]
evidence: "Historical SESSION3.2.21 details at Gite449e4c233ab4df02aa3e002ac1ece5614c0bcad for this path; current TYPE23.2.8 native/fresh probe."
reverify: "bash tools/project_data_run.sh env PERL5LIB= prove -q -Iperl t/emptiness_result_receiver_contract.t t/emptiness_value_expression_contract.t"
---

Historical SESSION3.2.21 proves literal String0/binding drift and host-$0 dependence for numeric0. FlowExpr::_lower_is_empty_expr uses host truthiness for general expressions and permissive scalar-name lookup for literals. Original controls/commands and full ordinary repair history remain in this path at Git3959d9a60ce2023f92753bcd43cefb7487a86cf8. SESSION16.1/.16.2 retain condition/attached/global scalar-consumer ownership; those paths are unchanged.

TYPE23.2.8 native/fresh diagnostics show stopped fluent values, literal/bound0 nonempty0!/1!, and an empty-Array block giving wrong0!/SA.23.3.9.1.1/.1.2 now share _lower_emptiness_value_test on typed/legacy ordinary values, complete operands, preserve generic source kinds and root function context, and add scalar-result/zero-operand dispatch through scalar/default/Hash families. Copy must not infer Hash from the next generic predicate: a bound Array gave1! instead of0!. Native/fresh copied Array/Hash and literal/binding/block/nested/function regressions pass after RED, including zero/false/String0 data, two host-program-name states, false retention/bridges/scalar nulls and1!/SA/once-only snapshots. Other backend records: [[terse-array-receiver-value-chains]]. Broader SESSION16/full admission remain open.

TYPE45.12 reconciles only the old value-layer Phase0 emptiness group:3 source
oracle RED/1 healthy ->4 GREEN. Original3 helper expressions/fourth Hash
assertion stay exact; local private-owner loading makes focused selection
independent. Five public native/fresh controls and direct expression11 pass;
source preservation, zero/false data and once-only snapshot behavior agree.
No production/FlowExpr policy change or broad SESSION16/17 closure. Actual
source/RED-GREEN/producers retained in perl-phase0-emptiness-intake.json.gz.
