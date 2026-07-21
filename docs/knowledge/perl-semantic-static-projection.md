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
status: current private static foundation; compiled call layer added separately; public query and admission pending
tags: [perl, semantic-introspection, records, relations, source-map, diagnostics, immutability]
evidence: perl/LinkedSpec/SemanticStaticProjection.pm; perl/LinkedSpec/SemanticCallProjection.pm; perl/LinkedSpec/SemanticIndex.pm; t/semantic_index_perl_static_projection.t; t/semantic_index_perl_calls_projection.t; FUTURE-PARITY-BACKLOG.10.3.2.1; FUTURE-PARITY-BACKLOG.10.3.3.1.1
reverify: PERL5LIB= prove -Iperl t/semantic_index_perl_static_projection.t && python3 tools/check_semantic_introspection_contract.py
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
`capabilities`/`query`, execution observations, composed admission, and MCP remain later leaves; rollout stays 1/9
and native admission 0/6. See [[perl-semantic-index-source-foundation]],
[[perl-semantic-call-staged-projection]], [[semantic-introspection-static-rule-authority]], and
[[semantic-introspection-neutral-contract]].
