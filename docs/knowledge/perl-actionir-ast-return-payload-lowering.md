---
id: perl-actionir-ast-return-payload-lowering
title: Perl return payloads consume ActionIR AST values before raw fallback
answers:
  - "are return payloads lowered from AST in Perl"
  - "does Perl return payload lowering still regex substitute helper calls first"
  - "does return(count) still read scalar count after AST migration"
  - "does unsupported substr inside a return payload leak as host Perl substr"
  - "which leaf moved return payloads to AST traversal"
date: 2026-07-01
status: current
tags: [actionir, ast, perl-reference, method-lowering, return-payloads]
evidence: "PERL-ACTIONIR-AST-MIGRATION.3.4 changed MethodLowering::_lower_return_payload_expr so typed return payloads parse through LinkedSpec::ActionIR::AST and return the AST-lowered value before the legacy helper-substitution loop. Focused t/actionir_ast_parser.t coverage poisons array/hash/string/call/chain/variable source fields and proves typed payloads consume AST fields, return(count) still lowers through scalar source-slot reads as $count, unsupported covered chains keep the LINKEDSPEC_UNSUPPORTED_ACTIONIR_HELPER sentinel, and raw compatibility payloads such as \\(my $capt = capture_slice()) still use the narrow fallback."
reverify: "prove -Iperl t/actionir_ast_parser.t && prove -q -Iperl t/phase0_regression.t"
---

`perl/LinkedSpec/ActionIR/MethodLowering.pm` now treats typed generalized return payloads
as AST values before trying the old helper-looking regex substitution loop.

This covers direct shapes, primitive literals, nested helper calls, direct/nested access,
block values, and receiver-dot chains through the same value traversal used by
`_lower_method_value_expr(...)`.

Bare AST `variable` payloads are intentionally not returned from the direct AST path.
They continue through the source-slot rule so `return(count)` lowers to `return $count`
rather than the raw identifier `count`.

Unsupported covered helper chains inside return payloads use the existing unresolved-helper
sentinel path. For example, a malformed covered `"abc".substr()` chain inside a typed
payload becomes `LINKEDSPEC_UNSUPPORTED_ACTIONIR_HELPER:substr` instead of generated host
Perl `substr(...)`.

The raw fallback remains only for untyped compatibility payloads, such as
`\(my $capt = capture_slice())`, until later migration leaves can retire or model those
surfaces.
