---
id: function-body-staged-registry-dispatch
title: Function-body parse jobs dispatch through the minimal staged parser registry
answers:
  - "how are function body parse jobs dispatched"
  - "what is the first staged parser registry implementation"
  - "does actionir-body.spec resolve yet"
  - "what does the minimal staged registry provider do"
  - "what cache key fields are used for function body staged dispatch"
  - "does body_ast come from staged dispatch"
  - "what remains future after STAGED-LINKED-PARSING.5.5"
date: 2026-07-03
status: current
tags: [staged-parsing, parser-registry, parse-jobs, user-functions, rust, perl]
evidence: "STAGED-LINKED-PARSING.5.5; perl/LinkedSpec/StagedParserRegistry.pm; rust/linkedspec-runtime/src/staged_parser_registry.rs; perl/LinkedSpec/UserFunctionRegistry.pm; rust/linkedspec-runtime/src/spec_parser.rs; focused Perl/Rust tests in t/phase0_regression.t and rust/linkedspec-runtime/tests/integration_test.rs."
reverify: "rg -n 'StagedParserRegistry|staged_parser_registry|builtin:actionir-body.spec|staged_parser_cache_key|body_ast|staged_parser_registry_dispatches_function_body_jobs' perl/LinkedSpec/StagedParserRegistry.pm perl/LinkedSpec/UserFunctionRegistry.pm rust/linkedspec-runtime/src/staged_parser_registry.rs rust/linkedspec-runtime/src/spec_parser.rs t/phase0_regression.t rust/linkedspec-runtime/tests/integration_test.rs"
---

`STAGED-LINKED-PARSING.5.5` adds the first executable staged parser registry path.

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
compiled function state.

This does not implement the full future surface. Public `parse_job(...)` authoring,
filesystem/import/provider search roots, multiple next-stage parser families, recursive
staged queues, and cycle diagnostics remain future leaves.
