---
id: perl-semantic-static-projection
title: Perl semantic static records compose descriptor, source, and failure authorities
answers:
  - "does the Perl semantic index retain static records"
  - "which authority owns Perl semantic rule and edge records"
  - "how are Perl semantic regex slot ids kept distinct"
  - "how does Perl semantic introspection normalize unknown rule failures"
  - "does a self-indexed semantic edge dispatch to its own rule"
  - "are Perl semantic capabilities and query public yet"
  - "what does semantic_index_perl_static_projection test"
date: 2026-07-21
status: current private static foundation; public query/runtime layers and composed admission added separately
tags: [perl, semantic-introspection, records, relations, source-map, diagnostics, immutability]
evidence: perl/LinkedSpec/SemanticStaticProjection.pm; perl/LinkedSpec/SemanticCallProjection.pm; perl/LinkedSpec/SemanticIndex.pm; t/semantic_index_perl_static_projection.t; t/semantic_index_perl_calls_projection.t; FUTURE-PARITY-BACKLOG.10.3.2.1; FUTURE-PARITY-BACKLOG.10.3.3.1.1
reverify: PERL5LIB= prove -Iperl t/semantic_index_perl_static_projection.t && bash tools/run_python_project_data.sh tools/check_semantic_introspection_contract.py
---

`LinkedSpec::semantic_index(...)` now retains a private clone-safe static projection. The descriptor owns compiled
rule order, family/cursor/repetition, edge ownership, and resolved topology; accepted decoded source plus
`SemanticSourceMap` owns authored direct/indexed forms and exact UTF-8 ranges; runtime context owns failed-
compilation fields. The projector normalizes those authorities into v1 spec/source/rule/regex-slot/edge/lifecycle/
diagnostic/decision/explanation records and static relations without serializing coderefs, compiled regexes, AST/
IR layouts, object identities, or paths.

Duplicate regex patterns retain separate zero-based authored slot ids. Indexed edges select the named slot; a
self-indexed edge has `selects_regex` but no redundant `dispatches_to` self-relation. Failed default-family bare
edges retain `action` intent and normalize `bare_edge_target_undefined` to portable `unknown_rule_reference` with
source-aware decision/explanation evidence. Neutral booleans remain `JSON::PP::Boolean` values through immutable
copying.

The focused static test deep-compares graph, privacy full/limited, failed compilation, and the runtime fixture's
static half with `linkedspec-semantic-model-v1` after materializing source refs. Compiled sources with functions now
delegate their typed call/binding/staged/generated rows to the separately tested call projection. Public
`capabilities`/`query` are supplied by `.10.3.4`; execution observations are an additive derived layer supplied by
`.10.3.5`; one exact consumer admits their composition in `.10.3.6`. MCP and later backends remain separate. See
[[perl-semantic-index-source-foundation]], [[perl-semantic-query-evaluator]],
[[perl-semantic-runtime-observation]],
[[perl-semantic-introspection-admission]],
[[perl-semantic-call-staged-projection]], [[semantic-introspection-static-rule-authority]], and
[[semantic-introspection-neutral-contract]].
