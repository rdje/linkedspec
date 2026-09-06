---
id: perl-compiler-pipeline-stage-and-mode-boundaries
title: Perl compiler pipeline validates explicit state before projecting descriptors and selecting return modes
answers:
  - "what stages does Perl run_get_pipeline execute"
  - "what does Perl parse_only return"
  - "what does Perl generate_only return"
  - "does generate_only take precedence over return_descriptor"
  - "when does the Perl compiler validate staged and recognition policies"
  - "when does the Perl compiler flush generated source capture"
  - "where does the returned Perl parser preserve runtime errors"
date: 2026-09-06
status: current source-level ownership record; no new runtime behavior or signoff claim
tags: [perl, compiler, pipeline, modes, diagnostics, generated-source, continuity]
evidence: "SESSION-STARTUP-READING.3.2.6-.3.2.7 read all 2,002 Compiler.pm lines at the unchanged baeb984e baseline. ARCHITECTURE_STATE.md compiler/state sections and existing root/context/generated-source Knowledge reconcile the owners. This card indexes phase and mode boundaries directly visible in run_get_pipeline; it does not replace those contracts or claim a new runtime test."
reverify: "rg -n 'sub run_get_pipeline|validate_spec_content|validate_dsl_syntax|validate_compiled_descriptor_state|validate_rule_rows|if [(][$]parse_only|if [(][$]generate_only|if [(][$]return_descriptor|flush_runtime_ctx_parser_source|has_runtime_ctx_last_error_type' perl/LinkedSpec/Compiler.pm"
---

`perl/LinkedSpec/Compiler.pm::run_get_pipeline` coordinates the existing owners in this order:

1. Require and prepare the injected runtime context, apply trace options, clear its last error,
   and reject removed cursor-override options.
2. Resolve bootstrap/entry-compilation dependencies, build the user-function registry while preserving
   source positions, then run envelope and DSL validation over the stripped source.
3. Run bootstrap parsing and require a successful, nonempty array of parsed entries.
4. Build explicit compiled-spec state, check function/rule-name compatibility, and attach the registry.
5. Assemble explicit descriptor/dependency state and validate its references before outward projection.
6. Validate staged parse-job, progressive span-dispatch, recursive-observation, and recognition-transaction
   rule policies, in that order. A diagnostic or trapped exception stops compilation.
7. Project the outward descriptor, resolve effective entry identity, finish any requested source capture,
   and select the requested return mode.

The parse-only expected-failure path may continue after a validator returns false; a trapped validator
exception still stops the pipeline. Bootstrap output must still pass its shape/success check. This is a
test-mode boundary, not a source-validation bypass for normal parser generation.

| Mode | Successful stop point | Return value |
| --- | --- | --- |
| `parse_only` | After bootstrap output validation, before compiled-state construction | `undef` |
| `generate_only` | After generation, policy checks, entry selection, and requested source flush | `undef` |
| `return_descriptor` | After those same generation steps | Outward descriptor hash reference |
| Default | After those same generation steps | Parser code reference |

Mode checks occur in that table's order: `parse_only` wins before generation, and `generate_only` wins
over `return_descriptor`. Source capture is independent of the return value: when `dump_parser_source`
is enabled, preamble/handler chunks are emitted during generation and the completed postamble is flushed
through RuntimeContext before the generate-only or descriptor-return branch.

The returned parser clears stale context error state at invocation entry. It resolves the captured entry
selection and handler before validating the input scalar reference, then prepares invocation-local sinks
and dispatch/enrichment state. Handler execution and staged completion share an exception boundary.
Marked sink-control errors are rethrown unchanged; other caught errors are recorded with rule/handler
attribution and rethrown. A defined result clears stale `runtime_handler` state, while an undefined result
preserves that handler diagnostic in the context and `$@`.

Entry-selection precedence, generated-source versions, state layouts, and runtime error payload ownership
remain in their existing canonical records:
[[perl-root-rule-selection-core]], [[perl-root-rule-selection-routes]],
[[perl-generated-source-contract-v2]], [[compilerstate-internal-model]],
[[runtimecontext-boundary]], and [[linkedspec-pm-is-thin-facade]].
