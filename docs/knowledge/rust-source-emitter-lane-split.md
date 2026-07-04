---
id: rust-source-emitter-lane-split
title: RUST-PARITY.8 is split into narrow source-emitter leaves; Rust now has a minimal generated-source scaffold, while direct handler-family emission starts in .8.3
answers:
  - "what is the Rust code generation emitter plan"
  - "does the Rust backend currently generate source code"
  - "does the Rust source emitter exist yet"
  - "does generated Rust source currently delegate through Engine"
  - "what is the next RUST-PARITY.8 task"
  - "why was RUST-PARITY.8 split before implementation"
  - "how does Rust CompiledSpec relate to HandlerIR"
  - "what owns the minimal Rust source emitter scaffold"
  - "which leaf owns Rust generated-source compile/run harness"
  - "which leaf owns non-repetition Rust handler emission"
  - "which leaf owns repetition Rust handler emission"
date: 2026-07-04
status: accepted
tags: [rust, codegen, HandlerIR, RUST-PARITY, task-tree]
evidence: "RUST-PARITY.8.1 read docs/knowledge/handler-ir-design.md, perl/LinkedSpec/HandlerVariantEmitter.pm, rust/linkedspec-core/src/types.rs, rust/linkedspec-core/src/compiler.rs, rust/linkedspec-runtime/src/engine.rs, rust/README.md, and docs/linkedspec-book/src/appendix/backend-handoff.md. Perl HandlerIR has 10 structural variant kinds and Perl/JSON emitters. Rust executes an interpreted native structural contract: CompiledSpec contains CompiledRule rows with regex_patterns, parsed lifecycle CodeBlock slots, AcodeEntry dispatch, BcodeEntry dispatch, parse mode, and repetition bounds. RUST-PARITY.8.2 added linkedspec_runtime::source_emitter::emit_rust_source, which emits a standalone Rust module embedding serialized CompiledSpec and delegating parse(input) through Engine; tests build that generated source in an isolated temp crate. The remaining .8 leaves are .8.3 non-REP direct emission, .8.4 REP direct emission, and .8.5 all-variant/oracle integration."
reverify: "rg -n 'RUST-PARITY\\.8\\.|emit_rust_source|source_emitter|CompiledSpec|CompiledRule|AcodeEntry|BcodeEntry|HandlerIR|_emit_handler' docs/tasks/RUST-PARITY.md rust/linkedspec-runtime/src/source_emitter.rs rust/linkedspec-runtime/tests/source_emitter.rs rust/linkedspec-core/src/types.rs perl/LinkedSpec/HandlerVariantEmitter.pm rust/README.md"
---

# Rust Source-Emitter Lane Split

**Accepted 2026-07-04 (`RUST-PARITY.8.1`) and updated by
`RUST-PARITY.8.2`.** The Rust source-emitter work is not one implementation
patch. It is a parent lane because it crosses three separate contracts:

- Perl `HandlerVariantEmitter.pm` builds 10 HandlerIR structural variants and
  emits Perl source or JSON diagnostics.
- Rust currently interprets `CompiledSpec` / `CompiledRule`, with parsed
  lifecycle `CodeBlock`s plus action-edge and blind-call dispatch tables.
- The `.8` lane adds a generated Rust-source path without weakening the
  interpreted runtime path or the manifest-backed oracle corpus.

Current child frontier:

- `.8.2`: done — minimal emitter API plus generated-source compile/run
  harness. The generated module currently embeds serialized `CompiledSpec` and
  delegates `parse(input)` through `Engine`.
- `.8.3`: current frontier — non-repetition handler-family emission.
- `.8.4`: repetition handler-family emission and termination guards.
- `.8.5`: all-variant smoke matrix and oracle/corpus integration.

No parser, compiler, or interpreter behavior changed in `.8.1`. `.8.2` adds a
source-emitter module and compile/run harness only; replacing the delegation
with direct generated handlers is `.8.3+`.
