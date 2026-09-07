---
id: perl-semantic-call-staged-projection
title: Perl semantic call projection composes typed ActionIR, staged records, and generated-v2 identity
answers:
  - "does the Perl semantic index project functions helpers calls and bindings"
  - "how are Perl semantic call records ordered"
  - "how does Perl semantic introspection infer call return shapes"
  - "how does Perl semantic introspection represent function body staging"
  - "where does the Perl semantic generated plan family come from"
  - "are Perl function descriptor source spans bytes or characters"
  - "why does the Perl semantic source scan mask function definitions"
  - "does Perl semantic call projection expose ActionIR or generated source"
  - "what does semantic_index_perl_calls_projection test"
  - "are Perl semantic capabilities and query public after calls projection"
date: 2026-09-07
status: current private compiled projection; public query/runtime layers and composed admission added separately
tags: [perl, semantic-introspection, actionir, calls, bindings, staging, generated-source, unicode]
evidence: perl/LinkedSpec/SemanticCallProjection.pm; perl/LinkedSpec/SemanticStaticProjection.pm; perl/LinkedSpec/GeneratedSource.pm; t/semantic_index_perl_calls_projection.t; FUTURE-PARITY-BACKLOG.10.3.3.1.1
reverify: bash tools/project_data_run.sh env PERL5LIB= prove -Iperl t/semantic_index_perl_calls_projection.t && bash tools/run_python_project_data.sh tools/check_semantic_introspection_contract.py && bash tools/project_data_run.sh env PERL5LIB= perl tools/check_generated_source_contract.pl
---

`LinkedSpec::semantic_index(...)` now retains the corrected calls snapshot's complete private compiled projection.
`SemanticCallProjection` combines descriptor function order/signatures, source-preorder typed ActionIR calls and
bindings, function-body staged sidecars, and generated-source-v2 identity. After internal source refs are
materialized, all 22 records and 25 relations deep-equal `linkedspec-semantic-model-v1`: function/helper/call/
binding records, contract-bounded value and target shapes, exact user-function resolution evidence, separate
payload/parse-job/result records, and the `default` generated handler plan.

Traversal is deterministic authored preorder: definitions are merged by source position, statements retain order,
and an outer call precedes nested arguments. Registered user functions are resolved before helper fallback. Shape
inference is deliberately limited to typed literals, bindings, registered function returns, and the governed
semantic helper vocabulary; anything else stays `unknown`. Staged records preserve `contains`, `consumes`,
`produces`, `lowered_from`, and `staged_by` direction. Generated family and contract identity come from shared
`LinkedSpec::GeneratedSource` owners also used by the compiler; no implementation source is generated or retained.

Perl function registry `source_span`/`body_span` values and ActionIR-local spans are character offsets. The source
map performs the only conversion to strict UTF-8 byte offsets and one-based Unicode-scalar columns when it builds
a source reference. A multibyte prefix regression locks this boundary. The semantic scanner also masks descriptor-
owned top-level function ranges while preserving newlines before classifying original rule text, matching the
compiler's function-blanked rule input and preventing an interleaved `fn` shell from becoming a synthetic edge.

Every retained result is cloned plain data. Descriptor coderefs/compiled regexes, raw function records, ActionIR
layouts, generated implementation text, object identity, and paths do not cross the boundary. Public
`capabilities`/`query` are supplied by `.10.3.4`; `.10.3.5` adds runtime observations without changing this
compiled layer; `.10.3.6` admits their composition through one exact consumer. This layer remains the only
compiled-call projection.

Related facts: [[perl-semantic-static-projection]], [[perl-semantic-introspection-authority-map]],
[[perl-semantic-query-evaluator]], [[perl-semantic-runtime-observation]],
[[perl-semantic-introspection-admission]],
[[semantic-introspection-staged-artifact-schema]], [[semantic-introspection-generated-plan-authority]],
[[outward-descriptor-is-not-semantic-wire-model]].

## September 6 source-reading boundary

`SESSION-STARTUP-READING.3.2.42` reads all 753 SemanticCallProjection lines and all 395 SemanticIndex
lines at unchanged baseline baeb984e. The source retains authored definition merging, bounded fixed-point
function-shape inference, typed call preorder, independent staged provenance, and shared generated-v2
identity. Three focused foundation/call/query suites pass twenty tests collectively.

The projection description above concerns its supported compiled-call path. An empty function registry
still returns before rule-call traversal, so helper-only rules can lose call and binding records.
That independently reproduced defect remains `.22`-owned in
[[semantic-rule-calls-empty-function-gate]]; passing the existing call snapshot does not close it.

## September 7 independent call evidence controls

`SESSION-STARTUP-READING.3.3.31` reproduces two further gaps on paired Rust/Perl public queries:
zero/two-argument calls receive signature-acceptance evidence despite their declared fixed arity of one,
and an array-wrapped trim call is omitted while direct/nested-call controls remain present. Rust additionally
omits that array binding's source; Perl preserves its RHS source. Six Perl Get controls confirm the array
call executes and returns ["x"]. New .67 owns distinct compatibility-evidence and composite-traversal repairs;
see [[semantic-call-signature-and-container-projection-gaps]] for exact sources, assertions and limits.
Fresh neutral semantic 6/20/128, rollout9/0 and admission6/0 remain green; those fixtures do not close these cases.
