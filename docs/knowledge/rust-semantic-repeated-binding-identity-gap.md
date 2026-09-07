---
id: rust-semantic-repeated-binding-identity-gap
title: Rust semantic queries reuse binding identities and source references after the second same-name assignment
answers:
  - "why does Rust semantic query return duplicate binding ids"
  - "why do repeated Rust semantic bindings show the final assignment source"
  - "does Rust preserve semantic identity for repeated assignments"
  - "which task fixes Rust semantic binding order"
date: 2026-09-07
status: confirmed public query defect; repair pending under SESSION-STARTUP-READING.66
tags: [rust, perl, semantic-introspection, binding, identity, source-reference, startup-reading]
evidence: "SESSION-STARTUP-READING.3.3.30: six paired native/public SemanticIndex queries; verified existing runtime library; exact source cause and retained independent assertions. No runtime repair or whole-project signoff."
reverify:
  - "bash tools/run_python_project_data.sh tools/check_semantic_introspection_contract.py"
  - "bash tools/project_data_run.sh env PERL5LIB= perl -Iperl .linkedspec-data/scratch/startup89-semantic-bindings/probe.pl .linkedspec-data/scratch/startup89-semantic-bindings"
  - "bash tools/project_data_run.sh .linkedspec-data/scratch/startup89-semantic-bindings/probe .linkedspec-data/scratch/startup89-semantic-bindings"
---

# Repeated semantic binding identities

Six exact ASCII source cases use the public Rust `SemanticIndex::from_source` / `query_neutral` and
Perl `LinkedSpec::semantic_index` / `query` APIs. Each query lists helper/binding/call records at text
detail; every snapshot is compiled, every query succeeds, and every diagnostic list is empty.

| Case | Rust binding suffixes | Perl binding suffixes |
| --- | --- | --- |
| No function, one rule assignment | no records | no records |
| Unused function, one assignment | 0 | 0 |
| Same name assigned twice | 0, 1 | 0, 1 |
| Same name assigned three times | 0, 1, 1 | 0, 1, 2 |
| Same name assigned four times | 0, 1, 1, 1 | 0, 1, 2, 3 |
| Three distinct names | each name has suffix 0 | each name has suffix 0 |

The full repeated-binding ID is `binding:edge:rule:Top:0:value:<suffix>`. The four-assignment
Rust response also materializes the final `trim(" 3 ")` excerpt and byte span on all three records
with suffix 1. Perl retains each assignment's distinct excerpt and range.

In `rust/linkedspec-runtime/src/semantic_index/call_projection.rs`, `emit_statement` at 306–334 counts
matching keys in `binding_by_owner_name` to choose the order. That map holds only the latest ID per
(owner,name), so the count is zero before the first assignment and one thereafter. Every later assignment
reuses suffix 1. `register_source` at 1128–1150 inserts by `source_ref:<record_id>` and overwrites its prior
range/excerpt. The Perl edge projector at 226–251 uses a separate incrementing per-name order counter.
The neutral validator at `tools/check_semantic_introspection_contract.py` 924 explicitly requires unique
record IDs, but its current frozen examples do not exercise this repeated native assignment sequence.

The no-function/unused-function pair separately confirms the existing
[[semantic-rule-calls-empty-function-gate]] on Rust. It does not cause the duplicate-ID failure, which
occurs with a populated function registry. Function-local/lifecycle assignment routes, paging/get/relations,
MCP exposure and other backend repetition behavior were not freshly measured.

The six sources, request, twelve full responses, Rust/Perl probes, commands, status, library identity and
supporting source hashes are retained under `.linkedspec-data/scratch/startup89-semantic-bindings/`.
The manifest covers 37 files/35,637,599 bytes; manifest itself is 7,182 bytes, SHA-256
`d165a6e0a96f69406d61b51b5c9f274b34d396d0ae02f418364715bf89b4ff07`.
Independent paired assertions are 3,110 bytes, SHA-256
`14a227c09c40083cc5cff1a00dce688ed7ac566cc9296a0ac28a9d0cfa08f956`.

Rust compilation exits 0 in 335.326 seconds, execution exits 0 in 7.702 seconds; Perl exits 0 in 11.203
seconds. All three stderr files are empty. The runtime library SHA-256 is
`7cbddb91b8c3043adaf709ae4344f94cf0b17f80e25569456445285648f8c972`; Cargo fingerprint metadata selects
the matching serde_json dependency. The retained binary is a baseline diagnostic; rebuild it against a verified
current runtime before claiming repair proof. Fresh neutral semantics pass 6 fixture groups/20 exact queries/
128 mutations at rollout 9/0 and admission 6/0.

Repair owner `SESSION-STARTUP-READING.66` requires distinct occurrence allocation, immutable source
references, repeated-name/owner controls and meaningful query recurrence, followed by supported-carrier/MCP
census and public/canonical closeout. Runtime repair follows the required reading and policy prerequisites.
