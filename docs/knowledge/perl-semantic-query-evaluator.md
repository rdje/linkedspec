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
date: 2026-07-21
status: current static native query surface; runtime observations, routes, and admission pending
tags: [perl, semantic-introspection, query, capabilities, privacy, pagination, budgets, immutability]
evidence: perl/LinkedSpec/SemanticQuery.pm; perl/LinkedSpec/SemanticIndex.pm; t/semantic_index_perl_query.t; FUTURE-PARITY-BACKLOG.10.3.4
reverify: PERL5LIB= prove -Iperl t/semantic_index_perl_query.t && python3 tools/check_semantic_introspection_contract.py
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

The focused test matches all 19 static neutral response SHA-256 digests byte-for-byte; only the `runtime_events`
case remains owned by `.10.3.5`. It also exercises 26 request/error boundaries, including the JSON-boolean type
fence, mutates returned answers, replaces the compiler entrypoint with a die during a successful query, captures
stdout/stderr, and scans encoded answers for
paths and host object identities. Runtime observations/routes and composed Perl admission remain absent, so neutral
rollout stays 1/9 and native backend admission stays 0/6.

Canonical signoff passes both primary CLI environments at 66/66 and Phase 0 at 1,031/1,031 in 643 seconds. The
complete local gate exits 0 with capability 80/0/0 and semantic governance 6/20/57 unchanged.

Related facts: [[semantic-introspection-neutral-contract]], [[perl-semantic-static-projection]],
[[perl-semantic-call-staged-projection]], [[perl-semantic-introspection-authority-map]].
