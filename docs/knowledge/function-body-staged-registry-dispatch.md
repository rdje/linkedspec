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
  - "what remains future after STAGED-LINKED-PARSING.5.5"
date: 2026-07-09
status: current
tags: [staged-parsing, parser-registry, parse-jobs, user-functions, rust, perl, dart]
evidence: "STAGED-LINKED-PARSING.5.5 adds Perl/Rust dispatch; DART-BACKEND-PARITY.5.1 adds Dart dispatch; JULIA-BACKEND-PARITY.5.1 adds Julia dispatch. Evidence lives in the four staged registry owners and their focused tests."
reverify: "rg -n 'StagedParserRegistry|staged_parser_registry|builtin:actionir-body.spec|staged_parser_cache_key|body_ast|dispatchFunctionBodyParseJobs|executeStagedParseJobs|dispatch_function_body_parse_jobs|execute_staged_parse_jobs' perl/LinkedSpec/StagedParserRegistry.pm rust/linkedspec-runtime/src/staged_parser_registry.rs dart/lib/src/parser/staged_parser_registry.dart julia/src/parser/StagedParserRegistry.jl t/phase0_regression.t rust/linkedspec-runtime/tests/integration_test.rs dart/test/staged_parser_registry_test.dart julia/test/runtests.jl"
---

`STAGED-LINKED-PARSING.5.5` adds the first executable staged parser registry path
on Perl and Rust. `DART-BACKEND-PARITY.5.1` adds the same narrow dispatch
contract on Dart, and `JULIA-BACKEND-PARITY.5.1` adds it on Julia.

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
`action_block` shape in `body_ast`.

This does not implement the full future surface. Public `parse_job(...)` authoring,
filesystem/import/provider search roots, multiple next-stage parser families, recursive
staged queues, and cycle diagnostics remain future leaves. Dart user-function runtime
execution has since landed under `DART-BACKEND-PARITY.5.2`.

Related Julia fact: [[julia-staged-function-body-registry]].
