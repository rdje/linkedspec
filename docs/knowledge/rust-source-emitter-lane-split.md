---
id: rust-source-emitter-lane-split
title: RUST-PARITY.8 is split into narrow source-emitter leaves; Rust generated source now directly runs all structural families and a manifest-backed corpus subset
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
  - "which leaf owns generated non-REP family-plan emission"
  - "which leaf owns repetition Rust handler emission"
date: 2026-07-04
status: accepted
tags: [rust, codegen, HandlerIR, RUST-PARITY, task-tree]
evidence: "RUST-PARITY.8.1 read docs/knowledge/handler-ir-design.md, perl/LinkedSpec/HandlerVariantEmitter.pm, rust/linkedspec-core/src/types.rs, rust/linkedspec-core/src/compiler.rs, rust/linkedspec-runtime/src/engine.rs, rust/README.md, and docs/linkedspec-book/src/appendix/backend-handoff.md. Perl HandlerIR has 10 structural variant kinds and Perl/JSON emitters. Rust executes an interpreted native structural contract: CompiledSpec contains CompiledRule rows with regex_patterns, parsed lifecycle CodeBlock slots, AcodeEntry dispatch, BcodeEntry dispatch, parse mode, and repetition bounds. RUST-PARITY.8.2 added linkedspec_runtime::source_emitter::emit_rust_source, which emits a standalone Rust module embedding serialized CompiledSpec; tests build that generated source in an isolated temp crate. RUST-PARITY.8.3 split non-REP direct emission because rule-mode/family metadata, generated family-plan emission, acode execution, bcode execution, and matrix closeout are separate mechanisms. RUST-PARITY.8.3.1 preserved parsed RuleMode on CompiledRule and made generated source embed/validate a GENERATED_RULES family plan across default/OR/AND acode-bcode markers. RUST-PARITY.8.3.2 made generated parse enter Engine::execute_generated_with_plan and directly run Default/OrAcode; RUST-PARITY.8.3.3 added direct AndSingleAcode/AndAcodeSeq plus ordered AND sequence semantics; RUST-PARITY.8.3.4 added direct AndBcode/OrBcode execution with shared blind-edge tail handling and OR first-match semantics; RUST-PARITY.8.3.5 closed the non-REP matrix; RUST-PARITY.8.4 closed direct REP families with RepAcode, RepBcode, RepAndAcode, and RepAndBcode plus termination coverage. RUST-PARITY.8.5 added generated-source validation against a manifest-backed 8-case corpus subset while keeping the full 91-fixture corpus as the interpreter oracle gate. The generated-source subset remains curated; the current full interpreter oracle is 91 fixtures."
reverify: "rg -n 'RUST-PARITY\\.8\\.|emit_rust_source|source_emitter|CompiledSpec|CompiledRule|AcodeEntry|BcodeEntry|HandlerIR|_emit_handler' docs/tasks/RUST-PARITY.md rust/linkedspec-runtime/src/source_emitter.rs rust/linkedspec-runtime/tests/source_emitter.rs rust/linkedspec-core/src/types.rs perl/LinkedSpec/HandlerVariantEmitter.pm rust/README.md"
---

# Rust Source-Emitter Lane Split

**Accepted 2026-07-04 (`RUST-PARITY.8.1`) and updated by
`RUST-PARITY.8.2` / `.8.3` / `.8.3.1` / `.8.3.2` / `.8.3.3` / `.8.3.4` / `.8.3.5` / `.8.4`.** The Rust source-emitter work is not one implementation
patch. It is a parent lane because it crosses three separate contracts:

- Perl `HandlerVariantEmitter.pm` builds 10 HandlerIR structural variants and
  emits Perl source or JSON diagnostics.
- Rust currently interprets `CompiledSpec` / `CompiledRule`, with parsed
  lifecycle `CodeBlock`s plus action-edge and blind-call dispatch tables.
- The `.8` lane adds a generated Rust-source path without weakening the
  interpreted runtime path or the manifest-backed oracle corpus.

Current child frontier:

- `.8.2`: done — minimal emitter API plus generated-source compile/run
  harness. The generated module embeds serialized `CompiledSpec`.
- `.8.3`: done/split — non-repetition handler-family emission is now
  decomposed into `.8.3.1` family metadata/plan, `.8.3.2` default/OR acode,
  `.8.3.3` AND acode, `.8.3.4` AND/OR bcode, and `.8.3.5` matrix closeout.
- `.8.3.1`: done — `CompiledRule` preserves parsed `RuleMode`, generated
  source embeds a `GENERATED_RULES` family plan, and the generated entry point
  validates that plan before execution.
- `.8.3.2`: done — generated parse enters the plan-aware executor; `Default`
  and `OrAcode` families run directly.
- `.8.3.3`: done — `AndSingleAcode` and `AndAcodeSeq` families run directly,
  including ordered non-repetition AND regex/acode sequence semantics.
- `.8.3.4`: done — direct AND/OR bcode generated execution.
- `.8.3.5`: done — non-repetition generated-family matrix closeout.
- `.8.4`: done — repetition handler-family emission and termination guards.
- `.8.5`: done — all-variant smoke matrix plus manifest-backed oracle corpus subset.

No parser, compiler, or interpreter behavior changed in `.8.1` or the `.8.3`
split. `.8.2` added a source-emitter module and compile/run harness only.
`.8.3.1` added the generated family-plan metadata and validation contract.
`.8.3.2`, `.8.3.3`, `.8.3.4`, `.8.3.5`, and `.8.4` replaced fallback
execution for every current generated family. `.8.5` added the manifest-backed
corpus-subset proof; see [[rust-generated-source-corpus-subset]].
