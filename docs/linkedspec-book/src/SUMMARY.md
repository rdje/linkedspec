# Summary

- [The LinkedSpec Book](index.md)

# Overview

- [What LinkedSpec Is](overview/what-is-linkedspec.md)
- [Design Rationale](overview/design-rationale.md)
- [Documentation Layers](overview/documentation-layers.md)
- [Project Status](overview/project-status.md)

# User Model

- [.spec Files and Rule Paragraphs](user-model/spec-files-and-rule-paragraphs.md)
- [Worked `.spec` Walkthrough](user-model/worked-spec-walkthrough.md)
- [Rule Modes and Cursor Policy](user-model/rule-modes-and-parse-modes.md)
- [Regex in `.spec`](user-model/regex-in-spec.md)
- [Blind Calls and Parser Orchestration](user-model/blind-calls-and-parser-orchestration.md)
- [Runtime Context and Tracing](user-model/runtime-context-and-tracing.md)

# Public API

- [`Get(...)` and `get_parser(...)`](public-api/get-and-get-parser.md)
- [Native Spec Loading](public-api/native-spec-loading.md)
- [Application Integration](public-api/integration.md)
- [Perl Application Integration](public-api/integration-perl.md)
- [Rust Application Integration](public-api/integration-rust.md)
- [Dart Application Integration](public-api/integration-dart.md)
- [Julia Application Integration](public-api/integration-julia.md)
- [Lua Application Integration](public-api/integration-lua.md)
- [Descriptor Introspection](public-api/descriptor-introspection.md)
- [Semantic Introspection](public-api/semantic-introspection.md)
- [Trace API](public-api/trace-api.md)
- [Plugin Registry and Legacy Transition](public-api/plugin-registry.md)

# DSL and Actions

- [Action Model and Helper Surface](dsl/action-model-and-helper-surface.md)
- [ActionIR Lowering Mental Model](dsl/actionir-lowering-mental-model.md)
- [Working Variables and Setup](dsl/declaration-helper-reference.md)
- [Fluent and Block Forms](dsl/fluent-and-block-forms.md)
- [Action and Lifecycle Placement](dsl/action-and-lifecycle-placement.md)
- [Capture, Marks, and Source Locations](dsl/capture-marks-and-source-locations.md)
- [Source Boundary Helper Reference](dsl/source-boundary-helper-reference.md)
- [Values, Containers, and Flow Helpers](dsl/values-containers-and-flow-helpers.md)
- [Value, Container, and Flow Helper Reference](dsl/value-container-flow-helper-reference.md)

# Compiler and Runtime

- [Pipeline Overview](compiler/pipeline-overview.md)
- [Staged AST Enrichment Contract](compiler/staged-ast-enrichment.md)
- [Compiled State Model](compiler/compiled-state-model.md)
- [Generated Handlers and Dispatch](compiler/generated-handlers-and-dispatch.md)
- [Diagnostics](compiler/diagnostics.md)

# Shipped Material

- [Shipped Specs and Corpora](specs-and-corpora/shipped-specs-and-corpora.md)
- [`Lispish.spec` Walkthrough](specs-and-corpora/lispish-spec-walkthrough.md)
- [Complete S-Expression Documents](specs-and-corpora/sexpr-document-v1.md)
- [`ebnf.spec` Walkthrough](specs-and-corpora/ebnf-spec-walkthrough.md)
- [`tablegrep.spec` Walkthrough](specs-and-corpora/tablegrep-spec-walkthrough.md)
- [`portmap.spec` Walkthrough](specs-and-corpora/portmap-spec-walkthrough.md)
- [`pplugin.spec` Walkthrough](specs-and-corpora/pplugin-spec-walkthrough.md)

# Architecture

- [Owner Tree and Module Boundaries](architecture/owner-tree.md)
- [Post-Parity Structured-Text Program](architecture/structured-format-program.md)

# Appendix

- [Formal `.spec` Grammar](appendix/formal-grammar.md)
- [Helper Contract Catalog](appendix/helper-contract-catalog.md)
- [Runtime Semantics](appendix/runtime-semantics.md)
- [Backend Handoff](appendix/backend-handoff.md)

# Development

- [Local CI and Regression](development/local-ci-and-regression.md)
- [Diagnosing macOS Rust Launch Latency](development/macos-rust-launch-latency.md)
- [Inspecting `.spec` Code Generation](development/codegen-inspector.md)
- [Documentation Workflow](development/documentation-workflow.md)
