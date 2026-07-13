---
id: julia-generated-source-scaffold
title: Julia has a deterministic contract-v1 generated-source scaffold
answers:
  - does Julia generated source exist now
  - where is the Julia generated-source emitter
  - how does Julia generated source preserve Unicode
  - does Julia generated source mean UTF-8 is Unicode
  - how is generated Julia source loaded in isolation
  - what generated-source work remains for Julia
  - what task owns Julia generated family execution
  - does Julia generated source preserve punctuation light aliases
date: 2026-07-13
status: current
tags: [julia, codegen, source-emitter, unicode, utf8, embedding, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.3.4.1 adds julia/src/source/SourceEmitter.jl and julia/test/source_emitter_test.jl. Public compatibility/v1 emitters reconstruct effective ordered AST state, encode canonical JSON as strict UTF-8 bytes represented by ASCII hex, and emit a native module with metadata, direct execution, traced execution, and typed errors. An 18-assertion test loads valid/corrupt modules in caller-owned temporary projects with private writable depots and compiled modules disabled. .3.4.2 adds exact family-plan/direct execution and .3.4.3 adds exact accepted-subset admission. FUTURE-PARITY-BACKLOG.16.5 proves punctuation-light typed AST equivalence plus exact native, generated-plan, emitted-state reconstruction, and CLI results; the complete 1,394/primary-CLI/105 gate passes."
reverify: "JULIA_DEPOT_PATH=/private/tmp/linkedspec-julia-depot:/Users/richarddje/.julia /opt/homebrew/bin/julia --project=julia --startup-file=no --history-file=no -e 'using LinkedSpecJulia, JSON3, Test; const REPO_ROOT=pwd(); include(\"julia/test/source_emitter_test.jl\"); include(\"julia/test/punctuation_light_zero_arg_contract_test.jl\")'"
---

Julia's public generated-source implementation starts in `julia/src/source/SourceEmitter.jl`.
`emit_julia_source_v1(compiled, source_identity)` emits deterministic native Julia source;
`emit_julia_source(compiled)` is the `<inline>` compatibility adapter. The generated module exposes contract,
format, and identity markers, `metadata()`, direct-value `execute(...)`, and `execute_with_trace(...)`.

Emission reconstructs a normalized effective `SpecFile` from compiled function order and last-definition rule
order, then writes recursively key-sorted JSON. The logical file and payload are Unicode scalar text. At the
generated-payload boundary, Julia encodes that JSON and the source identity as strict UTF-8 bytes and represents
the bytes as ASCII hexadecimal. This prevents Julia interpolation/literal spelling from changing the data.
Unicode is not synonymous with UTF-8: UTF-8, UTF-16, and UTF-32 are encodings; strict UTF-8 is simply the current
persisted/generated boundary selected by LinkedSpec's contract.

`GeneratedSourceMetadata` and `GeneratedSourceException` project the neutral v1 metadata and emission,
compile/load, validation, and execution stage/code vocabulary. The generated module reconstructs the AST through
the public JSON contract and ordinary compiler, then executes through the native in-memory runtime without a CLI.

The 18-assertion scaffold proof writes valid and deliberately corrupted modules into a caller-owned temporary
project, launches fresh Julia processes offline with compiled modules disabled, gives them a private writable depot
layer over the already-instantiated read layer, verifies Unicode result/metadata and stable failures, and deletes
the entire project/depot with the owning temporary directory. Native interpreter and CLI behavior are unchanged.

Exact ten-family plan/direct execution and interpreter-first manifest-backed admission are implemented under
`FUTURE-PARITY-BACKLOG.3.4.2` and `.3.4.3`. Julia generated source is pass at census 60/0/0.

`FUTURE-PARITY-BACKLOG.4.3.2` additionally proves that canonical normalized JSON preserves the exact fixed-v1 /
variadic-v2 function union. The emitted ASCII-hex payload reconstructs typed callable signatures and executes the
same fixed-prefix/rest semantics without Julia splat dispatch.

Punctuation-light zero-argument aliases reuse the same typed state rather than creating generated-only syntax.
The `.16.5` contract reconstructs emitted ASCII-hex normalized state and returns the same exact fixture value as
the native and generated-plan paths.

Related facts: [[user-observable-backend-cli-parity-contract]], [[julia-backend-interpreter-first-plan]],
[[julia-compiled-spec-state]], [[julia-full-corpus-gate]], [[native-in-memory-backend-contract]],
[[rust-source-emitter-lane-split]], [[rust-generated-source-family-plan]],
[[rust-generated-source-corpus-subset]], [[dart-generated-source-deferred]],
[[julia-generated-source-family-plan]], [[julia-scoped-parity-no-drift]].
See also [[julia-variadic-user-functions]].
