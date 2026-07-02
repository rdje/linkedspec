---
id: function-body-parse-job-sidecar
title: User-function body payloads now carry a neutral body_parse_job sidecar
answers:
  - "what is body_parse_job"
  - "where is the user-function body parse job stored"
  - "does body_payload include parser identity"
  - "what parse job fields are emitted for user-function bodies"
  - "is the function body parse job dispatched yet"
  - "how is the function body parse job id derived"
date: 2026-07-03
status: current
tags: [staged-parsing, parse-jobs, user-functions, descriptors, rust, perl]
evidence: "STAGED-LINKED-PARSING.5.4; specs/user_function_definition.spec emits body_parse_job; perl/LinkedSpec/UserFunctionRegistry.pm normalizes it; rust/linkedspec-runtime/src/spec_parser.rs validates and normalizes it; docs/linkedspec-book/src/public-api/descriptor-introspection.md documents it."
reverify: "rg -n 'body_parse_job|parse_job:function_body|actionir-body.spec|result_policy|failure_policy' specs/user_function_definition.spec perl/LinkedSpec/UserFunctionRegistry.pm rust/linkedspec-runtime/src/spec_parser.rs docs/linkedspec-book/src/public-api/descriptor-introspection.md"
---

Top-level user-function definition AST nodes now carry two separate staged records.

`body_payload` remains the neutral exact text island with source provenance.
`body_parse_job` is the neutral parse-intent sidecar for that text island. It records
`kind = parse_job`, a deterministic `job_id`, `parent_ast_path`, `node_kind`,
`payload_kind`, exact `text`, `source_span`, `parser_spec_id = actionir-body.spec`,
`top_rule = action_block`, `result_policy = replace_field`, `result_field = body_ast`,
`failure_policy = fail`, and diagnostic ownership.

`specs/user_function_definition.spec` emits the raw source-order sidecar. The Perl
registry and Rust runtime adapter validate it, normalize the source-order parent path
and job id after function ordinal assignment, and preserve it in descriptor / parsed /
compiled function state.

This is not staged dispatch yet. The sidecar is metadata; executing the next-stage
parser is tracked by `STAGED-LINKED-PARSING.5.5`.
