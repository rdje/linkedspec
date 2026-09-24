---
id: perl-generated-source-cold-trace-dependency
title: Fresh Perl generated execution needs an explicit Trace dependency
answers:
  - why does a generated Perl parser fail only in a fresh process
  - why is trace_generated_handler_branch undefined in emitted source
  - do the Perl integration book examples execute directly in recurring tests
  - why did same process generated source tests miss the Trace import
date: 2026-09-24
status: .86.4.4.2.1 repaired and verified; final helper recomposition remains .86.4.4.2.2
tags: [perl, generated-source, trace, mdbook, public-api]
evidence: "At af168d2fe, all four exact book examples pass public SpecLoader and descriptor checks but fail plain generated Execute in fresh Perl processes. Structured errors name execute_generated/generated_execution_failed with Undefined subroutine LinkedSpec::Trace::trace_generated_handler_branch. Compiler::_generated_source_preamble omits Trace; ExecuteWithTrace requires it, while ordinary Execute does not. Existing generated_source_contract.t imports Trace in its parent process before eval-loading artifacts."
reverify: "bash tools/project_data_run.sh env PERL5LIB= prove -v -Iperl t/generated_source_contract.t; inspect the book-example subtest's public results and fresh-process status, not only source presence."
---

The repaired preamble explicitly imports Trace. The four-example recurring
subtest passes66 assertions; the nine-file generated/loader/AST/trace/cursor
suite passes173 tests. Syntax, the unchanged generated-source contract and
book rendering pass. An isolated changed result fails only its live/generated
value assertions; removing a complete example fails the coverage count.

The emitted handlers call `LinkedSpec::Trace::trace_generated_handler_branch`
even when the caller uses plain `Execute`. The generated preamble must load
that runtime dependency itself. Importing Trace only in `ExecuteWithTrace`
cannot establish availability for ordinary execution.

The earlier generated tests load the artifact into another package in a process
that already imported both LinkedSpec and Trace. Those are useful package and
value checks, but do not establish fresh-process bootstrap completeness.
`.86.4.4.2.1` verifies the explicit emitted import; `.86.4.4.2.2` retains final helper
recomposition. The four complete Markdown sources are extracted directly from
the integration guide so their loader and generated results cannot drift behind
duplicate fixture strings. No generated-format version change is intended.
