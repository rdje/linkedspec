---
id: backend-capability-census
title: A validated 15-capability census owns every current four-backend parity residual
answers:
  - where is the LinkedSpec backend capability matrix
  - how many backend capabilities are in the parity census
  - which current capabilities are not yet equal across Perl Rust Dart and Julia
  - does the 99 fixture corpus prove every LinkedSpec feature
  - does Rust expose the backend neutral compiled descriptor
  - does Rust expose structured runtime diagnostics
  - do Rust Dart and Julia have native named spec resolution
  - does Dart trace frontend compiler and staged phases
  - what did FUTURE-PARITY-BACKLOG 1.6.0 audit
date: 2026-07-10
status: current
tags: [parity, capability, matrix, public-api, rust, dart, julia, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.1.6.0 adds capability_conformance/manifest.json and tools/check_capability_conformance.pl: 15 capabilities x four backends classify 47 pass, five partial-proof, and eight gap states, each non-pass state with an explicit owner."
reverify: "perl tools/check_capability_conformance.pl && rg -n 'FUTURE-PARITY-BACKLOG.1.6.[0-6]' docs/tasks/FUTURE-PARITY-BACKLOG.md"
---

`capability_conformance/manifest.json` is the current user-observable capability census. The checker validates the
schema, exact backend set, evidence paths, status vocabulary, unique ids, gap ownership, and explicit legacy/future
exclusions. The initial audit has 15 capability rows and 60 backend states: 47 pass, five partial, and eight gap.

The audit distinguishes implementation gaps from proof gaps:

- the unchanged 99-fixture interpreter corpus passes all four backends, but is not yet indexed exhaustively against
  every current non-legacy mdBook language/helper/API contract; `.1.6.1` owns that neutral proof;
- Perl/Dart/Julia expose the documented outward compiled descriptor, while Rust exposes only its internal/public
  `CompiledSpec` shape; `.1.6.2` owns the projection;
- Perl/Dart/Julia expose structured runtime diagnostic attribution, while Rust uses a string payload in
  `LinkedSpecError::Runtime`; `.1.6.3` owns the structured record;
- the native file-oriented named-spec role exists only as Perl `get_parser(...)`; Rust/Dart/Julia process adapters
  resolve names but their public libraries do not; `.1.6.4` owns idiomatic native equivalents;
- Perl/Rust/Julia propagate a native emitter through frontend/compiler/function-shell/staged/runtime phases, while
  Dart native trace begins at the interpreter; `.1.6.5` owns the missing pipeline coverage;
- generated source remains top-level `.3`: Perl passes, Rust has all structural families but only a curated corpus
  proof, and Dart/Julia have no emitter.

`.1.6.6` closes non-codegen capability parity only after the matrix has no unowned partial/gap state. Deprecated
Perl plugins and not-yet-current general parse jobs, semantic introspection/MCP, generic final-codeblock behavior,
and Lua are explicit exclusions/future owners, not omitted rows.

Related facts: [[user-observable-backend-cli-parity-contract]], [[native-in-memory-backend-contract]],
[[trace-cross-variant-capability-contract]], [[dart-generated-source-deferred]],
[[julia-generated-source-deferred]], [[rust-parity-followon-closed]], [[primary-cli-four-backend-matrix]].
