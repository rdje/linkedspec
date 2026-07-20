---
id: outward-descriptor-is-not-semantic-wire-model
title: The outward descriptor is reusable semantic state but not the portable semantic query wire model
answers:
  - can LinkedSpec use return_descriptor directly as the semantic introspection JSON schema
  - is the outward descriptor portable JSON on every backend
  - why does semantic introspection need a normalized model separate from the descriptor
  - does the Perl outward descriptor contain compiled regex or callable objects
  - should semantic introspection serialize backend AST or IR
  - what existing state can the semantic index reuse
date: 2026-07-20
status: current design constraint
tags: [descriptor, introspection, semantic-api, perl, portability, mcp, FUTURE-PARITY-BACKLOG]
evidence: "A FUTURE-PARITY-BACKLOG.10.1 TOOLBOX return_descriptor probe produced the exact four-key public projection but showed Perl HASH rules/functions/meta alongside Regexp dependency values and handler coderefs; direct JSON encoding failed on the compiled Regexp object. Rust, Dart, Julia, and Lua already expose equivalent descriptor meanings through their own typed projections. ADR 0049 therefore consumes descriptor facts but forbids treating host descriptor values or AST/IR layouts as the semantic wire schema."
reverify: "rg -n 'dependency_regex_map|handler' capability_conformance/outward_descriptor_contract.json perl/LinkedSpec/CompilerState.pm rust/linkedspec-core/src/descriptor.rs dart/lib/src/compiler/compiled_spec.dart julia/src/compiler/CompiledSpec.jl lua/src/linkedspec/compiled_spec.lua && rg -n 'not the semantic schema|compiled regex objects' docs/decisions/0049-versioned-semantic-introspection-model-and-thin-mcp.md"
---

# The Outward Descriptor Is Not the Semantic Wire Model

The public descriptor remains a valuable, pure compatibility projection. Its exact top-level keys are `spec`,
`functions`, `dependency_regex_map`, and `meta`, and all five current backends project the same meanings from their
compiled state. The semantic index should reuse its normalized rule, order, function, cursor, root, slot, and edge
facts rather than excavating them again.

The descriptor's native values are deliberately host-idiomatic, however. The Perl reference uses handler coderefs
and compiled regex objects; other backends use their own typed rule, regex, map, and JSON projections. A direct Perl
JSON probe fails at the compiled regex value. The outward descriptor therefore cannot be copied wholesale into an
MCP or cross-backend semantic response.

ADR `0049` fixes the boundary: `SemanticIndex` reads existing descriptor/compiled/ActionIR/provenance/diagnostic/
generated authorities and emits normalized versioned facts. It never serializes a host callable, regex object,
object identity, backend type name, raw AST/IR layout, or implementation source. The descriptor stays stable on its
existing contract while introspection evolves independently through `linkedspec-semantic-model-v1`.

Related facts: [[outward-compiled-descriptor-four-backend-contract]],
[[rust-outward-compiled-descriptor-projection]], [[semantic-introspection-api-mcp-direction]].
