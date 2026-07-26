---
id: semantic-source-ceiling-boundary
title: Semantic source ceilings govern outward query projection, not private authority retention
answers:
  - "does a semantic identity construction ceiling delete private source spans excerpts and digests"
  - "where is semantic source detail redaction applied"
  - "why does the privacy_limited private oracle contain full source references"
  - "may a semantic static projector retain source text above the caller query ceiling"
  - "what does source_detail_ceiling mean in a semantic snapshot"
  - "when must semantic source limits be applied before records leave the native API"
  - "how do Perl Rust Dart and Julia redact semantic source references"
  - "what Lua task corrected the private retention versus outward redaction boundary"
date: 2026-07-25
status: current contract clarification; behavior unchanged
tags: [semantic-introspection, privacy, source-map, query, static-projection, lua, FUTURE-PARITY-BACKLOG]
evidence: "ADR 0049 section 5; capability_conformance/semantic_introspection_model.json privacy_limited; Perl/Rust/Dart/Julia private static projectors and semantic query source projectors; FUTURE-PARITY-BACKLOG.10.7.3.2.0"
reverify: "python3 tools/check_semantic_introspection_contract.py; rg -n 'project_source|_project_source|_semantic_query_project_source|_projectSemanticQuerySource|register_source|_registerSemanticSource' perl/LinkedSpec/SemanticQuery.pm rust/linkedspec-runtime/src/semantic_index dart/lib/src/semantic julia/src/semantic"
---

# Semantic Source Ceiling Boundary

ADR `0049` defines source privacy at the native query boundary. A semantic index records the caller-selected
`none`/`identity`/`span`/`text` ceiling and digest availability in its snapshot. A query request above that ceiling
fails with `semantic_query_source_detail_forbidden`; an accepted request structurally projects each private source
reference to the requested detail before any semantic record leaves the native API.

The private static projection intentionally retains full authoritative source references: logical identity, exact
span, excerpt, content digest, and provenance. This is why the neutral `privacy_limited` construction oracle still
contains complete private `source_refs` while its snapshot says `source_detail_ceiling=identity` and
`content_digest_available=false`. The oracle describes construction authority, not a public query response. The
package-private exact-oracle seam used by backend tests is not a public bypass.

All four admitted backends implement the same split:

- Perl `_project_source`, Rust `project_source`, Dart `_projectSemanticQuerySource`, and Julia
  `_semantic_query_project_source` read complete private source authority;
- `none` returns no source, `identity` returns source id/logical name only, `span` adds coordinates, and `text`
  adds excerpt plus an explicitly requested digest; and
- each query validator rejects detail or digest requests that exceed the snapshot ceiling before projection.

Deleting private span/text/digest fields at construction would contradict the exact private oracle and prevent a
single immutable projection from serving multiple allowed query detail levels. Exposing those fields through a
public constructor, record accessor, debug string, or query above the ceiling would still be a privacy defect.
Lua correction leaf `FUTURE-PARITY-BACKLOG.10.7.3.2.0` fixes only the active acceptance wording before remaining-
target implementation; it changes no production behavior, fixture, record, response, format, rollout, or admission.

See [[semantic-introspection-neutral-contract]], [[lua-semantic-static-projection-plan]],
[[perl-semantic-static-projection]], [[rust-semantic-static-projection]], and
[[julia-semantic-static-projection-plan]].
