---
id: function-body-staged-prototype-proof
title: Function-body staged parsing is proven end to end for the first prototype
answers:
  - "is the function-body staged prototype proven end to end"
  - "what proves the staged function-body prototype"
  - "does STAGED-LINKED-PARSING.5.6 close the first staged prototype"
  - "how are function-body source-provenance diagnostics locked"
  - "what remains future after STAGED-LINKED-PARSING.5.6"
date: 2026-07-03
status: current
tags: [staged-parsing, parser-registry, parse-jobs, user-functions, diagnostics, rust, perl]
evidence: "STAGED-LINKED-PARSING.5.6 adds Perl phase0 subtest function_body_staged_prototype_end_to_end and Rust integration test function_body_staged_prototype_end_to_end_shape_and_runtime. They assert descriptor/parsed/compiled body_payload and body_parse_job provenance, deterministic job ids, stitched body_ast action blocks, stable runtime output, and source-provenance diagnostics with phase, parent AST path, source span, and failure policy."
reverify: "rg -n 'function_body_staged_prototype_end_to_end|function_body_staged_prototype_end_to_end_shape_and_runtime|STAGED-LINKED-PARSING\\.5\\.6|source_span=10-21|failure_policy=fail|body_ast' t/phase0_regression.t rust/linkedspec-runtime/tests/integration_test.rs docs/tasks/STAGED-LINKED-PARSING.md docs/linkedspec-book/src"
---

`STAGED-LINKED-PARSING.5.6` closes the first function-body staged parsing prototype
proof. It does not add new production dispatch behavior beyond `.5.5`; it proves the
already-landed narrow path end to end.

The Perl proof builds a multi-function descriptor and checks source-order function
registry shape, exact `body_payload` text and spans, normalized `body_parse_job`
parent paths, deterministic job ids over `functions.<index>.body_source` plus source
span, parser identity `actionir-body.spec` / `action_block`, `replace_field` into
`body_ast`, and stitched `action_block` body ASTs. It also runs the parser to keep
existing user-function semantics stable.

The Rust proof checks the same neutral contract through raw
`specs/user_function_definition.spec` AST output, normalized parsed `SpecFile.functions`,
compiled `CompiledUserFunction` records, runtime output, and dispatch diagnostics.

Source-provenance diagnostics are locked by unsupported-parser jobs whose errors include
the registry phase, parent AST path, original body source span, and failure policy.
General public `parse_job(...)` authoring, provider/import search roots, multiple
payload parser families, recursive staged queues, and cycle diagnostics remain future
work requiring new task-tree leaves.
