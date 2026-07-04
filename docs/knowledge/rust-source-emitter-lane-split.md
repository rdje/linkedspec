---
id: rust-source-emitter-lane-split
title: RUST-PARITY.8 is split before code: Rust currently interprets CompiledSpec/CompiledRule, while the new source-emitter lane will add generated Rust source through narrow child leaves
answers:
  - "what is the Rust code generation emitter plan"
  - "does the Rust backend currently generate source code"
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
evidence: "RUST-PARITY.8.1 read docs/knowledge/handler-ir-design.md, perl/LinkedSpec/HandlerVariantEmitter.pm, rust/linkedspec-core/src/types.rs, rust/linkedspec-core/src/compiler.rs, rust/linkedspec-runtime/src/engine.rs, rust/README.md, and docs/linkedspec-book/src/appendix/backend-handoff.md. Perl HandlerIR has 10 structural variant kinds and Perl/JSON emitters. Rust currently executes an interpreted native structural contract: CompiledSpec contains CompiledRule rows with regex_patterns, parsed lifecycle CodeBlock slots, AcodeEntry dispatch, BcodeEntry dispatch, parse mode, and repetition bounds. The broad .8 leaf was split into .8.2 scaffold/compile-run harness, .8.3 non-REP families, .8.4 REP families, and .8.5 all-variant/oracle integration."
reverify: "rg -n 'RUST-PARITY\\.8\\.|CompiledSpec|CompiledRule|AcodeEntry|BcodeEntry|HandlerIR|_emit_handler' docs/tasks/RUST-PARITY.md rust/linkedspec-core/src/types.rs perl/LinkedSpec/HandlerVariantEmitter.pm rust/README.md"
---

# Rust Source-Emitter Lane Split

**Accepted 2026-07-04 (`RUST-PARITY.8.1`).** The Rust source-emitter work is
not one implementation patch. It is a parent lane because it crosses three
separate contracts:

- Perl `HandlerVariantEmitter.pm` builds 10 HandlerIR structural variants and
  emits Perl source or JSON diagnostics.
- Rust currently interprets `CompiledSpec` / `CompiledRule`, with parsed
  lifecycle `CodeBlock`s plus action-edge and blind-call dispatch tables.
- The new `.8` lane adds a generated Rust-source path without weakening the
  interpreted runtime path or the manifest-backed oracle corpus.

Current child frontier:

- `.8.2`: minimal emitter API plus generated-source compile/run harness.
- `.8.3`: non-repetition handler-family emission.
- `.8.4`: repetition handler-family emission and termination guards.
- `.8.5`: all-variant smoke matrix and oracle/corpus integration.

No parser, compiler, or runtime behavior changed in `.8.1`; it is an ownership
and contract split so implementation begins from a reviewable leaf.
