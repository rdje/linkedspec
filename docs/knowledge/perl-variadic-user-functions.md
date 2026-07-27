---
id: perl-variadic-user-functions
title: Perl preserves v1 fixed functions and executes v2 variadic functions through generated source
answers:
  - "does Perl support variadic user functions"
  - "where does Perl bind a rest parameter"
  - "does Perl evaluate variadic arguments left to right"
  - "are Perl rest arrays fresh per invocation"
  - "does Perl preserve variadic signatures in staged records"
  - "why did variadic result length return 18 instead of 3"
  - "does length work on array values in Perl"
date: 2026-07-12
status: current
tags: [perl, functions, variadic, rest-parameter, descriptor, staged-parsing, generated-source, length, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.4.2.1 updates specs/spec.spec, specs/user_function_definition.spec, perl/LinkedSpec/UserFunctionRegistry.pm, and perl/LinkedSpec/ActionIR/MethodLowering.pm. t/variadic_user_function_contract.t consumes the unchanged neutral contract with 66 assertions; canonical CI passes 61x2 CLI and Phase 0 1..1030 in 710 seconds."
reverify: "PERL5LIB= prove -Iperl t/variadic_user_function_contract.t && bash tools/run_python_project_data.sh tools/check_callable_signature_contract.py"
---

The Perl reference accepts `fn name(fixed, ...rest) { ... }`. The spec-owned definition shell emits a version-2
function record containing the adopted version-1 `callable_signature`; fixed definitions still emit their exact
version-1 `params`/`arity` records. `LinkedSpec::UserFunctionRegistry` rejects mixed representations and preserves
the signature unchanged in the body payload, parse job, compiled registry, and outward descriptor.

Generated Perl evaluates authored arguments into source-ordered temporaries before binding parameters. Fixed
prefix names receive the first `min_arity` values. Every remaining value is placed in a newly allocated scalar-held
array reference bound to the rest name; zero extras create `[]`. Separate invocations receive different array
identities. Nested arrays/hashes, booleans, and `undef` remain individual values. Fixed wrong-arity and variadic
below-minimum calls stay on the existing registered-callee unresolved-helper diagnostic path with no raw fallback.

The neutral fixture surfaced a pre-existing receiver-chain bug: `all_values(1, 2, 3).length()` initially returned
`18`, the typical character length of Perl's stringified `ARRAY(0x...)` reference, instead of `3`. The documented
`length` contract already covered strings and arrays, but the shared Perl lowerer always called scalar `length`.
It now checks for an array reference and returns cardinality; defined non-array scalars retain the old string-length
behavior. This was a latent Perl implementation drift exposed by variadic array results, not a change to ADR 0030.
