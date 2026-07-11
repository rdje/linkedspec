---
id: outward-function-descriptor-record-shape-drift
title: Outward function records preserve aligned staged semantics under divergent outer field conventions
answers:
  - "do all backends expose exactly the same outer function descriptor fields"
  - "why do Perl and Dart Julia function descriptor records differ"
  - "which fields differ in outward function descriptor records"
  - "are body_payload body_parse_job and body_ast aligned across backends"
  - "which leaf owns exact function descriptor record normalization"
date: 2026-07-11
status: resolved
tags: [descriptor, user-functions, staged-parsing, perl, rust, dart, julia, parity, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.1.6.2.2 source/probe audit. Perl outward functions clone the neutral function_definition record with kind/version/source_text and no index. Dart/Julia UserFunctionEntry projection adds index to FunctionDefinition JSON, uses source, and omits kind/version. Rust .2 projects index plus the neutral kind/version/source_text identity. All preserve name/params/arity/spans/body_source and aligned nested body_payload/body_parse_job/body_ast values. FUTURE-PARITY-BACKLOG.1.6.2.3 owns exact normalization before the capability row can pass."
evidence_update_2026_07_11: "FUTURE-PARITY-BACKLOG.1.6.2.3 resolves the drift with capability_conformance/outward_descriptor_contract.json. Every variant now exposes the exact outer fields index/kind/version/name/params/arity/source_text/source_span/body_span/body_source/body_payload/body_parse_job/body_ast; focused tests consume the shared schema and complete backend gates pass."
reverify: "rg -n 'source_text|kind.*user_function_definition|version|index|body_payload|body_parse_job|body_ast' perl/LinkedSpec/CompilerState.pm dart/lib/src/action/function_registry.dart dart/lib/src/ast/spec_ast.dart julia/src/action/FunctionRegistry.jl julia/src/spec/Ast.jl rust/linkedspec-core/src/descriptor.rs docs/tasks/FUTURE-PARITY-BACKLOG.md"
---

# Outward Function Descriptor Record-Shape Drift

The semantic staged core is aligned: all implemented variants preserve function name, ordered parameters, arity,
source/body spans, body source, neutral `body_payload`, normalized `body_parse_job`, and stitched `body_ast`.

The former outer-record drift is resolved. Every variant now exposes `index`, `kind`, `version`, `name`, `params`,
`arity`, `source_text`, `source_span`, `body_span`, `body_source`, `body_payload`, `body_parse_job`, and `body_ast`.
The shared executable schema is `capability_conformance/outward_descriptor_contract.json`. Dart and Julia keep
their internal AST serialization unchanged by using descriptor-specific projections.
