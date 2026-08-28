---
id: function-body-staged-registry-dispatch
title: Function-body parse jobs dispatch through the minimal staged parser registry across current backends
answers:
  - "how are function body parse jobs dispatched"
  - "what is the first staged parser registry implementation"
  - "does actionir-body.spec resolve yet"
  - "what does the minimal staged registry provider do"
  - "what cache key fields are used for function body staged dispatch"
  - "does body_ast come from staged dispatch"
  - "does Dart have function-body staged dispatch"
  - "does Lua have function-body staged dispatch"
  - "what remains future after STAGED-LINKED-PARSING.5.5"
date: 2026-07-09
status: current
tags: [staged-parsing, parser-registry, parse-jobs, user-functions, rust, perl, dart, julia, lua]
evidence: "STAGED-LINKED-PARSING.5.5 adds Perl/Rust dispatch; DART-BACKEND-PARITY.5.1 adds Dart dispatch; JULIA-BACKEND-PARITY.5.1 adds Julia dispatch; LUA-BACKEND-PARITY.5.1.1 adds Lua dispatch. Evidence lives in the five staged registry owners and their focused tests."
evidence_update_2026_08_28_general_v2_separation: "FUTURE-PARITY-BACKLOG.14.7.2-.9 add a separate general-v2 dedicated marker, caller-frozen scheduler, six-runtime recurrence, and exact public assignment authoring without widening or replacing this function-body-v1 registry path."
reverify: "rg -n 'StagedParserRegistry|staged_parser_registry|builtin:actionir-body.spec|staged_parser_cache_key|body_ast|dispatchFunctionBodyParseJobs|executeStagedParseJobs|dispatch_function_body_parse_jobs|execute_staged_parse_jobs' perl/LinkedSpec/StagedParserRegistry.pm rust/linkedspec-runtime/src/staged_parser_registry.rs dart/lib/src/parser/staged_parser_registry.dart julia/src/parser/StagedParserRegistry.jl lua/src/linkedspec/staged_parser_registry.lua t/phase0_regression.t rust/linkedspec-runtime/tests/integration_test.rs dart/test/staged_parser_registry_test.dart julia/test/runtests.jl lua/test/run.lua"
---

`STAGED-LINKED-PARSING.5.5` adds the first executable staged parser registry path
on Perl and Rust. `DART-BACKEND-PARITY.5.1` adds the same narrow dispatch
contract on Dart, `JULIA-BACKEND-PARITY.5.1` adds it on Julia, and
`LUA-BACKEND-PARITY.5.1.1` adds it on both Lua ABIs.

The path is intentionally narrow. For user-function body jobs, `resolve` maps
`parser_spec_id = actionir-body.spec` to the neutral built-in provider identity
`builtin:actionir-body.spec`; `load` records the fixed adapter contract digest
`sha256:87ca81d966bb41f7025d31e4bae426af101e2ec75ff2ac14e96517d97fbbf55c`;
`compile` selects top rule `action_block` and builds a cache key over normalized spec
identity, digest, import-graph fingerprint, top rule, version fields, and backend
capabilities; `execute` parses the exact body text into an `action_block` AST.

Jobs execute in deterministic queue order: parent AST path, source span, then `job_id`.
The returned `action_block` AST is stitched into the function definition's `body_ast`
field according to the parse job's `replace_field` / `body_ast` policy. Perl exposes
this through `LinkedSpec::StagedParserRegistry`; Rust exposes it through
`linkedspec-runtime::staged_parser_registry` and preserves `body_ast` through parsed and
compiled function state. Dart exposes it through
`dart/lib/src/parser/staged_parser_registry.dart`, with
`executeStagedParseJobs(...)`, `dispatchFunctionBodyParseJobs(...)`,
`stitchFunctionBodyParseJobs(...)`, and
`parseSpecWithStagedUserFunctionDefinitionAsts(...)`.
Julia exposes the snake-case equivalents from
`julia/src/parser/StagedParserRegistry.jl` and stores the same neutral JSON
`action_block` shape in `body_ast`. Lua exposes the snake-case equivalents from
`lua/src/linkedspec/staged_parser_registry.lua`, adds duplicate-job rejection,
and preserves source `SpecFile` and staged-result isolation during stitching.

This narrow v1 adapter does not itself implement the general surface. A separate general-v2 path now provides
exact public assignment-form `parse_job(...)` authoring, already-compiled registry selection, recursive staged
queues, and cycle diagnostics. Filesystem/URI loading, provider queries, callbacks, compilation, and registry
mutation remain deliberately denied. Dart user-function runtime
execution has since landed under `DART-BACKEND-PARITY.5.2`; Lua fixed-v1 runtime execution lands under
`LUA-BACKEND-PARITY.5.1.2`, variadic/contextual runtime follows through `.5.1.4.2`, and no-drift `.5.1.5` closes
the Lua staged-function parent.

Audit `FUTURE-PARITY-BACKLOG.14.7.0` additionally proves that the raw registry only
transports alternate result/failure policy strings; the current function-specific stitch
path alone implements and enforces `replace_field` / `body_ast` / `fail`. Corrective
leaf `.14.7.1` now locks wrong-top compile diagnostics across all five source backends and
both Lua ABIs: each preserves the original job id/path/parser/top/payload/span/failure
context and the resolved built-in identity. The repair changes no success, policy, queue,
generated-format, or public behavior before the general contract expands.

Related backend facts: [[julia-staged-function-body-registry]],
[[lua-staged-function-body-registry]], [[lua-fixed-v1-user-function-runtime]], and
[[general-staged-ast-current-boundary]].
