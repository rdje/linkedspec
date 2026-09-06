---
id: perl-semantic-query-evaluator
title: Perl exposes the exact immutable static semantic query surface
answers:
  - "are Perl semantic capabilities and query public now"
  - "which Perl semantic query operations are implemented"
  - "how many semantic query response digests does Perl match"
  - "does a Perl semantic query compile or execute a parser"
  - "does Perl semantic query read a source path or enable trace"
  - "how does Perl semantic query enforce source privacy"
  - "how does Perl semantic query page relation traversal"
  - "how are Perl semantic query budgets and costs counted"
  - "what does semantic_index_perl_query test"
  - "is Perl semantic introspection admitted after query implementation"
date: 2026-09-06
status: current admitted native query evaluator; runtime projection remains separately derived
tags: [perl, semantic-introspection, query, capabilities, privacy, pagination, budgets, immutability]
evidence: perl/LinkedSpec/SemanticQuery.pm; perl/LinkedSpec/SemanticIndex.pm; t/semantic_index_perl_query.t; FUTURE-PARITY-BACKLOG.10.3.4
reverify: bash tools/project_data_run.sh env PERL5LIB= prove -Iperl t/semantic_index_perl_query.t && bash tools/run_python_project_data.sh tools/check_semantic_introspection_contract.py
---

`LinkedSpec::semantic_index(...)` now returns an opaque object with public `$index->capabilities` and
`$index->query($request)` methods. `capabilities` is the canonical v1 capabilities operation. The lazy query owner
receives only a cloned plain-data projection; it never receives descriptor coderefs, compiled regexes, the source
mapper, decoded source, a path, or a parser execution seam.

The evaluator implements exact `capabilities`, `list`, `get`, `relations`, and `explain` envelopes. It applies
canonical record/relation order, after-id paging, relation-kind-filtered directional breadth-first traversal,
record/relation/depth budget prefixes, logical costs, source `none`/`identity`/`span`/`text` projection, structural
fact redaction, digest ceilings, and portable invalid/unsupported/forbidden/budget diagnostics. Responses and
capabilities are fresh clone-safe plain data on every call.

The focused test matches all 19 static neutral response SHA-256 digests byte-for-byte. Runtime leaf `.10.3.5` now
feeds the same evaluator a separately derived immutable projection and matches the twentieth `runtime_events`
digest; see [[perl-semantic-runtime-observation]]. The static test also exercises 26 request/error boundaries,
including the JSON-boolean type
fence, mutates returned answers, replaces the compiler entrypoint with a die during a successful query, captures
stdout/stderr, and scans encoded answers for
paths and host object identities. Composed Perl admission `.10.3.6` reuses this evaluator for every one of the 20
exact responses. At that July 21 milestone, only Perl advanced: rollout was 2/9 and native admission 1/6.
The September 6 canonical proof is complete at 9/9 rollout and 6/6 admission with 128 neutral mutations.

The July 21 signoff passed both primary CLI environments at 66/66 and Phase 0 at 1,031/1,031 in 643 seconds;
its capability 80/0/0 and semantic governance 6/20/57 are dated historical measurements. The September 6
`.3.2.41` canonical gate instead passes Phase 0 1,032/1,032, capability 100/0/0, and semantic 6/20/128,
with both CLI environments still 66/66. These counts describe their respective measured candidates.

Related facts: [[semantic-introspection-neutral-contract]], [[perl-semantic-static-projection]],
[[perl-semantic-call-staged-projection]], [[perl-semantic-introspection-authority-map]].
See also [[perl-semantic-introspection-admission]].

## September 6 complete query-owner reading

`SESSION-STARTUP-READING.3.2.43` reads all 596 query-owner lines at unchanged baseline baeb984e.
Validation, independent projection clones, source redaction, canonical paging, relation traversal, and
explanation evidence stay in the existing native owner. The preceding canonical query suite passes nine
top-level tests; its exact test and contract inputs remain unchanged at this checkpoint.

Explain accounting was compared with the neutral evaluator: it reserves one record for the decision
and selects evidence by the remaining record budget; its explained_by relations and depth-one cost follow
the neutral operation. This comparison establishes agreement of those implementations, not a new general
budget contract or proof that every possible request is covered. Relation traversal has its own separate
record/relation/depth accounting. No query behavior is changed by this reading checkpoint.
