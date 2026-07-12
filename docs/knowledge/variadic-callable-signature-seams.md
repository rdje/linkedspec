---
id: variadic-callable-signature-seams
title: Variadic user functions require one neutral signature evolution across every staged and runtime seam
answers:
  - "can user-defined functions accept unlimited arguments"
  - "where is user function arity stored"
  - "why can variadic functions not be implemented only in the runtime"
  - "which helpers already accept an unlimited number of arguments"
  - "how do receiver methods count their arguments"
  - "do user functions support overloads"
  - "what task owns variadic user-defined functions"
  - "what happens when an unknown rest parameter syntax is parsed"
date: 2026-07-12
status: current
tags: [functions, helpers, methods, arity, variadic, staged-parsing, descriptor, parity, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.4.0 retrieved the existing function/staged facts and ADRs 0017/0023, used LinkedSpec::Get return_descriptor/runtime_ctx_ref probes, and inspected specs/user_function_definition.spec, specs/spec.spec, the exact outward descriptor contract, Perl/Rust/Dart/Julia AST/registry/runtime/generated seams, and Lua's prepared invocation frame."
reverify: "rg -n 'params|arity|resolve_exact|resolveCall|resolve_user_function_call|execute_user_function|_executeUserFunction|_execute_runtime_user_function|prepare_invocation' specs/user_function_definition.spec capability_conformance/outward_descriptor_contract.json perl/LinkedSpec/UserFunctionRegistry.pm perl/LinkedSpec/ActionIR/MethodLowering.pm rust/linkedspec-core/src rust/linkedspec-runtime/src dart/lib/src julia/src lua/src/linkedspec"
---

Purpose-specific unbounded helper calls already exist. The Perl ActionIR classifier represents helper arity as
`[minimum, maximum]`, with an undefined maximum for calls such as `cat`, `coalesce`, `num_add`, `num_mul`, scalar
`num_min`/`num_max`, `array`, `hash`, `concat_arrays`, `merge_hash`, `drop_keys`, and `pick_keys`. The neutral scalar
numeric v1 contract independently locks the same exact-versus-variadic distinction. Receiver methods inject the
receiver into the effective helper argument list (except explicitly governed order exceptions), so their arity is
still the semantic helper signature rather than a separate host-method rule.

User-defined functions have no equivalent open upper bound. Exact `arity` is repeated through:

- the `specs/user_function_definition.spec` returned node;
- its `body_payload` and `body_parse_job` staged sidecars;
- the exact public function record in `capability_conformance/outward_descriptor_contract.json`;
- every backend's parsed and compiled function record, validator, registry, and call resolution;
- eager native/generated execution and fresh local parameter binding; and
- Lua's registry and prepared invocation-frame boundary.

Function names are unique and duplicate definitions are rejected, so the current `expected_arities` collections do
not constitute overload support. A variadic definition is therefore one fixed-prefix-plus-optional-rest signature,
not an overload set and not host-language splat dispatch. The rest binding must be a fresh typed LinkedSpec array;
fixed functions retain exact arity and purpose-specific built-ins retain their existing minimum/maximum contracts.

Unrecognized rest spellings currently produce a `function_definition_error`. The Perl public `Get(...)` result is
`undef`, with `runtime_ctx_ref->{last_error}` reporting `compiler_pipeline:function_registry` and the precise
invalid-definition detail. The critical trace is not a swallowed exception or a successful empty registry.

Implementation must begin with a versioned neutral signature/schema and executable fixture. Changing only a final
runtime length check would leave staged metadata, public descriptors, generated source, diagnostics, and other
backends inconsistent. `FUTURE-PARITY-BACKLOG.4.1` owns the syntax and contract; `.4.2` and `.4.3` own paired
backend rollouts; `.4.4` owns no-drift plus routing into Lua's dependency-complete function-execution leaf.
