---
id: rust-semantic-introspection-authority-map
title: Rust semantic introspection composes typed compiler/runtime owners and needs new source and observation seams
answers:
  - "which Rust authorities build the semantic index"
  - "can Rust parse the semantic privacy fixture Töp"
  - "are Rust rule labels ASCII or Unicode"
  - "where do Rust semantic source spans come from"
  - "what Rust failure does failed.spec currently report"
  - "does Rust already have a semantic observation sink"
  - "where can Rust semantic slot events be captured"
  - "can Rust generated metadata reconstruct a semantic index"
  - "can CompiledSpec be serialized without host state"
  - "why is TOOLBOX semantic introspection output stale"
date: 2026-07-21
status: current
tags: [rust, semantic-introspection, source-map, unicode, diagnostics, runtime, generated-source]
evidence: docs/tasks/FUTURE-PARITY-BACKLOG.md leaf .10.4.0; docs/decisions/0049-versioned-semantic-introspection-model-and-thin-mcp.md; capability_conformance/semantic_introspection_model.json; rust/linkedspec-core/src/parser.rs; rust/linkedspec-runtime/src/engine.rs
reverify: "python3 tools/check_semantic_introspection_contract.py; cargo test --manifest-path rust/Cargo.toml -p linkedspec-core --test descriptor_test; cargo test --manifest-path rust/Cargo.toml -p linkedspec-runtime --test runtime_diagnostics --test diagnostic_output_contract --test spec_loader --test trace_controls --test source_emitter; rg -n 'Semantic(Index|Query|Observation)|semantic_(index|query|observation)|regex_slot_selected' rust -g '*.rs'"
---

Rust semantic introspection must compose several existing typed owners. `parse_spec_with_user_functions` owns the
function-extraction/staged-body boundary and parsed rules; core validation/compiler own accepted graph state and
portable compile diagnostics; `CompiledSpec` owns deterministic ordered rules/functions, regex slots, edges,
families/cursor/root facts, ActionIR, and function sidecars; descriptor projection is derived compatibility data.
`CompiledSpec` is serde-safe: an exact probe serialized/deserialized it and retained descriptor equality. The
generated-source-v2 artifact adds exact ordered `{label,family}` plan identity around serialized compiled state,
but it neither retains accepted authored source nor constitutes a semantic snapshot. Strict spec loaders own file
decoding/identity only; a semantic constructor must still take caller logical identity and never infer a path.

Exact source evidence needs a new immutable mapper over the accepted `&str` plus canonical UTF-8 bytes. Ordinary
rule headers and body members retain only one-based lines, and compiled `CodeBlock`/`Expr` nodes have no general
source spans. Function extraction is richer: staged function sidecars retain character-offset source/body spans,
payload/job/result policy, and typed body AST. The mapper/correlator must convert final references to zero-based
half-open bytes and one-based Unicode-scalar columns without serializing Rust AST layout.

Current native probes establish these exact boundaries:

- graph, calls, failed, and runtime sources parse; graph/calls/runtime validate and compile;
- calls retains the exact typed body AST and `actionir-body.spec` parse job;
- `failed.spec` validation reports `bare_edge_target_undefined` at `normalize_edges`, while direct compile reports
  `regex_slot_identity_invalid` at `validate_compiled_rule`; the neutral model's
  `unknown_rule_reference`/`compile` record therefore needs an explicit normalized projection;
- the runtime fixture directly returns `["A","B"]`; and
- the privacy source fails before validation because Rust's header regex uses `\w+` through the current ASCII
  regex engine and the published formal grammar explicitly defines labels as `[A-Za-z0-9_]+`.

The privacy result is a contract conflict, not an adapter detail. Accepted neutral v1 plus admitted Perl require
the exact `Töp` label and percent-encoded id, while published/Rust DSL behavior is ASCII-only. Leaf `.10.4.0.2`
must resolve that direction before Rust semantic construction; `.10.4.1` depends on it.

There is no current `SemanticIndex`, semantic query evaluator, or typed semantic observation sink in Rust. Direct
and generated executors nevertheless have parallel authoritative seams: after structural slot identity is checked,
both emit `regex_slot_selected` trace decisions with executing rule, target rule, authored regex index, and cursor;
their rule wrappers own final typed result and final cursor. A future optional invocation-local semantic sink can
attach there, separately from buffered text trace and `RuntimeDiagnosticOutputSink`, and a post-execution builder
can derive a new immutable snapshot without query-side execution.

During this audit, `TOOLBOX.md` §4.9 still advertised 57 rejected mutations, rollout 1+8, and pre-admission Perl
state even though the executable checker reports 65, rollout 2+7, and admission 1+5. The checker guards contract,
CI, and book topology but not its own toolbox command/output documentation. Leaf `.10.4.0.1` owns the current-state
repair plus a no-drift guard. See [[semantic-introspection-neutral-contract]],
[[rust-generated-source-v2-rule-local-cursor]], [[rust-runtime-structured-diagnostics]],
[[rust-diagnostic-output-events]], [[function-body-parse-job-sidecar]],
[[outward-descriptor-is-not-semantic-wire-model]], and [[rust-native-spec-resolution]].
