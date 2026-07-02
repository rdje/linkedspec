---
id: function-body-parse-job-sidecar
title: User-function body payloads carry a neutral body_parse_job sidecar
answers:
  - "what is body_parse_job"
  - "where is the user-function body parse job stored"
  - "does body_payload include parser identity"
  - "what parse job fields are emitted for user-function bodies"
  - "is the function body parse job dispatched"
  - "how is the function body parse job id derived"
date: 2026-07-03
status: current
tags: [staged-parsing, parse-jobs, user-functions, descriptors, rust, perl]
evidence: "STAGED-LINKED-PARSING.5.4 emitted and preserved body_parse_job; STAGED-LINKED-PARSING.5.5 dispatches it through the minimal staged registry path. specs/user_function_definition.spec emits body_parse_job; perl/LinkedSpec/UserFunctionRegistry.pm normalizes it and calls LinkedSpec::StagedParserRegistry; rust/linkedspec-runtime/src/spec_parser.rs validates/normalizes it and calls staged_parser_registry; docs/linkedspec-book/src/public-api/descriptor-introspection.md documents it."
reverify: "rg -n 'body_parse_job|parse_job:function_body|actionir-body.spec|result_policy|failure_policy|StagedParserRegistry|staged_parser_registry' specs/user_function_definition.spec perl/LinkedSpec/UserFunctionRegistry.pm perl/LinkedSpec/StagedParserRegistry.pm rust/linkedspec-runtime/src/spec_parser.rs rust/linkedspec-runtime/src/staged_parser_registry.rs docs/linkedspec-book/src/public-api/descriptor-introspection.md"
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

As of `STAGED-LINKED-PARSING.5.5`, the sidecar is dispatched by the minimal staged
registry path for `actionir-body.spec` / `action_block`, and the returned `action_block`
AST is stitched into `body_ast`. General public `parse_job(...)` authoring and broad
provider search remain future work.
