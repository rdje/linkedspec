---
id: native-in-memory-backend-contract
title: Native in-memory embedding is the primary LinkedSpec multi-backend contract; CLIs are thin secondary adapters
answers:
  - why does LinkedSpec have multiple backends
  - is LinkedSpec multi-backend mainly for command line tools
  - must Rust support in-memory LinkedSpec use
  - must Dart support in-memory LinkedSpec use
  - must Julia support in-memory LinkedSpec use
  - must Lua support in-memory LinkedSpec use
  - can a LinkedSpec backend require a CLI or subprocess
  - can a LinkedSpec backend require temporary files or serialized handoff
  - what is the primary public surface of a LinkedSpec backend
  - are LinkedSpec backend CLIs thin adapters
date: 2026-07-10
status: accepted
tags: [architecture, portability, backends, embedding, public-api, cross-variant-parity]
evidence: "FUTURE-PARITY-BACKLOG.1.4 audits Perl LinkedSpec::Get/get_parser, Rust linkedspec-core plus runtime Engine, Dart parseSpec/compileSpec/LinkedSpecRuntimeEngine, and Julia parse_spec/compile_spec/runtime_parse/runtime_execute. ADR 0022 ratifies their native host-process pattern as mandatory for Lua and future backends and makes CLIs/corpus runners secondary adapters with no exclusive semantics."
evidence_update_2026_07_15_lua: "Lua exports parse/validate/compile/runtime/staged/diagnostic/trace APIs in process; LUA-BACKEND-PARITY.5.2.1 adds typed deterministic native file resolution/loading and strict UTF-8 through the same module at 149/149 on both ABIs."
evidence_update_2026_07_15_lua_automatic_functions: "LUA-BACKEND-PARITY.5.2.2 executes the bundled function-definition spec through native parse/validate/compile/runtime APIs, caches the compiled parser, and composes Unicode projection/body dispatch in process at 151/151 on both ABIs."
evidence_update_2026_07_15_lua_native_pipeline: "LUA-BACKEND-PARITY.5.2.3 exposes typed loaded/compiled state plus named/path-identified runtime-engine creation and executes loaded top-level functions fully in process at 153/153 on both ABIs."
reverify: "rg -n 'sub Get|sub get_parser|pub fn parse_spec|pub fn new\(spec: CompiledSpec\)|pub fn execute\(&self|parseSpec|compileSpec|LinkedSpecRuntimeEngine|parse_spec|compile_spec|runtime_parse|runtime_execute' perl/LinkedSpec.pm rust/linkedspec-core/src/parser.rs rust/linkedspec-runtime/src/engine.rs dart/lib/linkedspec_dart.dart julia/src/LinkedSpecJulia.jl"
---

## Contract

LinkedSpec has multiple backends so a program can embed LinkedSpec directly in the host
language and keep `.spec` source, parser input, and structured results in memory. The
primary product surface is therefore an idiomatic library/module/package/crate, not a
collection of independent command-line implementations.

Every backend must let a host program:

1. provide `.spec` source as an in-memory value;
2. parse and compile that source through native APIs;
3. execute against in-memory input;
4. receive structured host-language results and diagnostics; and
5. do all of the above without a required subprocess, CLI, temporary file, or serialized
   inter-process handoff.

File resolution, distinct per-variant executable names, corpus runners, Wasm, web, mobile,
FFI, and service wrappers remain useful. They are adapters over the native library and
cannot own semantics unavailable to in-process callers. Distinct CLI names expose one
identical user interface under ADR `0023`; backend identity is not permission to change its API.

## Current structural evidence

| Backend | Native in-memory surface |
| --- | --- |
| Perl | `LinkedSpec::Get(...)` compiles `.spec` text and returns a parser coderef; `get_parser(...)` is the file-oriented convenience path. |
| Rust | `linkedspec-core::parser::parse_spec(...)`, core compilation, and `linkedspec-runtime::engine::Engine::new(...).execute(...)` operate on Rust values. |
| Dart | The package exports `parseSpec(...)`, `compileSpec(...)`, and `LinkedSpecRuntimeEngine`; the CLI/corpus runner reuses that package code. |
| Julia | `LinkedSpecJulia` exports `parse_spec(...)`, `compile_spec(...)`, `LinkedSpecRuntimeEngine`, `runtime_parse(...)`, and `runtime_execute(...)`; scripts call the module. |
| Lua | `require("linkedspec")` exports in-memory parse/validate/compile, staged function projection/dispatch, `runtime_engine(...)`, and `runtime_parse(...)`/`runtime_execute(...)`; typed `resolve_spec(...)`, `load_spec(...)`, and `load_and_compile_spec(...)` add deterministic file-to-compiled-state composition, while `LoadedCompiledSpec:create_engine(...)` carries name/path identity into runtime diagnostics. `.5.2.4` closes this native-loading boundary; `.5.3` owns descriptors/full trace. |
| Future | Must meet the same in-process library gate with idiomatic host-language names and types. |

This structural audit does not claim that every active backend has completed every
behavioral parity milestone. Those claims remain owned by the backend task trees and
language-neutral corpus gates. The broader current matrix and its named-resolution/descriptor/diagnostic/trace
residuals are recorded by [[backend-capability-census]].

## Links

- [ADR 0022](../decisions/0022-native-in-memory-backend-embedding.md)
- [Original backend vision](../decisions/0006-multi-backend-vision.md)
- [Backend rollout order](../decisions/0021-future-backend-rollout-order.md)
- [Backend handoff](../linkedspec-book/src/appendix/backend-handoff.md)
- [[language-agnostic-backend-vision]]
- [[cross-backend-cli-contract-gap]]
- [[user-observable-backend-cli-parity-contract]]
