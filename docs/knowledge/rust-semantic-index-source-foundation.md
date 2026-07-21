---
id: rust-semantic-index-source-foundation
title: Rust SemanticIndex owns strict source mapping and opaque compiled-or-failed authority
answers:
  - "how do I construct a Rust semantic index"
  - "does Rust semantic construction accept a file path"
  - "how does Rust map UTF-8 bytes to Unicode scalar columns"
  - "what does Rust SemanticIndex expose before semantic projection"
  - "does Rust semantic index construction execute the target parser"
  - "how is the Rust semantic source digest computed"
  - "where is the Rust generated semantic plan retained"
  - "what happens when Rust semantic source validation fails"
date: 2026-07-21
status: current
tags: [rust, semantic-introspection, source-map, utf8, diagnostics, generated-source, privacy]
evidence: rust/linkedspec-runtime/src/semantic_index.rs; rust/linkedspec-runtime/tests/semantic_index_foundation.rs; docs/tasks/FUTURE-PARITY-BACKLOG.md leaf .10.4.1
reverify: "cargo test --manifest-path rust/Cargo.toml -p linkedspec-runtime --test semantic_index_foundation; python3 tools/check_semantic_introspection_contract.py"
---

`linkedspec_runtime::semantic_index::SemanticIndex` is the opaque Rust source/outcome foundation. Construct it
with `SemanticIndex::from_source(&str, options)` or `SemanticIndex::from_utf8(&[u8], options)`. Options require a
caller-owned logical name and one immutable `none`/`identity`/`span`/`text` source-detail ceiling; an exact optional
entry label uses the shared pinned Unicode rule-label classifier. The API has no path constructor and performs no
implicit filesystem read.

Construction copies decoded text and canonical strict-UTF-8 bytes, rejects malformed bytes before language
parsing, and builds one private map whose offsets are zero-based half-open bytes while lines and Unicode-scalar
columns are one-based. Mid-scalar byte boundaries are rejected. A text-ceiling snapshot can return exact excerpts
and a `sha256:` identity over the canonical bytes; lower ceilings cannot elevate to those values. Returned
foundation values and diagnostics are owned clones. `none` denies source/plan identity, including debug output;
`identity` denies spans/digest; `span` denies excerpts/digest; and `text` permits complete foundation detail.
`SemanticIndex` itself does not serialize or expose its parsed AST, `CompiledSpec`, source-map object, or accepted
source.

Accepted source retains parsed, validated, compiled, exact entry-selection, and generated-source-v2 plan
authority. The plan rows use the same `classify_generated_rule_family` owner as code generation. Parse,
validation, compilation, or entry-selection language failures still return an opaque `failed_compilation`
snapshot with raw `PortableDiagnostic` evidence and available source mapping; constructor policy errors remain
typed `SemanticIndexError`s. Static v1 records and normalized failure projection are deliberately later leaf
`.10.4.2`.

The full-source parser internally uses LinkedSpec's admitted staged parser for user-function definitions. The
no-execution guarantee is about the caller's target specification: construction never invokes the resulting
target parser, target lifecycle/action code, trace, or runtime semantic observation. Queries do not exist in this
foundation leaf. See [[rust-semantic-introspection-authority-map]], [[semantic-introspection-neutral-contract]],
and [[rust-generated-source-v2-rule-local-cursor]].
