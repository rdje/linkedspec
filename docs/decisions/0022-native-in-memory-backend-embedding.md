# 0022 - Native in-memory embedding is the primary multi-backend product contract

- Date: 2026-07-10
- Status: accepted
- Tags: architecture, portability, backends, embedding, public-api, cross-variant-parity

> Update 2026-07-10: ADR `0023` preserves CLIs as secondary adapters while
> requiring distinct backend executable names to expose one identical interface.
> It also makes complete parity contingent on the full user-observable capability matrix.

## Context

ADR `0006` established identical `.spec` files and lockstep semantics across backends, and
ADR `0021` scheduled Dart, Julia, and Lua after Perl and Rust. Those records did not state
why separate host-language implementations are product-critical. Their CLI-oriented reach
tables could therefore be misread as making a command-line program the primary backend
surface.

The director clarified the product intent: LinkedSpec has multiple backends so applications
written in Rust, Dart, Julia, Lua, and later host languages can use LinkedSpec directly in
memory. A complete backend is a native library, module, package, or crate embedded in the
calling process. A CLI remains useful, but it is an adapter over that capability.

The implemented surfaces already demonstrate this model:

- Perl `LinkedSpec::Get(...)` compiles in-memory `.spec` text and returns a parser coderef.
- Rust exposes `linkedspec-core` parsing/compilation APIs and
  `linkedspec-runtime::engine::Engine` for direct execution over `&str` values.
- Dart exports `parseSpec(...)`, `compileSpec(...)`, and `LinkedSpecRuntimeEngine` from its
  package library; its CLI/corpus runner calls the same library implementation.
- Julia exports `parse_spec(...)`, `compile_spec(...)`, `LinkedSpecRuntimeEngine`,
  `runtime_parse(...)`, and `runtime_execute(...)` from `LinkedSpecJulia`; its command
  entrypoints call those module functions.

## Decision

1. **Native in-process use is primary.** Every LinkedSpec backend must expose an idiomatic
   host-language library API that can parse, compile, and execute LinkedSpec within the
   caller's process.
2. **The data path is in memory.** Callers must be able to supply `.spec` source and parser
   input as host-language values and receive structured host-language values without a
   required CLI, subprocess, temporary file, or serialized inter-process handoff.
3. **Names and execution strategy stay idiomatic.** Backends may interpret or emit generated
   source and may choose host-appropriate API names and types. Those implementation choices
   do not weaken the in-memory capability contract.
4. **File APIs are conveniences.** Named-spec resolution and filesystem-backed entrypoints
   may wrap the same library pipeline, but they cannot be the only complete public surface.
5. **CLIs are secondary thin adapters.** Each variant may keep a distinct primary executable name plus separate
   corpus runner and diagnostic tooling. Primary commands must share ADR `0023`'s exact interface, delegate
   semantic work to the native library, and may not own parser, compiler, runtime, or language behavior unavailable
   to library callers.
6. **Library-level proof is mandatory.** Backend acceptance must include direct host-process
   tests of in-memory parse/compile/execute behavior. CLI and corpus tests supplement that
   proof; they do not replace it.
7. **Lua and future backends inherit this gate.** Their first plans and scaffolds must define
   the native module/library entrypoints before CLI productization can count as backend
   completion.
8. **Wrappers do not redefine the contract.** Wasm, web, mobile, FFI, and service adapters
   may be layered on a native backend, but an adapter-only implementation is not a complete
   host-language backend under this decision.

This record clarifies the primary product surface of ADRs `0006` and `0021`; it does not
change their universal `.spec`, semantic lockstep, reference-backend, or rollout-order
decisions.

## Consequences

- Backend handoff documentation must begin with the native in-memory library requirement.
- Roadmaps and task trees must assess backend completeness at the library surface before
  celebrating CLI reach.
- Corpus runners should remain ordinary library consumers, making them useful evidence that
  the public parser/compiler/runtime composition is reusable.
- Any CLI-only semantic path is architecture drift and must be moved behind a shared library
  API before the backend can claim parity.
- The Perl, Rust, Dart, and Julia APIs above satisfy the structural part of this contract
  today; behavioral breadth remains governed by their existing parity tasks and test gates.

## Links

- Task owner: `docs/tasks/FUTURE-PARITY-BACKLOG.md` (`FUTURE-PARITY-BACKLOG.1.4`)
- Original backend vision: `docs/decisions/0006-multi-backend-vision.md`
- Backend rollout order: `docs/decisions/0021-future-backend-rollout-order.md`
- Public API: `docs/linkedspec-book/src/public-api/get-and-get-parser.md`
- Backend handoff: `docs/linkedspec-book/src/appendix/backend-handoff.md`
- Knowledge Map card: `docs/knowledge/native-in-memory-backend-contract.md`
- Exact interface parity: `docs/decisions/0023-user-observable-backend-and-cli-parity.md`
