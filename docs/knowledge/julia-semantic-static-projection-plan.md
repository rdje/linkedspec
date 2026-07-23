---
id: julia-semantic-static-projection-plan
title: Julia static semantic projection must correlate authored members with typed compiled owners
answers:
  - "what are the five Julia semantic static construction targets"
  - "how many records and relations are in each Julia static projection target"
  - "which Julia authorities own semantic spec rule regex edge lifecycle and evidence records"
  - "why can Julia compiled regex patterns not be projected directly as semantic regex slots"
  - "does Julia Default rule mode mean neutral semantic repetition"
  - "how must Julia normalize the failed semantic fixture"
  - "how must Julia source ranges be correlated for static semantic records"
  - "which Julia task implements the compiled static graph"
  - "which Julia task owns privacy failure runtime-static and isolation"
  - "does Julia static projection expose query trace or runtime observations"
date: 2026-07-22
status: current verified behavior-free implementation plan; production projection remains pending
tags: [julia, semantic-introspection, static-projection, source-map, diagnostics, privacy, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.10.6.3.0; capability_conformance/semantic_introspection_model.json; Julia probes over graph/privacy/failed/runtime fixtures; admitted Perl/Rust/Dart static projectors; ADR 0049"
reverify: "python3 tools/check_semantic_introspection_contract.py && JULIA_DEPOT_PATH=/private/tmp/linkedspec-julia-semantic-static-plan-depot:$HOME/.julia /opt/homebrew/bin/julia --project=julia -e 'using LinkedSpecJulia,Test; include(\"julia/test/semantic_index_source_foundation_test.jl\"); include(\"julia/test/semantic_index_compilation_foundation_test.jl\")'"
---

# Julia Semantic Static Projection Plan

Behavior-free leaf `FUTURE-PARITY-BACKLOG.10.6.3.0` freezes five private construction targets before production
projection code:

| Target | Ceiling/state | Static records | Static relations |
|---|---|---:|---:|
| `graph` | `text` / compiled | 12 | 14 |
| `privacy` | `text` / compiled | 4 | 3 |
| `privacy_limited` | `identity` / compiled | 4 | 3 |
| `failed` | `span` / failed compilation | 6 | 4 |
| `runtime` static half | `text` / compiled, `has_execution=false` | 7 | 8 |

The runtime count deliberately removes its one execution record, three event records, and every relation touching
them. Static construction never executes the fixture or invents observations.

No single Julia object owns the portable answer. The projector must compose:

- copied accepted source, caller logical identity, SHA-256, and `_SemanticSourceMap` for exact references;
- parsed `SpecFile`, `RuleHeader`, and grouped `BodyElement` occurrences for authored order, source spelling,
  explicit-versus-omitted target indices, entry markers, and lifecycle occurrence order;
- typed `CompiledSpec` / `CompiledRule` for compiled order, accepted modes, structural slots, resolved action/blind
  topology, payload presence, typed Action AST return shapes, and lifecycle payload identity;
- the detached selected-entry owner for the effective root and basis; and
- the native `SemanticCompilationDiagnostic` for failure input before neutral normalization.

Two native/neutral traps are mandatory normalization rules. Julia's `is_repetition(Default)` is true, but neutral
v1 treats `Default`, `And`, `Single`, and `Pipe` as non-repeating; their neutral bounds are null. Also,
`CompiledRule.regex_patterns` includes parent matchers attached to cross-rule action edges. Those matchers do not
become target regex-slot records. A scanned authored matcher is retained only when it is an ordinary structural
slot or a self-indexed matcher; duplicate authored slots remain distinct and ordered.

Source correlation groups parsed body elements by their one-based authored line and scans the complete trimmed
member, including multiline blocks. It must not use the short Julia element fragments (`/a/`, `-> Child[0]`, or
`E`) as the final source range. The retained source map already reproduces all 14 neutral graph/privacy/failed/
runtime source references exactly, including Unicode UTF-8 byte ranges, Unicode-scalar columns, excerpts, and
digests. Stable record ids percent-escape strict UTF-8 bytes with uppercase hex.

The graph topology is exact: spec declares two rules and contains one source; rule containment owns two Child
slots, two Top edges, and one Top lifecycle; the two edges dispatch to Child and select slots 0/1. Entry evidence
is one decision plus two ordered explanation steps, with both `explained_by` relations citing `rule:Top`. The
runtime-static topology retains one rule, two self slots, two edges, and their `selects_regex` relations without
redundant self `dispatches_to` relations. Both privacy targets retain the same four records/three relations while
the snapshot fixes the construction ceiling and digest availability.

The failed foundation remains unchanged at native `bare_edge_target_undefined` / `normalize_edges` with
`rule_label=Top` and `target=Missing`. Only the private projector maps it to `unknown_rule_reference` / `compile`,
neutral rule ids/fields/message, one dependency-resolution decision, one explanation, one `diagnoses` relation,
and one `explained_by` relation whose evidence is `diagnostic:compile:0`. Because validation fails before compiled
authored-definition state is built, the failed spec/rule rows come directly from parsed rules, not from the empty
foundation authored-definition tuple.

Projection storage must be immutable internally and every test/query-facing copy must be recursively detached.
The private source-reference table may retain complete correlation evidence, but no public projection accessor is
added here; later query code alone applies requested `none`/`identity`/`span`/`text` detail beneath the immutable
construction ceiling. Paths, `SpecFile`, `CompiledSpec`, AST/ActionIR objects, regex objects, descriptors,
generated implementation source, executors, trace, diagnostic sinks, and runtime observers cannot cross the
projection boundary.

Implementation order is fixed: `.10.6.3.1` owns compiled graph/source/evidence and exact graph equality;
`.10.6.3.2` owns both privacy ceilings, failure normalization, runtime-static absence, clone isolation, repeated-
lifecycle occurrence safety, and host-leak denial; `.10.6.3.3` recomposes all five targets and closes the parent.
The plan adds no production/test/fixture/API/query/trace/runtime-observation/format behavior and does not promote
semantic rollout or native admission.

Signoff is exact: direct probes cover all five targets and 14 source references; focused source/outcome is 220;
complete Julia is 7,762/primary/105; the primary matrix is 5x2x66 and every Unicode manifest leg passes. Unicode,
semantic, capability, generated, and public ledgers remain 806/9/8/2, 6/20/81 at 4/9 + 3/6, 80/0/0,
v1/10/80-0-0, and 59/27/0. Knowledge Map 683/5,188, mdBook, four doctrines, canonical Rust admission 78.75s,
Dart 1/1, reference primary 66x2, Phase 0 1,031/632s, and exact 1.56-GB cleanup preserving 517 Pgen artifacts
pass. Graph implementation `.10.6.3.1` follows only after the clean plan commit.

See [[julia-semantic-introspection-authority-map]], [[semantic-introspection-neutral-contract]],
[[semantic-introspection-static-rule-authority]], [[perl-semantic-static-projection]],
[[rust-semantic-static-projection]], and [[dart-semantic-introspection-authority-map]].
